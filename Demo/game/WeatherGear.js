.pragma library

var weapons={
    wickPistol:{title:"Wick pistol",rarity:"common",art:"pistol",frame:141,effect:"ballistic",capacity:8,
        damage:2.55,delay:.33,reload:1.17,aim:26,color:"#ffba84",trace:2.2,afterglow:.14,handling:"reload",
        affinity:"clear",affinityBonus:.12,description:"A small burnished pistol. Its dry powder deals 12% more damage without an active weather overlay."},
    stormWicket:{title:"Storm Wicket",rarity:"epic",art:"coil",frame:142,effect:"pulse",capacity:9,
        damage:4.05,delay:.40,reload:1.44,aim:31,color:"#c8b3ff",trace:4.6,afterglow:.18,handling:"reload",
        element:"electric",elementLevel:1,affinity:"weather",affinityBonus:.16,
        description:"An Electric I pulse rifle with a violet spark gap. It hits 16% harder during an active weather overlay."},
    zenithThroat:{title:"Zenith Throat",rarity:"legendary",art:"sunlance",frame:143,effect:"beam",capacity:4,damage:11.6,delay:.79,
        reload:2.60,aim:17,color:"#ffd348",trace:9.1,afterglow:.29,handling:"reload",penetration:3,pierceRetain:.86,element:"burn",elementLevel:1,
        affinity:"daytime",affinityBonus:.38,description:"A sunbeam punches through three targets and leaves Burn I. Bright daytime gives it 38% more impact."},
    barometer:{title:"Barometer",rarity:"rare",art:"carbine",frame:144,effect:"burst",capacity:15,
        damage:2.12,delay:.64,reload:1.44,burst:{count:3,interval:.09},aim:28,color:"#a9efd3",trace:3.2,afterglow:.14,handling:"capacity",
        affinity:"weather",affinityBonus:.18,description:"A three-round lever burst that hits 18% harder during active weather. Long enough between salvos to reset your aim."},
    crepuscule:{title:"Crepuscule",rarity:"epic",art:"rail",frame:145,effect:"beam",capacity:5,
        damage:7.6,delay:.61,reload:2.04,aim:21,color:"#ed8c8c",trace:6,afterglow:.23,handling:"reload",penetration:2,pierceRetain:.82,
        affinity:"twilight",affinityBonus:.28,description:"A dual-piercing needle rifle. Its twilight chamber deals 28% more damage in sunset and sunrise."},
    moonwake:{title:"Moonwake",rarity:"legendary",art:"mooncoil",frame:146,effect:"laser",capacity:0,
        damage:5.2,delay:.31,reload:0,sustain:{limit:3.2,cooldown:2.65},aim:20,color:"#a5a9ff",trace:6.7,afterglow:.21,
        penetration:3,pierceRetain:.84,handling:"cooldown",element:"weaken",elementLevel:1,affinity:"night",affinityBonus:.34,
        description:"A continuous lunar beam with Weaken I and three-target penetration. It runs hotter at Night and Blood Moon, gaining 34% impact."}
}

var actives={
    openSign:{title:"Open sign",rarity:"common",environment:"clear",cooldown:19,form:"clearRound",value:3,
        description:"Three rounds for your equipped gun during clear weather. If it is reloading, this also trims 0.45 seconds off the remaining reload."},
    pressureRelease:{title:"Pressure release",rarity:"rare",cooldown:17,form:"stormPush",value:0,
        description:"Pushes the three nearest demons back with Knockback I. An active weather overlay raises it to Knockback II."},
    solarCoronal:{title:"Coronal lash",rarity:"legendary",cooldown:23,form:"solarCone",value:15,element:"burn",elementLevel:2,affinity:"daytime",affinityBonus:.50,
        description:"Rake three nearby foes with a fan of fire and Burn II. Bright daytime makes the direct hit 50% stronger."},
    blackGlass:{title:"Black glass",rarity:"rare",cooldown:21,form:"stormGlass",value:4,affinity:"weather",affinityBonus:.45,
        description:"Shatter up to four incoming shots here. The fragments strike the nearest demon, harder during active weather."},
    blueHour:{title:"Blue hour",rarity:"epic",cooldown:24,form:"nightVeil",value:9.4,element:"blind",elementLevel:2,affinity:"night",affinityBonus:.60,
        description:"Drape the four nearest enemies in Blindness II. Direct damage increases by 60% in Night or Blood Moon."},
    lastStar:{title:"Last star",rarity:"legendary",environment:"night",cooldown:32,form:"lunarWard",value:0,
        description:"By moonlight, raise a barrier or restore two seconds of field shield charge."}
}

