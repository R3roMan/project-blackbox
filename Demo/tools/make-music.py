"""Render Blackbox's original loops as stereo Ogg Vorbis. Needs NumPy and FFmpeg."""

from dataclasses import dataclass
from pathlib import Path
import subprocess

import numpy as np


RATE = 44100
DEST = Path(__file__).resolve().parents[1] / "audio" / "music"
DEST.mkdir(parents=True, exist_ok=True)
TAU = 2 * np.pi


@dataclass(frozen=True)
class Track:
    name: str
    bpm: int
    root: int
    progression: tuple[int, ...]
    hits: tuple[int, ...]
    accents: tuple[int, ...]
    bars: int = 16
    tension: float = .65


TRACKS = [
    Track("book",72,43,(0,5,10,3,8,2,7,0),(),(),16,.10),
    Track("oblogabgalus",116,33,(0,3,-1,5),(0,4,8,11,14),(4,12),12,.55),
    Track("home", 71, 33, (0, -1, 5, -2), (0, 11), (12,), 14, .18),
    Track("frontier", 104, 34, (0, 3, -2, 6), (0, 4, 8, 11, 14), (4, 12), 12, .52),
    Track("fracture", 126, 31, (0, 1, -2, 3), (0, 3, 5, 8, 11, 14), (6, 12), 14, .68),
    Track("embers", 142, 33, (0, -2, 6, 1), (0, 2, 4, 7, 8, 10, 13, 15), (4, 12), 16, .76),
    Track("humontafagus", 150, 31, (0, 0, 3, 1), (0, 2, 5, 6, 8, 11, 13, 15), (4, 12), 16, .88),
    Track("mastafangenbus", 172, 30, (0, -2, 2, 5), (0, 1, 3, 6, 8, 9, 11, 14), (4, 10, 12), 16, .97),
    Track("gigafinterus", 155, 33, (0, 6, -1, 1), (0, 3, 4, 5, 7, 8, 11, 12, 15), (4, 12, 14), 16, .93),
    Track("lucifoverus", 163, 34, (0, -1, 1, 8), (0, 2, 3, 6, 8, 9, 12, 14, 15), (5, 12, 15), 16, .99),
    Track("hasasasa", 169, 35, (0, 1, -3, 6), (0, 2, 5, 6, 9, 10, 12, 14, 15), (4, 8, 13), 16, .91),
    Track("stinkaturumus", 157, 28, (0, -1, -4, 6), (0, 1, 4, 7, 8, 9, 12, 13, 15), (4, 11, 14), 16, .97),
    Track("voidGlitch", 166, 29, (0, -1, 6, -3), (0, 1, 4, 5, 8, 10, 11, 14, 15), (3, 7, 12), 16, .94),
    Track("reapfast", 184, 28, (0, 1, -4, 6), (0, 1, 3, 4, 6, 8, 9, 11, 12, 14, 15), (3, 7, 10, 13), 20, .90),
    Track("shop", 113, 43, (0, 2, 5, 7), (), (), 12, .16),
]


def frequency(note):
    return 440 * 2 ** ((note - 69) / 12)


def timeline(duration):
    return np.arange(max(1, round(duration * RATE)), dtype=np.float32) / RATE


def env(t, attack, release, end):
    return np.clip(t / attack, 0, 1) * np.clip((end - t) / release, 0, 1)


def add(mix, when, voice, volume, pan=0):
    start = round(when * RATE)
    length = min(len(voice), len(mix) - start)
    if length > 0:
        mix[start:start + length, 0] += voice[:length] * volume * np.sqrt((1 - pan) / 2)
        mix[start:start + length, 1] += voice[:length] * volume * np.sqrt((1 + pan) / 2)


def chord(root, color, duration, quiet):
    t = timeline(duration)
    layers = np.sin(TAU * frequency(root - 12) * t) * .76
    for i, partial in enumerate(color):
        hz = frequency(root + partial)
        vibrato = .13 * np.sin(TAU * (.32 + i * .17) * t)
        layers += (np.sin(TAU * hz * t + vibrato) + .47 * np.sin(TAU * hz * 1.005 * t)) / (5 + i * 2)
    return layers * env(t, .47 if not quiet else .98, .56, duration)


def riff(note, duration, aggression, pan_phase):
    t = timeline(duration)
    hz = frequency(note)
    phase = TAU * hz * t
    shape = np.sin(phase) + .60 * np.sin(2 * phase + pan_phase) + .32 * np.sin(3.01 * phase + .2 * np.sin(phase))
    shape += .33 * aggression * np.sin(7.01 * phase)
    return np.tanh((1.34 + 2.1 * aggression) * shape) * env(t, .006, .08, duration) * np.exp(-t * aggression * 1.9)


def percussion(rng):
    t = timeline(.26)
    kick = np.sin(TAU * (44 * t + 2.1 * (1 - np.exp(-t * 45)))) * env(t, .004, .055, .26) * np.exp(-t * 13)
    snare = (rng.uniform(-1, 1, t.size) * .73 + .3 * np.sin(TAU * 181 * t)) * env(t, .003, .03, .26) * np.exp(-t * 24)
    hat = np.diff(rng.uniform(-1, 1, t.size + 1)) * env(t, .002, .02, .26) * np.exp(-t * 66) * .58
    return kick, snare, hat


