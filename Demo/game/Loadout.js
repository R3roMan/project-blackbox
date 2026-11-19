.pragma library
.import "DeepGear.js" as Deep
.import "MilestoneGear.js" as Milestones
.import "CampaignGear.js" as Campaign
.import "BloodGear.js" as Blood

.import "Pets.js" as Pets
.import "Elements.js" as Elements
.import "Expansion.js" as Extra
.import "Arsenal.js" as Arsenal
.import "Defense.js" as Defense
.import "SlotEffects.js" as Sockets
.import "Meta.js" as Meta
.import "Tarot.js" as Tarot
.import "GradeGear.js" as Grades
.import "WeatherGear.js" as Weather

var weapons = {
    pistol: { id: "pistol", title: "Service pistol", category: "Weapon", rarity: "common", effect: "ballistic", capacity:7, damage:2, delay:0.25,
        reload:0.94, aim: 25, color: "#ffb66d", trace: 1.6, afterglow: 0.14,
        handling:"reload", description: "A precise single-shot sidearm with a quick reload." },
    scattergun: { id: "scattergun", title: "Scattergun", category: "Weapon", rarity: "common", effect: "spread", capacity:5, damage:1.23, delay:0.57,
        reload:1.38, spread: [[0, 0], [-0.026, -0.013], [0.026, -0.013], [-0.02, 0.018], [0.02, 0.018]],
        aim: 48, color: "#ff855d", trace: 2.2, afterglow: 0.23,
        handling:"capacity", description: "Five pellets per shell. Get close to land the whole spread." },
    rail: { id: "rail", title: "Rail rifle", category: "Weapon", rarity: "rare", effect: "beam", capacity:5, damage:6.35, delay:0.72,
        reload:1.6, aim: 19, color: "#75e4ff", trace: 5, afterglow: 0.31,
        handling:"reload", element:"stun", elementLevel:1, penetration:2, crit:.075,
        description: "An accurate, penetrating shot with level 1 Stun and higher critical chance." },
    carbine: { id: "carbine", title: "Auto carbine", category: "Weapon", rarity: "common", effect: "tracer", capacity:14, damage:1.12, delay:0.118,
        reload:.94, aim: 30, color: "#d0ff8d", trace: 2, afterglow: 0.088,
        handling:"capacity", description: "A quick mechanical cycle for close to medium range." },
    riot: { id: "riot", title: "Riot pump", category: "Weapon", rarity: "rare", effect: "spread", capacity:6, damage:1.29, delay:0.69,
        reload:1.53, aim: 55, color: "#ffc97e", trace: 2.7, afterglow: 0.21,
        spread: [[0, 0], [-.034, -.020], [-.031, .018], [.034, -.020], [.031, .018], [0, .032], [0, -.030]],
        handling:"reload", description: "Seven wide pellets per shell. The largest close-range shot pattern." },
    ion: { id: "ion", title: "Ion SMG", category: "Weapon", rarity: "rare", effect: "pulse", capacity:17, damage:1.43, delay:0.127,
        reload:1.26, aim: 27, color: "#63f1d6", trace: 2.9, afterglow: 0.105,
        handling:"capacity", element:"electric", elementLevel:1, description: "Rapid plasma pulses that jump between nearby enemies." },
    hellbore: { id: "hellbore", title: "Hellbore", category: "Weapon", rarity: "epic", effect: "spread", capacity:2, damage:2.1, delay:0.64,
        reload:1.43, aim: 59, color: "#ff677f", trace: 3.1, afterglow: 0.29,
        spread: [[0, 0], [-.027, -.018], [.027, -.018], [-.04, .012], [.04, .012], [0, .03]],
        handling:"capacity", element:"burn", elementLevel:1, signature:"closeKick",
        description: "Six incendiary pellets. Land at least three on a close target to knock it backwards." },
    arc: { id: "arc", title: "Arc repeater", category: "Weapon", rarity: "epic", effect: "burst", capacity:21, damage:2.04, delay:.54,
        reload:1.44, aim: 34, color: "#d98aff", trace: 2.6, afterglow: 0.12, burst:{count:3,interval:.072},
        handling:"reload", element:"electric", elementLevel:2, signature:"reclaimSpark",
        description: "Fires three timed Electric pulses. Breaking a barrier with one reclaims a round." },
    lance: { id: "lance", title: "Cryo lance", category: "Weapon", rarity: "epic", effect: "beam", capacity:6, damage:6.45, delay:0.55,
        reload:1.55, aim: 21, color: "#8ab4ff", trace: 5.5, afterglow: 0.26,
        handling:"reload", element:"freeze", elementLevel:2, penetration:2, signature:"frostCrush",
        description: "Piercing Frost bolts deal an extra 3.4 damage to a target frozen solid." },
    solar: { id: "solar", title: "Solar lance", category: "Weapon", rarity: "legendary", effect: "laser", capacity:0, damage:1.56, delay:0.108,
        reload:0, aim: 17, color: "#fff27a", trace: 7, afterglow: 0.13, sustain:{limit:3.2,cooldown:1.86},
        handling:"cooldown", element:"burn", elementLevel:2, penetration:3, signature:"beamFocus",
        description: "Hold a piercing gold beam. After five consecutive contacts with one target, its damage rises by 35%. Cools after 3.2 seconds of fire." },
    dread: { id: "dread", title: "Dread cannon", category: "Weapon", rarity: "legendary", effect: "rocket", capacity:3, damage:12.45, delay:0.72,
        reload:1.86, aim: 35, color: "#ff7851", trace: 5.5, afterglow: 0.34, splash: 4,
        handling:"capacity", element:"explosive", elementLevel:2, signature:"breachArmor",
        description: "A heavy launcher. Direct hits shatter barriers before dealing damage, and prime a large death blast." },
    crucible: { id: "crucible", title: "Crucible repeater", category: "Weapon", rarity: "legendary", effect: "pulse", capacity:15, damage:3.17, delay:0.192,
        reload:1.48, aim: 31, color: "#ff7ec9", trace: 4.2, afterglow: 0.155,
        handling:"reload", element:"poison", elementLevel:1, signature:"sporeSeed",
        description: "Poison rounds spread a level 1 dose to nearby enemies when they hit a target already suffering from Poison." },
    minigun: { id:"minigun", title:"Foundry minigun", category:"Weapon", rarity:"rare", effect:"tracer", capacity:44,
        damage:1.25, delay:0.091, reload:2.91, aim:36, color:"#fed18f", trace:2.8, afterglow:.10, spinup:1,
        handling:"spinup", description:"Hold fire for one second to spin up six barrels. A long belt feeds the firing burst." },
    launcher: { id:"launcher", title:"Lobber grenade launcher", category:"Weapon", rarity:"epic", effect:"grenade", capacity:5,
        damage:8.2, delay:0.82, reload:2.57, aim:45, color:"#ffad55", trace:4, afterglow:.58, blast:160,
        handling:"reload", element:"explosive", elementLevel:2, signature:"impactFuse",
        description:"Lobs a timed grenade. Its fuse burns twice as fast when aimed directly at a target. A blast primes a death explosion." },
    breacher: { id:"breacher", title:"Doorbreaker", category:"Weapon", rarity:"common", effect:"spread", capacity:4,
        damage:1.42, delay:0.53, reload:1.37, aim:43, color:"#ffdb99", trace:2.1, afterglow:.20, locked:true,
        spread:[[0,0],[-.020,.008],[.020,.008],[0,-.021]], handling:"capacity", description:"A short four-pellet breach gun with a tight, vertical pattern." },
    volt: { id:"volt", title:"Volt caster", category:"Weapon", rarity:"rare", effect:"pulse", capacity:13,
        damage:2.06, delay:0.188, reload:1.19, aim:27, color:"#8dffe4", trace:3.7, afterglow:.14, shieldDamage:2, locked:true,
        handling:"reload", element:"electric", elementLevel:1, description:"An electric arc gun that deals 2 extra damage to barriers." },
    razor: { id:"razor", title:"Razor repeater", category:"Weapon", rarity:"rare", effect:"burst", capacity:18,
        damage:1.92, delay:.58, reload:1.4, aim:37, color:"#cafdff", trace:2.6, afterglow:.13, locked:true,
        burst:{count:3,interval:.082}, handling:"capacity", element:"freeze", elementLevel:1,
        description:"Three timed Frost tracers. Track the target until the final round hits." },
    ember: { id:"ember", title:"Ember thrower", category:"Weapon", rarity:"epic", effect:"rocket", capacity:8,
        damage:4.72, delay:0.364, reload:1.66, aim:35, color:"#ff934b", trace:5, afterglow:.26, splash:1.75, locked:true,
        handling:"reload", element:"burn", elementLevel:2, signature:"flareUp",
        description:"Cinder charges apply Burn. Hitting a target that is already burning creates a stronger, wider splash." },
    harrier: { id:"harrier", title:"Harrier railgun", category:"Weapon", rarity:"epic", effect:"beam", capacity:6,
        damage:7.25, delay:0.6, reload:1.77, aim:18, color:"#c5ff88", trace:5, afterglow:.27, locked:true,
        handling:"capacity", element:"weaken", elementLevel:1, penetration:2, signature:"fullPierce", pierceRetain:1,
        description:"A Weaken beam that hits a second aligned target at full power." },
    prism: { id:"prism", title:"Prism Array", category:"Weapon", rarity:"legendary", effect:"laser", capacity:0,
        damage:1.20, delay:0.168, reload:0, aim:30, color:"#aff5ff", trace:5.2, afterglow:.19, locked:true,
        spread:[[0,-.006],[-.012,.010],[.012,.010]], handling:"cooldown", element:"freeze", elementLevel:2, penetration:3,
        sustain:{limit:3.55,cooldown:1.87}, signature:"prismLock",
        description:"Three continuous Frost beams. Overlap all three on one foe for a longer chill. Automatically cools between bursts." },
    cyclone: { id:"cyclone", title:"Cyclone rotary", category:"Weapon", rarity:"legendary", effect:"tracer", capacity:64,
        damage:1.44, delay:0.084, reload:2.62, aim:40, color:"#d69bff", trace:3.3, afterglow:.10, spinup:.86, locked:true,
        handling:"spinup", signature:"rotaryRamp", description:"A rotary gun that builds up to 26% more damage during a long burst. Takes time to change the belt." }
}

var rarities = {
    common: { label: "Common", color: "#7ebeff", chance: 71.45 },
    rare: { label: "Rare", color: "#ffa36c", chance: 21 },
    epic: { label: "Epic", color: "#d5a3ff", chance: 6 },
    legendary: { label: "Legendary", color: "#ffe47b", chance: 1.55 }
}

