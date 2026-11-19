.pragma library
.import "Abyss.js" as Abyss
.import "Conditions.js" as Conditions
.import "EnemyLore.js" as Lore

var fronts = [
    { id: "front", title: "Shrine Path", label: "Shrine", yaw: 0, pitch: 0, art: "shrine.png", color: "#f7b47a" },
    { id: "left", title: "West Approach", label: "West", yaw: 90, pitch: 0, art: "media.jpg", color: "#f1a1ab" },
    { id: "right", title: "Droid Lab", label: "Droid Lab", yaw: -90, pitch: 0, art: "lab.jpg", color: "#f1b789" },
    { id: "up", title: "Star Sky", label: "Star Sky", yaw: 0, pitch: 90, art: "sky.jpg", color: "#86def2" },
    { id: "down", title: "The Abyss", label: "Abyss", yaw: 0, pitch: -90, art: "abyss.jpg", color: "#c7adff" }
]

var groundFronts = ["left", "front", "right"]

var spawnDistance = 1750
var attackIntervalScale = 1.22
var arrivalSpacing = 1.16

var enemyTypes = {
    silophosus: {
        id: "silophosus", title: "Silophosus", role: "ground", health: 2, damage: 7,
        speed: 335, pace: "Very high", reach: 270, interval: 3.0, windup: 0.85,
        skin: "#b95e30", accent: "#ffc670", size: 1, shake: [5, 2, 0.20, 74],
        description: "A light melee demon that closes ground quickly. Its jaw opens wide before a weak bite."
    },
    fhantamegus: {
        id: "fhantamegus", title: "Fhantamegus", role: "ground", health: 8, damage: 13,
        speed: 185, pace: "Medium-high", reach: 280, interval: 3.0, windup: 0.92,
        skin: "#7041ad", accent: "#cc8cff", size: 1.08, shake: [12, 3, 0.31, 58],
        description: "Warps to a visible lane on another ground front every three seconds. Watch for the violet exit and destination alert."
    },
    hosphoragus: {
        id: "hosphoragus", title: "Hosphoragus", role: "ground", health: 14, damage: 24,
        speed: 91, pace: "Low", reach: 320, interval: 3.75, windup: 1.12,
        skin: "#a93448", accent: "#ff758c", size: 1.48, shake: [7, 19, 0.52, 34],
        description: "A heavy melee demon. The first time it reaches striking distance, its roar stuns you for one second."
    },
    skorochiyus: {
        id:"skorochiyus",title:"Skorochiyus",role:"ground",health:10,damage:10,speed:155,pace:"High",
        reach:750,interval:4.9,windup:1.38,element:"burn",elementLevel:2,boltTime:1.02,boltHealth:2.5,
        skin:"#aa784b",accent:"#ff8839",size:1.54,shake:[9,13,.34,73],
        description:"A flying skull with burning sockets. Its open jaw launches two spread fireballs at once. Each hit applies Burn II."
    },
    spartalien: {
        id: "spartalien", title: "Spartalien", role: "alien", health: 5, damage: 9,
        speed: 91, pace: "Low", reach: 645, interval: 4.3, windup: 1.35,
        skin: "#167b91", accent: "#74eaff", size: 1, shake: [3, 7, 0.30, 47],
        description: "A slow Star Sky attacker with a single low-damage bolt."
    },
    fizzalien: {
        id: "fizzalien", title: "High Fizzalien", role: "alien", health: 3, damage: 15, barrier: 3,
        speed: 134, pace: "Medium", reach: 609, interval: 4.1, windup: 1.25,
        skin: "#657e23", accent: "#e4ff5b", size: 0.95, shake: [11, 8, 0.29, 129],
        description: "A fragile alien behind a three-point barrier. It fires a pair of bolts in quick succession."
    },
    ghorimagous: {
        id: "ghorimagous", title: "Ghorimagous", role: "ground", health: 13, damage: 13,
        speed: 74, pace: "Low", reach: 295, interval: 3.8, windup: 1.15,
        skin: "#228970", accent: "#89ffc4", size: 1.36, shake: [11, 10, 0.47, 28],
        description: "Moves diagonally. Every five seconds it phases into an invincible grey ghost for three seconds."
    },
    bergensus: {
        id: "bergensus", title: "Bergensus", role: "ground", health: 1.5, damage: 23,
        speed: 282, pace: "High", reach: 208, interval: 0.62, windup: 0.60, crit:.18,
        skin: "#b92762", accent: "#ff9ad9", size: 0.43, shake: [21, 7, 0.23, 99],
        description: "A tiny flier that rushes you at high speed. Its one strike has an 18% critical chance, then it dies."
    },
    gojemarus: {
        id: "gojemarus", title: "Gojemarus", role: "gold", health: 37, damage: 0,
        speed: 245, pace: "High", reach:spawnDistance, interval: 0, windup: 0,
        skin: "#897232", accent: "#ffe766", size: 1.18, shake: [5, 5, 0.20, 74],
        description: "Flies side to side and up and down for ten seconds, then flees. Earn 2 gold per hit and 50 on the kill. Allies on its front move and attack 20% faster."
    },
    humontafagus: {
        id: "humontafagus", title: "Humontafagus", role: "boss", health: 108, damage: 22,
        speed: 104, pace: "Medium", reach: 360, interval: 3.8, windup: 1.48,
        skin: "#75422e", accent: "#ffe083", size: 2.12, shake: [24, 17, 0.72, 28],
        description: "First appears on wave 10. At half health it summons three demons on its wallpaper. The wave-ten summons have reduced health and damage."
    },
    mothergalian: {
        id: "mothergalian", title: "Mothergalian", role: "alien", health: 28, damage: 6, barrier: 3,
        speed: 46, pace: "Very low", reach: 710, interval: 5.6, windup: 1.55,
        skin: "#854369", accent: "#ffabdc", size: 1.66, shake: [4, 7, .32, 61],
        description: "Her barrier protects a slow brood carrier. Every nine seconds she can release a Spartalien or High Fizzalien on her wallpaper. A brood can have three live offspring."
    },
    zadrrimus: {
        id: "zadrrimus", title: "Zadrrimus", role: "ground", health: 24, damage: 31,
        speed: 156, pace: "Medium", reach: 320, interval: 4.8, windup: 1.4, crit:.16,
        skin: "#5b3154", accent: "#fb76de", size: 1.42, shake: [17, 11, .48, 85],
        description: "A huge, toothy mouth telegraphs its bite. A hit distorts your view for five seconds and has a 16% critical chance."
    },
    rerogorubus: {
        id: "rerogorubus", title: "Rerogorubus", role: "ground", health: 9, damage: 12,
        speed: 83, pace: "Low", reach: 310, interval: 4.0, windup: 1.2,
        skin: "#667647", accent: "#e4f991", size: 1.33, shake: [8, 12, .39, 65],
        element:"poison", elementLevel:1,
        description: "Its poisonous tongue can reduce maximum health. Each death splits it in two until the second split. Smaller copies hit just as hard."
    },
    mastafangenbus: {
        id: "mastafangenbus", title: "Mastafangenbus", role: "boss", health: 110, damage: 43,
        speed: 73, pace: "Low", reach: 440, interval: 4.2, windup: 1.46, rangedInterval:4.7, crit:.30,
        skin: "#254b5b", accent: "#79f1ed", size: 2.45, shake: [29, 18, .66, 49],
        description: "First appears on wave 20. Winds up lethal spinning strikes and hurls bright shards from range. Both attacks have a 30% critical chance."
    },
    gigafinterus: {
        id: "gigafinterus", title: "Gigafinterus", role: "boss", health: 163, damage: 17,
        speed: 54, pace: "Very low", reach: 615, interval: 5.35, windup: 1.82,
        skin: "#78413c", accent: "#ff9c5f", size: 2.64, shake: [13, 17, .62, 36],
        description: "First appears on wave 30. The dragon opens its jaws and breathes a cone of fire that applies level 3 Burn."
    },
    princoratus: {
        id: "princoratus", title: "Princoratus", role: "ground", health: 10, damage: 23,
        speed: 211, pace: "High", reach: 225, interval: 2.75, windup: .83,
        skin: "#a74d31", accent: "#ffa95f", size: 1.06, shake: [18, 10, .35, 91],
        description: "Bobs up and down as it rushes you. Its level 2 death blast hits nearby demons and can hurt you. Shoot it at a distance."
    },
    claptrap: {
        id:"claptrap", title:"Clap Trap", role:"alien", health:21, damage:18, barrier:3,
        speed:208, pace:"High", reach:645, interval:4.15, windup:1.3,
        skin:"#4f829f", accent:"#c0efff", size:1.23, shake:[15,11,.38,105],
        element:"freeze", elementLevel:1,
        description:"An icy saucer with a bright eye. Its bolts apply level 1 Frost and slow your reticle and turns."
    },
    mystery: {
        id:"mystery", title:"???", role:"phantom", abyss:true, health:45, damage:6,
        speed:245, pace:"High", reach:245, interval:3.4, windup:1.15,
        skin:"#1b1325", accent:"#ebc7ff", size:1.41, shake:[12,9,.47,15],
        element:"weaken", elementLevel:2,
        description:"The Abyss shade blacks out the field while it is alive. Its touch weakens your attacks for five seconds. Kill it to make it drift away."
    },
    meteor: {
        id:"meteor",title:"Falling meteor",role:"hazard",health:44,damage:46,
        speed:136,pace:"Medium",reach:240,interval:0,windup:.9,
        skin:"#835044",accent:"#ffd48b",size:1.48,shake:[25,19,.46,88],
        description:"Shoot down the incoming rock during a meteor shower. It detonates and breaks apart at contact."
    },
    helboranius: {
        id:"helboranius",title:"Helboranius",role:"angel",health:36,damage:14,
        speed:192,pace:"High",reach:327,interval:4.3,windup:1.36,
        skin:"#393643",accent:"#f3e7df",size:2.07,shake:[10,19,.41,57],
        description:"Its big robed frame can hide others behind it. Physical hits lose 20% of their damage."
    },
    jos: {
        id:"jos",title:"Jospharemus",role:"angel",health:23,damage:26,
        speed:56,pace:"Very low",reach:310,interval:4.0,windup:1.14,
        skin:"#666777",accent:"#d0e5e9",size:1.39,shake:[19,4,.38,73],
        description:"This weeping stone angel covers its eyes and takes 90% less damage while you look at it."
    },
    lucifoverus: {
        id:"lucifoverus",title:"Lucifoverus",role:"boss",angel:true,health:143,damage:26,
        speed:264,pace:"Very high",reach:323,interval:.92,windup:.70,crit:.14,chargeDistance:510,chargeSpeed:2.85,
        skin:"#81263c",accent:"#ffce99",size:2.31,shake:[25,21,.51,105],
        immune:true,
        description:"Its trident deals a random level 1 status and has a 14% critical chance. It retreats to another wallpaper after striking and recovers for five seconds. Elemental statuses cannot stop it."
    },
    gendoustagus: {
        id:"gendoustagus",title:"Gendoustagus",role:"ground",health:3.4,damage:5,
        speed:79,pace:"Low",reach:240,interval:4.65,windup:1,
        skin:"#413053",accent:"#bf68ee",size:.85,shake:[5,5,.21,29],
        description:"Its killer carries a shadow curse for the rest of the wave. A skull marks this demon. A player curse increases incoming damage by 20% and occasionally makes a shot misfire."
    },
    jon: {
        id:"jon",title:"Jonbosporo Fighter",role:"alien",health:21,damage:13,
        speed:273,pace:"Very high",reach:640,interval:3.6,windup:.96,
        skin:"#394772",accent:"#9ceaff",size:1.22,shake:[13,7,.30,107],
        dodge:2,maneuver:true,
        description:"A fast fighter that slips erratically across Star Sky and dodges a held aim at level 2."
    },
    veilskate: {
        id:"veilskate",title:"Veilskate",role:"alien",health:4.5,damage:12,
        speed:65,pace:"Low",distance:5825,reach:5825,interval:7.2,windup:1.5,crit:.40,
        boltTime:2.15,boltHealth:3,skin:"#35474a",accent:"#66ff35",size:.79,shake:[8,4,.24,70],
        description:"A small camouflaged alien that drifts sideways at extreme range. Its green plasma balls hit for medium damage and have a 40% critical chance."
    },
    hasasasa: {
        id:"hasasasa",title:"Hasasasa Forum",role:"boss",ship:true,health:218,damage:18,barrier:4,
        speed:0,pace:"Stationary",reach:spawnDistance,interval:3.7,windup:1.02,
        skin:"#373d60",accent:"#abbdff",size:2.27,shake:[15,19,.42,65],
        description:"Aim for the moving emitters at the ends of the hanging tubes, then shoot the central cannon. Each lost emitter brings a new barrier and two ships. You can intercept every projectile."
    },
    battlestar: {
        id:"battlestar",title:"Go Go Battlestar",role:"alien",battlestar:true,
        health:47,damage:3.3,speed:61,pace:"Low",reach:1180,interval:4.3,windup:1.1,
        beam:{duration:2.75,tick:.55,warning:1.04},skin:"#171522",accent:"#ff3c54",size:2.35,shake:[4,5,.24,61],
        description:"A black and scarlet warship that slowly rises and sinks through Star Sky. Its warning line turns into a continuous long-range laser. Turn away before it fires or strike during its cooldown."
    },
    skarabatunus: {
        id:"skarabatunus",title:"Skarabatunus",role:"ground",skeleton:true,
        health:37,damage:12,speed:148,pace:"Medium",reach:316,interval:3.65,windup:.95,
        skin:"#947f6a",accent:"#ffdd51",size:1.51,shake:[8,9,.31,73],
        beamsEvery:5, description:"A yellow-eyed skeleton stops every five seconds to fire a gold-stealing ray. Turn away to avoid it. Defeating it returns 60% of the stolen gold."
    },
    nindumipus: {
        id:"nindumipus",title:"Nindumipus",role:"ground",health:13,damage:22,
        speed:151,pace:"Medium",reach:264,interval:3.25,windup:.79,
        skin:"#363645",accent:"#e1ecfc",size:1.12,shake:[22,6,.30,100],dodge:3,
        description:"A clawed demon that quickly dodges a held aim at level 3. When hurt it leaves ten seconds of smoke that hides enemies behind it."
    },
    iceterapus: {
        id:"iceterapus",title:"Iceterapus",role:"ground",health:15,damage:19,
        speed:107,pace:"Medium",reach:269,interval:3.9,windup:1,
        skin:"#a5cee2",accent:"#e4fbfc",size:1.47,shake:[11,14,.35,53],
        element:"freeze",elementLevel:3,
        description:"The furry ice brute resists Frost. It grows visibly angry and speeds up after the first hit."
    },
    seraphijus: {
        id:"seraphijus",title:"Seraphijus",role:"angel",health:23,damage:35,
        speed:72,pace:"Low",reach:spawnDistance,interval:0,windup:1,
        skin:"#5b5363",accent:"#fff0da",size:1.29,shake:[23,20,.43,52],dodge:1,maneuver:true,
        description:"This angel drifts sideways and vertically for 15 seconds. It then sets off a level 3 explosion. Its chest timer and level 1 Dodge make it a priority target."
    },
    stinkaturumus: {
        id:"stinkaturumus", title:"Stinkaturumus", role:"boss", slime:true, poisonImmune:true, health:187, damage:12,
        speed:207, pace:"High", reach:640, interval:5.4, windup:1.65,
        skin:"#48672a", accent:"#d9ed46", size:2.50, shake:[11,13,.48,39],
        description:"First appears on wave 60. It exhales a green cloud of level 3 Poison on its wallpaper. Hitting it can call Saslimigus. It slips to a neighbouring view when a peon sticks you."
    },
    saslimigus: {
        id:"saslimigus", title:"Saslimigus", role:"ground", slime:true, health:9, damage:5,
        speed:153, pace:"Medium", reach:510, interval:4.25, windup:1.03,
        skin:"#709e2d", accent:"#eafb59", size:.65, shake:[4,5,.23,73],
        element:"sticky", elementLevel:3,
        description:"A hornless peon from Stinkaturumus. Its slime glob can be shot down and only sticks if you are looking at its wallpaper. Level 3 Sticky blocks turning briefly."
    },
    capablancamus: {
        id:"capablancamus",title:"Capablancamus",role:"ground",health:37,damage:23,crit:.50,critImmune:true,
        speed:272,pace:"Very high",reach:307,interval:6.45,windup:1.45,
        skin:"#2e252c",accent:"#ffd079",size:1.53,shake:[20,9,.48,49],
        description:"A fast, armored executioner that takes normal damage from critical hits. It charges a heavy strike with a 50% chance to crit, then needs a long recovery."
    },
    trispiramahedus: {
        id:"trispiramahedus",title:"Trispiramahedus",role:"alien",health:21,damage:5.8,triad:true,
        speed:91,pace:"Low",reach:777,interval:5.15,windup:1.28,element:"electric",elementLevel:1,electricStun:.30,
        skin:"#929899",accent:"#d5b2ff",size:.82,shake:[9,7,.29,98],
        description:"Three flying magnets linked in a triangle. Each stops at range and fires lightning with a 30% Stun chance. Links to nearby enemies give them 30% movement speed, 28% faster attack timers, and 14 extra points of critical chance."
    },
    helesepeptium: {
        id:"helesepeptium",title:"Helesepeptium",role:"ground",serpent:true,health:39,damage:12,
        speed:0,pace:"Stationary",distance:3950,reach:3950,interval:5.65,windup:1.47,
        skin:"#263a30",accent:"#b0f487",size:1.19,shake:[9,11,.31,88],
        element:"electric",elementLevel:2,boltTime:1.49,boltHealth:3.2,
        description:"A stationary serpent that materialises beyond twice the ordinary spawn distance. Hold Shift to zoom in on its head. Its Electric bolts travel quickly and can be intercepted."
    },
    fetaSpotter: {
        id:"fetaSpotter",title:"Feta Spotter",role:"alien",sniper:true,health:44,damage:25,
        speed:0,pace:"Stationary",distance:5250,reach:5250,interval:6.45,windup:2.15,
        skin:"#283950",accent:"#ff6b59",size:1.31,shake:[13,6,.36,77],boltTime:.84,boltHealth:5.6,
        description:"A hovering droid with a long rifle. It sights you from beyond the serpent's range. A damaging shot makes it disappear and rematerialise on another perch on the same wallpaper."
    },
    nosferapabakus: {
        id:"nosferapabakus",title:"Nosferapabakus",role:"ground",devour:true,health:84,damage:34,
        speed:48,pace:"Very low",reach:414,interval:5.44,windup:1.63,
        skin:"#473235",accent:"#f2c39b",size:2.36,shake:[23,19,.59,42],
        description:"A hairy maw with tiny wings. Landing a bite restores 12% of its maximum health. While wounded it can turn, dash at a nearby demon, and tear off a chunk to heal."
    },
    crufixicatus:{
        id:"crufixicatus",title:"Crufixicatus",role:"ground",blindImmune:true,health:11,damage:12,
        speed:289,pace:"Very high",reach:280,interval:2.17,windup:1.09,
        skin:"#c8bdbb",accent:"#d34b75",size:1.22,shake:[13,9,.37,91],
        description:"The tears fall upward. Its first touch brings the face too close."
    },
    voidGlitch: {
        id:"voidGlitch",title:"?!:!E#DR#FJD",role:"boss",voidBoss:true,abyss:true,health:249,damage:30,crit:.50,dodge:2,
        speed:238,pace:"High",distance:4650,reach:4350,interval:5.8,windup:1.86,
        skin:"#151321",accent:"#ff405f",size:2.32,shake:[23,12,.47,91],boltTime:1.12,boltHealth:6.8,
        description:"A distortion with two red eyes. Its far-range shots have a 50% critical chance. It roams between views and calls a shade every 15 seconds. At half health its signal distorts the screen until it dies."
    },
    crawler: {
        id: "crawler", title: "Void Crawler", role: "void", abyss:true,health: 15, damage: 12,
        speed: 81, pace: "Low", reach: 350, interval: 5.2, windup: 1.45,
        skin: "#263343", accent: "#b7afe5", size: 1.06, shake: [6, 16, 0.43, 39],
        element:"blind",elementLevel:1,
        description: "A deep-water hunter that darkens the edge of your vision when it bites. Fight it with weapons. Hold F in the Abyss to close the rift and stop later Void spawns."
    }
}
enemyTypes.papapoganus={id:"papapoganus",title:"Papapoganus",role:"ground",sprayer:true,poisonImmune:true,
    health:57,damage:1.3,speed:114,pace:"Medium",reach:735,interval:6.8,windup:1.35,
    skin:"#878384",accent:"#e5d76c",size:1.72,shake:[2,2,.12,65],description:"A smiling, perforated horror with a poisonous yellow spray."}
