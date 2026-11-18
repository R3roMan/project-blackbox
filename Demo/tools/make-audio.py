from array import array
from math import cos, exp, pi, sin
from pathlib import Path
from random import Random
import sys
import wave


RATE = 48000
DEST = Path(__file__).resolve().parents[1] / "audio"
DEST.mkdir(exist_ok=True)
SELECTED=set(sys.argv[1:])


def tone(hz, t):
    return sin(2 * pi * hz * t)


def write(name, seconds, sample):
    if SELECTED and name not in SELECTED:
        return
    values = array("h", (round(32767 * max(-1, min(1, sample(i / RATE)))) for i in range(round(seconds * RATE))))
    if sys.byteorder == "big":
        values.byteswap()
    with wave.open(str(DEST / (name + ".wav")), "wb") as output:
        output.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        output.writeframes(values.tobytes())


noise = Random(4201)
write("alarm", 0.44, lambda t: min(1, t * 65) * exp(-t * 4) * (0.33 * tone(312, t) + 0.16 * tone(453, t)))
write("seal", 0.36, lambda t: min(1, t * 85) * exp(-t * 7) * (0.32 * tone(192 + 260 * t, t) + 0.19 * tone(389, t)))
write("roar", 1.0, lambda t: min(1, t * 24) * exp(-t * 3.6)
      * (0.30 * tone(68 - t * 16, t) + 0.35 * tone(135 - t * 34, t) + 0.22 * noise.uniform(-1, 1)))

