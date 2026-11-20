.pragma library
.import "Loadout.js" as Gear

var bossChoices = [
    { id:"health", title:"Maximum health", values:[60,74,89,102,114], description:"Increase your maximum and current health for this run." },
    { id:"damage", title:"Damage", values:[.21,.27,.32,.39,.46], description:"Increase your outgoing damage for this run." },
    { id:"speed", title:"Turn speed", values:[.17,.22,.27,.32,.38], description:"Turn between wallpapers faster for this run." }
]

function draftBoss(random, previous) {
    return bossChoices.map(function(choice) {
        const prior = previous.find(function(card) { return card.id === choice.id })
        const values = prior ? choice.values.filter(function(value) { return value !== prior.amount }) : choice.values
        const amount = values[Math.floor(random() * values.length)]
        return { id:choice.id, title:choice.title, amount:amount, description:choice.description,
            display:"+" + (choice.id === "health" ? amount + " HP" : Math.round(amount * 100) + "%") }
    })
}

function canRefresh(phase) {
    return phase === "ready" || phase === "bossReward" || phase === "shop" || phase === "reward"
}

function canFreeze(run) {
    const covenant=run.covenant
    return (run.phase==="shop" || run.phase==="reward") && !!(covenant && covenant.ranks.freezeStock)
}

function freezable(run,phase,card) {
    if (!card || card.sold || card.paid) return false
    if (phase==="reward") {
        const group=Gear.groupOf(card)
        return card.id==="dressing" || card.id==="reserve" || group && Gear.canOffer(run,Gear.catalogs[group][card.id])
    }
    if (card.action==="gear") return Gear.canOffer(run,Gear.catalogs[card.group][card.gearId])
    const slot=run.slots[card.group]?.[card.index]
    switch (card.action) {
    case "supply": case "mystery": case "scramble": return true
    case "upgrade": {
        const item=Gear.ownedItem(run,card.group,card.gearId)
        return !!item && Gear.findSlot(run,card.group,card.gearId)>=0 && item.level===card.level-1
    }
    case "unlock": return run.slots[card.group].length===card.index
    case "item-upgrade":return Gear.upgradeTargets(run).length>0
    case "inventory":return run.inventory.length===card.index
    case "pet":return !!run.pet && run.pet.level<3
    case "shield-upgrade":return run.shield.level<3
    case "barrier-core":return Gear.canBuyCore(run)
    case "repeat-upgrade":return run.repeatRank<3
    case "shop-stat":return run.shopStats[card.stat]<3
    case "shop-quality":return run.shopQuality+1===card.level
    case "power":return !!slot && slot.power!==card.powerId
    case "power-upgrade":return !!slot && slot.power===card.powerId && slot.powerLevel===card.level-1
    }
    return false
}

function isFrozen(run,card) {
    const frozen=run.frozenOffer
    return !!(frozen && card && frozen.phase===run.phase && frozen.card.id===card.id)
}

function frozenFor(run,phase) {
    const frozen=run.frozenOffer
    if (!frozen || frozen.phase!==phase) return null
    if (!freezable(run,phase,frozen.card)) {
        run.frozenOffer=null
        return null
    }
    return frozen.card
}

function leaveFrozen(run,claimed) {
    if (isFrozen(run,claimed) || run.frozenOffer && run.frozenOffer.phase===run.phase && run.frozenOffer.wave<run.wave)
        run.frozenOffer=null
}

function rewardPool(run) {
    return Object.values(Gear.weapons).concat(Object.values(Gear.activeAbilities),Object.values(Gear.passives))
        .filter(function(card){return Gear.canOffer(run,card)})
}

function rerollRewards(run,random) {
    let available=rewardPool(run).filter(function(card) {
        return !run.offers.some(function(prior){return card.id===prior.id})
    })
    return run.offers.map(function(prior) {
        if (isFrozen(run,prior)) return prior
        const tier=prior.rarity || "common"
        const eligible=available.filter(function(candidate){return candidate.rarity===tier})
        const chosen=eligible.length ? Gear.pickRarityItem(run,eligible,random()) : null
        if (!chosen) return prior
        available=available.filter(function(card){return card.id!==chosen.id})
        return Gear.describeOffer(run,chosen)
    })
}

function rerollShop(run, random) {
    const fixed=function(card){return card.sold || card.paid || isFrozen(run,card)}
    const kept=run.shopStock.filter(fixed)
    if (kept.length===run.shopStock.length) return null
    const fresh=Gear.makeShop(run,random,kept.map(function(card){return card.id}),run.shopStock.length-kept.length)
    let index=0
    return run.shopStock.map(function(card){return fixed(card) ? card : fresh[index++] || card})
}
