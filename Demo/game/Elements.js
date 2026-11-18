.pragma library

var kinds = {
    burn: { title:"Burn", color:"#ff8c54", damage:[0,.85,1.45,2.15], duration:[0,3.6,5.4,7.2] },
    freeze: { title:"Frost", color:"#93ddff", chance:[0,.065,.12,.19], slow:[0,.20,.30,.43], duration:[0,2.7,3.2,3.8] },
    explosive: { title:"Explosive", color:"#ffc576", damage:[0,5,8.5,13], radius:[0,240,345,460] },
    electric: { title:"Electric", color:"#d2a3ff", passes:[0,1,2,4], retain:[0,.50,.58,.66], radius:[0,185,200,215] },
    weaken: { title:"Weaken", color:"#e5a3ff", penalty:[0,.18,.30,.44], duration:[0,4,5,6] },
    stun: { title:"Stun", color:"#ffde91", duration:[0,1,1.45,1.9] },
    blind: { title:"Blindness", color:"#b6afc5", intensity:[0,.48,.68,.88], duration:[0,3.5,4.5,6], miss:[0,.08,.17,.30] },
    poison: { title:"Poison", color:"#a8ed6a", rate:[0,.01,.02,.03], duration:[0,6.5,7.5,8.5] },
    sticky: { title:"Sticky", color:"#dcfa70", duration:[0,1.6,2.3,3.3] },
    wind: { title:"Wind knockback", color:"#abffda", push:[0,110,190,270] }
}

function fresh() {
    return { burn:0, burnLeft:0, burnTick:0, frost:0, frostLeft:0, frozen:0, explosive:0,
        weaken:0, weakenLeft:0, stunned:0, stunGate:0, blind:0, blindLeft:0,
        poison:0, poisonLeft:0, poisonDuration:0, poisonTick:0, poisonLoss:0,
        sticky:0, stickyLeft:0, stickyGuard:0 }
}

function clearPoison(state) {
    state.poison = state.poisonLeft = state.poisonDuration = state.poisonTick = state.poisonLoss = 0
}

function apply(state, kind, level, random, perks) {
    const data = kinds[kind]
    if (!data || level < 1)
        return
    const tier = Math.min(3, level)
    const bonus = perks || {}
    if (kind === "burn") {
        state.frost = state.frostLeft = state.frozen = 0
        if (!state.burnLeft)
            state.burnTick = .60
        state.burn = Math.max(state.burn, tier)
        state.burnLeft = Math.max(state.burnLeft, data.duration[tier] + (bonus.duration || 0))
    } else if (kind === "freeze") {
        state.burn = state.burnLeft = state.burnTick = 0
        state.frost = Math.max(state.frost, tier)
        state.frostLeft = Math.max(state.frostLeft,(data.duration[tier] + (bonus.duration || 0))*(bonus.durationScale || 1))
        if (bonus.preventFreeze) return
        if (bonus.forceFreeze) {
            state.frostLeft = 2*(bonus.durationScale || 1)
            state.frozen = state.frostLeft
        } else if (random() < Math.min(.36, (bonus.freezeChance ?? data.chance[tier]) + (bonus.chance || 0)))
            state.frozen = 2*(bonus.durationScale || 1)
    } else if (kind === "explosive") {
        state.explosive = Math.max(state.explosive, tier)
    } else if (kind === "stun") {
        if (!state.stunGate) {
            state.stunned = bonus.stunDuration || data.duration[tier]
            state.stunGate = state.stunned + 1.65
        }
    } else if (kind === "poison") {
        if (state.poison >= tier)
            return
        const duration = data.duration[tier] * (bonus.durationScale || 1)
        const elapsed = state.poisonDuration - state.poisonLeft
        if (!state.poison)
            state.poisonTick = 1
        state.poison = tier
        state.poisonDuration = Math.max(state.poisonDuration, duration)
        state.poisonLeft = state.poisonDuration - elapsed
    } else if (kind === "sticky") {
        if (state.sticky < tier && (state.sticky || !state.stickyGuard)) {
            state.sticky = tier
            state.stickyLeft = data.duration[tier]
            state.stickyGuard = state.stickyLeft + 1.5
        }
    } else if (kind === "weaken" || kind === "blind") {
        const timer = kind + "Left"
        state[kind] = Math.max(state[kind], tier)
        state[timer] = Math.max(state[timer], Math.max(.5,(bonus.durationScale || 1)*data.duration[tier]+(bonus.duration || 0)))
    }
}

function advance(state, dt) {
    state.frozen = Math.max(0, state.frozen - dt)
    state.stunned = Math.max(0, state.stunned - dt)
    state.stunGate = Math.max(0, state.stunGate - dt)
    state.frostLeft = Math.max(0, state.frostLeft - dt)
    if (!state.frostLeft)
        state.frost = 0
    for (const effect of ["weaken", "blind", "sticky"]) {
        const timer = effect + "Left"
        state[timer] = Math.max(0, state[timer] - dt)
        if (!state[timer])
            state[effect] = 0
    }
    state.stickyGuard = Math.max(0, state.stickyGuard - dt)
    if (state.poisonLeft > 0) {
        state.poisonTick -= Math.min(dt, state.poisonLeft)
        const ticks = Math.max(0, Math.floor(1 - state.poisonTick + 1e-7))
        if (ticks) {
            state.poisonTick += ticks
            state.poisonLoss += ticks * kinds.poison.rate[state.poison]
        }
        state.poisonLeft = Math.max(0, state.poisonLeft - dt)
        if (state.poisonLeft <= 1e-7)
            clearPoison(state)
    }

    const burnTime = Math.min(dt, state.burnLeft)
    if (!burnTime)
        return 0
    state.burnLeft = Math.max(0, state.burnLeft - dt)
    state.burnTick -= burnTime
    const damage = state.burnTick <= 1e-7 ? kinds.burn.damage[state.burn] : 0
    if (damage)
        state.burnTick += .75
    if (!state.burnLeft)
        state.burn = 0
    return damage
}

function pace(state) {
    return 1 - kinds.freeze.slow[state.frost || 0]
}

function damageFactor(state) {
    return 1 - kinds.weaken.penalty[state.weaken || 0]
}

function electricStun(level) {
    return [0,.055,.105,.165][Math.min(3,level)]
}

function healthFactor(state) {
    return 1 - (state.poisonLoss || 0)
}

function visibilityLoss(state) {
    return kinds.blind.intensity[state.blind || 0]
}

function visible(state) {
    if (!state)
        return ""
    if (state.frozen || state.frost)
        return "freeze"
    if (state.burn)
        return "burn"
    if (state.sticky)
        return "sticky"
    if (state.poison)
        return "poison"
    if (state.weaken)
        return "weaken"
    if (state.blind)
        return "blind"
    if (state.stunned)
        return "stun"
    return state.explosive ? "explosive" : ""
}
