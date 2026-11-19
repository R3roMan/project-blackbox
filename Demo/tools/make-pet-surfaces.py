"""Build the companion color, normal, and packed finish maps."""
from pathlib import Path

import numpy as np
from PIL import Image

DEST = Path(__file__).resolve().parents[1] / "assets" / "surfaces" / "pets"
SIZE = 256
X, Y = np.meshgrid(np.arange(SIZE, dtype=np.float32) / SIZE,
                   np.arange(SIZE, dtype=np.float32) / SIZE)
GRAIN = np.random.default_rng(67391).uniform(-1, 1, X.shape)


def wave(cycles):
    return np.sin(np.pi * 2 * cycles)


def pulse(distance, width):
    return np.exp(-(distance / width) ** 2)


def distance_to_edge(cycles):
    return np.abs(cycles - np.rint(cycles))


def rgb(path, channels, is_color=False):
    pixels = (np.stack(channels, axis=-1).clip(0, 1) * 255).round().astype(np.uint8)
    image = Image.fromarray(pixels)
    if is_color:
        image.save(DEST / path, quality=88, method=6)
    else:
        # Most companions occupy fewer than 128 pixels in combat.
        # Filter fine relief before packing the linear maps losslessly.
        image.resize((128, 128), Image.Resampling.BOX).save(DEST / path, lossless=True, method=6)


def maps(name, pigment, height, roughness, relief, tint=(1, 1, 1)):
    pigment = np.broadcast_to(pigment, X.shape)
    rgb(name + "-color.webp", [pigment * channel for channel in tint], is_color=True)
    dx = (np.roll(height, 1, axis=1) - np.roll(height, -1, axis=1)) * relief
    dy = (np.roll(height, -1, axis=0) - np.roll(height, 1, axis=0)) * relief
    length = np.sqrt(1 + dx**2 + dy**2)
    rgb(name + "-normal.webp", (.5 + .5 * dx / length, .5 + .5 * dy / length, .5 + .5 / length))
    cavity = .69 + .31 * np.clip(height, 0, 1)
    rgb(name + "-surface.webp", (cavity, np.broadcast_to(roughness, X.shape), np.ones_like(X)))


def staggered_rows(columns, rows, warp=0):
    row = Y * rows + warp * wave(X * 3)
    column = X * columns + .5 * np.floor(row) + warp * wave(Y * 2)
    return column % 1 - .5, row % 1 - .5


def chassis():
    scratch = wave(Y * 71 + X * 2) * .025 + GRAIN * .018
    for name, sections, bands in [("wasp", 5, 5), ("drone", 3, 4), ("circuit", 4, 7)]:
        u, v = staggered_rows(sections, bands)
        seam = pulse(.5 - np.maximum(np.abs(u), np.abs(v)), .045)
        u_corner = np.abs(u) - .37
        v_corner = np.abs(v) - .33
        rivets = pulse(np.hypot(u_corner, v_corner), .049)
        led = pulse(u + .21, .045) * (np.abs(v) < .27)
        panel = wave(X * sections - .1) * .06 + wave(Y * bands + .38) * .04
        height = .73 - .59 * seam + .22 * rivets + scratch + panel
        pigment = .91 - .52 * seam + .19 * rivets + scratch + panel
        if name == "wasp":
            stripe = pulse(distance_to_edge(X * 5 + Y * 2), .16)
            pigment -= .29 * stripe
        if name == "drone":
            inset = pulse(np.abs(u) - .23, .025) * (np.abs(v) < .23)
            height -= inset * .2
            pigment -= inset * .25 + led * .15
        if name == "circuit":
            trace = pulse(v - np.where(u > .08, .19, -.19), .036)
            trace *= np.abs(u) < .38
            vias = pulse(np.hypot(u - .25, v - .19), .069)
            height += .24 * trace + .11 * vias
            pigment += .25 * trace + .23 * vias - .25 * led
        maps(name, pigment, height, .62 + seam * .27 - rivets * .22, 3.2)


