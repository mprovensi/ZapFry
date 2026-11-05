import copy
import itertools
import json
from pathlib import Path
import unittest

from tools.validate_levels import find_solution, is_solved, movable, validate_structure

ROOT = Path(__file__).resolve().parents[1]


class RequiredNodesTests(unittest.TestCase):
    def fixture(self):
        return {"size": 2, "source_index": 0, "source_port": 8,
                "target_index": 1, "target_port": 2, "required_nodes": [2],
                "cells": [{"kind": "tee", "rotation": 2, "fixed": True},
                          {"kind": "straight", "rotation": 1, "fixed": True},
                          {"kind": "curve", "rotation": 1},
                          {"kind": "curve", "rotation": 2}]}

    def test_lamp_and_chair_must_share_source_at_same_time(self):
        data = self.fixture()
        self.assertFalse(is_solved(data))
        data["cells"][2]["rotation"] = 0
        self.assertTrue(is_solved(data))
        data["cells"][1]["rotation"] = 0
        self.assertFalse(is_solved(data))

    def test_lamp_can_be_on_branch_not_on_source_target_path(self):
        data = self.fixture()
        solution = find_solution(data)
        self.assertEqual(solution["minimum_taps"], 2)
        self.assertIn(2, solution["path"])

    def test_global_minimum_matches_exhaustive_orientation_oracle(self):
        # Inclui ciclos, T, duas lâmpadas, fonte móvel e terminais incompatíveis.
        for kind, lamps, fixed, seed in itertools.product(
                ("curve", "tee", "straight"), ([2], [2, 3]), (True, False), range(4)):
            data = self.fixture()
            data["required_nodes"] = lamps
            data["cells"][0]["fixed"] = fixed
            data["cells"][2].update(kind=kind, rotation=seed)
            data["cells"][3]["rotation"] = (seed + 1) % 4
            minimum = None
            choices = [range(4) if movable(c) else (0,) for c in data["cells"]]
            for turns in itertools.product(*choices):
                state = [(c["rotation"] + t) % 4 for c, t in zip(data["cells"], turns)]
                if is_solved(data, state):
                    minimum = sum(turns) if minimum is None else min(minimum, sum(turns))
            found = find_solution(data)
            with self.subTest(kind=kind, lamps=lamps, fixed=fixed, seed=seed):
                self.assertEqual(None if found is None else found["minimum_taps"], minimum)

    def test_invalid_objectives_rejected(self):
        base = json.loads((ROOT / "levels/level_10.json").read_text(encoding="utf-8"))
        for invalid in ([True], [-1], [25], [base["target_index"]], [1, 1], [1.5], "1"):
            data = copy.deepcopy(base)
            data["required_nodes"] = invalid
            with self.subTest(invalid=invalid), self.assertRaises(ValueError):
                validate_structure(data)

    def test_branch_junction_and_cycles_match_exhaustive_oracle(self):
        for seed in range(3):
            data = {"size": 3, "source_index": 0, "source_port": 8,
                    "target_index": 2, "target_port": 2, "required_nodes": [4, 7],
                    "cells": [{"kind": "straight", "rotation": 1, "fixed": True},
                              {"kind": "tee", "rotation": seed},
                              {"kind": "straight", "rotation": 1, "fixed": True},
                              {"kind": "curve", "rotation": seed},
                              {"kind": "straight", "rotation": 1},
                              {"kind": "curve", "rotation": 2},
                              {"kind": "curve", "rotation": 3},
                              {"kind": "curve", "rotation": 1},
                              {"kind": "curve", "rotation": seed}]}
            minimum = None
            for turns in itertools.product(*(range(4) if movable(c) else (0,) for c in data["cells"])):
                if minimum is not None and sum(turns) >= minimum:
                    continue
                state = [(c["rotation"] + t) % 4 for c, t in zip(data["cells"], turns)]
                if is_solved(data, state):
                    minimum = sum(turns)
            self.assertEqual(find_solution(data)["minimum_taps"], minimum)

    def test_only_authored_stages_have_lamps_and_generator_preserves_them(self):
        # Regenerar o setor não deve apagar a regra nem acrescentá-la à fase 12.
        import sys
        sys.path.insert(0, str(ROOT / "tools"))
        from tools.create_five_by_five_levels import SPECS, make_level
        for spec in SPECS:
            data = make_level(spec)
            self.assertEqual(bool(data.get("required_nodes")), spec["id"] in (10, 11))
            saved = json.loads((ROOT / f"levels/level_{spec['id']:02d}.json").read_text(encoding="utf-8"))
            self.assertEqual(data, saved)
