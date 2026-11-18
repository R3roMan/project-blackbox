#!/usr/bin/env python3
"""Illustrate the Witch's Vault deck with engraved shapes and coloured ink."""
from concurrent.futures import ThreadPoolExecutor
from html import escape
from io import BytesIO
from math import cos, sin, pi
from pathlib import Path
from random import Random
from subprocess import run

from PIL import Image

OUT = Path(__file__).resolve().parents[1] / "art" / "tarot"
W, H = 180, 270
INK = "#160e1b"
BONE = "#ead4a2"
GOLD = "#c4945a"
MAJOR_LINE = "#543047"
MAJORS = [
    ("The Fool", "#e49961"), ("The Magician", "#d8ac65"), ("The High Priestess", "#8ba4cf"),
    ("The Empress", "#e4a4a2"), ("The Emperor", "#dd7762"), ("The Hierophant", "#c298db"),
    ("The Lovers", "#e795b0"), ("The Chariot", "#ddaf77"), ("Strength", "#dfa172"),
    ("The Hermit", "#9bd1bb"), ("Wheel of Fortune", "#dfc576"), ("Justice", "#cdd0df"),
    ("The Hanged Man", "#a5bb8b"), ("Death", "#ae8ccf"), ("Temperance", "#8ec9d4"),
    ("The Devil", "#a2dd71"), ("The Tower", "#ed8e6c"), ("The Star", "#c3b3ef"),
    ("The Moon", "#b8adf6"), ("The Sun", "#f6c66b"), ("Judgement", "#e68c85"),
    ("The World", "#b4cf86"),
]
SUITS = [
    ("Wands", "#ed955d"), ("Cups", "#bc748e"), ("Swords", "#a8b8d7"), ("Pentacles", "#baad75"),
]
RANKS = ("Ace Two Three Four Five Six Seven Eight Nine Ten Page Knight Queen King").split()
ROW_PIPS = {1:[1], 2:[1,1], 3:[1,2], 4:[2,2], 5:[2,1,2], 6:[2,2,2], 7:[2,3,2],
            8:[2,2,2,2], 9:[3,3,3], 10:[3,2,2,3]}


def path(shape, fill="none", stroke="none", width=1):
    return f'<path d="{shape}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round"/>'


def ring(x, y, r, fill="none", stroke="none", width=1):
    return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"/>'


def tile(x, y, width, height, fill, stroke="none", radius=0):
    return f'<rect x="{x}" y="{y}" width="{width}" height="{height}" fill="{fill}" stroke="{stroke}" rx="{radius}"/>'


def line(x1, y1, x2, y2, color=GOLD, width=.9):
    return path(f"M{x1},{y1} {x2},{y2}", "none", color, width)


def place(items, x, y, scale=1, angle=0):
    return f'<g transform="translate({x},{y}) rotate({angle}) scale({scale})">{items}</g>'


def label(x, y, value, size, color=GOLD):
    return f'<text x="{x}" y="{y}" text-anchor="middle" font-family="DejaVu Serif" font-size="{size}" fill="{color}">{escape(value)}</text>'


def star(x, y, r, color=BONE, points=4, indent=.32):
    outline = []
    for k in range(points*2):
        angle = k*pi/points-pi/2
        distance = r if k%2==0 else r*indent
        outline.append(f"{x+cos(angle)*distance:.2f},{y+sin(angle)*distance:.2f}")
    return path("M"+" ".join(outline)+" Z", color)


def shade(shape, color):
    return path(shape, INK, color, 1.2)


def wings(color):
    feather = shade("M0,0 Q-24,-23 -61,-47 Q-61,-19 -51,-9 L-58,-14 Q-48,17 -16,27 L-28,28 Q-13,37 0,25 Z",color)
    feather += path("M-4,15 Q-28,3 -53,-29 M-12,20 Q-37,10 -45,-2 M-16,24 Q-31,18 -37,13","none",color,.9)
    return feather + '<g transform="scale(-1,1)">'+feather+'</g>'