# Each entry describes the gun's report and the sequence of mechanisms heard
# during its reload. These are original synths, including all unlock weapons.
GUNS = {
    "twinSmgs":("ballistic",214,.11,.67,(.10,.22,.47,.73,.94)),
    "veinDrinker":("rail",101,.29,.92,(.09,.26,.55,.72,.95)),
    "rimeBell":("pump",129,.28,.79,(.11,.43,.59,.92)),
    "furnaceDoor":("pump",52,.42,1.04,(.10,.31,.58,.80,.97)),
    "twinShotguns":("pump",73,.34,.78,(.08,.27,.48,.72,.96)),
    "siegeRpg":("launch",43,.58,.91,(.10,.35,.61,.87,.98)),
    "cinderTwig":("staff",164,.35,.40,(.10,.65)),
    "draughtStick":("staff",376,.35,.40,(.12,.62)),
    "pollenRod":("staff",127,.39,.45,(.14,.61,.83)),
    "staticFork":("staff",643,.35,.43,(.12,.48,.80)),
    "hourhand":("staff",921,.52,.57,(.11,.43,.72,.92)),
    "graduate":("ballistic",152,.18,.41,(.11,.42,.79)),
    "kingsRansom": ("ballistic", 198, .24, .57, (.10, .27, .55, .85)),
    "stillwater": ("rail", 674, .39, .63, (.13, .38, .71, .94)),
    "pistol": ("ballistic", 122, .16, .31, (.16, .42, .73)),
    "scattergun": ("pump", 64, .28, .58, (.14, .32, .53, .85)),
    "carbine": ("ballistic", 161, .13, .43, (.18, .43, .81)),
    "rail": ("rail", 280, .32, .48, (.09, .34, .57, .90)),
    "riot": ("pump", 83, .32, .71, (.10, .27, .41, .56, .83)),
    "ion": ("pulse", 419, .19, .42, (.14, .46, .74)),
    "hellbore": ("pump", 49, .39, .84, (.08, .25, .43, .66, .94)),
    "arc": ("pulse", 598, .22, .53, (.13, .37, .69, .91)),
    "lance": ("rail", 475, .28, .62, (.13, .42, .72)),
    "solar": ("beam-loop", 168, 1, .58, (.14, .39, .63, .87)),
    "dread": ("launch", 58, .47, .78, (.16, .38, .73, .91)),
    "crucible": ("pulse", 330, .20, .66, (.11, .31, .63, .86)),
    "minigun": ("rotary", 173, .091, 1.02, (.12, .29, .46, .58, .83, .96)),
    "launcher": ("launch", 91, .41, .83, (.14, .33, .49, .71, .94)),
    "breacher": ("pump", 101, .25, .59, (.11, .35, .56, .91)),
    "volt": ("pulse", 721, .18, .55, (.13, .39, .66, .85)),
    "razor": ("ballistic", 201, .15, .57, (.12, .28, .53, .77, .91)),
    "ember": ("launch", 144, .31, .61, (.12, .41, .65, .93)),
    "harrier": ("rail", 354, .34, .71, (.16, .31, .57, .78, .95)),
    "prism": ("beam-loop", 239, 1, .75, (.14, .34, .55, .70, .94)),
    "cyclone": ("rotary", 249, .095, 1.19, (.09, .21, .39, .54, .73, .87, .96)),
    "redline": ("ballistic", 147, .33, 1.62, (.10, .34, .67, .87, .96)),
    "tesla": ("laser", 919, .27, 1.66, (.13, .25, .44, .71, .94)),
    "pyre": ("pump", 59, .42, 1.46, (.17, .31, .56, .91)),
    "glacier": ("rail", 449, .34, 1.73, (.13, .38, .67, .76, .92)),
    "shrapnel": ("pump", 40, .46, 1.63, (.07, .23, .31, .59, .77, .94)),
    "starDestroyer": ("laser", 293, .68, 1.94, (.08, .24, .58, .88)),
    "starDestroyerPlus": ("rail", 227, .89, .85, (.06, .21, .67, .93)),
    "bilecaster": ("pressure", 134, .31, .70, (.08, .31, .58, .94)),
    "nailclub": ("club", 83, .31, .62, (.16, .45, .93)),
    "katana": ("blade", 930, .24, .65, (.06, .49, .84)),
    "mechasword": ("blade", 414, .35, .86, (.13, .28, .57, .81, .98)),
    "duoknives": ("blade", 1591, .18, .55, (.05, .29, .55, .80)),
    "darksaber": ("blade", 211, .44, .83, (.06, .23, .74)),
    "chainsaw": ("saw-loop", 53, 1, .71, (.06, .38, .76, .92)),
    "tomahawk": ("blade", 283, .35, 1.02, (.18, .53, .83, .96)),
    "twinpistols": ("ballistic", 182, .12, 1.55, (.08, .17, .35, .52, .73, .94)),
    "furnacebeam": ("beam-loop", 92, 1, .83, (.10, .31, .54, .83)),
    "kestrel": ("ballistic", 205, .115, 1.30, (.09, .36, .72, .94)),
    "deadeye": ("ballistic", 146, .27, 1.48, (.10, .33, .63, .91)),
    "gravhammer": ("club", 59, .44, .93, (.13, .49, .88)),
    "reaperscythe": ("blade", 383, .39, .81, (.08, .34, .59, .89)),
    "windstaff": ("staff", 342, .33, .46, (.10, .68)),
    "firestaff": ("staff", 103, .46, .63, (.13, .37, .74)),
    "icestaff": ("staff", 856, .34, .55, (.11, .53, .86)),
    "thunderstaff": ("staff", 133, .42, .52, (.10, .52, .81)),
    "earthstaff": ("staff", 51, .39, .72, (.14, .51, .85)),
    "avatarstaff": ("staff", 408, .38, .62, (.05, .26, .49, .72, .94)),
    "abyssstaff": ("staff", 119, .48, .56, (.14, .43, .78)),
    "aurorastaff": ("staff", 661, .48, .53, (.09, .50, .83)),
    "helltrident": ("launch", 71, .43, .70, (.02, .22, .49, .81)),
    "ironservice": ("ballistic", 101, .21, .42, (.08, .34, .82)),
    "fieldRepeater": ("ballistic", 186, .105, .51, (.13, .41, .68, .87)),
    "splinter": ("pump", 76, .31, .72, (.14, .27, .56, .88)),
    "standardBolt": ("pulse", 456, .16, .53, (.12, .52, .91)),
    "reed": ("ballistic", 219, .107, .60, (.09, .31, .58, .89)),
    "shortRam": ("pump", 93, .24, .64, (.09, .39, .62, .87)),
    "gallows": ("rail", 301, .35, .76, (.07, .32, .67, .89)),
    "verdictRifle": ("ballistic", 139, .31, .78, (.08, .23, .53, .96)),
    "crest": ("pump", 68, .33, .66, (.11, .48, .59, .86)),
    "frostwing": ("rail", 573, .19, .58, (.16, .40, .78)),
    "weathered": ("ballistic", 66, .29, .71, (.10, .22, .37, .55, .80, .93)),
    "stingNeedle": ("pressure", 268, .24, .60, (.14, .44, .71, .86)),
    "copperPulse": ("pulse", 479, .24, .72, (.11, .28, .61, .91)),
    "cinderDouble": ("pump", 53, .36, .79, (.12, .28, .44, .64, .89)),
    "stoneRail": ("rail", 194, .31, .67, (.16, .37, .67, .94)),
    "paleward": ("rail", 417, .24, .67, (.06, .28, .51, .82)),
    "coldSnap": ("pulse", 1046, .23, .78, (.10, .41, .67, .92)),
    "brightShot": ("pulse", 562, .11, .63, (.17, .43, .71, .86)),
    "omenCaster": ("pulse", 181, .30, .74, (.15, .39, .66, .91)),
    "splitPin": ("ballistic", 236, .105, .66, (.08, .36, .65, .93)),
    "feint": ("ballistic", 169, .15, .71, (.09, .23, .43, .66, .90)),
    "grindstone": ("launch", 65, .37, .87, (.08, .35, .53, .69, .94)),
    "emberslash": ("blade", 802, .36, .74, (.04, .32, .62, .91)),
    "blackHole": ("gravity", 74, .68, .87, (.10, .29, .57, .88)),
    "breakerGlaive": ("blade", 313, .41, .83, (.13, .37, .66, .94)),
    "breakwater": ("rail", 117, .45, 1.16, (.09, .23, .46, .79, .96)),
    "nightInk": ("gravity", 98, .48, .92, (.06, .30, .63, .91)),
    "echosix": ("ballistic", 78, .23, .96, (.09, .24, .38, .52, .67, .91)),
    "riftScatter": ("pump", 57, .36, .85, (.08, .28, .56, .84)),
    "siltCarbine": ("pressure", 268, .12, .59, (.10, .38, .65, .83)),
    "rimeRelay": ("pulse", 1350, .24, .69, (.11, .34, .67, .92)),
    "whiteoutCoil": ("beam-loop", 314, 1, .97, (.06, .28, .53, .76, .95)),
    "fearScythe": ("blade", 151, .49, 1.22, (.11, .37, .58, .71, .92)),
    "jesterScatter": ("pump", 112, .29, 1.34, (.18, .40, .52, .77, .91)),
}