var activeAbilities = {
    quickload: { id: "quickload", title: "Quickload", category: "Active", rarity: "common", cooldown:9,
        description: "Refill your magazine instantly, even during a reload." },
    repulse: { id: "repulse", title: "Repulse", category: "Active", rarity: "common", cooldown:13,
        description: "Push materialised threats on this front back 285 units and interrupt their attack." },
    shock: { id: "shock", title: "Shock pulse", category: "Active", rarity: "rare", cooldown:18,
        element:"electric", elementLevel:1, description: "Release a white-violet electric pulse from the closest target." },
    ward: { id: "ward", title: "Ward", category: "Active", rarity: "rare", cooldown:21,
        description: "Raise a two-charge barrier for 3.6 seconds. Each charge absorbs one hit." },
    trauma: { id: "trauma", title: "Trauma patch", category: "Active", rarity: "epic", cooldown:24,
        description: "Recover 29 health." },
    interceptor: { id: "interceptor", title: "Interceptor", category: "Active", rarity: "common", cooldown:12, firstOfferWave: 3,
        description: "Destroy incoming bolts on the front you are looking at." },
    decoy: { id: "decoy", title: "Decoy", category: "Active", rarity: "common", cooldown:15,
        element:"blind", elementLevel:1, description: "Hold enemy attacks briefly and blind the targets on this wallpaper." },
    breaker: { id: "breaker", title: "Barrier breaker", category: "Active", rarity: "rare", cooldown:14, firstOfferWave: 5,
        description: "Shatter every enemy barrier on the front you are looking at." },
    stasis: { id: "stasis", title: "Time snare", category: "Active", rarity: "epic", cooldown:23,
        description: "Freeze movement and attacks on this front for 3 seconds." },
    overdrive: { id: "overdrive", title: "Overdrive", category: "Active", rarity: "epic", cooldown:21,
        description: "Shorten shot recovery by 32% for 6.5 seconds." },
    sunfall: { id: "sunfall", title: "Sunfall", category: "Active", rarity: "legendary", cooldown:39,
        element:"burn", elementLevel:2, description: "Burn enemies across all fronts and clear every incoming bolt." },
    reclaim: { id: "reclaim", title: "Reclaim", category: "Active", rarity: "legendary", cooldown:22,
        description: "Refill every carried gun and finish their shot recovery." },
    sealcharge: { id:"sealcharge", title:"Seal charge", category:"Active", rarity:"rare", cooldown:20, firstOfferWave:9,
        description:"Throw a charge into the Abyss to hold a Void creature back and complete 72% of its seal." },
    frag: { id:"frag", title:"Frag grenade", category:"Active", rarity:"common", cooldown:18,
        element:"explosive", elementLevel:1, description:"Throw a grenade that damages a group around your aim point after a short fuse." },
    cryogrenade: { id:"cryogrenade", title:"Cryo grenade", category:"Active", rarity:"rare", cooldown:22, locked:true,
        element:"freeze", elementLevel:1, description:"A delayed blast chills targets, slows their advance and deals light damage." },
    nullgrenade: { id:"nullgrenade", title:"Null grenade", category:"Active", rarity:"epic", cooldown:24, firstOfferWave:9, locked:true,
        element:"blind", elementLevel:2, description:"Shatter barriers and blind the blast area. Add sealing progress in the Abyss." },
    flashflare: { id:"flashflare", title:"Flash flare", category:"Active", rarity:"rare", cooldown:19, locked:true,
        element:"stun", elementLevel:1, description:"Stun enemies on this wallpaper and mark them for bonus damage on your next hit." },
    repairkit: { id:"repairkit", title:"Emergency solder", category:"Active", rarity:"epic", cooldown:24, locked:true,
        description:"Clear Poison, heal 12% of maximum health and refill the current weapon." },
    arcshield: { id:"arcshield", title:"Arc shield", category:"Active", rarity:"legendary", cooldown:30, locked:true,
        element:"electric", elementLevel:1, description:"Raise a two-charge barrier. Intercept incoming bolts here and discharge Electric damage into the nearest enemy." },
    gravitywell: { id:"gravitywell", title:"Graviton grenade", category:"Active", rarity:"legendary", cooldown:24, locked:true,
        element:"explosive", elementLevel:2, description:"Trap a group in a delayed blast and push nearby threats deeper into the field." },
    reversal: { id:"reversal", title:"Reversal pulse", category:"Active", rarity:"legendary", cooldown:32, locked:true,
        element:"weaken", elementLevel:1, description:"Reload, repel and weaken enemies nearby. Recover health in a critical state." }
}

var passives = {
    magazine: { id: "magazine", title: "Extended magazine", category: "Passive", rarity: "common",
        description: "Add 2 rounds to the magazine of any weapon." },
    reload: { id: "reload", title: "Quick ejector", category: "Passive", rarity: "common",
        description: "Shorten reloads by 0.16 seconds." },
    caliber: { id: "caliber", title: "Heavy rounds", category: "Passive", rarity: "rare",
        description: "Add 1 damage per target hit by a shot." },
    seal: { id: "seal", title: "Seal amplifier", category: "Passive", rarity: "common",
        description: "Increase sealing speed by 20% of its original rate." },
    cooling: { id: "cooling", title: "Cooling coils", category: "Passive", rarity: "rare",
        description: "Reduce all active cooldown lengths by 10% of their original values." },
    armour: { id: "armour", title: "Reinforced armour", category: "Passive", rarity: "rare",
        description: "Reduce damage taken by 12% of the original value." },
    medic: { id: "medic", title: "Field medic", category: "Passive", rarity: "epic",
        description: "Recover 8 health per rank at the start of each wave." },
    capacity: { id: "capacity", title: "Vital core", category: "Passive", rarity: "epic",
        description: "Increase maximum health by 10 while equipped." },
    cycling: { id: "cycling", title: "Fast action", category: "Passive", rarity: "common",
        description: "Shorten shot recovery by 8% of its original length." },
    exploit: { id: "exploit", title: "Counter rounds", category: "Passive", rarity: "rare",
        description: "Add 2 damage when you hit a demon during its attack wind-up." },
    fury: { id: "fury", title: "Kill switch", category: "Passive", rarity: "legendary",
        description: "Each defeated enemy takes 2 seconds off all active cooldowns." },
    plate: { id: "plate", title: "Ablative plate", category: "Passive", rarity: "rare",
        description: "Start each wave with a short barrier. Strength extends its duration." },
    flywheel: { id:"flywheel", title:"Balanced flywheel", category:"Passive", rarity:"rare",
        description:"Rotary guns spin up 17% faster per rank." },
    primer: { id:"primer", title:"Void primer", category:"Passive", rarity:"common", firstOfferWave:8,
        description:"Seals lose progress more slowly when you stop channelling." },
    sparebox: { id:"sparebox", title:"Field box", category:"Passive", rarity:"common", locked:true,
        description:"Start a wave with one extra round in every equipped gun per rank." },
    insulation: { id:"insulation", title:"Ceramic lining", category:"Passive", rarity:"rare", locked:true,
        description:"Take 9% less damage from alien bolts per rank." },
    steadyaim: { id:"steadyaim", title:"Steady rest", category:"Passive", rarity:"rare", locked:true,
        description:"Reduce pellet spread by 9% per rank." },
    booster: { id:"booster", title:"Payload booster", category:"Passive", rarity:"epic", locked:true,
        description:"Grenade blasts deal 1 extra damage per rank." },
    voidliner: { id:"voidliner", title:"Abyss lining", category:"Passive", rarity:"epic", locked:true,
        description:"Sealing is 23% faster per rank." },
    deepcell: { id:"deepcell", title:"Deep cell", category:"Passive", rarity:"epic", locked:true,
        description:"Active abilities cool down 7% faster per rank. Maximum health increases by 4 per rank." },
    hunter: { id:"hunter", title:"Barrier hunter", category:"Passive", rarity:"legendary", locked:true,
        description:"Your shots deal 1 extra damage per rank to enemies with barriers." },
    cryojacket: { id:"cryojacket", title:"Cryo jacket", category:"Passive", rarity:"rare",
        description:"Frost has a higher chance to freeze. Its Lv 2 perk extends chill." },
    cinder: { id:"cinder", title:"Cinder wick", category:"Passive", rarity:"rare",
        description:"Your Burn deals more damage per tick. Its Lv 2 perk extends the fire." },
    conductor: { id:"conductor", title:"Arc conductor", category:"Passive", rarity:"epic",
        description:"Electric jumps retain more damage. Its Lv 2 perk increases jump range." },
    chainfuse: { id:"chainfuse", title:"Chain fuse", category:"Passive", rarity:"epic",
        description:"Death blasts prime survivors and deal more damage. Lv 2 expands the blast." },
    rewire: { id:"rewire", title:"Second look", category:"Passive", rarity:"rare",
        description:"Adds one extra free reroll per run while equipped. Upgrades lower shop prices and improve Mega Gift coin drops." }
}