def scales():
    for name, columns, rows, pointed, tint in [
        ("scales", 17, 13, .72, (.97, .88, 1)),
        ("wyvern", 11, 9, 1.38, (1, .91, .79)),
        ("shell", 6, 5, .42, (.84, .93, 1)),
    ]:
        u, v = staggered_rows(columns, rows, .16)
        outline = np.maximum(np.abs(u) + pointed * v**2, np.abs(v) * 1.08)
        plate = np.maximum(0, 1 - (outline / .56) ** 3)
        center = pulse(u, .10) * (1 - 1.8 * np.abs(v))
        broad = .075 * wave(X * 3 + Y) * wave(Y * 2)
        height = .18 + .63 * plate + .15 * center + GRAIN * .035 + broad
        pigment = .5 + .43 * plate + .08 * center + broad
        maps(name, pigment, height, .87 - .35 * plate, 2.8, tint)


def plumage():
    for name, columns, rows, flecks, tint in [
        ("crow", 12, 9, .16, (.91, .89, 1)),
        ("archive", 9, 8, .13, (.86, 1, .94)),
        ("owl", 10, 8, .40, (1, .94, .83)),
        ("finch", 13, 11, .20, (.95, 1, .81)),
        ("wendy", 12, 10, .25, (1, .92, .79)),
    ]:
        u, v = staggered_rows(columns, rows, .17)
        scallop = pulse(v + .30 - .77 * np.abs(u)**1.45, .071)
        shaft = pulse(u, .15) * pulse(v, .34)
        barb = wave(np.abs(u) * 4 + v * 3) * .047
        dapple = pulse(np.hypot(u * .73, v + .24), .16) * (.66 + .34 * wave(X * 4 + Y * 5))
        field = .06 * wave(Y * 3 + wave(X * 2) * .30)
        pigment = .91 - .20 * scallop - flecks * dapple + .075 * shaft + barb + field
        height = .59 - .20 * scallop + .16 * shaft + barb + field
        maps(name, pigment, height, .93 - .12 * shaft + .04 * scallop, 3, tint)

    shaft = pulse(Y - .5, .028)
    barbs = wave(X * 24 - np.abs(Y - .5)**.8 * 14)
    wash = .1 * wave(X * 2) + .065 * wave((Y - .5) * 7)
    edge = np.abs(Y - .5) * .38
    for name, barring in [("quill", .07), ("quill-barred", .28)]:
        bars = barring * pulse(distance_to_edge(X * 6 - np.abs(Y - .5)**1.2), .25)
        maps(name, .89 + .23 * shaft + barbs * .075 - edge + wash - bars,
             .62 + .28 * shaft + barbs * .095 - edge, .85 - .32 * shaft + bars, 3.8)


