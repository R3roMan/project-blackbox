.pragma library
.import "Rules.js" as Rules
.import "Loadout.js" as Gear
.import "Encounters.js" as Mission
.import "Elements.js" as Elements
.import "Pets.js" as Pets
.import "Conditions.js" as Conditions
.import "Meta.js" as Meta

var phases = ["ready","combat","between","reward","bossReward","shop"]

function plain(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value)
}

function safeTree(value, depth, budget) {
    if (--budget.left < 0 || depth > 24)
        return false
    if (value === null || typeof value === "boolean")
        return true
    if (typeof value === "number")
        return Number.isFinite(value) && Math.abs(value) <= 1e12
    if (typeof value === "string")
        return value.length <= 4*1024*1024
    if (Array.isArray(value))
        return value.length <= 2048 && value.every(function(entry) {return safeTree(entry,depth+1,budget)})
    if (!plain(value))
        return false
    return Object.keys(value).every(function(key) {
        return key.length <= 120 && !["__proto__","constructor","prototype"].includes(key)
            && safeTree(value[key],depth+1,budget)
    })
}

function parse(text) {
    if (typeof text !== "string" || text.length > 4*1024*1024)
        return null
    try {
        const data = JSON.parse(text)
        return safeTree(data,0,{left:120000}) ? data : null
    } catch (error) {
        return null
    }
}

function shape(value, sample) {
    if (sample === null)
        return value === null || plain(value)
    if (Array.isArray(sample))
        return Array.isArray(value)
    if (plain(sample)) {
        return plain(value) && Object.keys(sample).every(function(key) {
            return value[key] === undefined || shape(value[key],sample[key])
        })
    }
    return typeof value === typeof sample
}

function defaults(sample, value) {
    const result = Object.assign({},value)
    for (const key of Object.keys(sample)) {
        result[key] = value[key] === undefined ? sample[key]
            : plain(sample[key]) ? defaults(sample[key],value[key]) : value[key]
    }
    return result
}

function validMetrics(value) {
    return plain(value) && Object.keys(value).every(function(key) {
        return /^[A-Za-z0-9_]+$/.test(key) && typeof value[key] === "number" && value[key] >= 0
    })
}

function validItem(item, group) {
    return plain(item) && !!Gear.catalogs[group][item.id] && Number.isInteger(item.level) && item.level >= 0 && item.level <= 3
        && shape(item,Gear.makeItem(item.id))
}

function validEnemy(entry) {
    return plain(entry) && !!Mission.enemyTypes[entry.type] && Mission.fronts.some(function(front) {return front.id === entry.front})
        && Number.isFinite(entry.id) && Number.isFinite(entry.hp) && Number.isFinite(entry.depth)
        && Number.isFinite(entry.age) && Number.isFinite(entry.attack) && Number.isFinite(entry.barrier)
        && (entry.type !== "hasasasa" || Array.isArray(entry.turrets) && entry.turrets.length === 3
            && entry.turrets.every(function(part) {return plain(part) && Number.isFinite(part.hp) && Number.isFinite(part.targetId)}))
        && (entry.type !== "reapfast" || Array.isArray(entry.fangs) && entry.fangs.length === 3
            && entry.fangs.every(function(fang) {return plain(fang) && Number.isFinite(fang.hp) && Number.isFinite(fang.id)}))
        && plain(entry.elements) && shape(entry.elements,Elements.fresh())
}

function validStage(stage) {
    return stage === null || plain(stage) && Number.isInteger(stage.wave) && Number.isFinite(stage.enemyCount)
        && (stage.night===undefined || ["night","bloodMoon"].includes(stage.night) && stage.skySeconds>=1 && Number.isFinite(stage.skySeconds))
        && Array.isArray(stage.groups) && stage.groups.every(function(group) {return !!Mission.enemyTypes[group.type]
            && Number.isInteger(group.count) && group.count > 0}) && Array.isArray(stage.schedule) && plain(stage.ranks)
}

