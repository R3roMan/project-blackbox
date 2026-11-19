.pragma library

var weapons = {
    rimeBell:{title:"Rime Bell",rarity:"epic",art:"rimeBell",effect:"spread",capacity:5,
        damage:1.5,delay:.78,reload:1.58,aim:65,color:"#a2efff",trace:3,afterglow:.25,handling:"reload",
        element:"freeze",elementLevel:1,signature:"rimeBell",spread:[[0,0],[-.053,0],[.053,0],[-.034,.027],[.034,.027],[-.019,-.030],[.019,-.030]],
        description:"A seven-pellet frost bell. Land four pellets on one target inside 500 units to freeze it solid."},
    furnaceDoor:{title:"Furnace Door",rarity:"legendary",art:"furnaceDoor",effect:"spread",capacity:3,
        damage:2.05,delay:1.02,reload:2.15,aim:74,color:"#ff9051",trace:4.2,afterglow:.36,handling:"capacity",
        element:"burn",elementLevel:2,signature:"furnaceDoor",spread:[[0,0],[-.062,0],[.062,0],[-.039,.031],[.039,.031],[-.032,-.037],[.032,-.037],[0,.046]],
        description:"Eight furnace pellets inflict Burn II. Four hits on one foe within 500 units prime it to explode on death."},
    twinSmgs:{title:"Twin SMGs",rarity:"rare",dual:true,art:"twinSmgs",effect:"tracer",capacity:30,
        damage:1.36,delay:.105,reload:1.72,aim:33,color:"#8ee7ce",trace:2.7,afterglow:.11,handling:"capacity",
        description:"Two compact automatics alternate a long stream of rounds. Best at short and medium range."},
    twinShotguns:{title:"Twin shotguns",rarity:"epic",dual:true,art:"twinShotguns",effect:"spread",capacity:8,
        damage:1.78,delay:.48,reload:1.95,aim:58,color:"#ffa37b",trace:3.1,afterglow:.26,handling:"reload",
        spread:[[0,0],[-.030,-.017],[.030,-.017],[-.036,.021],[.036,.021],[0,.031]],
        description:"Alternating short barrels throw six wide pellets. Close targets take the full blast."},
    siegeRpg:{title:"Siege RPG",rarity:"legendary",art:"siegeRpg",effect:"rocket",capacity:1,
        damage:27.5,delay:1.54,reload:4.35,aim:32,color:"#ffc786",trace:8.5,afterglow:.46,handling:"reload",
        blast:510,element:"explosive",elementLevel:2,signature:"siegeRocket",
        description:"A heavy shoulder launcher. Its slow rockets burst over a wide area and prime survivors to explode."},
    cinderTwig:{title:"Cinder twig",rarity:"common",color:"#ffad71",damage:3.5,delay:.89,
        element:"burn",elementLevel:1,staff:{kind:"burn",style:"twig",cost:5,cast:"Little meteor"},
        description:"A charred beginner's staff. Five attacks charge a small meteor that spreads Burn I."},
    draughtStick:{title:"Draught stick",rarity:"common",color:"#b7e9cc",damage:3.8,delay:.97,
        element:"wind",elementLevel:1,staff:{kind:"wind",style:"twig",cost:5,cast:"Crosswind"},
        description:"Its modest bolts push with Knockback I. Five attacks charge a wider gust."},
    pollenRod:{title:"Pollen rod",rarity:"rare",color:"#e6d46c",damage:5.4,delay:1.03,
        element:"poison",elementLevel:1,staff:{kind:"poison",style:"pollen",cost:5,cast:"Sour blossom"},
        description:"Poison I bolts chip away at an enemy's health cap. Its charged blossom poisons a group."},
    staticFork:{title:"Static fork",rarity:"rare",color:"#d6b6ff",damage:5.2,delay:.98,
        element:"electric",elementLevel:1,staff:{kind:"electric",style:"fork",cost:5,cast:"Forked flash"},
        description:"A split conductor that links nearby enemies. Five attacks charge a larger lightning strike."},
    hourhand:{title:"Hourhand sceptre",rarity:"legendary",locked:true,color:"#b9dcff",damage:10.6,delay:1.08,
        element:"freeze",elementLevel:2,staff:{kind:"freeze",style:"hourglass",cost:4,cast:"Still hour"},
        description:"Frost II bolts slow the crowd. Its charged spell freezes a group and pushes nearby projectiles backward."},
    graduate:{title:"Graduation pistol",rarity:"rare",locked:true,art:"graduate",effect:"ballistic",capacity:9,
        damage:3.4,delay:.32,reload:1.10,aim:24,color:"#ffda8b",trace:3.2,afterglow:.18,handling:"reload",signature:"graduate",
        description:"A gift for completing the tutorial. Deals 50% more damage through wave 20, then becomes a dependable normal pistol."}
}