var kits = [
    { weapon: "pistol", active: "quickload", passive: "magazine", title: "Field kit", bonus: "Service pistol shots deal 1 extra damage." },
    { weapon: "scattergun", active: "repulse", passive: "exploit", title: "Breach kit", bonus: "Repulse pushes enemies back another 140 units." },
    { weapon: "carbine", active: "decoy", passive: "cycling", title: "Runner kit", bonus: "The Auto carbine cycles 15% faster." },
    { weapon: "rail", active: "breaker", passive: "caliber", title: "Rail kit", bonus: "The Rail rifle deals 2 extra damage to shielded enemies." },
    { weapon: "riot", active: "ward", passive: "armour", title: "Riot kit", bonus: "Ward lasts another 1.5 seconds." },
    { weapon: "ion", active: "interceptor", passive: "cooling", title: "Ion kit", bonus: "Intercepting bolts loads up to 4 rounds into your current gun." },
    { weapon: "hellbore", active: "shock", passive: "seal", title: "Hellbore kit", bonus: "Shock pulse deals another 2 damage." },
    { weapon: "arc", active: "stasis", passive: "medic", title: "Arc kit", bonus: "Time snare lasts another 1.5 seconds." },
    { weapon: "lance", active: "trauma", passive: "capacity", title: "Cryo kit", bonus: "Trauma patch restores another 15 health." },
    { weapon: "solar", active: "sunfall", passive: "fury", title: "Solar kit", bonus: "Sunfall deals another 5 damage." },
    { weapon: "dread", active: "overdrive", passive: "reload", title: "Dread kit", bonus: "Overdrive lasts another 4 seconds." },
    { weapon: "crucible", active: "reclaim", passive: "plate", title: "Crucible kit", bonus: "Reclaim also grants a two-second barrier." },
    { weapon:"minigun", active:"frag", passive:"flywheel", title:"Foundry kit", bonus:"Frag grenades deal 2 extra damage." },
    { weapon:"launcher", active:"sealcharge", passive:"primer", title:"Rift crew kit", bonus:"A Seal charge closes a Void seal outright." },
    { weapon:"breacher", active:"cryogrenade", passive:"sparebox", title:"Cold start kit", bonus:"Cryo grenades chill for another two seconds." },
    { weapon:"volt", active:"nullgrenade", passive:"insulation", title:"Null kit", bonus:"A Null grenade can close a Void seal outright." },
    { weapon:"razor", active:"flashflare", passive:"steadyaim", title:"Signal kit", bonus:"Flash flare interrupts attacks for longer." },
    { weapon:"ember", active:"repairkit", passive:"booster", title:"Forge kit", bonus:"Emergency solder restores another 12 health." },
    { weapon:"harrier", active:"arcshield", passive:"voidliner", title:"Sentinel kit", bonus:"Arc shield has a third barrier charge." },
    { weapon:"prism", active:"gravitywell", passive:"deepcell", title:"Prism kit", bonus:"Graviton grenades have a wider blast radius." },
    { weapon:"cyclone", active:"reversal", passive:"hunter", title:"Cyclone kit", bonus:"Reversal restores more health and spins up your rotary gun." },
    { key:"iceCircuit", weapon:"lance", active:"cryogrenade", passive:"cryojacket", title:"Ice circuit", bonus:"Frost has another 6% chance to freeze." },
    { key:"hotChamber", weapon:"solar", active:"sunfall", passive:"cinder", title:"Hot chamber", bonus:"Burn ticks deal another 0.45 damage." },
    { key:"resonance", weapon:"ion", active:"shock", passive:"conductor", title:"Resonance kit", bonus:"Electric arcs can jump to one more target." },
    { key:"demolition", weapon:"dread", active:"frag", passive:"chainfuse", title:"Demolition kit", bonus:"Death blasts reach 12% farther." },
    { key:"quartermaster", weapon:"pistol", active:"quickload", passive:"rewire", title:"Quartermaster kit", bonus:"Quickload also clears shot recovery." }
]

Object.assign(weapons, Extra.weapons, Arsenal.weapons, Defense.weapons, Deep.weapons, Milestones.weapons,Campaign.weapons,Blood.weapons,Grades.weapons,Weather.weapons)
Object.assign(activeAbilities, Extra.actives, Arsenal.actives, Defense.actives, Deep.actives, Milestones.actives,Campaign.actives,Blood.actives,Grades.actives,Weather.actives)
Object.assign(passives, Extra.passives, Arsenal.passives, Defense.passives, Deep.passives, Milestones.passives,Campaign.passives,Blood.passives,Grades.passives,Weather.passives)
kits = kits.concat(Extra.kits, Arsenal.kits, Defense.kits, Deep.kits, Milestones.kits,Campaign.kits,Blood.kits,Grades.kits,Weather.kits, [
    { key:"starSet", weapon:"starDestroyer", active:"bloodbattery", passive:"sparebox", title:"Starlight kit",
        bonus:"Star Destroyer charges 25% faster while Infinite Ammo is active." }
])

weapons.starDestroyer = {
    id:"starDestroyer", title:"Star Destroyer", category:"Weapon", rarity:"legendary", effect:"laser",
    capacity:5, damage:17, delay:.38, reload:1.94, aim:35, color:"#ffe68c", trace:13, afterglow:.48,
    spinup:1.14, chargeEachShot:true, handling:"spinup", penetration:4, firstOfferWave:18, signature:"starBlast",
    description:"Charge a piercing 17-damage golden beam. Its kills explode at level 1, 2 or 3 as you upgrade the weapon."
}
weapons.starDestroyerPlus = Object.assign({}, weapons.starDestroyer, {
    id:"starDestroyerPlus", title:"Star Destroyer+", capacity:1, damage:100, trace:18, afterglow:.62,
    spinup:.36, penetration:12, debugOnly:true, description:"A fast-charging, fully penetrating debug beam with infinite ammunition."
})
for (const weapon of Object.values(weapons)) {
    if (weapon.capacity > 0 && !weapon.debugOnly)
        weapon.capacity += Math.max(1,Math.round(weapon.capacity*.12))
}

var inventoryDestination = -2
var inventoryLimit = 10
var startingInventorySize = 5
var limits = { weapon: 2, active: 2, passive: 8 }
var groupLabels = { weapon: "Weapon", active: "Active", passive: "Passive" }
var catalogs = { weapon: weapons, active: activeAbilities, passive: passives }
var starterPool = Object.values(weapons).filter(function(item) {
    return item.rarity !== "legendary" && !item.debugOnly && (!item.firstOfferWave || item.firstOfferWave <= 1)
})
var primaryKits = buildPrimaryKits()
kits = kits.concat(primaryKits.filter(function(kit) { return kit.generated }))
var unlockPrices = { weapon: [0, 440], active: [0, 390], passive: [0, 0, 0, 0, 565, 565, 565, 565] }
var slotPowers = {
    weapon: [
        { id: "ballistics", title: "Hardened chamber", stat: "damage", levels: [.45, .64, .82, 1], color:"#ffa46d",
            description: "Adds %1 damage per shot to this weapon slot." },
        { id: "stabilizer", title: "Stabilizer", stat: "recovery", levels: [.93,.91,.89,.87], format: "reduction", color:"#69dfed",
            description: "Shortens shot recovery in this weapon slot by %1%." },
        { id: "feeder", title: "Magazine feeder", stat: "ammo", levels: [1,2,3,4], color:"#edcf73",
            description: "Adds %1 rounds to the magazine in this weapon slot." }
    ],
    active: [
        { id: "relay", title: "Cooling relay", stat: "cooldown", levels: [.91,.88,.85,.82], format: "reduction", color:"#84a7ff",
            description: "Shortens cooldowns for this active slot by %1%." },
        { id: "coupler", title: "Power coupler", stat: "strength", levels: [.35,.50,.65,.80], color:"#cfa2ff",
            description: "Increases the effective level of this slot's active by %1." }
    ],
    passive: [
        { id: "amplifier", title: "Passive amplifier", stat: "strength", levels: [1, 2, 3, 4], color:"#ec9cd6",
            description: "Increases the effective level of this slot's passive by %1." },
        { id: "padding", title: "Lined socket", stat: "armour", levels: [.042,.054,.066,.078], format: "percent", color:"#82ecad",
            description: "Reduces damage taken by %1% while this passive slot is occupied." }
    ]
}
for (const group of Object.keys(slotPowers))
    slotPowers[group] = slotPowers[group].concat({weapon:Sockets.weapon,active:Sockets.active,passive:Sockets.passive}[group])

function usesAmmo(spec) {
    return !spec.melee && !spec.sustain && !spec.throwing && !spec.staff && !spec.stab
}

function hasGunSights(spec) {
    return !spec.melee && !spec.throwing && !spec.staff && !spec.stab
}

function makeItem(id) {
    const spec = weapons[id]
    if (spec)
        return { id:id, level:0, ammo:spec.capacity, reload:0, reloadLength:spec.reload, recovery:0, cycle:spec.delay, spin:0,
            prep:0, prepLength:0, primed:false, chargedStrike:false, heat:0, cool:0, firing:false, hold:0,
            sequence:0, lastTarget:0, focus:0, streak:0, combo:0, comboUntil:0, charge:0,
            burstLeft:0, burstWait:0, burstRefunded:false, critLoaded:0 }
    return { id: id, level: 0 }
}

function starter() {
    return {
        weapon: [{ item: makeItem("pistol"), power: "", powerLevel: 0 }],
        active: [{ item: null, power: "", powerLevel: 0 }],
        passive: Array.from({ length:4 }, function() { return { item:null, power:"", powerLevel:0 } })
    }
}

function draftStarters(unlocks, rolls, previous) {
    const commons = []
    const rares = []
    const epics = []
    for (let i = 0; i < starterPool.length; ++i) {
        const item = starterPool[i]
        if (previous.includes(item.id) || item.locked && !unlocks.includes(item.id))
            continue
        const options = item.rarity === "common" ? commons : item.rarity === "rare" ? rares : epics
        options.push(item.id)
    }
    const first = commons.splice(Math.floor(rolls[0]*commons.length),1)[0]
    const special = rolls[2] < .15 && epics.length ? epics : rares
    return [first,commons[Math.floor(rolls[1]*commons.length)],special[Math.floor(rolls[3]*special.length)]]
}

function current(run) {
    return run.slots.weapon[run.selectedWeapon].item
}

function groupOf(card) {
    return card.category.toLowerCase()
}

function slotPowerAt(spec, level) {
    if (!spec)
        return {}
    const value = spec.levels[level]
    const displayed = spec.format === "reduction" ? Number(((1 - value) * 100).toFixed(1))
        : ["percent","points"].includes(spec.format) ? Number((value * 100).toFixed(1)) : value
    return { id: spec.id, title: spec.title, level: level, color:spec.color, condition:spec.condition,
        description: spec.description.replace("%1", displayed),
        [spec.stat]: value }
}

function slotPower(group, slot, level) {
    if (!slot || !slot.power)
        return {}
    const spec = slotPowers[group].find(function(entry) { return entry.id === slot.power })
    return slotPowerAt(spec, level === undefined ? slot.powerLevel || 0 : level)
}

function socketEffect(run, group, slot) {
    if (!slot?.power || !slot.item)
        return {}
    const power=slotPower(group,slot)
    const item=catalogs[group][slot.item.id]
    const weapon=weapons[current(run)?.id]
    const pair=power.condition==="paired" && run.slots.active.filter(function(cell) {return !!cell.item}).length>1
    const set=power.condition==="fullKit" && completeKit(run,kitFor(group,item.id))
    return Sockets.matches(power.condition,item,weapon,pair,set) ? power : {}
}

function weaponSocket(run, slot) {
    return socketEffect(run,"weapon",slot || run.slots.weapon[run.selectedWeapon])
}

function passiveSockets(run, stat, cap) {
    const total=run.slots.passive.reduce(function(value,slot) {
        if (!slot.power) return value
        return value+(socketEffect(run,"passive",slot)[stat] || 0)
    },0)
    return Math.min(cap,total)
}

function findSlot(run, group, id) {
    return run.slots[group].findIndex(function(slot) { return slot.item && slot.item.id === id })
}

function kitFor(group, id) {
    return primaryKits.find(function(kit) { return kit[group] === id })
}

function kitDescription(group, id, description) {
    const kit = kitFor(group,id)
    return kit ? description + "\n" + kit.title : description
}

