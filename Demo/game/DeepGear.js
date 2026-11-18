.pragma library

var weapons = {
    breakerGlaive:{ title:"Breaker glaive",rarity:"epic",art:"breakerGlaive",effect:"melee",capacity:0,
        damage:12.6,delay:.68,reload:.83,aim:80,color:"#a8efe9",trace:5.4,afterglow:.29,knockback:2,handling:"reload",
        melee:{reach:526,targets:3,trick:"Reverse the glaive",boost:1.57},
        description:"A long steel blade that cleaves three targets and pushes them with Knockback II. R primes a charged lunge." },
    breakwater:{ title:"Breakwater .90",rarity:"epic",art:"breakwater",effect:"tracer",capacity:4,
        damage:14.2,delay:1.13,reload:1.9,aim:18,color:"#e6d8ae",trace:5.4,afterglow:.34,knockback:3,handling:"reload",
        scopeZoom:3.6,crit:.12,description:"A heavy long-range sniper with a ×3.6 scope. Its high-calibre round hits with Knockback III." },
    nightInk:{ title:"Night Ink",rarity:"epic",art:"nightInk",effect:"pulse",capacity:10,
        damage:5.0,delay:.39,reload:1.46,aim:25,color:"#a382db",trace:4.2,afterglow:.23,element:"blind",elementLevel:2,
        description:"A dense black projectile with a violet rim. Hits blind demons, making them lose their direction while the dose lasts." },
    echosix:{ title:"Echo revolver",rarity:"rare",art:"echosix",effect:"ballistic",capacity:6,
        damage:4.25,delay:.42,reload:1.39,aim:25,color:"#b2c9e1",trace:3.5,afterglow:.17,element:"blind",elementLevel:1,
        description:"A six-shot revolver that applies light Blindness, throwing targets off course." },
    riftScatter:{ title:"Rift scattergun",rarity:"rare",art:"riftScatter",effect:"spread",capacity:5,
        damage:1.55,delay:.58,reload:1.43,aim:49,color:"#a2b7b8",trace:3,afterglow:.22,knockback:1,handling:"capacity",
        spread:[[0,0],[-.021,.022],[.021,.022],[-.032,-.014],[.032,-.014]],
        description:"Five pellets spread wide before striking. One hit per target is enough to push it with Knockback I." },
    siltCarbine:{ title:"Silt carbine",rarity:"epic",art:"siltCarbine",effect:"burst",capacity:18,
        damage:2.65,delay:.52,reload:1.63,aim:29,color:"#98dfac",trace:3.4,afterglow:.18,
        element:"weaken",elementLevel:1,burst:{count:3,interval:.086},description:"Three timed sea-green tracers Weaken on contact." },
    rimeRelay:{ title:"Rime Relay",rarity:"epic",art:"rimeRelay",effect:"pulse",capacity:8,
        damage:6.5,delay:.55,reload:1.52,aim:23,color:"#a0daff",trace:4.4,afterglow:.24,
        signature:"rimeRelay",element:"freeze",elementLevel:2,
        description:"Hit a frozen enemy to throw ice shards into up to four neighbours. The shards deal damage and apply Frost." },
    whiteoutCoil:{ title:"Whiteout Coil",rarity:"legendary",art:"whiteoutCoil",effect:"laser",capacity:0,
        damage:1.82,delay:.159,reload:0,aim:21,color:"#ccf8ff",trace:7.2,afterglow:.16,penetration:2,handling:"cooldown",
        signature:"deepFreeze",element:"freeze",elementLevel:2,sustain:{limit:2.95,cooldown:1.94},
        description:"Hold a narrow Frost beam. Six continuous hits on one enemy lock it in solid ice for two seconds." },
    fearScythe:{title:"Fearme's Harvest",rarity:"legendary",locked:true,art:"fearScythe",effect:"melee",capacity:0,
        damage:16.8,delay:.87,reload:1.27,aim:98,color:"#ed82c0",trace:6,afterglow:.45,signature:"harvest",
        melee:{reach:578,targets:5,trick:"Wheel the harvest blade",boost:1.63},
        description:"Sweep a wide Void blade across up to five foes. Each kill with this scythe adds 1.8% damage to it for the wave, up to 27%."},
    jesterScatter:{title:"Jester's Verdict",rarity:"epic",art:"jesterScatter",effect:"spread",capacity:6,
        damage:2.16,delay:.62,reload:1.65,aim:47,color:"#ff91d9",trace:4.3,afterglow:.28,signature:"jesterDeck",
        spread:[[0,0],[-.024,.018],[.024,.018],[-.028,-.021],[.028,-.021]],
        description:"A rainbow scattergun. Each shot draws a different status from its shuffled six-colour deck before the deck reshuffles. All its pellets carry that dose."}
}

var actives = {
    riftWeld:{ title:"Rift weld",rarity:"epic",cooldown:33,
        description:"While looking into the Abyss, advance the rift seal by 27% and knock back nearby Void creatures." },
    blackWake:{ title:"Black wake",rarity:"rare",cooldown:23,element:"blind",elementLevel:2,
        description:"Release a wave of ink that damages and blinds up to four foes in this view." },
    undertow:{ title:"Undertow",rarity:"legendary",cooldown:34,knockback:3,
        description:"Force every materialised enemy on your wallpaper back with Knockback III and interrupt wind-ups." },
    breakLamp:{ title:"Snuff the lure",rarity:"rare",cooldown:28,
        description:"Extinguish every active Lantis lamp on this wallpaper for eight seconds." },
    quietWater:{ title:"Quiet water",rarity:"epic",cooldown:30,
        description:"Clear Blindness and delay attacks and wind-ups on your current wallpaper." },
    brineFlare:{ title:"Brine flare",rarity:"epic",cooldown:27,element:"burn",elementLevel:2,
        description:"Launch a flare that damages every Void foe on your wallpaper and sets vulnerable targets on fire." },
    iceBloom:{ title:"Ice bloom",rarity:"epic",cooldown:27,element:"freeze",elementLevel:1,
        description:"Rapidly freeze up to three nearby enemies for two seconds. Targets with Frost immunity resist it." },
    thawCoil:{ title:"Thaw coil",rarity:"rare",cooldown:21,
        description:"Clear your current Frost dose and shorten your weapon's recovery." },
    boneShatter:{title:"Bone shatter",rarity:"epic",cooldown:30,
        description:"For eight seconds, add 24 percentage points to critical chance and 0.52 to the critical multiplier."},
    colourSpill:{title:"Colour spill",rarity:"rare",cooldown:26,
        description:"Damage the nearest three demons on this wallpaper and deal a different elemental status to each."}
}

