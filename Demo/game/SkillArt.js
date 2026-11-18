.pragma library

var colors = {
    freeze:"#92e6ff",burn:"#ff8c42",electric:"#dfb6ff",poison:"#bcf35c",void:"#b78af1",blood:"#ff526c",
    heal:"#8ff6c1",guard:"#83d2ff",explosive:"#ffc275",wind:"#ace9d6",rune:"#e5a7ff",reload:"#ffd5a3",
    critical:"#ffcf72",stun:"#fbe59e",sticky:"#c0e46a",blind:"#c7acee",weaken:"#d9a0ee",knockback:"#ade9d8",
    cut:"#f4c5cf",coin:"#f9ca6d",summon:"#77e9de",intercept:"#a7e8fa"
}

var names = {
    freeze:"FROST",burn:"BURN",electric:"ELECTRIC",poison:"POISON",void:"VOID",blood:"DRAIN",
    heal:"HEALING",guard:"PROTECTION",explosive:"BLAST",wind:"DRAFT",rune:"RUNES",
    reload:"AMMO",critical:"CRITICAL",stun:"STUN",sticky:"STICKY",blind:"BLIND",weaken:"WEAKEN",
    knockback:"PUSH",cut:"BLADE",coin:"GOLD",summon:"COMPANION",intercept:"INTERCEPT"
}

// Kind controls shape, anchor controls where it starts. Cards with multiple
// outcomes also leave marks on the actual targets reached by the cast.
var profiles = {}
function group(ids, kind, anchor, motif) {
    for (const id of ids.split(" "))
        profiles[id]={kind:kind,anchor:anchor,motif:motif}
}
group("ward remoteward voidaegis arcshield reserveGuard riposte oathWard", "guard", "self", "shield")
group("trauma repairkit bloodbattery antidote thawCoil","heal","self","recover")
group("quickload lockfeed reversal salvo openingSalvo","reload","self","reload")
group("sidestep threadstep guststep","wind","self","evade")
group("decoy dronebeacon","summon","aim","beacon")
group("boneShatter sureStrike sharpen riskCharge overdrive","critical","self","empower")
group("critMark","critical","target","mark")
group("criticalEcho","critical","target","echo")
group("repulse draftCircle undertow","knockback","field","surge")
group("interceptor mirrormine","intercept","field","intercept")
group("immolate sunfall emberharvest emberPulse","burn","field","pyre")
group("searingmark","burn","target","brand")
group("execution","explosive","target","verdict")
group("frag","explosive","aim","throw")
group("cryogrenade","freeze","aim","throw")
group("nullgrenade gravitywell","void","aim","throw")
group("stormcall colourSpill staticLatch","electric","field","storm")
group("shock","electric","target","arc")
group("whiteout iceBloom borrowedBeat quietWater","freeze","field","crystal")
group("stasis panicbell snaretrap lateBloom","stun","field","stasis")
group("tarpit","sticky","target","snare")
group("blackWake riftWeld sealcharge breakLamp eventFold","void","field","rift")
group("flashflare","blind","field","veil")
group("mireCloud yellowNoon purge","poison","aim","cloud")
group("sporeBurst","poison","target","rupture")
group("bloodLibation","blood","field","drain")
group("bladesweep axeHook","cut","target","slice")
group("runefill","rune","self","staff")
group("runesurge fieldLesson breachOrder reclaim breaker guardPulse","explosive","field","shockwave")
group("liquidation","coin","field","mint")

var forms = {
    repelShield:["guard","self","shield"],edgeRing:["cut","field","slice"],seekMark:["critical","target","mark"],
    electrify:["electric","target","arc"],abyss:["void","field","rift"],wideSlow:["freeze","field","crystal"],
    reloadCut:["reload","self","reload"],axePrep:["cut","self","empower"],sight:["critical","self","mark"],
    cleanFrost:["heal","self","recover"],shieldWindow:["guard","self","shield"],ember:["burn","target","brand"],
    interrupt:["stun","target","stasis"],corrode:["poison","target","rupture"],burstPulse:["explosive","field","shockwave"],
    mint:["coin","field","mint"],pierceScroll:["electric","target","arc"],clearRound:["reload","self","reload"],
    stormPush:["wind","field","surge"],solarCone:["burn","field","pyre"],stormGlass:["intercept","field","intercept"],
    nightVeil:["blind","field","veil"],lunarWard:["guard","self","shield"]
}

function profile(ability) {
    const known=profiles[ability.id]
    if (known) return known
    const form=forms[ability.form]
    if (form) return {kind:form[0],anchor:form[1],motif:form[2]}
    return {kind:colors[ability.element] ? ability.element : "rune",anchor:ability.element ? "target" : "self",motif:ability.element || "empower"}
}

function footprint(enemy) {
    const effect=enemy.elements
    return [enemy.hp,enemy.barrier,Math.round(enemy.depth),enemy.attack,enemy.slow,enemy.mark,enemy.interruptIn,
        effect?.frozen,effect?.stunned,effect?.blind,effect?.weaken,effect?.burn,effect?.poison,effect?.electric,
        effect?.explosive,effect?.sticky,enemy.criticalMark].join("|")
}

function intensity(rarity) {
    return rarity==="legendary" ? 4 : rarity==="epic" ? 3 : rarity==="rare" ? 2 : 1
}

function caption(kind, power, summary, level) {
    if (summary) return summary
    return names[kind] + (level ? " "+["","I","II","III"][Math.min(3,level)] : "")
}