function buildPrimaryKits() {
    const taken = { weapon:{}, active:{}, passive:{} }
    const result = []
    function add(kit) {
        for (const key of Object.keys(taken))
            taken[key][kit[key]] = true
        result.push(kit)
    }
    for (const kit of kits) {
        if (Object.keys(taken).every(function(key) { return !taken[key][kit[key]] }))
            add(kit)
    }
    const unassigned = function(group) {
        return Object.values(catalogs[group]).filter(function(item) {
            return !item.debugOnly && !taken[group][item.id]
        }).sort(function(a, b) {
            return Object.keys(rarities).indexOf(a.rarity) - Object.keys(rarities).indexOf(b.rarity)
        })
    }
    const actives = unassigned("active")
    const passives = unassigned("passive")
    const survivors = unassigned("weapon")
    for (let index = 0; index < survivors.length; index += 1) {
        const weapon = survivors[index]
        const active = actives[index]
        const passive = passives[index]
        if (!active || !passive)
            continue
        const bonusOptions = [
            { stat:"damage", value:.057, scope:weapon.id, bonus:weapon.title + " deals another 5.7% damage." },
            { stat:"recovery", value:.067, scope:weapon.id, bonus:weapon.title + " recovers from attacks another 6.7% sooner." },
            { stat:"crit", value:.038, scope:weapon.id, bonus:weapon.title + " gains 3.8 percentage points of critical chance." },
            { stat:"active", value:.09, scope:active.id, bonus:active.title + " recharges another 9% sooner." },
            { stat:"critPower", value:.18, scope:weapon.id, bonus:weapon.title + " critical hits add another ×0.18 to their multiplier." }
        ]
        add(Object.assign({ key:"fieldKit-" + weapon.id, title:weapon.title + " kit", weapon:weapon.id,
            active:active.id, passive:passive.id, generated:true }, bonusOptions[index % bonusOptions.length]))
    }
    return result
}

function kitBonus(run, stat, id) {
    return primaryKits.reduce(function(total, kit) {
        return total + (kit.stat === stat && (!kit.scope || kit.scope === id) && completeKit(run,kit) ? kit.value : 0)
    }, 0)
}

function kitMembers(run,kit) {
    return ["weapon","passive","active"].map(function(group) {
        const item=catalogs[group][kit[group]]
        return {id:item.id,group:group,title:item.title,owned:!!ownedItem(run,group,item.id)}
    })
}

function kitOwnership(run,group,id) {
    if (!run) return ""
    return kits.filter(kit=>kit[group]===id).map(function(kit) {
        const other=kitMembers(run,kit).filter(part=>part.group!==group && part.owned)
        return other.length ? kit.title+" · You own "+other.map(part=>part.title).join(" + ") : ""
    }).filter(Boolean).join("\n")
}

function completeKit(run, kit) {
    return !!kit && Object.keys(limits).every(function(group) { return findSlot(run, group, kit[group]) >= 0 })
}

function hasKit(run, id) {
    return completeKit(run, kits.find(function(kit) { return (kit.key || kit.weapon) === id }))
}

var secondPerks = {
    magazine:{ reload:.065, text:"Reload time −6.5%" }, reload:{ ammo:1, text:"Magazine +1" },
    caliber:{ cycle:.055, text:"Shot recovery −5.5%" }, seal:{ health:4, text:"Maximum health +4" },
    cooling:{ health:5, text:"Maximum health +5" }, armour:{ heal:3, text:"Heal 3 at wave start" },
    medic:{ armor:.045, text:"Damage taken −4.5%" }, capacity:{ heal:4, text:"Heal 4 at wave start" },
    cycling:{ reload:.065, text:"Reload time −6.5%" }, exploit:{ cycle:.055, text:"Shot recovery −5.5%" },
    fury:{ cooldown:.06, text:"Active cooldowns −6%" }, plate:{ armor:.045, text:"Damage taken −4.5%" },
    flywheel:{ ammo:2, text:"Magazine +2" }, primer:{ health:4, text:"Maximum health +4" },
    sparebox:{ reload:.065, text:"Reload time −6.5%" }, insulation:{ armor:.04, text:"Damage taken −4%" },
    steadyaim:{ cycle:.06, text:"Shot recovery −6%" }, booster:{ blastRadius:.08, text:"Blast radius +8%" },
    voidliner:{ heal:4, text:"Heal 4 at wave start" }, deepcell:{ armor:.04, text:"Damage taken −4%" },
    hunter:{ cycle:.07, text:"Shot recovery −7%" }, cryojacket:{ frostDuration:1.2, text:"Frost duration +1.2s" },
    cinder:{ burnDuration:1.35, text:"Burn duration +1.35s" }, conductor:{ arcRadius:42, text:"Electric jump range +42" },
    chainfuse:{ blastRadius:.11, text:"Death blast radius +11%" }, rewire:{ coins:30, text:"Mega coin gifts +30 gold" }
}
Object.assign(secondPerks, Extra.perks, Arsenal.perks, Defense.perks, Deep.perks, Milestones.perks,Campaign.perks,Blood.perks,Grades.perks,Weather.perks)

function passiveRank(run, id) {
    const index = findSlot(run, "passive", id)
    if (index < 0)
        return 0
    const slot = run.slots.passive[index]
    const level = slot.item.level
    return 1 + (level >= 1 ? 1 : 0) + (level >= 3 ? 2 : 0) + (slotPower("passive", slot).strength || 0)
}

function environmentMatches(run,phase) {
    if (!phase) return true
    if (!run) return false
    if (phase==="night") return Tarot.dark(run)
    if (phase==="twilight") return run.skyPhase==="sunrise" || run.skyPhase==="sunset"
    if (phase==="weather") return !!Tarot.weather(run)
    if (phase==="clear") return !Tarot.weather(run)
    return run.skyPhase===phase
}

var environmentNames={night:"Night or Blood Moon",twilight:"sunrise or sunset",weather:"an active weather overlay",
    clear:"clear weather",daytime:"daylight"}

function affinity(run,spec) {
    return spec.affinity && environmentMatches(run,spec.affinity) ? 1+spec.affinityBonus : 1
}

function perk(run, stat) {
    const polish=Meta.benefits(run).passive
    let total=0
    for (const slot of run.slots.passive) {
        const item=slot.item
        if (!item) continue
        const basic=Grades.basic[item.id] || Weather.conditional[item.id]
        if (basic && basic[stat] && environmentMatches(run,basic.when))
            total+=basic[stat]*(1+(item.level>=1 ? .35 : 0)+(item.level>=3 ? .55 : 0))
        const extra=secondPerks[item.id]
        if (item.level>=2 && extra && extra[stat] && environmentMatches(run,extra.when))
            total+=extra[stat]*polish
    }
    return total
}

function weaponStats(item) {
    const spec = weapons[item.id]
    const level = item.level || 0
    const handling = level >= 3 ? spec.handling : ""
    const second = level >= 2 && !spec.element && !spec.knockback && !spec.staff && !["starBlast","jesterDeck"].includes(spec.signature) ? .82 : 1
    return {
        damage:spec.damage*(spec.effect === "spread" ? 1.08 : 1)*(level>=3 ? 2.10 : level>=1 ? 1.40 : 1), delay:spec.delay * second,
        capacity:spec.capacity + (spec.capacity ? Math.ceil(spec.capacity*level*.10) : 0)
            + (handling === "capacity" ? Math.max(1, Math.round(spec.capacity * .26)) : 0),
        reload:spec.reload * (handling === "reload" ? .72 : 1),
        spinup:spec.spinup ? spec.spinup * (handling === "spinup" ? .72 : 1) : 0,
        heat:spec.sustain ? spec.sustain.limit : 0,
        cooling:spec.sustain ? spec.sustain.cooldown * (handling === "cooldown" ? .72 : 1) : 0,
        deathLevel:spec.signature === "starBlast" ? Math.min(3, 1 + Math.max(0, level - 1)) : 0,
        knockback:spec.knockback ? Math.min(3,spec.knockback+Number(level>=2)) : 0,
        pushBonus:spec.knockback === 3 && level >= 2 ? 55 : 0,
        element:spec.element || "", elementLevel:Math.min(3, (spec.elementLevel || 0) + (level >= 2 && (spec.element || spec.staff) ? 1 : 0)),
        chargeCost:spec.staff ? spec.staff.cost - Number(handling === "staffCharge") : 0
    }
}

function weaponLevel(run, item) {
    return run.maxGearTime > 0 ? 3 : item.level
}

function effectiveWeaponStats(run, item) {
    const stats=weaponStats(run.maxGearTime > 0 ? Object.assign({},item,{level:3}) : item)
    stats.damage*=Meta.benefits(run).weapon*affinity(run,weapons[item.id])
    if (run.covenant && run.covenant.tarot) {
        const omen=Tarot.stats(run)
        stats.damage*=Tarot.weaponFactor(run,omen.hurtDamage || omen.direDamage ? maxHealth(run) : 1)
    }
    return stats
}

function covenantOffer(run,group,qualities,salt) {
    const pool=Object.values(catalogs[group]).filter(function(item) {
        return qualities.includes(item.rarity) && !item.debugOnly && (!item.locked || run.unlocks.includes(item.id))
    })
    const index=(Math.imul(run.seed^salt,0x85ebca6b)>>>0)%Math.max(1,pool.length)
    return pool[index]?.id || ""
}

function loadRating(run) {
    const tiers={common:1,rare:1.28,epic:1.62,legendary:2.10}
    const totals={items:0,upgrades:0,burden:0}
    for (const group of Object.keys(catalogs)) {
        const slots=run.slots[group]
        for (const slot of slots) {
            if (!slot.item) continue
            const item=slot.item
            totals.items++
            totals.upgrades+=item.level+(slot.power ? slot.powerLevel+1 : 0)
            totals.burden+=(tiers[catalogs[group][item.id].rarity] || 1)+item.level*.34+(slot.power ? .24+slot.powerLevel*.17 : 0)
        }
    }
    totals.items+=run.inventory.filter(Boolean).length
    return totals
}

function activeStats(item, bonus) {
    const spec = activeAbilities[item.id]
    const level = item.level || 0
    return {
        cooldown:spec.cooldown * (level >= 1 ? .78 : 1) * (level >= 3 ? .78 : 1),
        strength:(bonus || 0) + (spec.element ? (level >= 3 ? 2 : 0) : (level >= 3 ? 3 : level >= 2 ? 2 : 0)),
        element:spec.element || "", elementLevel:Math.min(3, (spec.elementLevel || 0) + (spec.element && level >= 2 ? 1 : 0))
    }
}

