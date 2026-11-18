.pragma library

var weapons = {
    blackHole:{ id:"blackHole",title:"Black Hole",category:"Weapon",rarity:"legendary",effect:"pulse",capacity:5,
        damage:11.6,delay:.84,reload:1.91,aim:24,color:"#c892ff",trace:6.5,afterglow:.31,handling:"reload",
        signature:"blackHole",firstOfferWave:26,
        description:"A hit opens a black hole at the impact. It tugs nearby demons inward once per second for three seconds." },
    kestrel:{ id:"kestrel",title:"Kestrel burst carbine",category:"Weapon",rarity:"rare",effect:"burst",capacity:18,
        damage:1.96,delay:.57,reload:1.31,aim:31,color:"#9ddc81",trace:2.7,afterglow:.11,handling:"reload",
        burst:{ count:3, interval:.074 },description:"Each press commits to three timed rounds. Follow a moving target through the burst." },
    deadeye:{ id:"deadeye",title:"Deadeye repeater",category:"Weapon",rarity:"epic",effect:"tracer",capacity:10,
        damage:3.8,delay:.37,reload:1.48,aim:23,color:"#facf80",trace:3.4,afterglow:.15,handling:"reload",
        signature:"hitStreak",crit:.075,
        description:"Higher critical chance. Every connected shot adds ×0.12 damage to the next up to ×2.20. A miss resets the streak." },
    gravhammer:{ id:"gravhammer",title:"Grav hammer",category:"Weapon",rarity:"epic",effect:"melee",capacity:0,
        damage:15.3,delay:.81,reload:.94,aim:82,color:"#dcc78b",trace:6,afterglow:.34,handling:"reload",
        melee:{reach:525,targets:3,trick:"Reverse the grip",boost:1.55},signature:"gravityHammer",element:"stun",elementLevel:1,locked:true,
        description:"A weighty three-target blow with Stun. Reverse your grip with R to load its ranged shockwave." },
    reaperscythe:{ id:"reaperscythe",title:"Reaper scythe",category:"Weapon",rarity:"legendary",effect:"melee",capacity:0,
        damage:10.6,delay:.61,reload:.81,aim:94,color:"#d487b3",trace:6,afterglow:.29,handling:"reload",
        melee:{reach:592,targets:4,trick:"Scythe wheel",boost:1.64},signature:"soulHarvest",locked:true,
        description:"Sweep up to four enemies. A close kill restores 3 health. R spins the shaft to prime a long spectral cut." },
    helltrident:{ id:"helltrident",title:"Demonic trident",category:"Weapon",rarity:"legendary",effect:"pulse",capacity:0,
        damage:10.3,delay:.84,reload:.71,aim:32,color:"#ff6a43",trace:6.8,afterglow:.31,handling:"reload",
        stab:{ damage:14.5,reach:467 },element:"burn",elementLevel:2,signature:"tridentFlame",locked:true,
        description:"Launch burning bolts. R or right click thrusts the fire-tipped prongs into a close enemy." },
    windstaff:{title:"Wind staff",rarity:"epic",color:"#95ffd8",damage:9.8,delay:.91,
        element:"wind",elementLevel:2,staff:{kind:"wind",cost:4,cast:"Gale front"},
        description:"Wind bolts push enemies away. After four attacks, R sends a wide gale down this wallpaper."},
    firestaff:{title:"Fire staff",rarity:"epic",color:"#ff794c",damage:10.1,delay:1.03,
        element:"burn",elementLevel:2,staff:{kind:"burn",cost:4,cast:"Falling star"},
        description:"Fire bolts apply Burn. After four attacks, R drops a blazing meteor on your aim."},
    icestaff:{title:"Ice staff",rarity:"epic",color:"#a9e9ff",damage:8.8,delay:.99,
        element:"freeze",elementLevel:2,staff:{kind:"freeze",cost:4,cast:"Glacier bloom"},
        description:"Frost bolts slow enemies. After four attacks, R grows a field of ice that freezes a group."},
    thunderstaff:{title:"Thunder staff",rarity:"legendary",color:"#e8c3ff",damage:10.4,delay:1.13,
        element:"electric",elementLevel:2,staff:{kind:"electric",cost:5,cast:"Thunderfall"},
        description:"Heavy Electric bolts bounce between nearby enemies. After five attacks, R calls a lightning strike at your aim."},
    earthstaff:{title:"Earth staff",rarity:"epic",color:"#e4b17a",damage:11.8,delay:1.16,
        element:"stun",elementLevel:1,staff:{kind:"stun",cost:4,cast:"Fault line"},
        description:"Heavy stone bolts Stun targets. After four attacks, R sends a wide tremor through the enemies ahead."},
    avatarstaff:{title:"Avatar's staff",rarity:"legendary",color:"#ffc8ad",damage:9.9,delay:.79,
        elementLevel:2,staff:{kind:"avatar",cost:5,cast:"Convergence"},
        description:"Each hit draws a random element. After five attacks, R calls a stronger spell from the same six-element pool."},
    abyssstaff:{title:"Abyss staff",rarity:"legendary",color:"#ba8dff",damage:11.3,delay:.95,
        element:"weaken",elementLevel:2,staff:{kind:"weaken",cost:4,cast:"Null eclipse"},locked:true,
        description:"Weaken enemies with void bolts. After four attacks, R unfolds an eclipse that weakens a group and advances a Void seal."},
    aurorastaff:{title:"Aurora staff",rarity:"legendary",color:"#a3ffdc",damage:11.7,delay:1.02,
        element:"electric",elementLevel:1,staff:{kind:"aurora",cost:4,cast:"Aurora wall"},locked:true,
        description:"Arc bolts chain through groups. After four attacks, R detonates green-white lightning and raises a one-charge barrier."}
}

