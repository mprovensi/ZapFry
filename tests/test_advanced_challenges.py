import copy
import itertools
import json
from pathlib import Path
import unittest

from tools.validate_levels import apply_action, find_solution, is_solved, action_indices, action_period, validate_structure


def alarm_fixture(fixed=False):
    return {"id": 0, "size": 2, "time_limit": 90, "source_index": 0, "source_port": 8,
            "target_index": 1, "target_port": 2, "forbidden_nodes": [2], "cells": [
                {"kind": "tee", "rotation": 2, "fixed": True},
                {"kind": "straight", "rotation": 1, "fixed": True},
                {"kind": "straight", "rotation": 0, "fixed": fixed},
                {"kind": "empty", "rotation": 0}]}


def switch_fixture():
    return {"id": 0, "size": 2, "time_limit": 90, "source_index": 0, "source_port": 8,
            "target_index": 3, "target_port": 2, "cells": [
                {"kind": "curve", "rotation": 2, "fixed": True}, {"kind": "empty", "rotation": 0},
                {"kind": "switch", "rotation": 1, "switch_masks": [3, 9]},
                {"kind": "straight", "rotation": 1, "fixed": True}]}


def pair_fixture(turns=1):
    cells = [{"kind": "empty", "rotation": 0} for _ in range(9)]
    for index, kind, rotation, fixed in ((0, "curve", 2, True), (3, "curve", (-turns) % 4, False),
                                        (4, "straight", 1, True), (5, "curve", (2-turns) % 4, False),
                                        (8, "curve", 0, True)):
        cells[index] = {"kind": kind, "rotation": rotation, "fixed": fixed}
    return {"id": 0, "size": 3, "time_limit": 90, "source_index": 0, "source_port": 8,
            "target_index": 8, "target_port": 2, "linked_groups": [[3, 5]], "cells": cells}


def output_fixture():
    data = alarm_fixture()
    data.pop("forbidden_nodes")
    data["required_outputs"] = [{"index": 2, "port": 8}]
    data["cells"][2] = {"kind": "curve", "rotation": 0}
    return data