def skull(color=BONE, horns=True):
    features = shade("M-26,-6 Q-28,-36 0,-40 Q28,-36 26,-6 L19,7 17,20 7,26 -7,26 -17,20 -19,7 Z",color)
    features += path("M-20,-17 Q-12,-23 -3,-12 Q-5,-3 -16,-3 Z M20,-17 Q12,-23 3,-12 Q5,-3 16,-3 Z",color)
    features += path("M0,-6 5,5 0,2 -5,5 Z",color)
    features += path("M-15,13 Q0,7 15,13 M-15,18 Q0,22 15,18 M-10,12 V20 M-5,11 V21 M0,11 V22 M5,11 V21 M10,12 V20","none",color,.8)
    features += path("M-18,-29 Q0,-41 17,-30 M-11,-31 Q1,-27 11,-33","none",color,.85)
    if horns:
        horn = shade("M-18,-30 Q-37,-31 -37,-61 Q-25,-46 -9,-38 Z",color)
        features = horn+'<g transform="scale(-1,1)">'+horn+'</g>'+features
    return features


def eye(color):
    return shade("M-22,0 Q0,-17 22,0 Q0,18 -22,0 Z",color)+ring(0,0,8,color)+path("M0,-7 Q4,0 0,7 Q-4,0 0,-7 Z",INK)


def moon(x, y, scale, color):
    return place(path("M14,-29 A33,33 0 1 0 30,17 A27,27 0 0 1 14,-29 Z",color),x,y,scale)


def crown(color):
    return shade("M-20,7 -24,-11 -10,-2 0,-19 10,-2 24,-11 20,7 Z",color)+line(-18,3,18,3,color)+star(0,-4,3,color)


def flame(color):
    return path("M0,25 C-32,14 -24,-6 -11,-21 C-18,2 2,-8 0,-40 C26,-27 12,-4 26,-14 C35,8 17,22 0,25 Z",color)+path("M1,18 C-13,14 -10,7 3,-7 C3,1 18,8 1,18 Z",INK)


def goblet(color):
    return shade("M-31,-29 Q-34,6 -7,12 V27 L-24,34 H24 L7,27 V12 Q34,6 31,-29 Z",color)+path("M-31,-28 Q0,-38 31,-28 Q0,-17 -31,-28 M-27,-19 Q0,-8 27,-19 M-13,7 Q0,13 13,7","none",color,1.1)+star(0,-4,6,color)


def sword(color):
    return shade("M0,-53 8,-30 5,17 18,20 17,25 5,24 4,43 0,50 -4,43 -5,24 -17,25 -18,20 -5,17 -8,-30 Z",color)+line(0,-45,0,17,color)+ring(0,35,2,color)


def wand(color):
    return shade("M-4,49 -5,9 -9,-9 -6,-31 -9,-43 1,-52 9,-43 6,-31 9,-9 5,9 4,49 Z",color)+path("M-4,29 4,20 M-4,19 4,10 M-3,9 3,0","none",color,1.1)+star(0,-40,6,color)+ring(0,-40,10,"none",color,.65)


def coin(color):
    outline = ring(0,0,31,INK,color,1.5)+ring(0,0,26,"none",color,.6)
    points = [(cos(k*2*pi/5-pi/2)*20,sin(k*2*pi/5-pi/2)*20) for k in [0,2,4,1,3,0]]
    return outline+path("M"+" ".join(f"{x:.2f},{y:.2f}" for x,y in points),"none",color,1.4)+ring(0,0,4,color)


def priest(color, authority="", width=1):
    mantle = shade("M-61,79 Q-53,17 -28,3 Q-29,-38 0,-51 Q29,-38 28,3 Q53,17 61,79 Q0,98 -61,79 Z",color)
    mantle += path("M-50,73 -31,23 -16,17 -22,78 M50,73 31,23 16,17 22,78 M-9,35 -4,80 M9,35 4,80","none",color,.9)
    mantle += star(0,48,13,color,6)
    return place(mantle+place(skull(color,authority!="gentle"),0,-17,.64)+(place(crown(color),0,-49,.80) if authority=="crown" else ""),0,0,width)