def shot(kind, base, seconds, rng, t):
    if kind == "beam-loop":
        phase = .001 * tone(11, t)
        return .32 * tone(base, t + phase) + .15 * tone(3 * base, t) + .13 * tone(base + 9, t)
    if kind == "saw-loop":
        pulse = .67 + .33 * tone(base * 2, t)
        harmonics = sum(tone(base*partial,t + .001*tone(7,t)) / partial for partial in range(3,12,2))
        return pulse * (.37 * tone(base, t) + .44*harmonics + .13*tone(base*4,t) + .07*rng.uniform(-1,1))
    phase = t / seconds
    hit = min(1, t * 950) * min(1, max(0, 1 - phase) * 5)
    hiss = rng.uniform(-1, 1)
    motor = tone(base * .45, t + .019 * (1 - exp(-t * 55)))
    if kind in ("pump", "ballistic", "rotary"):
        low = base * (.53 if kind == "pump" else .67)
        shell = tone(low, t + .018 * (1 - exp(-t * 70)))
        chatter = tone(base * 5.14, t) * exp(-t * (19 if kind == "rotary" else 92))
        crack = .23 * tone(1760+base,t+.005*sin(237*t)) * exp(-t*118)
        return hit * (shell * .52 * exp(-t * 18) + hiss * .47 * exp(-t * 35) + chatter * .18 + crack)
    if kind == "launch":
        return hit * (motor * .55 * exp(-t * 7) + hiss * .15 * exp(-t * 5) + tone(base * 2.7, t) * .17 * exp(-t * 12))
    if kind == "pressure":
        bubbles = .55 + .44 * tone(35 - 26 * phase, t)
        return hit * exp(-phase * 2.3) * (motor * .29 + bubbles * (.33 * hiss + .22 * tone(base - 72 * phase, t)))
    if kind == "staff":
        root = tone(base, t + .065*(1-exp(-t*9)))
        bells = .23*tone(base*2.67,t-.16*t*t) + .13*tone(base*4.12,t)
        return hit * exp(-phase*2.1) * (.40*root + bells + .13*hiss*exp(-t*21))
    if kind == "gravity":
        sub = tone(base, t + .054*sin(5.2*t))
        fold = tone(base*3.1, t-.54*t*t)
        return hit * exp(-phase*1.4) * (.49*sub+.26*fold+.18*hiss*(.47+.53*tone(18,t)))
    if kind in ("club", "blade"):
        sweep = tone(base, t + .028 * sin(pi * phase))
        swing = min(1, t * 48) * exp(-phase * 2.8)
        colour = .52 if kind == "club" else .19
        return hit * swing * (colour * sweep + .33 * hiss + .14 * tone(base * 2.16, t))
    chirp = tone(base, t + .041 * (1 - exp(-t * 22)))
    ring = tone(base * (1.38 if kind == "laser" else 2.23), t)
    return hit * (chirp * .36 + ring * .23 + hiss * (.07 if kind == "laser" else .17)) * exp(-phase * 2.6)