enemyTypes.blandromedus={id:"blandromedus",title:"Blandromedus",role:"ground",vampire:true,
    health:83,damage:16,speed:143,pace:"Medium",reach:810,interval:4.25,windup:1.05,
    skin:"#efdac3",accent:"#ff435c",size:1.76,shake:[9,10,.4,58],element:"weaken",elementLevel:3,
    boltTime:1.22,boltHealth:5.2,description:"A Blood Moon vampire with a hanging eye and violet wings. Its blood shots inflict Weaken III and it regenerates health when a shot lands."}
enemyTypes.oblogabgalus={id:"oblogabgalus",title:"Oblogabgalus",role:"boss",trainer:true,tutorialOnly:true,
    health:60,damage:7,speed:138,pace:"Medium",reach:800,interval:3.8,windup:1.2,
    skin:"#bd9b4c",accent:"#fff0a0",size:2.25,shake:[6,7,.25,40],description:"Your first lesson has teeth."}
Object.assign(enemyTypes,Abyss.enemies)
enemyTypes.lalaBubu = {
    id:"lalaBubu",title:"Lala Bubu",role:"alien",maneuver:true,health:25,damage:11,speed:286,pace:"Very high",
    reach:770,interval:1.57,windup:.58,boltTime:.69,boltHealth:2.9,skin:"#a84b72",accent:"#ff556e",size:1.25,
    shake:[12,15,.36,106],description:"A grinning pink doll with red pupils. Strafes in both axes and fires only while you share her wallpaper."
        +" Her death curses you and reverses your view controls for ten seconds."
}

