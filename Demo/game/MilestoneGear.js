.pragma library

var weapons = {
    stillwater:{id:"stillwater",title:"Stillwater oath",category:"Weapon",rarity:"legendary",art:"stillwater",
        effect:"beam",capacity:5,damage:9.8,delay:.70,reload:1.65,aim:18,color:"#d4fff4",trace:6,afterglow:.30,
        penetration:2,crit:.09,handling:"reload",signature:"unbroken",scopeZoom:3.15,
        description:"A silver-green precision rifle. Shots gain 22% damage until you lose health in the current wave."},
    kingsRansom:{id:"kingsRansom",title:"King's Ransom",category:"Weapon",rarity:"legendary",art:"kingsRansom",
        effect:"ballistic",capacity:8,damage:12.8,delay:.43,reload:1.60,aim:23,color:"#ffe478",trace:4.7,afterglow:.24,
        handling:"capacity",signature:"coinShot",coinCost:4,crit:.04,
        description:"An engraved golden handgun. Spend 4 gold to fire a heavy coin. When broke, it fires ordinary rounds for 22% damage."}
}
var actives = {
    oathWard:{id:"oathWard",title:"Oath interval",category:"Active",rarity:"legendary",cooldown:48,duration:1.2,
        description:"Evade incoming strikes for 1.2 seconds. Burn and other ongoing damage keep working. Upgrades extend the window and shorten recovery."},
    liquidation:{id:"liquidation",title:"Liquidation",category:"Active",rarity:"epic",cooldown:43,
        description:"Spend up to 80 gold for a screen-wide blast. Needs 20 gold. Spending at least 50 also Weakens survivors at level 2."}
}
var passives = {
    oathglass:{id:"oathglass",title:"Untarnished glass",category:"Passive",rarity:"epic",
        description:"At full health, gain 12% weapon damage. Upgrades strengthen the bonus and add a little critical chance."},
    liquidAssets:{id:"liquidAssets",title:"Liquid assets",category:"Passive",rarity:"rare",
        description:"Each paid enemy kill grants one extra gold per rank. Upgrades also improve reload handling."}
}
var perks = {
    oathglass:{critChance:.013,text:"Critical chance +1.3%"},
    liquidAssets:{reload:.038,text:"Reload time −3.8%"}
}
var kits = [
    {key:"unbrokenOath",title:"Unbroken oath",weapon:"stillwater",active:"oathWard",passive:"oathglass",
        stat:"crit",value:.06,scope:"stillwater",bonus:"Stillwater oath gains another six percentage points of critical chance."},
    {key:"deadDividend",title:"Dead man's dividend",weapon:"kingsRansom",active:"liquidation",passive:"liquidAssets",
        stat:"coinDiscount",value:1,bonus:"King's Ransom spends one less gold per paid shot."}
]
for (const catalog of [weapons,actives,passives]) {
    for (const item of Object.values(catalog))
        item.locked = true
}