var passives={
    dryPriming:{title:"Dry priming",rarity:"common",description:"Reload 5% faster without an active weather overlay. Upgrades improve this bonus."},
    stormWick:{title:"Storm wick",rarity:"rare",description:"Take 6% less damage during an active weather overlay. Upgrades improve this bonus."},
    sunCup:{title:"Sun cup",rarity:"legendary",description:"Damaging active abilities deal 12% more damage in bright daytime. Upgrades improve this bonus."},
    barometerSpring:{title:"Barometer spring",rarity:"rare",description:"Cycle shots 7% faster during an active weather overlay. Upgrades improve this bonus."},
    gloamingWard:{title:"Gloaming ward",rarity:"epic",description:"Perfect parry timing is 0.04 seconds more generous in sunrise and sunset. Upgrades widen the window."},
    darkroom:{title:"Darkroom",rarity:"legendary",description:"Field shield recovery is 0.65 seconds shorter when the shield comes up by moonlight. Upgrades improve this bonus."}
}
var conditional={
    dryPriming:{when:"clear",reload:.05},stormWick:{when:"weather",armor:.06},sunCup:{when:"daytime",activeDamage:.12},
    barometerSpring:{when:"weather",cycle:.07},gloamingWard:{when:"twilight",parryWindow:.04},darkroom:{when:"night",shieldCool:.65}
}
var perks={
    dryPriming:{reload:.04,when:"clear",text:"Clear weather reload time −4%"},
    stormWick:{armor:.04,when:"weather",text:"Damage taken during weather −4%"},
    sunCup:{activeDamage:.06,when:"daytime",text:"Daytime active impact +6%"},
    barometerSpring:{cycle:.04,when:"weather",text:"Shot recovery during weather −4%"},
    gloamingWard:{parryWindow:.025,when:"twilight",text:"Twilight parry window +0.025s"},
    darkroom:{shieldCool:.30,when:"night",text:"Night shield recovery −0.30s"}
}
var kits=[
    {key:"dryInk",title:"Dry ink",weapon:"wickPistol",active:"openSign",passive:"dryPriming",
        stat:"reload",scope:"wickPistol",value:.075,bonus:"Wick pistol reloads a further 7.5% faster."},
    {key:"stormWindow",title:"Storm window",weapon:"stormWicket",active:"pressureRelease",passive:"stormWick",
        stat:"damage",scope:"stormWicket",value:.085,bonus:"Storm Wicket gains 8.5% shot damage."},
    {key:"sunlitSermon",title:"Sunlit sermon",weapon:"zenithThroat",active:"solarCoronal",passive:"sunCup",
        stat:"active",scope:"solarCoronal",value:.09,bonus:"Coronal lash recovers 9% sooner."},
    {key:"rainContract",title:"Rain contract",weapon:"barometer",active:"blackGlass",passive:"barometerSpring",
        stat:"recovery",scope:"barometer",value:.06,bonus:"Barometer cycles a further 6% faster."},
    {key:"redHorizon",title:"Red horizon",weapon:"crepuscule",active:"blueHour",passive:"gloamingWard",
        stat:"crit",scope:"crepuscule",value:.04,bonus:"Crepuscule gains four percentage points of critical chance."},
    {key:"moonlessMint",title:"Moonless mint",weapon:"moonwake",active:"lastStar",passive:"darkroom",
        stat:"shieldCooldown",scope:"",value:.45,bonus:"The field shield recovers 0.45 seconds sooner."}
]
var achievements=[
    {id:"witchLedger1",title:"The witch’s ledger I",metric:"vaultBuys",target:4,group:"active",reward:"openSign",
        requirement:"Make 4 purchases in the Witch’s Vault."},
    {id:"witchLedger2",title:"The witch’s ledger II",metric:"vaultBuys",target:24,group:"passive",reward:"stormWick",
        requirement:"Make 24 purchases in the Witch’s Vault."},
    {id:"witchLedger3",title:"The witch’s ledger III",metric:"vaultBuys",target:100,group:"weapon",reward:"zenithThroat",
        requirement:"Make 100 purchases in the Witch’s Vault."},
    {id:"witchGems1",title:"Crystal hoard I",metric:"vaultGems",target:500,group:"weapon",reward:"barometer",
        requirement:"Earn 500 dark gems across regular expeditions."},
    {id:"witchGems2",title:"Crystal hoard II",metric:"vaultGems",target:5000,group:"active",reward:"blueHour",
        requirement:"Earn 5,000 dark gems across regular expeditions."},
    {id:"witchGems3",title:"Crystal hoard III",metric:"vaultGems",target:24000,group:"weapon",reward:"moonwake",
        requirement:"Earn 24,000 dark gems across regular expeditions."}
]
for (const [category,catalog] of [["Weapon",weapons],["Active",actives],["Passive",passives]])
    for (const id of Object.keys(catalog))
        Object.assign(catalog[id],{id:id,category:category})
for (const medal of achievements)
    ({weapon:weapons,active:actives,passive:passives})[medal.group][medal.reward].locked=true