var actives = {
    doorstop:{title:"Doorstop",rarity:"rare",cooldown:23,damage:5,element:"wind",elementLevel:1,
        description:"Blast enemies within 500 units on this wallpaper and knock them back."},
    kilnRing:{title:"Kiln ring",rarity:"epic",cooldown:23,damage:9,element:"burn",elementLevel:2,
        description:"Ignite every enemy within 500 units on your wallpaper. Enemies within 300 take double impact damage."},
    openingSalvo:{title:"Opening salvo",rarity:"rare",cooldown:22,duration:6,
        description:"Speed up attacks for six seconds. The bonus is stronger through wave 20."},
    lateBloom:{title:"Late bloom",rarity:"epic",cooldown:24,damage:8,
        description:"Burst across the current wallpaper and Stun survivors. Damage more than doubles after wave 20."},
    breachOrder:{title:"Breach order",rarity:"epic",cooldown:24,damage:9,
        description:"A focused blast on the current wallpaper. It hits Overlords much harder than ordinary foes."},
    emberPulse:{title:"Ember pulse",rarity:"common",cooldown:19,damage:4,element:"burn",elementLevel:1,
        description:"A small pulse burns the current wallpaper. Upgrades raise its Burn level and damage."},
    draftCircle:{title:"Draft circle",rarity:"common",cooldown:18,damage:2,element:"wind",elementLevel:1,
        description:"A ring of wind deals light damage and pushes the current crowd away."},
    yellowNoon:{title:"Yellow noon",rarity:"epic",cooldown:24,damage:8,element:"poison",elementLevel:2,locked:true,
        description:"A corrosive cloud deals impact damage and applies Poison II to the current wallpaper."},
    staticLatch:{title:"Static latch",rarity:"rare",cooldown:24,damage:7,element:"electric",elementLevel:1,
        description:"Strike one enemy with a jumping Electric bolt. Higher levels add more jumps."},
    borrowedBeat:{title:"Borrowed beat",rarity:"epic",cooldown:22,locked:true,
        description:"Rewind incoming projectiles on this wallpaper and add one charge to a staff. Higher levels rewind farther."},
    fieldLesson:{title:"Field lesson",rarity:"rare",cooldown:18,damage:6,
        description:"A reliable blast. It deals twice its normal damage through wave 20."}
}

var passives = {
    chokeRing:{title:"Choke ring",rarity:"rare",description:"Gun hits gain 9% damage per rank inside 500 units."},
    furnaceApron:{title:"Furnace apron",rarity:"epic",description:"Take 8% less damage per rank from enemies attacking within 500 units."},
    firstShift:{title:"First shift",rarity:"rare",description:"Take 8% less damage per rank through wave 20, then 2% less per rank."},
    closingShift:{title:"Closing shift",rarity:"epic",description:"Gain 12% damage per rank after wave 20, and 3% per rank earlier."},
    giantKiller:{title:"Giant killer",rarity:"epic",description:"Your attacks gain 18% damage per rank against Overlords."},
    slowEmbers:{title:"Slow embers",rarity:"common",description:"Burn lasts 0.6 seconds longer per rank. Staff spells add a little impact damage."},
    leeSide:{title:"Lee side",rarity:"common",description:"Projectile hits deal 4% less damage per rank. Wind pushes gain a small range bonus."},
    cleanLungs:{title:"Clean lungs",rarity:"rare",description:"Poison lasts 10% less time per rank. Finishing a poisoned foe restores a little health."},
    runeRelay:{title:"Rune relay",rarity:"rare",description:"An Electric kill adds a staff charge, at most once every eight seconds. Upgrades shorten that wait."},
    secondHand:{title:"Second hand",rarity:"rare",locked:true,description:"Actives recover 7% sooner per rank during the first thirty seconds of a wave."},
    trainingWheels:{title:"Training wheels",rarity:"common",description:"Recover 2 HP per rank at wave start through wave 20, and 1 HP per rank afterward."}
}

