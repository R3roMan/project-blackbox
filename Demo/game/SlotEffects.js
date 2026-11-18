.pragma library

function socket(id, title, condition, stat, levels, description, color, format) {
    return { id:id, title:title, condition:condition, stat:stat, levels:levels,
        description:description, color:color, format:format }
}

var weapon = [
    socket("burstEscapement", "Burst escapement", "burst", "recovery", [.92,.90,.88,.86],
        "Burst weapons recover %1% faster between bursts.", "#f5ae68", "reduction"),
    socket("scatterChoke", "Breach choke", "scatter", "close", [.08,.11,.14,.17],
        "Shotguns deal %1% more damage within 430 units.", "#ff886d", "percent"),
    socket("phaseBore", "Phase bore", "piercing", "retention", [.045,.06,.075,.09],
        "Piercing weapons retain %1 extra percentage points of damage through each target.", "#7ddfed", "points"),
    socket("beamSink", "Ceramic heat sink", "sustain", "heatRecovery", [.90,.87,.84,.81],
        "Sustained fire weapons cool from overheat %1% faster.", "#ffc263", "reduction"),
    socket("temperedEdge", "Tempered edge", "melee", "primed", [.08,.11,.14,.17],
        "Primed melee attacks deal %1% more damage after a weapon trick.", "#ff937f", "percent"),
    socket("runeDiode", "Rune diode", "staff", "castRecovery", [.87,.84,.81,.78],
        "Staff spells finish their cast animation %1% faster.", "#caa4ff", "reduction"),
    socket("elementBaffle", "Element baffle", "elemental", "elementalDamage", [.055,.075,.095,.115],
        "An elemental weapon deals %1% more direct damage.", "#96e5c5", "percent"),
    socket("farSightLens", "Far-sight lens", "ranged", "scopedSpread", [.84,.80,.76,.72],
        "While you hold Shift, ranged weapon spread is %1% tighter.", "#92baff", "reduction"),
    socket("heavyCatch", "Heavy catch", "heavy", "reload", [.90,.87,.84,.81],
        "Weapons with a base reload of at least 2 seconds reload %1% faster.", "#eed57c", "reduction"),
    socket("markfinder", "Markfinder", "ranged", "markCrit", [.05,.065,.08,.095],
        "Gain %1 percentage points of critical chance with a ranged weapon against marked targets.", "#fb8eb2", "points")
]

var active = [
    socket("shockClock", "Shock clock", "control", "cooldown", [.93,.91,.89,.87],
        "Frost, Stun, Sticky and Knockback actives recover %1% faster.", "#83dcf1", "reduction"),
    socket("cinderReservoir", "Cinder reservoir", "pyro", "strength", [.35,.48,.61,.74],
        "Burn and Explosive actives gain %1 effect rank. Status level stays the same.", "#ff8857"),
    socket("arcCoil", "Arc matching coil", "arcPair", "cooldown", [.89,.86,.83,.80],
        "An Electric active recovers %1% faster while your selected weapon is Electric.", "#c6a0fa", "reduction"),
    socket("wardCondenser", "Ward condenser", "guardActives", "strength", [.35,.50,.65,.80],
        "Barrier and shield actives gain %1 effect rank.", "#80b9ff"),
    socket("medicineMeter", "Medicine meter", "healingActives", "healRatio", [.09,.12,.15,.18],
        "When this healing active restores health, recover another %1% of that healing, up to 5 HP.", "#83efb3", "percent"),
    socket("rewindFuse", "Rewind fuse", "paired", "otherCooldown", [.65,.9,1.15,1.4],
        "Casting trims %1 seconds from the other active slot's running cooldown.", "#e7b1dd"),
    socket("scribeNotch", "Scribe's notch", "staffHeld", "weaponRecovery", [.10,.15,.20,.25],
        "Casting trims %1 seconds from the current staff's recovery between attacks.", "#e3c1f8"),
    socket("duelistSeal", "Duelist seal", "meleeHeld", "weaponRecovery", [.16,.23,.30,.37],
        "Casting trims %1 seconds from a held melee weapon's attack recovery.", "#ff9f96"),
    socket("kitRelay", "Kit relay", "fullKit", "cooldown", [.91,.88,.85,.82],
        "This active recovers %1% faster while its full three-piece kit is equipped.", "#f0d888", "reduction"),
    socket("abyssResonator", "Abyss resonator", "voidActives", "strength", [.35,.50,.65,.80],
        "Void-themed actives gain %1 effect rank.", "#b191ed")
]

