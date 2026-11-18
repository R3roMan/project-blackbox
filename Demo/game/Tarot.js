.pragma library

// Effects are either permanent modifiers for this expedition or bounded rites.
var majors=[
    ["The Fool","A second chance waits at the mouth of the first wave.",{},["wave",1,"refresh",1,"first"]],
    ["The Magician","Your third active cast each wave primes both actives to return two seconds sooner.",{},["cast",3,"cool",2]],
    ["The High Priestess","Your shots deal 14% more damage on the Abyss wallpaper.",{abyssDamage:.14}],
    ["The Empress","Begin the expedition with 30 extra maximum HP.",{health:30}],
    ["The Emperor","The first Overlord defeated on each boss wave pays 45 extra gold.",{},["boss",1,"gold",45]],
    ["The Hierophant","Block three attacks in a wave to restore 10 HP.",{},["block",3,"heal",10]],
    ["The Lovers","The first perfect parry of each wave recovers 3 seconds of active cooldown.",{},["parry",1,"cool",3]],
    ["The Chariot","Wallpaper transitions take 22% less time.",{turn:.22}],
    ["Strength","Gun and blade attacks deal 18% more damage below half health.",{hurtDamage:.18}],
    ["The Hermit","Your first kill each wave grants four seconds of faster weapon cycling.",{},["kill",1,"fire",4]],
    ["Wheel of Fortune","Begin every third wave with a different boon drawn from gold, a barrier or faster fire.",{},["wave",1,"fortune",1,"third"]],
    ["Justice","Gain two points of critical chance and add 0.15 to the critical multiplier.",{critChance:.02,critPower:.15}],
    ["The Hanged Man","Deal 14% more damage in clear weather. Deal 7% less in active weather.",{clearDamage:.14,weatherDamage:-.07}],
    ["Death","After 10 kills in a wave, gain a single barrier hit for 25 seconds if your temporary barrier is empty.",{},["kill",10,"barrier",1]],
    ["Temperance","Begin each wave with three extra rounds in your equipped magazine.",{},["wave",1,"rounds",3]],
    ["The Devil","Jacko, a green-fire pumpkin familiar, joins your chosen pet for the expedition.",{jacko:true}],
    ["The Tower","The first rift sealed each wave gives 55 gold.",{},["seal",1,"gold",55]],
    ["The Star","Heal 12 HP upon sealing the rift and deal 8% extra shot damage in Star Sky.",{skyDamage:.08},["seal",1,"heal",12]],
    ["The Moon","Reload 21% faster and deal 10% more weapon damage by moonlight.",{nightReload:.21,nightDamage:.10}],
    ["The Sun","Deal 13% more weapon damage in daylight and recover 5 more HP when a wave ends.",{dayDamage:.13,waveHeal:5}],
    ["Judgement","The first perfect parry of each wave earns 13 gold.",{},["parry",1,"gold",13]],
    ["The World","Begin each boss wave with one barrier hit for 25 seconds and cast timed actives for 12% longer.",{duration:.12},["wave",1,"barrier",1,"boss"]]
]

