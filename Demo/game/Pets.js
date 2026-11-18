.pragma library

var uniqueColor = "#71ecd3"

var pets = [
    { id:"crow", title:"Cinder Crow", form:"crow", skin:"#343244", accent:"#ff9a62", damage:1.0, interval:4.3, travel:1.32, power:"mark", duty:25, rest:9,
        description:"Marks a foe for your next shot to deal extra damage. Steady damage and flight." },
    { id:"wasp", title:"Rook Wasp", form:"wasp", skin:"#475466", accent:"#ffce68", damage:.92, interval:4.2, travel:1.16, power:"break", duty:22, rest:8,
        description:"Its stinger triples damage against a barrier. It deals less to bare targets." },
    { id:"bat", title:"Mica Bat", form:"bat", skin:"#6e475d", accent:"#ffabc1", damage:.92, interval:4.5, travel:.94, power:"delay", duty:25, rest:7,
        description:"Its screech delays an enemy's next attack. Crosses wallpapers quickly." },
    { id:"owl", title:"Brass Owl", form:"owl", skin:"#94764d", accent:"#ffe6a0", damage:1.45, interval:5.5, travel:1.48, power:"heal", duty:19, rest:10,
        description:"Restores 2 health whenever it lands the finishing hit. Slow, heavy strikes." },
    { id:"moth", title:"Boreal Moth", form:"moth", skin:"#547e93", accent:"#a7f1fd", damage:.80, interval:4.5, travel:1.25, power:"seal", duty:28, rest:9,
        description:"Adds progress on Void seals. Weak in an ordinary fight." },
    { id:"drake", title:"Flux Drake", form:"drake", skin:"#66415e", accent:"#ed88ff", damage:.80, interval:4.65, travel:1.42, power:"splash", duty:20, rest:11,
        description:"Breathes a small blast around its target. Strong against a cluster." },
    { id:"kite", title:"Kite Drone", form:"kite", skin:"#45665e", accent:"#a0ffbf", damage:.72, interval:3.5, travel:.65, power:"rush", duty:22, rest:6,
        description:"The fastest traveller, with quick low-damage passes between wallpapers." },
    { id:"ray", title:"Soot Ray", form:"ray", skin:"#315d77", accent:"#78baff", damage:1.05, interval:4.4, travel:1.26, power:"slow", duty:25, rest:9,
        description:"Slows the enemy it strikes so you have more time to aim." },
    { id:"finch", title:"Nacre Finch", form:"finch", skin:"#697d76", accent:"#d3ffca", damage:.70, interval:4.7, travel:1.08, power:"ammo", duty:28, rest:7,
        description:"Sometimes tops up one round when it lands a hit. Light damage per strike." },
    { id:"beetle", title:"Cobalt Beetle", form:"beetle", skin:"#3a4b80", accent:"#9db6ff", damage:.83, interval:4.3, travel:1.27, power:"guard", duty:21, rest:10,
        description:"Can intercept an alien bolt on its patrol route instead of attacking." },
    { id:"archive", title:"Archive Raven", form:"crow", skin:"#41405e", accent:"#9af1cd", damage:1.20, interval:5.5, travel:1.18, power:"mark", duty:22, rest:9,
        description:"Its powerful mark lasts longer. It takes longer to strike again.", locked:true },
    { id:"wyvern", title:"Howl Wyvern", form:"drake", skin:"#8a5149", accent:"#ffce85", damage:.90, interval:5.25, travel:.87, power:"splash", duty:18, rest:8,
        description:"Sweeps in rapidly and clips a wider group. Less frequent attacks.", locked:true },
    { id:"firefly", title:"Glass Firefly", form:"moth", skin:"#636290", accent:"#fff599", damage:1.12, interval:4.65, travel:1.54, power:"seal", duty:23, rest:10,
        description:"Leaves a stronger trace on Void seals. Spends longer flying between fronts.", locked:true },
    { id:"warden", title:"Warden Fox", form:"fox", skin:"#836147", accent:"#ffcf96", damage:1.27, interval:5.0, travel:1.55, power:"guard", duty:20, rest:10,
        description:"Bites harder and screens incoming bolts. Slow to reach a new wallpaper.", locked:true },
    { id:"brain", title:"Cortex Crawler", form:"brain", skin:"#844e69", accent:"#ffd1ea", damage:1.18, interval:4.6, travel:1.54,
        power:"mind", duty:18, rest:10, crawl:true, description:"A little brain on spider legs. Its bite weakens foes, then it needs a long rest.", locked:true },
    { id:"chicken", title:"Wendy", form:"chicken", skin:"#ae8c66", accent:"#ff6a50", damage:.95, interval:4.05, travel:1.33,
        power:"peck", duty:20, rest:8, description:"Dives beak-first with a forceful peck. It hits harder against enemies close to you." },
    { id:"fairy", title:"Thorn Fairy", form:"fairy", skin:"#436079", accent:"#90e8be", damage:.72, interval:4.40, travel:1.13,
        power:"mend", duty:23, rest:9, description:"A winged fairy mends 2 HP every third strike. Trades damage for steady healing." },
    { id:"chibi", title:"Rose Sprite", form:"chibi", skin:"#613751", accent:"#ff83be", damage:.93, interval:4.45, travel:1.34,
        power:"spark", duty:21, rest:9, description:"A pink-haired flying chibi. Every third attack sends a small Electric jump." },
    { id:"minishade", title:"Mini Shadow", form:"minishade", skin:"#21182e", accent:"#cba2ff", damage:1.68, interval:4.45,
        travel:1.07, power:"blind", duty:21, rest:11, description:"Sends bursts of ink that blind targets and make them drift off course.",locked:true },
    {id:"jacko",title:"Jacko",form:"jacko",skin:"#b55322",accent:"#95ef5b",damage:1.21,interval:4.9,travel:1.22,
        power:"greenfire",duty:20,rest:10.5,tarot:true,
        description:"The Devil card lends you a second companion. Jacko attacks with green fire. His charged breath scorches the target and nearby enemies."}
]