for (const name of ["princoratus","seraphijus","meteor"])
    enemyTypes[name].explosionImmune = true
for (const spec of Object.values(enemyTypes)) {
    spec.description = Lore.whispers[spec.id] || spec.description
    spec.origin = Lore.origin(spec)
}

// A wave introduces at most one species. Bosses have their own final slot.
var introductions = [
    {wave:1,type:"silophosus",front:"front",weight:11},
    {wave:3,type:"fhantamegus",front:"front",weight:4},
    {wave:5,type:"hosphoragus",front:"front",weight:3,heavy:true},
    {wave:6,type:"skorochiyus",front:"front",weight:2.75,heavy:true},
    {wave:7,type:"spartalien",front:"up",weight:5},
    {wave:8,type:"iceterapus",front:"front",weight:2.5,heavy:true},
    {wave:11,type:"crawler",front:"down",weight:3.2,heavy:true},
    {wave:13,type:"fizzalien",front:"up",weight:3},
    {wave:15,type:"ghorimagous",front:"left",weight:3,heavy:true},
    {wave:17,type:"bergensus",front:"right",weight:4},
    {wave:18,type:"veilskate",front:"up",weight:2.3},
    {wave:19,type:"gojemarus",front:"front",weight:1.5,rare:true},
    {wave:21,type:"gendoustagus",front:"left",weight:3,rare:true},
    {wave:22,type:"mothergalian",front:"up",weight:1,heavy:true,rare:true},
    {wave:23,type:"nindumipus",front:"right",weight:2.2,heavy:true},
    {wave:24,type:"zadrrimus",front:"front",weight:1.4,heavy:true,rare:true},
    {wave:26,type:"rerogorubus",front:"right",weight:1.6,heavy:true,rare:true},
    {wave:27,type:"jon",front:"up",weight:1.7,heavy:true},
    {wave:28,type:"princoratus",front:"front",weight:1.7,heavy:true,rare:true},
    {wave:29,type:"claptrap",front:"up",weight:1.6,heavy:true,rare:true},
    {wave:32,type:"helboranius",front:"front",weight:1.5,heavy:true,rare:true},
    {wave:34,type:"jos",front:"left",weight:1.45,heavy:true,rare:true},
    {wave:36,type:"seraphijus",front:"right",weight:1.5,heavy:true,rare:true},
    {wave:42,type:"lalaBubu",front:"up",weight:1.04,heavy:true,rare:true},
    {wave:43,type:"battlestar",front:"up",weight:1.25,heavy:true,rare:true},
    {wave:47,type:"papapoganus",front:"front",weight:1.6,heavy:true},
    {wave:46,type:"skarabatunus",front:"front",weight:1.45,heavy:true,rare:true},
    {wave:53,type:"capablancamus",front:"right",weight:1.18,heavy:true,rare:true},
    {wave:56,type:"trispiramahedus",front:"up",weight:1.02,heavy:true,rare:true},
    {wave:62,type:"helesepeptium",front:"left",weight:1.03,heavy:true,rare:true},
    {wave:65,type:"fetaSpotter",front:"right",weight:.92,heavy:true,rare:true},
    {wave:67,type:"crufixicatus",front:"front",weight:2.45},
    {wave:68,type:"nosferapabakus",front:"front",weight:.81,heavy:true,rare:true}
].concat(Abyss.introductions).sort(function(a,b) { return a.wave-b.wave })