def bones(x, y, color):
    return place(path("M-42,21 -9,17 13,25 38,19 M-37,29 -8,24 11,32 42,26 M-22,18 -1,25 20,20","none",color,.9),x,y)


def skyline(color):
    positions=[(-67,10),(-58,19),(-50,8),(-43,19),(-35,13),(-20,25),(-11,12),(5,19),(23,13),(34,22),(53,25),(64,12)]
    rows=[]
    for x,h in positions:
        rows.append(shade(f"M{x-3},64 v{-h} l3,-8 3,8 v{h} Z",color))
    return "".join(rows)+line(-72,65,72,65,color)


def major(number, color):
    halo = ring(0,0,58,"none",color,.65)+ring(0,0,51,"none",MAJOR_LINE,.8)
    blade = sword(color)
    lantern = shade("M-22,18 -16,-16 H16 L22,18 15,28 H-15 Z M-12,-16 Q-13,-35 0,-35 Q13,-35 12,-16",color)
    lantern += place(flame(color),0,8,.39)
    scale = shade("M-5,49 0,-44 5,49 H23 V55 H-23 V49 Z",color)+line(-58,-24,58,-24,color,2)
    for x in [-44,44]:
        scale += shade(f"M{x-17},13 {x},-24 {x+17},13 Q{x},36 {x-17},13 Z",color)
    wheel = ring(0,0,64,INK,color,1.7)+ring(0,0,56,"none",color,.8)
    for step in range(8):
        angle=step*pi/4
        wheel += line(cos(angle)*22,sin(angle)*22,cos(angle)*54,sin(angle)*54,color,1.1)
        wheel += star(cos(angle)*60,sin(angle)*60,3,color)
    wheel += place(coin(color),0,0,.73)
    tower = shade("M-37,63 -31,4 -26,4 -22,-24 -33,-30 -31,-52 -15,-48 -11,-58 0,-53 11,-58 15,-48 31,-52 33,-30 22,-24 26,4 31,4 37,63 Z",color)
    tower += path("M-22,-23 23,-23 M-25,-1 25,-1 M-29,18 29,18 M-33,44 33,44 M-6,59 V36 Q0,26 6,36 V60 M-7,-10 V-18 H7 V-10 Z","none",color,.9)
    lightning = path("M-12,-76 -4,-97 48,-107 17,-88 33,-86 7,-68 14,-79 Z",color)
    heart = path("M0,25 C-11,13 -37,-1 -23,-20 Q-9,-32 0,-12 Q9,-32 23,-20 C37,-1 11,13 0,25 Z",color)
    pumpkin = shade("M0,-37 C-62,-55 -77,21 -32,43 Q0,53 32,43 C77,21 62,-55 0,-37 Z",color)
    pumpkin += path("M0,-38 C-41,-20 -42,23 -17,43 M0,-38 C41,-20 42,23 17,43 M-4,-38 Q-2,-55 12,-61 L16,-53 Q5,-47 5,-38","none",color,1.5)
    pumpkin += path("M-41,-7 -13,-19 -18,5 Z M41,-7 13,-19 18,5 Z M-42,15 -18,26 -11,18 0,30 9,20 17,27 42,13 Q30,40 0,36 Q-30,39 -42,15 Z",color)
    designs=[
        skyline(color)+place(priest(color,"gentle"),-10,4,.80,-14)+place(wand(color),39,-13,.59,21)+star(45,-67,15,color),
        halo+place(priest(color),0,13,.92)+place(wand(color),-48,-18,.47,12)+place(goblet(color),49,5,.49)+path("M-29,-60 Q-15,-76 0,-62 Q15,-48 29,-62 Q15,-76 0,-62 Q-15,-48 -29,-60 Z","none",color,1.6),
        moon(0,-39,1.2,color)+place(priest(color,"gentle"),0,19,.89)+place(eye(color),0,43,.82)+line(-56,-40,-56,66,color)+line(56,-40,56,66,color),
        halo+place(priest(color,"crown"),0,-1,.91)+place(heart,-49,43,.49)+place(heart,49,43,.49)+bones(0,41,color),
        shade("M-58,68 V-40 L-43,-62 H43 L58,-40 V68 Z",color)+place(priest(color,"crown"),0,-2,.92)+place(blade,-48,8,.59)+place(coin(color),46,40,.44),
        place(wings(color),0,-10,.91)+place(priest(color,"crown"),0,-1,.83)+place(goblet(color),0,65,.53),
        halo+place(heart+line(0,-38,0,-22,color),0,-35,1)+place(skull(color),-34,24,.88,15)+place(skull(color),34,24,.88,-15),
        skyline(color)+place(wings(color),0,-9,1.01)+place(skull(color),0,-11,.88)+place(wheel,-41,51,.43)+place(wheel,41,51,.43),
        halo+place(skull(color),0,-13,1.37)+path("M-49,42 Q-11,74 28,40 L38,30 50,58 45,69 M-47,40 -55,51 -47,63 -31,70","none",color,2.2)+star(0,51,10,color),
        skyline(color)+place(priest(color,"gentle"),-17,-8,.87)+place(lantern,37,13,.93),
        wheel+place(skull(color),0,-67,.46)+place(wand(color),0,66,.35,90),
        scale+place(eye(color),0,-59,.80)+place(blade,0,20,.43),
        path("M-60,-72 Q-23,-53 0,-68 Q23,-53 60,-72 M0,-67 V-34","none",color,2)+place(priest(color,"gentle"),0,17,.80,180)+stars(color,[-47,48]),
        bones(0,53,color)+place(priest(color),0,-3,.86)+path("M-45,72 33,-55 Q35,-77 63,-81 Q19,-82 15,-58 L-48,69 Z",color),
        halo+place(goblet(color),-37,-20,.90,-38)+place(goblet(color),34,41,.94)+path("M-21,-39 C24,-44 -11,27 30,20 M-17,-44 C33,-46 -5,26 34,18","none",color,1.5),
        place(wings(color),0,17,1.08)+place(flame(color),0,0,1.49)+place(pumpkin,0,19,.95)+place(coin(color),0,-65,.56),
        skyline(color)+place(tower,0,8,1.07)+lightning+path("M-24,-30 10,-12 -4,7 21,24 2,29 -9,48","none",color,2)+star(46,-37,12,color),
        skyline(color)+star(0,-44,36,color,8,.27)+stars(color,[-48,49])+place(eye(color),0,22,.87)+place(goblet(color),0,59,.42),
        moon(0,-32,1.63,color)+place(tower,-49,34,.37)+place(tower,49,34,.37)+place(skull(color,False),0,34,.59)+star(33,-53,8,color),
        skyline(color)+ring(0,-23,42,INK,color,2)+star(0,-23,61,color,12,.71)+ring(0,-23,31,INK,color,1.4)+place(eye(color),0,-23,1.04),
        place(wings(color),0,-41,.95)+place(skull(color,False),0,-45,.56)+place(goblet(color),0,-8,.64,180)+place(skull(color),-34,48,.60)+place(skull(color),34,48,.60),
        wheel+place(priest(color,"gentle"),0,1,.66)+stars(color,[-65,65])+star(0,-78,8,color)+star(0,77,8,color),
    ]
    return designs[number]