for (const id of Object.keys(weapons)) {
    const spec = weapons[id]
    if (spec.staff) {
        Object.assign(spec, { id:id, category:"Weapon", effect:"pulse", capacity:0, reload:0, aim:31, trace:6.2,
            afterglow:.31, handling:"staffCharge", signature:spec.staff.kind })
    }
}

var actives = {
    eventFold:{ id:"eventFold",title:"Event fold",category:"Active",rarity:"epic",cooldown:26,
        description:"Open a stronger three-second gravity well at the demon under your aim or the nearest demon on this wallpaper." },
    riposte:{id:"riposte",title:"Riposte",category:"Active",rarity:"rare",cooldown:19,
        description:"With a melee weapon, parry the next hit within 1.1 seconds and counter a nearby attacker."},
    bladesweep:{id:"bladesweep",title:"Blade orbit",category:"Active",rarity:"epic",cooldown:24,
        description:"Sweep every nearby enemy on this wallpaper with your equipped melee weapon."},
    salvo:{id:"salvo",title:"Breach rounds",category:"Active",rarity:"epic",cooldown:25,
        description:"The next three magazine shots deal 65% more damage to barriers."},
    lockfeed:{id:"lockfeed",title:"Lock feed",category:"Active",rarity:"rare",cooldown:22,
        description:"For four seconds the first connected round of each burst refunds one round."},
    runefill:{id:"runefill",title:"Rune fill",category:"Active",rarity:"epic",cooldown:28,
        description:"Add two attacks' worth of charge to your current staff spell."},
    guststep:{id:"guststep",title:"Gust step",category:"Active",rarity:"rare",cooldown:21,element:"wind",elementLevel:1,
        description:"Knock back threats on this wallpaper and speed up your turn for four seconds."},
    emberharvest:{id:"emberharvest",title:"Ember harvest",category:"Active",rarity:"legendary",cooldown:30,
        description:"Draw Burn from each burning target here to damage its neighbours with a flash."},
    axeHook:{id:"axeHook",title:"Axe hook",category:"Active",rarity:"rare",cooldown:23,locked:true,
        description:"Pull the enemy under your aim closer and interrupt its wind-up. Useful for melee range."},
    runesurge:{id:"runesurge",title:"Rune surge",category:"Active",rarity:"legendary",cooldown:34,locked:true,
        description:"Consume your staff's current charge to damage this wallpaper. Deal more damage with every charge spent."}
}