def rack(kind, base, seconds, pattern, rng, t):
    total = 0
    electrical = kind in ("pulse", "rail", "laser", "beam-loop", "staff", "gravity")
    for index, point in enumerate(pattern):
        age = t - seconds * point
        if 0 <= age < .095:
            rattle = rng.uniform(-1, 1) * .36
            movement = tone(base * (2 + index * .38), age) * .37
            total += (rattle + movement) * min(1, age * 1100) * exp(-age * (47 if index % 2 else 68))
    if electrical:
        total += tone(base * .66, t + .11 * (t / seconds) ** 2) * .07 * sin(pi * t / seconds) ** 2
    elif kind == "rotary":
        total += tone(base * .22, t) * .08 * sin(pi * t / seconds) ** 2
    elif kind == "pressure":
        total += rng.uniform(-1, 1) * .17 * sin(pi * t / seconds) ** 4
    elif kind == "saw-loop":
        total += .23 * tone(base * 2.7, t + .044 * sin(17 * t)) * sin(pi * t / seconds) ** 2
    return total


for index, (name, values) in enumerate(GUNS.items()):
    family, pitch, report, reload_time, pattern = values
    shot_rng = Random(7831 + index)
    rack_rng = Random(1013 + index)
    write("fire-" + name, report, lambda t: shot(family, pitch, report, shot_rng, t))
    write("reload-" + name, reload_time, lambda t: rack(family, pitch, reload_time, pattern, rack_rng, t))


def cue(name, seconds, pitch, falloff, roughness, curve):
    rng = Random(pitch)
    write(name, seconds, lambda t: min(1, t * 190) * min(1, (seconds - t) * 90) * exp(-t * falloff)
          * (0.32 * tone(pitch, t + curve * t ** 2) + .12 * tone(pitch * 1.51, t)
             + roughness * rng.uniform(-1, 1)))