function decodeRun(text, unlocks) {
    const saved = parse(text)
    if (!plain(saved) || saved.version !== 1 || !plain(saved.run))
        return null
    const data = saved.run
    if (!Number.isInteger(data.seed) || !Number.isInteger(data.wave) || data.wave < 0 || data.wave > 10000
        || !phases.includes(data.phase) || !Mission.difficulties[data.difficulty] || !validMetrics(data.metrics))
        return null
    const fresh = Rules.create(data.seed,unlocks || [])
    fresh.nextStage = null
    if (!shape(data,fresh) || !plain(data.slots) || !Array.isArray(data.inventory) || data.inventory.length > Gear.inventoryLimit)
        return null
    for (const group of Object.keys(Gear.limits)) {
        const slots = data.slots[group]
        if (!Array.isArray(slots) || slots.length < 1 || slots.length > Gear.limits[group])
            return null
        if (!slots.every(function(slot) {
            return plain(slot) && (slot.item === null || validItem(slot.item,group))
                && (!slot.power || Gear.slotPowers[group].some(function(power) {
                    return power.id === slot.power && Number.isInteger(slot.powerLevel) && slot.powerLevel >= 0 && slot.powerLevel <= 3
                }))
        }))
            return null
    }
    if (!data.slots.weapon.some(function(slot) {return !!slot.item}) || !Number.isInteger(data.selectedWeapon)
        || !data.slots.weapon[data.selectedWeapon]?.item)
        return null
    if (!data.inventory.every(function(entry) {return entry === null || plain(entry) && Gear.catalogs[entry.group] && validItem(entry.item,entry.group)})
        || !Array.isArray(data.enemies) || !data.enemies.every(validEnemy)
        || !Conditions.entries[data.weatherEffect] || !Mission.fronts.some(function(front) {return front.id === data.playerFront}))
        return null
    for (const key of ["pending","reinforcements"]) {
        if (!Array.isArray(data[key]) || !data[key].every(function(entry) {
            return plain(entry) && !!Mission.enemyTypes[entry.type] && Number.isFinite(entry.lane)
                && Mission.fronts.some(function(front) {return front.id === entry.front})
                && (key !== "pending" || Number.isFinite(entry.at))
        }))
            return null
    }
    if (data.pet && !Pets.pets.some(function(pet) {return pet.id === data.pet.id && !pet.tarot})
        || data.tarotPet && (data.covenant?.tarot!=="major-15" || data.tarotPet.id!=="jacko"
            || !shape(data.tarotPet,Pets.deploy("jacko"))))
        return null
    if ((data.covenant && !Meta.validTerms(data.covenant)) || (data.attemptId && !Meta.validId(data.attemptId)))
        return null
    if ((data.skyProgress!==undefined && (data.skyProgress<0 || data.skyProgress>1))
        || (data.skyPhase && !["daytime","sunset","night","bloodMoon","sunrise"].includes(data.skyPhase))
        || (data.skyClearing && (!data.stage?.night || data.phase!=="combat"))) return null
    if (data.shopCapacity!==undefined && (!Number.isInteger(data.shopCapacity) || data.shopCapacity<5 || data.shopCapacity>8))
        return null
    if (data.shopQuality!==undefined && (!Number.isInteger(data.shopQuality) || data.shopQuality<0 || data.shopQuality>3))
        return null
    if (!validStage(data.stage) || !validStage(data.nextStage) || !data.bolts.every(function(bolt) {
        return plain(bolt) && Number.isFinite(bolt.id) && Number.isFinite(bolt.remaining) && !!Mission.enemyTypes[bolt.source]
    }) || !data.shopStock.every(function(card) {
        return plain(card) && typeof card.id === "string" && typeof card.title === "string" && Number.isFinite(card.cost)
            && (card.action !== "gear" || Gear.catalogs[card.group] && !!Gear.catalogs[card.group][card.gearId])
    }))
        return null
    if (data.health <= 0 || data.gold < 0 || !plain(data.cooldowns) || !plain(data.taxedCooldowns)
        || ![data.cooldowns,data.taxedCooldowns].every(function(map) {return Object.values(map).every(function(value) {return typeof value === "number" && value >= 0})}))
        return null
    const run = defaults(fresh,data)
    run.unlocks = Array.from(new Set((unlocks || []).concat(run.debugUnlockAll ? run.unlocks : [])))
    run.careerUnlocks = unlocks || []
    run.cues = []
    run.cue = ""
    run.note = ""
    run.shield.held = run.shield.raised = false
    run.viewReady = true
    if (run.training && !run.training.lessonMap) {
        if (run.training.step>=4) run.training.step+=2
        run.training.lessonMap=2
    }
    // Convert a checkpoint from before weather and sky were separate.
    for (const stage of [run.stage,run.nextStage]) {
        if (!stage || stage.night) continue
        stage.night=Conditions.isNight(stage.weather) ? stage.weather : "night"
        stage.skySeconds=Math.max(12,(stage.schedule[stage.schedule.length-1]?.at || 0)/.70+3)
        if (["night","bloodMoon","sunrise","sunset"].includes(stage.weather)) stage.weather="clear"
    }
    if (run.phase==="combat" && data.skyProgress===undefined && run.stage) {
        run.skyProgress=Math.min(1,run.waveTime/run.stage.skySeconds)
        run.skyPhase=Conditions.daypart(run.skyProgress,run.stage.night)
        run.bloodMoonSeen=data.weatherEffect==="bloodMoon"
        run.weatherEffect=run.stage.weather
    }
    // Older checkpoints used one stock position for the counter expansion.
    if (run.phase === "shop" && run.shopStock.some(function(card) {return card.id === "expand-counter"})) {
        run.shopStock = run.shopStock.filter(function(card) {return card.id !== "expand-counter"})
        const listingRandom = {rng: (run.rng ^ 0x6eba65d1) >>> 0}
        const existing = run.shopStock.map(function(card) {return card.id})
        const missing = Math.max(0,run.shopCapacity-run.shopStock.length)
        run.shopStock.push(...Gear.makeShop(run,function() {return Rules.random(listingRandom)},existing,missing))
    }
    if (run.lunge) {
        run.lunge.gun = Gear.current(run)
        run.lunge.weapon = Gear.weapons[run.lunge.gun.id]
    }
    return run
}

