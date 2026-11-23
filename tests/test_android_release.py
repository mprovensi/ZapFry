"""Bloqueia manifestos de debug e bibliotecas incompatíveis antes da publicação."""

from pathlib import Path
import struct
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from check_android_release import check_elf, check_manifest


class AndroidReleaseTests(unittest.TestCase):
    def test_store_manifest_requires_package_version_api_and_release(self):
        manifest = ('<manifest xmlns:android="http://schemas.android.com/apk/res/android" '
                    'package="com.mprovensi.zapfry" android:versionName="0.23.0" android:versionCode="40">'
                    '<uses-sdk android:targetSdkVersion="36"/><application android:debuggable="false"/></manifest>')
        check_manifest(manifest, "0.23.0", 40)
        for before, after in [('com.mprovensi.zapfry', 'com.zapfry.prototype'),
                              ('versionCode="40"', 'versionCode="39"'),
                              ('targetSdkVersion="36"', 'targetSdkVersion="35"'),
                              ('debuggable="false"', 'debuggable="true"')]:
            with self.subTest(change=before), self.assertRaises(RuntimeError):
                check_manifest(manifest.replace(before, after), "0.23.0", 40)

    def test_native_segments_require_16kb_alignment(self):
        data = bytearray(120)
        data[:6] = b"\x7fELF\x02\x01"
        struct.pack_into("<Q", data, 32, 64)
        struct.pack_into("<HH", data, 54, 56, 1)
        struct.pack_into("<IIQQQQQQ", data, 64, 1, 5, 0, 0, 0, 120, 120, 16384)
        check_elf(data)
        struct.pack_into("<Q", data, 112, 4096)
        with self.assertRaisesRegex(RuntimeError, "16 KB"):
            check_elf(data)
