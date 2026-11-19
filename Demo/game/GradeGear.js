.pragma library

var chapters=[
    {grade:"F",key:"ashReceipt",title:"Ash receipt",weapon:"mortuarySix",active:"nervousBreath",passive:"bareHands",
        reward:"weapon",stat:"reload",value:.035,bonus:"The Mortuary sixgun reloads faster."},
    {grade:"D",key:"returnAddress",title:"Return address",weapon:"stampedCarbine",active:"sealTheEnvelope",passive:"splitLedger",
        reward:"active",stat:"recovery",value:.045,bonus:"The Stamped carbine cycles a little faster."},
    {grade:"C",key:"coldAudit",title:"Cold audit",weapon:"auditBreaker",active:"lineAudit",passive:"wellAccounted",
        reward:"passive",stat:"shieldCooldown",value:.36,bonus:"Field shield recovery is 0.36 seconds shorter."},
    {grade:"B",key:"violetPatent",title:"Violet patent",weapon:"patentCoil",active:"stalledClock",passive:"heldMargin",
        reward:"weapon",stat:"damage",value:.09,bonus:"Patent Coil deals 9% more weapon damage."},
    {grade:"A",key:"blackSeal",title:"Black seal",weapon:"registrar",active:"inkOfRecord",passive:"darkEstimate",
        reward:"active",stat:"active",value:.08,bonus:"Ink of record recharges 8% faster."},
    {grade:"S",key:"closingBalance",title:"Closing balance",weapon:"grandReceipt",active:"closeTheBook",passive:"bestTerms",
        reward:"passive",stat:"reload",value:.13,bonus:"Grand Receipt reloads 13% faster."},
    {grade:"SSS",key:"noWitness",title:"No witness",weapon:"zeroHour",active:"silenceTheCourt",passive:"cleanSlate",
        reward:"weapon",stat:"damage",value:.20,bonus:"Zero Hour deals 20% more damage when all three pieces are equipped."}
]

