from pathlib import Path
from random import Random
from math import cos, sin, pi

from PIL import Image, ImageDraw, ImageFilter

DEST = Path(__file__).resolve().parents[1] / "kde/contents/images"
W, H = 1600, 900
DEST.mkdir(parents=True, exist_ok=True)


def plate(top, bottom, light, centre, strength=0.8):
    small = Image.new("RGB", (400, 225))
    pix = small.load()
    rng = Random(42)
    for y in range(225):
        for x in range(400):
            v = y / 224
            dist = ((x / 399 - centre[0]) ** 2 * 2 + (v - centre[1]) ** 2 * 4)
            aura = max(0, 1 - dist) ** 3 * strength
            grain = rng.uniform(-1.8, 1.8)
            pix[x, y] = tuple(round(max(0, min(255, a + (b - a) * v + c * aura + grain)))
                              for a, b, c in zip(top, bottom, light))
    return small.resize((W, H), Image.Resampling.BICUBIC)


def save(name, image):
    image.save(DEST / (name + ".jpg"), quality=91, optimize=True)


def stars(draw, count, seed, until=H):
    rng = Random(seed)
    for _ in range(count):
        x, y = rng.randrange(W), rng.randrange(until)
        size = rng.choices([1, 2, 3], weights=[78, 19, 3])[0]
        light = rng.randint(65, 225)
        draw.ellipse((x, y, x+size, y+size), fill=(int(light*.77), int(light*.88), light))


sky = plate((3, 6, 19), (9, 18, 45), (46, 36, 85), (.56, .46))
stars(ImageDraw.Draw(sky), 1150, 204)
save("sky", sky)

for key, light, base, seed in [
    ("abyss", (38, 98, 106), (3, 10, 19), 12),
    ("trench", (27, 54, 109), (3, 7, 19), 16),
]:
    image = plate(base, (2, 4, 9), light, (.51, .21))
    draw = ImageDraw.Draw(image)
    rng = Random(seed)
    for i, shade in enumerate([(15, 33, 43), (9, 22, 29), (5, 12, 19), (2, 8, 12)]):
        y = 500 + i * 84
        points = [(x, y + rng.randrange(-95, 60)) for x in range(-80, W + 100, 80)]
        draw.polygon(points + [(W, H), (0, H)], fill=shade)
    for x, y, scale in [(165, 515, 1.8), (450, 556, .8), (1030, 613, 1.2), (1330, 530, 1.8)]:
        w, h = 28 * scale, 130 * scale
        draw.polygon([(x, y), (x+w, y), (x+w*1.1, y-h), (x+w*.1, y-h*.96)], fill=(9,22,27))
        draw.line([(x, y-h*.94),(x,y)], fill=(36,57,62), width=3)
    for side in [0, 1]:
        p = [(0,0), (266,0), (150,113), (231,191), (109,306), (149,409), (67,530), (90,614), (0,710)]
        draw.polygon([(W-x if side else x, y) for x,y in p], fill=(2,8,12))
    save(key, image)

media = plate((12,13,39),(26,14,39),(116,47,48),(.24,.51))
d = ImageDraw.Draw(media)
stars(d, 370, 94, 460)
d.ellipse((232,208,410,386), fill=(216,126,113))
rng = Random(83)
for i, colour in enumerate([(57,35,65),(35,25,59),(24,23,47),(13,19,36)]):
    y = 445 + 96*i
    d.polygon([(x,y+rng.randrange(-85,68)) for x in range(-100,W+200,120)]
              + [(W,H),(0,H)], fill=colour)
for i in range(130):
    x = rng.randrange(W)
    y = rng.randrange(620,H)
    d.line((x,y,x+rng.randrange(4,40),y), fill=(35,43,68))
save("media", media)

lab = plate((5,13,19),(9,21,27),(16,51,58),(.5,.43))
d = ImageDraw.Draw(lab)
d.polygon([(0,0),(560,183),(560,581),(0,826)],fill=(10,23,30))
d.polygon([(W,0),(1040,183),(1040,581),(W,826)],fill=(10,23,30))
d.rectangle((560,183,1040,582),fill=(11,36,44))
d.rectangle((617,237,983,536), fill=(12,26,35), outline=(44,84,90),width=6)
d.rounded_rectangle((700,259,900,511),radius=86, fill=(19,45,52),outline=(47,108,112),width=4)
for x in range(-440, W+480, 160):
    d.line((800,580,x,H),fill=(25,46,49),width=2)
for y in [628,692,777,885]:
    d.line((0,y,W,y), fill=(23,43,46),width=2)
for x in [129,316,1105,1294]:
    d.rounded_rectangle((x,318,x+150,472), radius=8, fill=(8,13,22),outline=(35,73,83),width=3)
    for i in range(6):
        d.line((x+18,344+i*17,x+92+(i%3)*12,344+i*17),fill=(30,92,94),width=2)
save("lab", lab)