for event in (
    ("arrive", .27, 315, 5, .15, .7), ("shift", .32, 473, 6, .08, -1.3),
    ("turn", .23, 105, 10, .21, -.32), ("shield-block", .21, 570, 11, .12, .08),
    ("shield-break", .39, 840, 8, .31, -.42), ("pet", .16, 963, 12, .02, .29),
    ("brood", .41, 156, 7, .22, -.27), ("boss", .83, 83, 2, .17, -.46),
    ("throw", .19, 206, 9, .16, .38), ("detonation", .43, 61, 6, .37, -.25),
    ("frost", .43, 1243, 9, .07, .24), ("breath", .86, 74, 1.9, .44, -.21),
    ("burn", .28, 164, 6, .38, -.21), ("distortion", .49, 246, 4.7, .39, 1.7),
    ("gift", .33, 624, 4, .04, 1.1), ("curse", .42, 231, 4, .2, -.7),
    ("buy", .28, 742, 6, .025, .8), ("empty", .13, 329, 22, .12, -.13),
    ("clear", .62, 422, 3, .025, .18), ("hurt", .24, 107, 13, .24, -.24),
    ("spinup", .62, 117, 1.7, .13, 1.58), ("refresh", .34, 534, 4.8, .11, .91),
    ("boon", .76, 392, 2.1, .045, .27), ("shade", .95, 63, 1.6, .26, -.62),
    ("mega", .52, 615, 3.7, .045, .51), ("electric", .28, 798, 10, .31, -.19),
    ("arrival", 2.45, 43, .58, .14, -.014), ("move-boss", .44, 95, 4, .22, .48),
    ("tube", .68, 113, 2.7, .42, -.43), ("wreck", 1.37, 74, 1.1, .30, .13),
    ("ship-final", 2.45, 36, .9, .54, -.016), ("intercept", .26, 919, 9, .30, -.61),
    ("dodge", .17, 299, 7.1, .15, -.23), ("turret", .36, 376, 9, .21, -.37),
    ("cannon", .52, 47, 5.5, .35, -.25), ("loss", 1.2, 163, 1.7, .10, -.31),
    ("alien-fire", .32, 286, 7, .18, -.67), ("meteor-hit", .61, 57, 4, .34, -.21),
    ("ninja-smoke", .36, 146, 6, .22, .61), ("seal-step", .32, 278, 3, .035, .07), ("star-charge", .95, 192, .44, .13, 1.04),
    ("shield-refill", .42, 484, 4, .047, .63), ("misfire", .16, 94, 17, .24, -.48),
    ("poison-cloud", .96, 54, 1.4, .39, -.18), ("poison-impact", .33, 113, 5.2, .29, -.84),
    ("poison-burst", .64, 79, 3.7, .39, .16), ("slime-spit", .29, 163, 4, .21, -.97),
    ("slime-impact", .41, 86, 5.6, .36, -.59), ("spin-shard", .34, 667, 6.8, .19, -.71),
    ("axe-impact", .24, 119, 8.5, .29, -.45), ("player-dodge", .25, 322, 4.6, .25, .56),
    ("overheat", .60, 149, 4.3, .48, -.40), ("bayonet", .28, 412, 5, .34, -.98),
    ("saw-rev", .84, 54, 2.2, .38, .42), ("beam-warn", .84, 376, .85, .05, .67),
    ("beam-fire", 2.75, 75, .43, .20, .014),
    ("combo-cut", .32, 633, 5.2, .27, -.63), ("staff-cast", .42, 224, 3.7, .05, .82),
    ("staff-impact", .50, 74, 6.1, .29, -.26), ("gold-warn", .74, 299, .90, .04, .33),
    ("gold-ray", .51, 514, 3.3, .21, -.54), ("coin-return", .46, 732, 3.8, .04, .78),
    ("flask-release", .53, 381, 3.9, .16, -.58),
    ("field-guard", .35, 551, 4.7, .07, .60), ("field-block", .31, 343, 9.4, .20, -.23),
    ("field-critical", .36, 718, 6.4, .23, -.29), ("critical-landed", .20, 994, 9.3, .12, .32),
    ("magnet-fire", .34, 1009, 5.8, .34, -.81),
    ("snake-bolt", .55, 477, 3.5, .28, -1.17),
):
    cue(*event)


