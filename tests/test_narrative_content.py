"""Valida o roteiro autoral e sua cobertura da campanha exportada."""

import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class NarrativeContentTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.story = json.loads((ROOT / "assets/narrative/campaign.json").read_text(encoding="utf-8"))

    def test_each_level_has_one_ordered_narrative_beat(self):
        levels = [json.loads(path.read_text(encoding="utf-8"))["id"]
                  for path in sorted((ROOT / "levels").glob("level_*.json"))]
        self.assertEqual([entry["id"] for entry in self.story["phases"]], levels)
        self.assertEqual(len(levels), 24)

    def test_two_short_speakers_and_compatible_character_variants(self):
        for entry in self.story["phases"]:
            with self.subTest(phase=entry["id"]):
                self.assertEqual(len(entry["lines"]), 2)
                for line in entry["lines"] + list(entry["replies"].values()):
                    self.assertIsInstance(line, str)
                    self.assertTrue(line.strip())
                    self.assertLessEqual(len(line), 72)
                for character in entry["replies"]:
                    self.assertTrue((ROOT / "assets/characters" / (character + ".tres")).is_file())
        self.assertEqual(sum(len(entry["replies"]) for entry in self.story["phases"]), 24)

    def test_premise_and_distinct_outcomes_are_complete(self):
        self.assertTrue(self.story["premise"].strip())
        outcomes = [entry["outcome"] for entry in self.story["phases"]]
        self.assertTrue(all(isinstance(line, str) and line.strip() for line in outcomes))
        self.assertEqual(len(set(outcomes)), 24)