function upgradeText(card, level) {
    if (!level)
        return ""
    if (card.category === "Weapon") {
        if (level === 1)
            return "Damage +40%"+(card.capacity ? " and magazine +10%" : "")
        if (level === 2)
            return card.signature === "starBlast" ? "Kill explosion rises to Lv 2"
                : card.staff && !card.element || card.signature === "jesterDeck" ? "Random status level +1"
                : card.knockback ? card.knockback === 3 ? "Knockback range +55" : "Knockback level +1"
                : card.element ? Elements.kinds[card.element].title + " level +1" : "Attack recovery −18%"
        if (card.signature === "starBlast")
            return "Damage +50%, kill explosion Lv 3 and charge time −28%"
        if (card.handling === "cooldown")
            return "Damage +50% and overheat cooldown −28%"
        if (card.handling === "staffCharge")
            return "Damage +50% and one fewer attack per spell"
        return "Damage +50% and "+(card.handling === "capacity" ? "magazine +26%" : card.handling === "spinup" ? "spin-up time −28%"
            : card.melee ? "trick time −28%" : card.throwing ? "draw time −28%" : card.stab ? "thrust recovery −28%" : "reload time −28%")
    }
    if (card.category === "Active") {
        if (level === 1)
            return "Cooldown −22%"
        if (level === 3)
            return "Cooldown −22% and stronger effect"
        return card.element ? Elements.kinds[card.element].title + " level +1" : "Effect strength +2 ranks"
    }
    if (level === 2)
        return secondPerks[card.id].text
    return card.id === "rewire" ? level === 3 ? "Shop price −10%" : "Shop price −5%"
        : level === 3 ? "Passive strength +2 ranks" : "Passive strength +1 rank"
}

function slotUpgradeColor(group, slot) {
    if (!slot)
        return "transparent"
    const power = slotPower(group, slot)
    if (power.color)
        return power.color
    const item = slot.item
    if (!item || !item.level)
        return "transparent"
    const card = catalogs[group][item.id]
    if (item.level === 2 && card.element)
        return Elements.kinds[card.element].color
    if (group === "weapon")
        return item.level === 1 || card.handling === "spinup" ? "#ffa46d"
            : item.level === 3 && card.handling === "capacity" ? "#edcf73" : "#69dfed"
    if (group === "active")
        return item.level === 1 || item.level === 3 && !card.element ? "#84a7ff" : "#cfa2ff"
    return rarities[card.rarity].color
}

var startingHealth = 200

function maxHealth(run) {
    const base = (run.debugBuild === "star" ? 9999 : startingHealth) + Meta.benefits(run).health + (run.boons ? run.boons.health : 0) + passiveRank(run, "capacity") * 10
        + passiveRank(run, "deepcell") * 3 + perk(run, "health") + passiveSockets(run,"health",18)
    return Math.max(1, Math.ceil(base * Elements.healthFactor(run.elements || {}) * (run.fearCut ? .5 : 1)))
}

function magazine(run, index) {
    const slot = run.slots.weapon[index === undefined ? run.selectedWeapon : index]
    if (!usesAmmo(weapons[slot.item.id]))
        return 0
    return effectiveWeaponStats(run,slot.item).capacity + passiveRank(run, "magazine") * 2 + passiveRank(run, "sparebox") + perk(run, "ammo")
        + (weaponSocket(run, slot).ammo || 0) + passiveSockets(run,"ammo",6) + run.bonusAmmo
}

function clampStats(run) {
    run.health = Math.min(run.health, maxHealth(run))
    run.slots.weapon.forEach(function(slot, index) {
        if (slot.item)
            slot.item.ammo = Math.min(slot.item.ammo, magazine(run, index))
    })
}

function bagIndex(run, group, id) {
    return run.inventory.findIndex(function(entry) { return entry && entry.group === group && entry.item.id === id })
}

function ownedItem(run, group, id) {
    const equipped = findSlot(run, group, id)
    if (equipped >= 0)
        return run.slots[group][equipped].item
    const stored = bagIndex(run, group, id)
    return stored >= 0 ? run.inventory[stored].item : null
}

function upgradeTargets(run) {
    const choices = []
    for (const group of Object.keys(catalogs)) {
        run.slots[group].forEach(function(slot,index) {
            if (slot.item && slot.item.level<3)
                choices.push({index:index,group:group,item:slot.item,place:groupLabels[group]+" "+(index+1)})
        })
    }
    run.inventory.forEach(function(entry,index) {
        if (entry && entry.item.level<3)
            choices.push({group:entry.group,item:entry.item,place:"Inventory "+(index+1)})
    })
    return choices.map(function(choice) {
        const spec=catalogs[choice.group][choice.item.id]
        return {key:choice.group+"/"+spec.id,item:choice.item,
            title:spec.title+" · "+choice.place+" · Lv "+choice.item.level+" → "+(choice.item.level+1)}
    })
}

function canStore(run) {
    return run.inventory.includes(null)
}

function canOffer(run, card) {
    if (card.debugOnly || card.locked && !run.unlocks.includes(card.id)
        || !run.debugUnlockAll && run.wave < (card.firstOfferWave || 0))
        return false
    const owned = ownedItem(run, groupOf(card), card.id)
    return !owned || owned.level < 3
}

function defaultSlot(run, card) {
    const group = groupOf(card)
    const matching = findSlot(run, group, card.id)
    if (matching >= 0)
        return matching
    if (bagIndex(run, group, card.id) >= 0)
        return inventoryDestination
    return run.slots[group].findIndex(function(slot) { return !slot.item })
}

function describeOffer(run, card) {
    const group = groupOf(card)
    if (!catalogs[group])
        return card
    const owned = ownedItem(run, group, card.id)
    const kit = kitFor(group, card.id)
    const level = owned ? owned.level + 1 : 0
    const place = bagIndex(run, group, card.id) >= 0 ? "In inventory · " : ""
    return Object.assign({}, card, { hint:place + (kit ? kit.title : ""), upgradeLevel:level, upgradeEffect:upgradeText(card, level), storedUpgrade:!!owned && bagIndex(run,group,card.id)>=0 })
}

function equip(run, card, preferred) {
    const group = groupOf(card)
    const owned = ownedItem(run, group, card.id)
    if (owned) {
        if (owned.level >= 3)
            return false
        owned.level += 1
    } else if (preferred === inventoryDestination) {
        const space = run.inventory.indexOf(null)
        if (space < 0)
            return false
        run.inventory[space] = { group:group, item:makeItem(card.id) }
    } else {
        const index = preferred === undefined || preferred < 0 ? defaultSlot(run, card) : preferred
        const slot = run.slots[group][index]
        if (!slot)
            return false
        const space = run.inventory.indexOf(null)
        if (slot.item && space >= 0)
            run.inventory[space] = {group:group,item:slot.item}
        slot.item = makeItem(card.id)
    }
    clampStats(run)
    return true
}

function swapInventory(run, cell, group, index) {
    const slot = run.slots[group] && run.slots[group][index]
    const stored = run.inventory[cell]
    if (!slot || !Number.isInteger(cell) || cell < 0 || cell >= run.inventory.length
        || stored && stored.group !== group || !stored && !slot.item)
        return false
    if (!stored && group === "weapon" && !run.slots.weapon.some(function(other) { return other !== slot && other.item }))
        return false
    const equipped = slot.item
    slot.item = stored ? stored.item : null
    run.inventory[cell] = equipped ? { group:group, item:equipped } : null
    if (group === "weapon" && equipped) {
        equipped.reload = 0
        equipped.spin = 0
        if (!slot.item && run.selectedWeapon === index)
            run.selectedWeapon = run.slots.weapon.findIndex(function(other) { return !!other.item })
    }
    clampStats(run)
    return true
}

function swap(run, group, from, to) {
    const slots = run.slots[group]
    if (!slots || !slots[from] || !slots[to] || from === to || (!slots[from].item && !slots[to].item))
        return false
    const next = slots[to].item
    slots[to].item = slots[from].item
    slots[from].item = next
    if (group === "weapon") {
        if (run.selectedWeapon === from)
            run.selectedWeapon = to
        else if (run.selectedWeapon === to)
            run.selectedWeapon = from
    }
    clampStats(run)
    return true
}

function practiceBuild(run, random) {
    const stage = Math.max(1, Math.floor(run.startAt / 10))
    const tiers = ["common", "rare", "epic", "legendary"].slice(0, Math.min(4, stage + 1))
    const pick = function(choices) { return choices[Math.floor(random() * choices.length)] }
    const makeSlot = function(id) {
        const item = id ? makeItem(id) : null
        if (item)
            item.level = Math.min(3, Math.max(0, stage - 1))
        return { item:item, power:"", powerLevel:0 }
    }
    const kit = pick(kits.filter(function(entry) {
        return Object.keys(catalogs).every(function(group) {
            const card = catalogs[group][entry[group]]
            return tiers.includes(card.rarity) && (card.firstOfferWave || 0) <= run.startAt
        })
    }))
    const fill = function(group, count) {
        const choices = Object.values(catalogs[group]).filter(function(card) {
            return !card.debugOnly && tiers.includes(card.rarity) && card.id !== kit[group]
                && (card.firstOfferWave || 0) <= run.startAt
        })
        const slots = [makeSlot(kit[group])]
        while (slots.length < count) {
            const choice = pick(choices)
            choices.splice(choices.indexOf(choice), 1)
            slots.push(makeSlot(choice.id))
        }
        return slots
    }
    run.slots.weapon = fill("weapon", stage >= 2 ? 2 : 1)
    run.slots.active = fill("active", stage >= 2 ? 2 : 1)
    run.slots.passive = fill("passive", Math.min(limits.passive, 4 + Math.floor(stage / 2)))
    run.boons = { health:stage * 25, damage:stage * .075, speed:Math.min(.5, stage * .035) }
    run.health = maxHealth(run)
}

function equipmentStock(run) {
    const cards = []
    for (const group of Object.keys(limits)) {
        const slots = run.slots[group]
        if (slots.length < limits[group])
            cards.push({ id:"unlock-" + group, action:"unlock", group:group, index:slots.length,
                title:"Unlock " + group + " slot " + (slots.length + 1), cost:unlockPrices[group][slots.length],
                description:"Adds one empty " + group + " slot for this run." })
        slots.forEach(function(slot, index) {
            if (slot.item && slot.item.level < 3) {
                const id = slot.item.id
                const item = catalogs[group][id]
                if (item.debugOnly)
                    return
                cards.push({ id:"upgrade-" + group + "-" + index, action:"upgrade", group:group, gearId:id,index:index,level:slot.item.level+1,
                    title:item.title + " · Lv " + (slot.item.level + 1), cost:170 + 100 * slot.item.level,
                    rarity:item.rarity, description:upgradeText(item, slot.item.level + 1) })
            }
            const current = slotPower(group, slot)
            if (current.id && current.level < 3) {
                const next = slotPower(group, slot, current.level + 1)
                cards.push({ id:"power-upgrade-" + group + "-" + index, action:"power-upgrade", group:group, index:index,
                    powerId:current.id, level:next.level, rarity:"rare",
                    title:next.title + " · Lv " + next.level, cost:220 + 110 * current.level,
                    description:groupLabels[group] + " slot " + (index + 1) + ". " + next.description })
            }
        })
    }
    return cards
}