var attackStyles = {
    silophosus:"chomp", fhantamegus:"lunge", hosphoragus:"roar", spartalien:"bolt", fizzalien:"doubleBolt",
    ghorimagous:"sweep", bergensus:"rush", gojemarus:"flutter", humontafagus:"headbutt", mastafangenbus:"spin",
    mothergalian:"broodBeam", zadrrimus:"jawSnap", rerogorubus:"tongue", gigafinterus:"fireBreath", princoratus:"spike",
    claptrap:"cryoRay", mystery:"tendrils", crawler:"voidLash", meteor:"impact", helboranius:"armClap", jos:"stoneHands",
    lucifoverus:"trident", gendoustagus:"hexPuff", jon:"strafingBolt", hasasasa:"cannon", nindumipus:"claws",
    iceterapus:"iceFist", seraphijus:"detonate", stinkaturumus:"poisonBreath", saslimigus:"slimeSpit",
    veilskate:"bolt", battlestar:"cannon", skarabatunus:"headbutt", capablancamus:"executioner", trispiramahedus:"magnetBolt",
    helesepeptium:"snakeLightning", fetaSpotter:"rifleLock", nosferapabakus:"feedingBite",voidGlitch:"fracture",
    tenmani:"tendrils", lantis:"jawSnap", shadow:"executioner", faeel:"snakeLightning", nightosphere:"hexPuff",
    endme:"claws", archfellanus:"trident", reapfast:"jawSnap", hallucination:"lunge", lalaBubu:"strafingBolt",
    papapoganus:"soulCry",blandromedus:"bloodSpit",oblogabgalus:"headbutt",fearme:"executioner",skorochiyus:"jawSnap",harvester:"soulCry",crufixicatus:"invertedBite"
}

