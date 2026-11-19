.pragma library

var rooms = {
    shrine: { name: "Home Shrine", subtitle: "Everyday workspace", image: "shrine.png", accent: "#f2c18a" },
    sky: { name: "Star Sky", subtitle: "Constellations and projects", image: "sky.jpg", accent: "#bcb6ff" },
    abyss: { name: "Abyss", subtitle: "Research, experiments and unfinished work", image: "abyss.jpg", accent: "#70decd" },
    birth: { name: "Birth Place", subtitle: "Private files, vaults and system recovery", image: "birth.jpg", accent: "#9cb8d4" },
    media: { name: "Media", subtitle: "Films, references and artwork", image: "media.jpg", accent: "#f5a4ad" },
    lab: { name: "Droid Lab", subtitle: "George Droid’s game workshop", image: "lab.jpg", accent: "#78e0d4" },
    code: { name: "Pure Code", subtitle: "Editor, terminal and documentation", image: "code.jpg", accent: "#a9cfff" }
}

var order = ["code", "media", "shrine", "lab", "sky", "abyss", "birth"]
var routes = {
    shrine: { up: "sky", down: "abyss", left: "media", right: "lab" },
    sky: { up: "birth", down: "shrine" },
    abyss: { up: "shrine", down: "birth" },
    birth: { up: "abyss", down: "sky" },
    media: { left: "code", right: "shrine" },
    lab: { left: "shrine", right: "code" },
    code: { left: "lab", right: "media" }
}

var transitions = {
    "shrine:sky": { kind: "lookUp", label: "Look up" },
    "sky:shrine": { kind: "lookDown", label: "Look down" },
    "shrine:media": { kind: "lookLeft", label: "Look left" },
    "media:shrine": { kind: "lookRight", label: "Look towards the Shrine" },
    "shrine:lab": { kind: "lookRight", label: "Look right" },
    "lab:shrine": { kind: "lookLeft", label: "Look towards the Shrine" },
    "shrine:abyss": { kind: "drop", label: "Fall into the Abyss" },
    "abyss:shrine": { kind: "rise", label: "Rise to the surface" },
    "abyss:birth": { kind: "seal", label: "Pass through the vault door" },
    "birth:abyss": { kind: "unseal", label: "Open into the Abyss" },
    "birth:sky": { kind: "birthstars", label: "Darkness gives birth to stars" },
    "sky:birth": { kind: "extinguish", label: "Starlight goes dark" },
    "media:code": { kind: "scan", label: "Scan into Pure Code" },
    "code:media": { kind: "open", label: "Open the scene" },
    "lab:code": { kind: "scan", label: "Switch to the code bench" },
    "code:lab": { kind: "open", label: "Open the workshop" }
}

var stars = [
    { x: .36, y: .43, title: "Ace Druggie", target: "lab", detail: "Game project · open Droid Lab" },
    { x: .45, y: .31, title: "Experiments", target: "abyss", detail: "Research and prototypes · open Abyss" },
    { x: .57, y: .40, title: "Development", target: "code", detail: "Editing and tools · open Pure Code" },
    { x: .63, y: .27, title: "References", target: "media", detail: "Artwork and references · open Media" }
]

var actions = {
    shrine: [{title:"Star chart",target:"sky"},{title:"Workshop",target:"lab"},{title:"Reference shelf",target:"media"}],
    abyss: [{title:"Explore another scene",action:"variant",detail:"Cycle the Ruins and Trench backgrounds."},
        {title:"System recovery",target:"birth"}],
    birth: [{title:"Password vault",detail:"Integration point for KeePassXC. Open and unlock the vault in its own application."},
        {title:"Private files",detail:"Integration point for encrypted storage. Lock and unlock using its own controls."},
        {title:"Recovery",detail:"Keep verified backups and recovery instructions in a separate, trusted location."}],
    media: [{title:"Full artwork",action:"clean",detail:"Hide the interface to view the current artwork."},
        {title:"Replace this image",action:"edit"}],
    lab: [{title:"Develop · Ace Druggie",target:"code"},{title:"Assets",action:"edit"}],
    code: [{title:"Project bench",target:"lab"},{title:"Research",target:"abyss"}]
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