function slotOffer(run, random) {
    const slots=[]
    for (const group of Object.keys(limits))
        for (let index=0;index<run.slots[group].length;index++)
            slots.push({group:group,index:index,slot:run.slots[group][index]})
    const occupied=slots.filter(function(item) {return item.slot.item})
    const choices=random()<.80 && occupied.length ? occupied : slots
    const {group,index}=choices[Math.floor(random()*choices.length)]
    const previous = slotPower(group, run.slots[group][index])
    const options = slotPowers[group].filter(function(effect) { return effect.id !== previous.id })
    const compatible=options.filter(function(effect) {
        const slot=run.slots[group][index]
        return socketEffect(run,group,{item:slot.item,power:effect.id,powerLevel:0}).id
    })
    const pool=random()<.72 && compatible.length ? compatible : options
    const power = slotPowerAt(pool[Math.floor(random() * pool.length)], 0)
    return { id:"slot-power", action:"power", group:group, index:index, powerId:power.id, rarity:"rare",
        title:power.title, cost:395, color:power.color, level:0,
        description:groupLabels[group] + " slot " + (index + 1) + ". " + power.description
            + (previous.title ? " Replaces " + previous.title + " · Lv " + previous.level + "." : " This slot has no ability yet.") }
}

var supplies = [
    { id:"restore", action:"supply", title:"Trauma supplies", cost:290, description:"Restore up to 40 health." },
    { id:"cartridges", action:"supply", title:"Reserve case", cost:230, description:"Adds four rounds to both magazines next wave." },
    { id:"fieldWard", action:"supply", title:"Barrier cells", cost:315, description:"Start the next wave with a two-charge barrier for ten seconds." },
    { id:"heatSink", action:"supply", title:"Coolant cartridge", cost:265, description:"Refresh all equipped active cooldowns." },
    { id:"powerCell", action:"supply", title:"Overcharged cells", cost:350, description:"Deal two extra damage per shot for the first 18 seconds of the next wave." },
    { id:"spareMed", action:"supply", title:"Field dressing bundle", cost:420, description:"Restore up to 65 health." },
    { id:"sealOil", action:"supply", title:"Abyss salve", cost:325, description:"Begin the next wave with 20% of the Abyss seal already drawn." },
    { id:"corners", action:"supply", title:"Corner plates", cost:370, description:"Start the next wave with a 15-second barrier." }
]

function repeatChance(level) {
    return .055 + (level || 0)*.04
}

function pickRarityItem(run, pool, roll) {
    if (!pool.length)
        return null
    const owned = pool.filter(function(item) { return ownedItem(run,groupOf(item),item.id) })
    const chance = owned.length ? repeatChance(run.repeatRank) : 0
    if (roll < chance)
        return owned[Math.floor(roll/chance*owned.length)]
    return pool[Math.floor((roll-chance)/(1-chance)*pool.length)]
}

var shopUpgrades = [
    {id:"health",title:"Reserve vitality",amount:24,perk:"+24 maximum health"},
    {id:"damage",title:"Workshop calibration",amount:.085,perk:"+8.5% outgoing damage"},
    {id:"speed",title:"Bearing grease",amount:.12,perk:"+12% turn speed"}
]

function shopOdds(rank) {
    return { premium:.24+.08*rank, legendary:.045+.028*rank }
}

function counterOffer(run) {
    const capacity=run.shopCapacity || 5
    return capacity>=8 ? null : {id:"expand-counter",title:"Unlock listing "+(capacity+1),action:"expand-shop",
        rarity:"rare",index:capacity,cost:shopPrice(run,475+(capacity-5)*180),
        description:"Stock this space now and keep it for future boss shops in this run."}
}

function shopPrice(run, price) {
    return Math.round(price*(1-.05*Math.max(0,passiveRank(run,"rewire")-1)-Tarot.value(run,"shop")))
}

function replacement(run, card) {
    return card?.action==="power" ? slotPower(card.group,run.slots[card.group]?.[card.index]) : {}
}

function replacementKey(power) {
    return power.id ? power.id+":"+power.level : ""
}

function shopCategory(action) {
    return ({shop:"Shop guide",power:"Slot effect","power-upgrade":"Slot rank",upgrade:"Equipment rank",gear:"Equipment",
        "item-upgrade":"Equipment upgrade","shop-quality":"Stock quality","expand-shop":"Counter space",unlock:"Equipment slot",inventory:"Storage",
        mystery:"Sealed cache","repeat-upgrade":"Stock affinity",pet:"Companion",
        "barrier-core":"Protection","shield-upgrade":"Protection",scramble:"Rebuild","shop-stat":"Run stat"})[action] || "Supplies"
}

function shopEntryId(offer) {
    if (offer.action==="power" || offer.action==="power-upgrade")
        return offer.powerId || "slot-work"
    if (offer.action==="upgrade")
        return "equipment-rank"
    if (offer.action==="shop-stat")
        return "counter-"+offer.stat
    return offer.id
}

function shopEntries() {
    const entries=[
        {id:"counter",title:"The bone counter",action:"shop",description:"Visit the counter after a boss. Buy, skip or refresh unpurchased listings. Sold listings keep their place. You start with five and can buy another three in sequence."},
        {id:"expand-counter",title:"Unlock a counter listing",action:"expand-shop",description:"Unlock and stock listing six, seven or eight immediately. Each space lasts for the run.",price:"475 / 655 / 835 gold"},
        {id:"shop-quality",title:"Curated stock",action:"shop-quality",rarity:"epic",
            description:"Ranks I–III increase the odds of better gear in future shops, newly unlocked listings and refreshes.",
            price:"515 / 700 / 885 gold",levels:[0,1,2,3].map(function(rank) {
                const odds=shopOdds(rank)
                return (rank ? "Rank "+rank : "Base")+" · "+Math.round(odds.premium*100)+"% premium, including "
                    +Number((odds.legendary*100).toFixed(1))+"% Legendary"
            })},
        {id:"repeat-upgrade",title:"Repeat luck",action:"repeat-upgrade",description:"Once a rarity is picked, an eligible item you own has extra weight inside that rarity. Special crates still use their own rarity roll.",price:"430 / 585 / 740 gold"},
        {id:"mystery-cache",title:"Wrapped mystery cache",action:"mystery",rarity:"epic",description:"Unwrap one eligible Epic item (80%) or Legendary item (20%). Then choose its destination.",price:"670 gold"},
        {id:"loaded-dice",title:"Loaded dice",action:"scramble",description:"Replace equipped gear with matching-rarity gear at Lv 0. Inventory and slot effects remain.",price:"560 gold"},
        {id:"item-upgrade-token",title:"Item upgrade token",action:"item-upgrade",description:"Upgrade any equipped or stored item once, up to Lv 3.",price:"510 gold"},
        {id:"expand-inventory",title:"Expand inventory",action:"inventory",description:"One extra bag space for this run, up to ten.",price:"310 gold"},
        {id:"pet-token",title:"Pet upgrade token",action:"pet",description:"Train your current companion up to three times. Each rank increases its damage and duty time and shortens rest.",price:"360 / 500 / 640 gold"},
        {id:"shield-upgrade",title:"Shield upgrade",action:"shield-upgrade",description:"Each rank cuts 0.65 seconds from the time to fully recharge. Rank II also reduces the charge spent per block.",price:"390 / 575 / 760 gold"},
        {id:"barrier-core",title:"Barrier core",action:"barrier-core",description:"Install a fresh Barrier with two, three or four charges. A broken Barrier needs another purchase.",price:"375 / 560 / 745 gold"},
        {id:"equipment-rank",title:"Equipment rank",action:"upgrade",description:"Improve one equipped item. Its item-specific upgrade is shown on the listing.",price:"170 / 270 / 370 gold"},
        {id:"slot-work",title:"Slot effects",action:"power",description:"Buy a slot effect to engrave that slot. It stays there when you replace the equipped item. Some effects require a particular item type or a complete kit. Replace a previous effect only after confirming.",
            price:"395 gold to install · 220 / 330 / 440 gold for ranks"}
    ]
    for (const group of Object.keys(limits)) {
        entries.push({id:"unlock-"+group,action:"unlock",title:"Unlock "+group+" slot",
            description:"Adds an equipment slot for the current run, up to "+limits[group]+".",
            price:unlockPrices[group].find(function(price) { return price>0 })+" gold per slot"})
        for (const spec of slotPowers[group]) {
            entries.push(Object.assign(slotPowerAt(spec,0),{action:"power",group:group,rarity:"rare",
                price:"395 gold to install · 220 / 330 / 440 gold for ranks",
                levels:spec.levels.map(function(_,index) {return "Lv "+index+" · "+slotPowerAt(spec,index).description})}))
        }
    }
    for (const stat of shopUpgrades)
        entries.push({id:"counter-"+stat.id,title:stat.title,action:"shop-stat",description:stat.perk+" for this run, per level. Up to three levels.",price:"380 / 545 / 710 gold"})
    for (const offer of supplies)
        entries.push(Object.assign({price:offer.cost+" gold"},offer))
    return entries.map(function(entry) {return Object.assign({category:shopCategory(entry.action),shopItem:true},entry)})
}

function mysteryItem(run, tierRoll, itemRoll) {
    const eligible = Object.values(weapons).concat(Object.values(activeAbilities),Object.values(passives))
    const tier = tierRoll * (88+22) < 88 ? "epic" : "legendary"
    const pool = eligible.filter(function(item) { return item.rarity === tier && canOffer(run,item) })
    return pickRarityItem(run,pool,itemRoll)
}