var difficulties = {
    normal:{title:"Normal",health:1,damage:.94,speed:.98,gap:1.04,scale:.22,extra:0,active:0,recovery:.08},
    hard:{title:"Hard",health:1.19,damage:1.25,speed:1.12,gap:.86,scale:.32,extra:1,active:1,recovery:.06},
    insane:{title:"Insane",health:1.40,damage:1.44,speed:1.23,gap:.73,scale:.40,extra:3,active:2,recovery:.04}
}

function difficulty(id) {
    return difficulties[id] || difficulties.normal
}

function front(id) {
    return fronts.find(function(entry) { return entry.id === id }) || fronts[0]
}

var bosses = ["humontafagus","mastafangenbus","gigafinterus","lucifoverus","hasasasa","stinkaturumus","voidGlitch","reapfast"]

function boss(wave) {
    return wave <= 0 || wave % 10 !== 0 ? "" : bosses[(wave / 10 - 1) % bosses.length]
}

function firstWave(type) {
    if (type === "blandromedus")
        return -1
    if (type === "oblogabgalus")
        return 0
    if (type === "saslimigus")
        return firstWave("stinkaturumus")
    if (type === "mystery" || type === "meteor")
        return 11
    if (type === "hallucination")
        return firstWave("lantis")
    const bossIndex = bosses.indexOf(type)
    if (bossIndex >= 0)
        return (bossIndex + 1) * 10
    const intro = introductions.find(function(entry) { return entry.type === type })
    return intro ? intro.wave : 1
}

