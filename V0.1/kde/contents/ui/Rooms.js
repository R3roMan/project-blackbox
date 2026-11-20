.pragma library

var rooms = {
    shrine: { name: "Home Shrine", subtitle: "Everyday workspace", image: "shrine.png", accent: "#f2c18a" },
    sky: { name: "Star Sky", subtitle: "Constellations and projects", image: "sky.jpg", accent: "#bcb6ff" },
    abyss: { name: "Abyss", subtitle: "Research, experiments and unfinished work", image: "abyss.jpg", accent: "#70decd" },
    media: { name: "Media", subtitle: "Films, references and artwork", image: "media.jpg", accent: "#f5a4ad" },
    code: { name: "Pure Code", subtitle: "Blackbox terminal", image: "pure-code.svg", accent: "#91ceb7" },
    lab: { name: "Droid Lab", subtitle: "George Droid’s game workshop", image: "lab.jpg", accent: "#78e0d4" }
}

var order = ["media","shrine","lab","sky","abyss"]
var routes = {
    shrine: { up: "sky", down: "abyss", left: "media", right: "lab" },
    sky: { down: "shrine" },
    abyss: { up: "shrine" },
    media: { right: "shrine" },
    lab: { left: "shrine" }
}

var transitions = {
    "shrine:sky": { kind: "lookUp", label: "Look up" },
    "sky:shrine": { kind: "lookDown", label: "Look down" },
    "shrine:media": { kind: "lookLeft", label: "Look left" },
    "media:shrine": { kind: "lookRight", label: "Look towards the Shrine" },
    "shrine:lab": { kind: "lookRight", label: "Look right" },
    "lab:shrine": { kind: "lookLeft", label: "Look towards the Shrine" },
    "shrine:abyss": { kind: "drop", label: "Fall into the Abyss" },
    "abyss:shrine": { kind: "rise", label: "Rise to the surface" }
}

var stars = [
    { x: .36, y: .43, title: "Ace Druggie", target: "lab", detail: "Game project · open Droid Lab" },
    { x: .45, y: .31, title: "Experiments", target: "abyss", detail: "Research and prototypes · open Abyss" },
    { x: .63, y: .27, title: "References", target: "media", detail: "Artwork and references · open Media" }
]

var actions = {
    shrine: [{title:"Star chart",target:"sky"},{title:"Workshop",target:"lab"},{title:"Reference shelf",target:"media"}],
    abyss: [{title:"Explore another scene",action:"variant",detail:"Cycle the Ruins and Trench backgrounds."}],
    media: [{title:"Full artwork",action:"clean",detail:"Hide the interface to view the current artwork."},
        {title:"Replace this image",action:"edit"}],
    lab: [{title:"Assets",action:"edit"}]
}

function title(id, edits) {
    return edits[id] && edits[id].name ? edits[id].name : rooms[id].name
}

function readEdits(text) {
    try {
        var edits = JSON.parse(text)
        return edits && typeof edits === "object" && !Array.isArray(edits) ? edits : {}
    } catch (_) {
        return {}
    }
}