def stars(color, xs):
    return "".join(star(x,(-1)**index*38,8-index,color) for index,x in enumerate(xs))


def minor(suit, rank, color):
    draw = [wand, goblet, sword, coin][suit]
    emblem = draw(color)
    if rank<=10:
        rows = ROW_PIPS[rank]
        scale = .98 if rank==1 else .56 if rank<=3 else .44 if len(rows)<4 else .34
        marks=[]
        for row,count in enumerate(rows):
            y=(row-(len(rows)-1)*.5)*53
            for column in range(count):
                x=(column-(count-1)*.5)*45
                angle = (8 if column%2 else -8)*(1 if row%2 else -1) if suit in [0,2] and rank>1 else 0
                marks.append(place(emblem,x,y,scale,angle))
        backdrop=ring(0,0,59,"none",MAJOR_LINE,.8)+ring(0,0,53,"none",MAJOR_LINE,.6)
        return backdrop+"".join(marks)+star(0,-79,5,color,6)+star(0,79,5,color,6)
    figure = [
        place(priest(color,"gentle"),0,1,.79,-9)+place(emblem,43,20,.54,13),
        place(wings(color),0,-39,.91)+place(priest(color),-9,4,.82,-6)+place(emblem,40,6,.62,28),
        place(moon(0,0,1,color),0,-30,1.05)+place(priest(color,"crown"),0,-2,.92)+place(emblem,0,50,.51),
        shade("M-55,63 V-51 L-37,-60 0,-44 37,-60 55,-51 V63 Z",color)+place(priest(color,"crown"),0,2,.95)+place(emblem,-50,8,.49)+place(emblem,50,8,.49),
    ]
    return figure[rank-11]