function makeShop(run, random, excluded, maximum) {
    const limit = maximum === undefined ? run.shopCapacity || 5 : maximum
    const blocked = excluded || []
    const options = equipmentStock(run).filter(function(card) { return !blocked.includes(card.id) })
    const stock = []
    function draw(pool) {
        if (!pool.length || stock.length >= limit)
            return
        const picked = pool[Math.floor(random() * pool.length)]
        stock.push(picked)
        const index = options.indexOf(picked)
        if (index >= 0)
            options.splice(index, 1)
    }

    function drawGear(rarity,prefix,price) {
        if (stock.length>=limit) return
        const pool=Object.values(weapons).concat(Object.values(activeAbilities),Object.values(passives)).filter(function(item) {
            return item.rarity===rarity && canOffer(run,item)
                && !blocked.includes("stock-"+item.id) && !blocked.includes("premium-"+item.id)
                && !stock.some(function(card){return card.gearId===item.id})
        })
        const item=pickRarityItem(run,pool,random())
        if (item) stock.push({id:prefix+item.id,action:"gear",gearId:item.id,group:groupOf(item),
            title:item.title,rarity:item.rarity,cost:price,description:item.description})
    }

    const odds=shopOdds(run.shopQuality || 0)
    const roll = random()
    if (roll<odds.premium)
        drawGear(roll<odds.legendary ? "legendary" : "epic","premium-",roll<odds.legendary ? 850 : 590)
    if (limit>=2 || !stock.length) {
        const rare=random()<.68
        drawGear(rare ? "rare" : "common","stock-",rare ? 460 : 325)
    }
    if (stock.length < limit && !blocked.includes("slot-power") && random() < .75) {
        stock.push(slotOffer(run, random))
    }
    if (stock.length < limit && !blocked.includes("pet-token") && run.pet && run.pet.level < 3) {
        const pet = Pets.spec(run.pet.id)
        const next = Pets.trained(pet,run.pet.level + 1)
        stock.push({ id:"pet-token", action:"pet", title:"Pet upgrade token", rarity:"unique", cost:360 + run.pet.level * 140,
            description:pet.title + " reaches Lv " + (run.pet.level + 1) + " with stronger attacks every "
                + next.interval.toFixed(1) + "s, " + next.duty.toFixed(1) + "s on duty and " + next.rest.toFixed(1) + "s rest." })
    }
    const quality=run.shopQuality || 0
    if (stock.length < limit && quality < 3 && !blocked.includes("shop-quality") && random() < .43) {
        const next=shopOdds(quality+1)
        stock.push({id:"shop-quality",title:"Curated stock · Lv "+(quality+1),action:"shop-quality",rarity:"epic",
            level:quality+1,cost:515+quality*185,
            description:"Future stock draws have "+Math.round(next.premium*100)+"% chance to offer Epic or Legendary gear, including "
                +Number((next.legendary*100).toFixed(1))+"% for Legendary. Also improves newly unlocked listings and refreshes."})
    }
    if (stock.length < limit && run.repeatRank < 3 && !blocked.includes("repeat-upgrade") && random() < .38) {
        stock.push({id:"repeat-upgrade",title:"Repeat luck · Lv "+(run.repeatRank+1),action:"repeat-upgrade",rarity:"rare",
            cost:430+run.repeatRank*155,description:"After rarity is rolled, gain an extra "+(repeatChance(run.repeatRank+1)*100).toFixed(1)
                +"% chance to draw eligible owned gear of that rarity."})
    }
    if (stock.length < limit && !blocked.includes("mystery-cache") && random() < .43) {
        const tierRoll = random()
        const itemRoll = random()
        if (mysteryItem(run,tierRoll,itemRoll))
            stock.push({id:"mystery-cache",title:"Wrapped mystery cache", action:"mystery", rarity:"epic", cost:670,
                tierRoll:tierRoll,itemRoll:itemRoll,description:"Unwrap one surprise. 80% Epic or 20% Legendary. Spend gold to reveal it, then choose where it goes."})
    }
    if (stock.length < limit && !blocked.includes("shop-stat") && random() < .43) {
        const stats = shopUpgrades.filter(function(profile) { return run.shopStats[profile.id] < 3 })
        if (stats.length) {
            const stat = stats[Math.floor(random()*stats.length)]
            stock.push({id:"shop-stat",title:stat.title+" · Lv "+(run.shopStats[stat.id]+1),action:"shop-stat",
                rarity:"rare",cost:380+run.shopStats[stat.id]*165,stat:stat.id,amount:stat.amount,
                description:stat.perk+" for this run. Each stat can be purchased three times."})
        }
    }
    draw(options.filter(function(card) { return card.action === "unlock" }))
    draw(options.filter(function(card) { return card.action === "upgrade" }))
    if (stock.length < limit && run.inventory.length < inventoryLimit && !blocked.includes("expand-inventory") && random() < .38) {
        stock.push({ id:"expand-inventory", action:"inventory", cost:310, title:"Expand inventory",
            index:run.inventory.length, description:"Adds one storage space for this run, up to ten." })
    }
    if (stock.length < limit && !blocked.includes("shield-upgrade") && run.shield.level < 3 && random() < .43) {
        stock.push({ id:"shield-upgrade",action:"shield-upgrade",title:"Shield upgrade · Lv " + (run.shield.level + 1),
            cost:390 + run.shield.level * 185, rarity:"rare",
            description:run.shield.level === 1 ? "Add one block per raise and reduce shield recovery by 0.65 seconds."
                : "Reduce shield recovery by 0.65 seconds for this run." })
    }
    if (stock.length < limit && !blocked.includes("barrier-core") && run.barrierCell.level < 3 && random() < .52) {
        stock.push({id:"barrier-core",action:"barrier-core",title:"Barrier core · Lv "+(run.barrierCell.level+1),
            rarity:"rare",cost:375+run.barrierCell.level*185,description:"Install a fresh Barrier with "+(run.barrierCell.level+2)
                +" charges. It lasts until broken. The next rank needs another purchase."})
    }
    if (!blocked.includes("loaded-dice") && random() < .23) {
        const dice = {id:"loaded-dice",title:"Loaded dice",action:"scramble",rarity:"rare",cost:560,
            description:"Replace all equipped gear with random items of matching rarity at Lv 0. Inventory and slot bonuses stay as they are."}
        if (stock.length < limit)
            stock.push(dice)
        else if (limit >= 5) {
            const replaceable = stock.filter(function(card) { return !["gear","pet","power","shop-quality","item-upgrade"].includes(card.action) })
            if (replaceable.length)
                stock[stock.indexOf(replaceable[Math.floor(random()*replaceable.length)])] = dice
        }
    }
    while (stock.length < limit) {
        const available = options.concat(supplies.filter(function(card) { return !stock.includes(card) && !blocked.includes(card.id) }))
        if (!available.length)
            break
        draw(available)
    }
    if (!blocked.includes("item-upgrade-token") && upgradeTargets(run).length && random()<.34) {
        const substitute=stock.findIndex(card=>["supply","upgrade","repeat-upgrade","shop-stat"].includes(card.action))
        const token={id:"item-upgrade-token",title:"Item upgrade token",action:"item-upgrade",rarity:"rare",cost:510,
            description:"Choose one weapon or ability in your loadout or inventory. Raises it by one level, up to Lv 3."}
        if (stock.length < limit) stock.push(token)
        else if (substitute>=0) stock[substitute]=token
    }
    return stock.map(function(card) { return Object.assign({ sold:false }, card, { cost:shopPrice(run,card.cost) }) })
}

function shopCards(run) {
    return run.shopStock || []
}

function scramble(run, random) {
    const changes = []
    for (const group of Object.keys(catalogs)) {
        const chosen = new Set()
        for (const slot of run.slots[group]) {
            if (!slot.item)
                continue
            const before = catalogs[group][slot.item.id]
            if (before.debugOnly)
                continue
            const pool = Object.values(catalogs[group]).filter(function(card) {
                return card.rarity === before.rarity && !chosen.has(card.id) && !ownedItem(run,group,card.id) && canOffer(run,card)
            })
            if (!pool.length)
                return false
            const after = pool[Math.floor(random()*pool.length)]
            chosen.add(after.id)
            changes.push({slot:slot,id:after.id})
        }
    }
    for (const change of changes)
        change.slot.item = makeItem(change.id)
    return changes.length > 0
}

function availableGold(run) {
    return run.debug && run.debugMoney ? Infinity : run.gold
}

function chargeGold(run,amount) {
    if (!(run.debug && run.debugMoney)) run.gold-=amount
}

function refundableRank(run,group,id) {
    if (run.phase!=="shop" || !["active","passive"].includes(group)) return 0
    const item=ownedItem(run,group,id)
    return item?.paidRanks?.[item.level-1] || 0
}

function refundableAbilities(run) {
    const items=[]
    for (const group of ["active","passive"]) {
        const ids=run.slots[group].map(function(slot){return slot.item?.id})
            .concat(run.inventory.filter(function(entry){return entry?.group===group}).map(function(entry){return entry.item.id}))
        for (const id of ids) {
            const amount=refundableRank(run,group,id)
            if (amount) items.push({group:group,id:id,title:catalogs[group][id].title,amount:amount})
        }
    }
    return items
}

function refundAbility(run,group,id) {
    const amount=refundableRank(run,group,id)
    if (!amount) return 0
    const item=ownedItem(run,group,id)
    item.paidRanks[item.level-1]=0
    item.level-=1
    run.gold+=amount
    clampStats(run)
    return amount
}