def shop_pattern(mix, start, beat, root, bar, quiet, drums):
    kick, _, hat = drums
    mode = (0, 4, 7, 9) if root in (43, 50) else (0, 3, 7, 10)
    for i in range(8):
        when = start + beat * (.5 * i + (.11 if i % 2 else 0))
        t = timeline(beat * (.69 if quiet else .37))
        pitch = root + mode[(i + bar) % 4] + (24 if i in (3, 6) else 12)
        phase = TAU * frequency(pitch) * t
        bell = (.68 * np.sin(phase) + .17 * np.sin(3 * phase) + .07 * np.sin(5 * phase))
        add(mix, when, bell * env(t, .014, .10, len(t) / RATE), .17 if quiet else .27, .44 if i % 2 else -.38)
        if i % 2 == 0:
            add(mix, when, riff(root + mode[(i // 2 + 1) % 4] - 12, beat * .42, 0, 0), .16 if quiet else .29)
            add(mix, when, kick, .17 if quiet else .34)
        elif not quiet:
            add(mix, when, hat, .17, .28)


def deep_pattern(mix, start, beat, root, bar, quiet):
    for i, offset in enumerate((0, 1, 6, 13, 7, 1, 0, -1)):
        if quiet and i % 3:
            continue
        note = root + 24 + offset + (5 if bar % 4 >= 2 else 0)
        t = timeline(beat * (.92 if quiet else .45))
        phase = TAU * (frequency(note) * t - (11 + i * 5) * t ** 2)
        sonar = np.sin(phase) + .32 * np.sin(phase * 1.99 + .42 * np.sin(TAU * 8 * t))
        sonar *= env(t, .012, .091, len(t) / RATE)
        when = start + beat * (i // 2 + (i % 2) * .67)
        add(mix, when, sonar, .10 if quiet else .19, .51 if i % 2 else -.52)
        add(mix, when + beat * .64, sonar, .061, -.48 if i % 2 else .52)


def jazz_voice(note, length, bass=False):
    t = timeline(length)
    angle = TAU * frequency(note) * t
    if bass:
        sound = np.sin(angle) + .34*np.sin(2*angle)*np.exp(-t*5) + .16*np.sin(3*angle)*np.exp(-t*8)
        attack = .013
    else:
        tremolo = .91 + .09*np.sin(TAU*4.2*t)
        sound = tremolo*(np.sin(angle+.16*np.sin(angle*2.003)*np.exp(-t*4))
            + .22*np.sin(angle*2.015)*np.exp(-t*4.2) + .09*np.sin(angle*4.047)*np.exp(-t*13))
        attack = .020
    return sound * env(t, attack, min(.19,length*.35), length) * np.exp(-t*(2.5 if bass else 1.18))


def jazz_comp(mix, start, beat, root, bar, amount, book=False):
    # Soft minor ninths and dominant sevenths under an original swung phrase.
    changes = [(3,7,10,14),(4,9,10,14),(4,7,11,14),(4,7,10,15)]
    voicing = changes[(bar//2)%len(changes)]
    for offset in (0.15,2.63):
        for note in voicing:
            add(mix, start+beat*offset, jazz_voice(root+12+note,beat*1.37),
                amount*.35, -.21+note*.025)
    if book:
        walk = (0,7,10,11) if bar%4<2 else (0,5,7,-1)
        for i,note in enumerate(walk):
            add(mix,start+beat*i,jazz_voice(root-12+note,beat*.87,True),.118,-.1)
        melody = ((.65,17),(1.61,15),(2.38,12),(3.67,10)) if bar%2==0 else ((.13,14),(1.65,19),(3.19,17))
        for place,note in melody:
            add(mix,start+beat*place,jazz_voice(root+24+note,beat*(.50 if place>3.3 else .94)),amount*.77,.26)
    elif bar%2==1:
        add(mix,start+beat*3.62,jazz_voice(root+31,beat*.32),amount*.33,.23)


def gallery_score(track, quiet):
    beat = 60 / track.bpm
    frames = round(beat*4*track.bars*RATE)
    mix = np.zeros((frames,2),dtype=np.float32)
    rng = np.random.default_rng(3217)
    for bar in range(track.bars):
        start=bar*beat*4
        root=track.root+track.progression[(bar//2)%len(track.progression)]
        jazz_comp(mix,start,beat,root,bar,.10,book=True)
        for place in (1.07,2.65,3.08):
            t=timeline(.16)
            noise=rng.normal(0,1,len(t))
            brush=np.convolve(noise,np.ones(27)/27,mode="same")
            brush*=env(t,.015,.099,.16)*np.exp(-t*6)
            add(mix,start+beat*place,brush,.061,-.29 if place<2 else .29)
    tail=round(.13*RATE)
    mix[:tail]*=np.linspace(0,1,tail)[:,None]
    mix[-tail:]*=np.linspace(1,0,tail)[:,None]
    return mix*(.76 if quiet else 1)


def arrange(track, quiet=False, variation=""):
    if track.name == "book":
        return gallery_score(track,quiet)
    pressure = variation == "pressure"
    climax = variation == "climax"
    beat = 60 / track.bpm / (.66 if quiet else .92 if pressure else 1.09 if climax else 1)
    duration = beat * 4 * track.bars
    mix = np.zeros((round(duration * RATE), 2), dtype=np.float32)
    rng = np.random.default_rng(track.bpm * 9 + track.root)
    kick, snare, hat = percussion(rng)
    for bar in range(track.bars):
        root = track.root + track.progression[(bar // 2) % len(track.progression)]
        start = bar * beat * 4
        climb = (.62 + min(1, bar / 6) * .38) if track.name == "home" or quiet else 1
        voicing = (7, 12, 18) if bar % 4 != 3 else (6, 13, 19)
        if track.name == "shop":
            shop_pattern(mix, start, beat, root, bar, quiet, (kick, snare, hat))
            continue
        if variation:
            jazz_comp(mix,start,beat,root,bar,.077 if pressure else .059)
        if track.name == "reapfast":
            deep_pattern(mix, start, beat, root, bar, quiet)
        add(mix, start, chord(root, voicing, beat * 4 + .42, quiet), .27 * climb if quiet else .24 * climb, -.13)
        if not quiet and track.name != "home":
            for i in range(16):
                when = start + beat * i / 4
                if i in track.hits and (not pressure or i % 4 == 0 or i == 11) or climax and i in (7, 15):
                    note = root + (7 if i in (6, 15) and bar % 2 else 0) + (1 if i == 11 and bar % 4 == 3 else 0)
                    tension = track.tension * (.66 if pressure or track.name == "reapfast" else 1)
                    attack = riff(note, beat * (.49 if i % 4 == 0 else .32), tension, i * .47)
                    add(mix, when, attack, .22 if pressure else .32, -.39)
                    add(mix, when + .011, attack, .13 if pressure else .21, .36)
                    add(mix, when, kick, .71 if i % 4 == 0 else .45)
                if i in track.accents:
                    add(mix, when, snare, .52, .07)
                if i % 2 == 0 or track.tension > .86:
                    volume = .16 + .07 * (i % 4 == 0)
                    add(mix, when + (.009 if i % 2 else 0), hat, volume * (.50 if pressure else 1), .33 if i % 3 else -.35)
            if pressure:
                add(mix, start + beat * 1.5, riff(root - 12, beat * 1.5, .20, .4), .16)
        elif bar >= 2:
            for i in (0, 11):
                when = start + beat * i / 4
                add(mix, when, kick, (.16 if quiet else .32) * climb)
                if bar > 4:
                    note = root + (12 if i == 11 else 0)
                    add(mix, when, riff(note, beat * 1.3, .05, .3), (.08 if quiet else .13) * climb, .4 if i else -.3)
                if bar > 6:
                    add(mix, when + beat * .42, hat, .12 * climb, -.31 if i else .32)
        if bar % 4 == 3 or track.name == "home" and bar > 7:
            pitch = root + 24 + (1 if bar % 2 else 6)
            length = beat * 1.65
            voice_time = timeline(length)
            signal = np.sin(TAU * frequency(pitch) * voice_time + .6 * np.sin(TAU * 1.3 * voice_time))
            signal *= env(voice_time, .14, .31, length)
            add(mix, start + beat * 2.3, signal, (.044 if quiet else .092) * climb, .59)
    # A short fade in and out keeps the loop quiet at the cut.
    fade = round(RATE * (.29 if quiet or track.name == "home" else .055))
    mix[:fade] *= np.linspace(0, 1, fade)[:, None]
    mix[-fade:] *= np.linspace(1, 0, fade)[:, None]
    return np.tanh(mix * (1.14 if quiet else 1.51))


def encode(name, audio):
    command = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-f", "f32le",
               "-ar", str(RATE), "-ac", "2", "-i", "pipe:0", "-c:a", "libvorbis", "-q:a", "3",
               str(DEST / (name + ".ogg"))]
    subprocess.run(command, input=audio.astype("<f4", copy=False).tobytes(), check=True)


if __name__ == "__main__":
    import sys
    args = set(sys.argv[1:])
    variations_only = "--variations-only" in args
    selected = args - {"--variations-only"}
    if selected - {track.name for track in TRACKS}:
        raise SystemExit("Unknown track name")
    for item in TRACKS:
        if selected and item.name not in selected:
            continue
        if not variations_only:
            encode(item.name, arrange(item))
            if item.name != "home":
                encode(item.name + "-pause", arrange(item, quiet=True))
        if item.name not in ("home","shop","book"):
            encode(item.name + "-pressure", arrange(item, variation="pressure"))
            if item.name not in ("frontier", "fracture", "embers"):
                encode(item.name + "-climax", arrange(item, variation="climax"))
