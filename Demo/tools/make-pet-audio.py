from array import array
from math import exp, pi, sin
from pathlib import Path
from random import Random
from sys import byteorder
import wave


RATE = 32_000
AUDIO = Path(__file__).resolve().parents[1] / "audio"
MELODIES = (
    (0, 3, 7, 3, 5, 10, 7, 0),
    (0, 7, 10, 12, 10, 5, 3, 0),
    (7, 5, 3, 7, 12, 10, 3, 5),
)


def tone(cycles):
    return sin(2 * pi * cycles)


def write(name, length, sample):
    pcm = array("h", (int(32767 * max(-1, min(1, sample(i / RATE))))
                      for i in range(round(length * RATE))))
    if byteorder == "big":
        pcm.byteswap()
    with wave.open(str(AUDIO / f"{name}.wav"), "wb") as target:
        target.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        target.writeframes(pcm.tobytes())


def voice(style, pitch, age, step):
    glide = pitch * age
    if style == "retro":
        # Stepped pitch and changing harmonics suggest a small desktop voice synth.
        wobble = .048 * tone(5 * age) + .029 * tone(20 * age)
        phase = glide + wobble
        return .25 * tone(phase) + .22 * tone(2 * phase) + (.19 + .06 * tone(4 * age)) * tone(4 * phase) + .08 * tone(7 * phase)
    if style == "slime":
        glug = .45 * tone(glide * .43 + 11 * age * age + .60 * tone(15 * age))
        return glug * (.59 + .41 * tone(12 * age + step * .7)) + .2 * tone(glide * .8 + 23 * age * age)
    if style == "robot":
        return .50 * tone(glide + .14 * tone(glide * 1.5)) + .18 * tone(2 * glide)
    if style == "shade":
        return .43 * tone(glide * .5 + .12 * tone(7 * age)) + .18 * tone(glide * 1.009)
    if style == "chime":
        return .45 * tone(glide * 1.5) + .19 * exp(-age * 8) * tone(glide * 2.46)
    return .52 * tone(glide * 1.7 + 41 * age * age + .15 * tone(16 * age)) + .12 * tone(glide * 3)


def melody(style, notes):
    speed = .197 if style == "robot" else .237
    def sample(t):
        position = int(t / speed)
        if position >= len(notes):
            return 0
        age = t - position * speed
        envelope = min(1, age * 125, (speed - age) * 31) * exp(-age * 3.1)
        pitch = 247 * 2 ** (notes[position] / 12)
        return .59 * envelope * voice(style, pitch, age, position)
    return len(notes) * speed, sample


for style in ("retro", "slime", "robot", "shade", "chime", "bird"):
    for index, notes in enumerate(MELODIES, 1):
        write(f"pet-song-{style}-{index}", *melody(style, notes))
    if style != "bird":
        write(f"idle-{style}", *melody(style, (3, 7) if style != "slime" else (0, 2, -3)))

write("pet-laugh", *melody("retro", (7, 7, 3, 1, 0)))
write("pet-thumb", *melody("retro", (3, 8, 12)))
write("pet-mend", *melody("chime", (0, 5, 12)))
write("pet-banana", .28, lambda t: .49 * min(1, 130 * t) * exp(-18 * t) * tone(272 * t - 451 * t * t))
noise = Random(632)
write("pet-ice", .48, lambda t: min(1, t * 160) * exp(-t * 8.5)
      * (.27 * noise.uniform(-1, 1) + .25 * tone(1941 * t) + .16 * tone(2977 * t)))
write("pet-flicker", .37, lambda t: min(1, 300 * t) * exp(-10 * t)
      * (.20 * tone(314 * t + 95 * t * t) + .22 * noise.uniform(-1, 1) * int(t * 107 % 7 < 3)))