var perks = {
    chokeRing:{reload:.04,text:"Reload time −4%"},furnaceApron:{health:6,text:"Maximum health +6"},
    firstShift:{armor:.02,text:"Damage taken −2%"}, closingShift:{cycle:.05,text:"Attack recovery −5%"},
    giantKiller:{critChance:.025,text:"Critical chance +2.5%"},slowEmbers:{magicForce:1.4,text:"Staff spell impact +1.4"},
    leeSide:{pushDistance:20,text:"Knockback range +20"},cleanLungs:{health:8,text:"Maximum health +8"},
    runeRelay:{active:.045,text:"Active recovery −4.5%"},secondHand:{reload:.05,text:"Reload time −5%"},
    trainingWheels:{shieldCool:.30,text:"Shield recovery −0.3s"}
}

var kits = [
    {key:"bellKit",title:"Door knell",weapon:"rimeBell",active:"doorstop",passive:"chokeRing",stat:"recovery",scope:"rimeBell",value:.12,bonus:"Rime Bell fires 12% sooner."},
    {key:"kilnKit",title:"Kiln keeper",weapon:"furnaceDoor",active:"kilnRing",passive:"furnaceApron",stat:"damage",scope:"furnaceDoor",value:.12,bonus:"Furnace Door deals 12% more damage."},
    {key:"firstShiftKit",title:"First shift",weapon:"twinSmgs",active:"openingSalvo",passive:"firstShift",stat:"recovery",scope:"twinSmgs",value:.08,bonus:"Twin SMGs recover 8% sooner."},
    {key:"closingShiftKit",title:"Closing shift",weapon:"twinShotguns",active:"lateBloom",passive:"closingShift",stat:"damage",scope:"twinShotguns",value:.10,bonus:"Twin shotguns deal another 10% damage."},
    {key:"siegeKit",title:"Siege order",weapon:"siegeRpg",active:"breachOrder",passive:"giantKiller",stat:"blastRadius",value:.10,bonus:"Siege explosions reach 10% farther."},
    {key:"cinderTwigKit",title:"Little furnace",weapon:"cinderTwig",active:"emberPulse",passive:"slowEmbers",stat:"damage",scope:"cinderTwig",value:.10,bonus:"Cinder twig gains 10% impact damage."},
    {key:"draughtKit",title:"Draught watch",weapon:"draughtStick",active:"draftCircle",passive:"leeSide",stat:"pushDistance",value:25,bonus:"Wind pushes travel another 25 units."},
    {key:"yellowNoonKit",title:"Sour blossom",weapon:"pollenRod",active:"yellowNoon",passive:"cleanLungs",stat:"active",scope:"yellowNoon",value:.10,bonus:"Yellow noon recovers 10% sooner."},
    {key:"staticForkKit",title:"Forked circuit",weapon:"staticFork",active:"staticLatch",passive:"runeRelay",stat:"arcRadius",value:35,bonus:"Electric arcs reach another 35 units."},
    {key:"hourhandKit",title:"Borrowed hour",weapon:"hourhand",active:"borrowedBeat",passive:"secondHand",stat:"active",scope:"borrowedBeat",value:.12,bonus:"Borrowed beat recovers 12% sooner."},
    {key:"graduateKit",title:"Shrine graduate",weapon:"graduate",active:"fieldLesson",passive:"trainingWheels",stat:"damage",scope:"graduate",value:.08,bonus:"Graduation pistol gains another 8% damage."}
]

for (const [id,weapon] of Object.entries(weapons)) {
    Object.assign(weapon,{id:id,category:"Weapon"})
    if (weapon.staff)
        Object.assign(weapon,{effect:"pulse",capacity:0,reload:0,aim:31,trace:5.5,afterglow:.30,handling:"staffCharge",signature:weapon.staff.kind})
}
for (const [id,active] of Object.entries(actives))
    Object.assign(active,{id:id,category:"Active"})
for (const [id,passive] of Object.entries(passives))
    Object.assign(passive,{id:id,category:"Passive"})
