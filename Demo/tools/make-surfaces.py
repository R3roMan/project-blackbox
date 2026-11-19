"""Build the shared Ultra material maps and the neutral workshop light probe."""
from pathlib import Path

import sys

import numpy as np
from PIL import Image

DEST = Path(__file__).resolve().parents[1] / "assets" / "surfaces"
DEST.mkdir(parents=True, exist_ok=True)
SIZE = 1024
X, Y = np.meshgrid(np.arange(SIZE, dtype=np.float32) / SIZE,
                   np.arange(SIZE, dtype=np.float32) / SIZE)
RNG = np.random.default_rng(4312)
TAU = 2 * np.pi


def wrinkles(frequency, wash):
    return (np.sin(TAU * (X * frequency + Y * 3) + np.sin(TAU * Y * 7) * wash)
            + np.cos(TAU * (Y * (frequency + 1) - X * 3) + np.sin(TAU * X * 5) * wash)) * .5


def rgb(path, channels, size=SIZE):
    values = np.stack(channels, -1).clip(0, 1)
    image = Image.fromarray(np.round(values * 255).astype("uint8"))
    if size != SIZE:
        image = image.resize((size, size), Image.Resampling.LANCZOS)
    image.save(DEST / path, lossless=True, method=6)


def maps(name, height, strength, roughness, reflectance, size=SIZE):
    dx = np.roll(height, 1, axis=1) - np.roll(height, -1, axis=1)
    dy = np.roll(height, -1, axis=0) - np.roll(height, 1, axis=0)
    dx *= strength
    dy *= strength
    length = np.sqrt(1 + dx**2 + dy**2)
    rgb(name + "-normal.webp", (.5 + .5 * dx / length, .5 + .5 * dy / length, .5 + .5 / length), size)
    rgb(name + "-surface.webp", (.73 + .27 * height, roughness, reflectance), size)


def reptile():
    # Low, rounded scales with folds and pores at finer resolutions.
    v = Y * 58 + .26 * wrinkles(9, 1.4)
    u = X * 46 + np.floor(v) % 2 * .5 + .19 * wrinkles(5, 2.3)
    a, b = u % 1 - .5, v % 1 - .5
    edge = np.maximum(0, 1 - (a / .52)**2 - (b / .59)**2)
    dome = edge**2 * (1 - b*.24)
    pores = wrinkles(211, .45) * .016 + RNG.random((SIZE, SIZE)) * .010
    height = (.54 + .25*dome + pores + .16*wrinkles(11, 2.7)).clip(0, 1)
    maps("hide", height, 4.9, .67-.18*dome+pores*.55, .77+.13*dome)


def steel():
    # Long toolmarks with small pits and offset machining marks.
    grooves = .11*wrinkles(13, .35) + .09*np.sin(TAU*(Y*161+X*2)+np.sin(TAU*X*9)*.65)
    scuffs = np.maximum(0, np.sin(TAU*(Y*73-X*2)) - .78) * (.5 + .5*wrinkles(7, 2.0))
    pits = np.maximum(0, RNG.random((SIZE, SIZE))-.91)*.7
    height = (.66 + grooves - scuffs*.39 - pits).clip(0, 1)
    maps("steel", height, 7.0, .31 + .44*(1-height), .81+.16*height)


def fabric():
    ythread = np.sin(TAU * Y * 105)
    xthread = np.cos(TAU * X * 92)
    height = (.55+.16*xthread+.12*ythread+.065*xthread*ythread
              +.09*wrinkles(17, 2.3)).clip(0, 1)
    maps("weave", height, 7.1, .64+.21*(1-height), .70+.23*height)


def wing():
    veins = np.zeros_like(X)
    for stem, curve in ((.13,-.11),(.29,.03),(.52,.15),(.80,.23)):
        path = .29 + X*stem + X*X*curve - X*.15
        trunk = np.exp(-((Y-path)/(.011-.006*X))**2)
        veins += trunk * (.76-.42*X)
        for start in (.28,.53,.71):
            travel = np.maximum(0,X-start)
            branch = path - travel*.44 + travel*travel*.23
            veins += np.exp(-((Y-branch)/.0047)**2) * (X>start) * np.exp(-travel*10) * .34
    creases = wrinkles(32,1.9)
    grain = wrinkles(151,1.1)*.017 + RNG.random(X.shape)*.009
    height = (.51 + .20*veins + .066*creases + grain).clip(0,1)
    maps("wing", height, 7.2, .73-.30*veins+.05*creases, .69+.24*height)
    tint = .72+.11*wrinkles(8,1.5)+.053*creases-.29*veins+.34*grain
    rgb("wing-color.webp",(tint,tint,tint))


def horn():
    lengthwise = X + .006*wrinkles(7,2.6)
    flutes = .64*np.sin(TAU*lengthwise*21) + .36*np.sin(TAU*lengthwise*47)
    rings = np.cos(TAU*Y*17 + .44*wrinkles(6,1.9))**4
    weathering = wrinkles(80,.9)
    height = (.53 + .071*flutes - .087*rings + .03*weathering).clip(0,1)
    maps("horn", height, 7.7, .47+.18*rings+.10*weathering, .72+.23*height, 512)
    tint = .91 - .22*rings - .085*flutes - .18*Y + .045*weathering
    rgb("horn-color.webp",(tint,tint*.97,tint*.94),512)