var enemyRanks = {
    blandromedus:"Nightmare",
    battlestar:"Nightmare", skarabatunus:"Nightmare", mystery:"Nightmare", seraphijus:"Nightmare", mothergalian:"Nightmare",
    capablancamus:"Nightmare", trispiramahedus:"Nightmare", helesepeptium:"Nightmare",
    fetaSpotter:"Nightmare", nosferapabakus:"Nightmare", nightosphere:"Nightmare", endme:"Nightmare",
    archfellanus:"Nightmare", faeel:"Nightmare", fearme:"Nightmare",harvester:"Nightmare",
    silophosus:"Normal", fhantamegus:"Normal", spartalien:"Normal", crawler:"Normal", fizzalien:"Normal", veilskate:"Normal",
    ghorimagous:"Ascended", bergensus:"Normal", gojemarus:"Normal", gendoustagus:"Normal", skorochiyus:"Normal",crufixicatus:"Normal"
}

function tier(type) {
    if (enemyTypes[type]?.role === "boss")
        return "Overlord"
    return enemyRanks[type] || "Ascended"
}

var tierColors = { Normal:"#85b7d1", Ascended:"#f46773", Nightmare:"#b16eea", Overlord:"#ff8d55" }

function weather(wave) {
    if (wave === 5 || wave % 8 === 5)
        return "night"
    if (wave === 8 || wave % 7 === 4 && wave > 8)
        return "rain"
    return "clear"
}

function inferno(wave, seed, rate) {
    if (wave < 9)
        return false
    let roll = (seed ^ Math.imul(wave,0x9e3779b1)) >>> 0
    roll = Math.imul(roll ^ (roll >>> 16),0x45d9f3b) >>> 0
    return ((roll ^ (roll >>> 16)) >>> 0) < .10 * (rate ?? 1) * 4294967296
}

function incursion(wave, seed, rate) {
    return wave >= 18 && !boss(wave) && (wave === 18 || inferno(wave,seed ^ 0xe17a1463,rate))
}

function winter(wave, seed, rate) {
    return wave >= 12 && !boss(wave) && (wave === 12 || inferno(wave,seed ^ 0x710e20fa,rate))
}

function waveSize(wave, preset) {
    const block = Math.floor((Math.max(1,wave)-1)/10)
    const step = (Math.max(1,wave)-1)%10+1
    const count = block === 0 ? 3+Math.floor(step*.55)
        : 5+block*2+Math.floor((step-1)*(.56+Math.min(5,block)*.04)) + Number(!!boss(wave))
    return Math.min(45,count) + difficulty(preset).extra
}

function maxConcurrent(wave, preset) {
    return (wave <= 3 ? 2 : wave <= 10 ? 3 : Math.min(9, 4 + Math.floor((wave - 11) / 8))) + difficulty(preset).active
}

function sampleWeighted(pool, random) {
    let roll = random() * pool.reduce(function(total, entry) { return total + entry.weight }, 0)
    for (const entry of pool) {
        roll -= entry.weight
        if (roll < 0)
            return entry
    }
    return pool[0]
}

function waveBudget(wave, preset) {
    const block = Math.floor((wave-1)/10)
    const step = (wave-1)%10+1
    const risk = preset === "insane" ? 2 : preset === "hard" ? 1 : 0
    const total = waveSize(wave,preset)
    const overlord = Number(!!boss(wave))
    const nightmare = wave < 22 ? 0 : Math.min(Math.floor(total*.39),
        Math.max(1,block-1)+Math.floor((step-1)/4)+risk)
    const ascended = wave < 5 ? 0 : Math.min(Math.floor((total-nightmare-overlord)*.52),
        (block ? block+1 : 1)+Math.floor((step-1)/4)+risk)
    const ranks = {Normal:total-nightmare-ascended-overlord,Ascended:ascended,Nightmare:nightmare,Overlord:overlord}
    const fresh = introductions.find(function(entry) { return entry.wave === wave })
    if (fresh && tier(fresh.type) !== "Normal") {
        const category = tier(fresh.type)
        const minimum = enemyTypes[fresh.type].triad ? 3 : 1
        if (ranks[category] < minimum) {
            ranks.Normal -= minimum-ranks[category]
            ranks[category] = minimum
        }
        if (!introductions.some(function(entry) { return entry.wave < wave && tier(entry.type) === category })) {
            ranks.Normal += ranks[category]-minimum
            ranks[category] = minimum
        }
    }
    return {
        total:total,block:block,step:step,ranks:ranks,
        variety:Math.min(8,1+Math.floor((wave-1)/4)+Number(step>=5)+risk),
        groupSize:wave < 10 ? 3 : 4+risk,
        gap:(wave <= 10 ? 3.25-(wave-1)*.08 : Math.max(1.7,2.63-block*.065-(step-1)*.045))
            * difficulty(preset).gap*arrivalSpacing,
        rest:(wave <= 10 ? 1.8 : 2.7)*difficulty(preset).gap
    }
}