def summoning(name, seconds, bass, rise, beat, grit):
    rng = Random(bass + 917)

    def sample(t):
        phase = t / seconds
        envelope = min(1, phase * 18) * min(1, (1 - phase) * 4)
        pulse = .74 + .26 * tone(beat, t)
        fundamental = tone(bass, t + rise * t * t)
        dissonance = tone(bass * 1.41, t + .052 * sin(pi * phase))
        gates = max(0, tone(beat * 3.1, t)) ** 2
        return envelope * (pulse * (.34 * fundamental + .20 * dissonance)
                           + gates * grit * rng.uniform(-1, 1) + .09 * tone(bass * 4.03, t))

    write("summon-" + name, seconds, sample)


summoning("humontafagus", 1.43, 56, -.084, 6.2, .20)
summoning("mastafangenbus", 1.37, 67, .135, 9.8, .29)
summoning("gigafinterus", 1.52, 51, -.051, 3.4, .43)
summoning("lucifoverus", 1.51, 73, .048, 4.5, .16)
summoning("hasasasa", 2.45, 42, -.010, 7.2, .22)
summoning("stinkaturumus", 1.54, 44, .092, 5.7, .34)


def wet_impact(name, seconds, bass, size):
    rng = Random(4703 + bass)
    current = 0

    def sample(t):
        nonlocal current
        phase = t / seconds
        current = current * .69 + rng.uniform(-1, 1) * .31
        suck = tone(bass * (.52 + 2.25 * exp(-phase * 5)), t)
        glob = (.62 + .34 * tone(17 + bass * .18, t)) ** 2
        crunch = max(0, tone(77 - phase * 49, t)) ** 4
        return min(1, t * 440) * min(1, (1-phase)*7) * exp(-phase*2.3) * (
            glob * (.57 * current + .26 * suck) + .22 * crunch * rng.uniform(-1, 1) + size * .21 * tone(bass*.44, t))

    write(name, seconds, sample)


wet_impact("gore-hit", .21, 131, .36)
wet_impact("gore-kill", .47, 83, .62)
wet_impact("gore-heavy", 1.12, 56, 1.1)
cue("death-coin", .44, 887, 5.1, .04, -.46)
cue("distant-metal", 2.23, 106, .78, .19, -.027)


def far_cry(name, duration, pitch):
    def sample(t):
        sound = 0
        for tap in range(4):
            age = t - tap * .285
            if age < 0:
                continue
            wail = tone(pitch, age + .052 * sin(age * 9) - .17 * age * age)
            voice = wail * .27 + tone(pitch * 1.49, age + .031 * sin(age * 7)) * .12
            sound += voice * min(1, age*12) * exp(-age*3.6) * (.56 ** tap)
        return sound * min(1, (duration-t)*5)

    write(name, duration, sample)


far_cry("distant-cry", 2.7, 257)
far_cry("distant-echo", 2.4, 103)


def rain_loop():
    rng = Random(7961)
    rolling = 0

    def sample(t):
        nonlocal rolling
        drop = rng.uniform(-1, 1)
        rolling = rolling * .92 + drop * .08
        tick = rng.uniform(-.33, .33) if rng.random() < .019 else 0
        return (.22 * drop + .57 * rolling + tick) * min(1, t*36, (5-t)*36)

    write("rain-loop", 5, sample)


rain_loop()


def bed(name, pulse_count, hot=False):
    rng = Random(28571 + pulse_count)
    duration = 8
    low = 0
    pop = 0

    def sample(t):
        nonlocal low, pop
        hiss = rng.uniform(-1, 1)
        low = low * .989 + hiss*.011
        pop *= .997
        if rng.random() < (.0026 if hot else .00006):
            pop = rng.uniform(.18,.81)
        loop = min(1,t*18,(duration-t)*18)
        sway = .52+.43*tone(.125*pulse_count,t)
        drone = .14*tone(46,t+.002*tone(.5,t)) + .07*tone(71,t)
        return loop * (low * 1.7 + (.22*hiss + .54*low)*pop + (.17*drone if hot else drone)*sway)

    write(name, duration, sample)


bed("combat-loop", 3)
bed("inferno-loop", 5, hot=True)