var passives = {
    tidalAnchor:{ id:"tidalAnchor",title:"Tidal anchor",category:"Passive",rarity:"epic",
        description:"Widen black holes and strengthen their pull. Wind also pushes targets farther." },
    hone:{id:"hone",title:"Honed grip",category:"Passive",rarity:"common",description:"Melee tricks complete 10% faster per rank."},
    longguard:{id:"longguard",title:"Long guard",category:"Passive",rarity:"rare",description:"Extend melee reach by 38 world units per rank."},
    bloodhone:{id:"bloodhone",title:"Blood hone",category:"Passive",rarity:"epic",description:"A melee kill strengthens your next melee attack."},
    condenser:{id:"condenser",title:"Rune condenser",category:"Passive",rarity:"rare",description:"A fully charged staff deals extra damage with normal attacks while you hold its spell."},
    runicgrip:{id:"runicgrip",title:"Runic grip",category:"Passive",rarity:"epic",description:"A normal staff kill grants an additional spell charge."},
    burstanchor:{id:"burstanchor",title:"Burst anchor",category:"Passive",rarity:"rare",description:"The last round of a timed burst deals extra damage."},
    returnSpring:{id:"returnSpring",title:"Return spring",category:"Passive",rarity:"rare",description:"Hitting with a Tomahawk shortens the draw time for the next axe."},
    followThrough:{id:"followThrough",title:"Follow through",category:"Passive",rarity:"epic",locked:true,
        description:"Finishing a foe with a timed burst shortens the wait before your next burst."},
    secondWind:{id:"secondWind",title:"Second wind",category:"Passive",rarity:"epic",locked:true,
        description:"Recover a little HP after a successful dodge."},
    redHunger:{id:"redHunger",title:"Red hunger",category:"Passive",rarity:"epic",
        description:"Weapon damage rises by up to 32% and reload time drops by up to 40% as your health percentage falls."},
    glassCannon:{id:"glassCannon",title:"Glass cannon",category:"Passive",rarity:"legendary",
        description:"Deal 48% more damage and take 35% more damage. Upgrading raises both modifiers."},
    deathMint:{id:"deathMint",title:"Death mint",category:"Passive",rarity:"legendary",
        description:"During a wave, shoot the skull coins that appear across the five wallpapers. Every fifth coin executes a random living enemy."},
    orbitWard:{id:"orbitWard",title:"Orbit guard",category:"Passive",rarity:"rare",
        description:"A small shield sweeps your view. Attacks lined up behind it deal 30% less damage while it passes."}
}

var perks = {
    tidalAnchor:{gravityRange:48,text:"Black hole radius +48"},
    hone:{cycle:.038,text:"Attack recovery −3.8%"}, longguard:{stabReach:38,text:"Bayonet reach +38"},
    bloodhone:{health:7,text:"Maximum health +7"}, condenser:{magicForce:1.1,text:"Staff spell damage +1.1"},
    runicgrip:{magicForce:1.3,text:"Staff spell damage +1.3"}, burstanchor:{reload:.05,text:"Reload time −5%"},
    returnSpring:{cycle:.05,text:"Attack recovery −5%"}, followThrough:{cycle:.05,text:"Attack recovery −5%"},
    secondWind:{evadeWindow:.08,text:"Turn dodge lasts 0.08s longer"},
    redHunger:{cycle:.05,text:"Attack recovery −5%"}, glassCannon:{cycle:.047,text:"Attack recovery −4.7%"},
    deathMint:{coinTime:1.45,text:"Death coins last 1.45s longer"}, orbitWard:{guardWidth:.019,text:"Orbit guard covers a wider angle"}
}

