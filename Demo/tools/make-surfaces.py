"""Build the shared Ultra material maps and the neutral workshop light probe."""
from pathlib import Path

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


def rgb(path, channels):
    values = np.stack(channels, -1).clip(0, 1)
    Image.fromarray(np.round(values * 255).astype("uint8")).save(DEST / path, lossless=True, method=6)


def maps(name, height, strength, roughness, reflectance):
    dx = np.roll(height, 1, axis=1) - np.roll(height, -1, axis=1)
    dy = np.roll(height, -1, axis=0) - np.roll(height, 1, axis=0)
    dx *= strength
    dy *= strength
    length = np.sqrt(1 + dx**2 + dy**2)
    rgb(name + "-normal.webp", (.5 + .5 * dx / length, .5 + .5 * dy / length, .5 + .5 / length))
    rgb(name + "-surface.webp", (.73 + .27 * height, roughness, reflectance))


def reptile():
    # Stagger the rows and round the edges of each scale. Broad folds
    # and pores break up the silhouette of the small repeating tiles.
    v = Y * 62 + .23 * wrinkles(9, 1.4)
    u = X * 48 + np.floor(v) % 2 * .5 + .23 * wrinkles(5, 2.3)
    a, b = u % 1 - .5, v % 1 - .5
    shape = np.maximum(abs(a) * .92 + abs(b) * .31, abs(b) * 1.12)
    dome = np.maximum(0, 1 - (shape / .53)**3)**1.25
    pores = wrinkles(211, .45) * .04 + RNG.random((SIZE, SIZE)) * .022
    height = (.77 * dome + pores + .12 * wrinkles(11, 2.7)).clip(0, 1)
    maps("hide", height, 9.7, .65-.29*dome+pores*.55, .72+.21*dome)


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
    reptile()
    steel()
    fabric()
    probe()