class AdvancedChallengeTests(unittest.TestCase):
    def test_campaign_distribution_and_regeneration_preserve_all_mechanics(self):
        import sys
        root = Path(__file__).resolve().parents[1]
        sys.path.insert(0, str(root / "tools"))
        from tools.create_six_by_six_levels import SPECS, make_level
        for spec in SPECS:
            data = json.loads((root / f"levels/level_{spec['id']:02d}.json").read_text(encoding="utf-8"))
            self.assertEqual(make_level(spec, width=6), data)
            number = spec["id"]
            self.assertEqual(bool(data.get("forbidden_nodes")), number in (18, 19, 20))
            self.assertEqual(any(c["kind"] == "switch" for c in data["cells"]), number == 21)
            self.assertEqual(bool(data.get("linked_groups")), number == 23)
            self.assertEqual(bool(data.get("required_outputs")), number == 24)
            self.assertEqual(data.get("rules_revision", 1), 1 if number in (17, 22) else 2)

    def test_alarm_with_two_power_paths_requires_cutting_both(self):
        data = {"size": 3, "source_index": 0, "source_port": 1, "target_index": 2, "target_port": 2,
                "forbidden_nodes": [4], "cells": [{"kind": "empty", "rotation": 0} for _ in range(9)]}
        for index, kind, rotation, fixed in ((0, "tee", 1, True), (1, "tee", 2, False),
                                            (2, "straight", 1, True), (3, "curve", 0, False), (4, "tee", 0, True)):
            data["cells"][index] = {"kind": kind, "rotation": rotation, "fixed": fixed}
        self.assertEqual(find_solution(data)["minimum_taps"], 3)

    def test_alarm_on_side_branch_is_recoverable_by_rotating_outside_main_path(self):
        data = alarm_fixture()
        self.assertFalse(is_solved(data))
        result = find_solution(data)
        self.assertEqual(result["minimum_taps"], 1)
        self.assertEqual(result["moves"], [2])
        self.assertIsNone(find_solution(alarm_fixture(fixed=True)))

    def test_alarm_requires_alternate_tee_orientation_even_when_out_already_works(self):
        data = {"size": 3, "source_index": 0, "source_port": 8, "target_index": 2, "target_port": 2,
                "forbidden_nodes": [4], "cells": [{"kind": "empty", "rotation": 0} for _ in range(9)]}
        for index in (0, 2):
            data["cells"][index] = {"kind": "straight", "rotation": 1, "fixed": True}
        data["cells"][1] = {"kind": "tee", "rotation": 2}
        data["cells"][4] = {"kind": "straight", "rotation": 0, "fixed": True}
        self.assertEqual(find_solution(data)["minimum_taps"], 2)

    def test_switch_has_two_states_and_costs_one_action_from_b_to_a(self):
        data = switch_fixture()
        self.assertEqual(find_solution(data)["minimum_taps"], 1)
        state = [c["rotation"] for c in data["cells"]]
        apply_action(data, state, 2)
        self.assertEqual(state[2], 0)
        self.assertTrue(is_solved(data, state))
        apply_action(data, state, 2)
        self.assertEqual(state[2], 1)

    def test_pair_counts_once_and_both_members_are_valid_click_targets(self):
        for turns in range(1, 4):
            data = pair_fixture(turns)
            self.assertEqual(find_solution(data)["minimum_taps"], turns)
            for index in (3, 5):
                state = [c["rotation"] for c in data["cells"]]
                for _ in range(turns):
                    apply_action(data, state, index)
                self.assertTrue(is_solved(data, state))

    def test_second_equipment_requires_its_output_port_not_just_power_in_cell(self):
        data = output_fixture()
        self.assertFalse(is_solved(data))
        self.assertEqual(find_solution(data)["minimum_taps"], 3)

    def test_minimum_agrees_with_exhaustive_actions_not_cell_rotation_sum(self):
        fixtures = json.loads((Path(__file__).parent / "fixtures/advanced_challenges.json").read_text(encoding="utf-8"))
        for base in (fixture["state"] for fixture in fixtures):
            for seed in range(4):
                data = copy.deepcopy(base)
                initial = [c["rotation"] for c in data["cells"]]
                actions = action_indices(data)
                for index in actions:
                    for _ in range(seed % action_period(data, index)):
                        apply_action(data, initial, index)
                for cell, rotation in zip(data["cells"], initial):
                    cell["rotation"] = rotation
                minimum = None
                for turns in itertools.product(*(range(action_period(data, i)) for i in actions)):
                    state = initial.copy()
                    for index, count in zip(actions, turns):
                        for _ in range(count):
                            apply_action(data, state, index)
                    if is_solved(data, state):
                        minimum = sum(turns) if minimum is None else min(minimum, sum(turns))
                result = find_solution(data)
                self.assertEqual(None if result is None else result["minimum_taps"], minimum)

    def test_new_data_rejects_conflicts_and_invalid_components(self):
        def complete(data):
            data = copy.deepcopy(data)
            data.update(id=1, name="Teste", instruction="Ligue os objetivos.", tip_lines=["Uma dica.", "Outra dica."], guided=False)
            for cell in data["cells"]:
                cell["solution"] = cell["rotation"]
            return data
        mutations = [
            (alarm_fixture(), "forbidden_nodes", [2, 2]),
            (alarm_fixture(), "forbidden_nodes", [True]),
            (alarm_fixture(), "forbidden_nodes", [3]),
            (pair_fixture(), "linked_groups", [[3, 5], [5, 3]]),
            (pair_fixture(), "linked_groups", [[3, 4]]),
            (pair_fixture(), "linked_groups", [[3, 3]]),
            (output_fixture(), "required_outputs", [{"index": 2, "port": 2}]),
            (output_fixture(), "required_outputs", [{"index": 2, "port": 8}, {"index": 2, "port": 8}]),
        ]
        for base, field, value in mutations:
            data = complete(base)
            data[field] = value
            with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                validate_structure(data)
        data = complete(alarm_fixture())
        data["required_nodes"] = [2]
        with self.assertRaises(ValueError):
            validate_structure(data)
        for masks in ([3, 3], [3, 12], [True, 9], [3, 17]):
            data = complete(switch_fixture())
            data["cells"][2]["switch_masks"] = masks
            with self.assertRaises(ValueError):
                validate_structure(data)