var weapons={
    mortuarySix:{title:"Mortuary sixgun",rarity:"common",art:"pistol",frame:43,effect:"ballistic",capacity:5,damage:2.65,delay:.36,reload:.79,
        aim:24,color:"#bbb6b2",trace:2,afterglow:.15,handling:"reload",description:"A compact funeral revolver. Small magazine, very quick reload."},
    stampedCarbine:{title:"Stamped carbine",rarity:"common",art:"carbine",frame:57,effect:"tracer",capacity:13,damage:1.41,delay:.15,reload:.88,
        aim:28,color:"#d4c097",trace:2.3,afterglow:.095,handling:"reload",description:"A slim carbine with a small and rapidly replaceable magazine."},
    auditBreaker:{title:"Audit breaker",rarity:"rare",art:"rail",frame:88,effect:"beam",capacity:4,damage:6.5,delay:.64,reload:1.85,shieldDamage:2.2,
        aim:23,color:"#98ceef",trace:4,afterglow:.26,handling:"capacity",description:"A barrier-breaking rifle with an extra 2.2 impact against protection."},
    patentCoil:{title:"Patent Coil",rarity:"epic",art:"ion",frame:73,effect:"burst",capacity:18,damage:2.28,delay:.57,reload:1.65,
        burst:{count:3,interval:.074},element:"electric",elementLevel:2,aim:31,color:"#e7b3ff",trace:4,afterglow:.15,
        handling:"reload",description:"Three sustained bursts of Electric II arc shots. Follow moving foes through the triplet."},
    registrar:{title:"The Registrar",rarity:"epic",art:"rail",frame:61,effect:"beam",capacity:4,damage:10.2,delay:.91,reload:1.95,aim:17,
        color:"#e6a8aa",trace:7.1,afterglow:.29,penetration:2,marksman:true,handling:"reload",
        description:"A long range rifle. A hit marks a demon so later shots deal extra damage to it."},
    grandReceipt:{title:"Grand Receipt",rarity:"legendary",art:"harrier",frame:91,effect:"beam",capacity:4,damage:13.7,delay:.75,reload:2.83,
        aim:18,color:"#ffda86",trace:8.1,afterglow:.33,penetration:3,pierceRetain:.88,element:"weaken",elementLevel:2,
        handling:"reload",description:"Three-target penetration with Weaken II. The heavy gold cell takes time to replace."},
    zeroHour:{title:"Zero Hour",rarity:"legendary",effect:"melee",capacity:0,damage:34,delay:.51,reload:1.25,
        aim:59,color:"#fff0ae",trace:5.6,afterglow:.36,art:"zeroHour",handling:"reload",signature:"zeroHour",crit:.14,
        melee:{reach:775,targets:2,trick:"Catch the descending blade",boost:1.68},
        description:"A long golden executioner’s blade. A landed cut sends half its damage into up to two nearby enemies. Spin and catch the blade with R for a powerful long-range charge."}
}
var actives={
    nervousBreath:{title:"Nervous breath",rarity:"common",cooldown:15,form:"sight",value:4,description:"Steady the reticle for four seconds."},
    sealTheEnvelope:{title:"Seal the envelope",rarity:"common",cooldown:15,form:"reloadCut",value:0,description:"Halve the remaining reload and apply Weaken I to a target."},
    lineAudit:{title:"Line audit",rarity:"rare",cooldown:19,form:"seekMark",value:4.5,description:"Wound and mark an enemy for extra follow-up damage."},
    stalledClock:{title:"Stalled clock",rarity:"rare",cooldown:15,form:"wideSlow",value:2.2,description:"Add 2.2 seconds to the next attacks of the three closest threats."},
    inkOfRecord:{title:"Ink of record",rarity:"epic",cooldown:22,form:"corrode",value:8,description:"Strike a target with Poison II and Weaken I."},
    closeTheBook:{title:"Close the book",rarity:"legendary",cooldown:23,form:"interrupt",value:13,description:"Interrupt and Stun the first two charging demons, wounding them."},
    silenceTheCourt:{title:"Silence the court",rarity:"legendary",cooldown:24,form:"edgeRing",value:17,description:"Send a wide blade through every foe within 575 units on this wallpaper."}
}
var passives={
    bareHands:{title:"Bare hands",rarity:"common",description:"Reduces reload time by 3%. The second upgrade adds another 3%."},
    splitLedger:{title:"Split ledger",rarity:"common",description:"Critical chance increases by one percentage point. The second upgrade adds another point."},
    wellAccounted:{title:"Well accounted",rarity:"rare",description:"Reduces field shield cooldown by 0.25 seconds. The second upgrade cuts another 0.20 seconds."},
    heldMargin:{title:"Held margin",rarity:"rare",description:"Reduces all incoming damage by 4%. The second upgrade adds another 3 percentage points of reduction."},
    darkEstimate:{title:"Dark estimate",rarity:"epic",description:"Actives recover 7% sooner. The second upgrade adds another 3 percentage points of cooldown reduction."},
    bestTerms:{title:"Best terms",rarity:"legendary",description:"Reload 9% faster and gain three percentage points of critical chance. The second upgrade cuts an additional 5% off reloads."},
    cleanSlate:{title:"Clean slate",rarity:"legendary",description:"Adds 0.3 to the critical multiplier. The second upgrade adds a further 0.2."}
}
var perks={
    bareHands:{reload:.03,text:"Reload −3%"},splitLedger:{critChance:.01,text:"Critical chance +1%"},
    wellAccounted:{shieldCool:.20,text:"Field shield recovery −0.20s"},heldMargin:{armor:.03,text:"Damage taken −3%"},
    darkEstimate:{cooldown:.03,text:"Active cooldowns −3%"},bestTerms:{reload:.05,text:"Reload −5%"},
    cleanSlate:{critPower:.20,text:"Critical multiplier +0.2"}
}
var basic={
    bareHands:{reload:.03},splitLedger:{critChance:.01},wellAccounted:{shieldCool:.25},heldMargin:{armor:.04},
    darkEstimate:{cooldown:.07},bestTerms:{reload:.09,critChance:.03},cleanSlate:{critPower:.30}
}
var kits=chapters.map(function(row){
    return Object.assign({scope:row.stat==="shieldCooldown" ? "" : row[row.stat==="active" ? "active" : "weapon"]},row)
})
var achievements=chapters.map(function(row){
    return {id:"grade"+row.grade,title:row.title,metric:"grade"+row.grade,target:1,group:row.reward,
        reward:row[row.reward],requirement:row.grade==="SSS"
            ? "Retire with SSS after 120 hitless wave clears. Meet the accuracy, combat and finance benchmarks."
            : "Earn an overall "+row.grade+" grade (−, plain or +) in a regular expedition."}
})
for (const [category,catalog] of [["Weapon",weapons],["Active",actives],["Passive",passives]])
    for (const id of Object.keys(catalog))
        Object.assign(catalog[id],{id:id,category:category})
for (const medal of achievements)
    ({weapon:weapons,active:actives,passive:passives})[medal.group][medal.reward].locked=true
