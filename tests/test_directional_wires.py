import copy
import itertools
import json
from pathlib import Path
import unittest

from tools.validate_levels import find_solution, is_solved, movable, validate_structure

ROOT = Path(__file__).resolve().parents[1]


def branch_fixture(rotation=0, fixed=False):
    return {"id": 0, "size": 2, "time_limit": 90, "source_index": 0, "source_port": 8,
            "target_index": 1, "target_port": 2, "required_nodes": [2],
            "cells": [{"kind": "tee", "rotation": 2, "fixed": True},
                      {"kind": "straight", "rotation": 1, "fixed": True},
                      {"kind": "diode", "rotation": rotation, "fixed": fixed},
                      {"kind": "empty", "rotation": 0}]}


class DirectionalWireTests(unittest.TestCase):
    def test_four_directions_require_entry_on_the_tail_of_the_arrow(self):
        for source, middle, target, source_port, target_port, expected in (
                (0, 1, 2, 8, 2, 1), (2, 5, 8, 1, 4, 2),
                (8, 7, 6, 2, 8, 3), (6, 3, 0, 4, 1, 0)):
            for rotation in range(4):
                data = {"size": 3, "source_index": source, "source_port": source_port,
                        "target_index": target, "target_port": target_port,
                        "cells": [{"kind": "empty", "rotation": 0} for _ in range(9)]}
                for i in (source, target):
                    data["cells"][i] = {"kind": "straight", "rotation": expected % 2, "fixed": True}
                data["cells"][middle] = {"kind": "diode", "rotation": rotation}
                self.assertEqual(is_solved(data), rotation == expected)
                self.assertEqual(find_solution(data)["minimum_taps"], (expected - rotation) % 4)

    def test_reverse_arrow_on_lamp_branch_requires_two_taps(self):
        data = branch_fixture()
        self.assertFalse(is_solved(data))
        self.assertEqual(find_solution(data)["minimum_taps"], 2)
        data["cells"][2]["rotation"] = 2
        self.assertTrue(is_solved(data))
        self.assertIsNone(find_solution(branch_fixture(fixed=True)))

    def test_direction_and_branch_minimum_agree_with_exhaustive_oracle(self):
        for seed, lamps, source_fixed in itertools.product(range(4), ([2], [2, 3]), (True, False)):
            data = branch_fixture(seed)
            data["required_nodes"] = lamps
            data["cells"][0]["fixed"] = source_fixed
            data["cells"][3] = {"kind": "tee", "rotation": (seed + 1) % 4}
            choices = [range(4) if movable(c) else (0,) for c in data["cells"]]
            minimum = None
            for turns in itertools.product(*choices):
                rotations = [(c["rotation"] + t) % 4 for c, t in zip(data["cells"], turns)]
                if is_solved(data, rotations):
                    minimum = sum(turns) if minimum is None else min(minimum, sum(turns))
            result = find_solution(data)
            self.assertEqual(None if result is None else result["minimum_taps"], minimum)

    def test_source_and_target_also_obey_direction(self):
        data = {"size": 2, "source_index": 0, "source_port": 8, "target_index": 1, "target_port": 2,
                "cells": [{"kind": "diode", "rotation": 1}, {"kind": "diode", "rotation": 1},
                          {"kind": "empty", "rotation": 0}, {"kind": "empty", "rotation": 0}]}
        self.assertTrue(is_solved(data))
        for index in (0, 1):
            reverse = copy.deepcopy(data)
            reverse["cells"][index].update(rotation=3, fixed=True)
            self.assertFalse(is_solved(reverse))
            self.assertIsNone(find_solution(reverse))

    def test_directed_cycle_terminates_and_can_feed_lamp_from_either_valid_side(self):
        data = {"size": 3, "source_index": 0, "source_port": 1, "target_index": 6, "target_port": 4,
                "required_nodes": [1], "cells": [
                    {"kind": kind, "rotation": r, "fixed": index != 1}
                    for index, (kind, r) in enumerate((
                        ("tee", 1), ("diode", 0), ("curve", 2), ("straight", 0), ("empty", 0),
                        ("straight", 0), ("tee", 1), ("straight", 1), ("curve", 3)))]}
        for rotation in range(4):
            data["cells"][1]["rotation"] = rotation
            self.assertEqual(is_solved(data), rotation in (1, 3))
            self.assertEqual(find_solution(data)["minimum_taps"], 0 if rotation in (1, 3) else 1)

    def test_only_authored_stages_gain_directional_wires(self):
        for number in range(1, 25):
            data = json.loads((ROOT / f"levels/level_{number:02d}.json").read_text(encoding="utf-8"))
            validate_structure(data)
            self.assertEqual(any(c["kind"] == "diode" for c in data["cells"]), number in (13, 14, 16))
            if number in (13, 14, 16):
                self.assertEqual(data["rules_revision"], 2)
                self.assertEqual(data["time_limit"], 180)