var passiveRows = [
    ["edgeReturn","Edge return","epic","Time a melee strike in the last 0.18 seconds of a projectile's flight to send it back at its attacker.",
        "returnWindow",.035,"Melee return window +0.035s"],
    ["foilGuard","Mirror timing","epic","Raise the field shield just before a projectile lands to return it to its attacker.",
        "shieldParryWindow",.045,"Shield return window +0.045s"],
    ["downwind","Downwind","rare","Increase the knockback level of attacks that already push by one, up to level III.",
        "pushDistance",28,"Knockback distance +28"],
    ["nightFilter","Night filter","rare","Shorten incoming Blindness and soften its edge darkening.",
        "blindResistance",.12,"Shorten Blindness by another 12%"],
    ["seamAnchor","Seam anchor","epic","Work on the Abyss seal faster. Each rank also improves the force of Knockback.",
        "sealSpeed",.13,"Seal speed +13%"],
    ["brinePlate","Brine plate","rare","Take less damage from Void creatures and their projectiles.",
        "armor",.025,"Damage taken −2.5%"],
    ["sleetLining","Sleet lining","rare","Shorten Frost doses and recover from being frozen sooner.",
        "frostResistance",.12,"Shorten Frost by another 12%"],
    ["iceSight","Ice sight","epic","Deal more damage to a frozen target.",
        "coldDamage",.08,"Damage to frozen foes +8%"],
    ["soulReaper","Soul reaper","epic","Each kill grants 1.2% outgoing damage for the wave, up to 18%.",
        "soulStrength",.004,"Each soul adds another 0.4% damage"],
    ["parry","Parry","epic","Raise the field shield within 0.20 seconds of a hit to take 3.8 seconds off its next cooldown.",
        "parryCredit",.65,"Timed parry cuts another 0.65 seconds from recovery"]
]
var passives = {}
var perks = {}
for (const row of passiveRows) {
    const [id,title,rarity,description,stat,value,text] = row
    passives[id] = {id:id,title:title,category:"Passive",rarity:rarity,description:description}
    perks[id] = {[stat]:value,text:text}
}
for (const id of Object.keys(weapons)) {
    const spec = weapons[id]
    Object.assign(spec,{id:id,category:"Weapon",handling:spec.handling || "reload"})
}
for (const id of Object.keys(actives))
    Object.assign(actives[id],{id:id,category:"Active"})

var kits = [
    {key:"breakerKit",title:"Breaker kit",weapon:"breakerGlaive",active:"undertow",passive:"edgeReturn",
        stat:"pushDistance",value:45,bonus:"All Knockback pushes another 45 units."},
    {key:"breakwaterKit",title:"Breakwater kit",weapon:"breakwater",active:"brineFlare",passive:"foilGuard",
        stat:"crit",value:.07,scope:"breakwater",bonus:"Breakwater gains another seven percentage points of critical chance."},
    {key:"inkKit",title:"Black ink kit",weapon:"nightInk",active:"blackWake",passive:"nightFilter",
        stat:"blindDuration",value:.80,bonus:"Blindness you inflict lasts another 0.8 seconds."},
    {key:"echoKit",title:"Echo kit",weapon:"echosix",active:"breakLamp",passive:"brinePlate",
        stat:"damage",value:.10,scope:"echosix",bonus:"Echo revolver deals another 10% damage."},
    {key:"riftScatterKit",title:"Rift watch kit",weapon:"riftScatter",active:"riftWeld",passive:"seamAnchor",
        stat:"sealSpeed",value:.19,bonus:"Work on the Abyss seal another 19% faster."},
    {key:"siltKit",title:"Silt wake kit",weapon:"siltCarbine",active:"quietWater",passive:"downwind",
        stat:"active",value:.13,scope:"quietWater",bonus:"Quiet water recovers another 13% sooner."},
    {key:"relayFrostKit",title:"Rime relay kit",weapon:"rimeRelay",active:"iceBloom",passive:"sleetLining",
        stat:"shardRadius",value:60,bonus:"Rime Relay's ice shards travel another 60 units."},
    {key:"whiteoutCoilKit",title:"Whiteout coil kit",weapon:"whiteoutCoil",active:"thawCoil",passive:"iceSight",
        stat:"coldDamage",value:.12,bonus:"Your attacks deal another 12% damage to frozen foes."},
    {key:"harvestKit",title:"Harvest kit",weapon:"fearScythe",active:"boneShatter",passive:"soulReaper",
        stat:"crit",value:.06,scope:"fearScythe",bonus:"Fearme's Harvest gains another six percentage points of critical chance."},
    {key:"jesterVerdictKit",title:"Jester's verdict kit",weapon:"jesterScatter",active:"colourSpill",passive:"parry",
        stat:"parryCredit",value:.65,bonus:"Timed parries remove another 0.65 seconds of shield recovery."}
]
