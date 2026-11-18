.pragma library
.import "Loadout.js" as Gear

var bossChoices = [
    { id:"health", title:"Maximum health", values:[75,90,105,120,135], description:"Increase your maximum and current health for this run." },
    { id:"damage", title:"Damage", values:[.24,.30,.36,.44,.52], description:"Increase your outgoing damage for this run." },
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

function freeRefreshes(run) {
    return Math.max(0, 1 + (Gear.passiveRank(run, "rewire") > 0 ? 1 : 0) - run.refreshUsed)
}

function rerollRewards(run, random) {
    const previous = run.offers.map(function(card) { return card.id })
    const chosen = []
    for (const card of run.offers) {
        const group = Gear.groupOf(card)
        const catalog = Gear.catalogs[group]
        const pool = catalog ? Object.values(catalog).filter(function(candidate) {
            return candidate.rarity === card.rarity && !previous.includes(candidate.id)
                && !chosen.some(function(offer) { return offer.id === candidate.id }) && Gear.canOffer(run, candidate)
        }) : []
        chosen.push(pool.length ? Gear.describeOffer(run,Gear.pickRarityItem(run,pool,random())) : card)
    }
    return chosen
}

function rerollShop(run, random) {
    const sold = run.shopStock.filter(function(card) { return card.sold || card.paid })
    if (sold.length === run.shopStock.length)
        return null
    const fresh = Gear.makeShop(run, random, sold.map(function(card) { return card.id }), run.shopStock.length - sold.length)
    let index = 0
    return run.shopStock.map(function(card) { return card.sold || card.paid ? card : fresh[index++] || card })
}
