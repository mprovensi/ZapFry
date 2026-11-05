"""Compõe a trilha original de mansão assombrada: sóbria, 120 BPM, 32 compassos.

Autoria offline com biblioteca padrão Python e ffmpeg para Vorbis.
O WAV mestre fica em builds/; somente o OGG é distribuído no jogo.
"""
from array import array
import json
import math
from pathlib import Path
import shutil
import subprocess
import sys
import wave

ROOT = Path(__file__).resolve().parents[1]
RATE = 22050
BPM = 120
BARS = 32
BEAT = 60 / BPM
DURATION = BARS * 4 * BEAT
COUNT = round(DURATION * RATE)
LEFT = array("f", [0]) * COUNT
RIGHT = array("f", [0]) * COUNT
TAU = math.tau


def frequency(note):
    return 440 * 2 ** ((note - 69) / 12)


def mix(samples, start, gain=1, pan=0):
    offset = round(start * RATE)
    left_gain = gain * math.sqrt((1 - pan) / 2)
    right_gain = gain * math.sqrt((1 + pan) / 2)
    for index, sample in enumerate(samples):
        target = (offset + index) % COUNT
        LEFT[target] += sample * left_gain
        RIGHT[target] += sample * right_gain


def voice(note, duration, instrument):
    pitch = TAU * frequency(note)
    for index in range(round(duration * RATE)):
        t = index / RATE
        phase = pitch * t
        if instrument == "organ":
            envelope = min(1, t / 0.018, (duration - t) / 0.075)
            tone = math.sin(phase) + 0.25 * math.sin(phase * 2) + 0.1 * math.sin(phase * 3) + 0.035 * math.sin(phase * 4)
        elif instrument == "bass":
            envelope = min(1, t / 0.008, (duration - t) / 0.045) * math.exp(-5 * t)
            tone = math.sin(phase) + 0.3 * math.sin(phase * 2) + 0.08 * math.sin(phase * 3)
        elif instrument == "pluck":
            envelope = min(1, t / 0.004, (duration - t) / 0.035) * math.exp(-13 * t)
            tone = math.sin(phase) + 0.3 * math.sin(phase * 2) + 0.1 * math.sin(phase * 3)
        else:
            envelope = min(1, t / 0.005, (duration - t) / 0.1) * math.exp(-4.5 * t)
            tone = math.sin(phase) + 0.16 * math.sin(phase * 2.01) * math.exp(-4 * t)
        yield tone * envelope


def compose():
    # Tema próprio: C#m, Am, F#dim7 e G#7, com baixo marcado e pequenas pausas.
    chords = [(61, 64, 68), (57, 60, 64), (54, 57, 60, 63), (56, 60, 63, 66)]
    roots = [49, 45, 42, 44]
    pattern = [0, 2, 1, None, 2, 0, 1, None]
    for bar in range(BARS):
        start = bar * 4 * BEAT
        chord = chords[(bar // 2) % 4]
        middle_section = 16 <= bar < 24
        register = -12 if middle_section else 0
        for step, degree in enumerate(pattern):
            if degree is None:
                continue
            note = chord[(degree + (bar % 2)) % len(chord)] + register
            mix(voice(note, 0.19, "organ"), start + step * BEAT / 2, 0.1 if middle_section else 0.115, -0.14)
        for beat in (0, 1, 2, 3):
            note = roots[(bar // 2) % 4] + (12 if beat % 2 else 0)
            mix(voice(note, 0.22, "bass"), start + beat * BEAT, 0.19 if beat % 2 else 0.25)
        for beat in (0.75, 2.75):
            for index, note in enumerate(chord):
                mix(voice(note, 0.14, "pluck"), start + beat * BEAT + index * 0.006, 0.075, 0.18)
        if bar % 2 == 0:
            for index, note in enumerate(chord):
                mix(voice(note - 12, 0.85, "organ"), start, 0.04, (index - 1) * 0.2)
    # Melodia original em frases curtas; a segunda seção responde em registro baixo.
    phrase = [(0, 0.5, 76), (0, 2, 75), (1, 1.5, 68), (1, 3, 73), (2, 1, 72), (3, 2.5, 69), (4, 0.5, 75), (4, 2, 72), (5, 1.5, 69), (6, 1, 72), (7, 2, 75), (7, 3.5, 72)]
    for section in range(4):
        for bar, beat, note in phrase:
            shift = -12 if section == 2 else 0
            mix(voice(note + shift, 0.85, "bell"), ((section * 8 + bar) * 4 + beat) * BEAT, 0.11 if section == 2 else 0.145, 0.13)
    # Ecos cruzados circulares: as caudas continuam através da emenda do loop.
    dry_left, dry_right = array("f", LEFT), array("f", RIGHT)
    for seconds, gain in [(0.17, 0.12), (0.34, 0.065), (0.71, 0.035)]:
        delay = round(seconds * RATE)
        for index in range(COUNT):
            LEFT[(index + delay) % COUNT] += dry_right[index] * gain
            RIGHT[(index + delay) % COUNT] += dry_left[index] * gain
    # Timbre limpo e contido: sem bateria hip-hop, swing ou ruído de fita.
    for index in range(COUNT):
        LEFT[index] = math.tanh(LEFT[index] * 1.15)
        RIGHT[index] = math.tanh(RIGHT[index] * 1.15)


def main():
    encoder = shutil.which("ffmpeg")
    if encoder is None:
        raise SystemExit("ffmpeg deve estar no PATH para exportar a trilha OGG.")
    compose()
    peak = max(max(abs(value) for value in LEFT), max(abs(value) for value in RIGHT))
    gain = 0.75 / peak
    pcm = array("h")
    energy = 0.0
    for left, right in zip(LEFT, RIGHT):
        for sample in (left * gain, right * gain):
            pcm.append(round(sample * 32767))
            energy += sample * sample
    if sys.byteorder != "little":
        pcm.byteswap()
    directory = ROOT / "builds/audio"
    directory.mkdir(parents=True, exist_ok=True)
    master = directory / "fortress-after-hours.wav"
    with wave.open(str(master), "wb") as output:
        output.setnchannels(2)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(pcm.tobytes())
    target = ROOT / "assets/audio/fortress-after-hours.ogg"
    subprocess.run([encoder, "-v", "error", "-y", "-i", str(master), "-c:a", "libvorbis", "-q:a", "4", str(target)], check=True)
    metrics = {"title": "Fortress After Hours", "style": "haunted-organ", "bpm": BPM, "bars": BARS, "seconds": DURATION, "rate": RATE, "channels": 2, "peak": 0.75, "rms": math.sqrt(energy / (COUNT * 2)), "loop_boundary_delta": max(abs(LEFT[0] - LEFT[-1]), abs(RIGHT[0] - RIGHT[-1])) * gain}
    (directory / "music-metrics.json").write_text(json.dumps(metrics, indent=2), encoding="utf-8")
    print(json.dumps(metrics))
    print(target)


if __name__ == "__main__":
    main()