function stageWeather(wave, seed, preset, sky) {
    const rate = Conditions.frequency(preset)
    if (incursion(wave,seed,rate))
        return "incursion"
    const ordinary = weather(wave)
    const landmark = wave === 5 || wave === 8
    if (ordinary === "rain" && (landmark || rate >= 1 || Conditions.roll(wave,seed,0x17c8fa34)<rate))
        return Conditions.rainVariant(wave,seed)
    if (winter(wave,seed,rate))
        return "winter"
    const drifting = Conditions.drifting(wave,seed,rate)
    if (drifting)
        return drifting
    if (wave >= 11 && !boss(wave) && !introductions.some(function(entry) { return entry.wave === wave })
        && Conditions.roll(wave,seed,0x7c193a31) < .067*rate)
        return "meteor"
    if (inferno(wave,seed,rate)) return "inferno"
    if (wave>=3 && Conditions.roll(wave,seed,0x74ce32ab)<.19*rate) return "fog"
    if (wave>=2 && Conditions.roll(wave,seed,0x67821a4c)<.19*rate) return "cloudy"
    if (wave>=4 && !Conditions.isNight(sky || Conditions.waveSky(wave,seed))
        && Conditions.roll(wave,seed,0x624b930d)<.12*rate) return "heatwave"
    return "clear"
}