def fibers():
    for name, frequency, sweep, length in [
        ("fur", 37, .22, 5), ("down", 43, .35, 8), ("hair", 18, .15, 2),
    ]:
        bend = sweep * wave(Y * length + wave(X * 4) * .27)
        flow = X * frequency + bend + .21 * wave(X * 5 + Y * 3)
        strands = pulse(distance_to_edge(flow), .29)
        filaments = wave(flow * 2 + Y * (length + 3))
        locks = wave(X * (frequency // 4) + wave(Y * 2 + X * 3) * .24)
        tuft = pulse(distance_to_edge(Y * 7 + wave(X * 11) * .4), .29)
        pigment = .81 + .095 * locks + .19 * strands * (.46 + tuft * .54) + .044 * filaments
        height = .61 + .20 * strands * (.51 + tuft * .49) + .095 * locks + .045 * filaments + GRAIN * .019
        maps(name, pigment, height, .82 - .17 * strands if name == "hair" else .97 - .10 * locks, 3.3)

    fold = wave(X * 7 - Y * 2 + .31 * wave(Y * 3))
    weave = wave(X * 49) * wave(Y * 44) * .055
    stitch = pulse(distance_to_edge(X * 7 - Y * 2), .11) * (.5 + .5 * wave(Y * 27))
    maps("cloth", .84 + .17 * fold + weave - .12 * stitch,
         .68 + .19 * fold + weave - .10 * stitch, .93, 3.2)


def flesh():
    # Meandering ridges interleave to give each brain lobe grooves and softer folds.
    u = X + .062 * wave(Y * 3 + X) + .036 * wave(Y * 5 - X * 2)
    v = Y + .048 * wave(X * 4 - Y) + .029 * wave(X * 6 + Y * 2)
    folds = wave(u * 8) + wave(v * 6) * .69 + .25 * wave((u + v) * 4)
    groove = pulse(folds, .24)
    shape = (1 - groove) ** .66
    flecks = GRAIN * .035 + .045 * wave(X * 24 + Y * 17) * wave(Y * 29 - X * 9)
    pigment = .47 + .49 * shape + flecks + wave(Y * 4 + X) * .062
    maps("cortex", pigment, .19 + .65 * shape + flecks,
         .52 + .38 * groove, 3.8, (1, .86, .93))

    pores = np.maximum(0, GRAIN - .77) * .23
    mottling = .019 * wave(X * 7 + .32 * wave(Y * 6)) * wave(Y * 8 - X * 3)
    maps("skin", .97 + mottling - pores, .71 + mottling - pores, .91 + mottling, 1.6)

    swirl = wave(X * 4 + Y * 2 + .44 * wave(Y * 3 - X))
    swirl += .33 * wave(X * 9 - Y * 3 + .6 * wave(Y * 2))
    maps("ink", .79 + .15 * swirl, .56 + .23 * swirl + GRAIN * .018,
         .62 - .25 * swirl, 2.6, (.82, .87, 1))


def wings():
    u = X - .20 * wave(Y)
    v = Y + .08 * wave(X)
    branches = pulse(distance_to_edge(v * 5 - u * 2 + .27 * wave(X * 2)), .075)
    ribs = pulse(distance_to_edge(v * 2 + u * 3 + .19 * wave(X * 3)), .069)
    fibers = .045 * wave(v * 19 + u * 4) + GRAIN * .024
    maps("membrane", .89 - .30 * ribs - .17 * branches + fibers,
         .65 + .28 * ribs + .14 * branches + fibers, .85 - .13 * ribs, 2.8)
    maps("veil", .9 - .18 * ribs - .19 * branches + fibers,
         .62 + .18 * ribs + .14 * branches + fibers, .67 - .15 * ribs, 2.7)

    # Offset eyespots and low-contrast dust show up on both sides of the wing.
    u, v = staggered_rows(4, 2, .15)
    eye = np.hypot(u * 1.28, v)
    border = pulse(eye - .29, .048)
    ring = pulse(eye - .19, .052)
    dust = .06 * wave(X * 31) * wave(Y * 43) + GRAIN * .053
    maps("moth", .88 - .38 * border + .14 * ring - .15 * ribs + dust,
         .57 + .13 * border + .17 * ribs + dust, .88 - .16 * ring, 3.2, (.85, .94, 1))


def gourd():
    rib = wave(X * 9 + .14 * wave(Y * 2))
    freckles = np.maximum(0, wave(X * 41 + Y * 17) * wave(Y * 29 - X * 8) + GRAIN * .34 - .70)
    crease = pulse(distance_to_edge(X * 9 + .14 * wave(Y * 2)), .091)
    maps("rind", .91 + .077 * rib - .18 * crease - .47 * freckles,
         .60 + .21 * rib - .25 * crease - .27 * freckles, .77 + .19 * crease, 3.2, (1, .95, .89))
    stalk = wave(X * 14 + .12 * wave(Y * 3))
    maps("stalk", .86 + .19 * stalk + GRAIN * .04,
         .57 + .31 * stalk + GRAIN * .055, .87 + .075 * stalk, 3.3)


if __name__ == "__main__":
    DEST.mkdir(parents=True, exist_ok=True)
    chassis()
    scales()
    plumage()
    fibers()
    flesh()
    wings()
    gourd()