var suits=[
    {id:"wands",name:"Wands",epithet:"Embers",rows:[
        ["Weapon attacks deal 6% more damage.",{damage:.06}],
        ["Gain 8% shot cycle speed when at least 80% of your maximum HP remains.",{healthyCycle:.08}],
        ["After your third kill each wave, quicken fire for five seconds.",{},["kill",3,"fire",5]],
        ["Begin the first wave with a single barrier hit for 25 seconds.",{},["wave",1,"barrier",1,"first"]],
        ["Weapon attacks deal 12% more damage in active weather.",{weatherDamage:.12}],
        ["Defeating an Overlord grants seven seconds of faster fire.",{},["boss",1,"fire",7]],
        ["The seventh confirmed shot each wave recovers two seconds of shield cooldown.",{},["hit",7,"shield",2]],
        ["Weapon cycling is 9% shorter.",{cycle:.09}],
        ["Take 9% less damage below half health.",{hurtArmor:.09}],
        ["Deal 22% extra weapon damage below 25% health.",{direDamage:.22}],
        ["Your first reload each wave grants three seconds of faster fire.",{},["reload",1,"fire",3]],
        ["Deal 10% more weapon damage during sunset or sunrise.",{twilightDamage:.10}],
        ["The first active cast each wave gives your equipped weapon two rounds.",{},["cast",1,"rounds",2]],
        ["The first active cast each wave grants two seconds of infinite ammo.",{},["cast",1,"infinite",2]]
    ]},
    {id:"cups",name:"Cups",epithet:"Veins",rows:[
        ["Add 17 to your maximum HP.",{health:17}],
        ["Your second kill in each wave restores 5 HP.",{},["kill",2,"heal",5]],
        ["Win each wave to recover an additional 7 HP.",{waveHeal:7}],
        ["Take 6% less damage on the Shrine wallpaper.",{shrineArmor:.06}],
        ["Take 5% less damage from ranged attacks.",{rangedArmor:.05}],
        ["Restore 6 more HP when clearing a wave in active weather.",{weatherHeal:6}],
        ["The seventh kill in a wave restores 7 HP.",{},["kill",7,"heal",7]],
        ["Your first shield block each wave grants a round to the equipped weapon.",{},["block",1,"rounds",1]],
        ["Take 8% less damage from melee attacks.",{meleeArmor:.08}],
        ["The first perfect parry each wave restores 8 HP.",{},["parry",1,"heal",8]],
        ["The first shop purchase in each boss wave restores 12 HP.",{},["buy",1,"heal",12]],
        ["Restore 14 HP when clearing every fourth wave.",{},["clear",1,"heal",14,"fourth"]],
        ["Win a wave without being hurt to restore 9 extra HP.",{flawlessHeal:9}],
        ["Begin each tenth wave with 20 HP restored.",{},["wave",1,"heal",20,"boss"]]
    ]},
    {id:"swords",name:"Swords",epithet:"Thorns",rows:[
        ["Gain two points of critical chance.",{critChance:.02}],
        ["Add 0.12 to your critical damage multiplier.",{critPower:.12}],
        ["Make your first three confirmed hits in a wave to earn 5 gold.",{},["hit",3,"gold",5]],
        ["Reduce field shield recovery by 0.4 seconds.",{shield:.4}],
        ["Deal 7% more weapon damage and take 4% more incoming damage.",{damage:.07,armor:-.04}],
        ["Reload 12% sooner.",{reload:.12}],
        ["The first parry each wave grants a round to the equipped weapon.",{},["parry",1,"rounds",1]],
        ["Cast four actives in a wave to recover 2.5 seconds of shield cooldown.",{},["cast",4,"shield",2.5]],
        ["Take 10% less damage at night.",{nightArmor:.10}],
        ["Reduce perfect parry timing demands by 0.035 seconds.",{parry:.035}],
        ["Interrupt your first projectile each wave to earn 8 gold.",{},["intercept",1,"gold",8]],
        ["Perfect parries also take 0.6 seconds off the next shield recovery.",{parryCredit:.6}],
        ["Reduce active recovery time by 9%.",{cooldown:.09}],
        ["Deal 10% more weapon damage and add 0.20 to the critical multiplier against Overlords.",{bossDamage:.10,bossCrit:.20}]
    ]},
    {id:"pentacles",name:"Pentacles",epithet:"Graves",rows:[
        ["Begin wave one with 42 extra gold.",{},["wave",1,"gold",42,"first"]],
        ["The two-minute wait is on the other side of the counter. Field shop prices are 5% lower.",{shop:.05}],
        ["Win 8 gold when you clear each third wave.",{},["clear",1,"gold",8,"third"]],
        ["Your first shield block every wave pays 4 gold.",{},["block",1,"gold",4]],
        ["Your first field purchase on each boss wave earns a 14 gold rebate.",{},["buy",1,"gold",14]],
        ["Sealing the rift grants two magazine rounds.",{},["seal",1,"rounds",2]],
        ["The seventh kill in a wave pays 11 additional gold.",{},["kill",7,"gold",11]],
        ["Your first field purchase each boss wave grants a refresh credit.",{},["buy",1,"refresh",1]],
        ["Your first reload each wave recovers one second of shield cooldown.",{},["reload",1,"shield",1]],
        ["Win 22 gold for clearing every fourth wave.",{},["clear",1,"gold",22,"fourth"]],
        ["Begin every fifth wave with 15 additional gold.",{},["wave",1,"gold",15,"fifth"]],
        ["Defeat an Overlord to recover 5 seconds of active cooldown.",{},["boss",1,"cool",5]],
        ["Receive 18 extra gold for sealing a rift, and 9% faster active recovery in clear weather.",{clearCooldown:.09},["seal",1,"gold",18]],
        ["Get 7% off field shop offers and gain 28 gold the first time you block on each boss wave.",{shop:.07},["block",1,"gold",28,"boss"]]
    ]}
]