function planWave(wave, seed, preset, resonance, forcedWeather, forcedLayer) {
    let state = (seed ^ Math.imul(wave,0x9e3779b1) ^ Math.imul(difficulty(preset).extra+1,0x85ebca6b)) >>> 0
    const random = function() {
        state = (Math.imul(state,1664525)+1013904223) >>> 0
        return state/4294967296
    }
    const budget = waveBudget(wave,preset)
    const ranks = Object.assign({},budget.ranks)
    const sky=Conditions.waveSky(wave,seed,forcedWeather)
    const requested=forcedLayer || (forcedWeather && !Conditions.validSky(forcedWeather) ? forcedWeather : stageWeather(wave,seed,preset,sky))
    const condition=requested==="windyCloudy" ? "windy" : requested==="heatwave" && Conditions.isNight(sky) ? "clear" : requested
    const extraWeather=requested==="windyCloudy" ? "cloudy" : forcedLayer ? "" : Conditions.companionWeather(condition,wave,seed)
    const groups = []
    const fresh = introductions.find(function(entry) { return entry.wave === wave })
    const pool = introductions.filter(function(entry) { return entry.wave < wave }).map(function(entry) {
        const origin=enemyTypes[entry.type].origin
        const chosen=resonance==="bass" ? "Void" : resonance==="treble" ? "Space" : resonance==="pulse" ? "Hellborne" : ""
        return Object.assign({},entry,{weight:entry.weight*(origin===chosen ? 1.6 : 1)})
    })
    if (wave > 11)
        pool.push({type:"mystery",front:"down",weight:.16,rare:true})
    const reserved = new Set()
    if (fresh) {
        const count = wave === 1 ? budget.total : enemyTypes[fresh.type].triad ? 3 : 1
        const rank = tier(fresh.type)
        groups.push({type:fresh.type,count:count,front:fresh.front,fresh:true})
        reserved.add(fresh.type)
        if (ranks[rank] < count) {
            ranks.Normal -= count-ranks[rank]
            ranks[rank] = count
        }
        ranks[rank] -= count
    }
    if (sky === "bloodMoon") {
        const rank = ranks.Nightmare > 0 ? "Nightmare" : ranks.Ascended > 0 ? "Ascended" : "Normal"
        ranks[rank] -= 1
        groups.push({type:"blandromedus",count:1,front:"front",late:true})
        reserved.add("blandromedus")
    }
    if ((wave >= 21 && Conditions.roll(wave,seed,0x46e158d3)<.94 || condition === "incursion")
        && !reserved.has("crawler") && ranks.Normal > 0) {
        groups.push({type:"crawler",count:1,front:"down"})
        ranks.Normal -= 1
        reserved.add("crawler")
    }
    const voidKinds=(wave >= 55 ? 3 : wave >= 35 || condition === "incursion" ? 2 : 0)
    while (groups.filter(function(group) {return enemyTypes[group.type].abyss}).length < voidKinds) {
        const available=pool.filter(function(entry) {
            return enemyTypes[entry.type].abyss && !reserved.has(entry.type) && ranks[tier(entry.type)] > 0
        })
        if (!available.length)
            break
        const entry=sampleWeighted(available,random)
        groups.push({type:entry.type,count:1,front:"down"})
        ranks[tier(entry.type)] -= 1
        reserved.add(entry.type)
    }
    if (condition === "meteor" && ranks.Ascended) {
        groups.push({type:"meteor",count:1,front:"up"})
        ranks.Ascended -= 1
    }
    const tierNames = ["Normal","Ascended","Nightmare"]
    const kinds = {}
    const candidates = {}
    for (const name of tierNames) {
        candidates[name] = pool.filter(function(entry) {
            return tier(entry.type) === name && !reserved.has(entry.type)
        })
        kinds[name] = ranks[name] > 0 && candidates[name].length ? 1 : 0
    }
    // Extra species change the composition while each tier keeps its assigned count.
    let variety = Object.values(kinds).reduce(function(sum,value) { return sum+value },groups.length)
    const targetVariety = Math.max(variety,budget.variety)
    while (variety < targetVariety) {
        let choice = ""
        let benefit = -1
        for (const name of tierNames) {
            if (kinds[name] >= Math.min(ranks[name],candidates[name].length))
                continue
            const score = ranks[name]/(kinds[name]+1)+(name === "Nightmare" ? .34 : 0)
            if (score > benefit) {
                benefit = score
                choice = name
            }
        }
        if (!choice)
            break
        kinds[choice] += 1
        variety += 1
    }
    let deep = 0
    const deepLimit = condition === "incursion" ? 6 : wave >= 55 ? 5 : wave >= 35 ? 3 : 2
    for (const group of groups)
        deep += enemyTypes[group.type].abyss ? group.count : 0
    for (const name of tierNames) {
        const count = ranks[name]
        const species = kinds[name]
        for (let index=0; index<species; ++index) {
            const amount = Math.floor(count/species)+Number(index<count%species)
            const available = candidates[name].filter(function(entry) {
                return !reserved.has(entry.type) && (!enemyTypes[entry.type].triad || amount%3 === 0)
            })
            const valid = available.filter(function(entry) {
                return !enemyTypes[entry.type].abyss || deep+amount <= deepLimit
            })
            const possible = valid.length ? valid : available
            const invading = condition === "incursion" && deep < deepLimit
                ? possible.filter(function(entry) { return enemyTypes[entry.type].abyss && deep+amount <= deepLimit }) : []
            const entry = sampleWeighted(invading.length ? invading : possible,random)
            if (!entry)
                continue
            reserved.add(entry.type)
            groups.push({type:entry.type,count:amount,front:entry.front})
            deep += enemyTypes[entry.type].abyss ? amount : 0
        }
    }
    const order = []
    const remaining = groups.map(function(group) { return group.late ? 0 : group.count })
    const opener = groups.findIndex(function(group) { return !group.late && !group.fresh && !enemyTypes[group.type].abyss && tier(group.type) === "Normal" })
    function add(index) {
        const group = groups[index]
        const units = enemyTypes[group.type].triad ? 3 : 1
        order.push(Object.assign({},group,{units:units}))
        remaining[index] -= units
    }
    if (opener >= 0)
        add(opener)
    const firstLook = groups.findIndex(function(group) { return group.fresh })
    if (firstLook >= 0)
        add(firstLook)
    const early = groups.findIndex(function(group) { return enemyTypes[group.type].earlyArrival && remaining[groups.indexOf(group)] > 0 })
    if (early >= 0)
        add(early)
    while (remaining.some(function(count) { return count > 0 })) {
        let next = -1
        let priority = -Infinity
        for (let i=0; i<groups.length; ++i) {
            if (!remaining[i])
                continue
            const previous = order[order.length-1]
            const danger = tier(groups[i].type) === "Nightmare"
            const score = remaining[i]/groups[i].count + random()*.12
                - Number(previous && tier(previous.type) === "Nightmare" && danger)*2
                - Number(previous && previous.type === groups[i].type)*.42
                - (enemyTypes[groups[i].type].abyss ? order.length < budget.total*.45 ? 2.0 : -.35 : 0)
            if (score > priority) {
                priority = score
                next = i
            }
        }
        add(next)
    }
    for (const group of groups.filter(function(entry) { return entry.late }))
        order.splice(Math.min(order.length,Math.ceil(order.length*.82)),0,Object.assign({},group,{units:1}))
    const chosen = []
    let at = .42
    let voidSent = 0
    for (let index=0; index<order.length; ++index) {
        const group = order[index]
        let home = group.front
        if (enemyTypes[group.type].abyss && condition === "incursion") {
            const possible = voidSent++ === 0 ? fronts.filter(function(place) { return place.id !== "down" }) : fronts
            home = possible[Math.floor(random()*possible.length)].id
        } else if (groundFronts.includes(home) && !group.late && !group.fresh && index > 0 && wave > 1)
            home = groundFronts[Math.floor(random()*groundFronts.length)]
        if (index === 1 && wave === 2)
            home = "right"
        if (index === 2 && wave === 2)
            home = "left"
        const arrival={at:at,type:group.type,front:home,lane:index ? Math.round(random()*250-125) : 0,units:group.units}
        chosen.push(arrival)
        at += budget.gap+(index > 0 && (index+1)%budget.groupSize === 0 ? budget.rest : 0)
    }
    const final = boss(wave)
    if (final) {
        groups.push({type:final,count:1,front:final === "hasasasa" ? "up" : enemyTypes[final].abyss ? "down" : "front"})
        chosen.push({ at:at, type:final,units:1,
            front:final === "hasasasa" ? "up" : enemyTypes[final].abyss ? "down" : "front", lane:0 })
    }
    const actualRanks = {Normal:0,Ascended:0,Nightmare:0,Overlord:0}
    for (const group of groups) {
        group.rank = tier(group.type)
        group.origin = enemyTypes[group.type].origin
        actualRanks[group.rank] += group.count
    }
    return {wave:wave,difficulty:preset || "normal",weather:condition,extraWeather:extraWeather,sky:sky,enemyCount:budget.total,
        variety:groups.length,ranks:actualRanks,groups:groups,schedule:chosen,
        concurrent:maxConcurrent(wave,preset),label:wave > 10 && budget.step <= 2 ? "Aftermath" : final ? "Overlord" : budget.step >= 8 ? "Surge" : "Approach"}
}