function encodeRun(run) {
    if (!phases.includes(run.phase) || run.health <= 0)
        return ""
    return JSON.stringify({version:1,savedAt:new Date().toISOString(),run:run})
}

function savedChoice(current, previous, unlocks) {
    for (const candidate of [current,previous]) {
        if (!candidate) continue
        const run = decodeRun(candidate,unlocks)
        if (run) {
            return {data:candidate,wave:run.wave || run.startAt,difficulty:Mission.difficulty(run.difficulty).title,
                phase:run.phase,debug:run.debug,training:!!run.training,attemptId:run.attemptId,restored:candidate!==current}
        }
    }
    return null
}

function bundle(profile, discoveries, override, display, sound, motion, runSave, vault) {
    return JSON.stringify({format:"PROJECT-BLACKBOX",version:1,exportedAt:new Date().toISOString(),
        profile:profile,discoveries:discoveries,achievementsOverride:override,display:display,sound:sound,motion:motion,runSave:runSave,vault:vault})
}

function decodeBundle(text) {
    const data = parse(text)
    if (!plain(data) || data.format !== "PROJECT-BLACKBOX" || data.version !== 1 || !validMetrics(data.profile)
        || !plain(data.discoveries) || !Array.isArray(data.discoveries.enemies) || !Array.isArray(data.discoveries.abilities)
        || !data.discoveries.enemies.every(function(id) {return !!Mission.enemyTypes[id]})
        || !data.discoveries.abilities.every(function(id) {return !!Gear.activeAbilities[id] || !!Gear.passives[id]
            || Object.values(Gear.slotPowers).some(function(powers) {return powers.some(function(power) {return power.id === id})})})
        || typeof data.achievementsOverride !== "boolean" || typeof data.sound !== "boolean" || typeof data.motion !== "boolean")
        return null
    const d = data.display
    if (!plain(d) || !["fill","fit","stretch"].includes(d.framing) || ![0,1080,1440,2160].includes(d.quality)
        || typeof d.zoom !== "number" || d.zoom < 1 || d.zoom > 1.4 || typeof d.mouseTurns !== "boolean"
        || ![0,1,2].includes(d.detail) || !["cinematic","soft"].includes(d.transitionStyle)
        || typeof d.transitionStrength !== "number" || d.transitionStrength < .4 || d.transitionStrength > 1.4)
        return null
    if (d.frameLimit===undefined) d.frameLimit=60
    if (d.showTimer===undefined) d.showTimer=false
    if (!Number.isInteger(d.frameLimit) || d.frameLimit<20 || d.frameLimit>240 || typeof d.showTimer!=="boolean") return null
    if (d.textScale!==undefined && ![1,1.15,1.3,1.45].includes(d.textScale)) return null
    if (d.autoSave!==undefined && typeof d.autoSave!=="boolean") return null
    if (data.runSave !== "" && !decodeRun(data.runSave,[]))
        return null
    if (data.vault!==undefined && !Meta.decode(data.vault)) return null
    return data
}