def frame(bearing, title, number, color, figure, back=False):
    rng = Random(number+6361)
    strips = []
    for _ in range(430):
        x, y = rng.randrange(10,171),rng.randrange(11,260)
        strips.append(ring(x,y,rng.uniform(.15,.46),rng.choice(["#533140","#372131","#362836","#513b39"])))
    borders = tile(2,2,176,266,"#241625",GOLD,9)+tile(7,7,166,256,INK,"#603743",6)
    borders += tile(12,12,156,246,"none",color,5)+tile(17,31,146,193,"url(#shade)", "#764655",4)
    corners = ""
    for x in [22,158]:
        for y in [37,219]:
            corners += star(x,y,5,color,4)+ring(x,y,6,"none",GOLD,.4)
    hatches=""
    for k in range(19):
        y=39+k*9.5
        hatches+=line(21,y,28,y+4,"#68445b",.5)+line(152,y+4,159,y,"#68445b",.5)
    seal = star(90,125,65,"#32203d",8,.83)+ring(90,125,61,"none","#694859",.6)
    header = label(90,25,bearing,9,color)
    footer=label(90,242,title,12.5 if len(title)<20 else 10.5,BONE)+line(40,249,140,249,"#73434e",.65)
    if back:
        footer = label(90,243,"THE WITCH’S VAULT",9,GOLD)
    art = borders+"".join(strips)+corners+hatches+seal+place(figure,90,126)+header+footer
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><defs><radialGradient id="shade"><stop stop-color="#342441"/><stop offset="1" stop-color="#1a1022"/></radialGradient></defs>{art}</svg>'


def render(card):
    name, drawing = card
    output=run(["rsvg-convert","--keep-aspect-ratio","-w","270","-h","405"],input=drawing.encode(),capture_output=True,check=True)
    with Image.open(BytesIO(output.stdout)) as img:
        img.save(OUT/name,format="webp",quality=89,method=5)


def main():
    OUT.mkdir(parents=True,exist_ok=True)
    cards = [(f"{index:02d}.webp",frame(f"ARCANA  •  {index:02d}", name,index,color,major(index,color)))
             for index,(name,color) in enumerate(MAJORS)]
    for suit,(name,color) in enumerate(SUITS):
        for rank,label_text in enumerate(RANKS,1):
            art=22+14*suit+rank-1
            cards.append((f"{art:02d}.webp",frame(name.upper(),f"{label_text} of {name}",art,color,minor(suit,rank,color))))
    seal = place(coin("#b67c78"),0,0,1.54)+place(eye(BONE),0,0,.56)
    seal += place(wings("#a4636a"),0,0,.92)+place(eye(BONE),0,0,.88)
    seal += moon(0,-60,.49,GOLD)+place(flame("#a4636a"),0,59,.37,180)
    cards.append(("back.webp",frame("FIVE DOORS", "",78,"#ad787d",seal,True)))
    with ThreadPoolExecutor(max_workers=4) as pool:
        list(pool.map(render,cards))


if __name__=="__main__":
    main()