var attackGestures = {
    crow:[-32,13,23,30], wasp:[27,-6,7,43], bat:[-14,26,-42,12], owl:[53,0,18,20],
    moth:[-16,45,-29,9], drake:[37,-21,9,33], kite:[-47,63,-32,49], ray:[20,36,55,8],
    finch:[-31,-45,35,24], beetle:[13,85,-11,14], archive:[-56,17,-31,22], wyvern:[34,50,-20,37],
    firefly:[-9,-70,23,21], warden:[39,-44,25,34], brain:[-22,11,7,40], chicken:[76,-12,18,34],
    fairy:[-27,77,56,13], chibi:[-31,-49,-46,27], minishade:[51,-28,32,37], jacko:[-28,37,-18,25]
}

var secondary = {
    crow:{title:"Cinder dive",every:3,charge:2.2,kind:"burn",power:1.48,description:"A hard dive with Burn I and a longer mark."},
    owl:{title:"Brass toll",every:2,charge:2.8,kind:"heal",power:1.4,description:"A heavy strike that restores 3 HP."},
    drake:{title:"Flux breath",every:3,charge:2.45,kind:"burn",power:1.38,description:"A wider breath attack with Burn I."},
    beetle:{title:"Aegis discharge",every:3,charge:2.3,kind:"intercept",power:1.32,description:"Breaks up to two hostile projectiles on its wallpaper before striking."},
    jacko:{title:"Witchfire volley",every:3,charge:2.65,kind:"burn",power:1.38,description:"A spread of green fire that scorches a small cluster with Burn I."},
    chicken:{title:"Wind-up peck",every:3,charge:2.1,kind:"knockback",power:1.63,description:"A stronger peck that knocks its target back."}
}

function attackPose(id, remaining) {
    const shape = attackGestures[id] || attackGestures.crow
    if (!remaining)
        return [0,0,0,0]
    const phase = Math.sin(Math.PI * Math.max(0, 1 - remaining / .45))
    return shape.map(function(value) { return value * phase })
}

function available(unlocks) {
    return pets.filter(function(pet) { return !pet.tarot && (!pet.locked || unlocks.includes(pet.id)) })
}

function draft(unlocks, random, previous) {
    const pool = available(unlocks).filter(function(pet) { return !(previous || []).includes(pet.id) })
    const choices = []
    while (choices.length < 3)
        choices.push(pool.splice(Math.floor(random() * pool.length), 1)[0].id)
    return choices
}

function spec(id) {
    return pets.find(function(pet) { return pet.id === id }) || pets[0]
}

function trained(helper, level) {
    return { damageScale:1 + level*.32, interval:helper.interval*(1-level*.12),
        duty:helper.duty + level*3.8, rest:Math.max(3,helper.rest-level*1.25), travel:helper.travel*(1-level*.09) }
}

function flight(pet, clock, animate) {
    const resting=pet.resting>0
    const fold=resting ? Math.min(1,Math.max(0,((pet.restLength || pet.stats.rest)-pet.resting)*3.1+.12)) : 0
    const helper=spec(pet.id)
    const phase=animate ? clock / (helper.travel + .25) : 0
    const crawl=helper.crawl
    const steering=pet.travel>0 ? pet.heading : Math.sin(phase*1.8)
    return {
        lane:pet.lane+(resting || crawl || !animate ? 0 : Math.cos(phase*1.9)*13),
        elevation:pet.elevation-fold*(crawl ? 9 : 49)+Math.sin(phase*(resting ? 3.6 : 4.7))*(resting ? 3 : crawl ? 4 : 11),
        depth:pet.depth+(resting ? 19*fold : animate ? Math.cos(phase*2.3)*9 : 0),
        pitch:fold*18+Math.sin(phase*3.2)*(resting ? 1 : crawl ? 3 : 8),
        yaw:resting ? 0 : steering*(pet.travel>0 ? 23 : 12),
        bank:resting ? -7*fold : steering*(pet.travel>0 ? 29 : 15)
    }
}

function deploy(id, level) {
    const helper = spec(id)
    const rank = level || 0
    const stats = trained(helper,rank)
    return { id:id, level:rank, stats:stats, front:"front", lane:-155, elevation:helper.crawl ? -126 : 75, depth:720,
        stamina:stats.duty, resting:0, restLength:0, heading:-1, travel:0, destination:"", next:4.0, flash:0,
        chargeLeft:0, chargeLength:0, chargePending:false, chargedFlash:0, ordinaryStrikes:0,
        targetId: 0, strikes: 0, aimLane: 0, aimElevation: 0, aimDepth: 0 }
}