var passive = [
    socket("bandolierLining", "Bandolier lining", "ammoPassives", "ammo", [1,2,3,4],
        "Pair with an ammunition or reload passive to add %1 rounds to magazine weapons.", "#ead088"),
    socket("recoveryWeave", "Recovery weave", "healPassives", "waveHeal", [2,3,4,5],
        "A healing or life-steal passive restores another %1 HP on wave clear.", "#91e0a8"),
    socket("braceFlex", "Spring bracing", "shieldPassives", "shieldRecovery", [.20,.30,.42,.55],
        "Pair with a shield passive to trim %1 seconds from shield recovery.", "#81c7f3"),
    socket("prismBraid", "Prism braid", "elementPassives", "elementDamage", [.025,.04,.055,.07],
        "Pair with a status passive for %1% more direct damage with elemental weapons.", "#acb9ff", "percent"),
    socket("knifeStitch", "Corded grip", "meleePassives", "meleeRecovery", [.035,.05,.065,.08],
        "Pair with a melee passive to reduce melee recovery by %1%.", "#f0a08e", "percent"),
    socket("aimNet", "Focus mesh", "critPassives", "critical", [.015,.02,.027,.035],
        "A critical-hit passive adds %1 percentage points of critical chance.", "#f089a8", "points"),
    socket("traderThread", "Gilt thread", "goldPassives", "killGold", [1,1.5,2,2.5],
        "Pair with an economy passive for up to %1 extra gold per kill before rounding.", "#f3d174"),
    socket("kitGraft", "Grafted lining", "fullKit", "health", [4,6,8,10],
        "While this passive's complete kit is equipped, add %1 maximum HP.", "#e5c178"),
    socket("blastRibs", "Blast ribs", "blastPassives", "blastResist", [.04,.06,.08,.10],
        "Pair with an explosion passive to reduce blast damage taken by %1%.", "#fbad7c", "percent"),
    socket("companionHarness", "Companion harness", "petPassives", "petRest", [.55,.78,1.0,1.25],
        "Pair with a companion passive to shorten the pet's rest by %1 seconds.", "#80dfc8")
]

// Names supplement structured catalog flags for utility gear that has no
// elemental field. A single list covers both the preview and live rules.
var tags = {
    guardActives:/ward|guard|parry|shield|bastion|interceptor|plate/,
    healingActives:/trauma|heal|mend|mercy|vital|repair|recover|bloodlibation/,
    voidActives:/void|rift|abyss|brine|blackwake|shade|seal|soul|null/,
    ammoPassives:/magazine|reload|sparebox|bandolier|shell|ammo|cartridge|brass|cycling/,
    healPassives:/capacity|heal|mend|drain|pact|vitali|cleanlungs|secondwind|trauma|survivor|renew/,
    shieldPassives:/guard|shield|parry|ward|block|barrier|plating/,
    elementPassives:/frost|burn|ice|rune|electric|storm|fire|freeze|poison|emb|spark|status|prism|arc|explosion/,
    meleePassives:/melee|knife|blade|katana|sword|duel|trick|cleave|edge/,
    critPassives:/crit|aim|mark|sight|focus|deadeye|precision|bone/,
    goldPassives:/gold|mint|coin|rewire|liquidassets|trader|bounty/,
    blastPassives:/blast|explos|deton|grenade|rocket|shrapnel/,
    petPassives:/pet|companion|sparepart|familiar|bond/
}

function matches(condition, spec, weapon, pair, set) {
    switch (condition) {
    case undefined: return true
    case "burst": return !!spec.burst
    case "scatter": return !!spec.spread && spec.spread.length>1
    case "piercing": return !!spec.penetration && spec.penetration>1
    case "sustain": return !!spec.sustain
    case "melee": return !!spec.melee
    case "staff": return !!spec.staff
    case "ranged": return !spec.melee
    case "elemental": return !!spec.element
    case "heavy": return spec.reload>=2
    case "control": return ["freeze","stun","sticky","knockback"].includes(spec.element) || /repulse|stasis/.test(spec.id)
    case "pyro": return ["burn","explosive"].includes(spec.element)
    case "arcPair": return spec.element==="electric" && weapon?.element==="electric"
    case "paired": return pair
    case "staffHeld": return !!weapon?.staff
    case "meleeHeld": return !!weapon?.melee
    case "fullKit": return set
    default:
        return tags[condition].test((spec.id+" "+spec.title).toLowerCase())
            || condition==="elementPassives" && !!spec.element
    }
}
