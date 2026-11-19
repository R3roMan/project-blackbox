const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const source = path.resolve(__dirname, "../game");
const modules = new Map();

function load(file) {
    if (modules.has(file))
        return modules.get(file);
    const scope = vm.createContext({});
    modules.set(file, scope);
    const code = fs.readFileSync(path.join(source, file), "utf8")
        .replace(/^\.pragma library$/gm, "")
        .replace(/^\.import "([^"]+)" as (\w+)$/gm, (_, entry, alias) => {
            scope[alias] = load(entry);
            return "";
        });
    vm.runInContext(code, scope, { filename: file });
    return scope;
}

const { weapons, activeAbilities } = load("Loadout.js");
const art = load("SkillArt.js");
const enemies = Object.fromEntries(Object.entries(load("Encounters.js").enemyTypes).map(([id, spec]) => [
    id, spec.ship || spec.role === "alien" || spec.sniper ? "alien" : spec.abyss ? "abyss"
        : spec.angel || spec.role === "angel" ? "angel" : spec.role === "boss" ? "boss"
        : spec.boltTime || spec.rangedInterval ? "ranged" : "melee"
]));
const kinds = Object.fromEntries(Object.entries(activeAbilities).map(([id, spec]) => [id, art.profile(spec).kind]));

if (process.argv.includes("--audit")) {
    const missing = [];
    for (const file of [
        ...Object.keys(weapons).flatMap(id => ["fire-" + id, "reload-" + id]),
        ...Object.keys(kinds).map(id => "ability-" + id),
        ...Object.keys(enemies).map(id => "attack-" + id)
    ]) {
        const full = path.resolve(__dirname, "../audio", file + ".wav");
        if (!fs.existsSync(full) || fs.statSync(full).size < 45)
            missing.push(file);
    }
    if (missing.length) {
        console.error("Missing clips: " + missing.join(", "));
        process.exitCode = 1;
    } else {
        console.log(Object.keys(weapons).length + " weapon profiles and " + Object.keys(kinds).length + " active casts and " + Object.keys(enemies).length + " enemy attacks have audio.");
    }
} else {
    console.log(JSON.stringify(process.argv.includes("--enemies") ? enemies : kinds));
}