for event in (
    ("sniper-shift", .49, 895, 3.1, .09, -.24),
    ("sniper-fire", .30, 122, 7.3, .29, -.23),
    ("feeding-bite", .46, 66, 4.0, .44, -.09),
    ("feeding-windup", .44, 148, 1.7, .16, -.21),
    ("black-hole-open", .74, 61, 2.4, .14, -.40),
    ("void-storm", 1.10, 141, 1.6, .25, -.24),
    ("void-fire", .58, 85, 4.7, .16, -.38),
    ("summon-voidGlitch", 1.44, 95, 1.1, .22, -.18),
    ("inferno", .64, 74, 3.2, .44, -.03),
    ("beam-start", .23, 519, 8.1, .15, -.17),
    ("blade-split", .30, 224, 6.0, .51, -.13),
    ("saw-split", .43, 57, 3.3, .48, .19),
    ("plasma-split", .32, 619, 3.8, .28, -.42),
    ("boss-warning", .61, 421, 2.8, .05, .31),
    ("leviathan-suction", 1.47, 82, 1.1, .36, -.14),
    ("leviathan-bubbles", 1.27, 182, 1.45, .11, .38),
    ("leviathan-charge", 1.25, 42, .98, .33, .64),
    ("leviathan-roar", 1.54, 59, 1.4, .4, -.11),
    ("leviathan-ready", .52, 73, 2.8, .13, .14),
    ("bubble-burst", .61, 78, 3.4, .49, -.39),
    ("void-shatter", .91, 1359, 4.6, .42, -.43),
    ("void-brood", .61, 160, 2.6, .27, -.31),
    ("void-push", .52, 114, 3.7, .26, -.30),
    ("void-intrusion", 1.25, 51, 1.1, .25, -.13),
    ("lure-start", 1.48, 454, 1.25, .064, -.055),
    ("lure-break", .71, 587, 4, .075, .71),
    ("ink-windup", .77, 267, 1.7, .085, .71),
    ("ink-fire", .49, 110, 4.1, .43, -.22),
    ("endme-break", .63, 675, 3.5, .17, -.50),
    ("faeel-bite", .49, 1088, 3.2, .53, -.53),
    ("orb-bolt", .48, 196, 4.1, .21, -.24),
    ("return-bolt", .34, 756, 6.3, .17, .37),
    ("pet-betray", .56, 343, 2.8, .23, -.43),
    ("angel-arrival", .91, 492, 2.5, .035, .105),
    ("alien-arrival", .66, 663, 3.9, .13, -.46),
    ("winter-arrival", 1.25, 734, 2.9, .065, .105),
    ("winter-pulse", .48, 1541, 5.1, .056, -.19),
    ("rain-arrival", .74, 211, 3.8, .33, -.12),
    ("night-arrival", 1.23, 111, 1.48, .036, -.064),
    ("meteor-arrival", 1.31, 65, .93, .41, -.12),
    ("wind-arrival", .81, 296, 3.9, .31, .22),
    ("wind-gust", 1.29, 78, 1.5, .51, .21),
    ("glitch-arrival", 1.25, 277, 1.67, .43, .46),
    ("aim-miss", .19, 287, 12.8, .16, -.91),
    ("parry-block", .39, 1097, 7.2, .24, .14),
    ("bone-shatter", .73, 351, 3.7, .36, -.14),
    ("colour-spill", .73, 687, 3.2, .087, .24),
    ("soul-taken", 1.51, 103, 1.57, .20, -.30),
    ("fang-crack", .42, 985, 7.35, .48, -.08),
    ("fang-launch", .56, 248, 4.20, .31, .27),
    ("leviathan-fangs", 1.09, 87, 2.14, .40, .12),
):
    cue(*event)

summoning("reapfast", 3.85, 40, .016, 3.2, .33)
wet_impact("leviathan-bite", 1.0, 43, 1.24)
wet_impact("tentacle-grab", .79, 79, .44)
wet_impact("tentacle-bite", .55, 68, .73)
wet_impact("void-arrival", .78, 103, .47)
bed("void-loop", 2)
bed("glitch-loop", 7)