def bone():
    pores = np.maximum(0, RNG.random(X.shape)-.92)
    fissures = np.maximum(0, wrinkles(71,2.3)-.63)
    height = (.72 + .11*wrinkles(11,1.7) - .10*fissures - .65*pores).clip(0,1)
    maps("bone", height, 4.8, .32+.29*(1-height)+.63*pores, .82+.14*height, 512)


def timber():
    # Grain wraps around small knots and alternates soft and hard growth.
    grain = X.copy()
    for x, y in ((.13,.16),(.61,.44),(.84,.80)):
        radius = ((X-x)/.12)**2 + ((Y-y)/.18)**2
        grain += .057*np.exp(-radius)*(1+.7*np.sin((Y-y)*36))
    coarse = np.sin(TAU*(grain*23 + .085*wrinkles(8,1.0)))
    fibres = np.cos(TAU*(grain*153 + .14*wrinkles(11,2.4)))
    coarse = .5+.5*coarse
    height = (.30+.28*coarse+.068*fibres+.059*wrinkles(13,1.1)).clip(0,1)
    maps("wood", height, 5.9, .67-.25*coarse+.07*fibres, .75+.20*height)
    tint = .54+.38*coarse+.10*fibres
    rgb("wood-color.webp",(tint,tint*.94,tint*.85))


def stone():
    mineral = wrinkles(34,4.4)*.14 + wrinkles(91,2.5)*.067
    seam = wrinkles(12,3.6)+wrinkles(17,5.1)*.48
    grooves = np.exp(-(seam / .049)**2) * (.48+.44*wrinkles(9,2.4))
    pits = np.maximum(0,RNG.random(X.shape)-.84)
    height = (.55+mineral-.26*grooves-.38*pits).clip(0,1)
    maps("stone",height,6.4,.69+.19*grooves-mineral*.22,.77+height*.14,512)


def ice():
    # Broken crystal faces, hairline cracks and pale pockets of trapped frost.
    size = 11
    u = X * size + .06 * wrinkles(7, 1.4)
    v = Y * size + .06 * wrinkles(8, 2.4)
    cell_x, cell_y = np.floor(u), np.floor(v)
    rng = np.random.default_rng(9372)
    sites = rng.random((size, size, 2), dtype=np.float32) * .73 + .135
    first = np.full_like(X, 20)
    second = first.copy()
    face = np.zeros_like(X)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            px, py = cell_x + dx, cell_y + dy
            site = sites[py.astype(int) % size, px.astype(int) % size]
            distance = (u - px - site[..., 0])**2 + (v - py - site[..., 1])**2
            closer = distance < first
            face = np.where(closer, site[..., 1], face)
            second = np.where(closer, first, np.minimum(second, distance))
            first = np.minimum(first, distance)
    crack = np.exp(-((second - first) / .043)**2)
    crystals = np.maximum(0, wrinkles(133, 2.6) - .45)**2
    frost = (.48 + .36 * wrinkles(13, 3.2) + rim_ice(crack)).clip(0, 1)
    height = (.57 + .21 * face - .29 * crack + crystals * .09 + .10 * frost).clip(0, 1)
    maps("ice", height, 4.7, .085 + .39 * frost + .12 * crack, .79 + .19 * face)
    tone = .63 + .23 * face + .18 * frost - .26 * crack + .23 * crystals
    rgb("ice-color.webp", (tone * .86, tone * .97, tone * 1.12))


def rim_ice(crack):
    return .38 * np.sqrt(crack) + .07 * wrinkles(63, 2.1)


def probe():
    w, h = 512, 256
    x, y = np.meshgrid(np.linspace(-np.pi,np.pi,w,endpoint=False), np.linspace(0,np.pi,h,endpoint=False))
    (cx, sy), (sinx, cy) = (np.cos(x),np.sin(y)), (np.sin(x),np.cos(y))
    dome = np.stack((np.maximum(0,cy) * .31+.11, np.maximum(0,cy)*.43+.10, np.maximum(0,cy)*.75+.13), -1)
    for azimuth,altitude,width,color in [(-.7,.78,25,(5.4,3.1,1.75)),(1.9,.48,17,(.57,1.68,3.95)),(-2.8,.20,36,(2.3,.67,.52))]:
        facing=(cx*np.cos(azimuth)+sinx*np.sin(azimuth))*sy*np.cos(altitude)+cy*np.sin(altitude)
        dome += np.exp((facing.clip(-1,1)-1)*width)[...,None]*np.array(color)
    peak=dome.max(axis=-1)
    _, exponent=np.frexp(peak)
    pixels=np.empty((h,w,4),dtype=np.uint8)
    pixels[:,:,:3]=np.rint(dome*(np.ldexp(1.,8-exponent)[...,None])).clip(0,255).astype("uint8")
    pixels[:,:,3]=(exponent+128).astype("uint8")
    with (DEST/"sky-light.hdr").open("wb") as out:
        out.write(f"#?RADIANCE\nFORMAT=32-bit_rle_rgbe\n\n-Y {h} +X {w}\n".encode())
        for row in pixels:
            out.write(bytes((2,2,w>>8,w&255)))
            for channel in row.T:
                for start in range(0,w,128):
                    out.write(bytes((128,)))
                    out.write(channel[start:start+128].tobytes())


if __name__ == "__main__":
    if "--ice-only" in sys.argv:
        ice()
    else:
        reptile()
        steel()
        fabric()
        wing()
        horn()
        bone()
        timber()
        stone()
        ice()
        probe()