function buy(run, id, preferred, random, confirmed) {
    if (run.phase !== "shop")
        return false
    const stored = shopCards(run).find(function(entry) { return entry.id === id })
    const card = id==="expand-counter" ? counterOffer(run) : stored
    if (!card || card.sold || availableGold(run) < card.cost)
        return false

    const slots = run.slots[card.group]
    const abilityRank=["gear","upgrade"].includes(card.action) && ["active","passive"].includes(card.group)
        ? ownedItem(run,card.group,card.gearId) : null
    switch (card.action) {
    case "item-upgrade": {
        const choice=upgradeTargets(run).find(entry=>entry.key===confirmed)
        if (!choice)
            return false
        choice.item.level+=1
        break
    }
    case "scramble":
        if (!random || !scramble(run,random))
            return false
        break
    case "expand-shop":
        if (run.shopCapacity >= 8)
            return false
        run.shopCapacity += 1
        break
    case "shop-quality":
        if ((run.shopQuality || 0)>=3 || card.level!==(run.shopQuality || 0)+1)
            return false
        run.shopQuality=card.level
        break
    case "repeat-upgrade":
        if (run.repeatRank >= 3)
            return false
        run.repeatRank += 1
        break
    case "shop-stat":
        if (run.shopStats[card.stat] >= 3)
            return false
        run.shopStats[card.stat] += 1
        run.boons[card.stat] += card.amount
        if (card.stat === "health")
            run.health += card.amount
        break
    case "barrier-core":
        if (run.barrierCell.level >= 3)
            return false
        run.barrierCell.level += 1
        run.barrierCell.hp = run.barrierCell.level+1
        run.barrierRefill = .47
        break
    case "mystery": {
        const gear = mysteryItem(run,card.tierRoll,card.itemRoll)
        if (!gear)
            return false
        const index = run.shopStock.indexOf(card)
        chargeGold(run,card.cost)
        run.shopStock[index] = {id:card.id, action:"gear", gearId:gear.id, group:groupOf(gear), title:gear.title,
            rarity:gear.rarity, description:gear.description, cost:0, paidPrice:(run.debug && run.debugMoney) ? 0 : card.cost, paid:true, sold:false}
        return true
    }
    case "shield-upgrade":
        if (run.shield.level >= 3)
            return false
        run.shield.level += 1
        break
    case "unlock":
        if (slots.length !== card.index || slots.length >= limits[card.group])
            return false
        slots.push({ item:null, power:"", powerLevel:0 })
        break
    case "upgrade": {
        const index = findSlot(run, card.group, card.gearId)
        if (index < 0 || slots[index].item.level >= 3)
            return false
        slots[index].item.level += 1
        break
    }
    case "power-upgrade":
        if (!slots?.[card.index]?.power || slots[card.index].powerLevel >= 3
            || card.powerId && slots[card.index].power!==card.powerId)
            return false
        slots[card.index].powerLevel += 1
        break
    case "power": {
        if (!slots?.[card.index] || !slotPowers[card.group].some(function(power) {return power.id===card.powerId}))
            return false
        const current = replacement(run,card)
        if (current.id && (current.id===card.powerId || replacementKey(current)!==confirmed))
            return false
        slots[card.index].power = card.powerId
        slots[card.index].powerLevel = 0
        break
    }
    case "gear": {
        const gear = catalogs[card.group][card.gearId]
        if (!canOffer(run, gear) || !equip(run, gear, preferred))
            return false
        break
    }
    case "inventory":
        if (run.inventory.length !== card.index || run.inventory.length >= inventoryLimit)
            return false
        run.inventory.push(null)
        break
    case "pet":
        if (!run.pet || run.pet.level >= 3)
            return false
        run.pet.level += 1
        run.pet.stats = Pets.trained(Pets.spec(run.pet.id),run.pet.level)
        break
    case "supply":
        if (id === "restore")
            run.health = Math.min(maxHealth(run), run.health + 40)
        else if (id === "cartridges")
            run.nextAmmo += 4
        else if (id === "fieldWard")
            run.nextBarrier = 10
        else if (id === "heatSink")
            run.cooldowns = {}
        else if (id === "powerCell")
            run.nextDamageBoost = 18
        else if (id === "spareMed")
            run.health = Math.min(maxHealth(run),run.health+65)
        else if (id === "sealOil")
            run.nextSeal = .20
        else if (id === "corners")
            run.nextBarrier = 15
        break
    default:
        return false
    }
    const index = run.shopStock.indexOf(card)
    if (index >= 0) run.shopStock[index] = Object.assign({}, card, { sold:true })
    const paid=run.debug && run.debugMoney ? 0 : card.cost+(card.paidPrice || 0)
    if (abilityRank && paid) {
        if (!abilityRank.paidRanks) abilityRank.paidRanks=[0,0,0]
        abilityRank.paidRanks[abilityRank.level-1]=paid
    }
    chargeGold(run,card.cost)
    clampStats(run)
    return true
}

function fireRate(spec,stats) {
    const burst=spec.burst && spec.burst.count || 1
    return burst/Math.max(.01,stats.delay+(spec.chargeEachShot ? stats.spinup : 0),spec.burst ? (burst-1)*spec.burst.interval : 0)
}

function weaponComparison(run,reference,item) {
    if (!reference || !item || !weapons[item.id] || !weapons[reference.id]) return []
    const from=weapons[reference.id], to=weapons[item.id]
    const left=run ? effectiveWeaponStats(run,reference) : weaponStats(reference)
    const right=run ? effectiveWeaponStats(run,item) : weaponStats(item)
    const boon=run && run.boons ? 1+run.boons.damage : 1
    const rows=[]
    function add(label,before,after,unit,invert) {
        const original=Number(before.toFixed(2)), offered=Number(after.toFixed(2))
        rows.push({label:label,original:original+unit,offered:offered+unit,
            delta:Math.sign(offered-original)*(invert ? -1 : 1)})
    }
    add("Damage / attack",left.damage*(from.spread ? from.spread.length : 1)*boon,
        right.damage*(to.spread ? to.spread.length : 1)*boon,"",false)
    add("Fire rate",fireRate(from,left),fireRate(to,right),"/s",false)
    if (usesAmmo(to)) {
        if (usesAmmo(from)) {
            add("Magazine",left.capacity,right.capacity,"",false)
            add("Reload",left.reload,right.reload,"s",true)
        } else {
            rows.push({label:"Magazine",original:"—",offered:String(right.capacity),delta:0})
            rows.push({label:"Reload",original:"—",offered:right.reload.toFixed(2)+"s",delta:0})
        }
    }
    return rows
}

function weaponClass(weapon) {
    return weapon.staff || weapon.stab ? "Staffs" : weapon.melee || weapon.throwing ? "Melee" : "Guns"
}

// Shared menu readout: keep descriptions and current upgrade statistics in one place.
function itemDetails(run,group,item) {
    const spec=catalogs[group]?.[item.id]
    if (!spec) return ""
    const level=item.level || 0
    const lines=[kitDescription(group,item.id,spec.description),"Upgrade "+level+" / 3"]
    if (group==="weapon") {
        const stats=run ? effectiveWeaponStats(run,item) : weaponStats(item)
        const damage=stats.damage*(1+(run?.boons?.damage || 0))
        lines.push("Damage "+damage.toFixed(2)+" per hit"+(spec.spread ? " × "+spec.spread.length+" pellets" : "")+" · fire rate "+fireRate(spec,stats).toFixed(2)+"/s")
        if (usesAmmo(spec)) lines.push("Magazine "+stats.capacity+" · reload "+stats.reload.toFixed(2)+"s")
        else if (spec.staff) lines.push("Spell charge "+(item.charge || 0)+" / "+stats.chargeCost+" attacks · R / right-click to cast")
        else if (spec.melee || spec.throwing) lines.push("R / right-click: "+(spec.melee ? "weapon trick, then a stronger charging strike" : "draw and spin the next axe"))
        else if (spec.sustain) lines.push("Continuous fire · "+spec.sustain.limit+"s heat capacity · automatic cooling")
        if (spec.element) lines.push(Elements.kinds[spec.element].title+" "+(stats.elementLevel || spec.elementLevel || 1))
    } else if (group==="active") {
        const stats=activeStats(item)
        lines.push("Cooldown "+(stats.cooldown*Meta.benefits(run).recovery).toFixed(1)+"s before other loadout bonuses"
            +(run?.cooldowns?.[item.id] ? " · remaining "+run.cooldowns[item.id].toFixed(1)+"s" : ""))
        lines.push("Ability damage: "+abilityDamageDescription(run,item))
        if (spec.environment) lines.push("Requires "+environmentNames[spec.environment])
        if (spec.element) lines.push(Elements.kinds[spec.element].title+" "+stats.elementLevel)
    } else lines.push("Effective passive rank "+(run ? passiveRank(run,item.id) : 1+Number(level>=1)+Number(level>=3)*2))
    if (level) lines.push("Latest upgrade: "+upgradeText(spec,level))
    const owned=kitOwnership(run,group,item.id)
    if (owned) lines.push(owned)
    return lines.join("\n")
}

function offerDetails(offer,run) {
    const group=groupOf(offer)
    if (!catalogs[group]?.[offer.id]) return offer.description
    return [itemDetails(null,group,{id:offer.id,level:offer.upgradeLevel || 0}),
        kitOwnership(run,group,offer.id)].filter(Boolean).join("\n")
}

var activeImpacts={shock:[5,1.5],sunfall:[8.25,2.3],immolate:[3.3,1],stormcall:[9,1.8],searingmark:[1.5,1],
    bladesweep:[7.4,2.3],blackWake:[4.2,1.25],brineFlare:[7.4,1.8],colourSpill:[5,1.5],mireCloud:[4.5,1]}
function abilityDamageDescription(run,item,bonus) {
    const spec=activeAbilities[item.id],s=activeStats(item).strength
    const factor=bonus ?? Meta.benefits(run).active*(1+(run?.boons?.damage || 0))*(run ? 1+perk(run,"activeDamage") : 1)
    const format=function(value){return Number((value*factor).toFixed(2))}
    if(spec.damage) {
        let multiplier=1
        if(run) multiplier=item.id==="lateBloom" && run.wave>20 ? 2.2 : item.id==="fieldLesson" && run.wave<=20 ? 2 : 1
        return format(spec.damage*(1+s*.22)*multiplier)+" impact per target"+(item.id==="breachOrder" ? " · ×2.5 vs Overlords" : "")
    }
    if (["solarCone","nightVeil","stormGlass"].includes(spec.form)) {
        const impact=format((spec.value+s*.9)*affinity(run,spec))
        return spec.form==="stormGlass" ? impact+" impact per shot shattered" : impact+" impact per target"
    }
    const base=activeImpacts[item.id]
    if(base)return format(base[0]+s*base[1])+" impact before build/kit bonuses"
    if(spec.form && ["edgeRing","seekMark","electrify","ember","interrupt","corrode","burstPulse","pierceScroll"].includes(spec.form))
        return format(spec.value+s*.9)+" impact"+(spec.form==="pierceScroll" ? "; successive targets retain84%" : spec.form==="burstPulse" ? "; ×1.72 with a burst weapon" : "")
    if(spec.form==="mint")return format(2.8+s)+" Electric impact to nearby foes"
    const conditional={
        execution:"Defeats one eligible non-boss, then triggers a death explosion",
        liquidation:format(5*(1+s*.14))+"–"+format(20*(1+s*.14))+" per target; spends20–80 gold",
        guardPulse:format(3.5+s)+"–"+format(22.5+s)+" per target, from absorbed shield force",
        criticalEcho:"Last critical ×"+Number((.52+s*.055).toFixed(2))+", capped at "+format(22)+" impact",
        mirrormine:format(2.5+s)+" impact per intercepted projectile",
        sporeBurst:format(5+s*2)+" +65% of the foe's Poison health loss",
        runesurge:format(3+s)+" +2.7 × stored staff charges",
        emberharvest:format(2.7+s)+" +1.5 × harvested Burn level",
        frag:format(5.4+s*1.25)+" blast impact",cryogrenade:format(3+s*1.25)+" blast impact",
        nullgrenade:format(2+s*1.25)+" blast impact",gravitywell:format(7+s*1.25)+" blast impact",
        arcshield:format(3+s)+"–"+format(6+s)+" impact from intercepted shots"
    }
    if(conditional[item.id])return conditional[item.id]+" · before build bonuses"
    return "No direct impact; applies the utility, status or summon described above"
}