var kits = [
    { key:"blackHoleKit",weapon:"blackHole",active:"eventFold",passive:"tidalAnchor",title:"Event horizon kit",
        bonus:"Your black holes pull another 21 units each second." },
    {key:"burstCrew",weapon:"kestrel",active:"lockfeed",passive:"burstanchor",title:"Burst crew kit",bonus:"The Kestrel's final burst round deals 18% more damage."},
    {key:"deadeyeSet",weapon:"deadeye",active:"salvo",passive:"caliber",title:"Deadeye kit",bonus:"Breach rounds load one additional shot."},
    {key:"gravKit",weapon:"gravhammer",active:"bladesweep",passive:"longguard",title:"Grav kit",bonus:"Blade orbit reaches another 90 units."},
    {key:"reaperKit",weapon:"reaperscythe",active:"riposte",passive:"bloodhone",title:"Reaper kit",bonus:"Riposte grants a short melee damage bonus."},
    {key:"windKit",weapon:"windstaff",active:"guststep",passive:"condenser",title:"North wind kit",bonus:"Wind effects push 55 units farther."},
    {key:"fireKit",weapon:"firestaff",active:"emberharvest",passive:"cinder",title:"Falling star kit",bonus:"Falling star's blast radius grows by 60 units."},
    {key:"iceKit",weapon:"icestaff",active:"whiteout",passive:"frostBite",title:"Glacier kit",bonus:"Glacier bloom freezes targets for another 0.5 seconds."},
    {key:"thunderKit",weapon:"thunderstaff",active:"stormcall",passive:"runicgrip",title:"Thunderfall kit",bonus:"Thunderfall jumps an extra 45 units."},
    {key:"earthKit",weapon:"earthstaff",active:"runefill",passive:"wardBattery",title:"Fault line kit",bonus:"Rune fill grants another charge."},
    {key:"avatarKit",weapon:"avatarstaff",active:"runesurge",passive:"ashenChar",title:"Convergence kit",bonus:"Rune surge deals another 3 damage."},
    {key:"abyssKit",weapon:"abyssstaff",active:"voidaegis",passive:"voidliner",title:"Eclipse kit",bonus:"Null eclipse adds another 12% to Void sealing."},
    {key:"auroraKit",weapon:"aurorastaff",active:"sidestep",passive:"secondWind",title:"Aurora kit",bonus:"Aurora wall's barrier lasts another second."},
    {key:"hookKit",weapon:"tomahawk",active:"axeHook",passive:"returnSpring",title:"Axe hook kit",bonus:"Axe hook pulls foes another 100 units."},
    {key:"quickSteel",weapon:"katana",active:"riposte",passive:"hone",title:"Quick steel kit",bonus:"Katana combo timing is 0.06 seconds more forgiving."},
    {key:"leadKit",weapon:"arc",active:"salvo",passive:"followThrough",title:"Lead kit",bonus:"Breach rounds deal 15% more to barriers."},
    {key:"redHungerKit",weapon:"hellbore",active:"reversal",passive:"redHunger",title:"Blood line kit",bonus:"Red hunger's reload bonus is 10% stronger."},
    {key:"glassKit",weapon:"deadeye",active:"sidestep",passive:"glassCannon",title:"Glass eye kit",bonus:"Sidestep lasts another 0.12 seconds."},
    {key:"mintKit",weapon:"kestrel",active:"riposte",passive:"deathMint",title:"Death mint kit",bonus:"Coins remain shootable for two extra seconds."},
    {key:"orbitKit",weapon:"mechasword",active:"ward",passive:"orbitWard",title:"Orbit kit",bonus:"The guard reduces an extra 6% of lined-up damage."},
    {key:"tridentKit",weapon:"helltrident",active:"immolate",passive:"cinder",title:"Fallen angel kit",bonus:"The trident's close thrust reaches 65 units farther."}
]