var ranks=["Ace","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Page","Knight","Queen","King"]
var deck=majors.map(function(row,index) {
    return {id:"major-"+index, title:row[0], description:row[1], stats:row[2], rite:row[3], art:index}
})
for (const [suitIndex,suit] of suits.entries()) {
    for (const [rank,row] of suit.rows.entries()) {
        deck.push({id:suit.id+"-"+(rank+1),title:ranks[rank]+" of "+suit.name,subtitle:suit.epithet,
            description:row[0],stats:row[1],rite:row[2],art:22+suitIndex*14+rank})
    }
}
var byId = {}
for (const card of deck) byId[card.id]=card

function card(id) {return Object.prototype.hasOwnProperty.call(byId,id) ? byId[id] : null}

function draw(random) {
    const pool=deck.slice()
    return Array.from({length:5},function() {
        const index=Math.max(0,Math.min(pool.length-1,Math.floor(random()*pool.length)))
        return pool.splice(index,1)[0].id
    })
}

var none={}
function stats(run) {
    if (!run.covenant || !run.covenant.tarot) return none
    const selected=card(run.covenant.tarot)
    return selected ? selected.stats : none
}
function value(run,key) {return stats(run)[key] || 0}
function dark(run) {return run.skyPhase==="night" || run.skyPhase==="bloodMoon"}
function weather(run) {return run.weatherEffect && run.weatherEffect!=="clear"}

function weaponFactor(run, cap) {
    const mod=stats(run)
    if (mod===none) return 1
    const day=run.skyPhase==="daytime"
    const twilight=run.skyPhase==="sunset" || run.skyPhase==="sunrise"
    const hurt=mod.hurtDamage || mod.direDamage ? run.health/Math.max(1,cap) : 1
    return 1+(mod.damage || 0)+(day ? mod.dayDamage || 0 : 0)+(dark(run) ? mod.nightDamage || 0 : 0)
        +(twilight ? mod.twilightDamage || 0 : 0)+(weather(run) ? mod.weatherDamage || 0 : mod.clearDamage || 0)
        +(hurt<.5 ? mod.hurtDamage || 0 : 0)+(hurt<.25 ? mod.direDamage || 0 : 0)
        +(run.playerFront==="down" ? mod.abyssDamage || 0 : 0)+(run.playerFront==="up" ? mod.skyDamage || 0 : 0)
}

function armor(run, cap, projectile) {
    const mod=stats(run)
    return (mod.armor || 0)+(projectile ? mod.rangedArmor || 0 : mod.meleeArmor || 0)
        +(dark(run) ? mod.nightArmor || 0 : 0)+(run.playerFront==="front" ? mod.shrineArmor || 0 : 0)
        +(run.health<cap*.5 ? mod.hurtArmor || 0 : 0)
}

var waveDivisors={boss:10,third:3,fourth:4,fifth:5}
function rite(run,event,count) {
    const selected=run.covenant && card(run.covenant.tarot)
    const effect=selected && selected.rite
    if (!effect || effect[0]!==event || effect[1]!==count)
        return null
    const timing=effect[4]
    if (timing==="first" ? run.wave!==1 : timing && run.wave%waveDivisors[timing]!==0)
        return null
    return {title:selected.title, action:effect[2], amount:effect[3]}
}