def siren(t):
    swell = (.5 - .5 * cos(2 * pi * t / 1.5)) ** 2
    phase = t + .059 * sin(2 * pi * t / 1.5)
    return swell * (.36 * tone(402, phase) + .15 * tone(804, phase))


def laughter(t):
    sound = 0
    for index, start in enumerate((0, .17, .33, .51, .76)):
        age = t - start
        if age < 0:
            continue
        pitch = 738 + 86 * index
        vibrato = .006 * tone(21, age)
        phase = age + vibrato - age ** 2 * (1.5 if index == 4 else .81)
        envelope = min(1, age * 132) * exp(-age * (12 if index < 4 else 6))
        sound += envelope * (.26 * tone(pitch, phase) + .17 * tone(pitch * 1.99, phase)
                             + .062 * tone(pitch * 3.13, phase))
    return sound * min(1, (1.27 - t) * 30)


def wind_bed(name, seed, level):
    rng = Random(seed)
    drift = 0

    def sample(t):
        nonlocal drift
        gust = rng.uniform(-1, 1)
        drift = drift * .97 + gust * .03
        swell = .59 - .35 * cos(t * pi / 2)
        return min(1, t * 24, (8 - t) * 24) * swell * level * (.16 * gust + 1.17 * drift + .064 * tone(229, t + .014 * tone(.5, t)))

    write(name, 8, sample)


write("boss-siren-loop", 3, siren)
write("lala-laugh", 1.27, laughter)
wind_bed("winter-loop", 2914, 1)
wind_bed("wind-loop", 4872, 1.7)

for name, duration, pitch, weight in (
    ("humontafagus", 1.55, 69, 1.08), ("mastafangenbus", 1.71, 107, 1.19),
    ("gigafinterus", 2.10, 81, 1.31), ("lucifoverus", 2.01, 158, 1.17),
    ("hasasasa", 2.49, 54, 1.54), ("stinkaturumus", 1.92, 45, 1.34),
    ("voidGlitch", 2.23, 94, 1.12), ("reapfast", 2.68, 36, 1.53),
):
    wet_impact("death-"+name,duration,pitch,weight)

far_cry("crufi-weep",2.16,379)
cue("soul-release",1.12,671,1.55,.06,.21)


def scream(name, duration, pitch, looping=False):
    rng = Random(821 + pitch)
    breath = 0

    def sample(t):
        nonlocal breath
        phase = t / duration
        breath = breath*.82+rng.uniform(-1,1)*.18
        vibrato = .0014 * tone(17,t) + .0008 * tone(29,t)
        rise = .028 * sin(pi*phase) * t
        voice = .36*tone(pitch,t+vibrato+rise)
        voice += .17*tone(pitch*2.01,t+vibrato)
        voice += .084*tone(pitch*3.03,t) + .22*breath
        envelope = min(1,t*28,(duration-t)*18)
        shake = .77+.23*tone(8,t)
        return voice*envelope*shake*(.85 if looping else 1)

    write(name,duration,sample)


scream("harvester-cry",1.14,681)
scream("harvester-loop",2,437,looping=True)
scream("crufi-scream",3,791)

# Short creature reactions leave the soundtrack and the next telegraph audible.
for name, pitch in (("hurt-hellborne", 102), ("hurt-space", 237), ("hurt-void", 67)):
    write(name, .24, lambda t, pitch=pitch: min(1, t * 95) * exp(-t * 14)
          * (.29 * tone(pitch * (1 - t * .7), t) + .17 * tone(pitch * 2.21, t)
             + .08 * noise.uniform(-1, 1)))

cue("tutorial-good",.54,512,1.31,.02,.08)
cue("tutorial-rewind",1.1,221,.61,.07,.16)
wet_impact("tutorial-molt",3.6,58,1.1)
wet_impact("spray",1.2,134,.62)
far_cry("cough",.60,149)
cue("summon-oblogabgalus",1.55,71,.72,.1,.2)

cue("blood-moon-arrival",1.75,89,.64,.045,.22)
wet_impact("blood-bolt",.44,163,.48)
cue("blood-drain",.79,172,.78,.025,.3)
cue("stone-break",.98,67,2.12,.25,.04)
