import copy
import itertools
import json
from pathlib import Path
import unittest

from tools.validate_levels import audit_campaign, audit_level, find_solution, is_solved, movable, validate_structure

ROOT = Path(__file__).resolve().parents[1]


class LevelPlayabilityTests(unittest.TestCase):
    def setUp(self):
        self.first = json.loads((ROOT / "levels/level_01.json").read_text(encoding="utf-8"))

    def test_every_campaign_level_has_a_playable_solution(self):
        reports = audit_campaign()
        self.assertEqual(len(reports), 24)
        self.assertEqual([r["size"] for r in reports], [4] * 8 + [5] * 8 + [6] * 8)
        self.assertEqual([r["minimum_taps"] for r in reports], [1, 2, 4, 6, 8, 8, 9, 10, 6] + list(range(12, 41, 2)))
        for report in reports:
            with self.subTest(level=report["id"]):
                self.assertGreater(report["minimum_taps"], 0)
                self.assertEqual(len(report["moves"]), report["minimum_taps"])
                if report["time_limit"]:
                    self.assertLess(report["simulated_seconds"] + 30, report["time_limit"])

    def test_solver_ignores_authored_reference(self):
        expected = find_solution(self.first)
        altered = copy.deepcopy(self.first)
        altered.pop("reference_path")
        altered.pop("reference_taps")
        for cell in altered["cells"]:
            cell.pop("solution")
        self.assertEqual(find_solution(altered), expected)

    def test_fixed_broken_connector_is_detected_as_impossible(self):
        self.first["cells"][1]["fixed"] = True
        self.assertIsNone(find_solution(self.first))
        with self.assertRaisesRegex(ValueError, "Não existe solução"):
            audit_level(self.first)

    def test_burnt_fuse_on_only_route_is_impossible(self):
        self.first["cells"][1] = {"kind": "blocker", "rotation": 0, "solution": 0, "fixed": True}
        self.assertIsNone(find_solution(self.first))

    def test_wrong_target_port_is_not_treated_as_victory(self):
        self.first["target_port"] = 1  # A borda é válida; a peça fixa não tem porta norte.
        self.assertIsNone(find_solution(self.first))

    def test_already_solved_level_is_rejected(self):
        self.first["cells"][1]["rotation"] = 1
        with self.assertRaisesRegex(ValueError, "começa resolvida"):
            audit_level(self.first)

    def test_invalid_data_is_rejected(self):
        mutations = [lambda d: d["cells"].pop(),
                     lambda d: d["cells"][1].update(kind="unknown"),
                     lambda d: d["cells"][1].update(rotation=4),
                     lambda d: d.update(target_port=3),
                     lambda d: d.update(source_index=-1),
                     lambda d: d.update(time_limit=float("nan")),
                     lambda d: d.update(tip_lines=[])]
        for mutation in mutations:
            data = copy.deepcopy(self.first)
            mutation(data)
            with self.subTest(data=data), self.assertRaises(ValueError):
                validate_structure(data)

    def test_bad_authored_path_is_rejected_even_when_board_is_solvable(self):
        self.first["reference_path"] = [0, 3]
        self.assertIsNotNone(find_solution(self.first))
        with self.assertRaisesRegex(ValueError, "Referência"):
            audit_level(self.first)

    def test_tee_and_fuse_are_introduced_separately(self):
        levels = [json.loads((ROOT / f"levels/level_{i:02d}.json").read_text(encoding="utf-8")) for i in (6, 7, 8)]
        kinds = [{c["kind"] for c in d["cells"]} for d in levels]
        self.assertIn("tee", kinds[0])
        self.assertNotIn("blocker", kinds[0])
        self.assertIn("blocker", kinds[1])
        self.assertNotIn("tee", kinds[1])
        self.assertTrue({"tee", "blocker"} <= kinds[2])

    def test_first_five_by_five_is_guided_and_untimed(self):
        data = json.loads((ROOT / "levels/level_09.json").read_text(encoding="utf-8"))
        self.assertEqual(data["size"], 5)
        self.assertTrue(data["guided"])
        self.assertEqual(data["time_limit"], 0)
        self.assertEqual(audit_level(data)["minimum_taps"], 6)

    def test_board_border_cannot_wrap_between_rows(self):
        for width in (4, 5, 6):
            data = {"size": width, "source_index": width - 1, "source_port": 2, "target_index": width, "target_port": 8,
                    "cells": [{"kind": "empty", "rotation": 0} for _ in range(width * width)]}
            data["cells"][width - 1] = {"kind": "straight", "rotation": 1, "fixed": True}
            data["cells"][width] = {"kind": "straight", "rotation": 1, "fixed": True}
            with self.subTest(width=width):
                self.assertFalse(is_solved(data))
                self.assertIsNone(find_solution(data))

    def test_final_sector_keeps_the_challenge_instead_of_restarting_tutorial(self):
        data = json.loads((ROOT / "levels/level_17.json").read_text(encoding="utf-8"))
        self.assertEqual(data["size"], 6)
        self.assertFalse(data["guided"])
        self.assertEqual(data["time_limit"], 210)
        self.assertEqual(audit_level(data)["minimum_taps"], 26)

    def test_challenge_from_level_ten_has_dense_boards_and_no_guidance(self):
        previous_minimum = 6
        for number in range(10, 25):
            data = json.loads((ROOT / f"levels/level_{number:02d}.json").read_text(encoding="utf-8"))
            report = audit_level(data)
            with self.subTest(level=number):
                self.assertFalse(data["guided"])
                self.assertGreater(data["time_limit"], 0)
                self.assertLessEqual(data["time_limit"], 225)
                self.assertGreater(report["minimum_taps"], previous_minimum)
                wires = sum(c["kind"] not in ("empty", "blocker") for c in data["cells"])
                self.assertGreaterEqual(wires - len(data["reference_path"]), 6)
                self.assertLessEqual(wires - len(data["reference_path"]), 8 if number >= 17 else 6 if number >= 11 else 16)
                self.assertTrue(all(not c.get("fixed", False) for i, c in enumerate(data["cells"])
                                    if c["kind"] not in ("empty", "blocker")
                                    and i not in (data["source_index"], data["target_index"])))
            previous_minimum = report["minimum_taps"]

    def test_level_eleven_leaves_room_to_understand_the_tee(self):
        data = json.loads((ROOT / "levels/level_11.json").read_text(encoding="utf-8"))
        self.assertEqual(audit_level(data)["minimum_taps"], 14)
        self.assertEqual(data["time_limit"], 180)
        self.assertEqual(sum(c["kind"] == "empty" for c in data["cells"]), 8)
        self.assertEqual(sum(c["kind"] == "tee" for c in data["cells"]), 1)

    def test_minimum_agrees_with_exhaustive_search_on_small_puzzles(self):
        # Oráculo simples enumera todos os estados; não usa busca por caminhos.
        fixture = {"size": 2, "source_index": 0, "source_port": 8, "target_index": 3, "target_port": 4,
                   "cells": [{"kind": "curve", "rotation": 2, "fixed": True},
                             {"kind": "empty", "rotation": 0},
                             {"kind": "curve", "rotation": 2},
                             {"kind": "curve", "rotation": 3}]}
        for kind in ("curve", "tee", "straight"):
            fixture["cells"][2]["kind"] = kind
            for rotation in range(4):
                fixture["cells"][2]["rotation"] = rotation
                minimum = None
                choices = [range(4) if movable(c) else range(1) for c in fixture["cells"]]
                for turns in itertools.product(*choices):
                    state = [(c["rotation"] + t) % 4 for c, t in zip(fixture["cells"], turns)]
                    if is_solved(fixture, state):
                        minimum = min(minimum, sum(turns)) if minimum is not None else sum(turns)
                found = find_solution(fixture)
                with self.subTest(kind=kind, rotation=rotation):
                    self.assertEqual(None if found is None else found["minimum_taps"], minimum)


if __name__ == "__main__":
    unittest.main(verbosity=2)
