.pragma library

var weapons = {
    veinDrinker:{
        id:"veinDrinker",title:"Vein Drinker",category:"Weapon",locked:true,rarity:"legendary",
        art:"veinDrinker",effect:"tracer",signature:"veinDrinker",damage:10.2,capacity:6,delay:.53,reload:1.65,
        aim:25,color:"#f65370",trace:3.7,afterglow:.22,handling:"reload",
        description:"This blood-fed rifle returns 16% of health damage to you, up to 2.5 HP per hit. A barrier or overkill cannot feed it."
    }
}

var actives = {
    bloodLibation:{
        id:"bloodLibation",title:"Blood libation",category:"Active",locked:true,rarity:"epic",
        damage:12,cooldown:32,
        description:"Drain enemies within 720 units on your current front. Recover 35% of their lost health, up to 12 HP per cast. Vein Drinker and Blood pact complete the Scarlet covenant."
    }
}

var passives = {
    bloodPact:{
        id:"bloodPact",title:"Blood pact",category:"Passive",locked:true,rarity:"rare",
        description:"Your own weapon kills restore 2.5 HP plus 1 HP for each additional passive rank. Can trigger once per 1.5 seconds. Pairs with Blood libation and Vein Drinker."
    }
}

var perks = {
    bloodPact:{health:8,text:"Maximum health +8"},
    bloodLibation:{active:.05,text:"Active recovery −5%"}
}

var kits = [
    {key:"scarletCovenant",title:"Scarlet covenant",weapon:"veinDrinker",active:"bloodLibation",passive:"bloodPact",
        stat:"vampirism",scope:"veinDrinker",value:.07,bonus:"Vein Drinker returns 23% of health damage, up to 3.5 HP per hit."}
]
