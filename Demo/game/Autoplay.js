.pragma library
.import "Rules.js" as Rules
.import "Loadout.js" as Gear
.import "Ship.js" as Ship

function waveLimit(profile, vault) {
    const records = [...(vault?.archive || []), vault?.last, vault?.best]
    let highest = Math.max(profile?.bestClearedWave || 0, profile?.bestTimedWave || 0, profile?.bestFlawlessWave || 0)
    for (const record of records) {
        if (record?.eligible && record.cleared > 0)
            highest = Math.max(highest, record.wave - Number(record.reason !== "retired"))
    }
    return Math.min(90, Math.floor(highest))
}

function shuffled(items) {
    const pool = items.slice()
    for (let i = pool.length - 1; i > 0; --i) {
        const other = Math.floor(Math.random() * (i + 1))
        const value = pool[i]
        pool[i] = pool[other]
        pool[other] = value
    }
    return pool
}

function destination(run, item) {
    if (!item || item.category === "Supply")
        return undefined
    const slot = Gear.defaultSlot(run, item)
    return slot === -1 ? Math.floor(Math.random() * run.slots[Gear.groupOf(item)].length) : slot
}

function select(run, boughtInShop) {
    if (run.phase === "reward")
        return shuffled(run.offers).some(card => Rules.choose(run,card.id,destination(run,card))) || Rules.skipSelection(run)
    if (run.phase === "bossReward")
        return shuffled(run.bossOffers).some(card => Rules.chooseBoon(run,card.id)) || Rules.skipSelection(run)
    if (run.phase === "shop") {
        const affordable = Gear.shopCards(run).filter(card => !card.sold && card.cost <= Gear.availableGold(run))
        const paid = affordable.find(card => card.paid)
        const options = paid ? [paid] : boughtInShop ? [] : shuffled(affordable)
        return options.some(card => {
            const item = card.action === "gear" ? Gear.catalogs[card.group][card.gearId] : null
            const replace = Gear.replacement(run,card)
            const upgrade=card.action==="item-upgrade" ? shuffled(Gear.upgradeTargets(run))[0]?.key : ""
            return Rules.buy(run,card.id,destination(run,item),upgrade || Gear.replacementKey(replace))
        }) || Rules.skipSelection(run)
    }
    return false
}

function liveEnemy(run, enemy) {
    return enemy.hp > 0 && !enemy.wreck && (!run.hypnosis || enemy.type === "hallucination")
}

function threat(run, enemy) {
    const spec = Rules.enemyTypes[enemy.type]
    return 1700 / Math.max(enemy.depth,160) + (enemy.front === run.playerFront ? 3 : 0)
        + (enemy.waitingBoss || spec.role === "boss" ? 3 : 0)
        + (spec.interval && enemy.depth <= spec.reach ? 2 : 0)
}

function plan(run) {
    const view = run.playerFront
    const seal = Rules.takeoverActive(run) && !run.hypnosis
    const shot = run.bolts.find(bolt => !bolt.bubble && !bolt.returning && bolt.front === view && bolt.remaining > 0 && bolt.remaining < .32)
    const enemies = run.enemies.filter(enemy => liveEnemy(run,enemy))
    const melee = enemies.some(enemy => enemy.front === view && !enemy.warp && !enemy.waitingBoss
        && enemy.depth <= Rules.enemyTypes[enemy.type].reach && Rules.charging(enemy) && enemy.attack < .34 && enemy.attack > 0)
    const guard = !run.hypnosis && (shot || melee) && (run.shield.raised || Rules.shieldCharge(run)>=.20)
    enemies.sort((a,b) => threat(run,b) - threat(run,a))
    const local = enemies.find(enemy => enemy.front === view && !enemy.warp && !enemy.waitingBoss && !Rules.ghosted(enemy))
    const destination = seal ? "down" : !local && !run.hypnosis && enemies[0]?.front
    if (destination && destination !== view)
        return {direction:Rules.directionToward(view,destination),guard:seal ? false : !!guard}
    if (local) {
        const part = local.turrets && Ship.remaining(local)[0]
        const point = part ? {lane:part.lane,elevation:Rules.elevation(local)+part.height,depth:local.depth-110} : Rules.arcPoint(local)
        return {point:point,id:part ? part.targetId : local.id,enemy:local,guard:!!guard,seal:seal}
    }
    const gift = run.gifts.find(item => item.front === view)
    const point = gift ? {lane:gift.lane,elevation:gift.elevation ?? -68,depth:gift.depth} : null
    return {point:point,id:gift?.id,guard:!!guard,seal:seal}
}
