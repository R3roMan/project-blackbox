.pragma library
.import "Loadout.js" as Gear
.import "Encounters.js" as Mission
.import "Pets.js" as Pets
.import "Elements.js" as Elements
.import "Selection.js" as Draw
.import "Ship.js" as Ship
.import "Progress.js" as Progress
.import "Defense.js" as Defense
.import "Abyss.js" as Abyss
.import "Conditions.js" as Conditions
.import "SkillArt.js" as SkillArt
.import "Meta.js" as Meta
.import "Tarot.js" as Tarot

var fronts = Mission.fronts
var groundFronts = Mission.groundFronts
var enemyTypes = Mission.enemyTypes

var weapons = Gear.weapons
var rarities = Gear.rarities
var activeAbilities = Gear.activeAbilities
var passives = Gear.passives

var dressing = { id: "dressing", title: "Field dressing", category: "Supply", rarity: "rare",
    description: "Recover up to 40 health immediately. Single use." }
var reserve = { id: "reserve", title: "Reserve cartridges", category: "Supply", rarity: "common",
    description: "Add 3 rounds to your magazine for the next wave." }
var giftNames = { heal: "First aid", speed: "Faster shots", damage: "Charged shots", blast: "Repellent" }
var curses = {
    turn:"Heavy turn", fire:"Slow cycling", damage:"Weakened shots", reload:"Slow reload", cooldowns:"Triggered cooldowns",
    dizzy:"Reversed turns for six seconds"
}
var megaGifts = ["coins", "refresh", "guest", "infinite", "bomb", "overclock"]
var killGold = 12
var killGoldMultiplier = { Normal:1, Ascended:1.7, Nightmare:2.8, Overlord:12 }

function front(id) {
    return Mission.front(id)
}

function turnFrom(view, direction) {
    if (view === "up")
        return direction === "down" ? "front" : view
    if (view === "down")
        return direction === "up" ? "front" : view
    if (direction === "up" || direction === "down")
        return view === "front" ? direction : view
    const index = groundFronts.indexOf(view)
    const step = direction === "left" ? -1 : 1
    return groundFronts[index + step] || view
}

function directionToward(view, targetView) {
    if (view === targetView)
        return ""
    if (view === "up")
        return "down"
    if (view === "down")
        return "up"
    if (!groundFronts.includes(targetView))
        return view === "front" ? targetView : view === "left" ? "right" : "left"
    return groundFronts.indexOf(targetView) < groundFronts.indexOf(view) ? "left" : "right"
}

function create(seed, unlocks) {
    const run = {
        seed:seed >>> 0, rng:seed >>> 0, phase:"ready", time:0, wave:0, waveTime:0,
        difficulty:"normal", startAt:1, debug:false, debugBuild:"standard", debugWeapon:"pistol", debugUnlockAll:false,debugMoney:false,debugWeather:"",debugLayer:"",
        nextStage:null,stage:null,desktop:null,training:null,abilityEvents:[],passiveFxReady:{},salvoTime:0,salvoBonus:0,runeReady:0,sprayTime:0,vampireReady:0,
        careerUnlocks:unlocks || [], playerFront:"front", viewReady:true, weatherEffect:"clear", nextFirePulse:0,
        skyPhase:"daytime",bloodMoonSeen:false,takeoverTime:0,stormAt:0,stormBursts:[],
        attemptId:"",covenant:null,entryWave:1,omenCounts:{},tarotPet:null,rehearsal:false,finishReason:"",
        fieldGems:{},gemSerial:0,lootEvents:[],lootSerial:0,
        abyssSeal:{progress:0,closed:false}, grab:null, hypnosis:null, inkStains:false, dizzyLeft:0,
        fearCut:false, souls:0, scytheSouls:0, boneTime:0, boneRank:0, windAt:20, gustLeft:0,scareTime:0,
        starterChoice:"", starterOffers:[], starterSeed:(seed >>> 0)^0x614f93cd,
        cursed:false, smokes:[], smokeRoster:0, fastTurn:0, remoteGuard:0,
        health: Gear.startingHealth, gold: 0, kills: 0, slots: Gear.starter(), inventory:Array(Gear.startingInventorySize).fill(null), selectedWeapon: 0, shopStock: [], unlocks: unlocks || [], pet:null, petChoice:"", petOffers:[], guestPet:null, guestTime:0,
        refreshUsed:0, rewireCredit:false, paidRerolls:0, refreshBank:0, frozenOffer:null, shopEdition:0, shopCapacity:5, shopQuality:0, repeatRank:0, nextSeal:0,
        shopStats:{health:0,damage:0,speed:0}, bossOffers:[], boons:{ health:0, damage:0, speed:0 },
        waveSize: 0, barrier: 0, barrierHp: 0, barrierMax: 0, barrierBreak: 0, barrierRefill:0,
        barrierCell:{level:0,hp:0}, stun: 0, distortion: 0, voidStorm:false,
        nextAmmo: 0, bonusAmmo: 0, nextBarrier: 0, nextDamageBoost: 0, fastFire: 0, impactType: "", impactTime: 0, injury: 0, powerFlash: 0,
        giftRate:0, giftDamage:0, infiniteAmmo:0, maxGearTime:0, rumble:0, arcBursts:[],
        frozenFront: "", frozenTime: 0, decoyFront: "", decoyTime: 0,
        cooldowns: {},
        nextId:1, enemies:[], links:[], pending:[], reinforcements:[], bolts:[], gifts:[], offers:[], grenades:[], axes:[], blast:null,
        dodgeWindow:0, turnEvadeUntil:0, dodgeReadyAt:0, dodgeFlash:0, bayonetTime:0,
        parry:0, counterTarget:0, meleeRush:0, honedHit:0, breachRounds:0, lockfeed:0, gore:[], splits:[], holes:[],
        deathCoins:0, coinsSent:0, nextCoin:0, aspect:1.6, guardFlash:0,
        ambientAt:0, ambientRng:(seed >>> 0) ^ 0x7c159e37, splatterAt:0, deathVoiceAt:0,
        lunge:null, meleeImpact:0,soulReturns:[],
        shield:{ level:0,raised:false,held:false,age:0,limit:0,capacity:1,charges:0,cool:0,rejected:0,drainRelief:0,recovery:Defense.modes.standard.cooldown,
            mode:"standard",tint:"#65c8ff",credit:0,blocked:0,absorbed:0,flash:0,bolstered:false },
        criticalSeed:(seed >>> 0) ^ 0xc38eaf17, aimSeed:(seed >>> 0) ^ 0x61c7b172,
        criticalFlash:0, criticalRoll:0, sureAttack:false, sharpenTime:0,
        incomingCriticalUntil:0,incomingCriticalDamage:0,hostileMissUntil:0,hostileMissName:"",lastKillTime:-1,
        lastCritical:0, criticalNumber:0, shieldCrits:0, reflections:[], carefulAim:0, axePower:0, surePower:0,
        elements: Elements.fresh(), burnOrigin: "front", burnSource:"", hexes: {}, taxedCooldowns: {},
        detonations: [], flames: [], venomClouds: [], bursts: [], abilitySchedule: {},
        metrics: {}, progress: 0, hurtThisWave: false, earnedKits: {}, spentGold:0,shopCleared:false,bossHurt:false,
        roster: 0, boltRoster: 0, giftRoster: 0, event: 0, cue: "", cues:[], note: "", noteUntil: 0
    }
    run.petOffers = Pets.draft(run.unlocks, function() { return random(run) }, [])
    run.petChoice = run.petOffers[0]
    run.starterOffers = draftStarters(run,[])
    prepareStage(run)
    return run
}

function draftStarters(run, previous) {
    const rolls = []
    for (let i = 0; i < 4; ++i) {
        run.starterSeed = (Math.imul(1664525,run.starterSeed) + 1013904223) >>> 0
        rolls.push(run.starterSeed / 4294967296)
    }
    return Gear.draftStarters(run.unlocks,rolls,previous)
}

var omenMetrics={kills:"kill",bossKills:"boss",hitShots:"hit",shieldBlocks:"block",parries:"parry",
    seals:"seal",intercepts:"intercept",reloads:"reload",shopBuys:"buy"}

var omenStyle={gold:["coin","mint"],heal:["heal","recover"],cool:["rune","empower"],shield:["guard","shield"],
    fire:["burn","empower"],barrier:["guard","shield"],rounds:["reload","reload"],infinite:["reload","empower"],refresh:["rune","rift"]}

function tarotEvent(run,event,advance) {
    if (!event || !run.covenant || !run.covenant.tarot) return
    const card=Tarot.card(run.covenant.tarot)
    if (!card || !card.rite || card.rite[0]!==event) return
    const before=run.omenCounts[event] || 0
    const count=before+(advance || 1)
    run.omenCounts[event]=count
    if (before>=card.rite[1] || count<card.rite[1]) return
    const effect=Tarot.rite(run,event,card.rite[1])
    if (!effect) return
    let action=effect.action, amount=effect.amount
    if (action==="fortune") {
        const result=run.wave/3%3
        action=["gold","fire","barrier"][result]
        amount=[18,6,1][result]
    }
    switch (action) {
    case "gold":
        run.gold+=amount
        record(run,"goldEarned",amount)
        break
    case "heal":
        run.health=Math.min(Gear.maxHealth(run),run.health+amount)
        break
    case "cool":
        for (const id of Object.keys(run.cooldowns))
            run.cooldowns[id]=Math.max(0,run.cooldowns[id]-amount)
        break
    case "shield":
        run.shield.cool=Math.max(0,run.shield.cool-amount)
        break
    case "fire":
        run.fastFire=Math.max(amount,run.fastFire)
        break
    case "barrier":
        if (run.barrierHp===0) {
            run.barrierMax=0
            raiseBarrier(run,25,1)
        }
        break
    case "rounds": {
        const gun=Gear.current(run)
        if (Gear.usesAmmo(weapons[gun.id]))
            gun.ammo=Math.min(magazine(run)+(event==="wave" ? amount : 0),gun.ammo+amount)
        break
    }
    case "infinite":
        run.infiniteAmmo=Math.max(amount,run.infiniteAmmo)
        break
    case "refresh":
        run.refreshBank=Math.min(5,run.refreshBank+1)
        break
    }
    const style=omenStyle[action]
    if (style && run.phase==="combat")
        passiveVisual(run,"omen",run.playerFront,style[0],style[1],null,"",.28)
    announce(run,null,action==="gold" ? "gold" : action==="barrier" ? "shieldBlock" : "seal")
}

function record(run, key, amount) {
    run.metrics[key] = (run.metrics[key] || 0) + (amount === undefined ? 1 : amount)
    if (key === "goldEarned")
        run.metrics.bestWallet = Math.max(run.metrics.bestWallet || 0,run.gold)
    tarotEvent(run,omenMetrics[key],amount)
    run.progress += 1
}

function spendGold(run, amount) {
    Gear.chargeGold(run,amount)
    run.spentGold += amount
    run.metrics.bestRunSpent = run.spentGold
    run.progress += 1
}

function choosePet(run, id) {
    if (run.phase !== "ready" || !run.petOffers.includes(id))
        return false
    run.petChoice = id
    return true
}

function chooseStarter(run, id) {
    if (run.phase !== "ready" || !run.starterOffers.includes(id))
        return false
    run.starterChoice = id
    return true
}

function configure(run, difficulty, startAt, build) {
    if (run.phase !== "ready" || !Mission.difficulties[difficulty] || startAt !== 1 && (startAt < 10 || startAt > 150 || startAt % 10))
        return false
    run.difficulty = difficulty
    run.startAt = startAt
    run.debug = startAt !== 1
    if (!run.debug) {
        run.debugMoney = false
        run.debugBuild = "standard"
        run.debugWeather = ""
        run.debugLayer = ""
        if (run.debugUnlockAll)
            applyDebugUnlocks(run, false)
    } else if (["standard","star","random","custom"].includes(build)) {
        run.debugBuild = build
    }
    prepareStage(run)
    return true
}

function setDebugWeapon(run,id) {
    if (run.phase!=="ready" || !run.debug || !weapons[id])
        return false
    run.debugBuild="custom"
    run.debugWeapon=id
    return true
}

function setPracticeWeather(run, enabled) {
    if (run.phase !== "ready" || !run.debug)
        return false
    run.debugWeather = enabled ? "bloodMoon" : ""
    run.nextStage = null
    prepareStage(run)
    return true
}

function setPracticeLayer(run, layer) {
    if (run.phase!=="ready" || !run.debug || !["","clear","rain","thunder","fog","winter","inferno","incursion","meteor","windy","glitch","cloudy","heatwave","windyCloudy"].includes(layer)) return false
    run.debugLayer=layer
    run.nextStage=null
    prepareStage(run)
    return true
}

function updateCareerUnlocks(run, unlocks) {
    run.careerUnlocks = unlocks
    if (!run.debugUnlockAll)
        run.unlocks = unlocks
}

function applyDebugUnlocks(run, enabled) {
    if (run.phase !== "ready" || enabled && !run.debug)
        return false
    run.debugUnlockAll = enabled
    run.unlocks = enabled ? Progress.achievements.map(function(item) { return item.reward }) : run.careerUnlocks
    const choice = run.petChoice
    run.petOffers = Pets.draft(run.unlocks, function() { return random(run) }, [])
    run.petChoice = run.petOffers.includes(choice) ? choice : run.petOffers[0]
    run.starterOffers = draftStarters(run,[])
    if (!run.starterOffers.includes(run.starterChoice))
        run.starterChoice = ""
    return true
}

function equipDebugGear(run, group, id, slot) {
    if (!run.debug || !run.debugUnlockAll || !canEditLoadout(run))
        return false
    const card = Gear.catalogs[group] && Gear.catalogs[group][id]
    return !!card && !card.debugOnly && Gear.equip(run, card, slot)
}

function skipSelection(run) {
    if (run.phase === "ready") {
        run.petChoice = ""
        return startWave(run)
    }
    if (run.phase === "bossReward") {
        run.bossOffers = []
        openShop(run)
        return true
    }
    if (run.phase === "shop")
        return leaveShop(run)
    if (run.phase !== "reward")
        return false
    Draw.leaveFrozen(run)
    run.offers = []
    run.phase = "between"
    return true
}

function lookFront(run, next) {
    if (next === run.playerFront || run.lunge || !canTurn(run))
        return false
    run.playerFront = next
    if (rank(run, "slipstream") && run.time >= run.dodgeReadyAt)
        run.turnEvadeUntil = run.time + .29 + Gear.perk(run, "evadeWindow")
    return true
}

function canTurn(run) {
    return run.elements.sticky <= 0 && !run.grab && !run.hypnosis && !run.scareTime
}

function turnInput(run, direction) {
    return run.weatherEffect === "glitch" || run.dizzyLeft > 0
        ? ({up:"down",down:"up",left:"right",right:"left"})[direction] || direction : direction
}

function slotInput(run, index) {
    return run.weatherEffect === "glitch" ? 1-index : index
}

function missChance(run, blind, playerAttack) {
    return 1 - (playerAttack ? .95 : 1) * (1 - (Elements.kinds.blind.miss[blind] || 0)) * (Conditions.hasWeather(run.weatherEffect,run.stage,"windy") ? .85 : 1)
}

function attackMisses(run, blind, playerAttack) {
    const chance = missChance(run,blind,playerAttack)
    if (!chance)
        return false
    run.aimSeed = (Math.imul(1664525,run.aimSeed)+1013904223) >>> 0
    return run.aimSeed / 4294967296 < chance
}

function missFeedback(run, owner, blind) {
    announce(run,owner+" missed"+(Conditions.hasWeather(run.weatherEffect,run.stage,"windy") ? " · high winds" : blind ? " · blindness" : ""),"aimMiss")
}

function hostileMiss(run, attacker, blind) {
    run.hostileMissUntil=run.time+1.05
    run.hostileMissName=attacker.title
    missFeedback(run,attacker.title,blind)
}

function isMarked(enemy) {
    return enemy && (enemy.marked || enemy.mark > 0 || enemy.sightMark > 0 || enemy.criticalMark > 0)
}

function sightLocked(run, id, view) {
    if (!id) return false
    const enemy = target(run,id) || Ship.turretAt(run,id)?.boss || fangAt(run,id,view)?.boss
    return enemy && enemy.front === view && enemy.sightMark > 0
}

function closeAttackHits(run, contact) {
    if (!contact) return false
    const enemy = contact.enemy || contact.tube?.boss || contact.fang?.boss
    return enemy?.sightMark > 0 || !attackMisses(run,attackBlindRank(run),true)
}

function criticalRoll(run, chance) {
    if (chance <= 0)
        return false
    run.criticalSeed = (Math.imul(1664525, run.criticalSeed) + 1013904223) >>> 0
    return run.criticalSeed / 4294967296 < chance
}

function criticalProfile(run, weapon) {
    return {
        chance:.05 + (weapon.crit || 0) + rank(run,"criticalLens")*.07 + Gear.perk(run,"critChance")
            + (run.boneTime > 0 ? .24 + (run.boneRank-1)*.045 : 0)
            + Gear.kitBonus(run,"crit",weapon.id) + Gear.passiveSockets(run,"critical",.06) + Tarot.value(run,"critChance"),
        power:1.5 + rank(run,"deepCut")*.30 + Gear.perk(run,"critPower") + Gear.kitBonus(run,"critPower",weapon.id)
            + (run.boneTime > 0 ? .52 + (run.boneRank-1)*.14 : 0) + Tarot.value(run,"critPower")
    }
}

function weaponCritical(run, weapon, gun, enemy) {
    const base = criticalProfile(run,weapon)
    const chance = base.chance + (run.criticalRoll > 0 ? .36 : 0)
        + (enemy && enemy.criticalMark > 0 ? .27 : 0)
        + (isMarked(enemy) ? Gear.weaponSocket(run).markCrit || 0 : 0)
    const forced = run.sureAttack
    const boost = forced ? run.surePower : 0
    run.sureAttack = false
    run.surePower = 0
    return forced || criticalRoll(run,Math.min(.83,chance)) ? base.power + boost : 1
}

function criticalHit(run, damage, killed) {
    if (run.criticalFlash <= .45)
        announce(run, null, "landedCritical")
    run.criticalFlash = .60
    run.lastCritical = damage
    run.criticalNumber = damage
    record(run, "criticalHits")
    if (killed) {
        record(run, "criticalKills")
        const fuel = rank(run,"critFuel")
        if (fuel)
            run.fastFire = Math.max(run.fastFire, 1.25 + fuel*.50)
    }
}

function shieldMode(run) {
    const transformation = run.slots.passive.find(function(slot) {
        return slot.item && Defense.modes[slot.item.id]
    })
    return transformation ? transformation.item.id : "standard"
}

function shieldCharge(run) {
    return Math.max(0,Math.min(1,1-run.shield.cool/run.shield.recovery))
}

function raiseShield(run) {
    const guard = run.shield
    if (!canAct(run) || run.hypnosis || guard.raised)
        return false
    const charge=shieldCharge(run)
    if (charge+1e-7 < Defense.raiseThreshold) {
        guard.rejected=.38
        return false
    }
    const mode = shieldMode(run)
    const spec = Defense.modes[mode]
    const upgrades = Math.max(0,rank(run,mode)-1)
    guard.limit = spec.limit + upgrades*.12 + Gear.perk(run,"shieldLimit")
    guard.capacity = spec.hits + Number(guard.level >= 2) + Number(rank(run,"guardSeam") >= 3) + Gear.kitBonus(run,"shieldHits")
    guard.recovery = Math.max(2.45,spec.cooldown - upgrades*.25 - guard.level*.65 - rank(run,"guardSeam")*.45
        - Gear.perk(run,"shieldCool") - Gear.kitBonus(run,"shieldCooldown") - Gear.passiveSockets(run,"shieldRecovery",.85) - Meta.benefits(run).shield - Tarot.value(run,"shield"))
    guard.cool = (1-charge+Defense.raiseCost)*guard.recovery
    guard.mode = mode
    guard.tint = spec.tint
    guard.raised = true
    guard.charges = guard.capacity
    guard.age = guard.blocked = guard.flash = guard.drainRelief = 0
    guard.parried = false
    guard.bolstered = false
    Gear.current(run).burstLeft = 0
    announce(run, spec.title + " raised", "fieldGuard")
    return true
}

function isTimedParry(run, extraWindow) {
    return run.shield.raised && run.shield.age <= .20+Meta.benefits(run).parry+Tarot.value(run,"parry")+Gear.perk(run,"parryWindow")+(extraWindow || 0)
}

function lowerShield(run) {
    const guard = run.shield
    if (!guard.raised)
        return
    guard.raised = false
    guard.charges = 0
}

function holdShield(run, held) {
    if (held===run.shield.held) return
    run.shield.held = held
    if (held)
        raiseShield(run)
    else
        lowerShield(run)
}

function tickShield(run, dt) {
    const guard = run.shield
    guard.flash = Math.max(0, guard.flash - dt)
    guard.rejected = Math.max(0,(guard.rejected || 0)-dt)
    if (guard.raised) {
        guard.age += dt
        const relaxed=Math.min(dt,guard.drainRelief || 0)
        guard.drainRelief=Math.max(0,(guard.drainRelief || 0)-dt)
        guard.cool=Math.min(guard.recovery,guard.cool+(dt-relaxed*.6)*guard.recovery/guard.limit)
        if (guard.cool>=guard.recovery-1e-7) lowerShield(run)
    } else {
        guard.cool = Math.max(0,guard.cool - dt)
    }
}

function blockWithShield(run, amount, origin, type, payload, projectile, critical) {
    const guard = run.shield
    guard.flash = .38
    guard.blocked += 1
    guard.absorbed = Math.min(100,guard.absorbed + amount * (critical ? 1.5 : 1))
    record(run, "shieldBlocks")
    if (critical) {
        run.shieldCrits += 1
        run.metrics.bestShieldCrits = run.shieldCrits
        run.progress += 1
    }
    if (rank(run,"guardToll") && guard.blocked <= 3) {
        const reward = Math.min(4,rank(run,"guardToll") + 1) + Gear.kitBonus(run,"guardGold")
        run.gold += reward
        record(run, "goldEarned", reward)
        passiveVisual(run,"guardToll",origin,"coin","mint",null,"+"+reward+" GOLD")
    }
    if (guard.mode === "fleetShell")
        run.fastTurn = Math.max(2.3,run.fastTurn)
    if (guard.mode === "jesterWard" && guard.blocked === 1) {
        const luck = sample(run,["heal","speed","gold"])
        const remaining=shieldCharge(run)
        guard.recovery += luck === "heal" ? .45 : luck === "speed" ? -.75 : 1.25
        guard.cool=(1-remaining)*guard.recovery
        guard.tint = luck === "heal" ? "#a9f299" : luck === "speed" ? "#72e5ff" : "#ffcf82"
        if (luck === "heal")
            run.health = Math.min(Gear.maxHealth(run),run.health+7)
        else if (luck === "speed")
            run.fastFire = Math.max(run.fastFire,2.8)
        else {
            run.gold += 7
            record(run,"goldEarned",7)
        }
    }
    const parried = !guard.parried && isTimedParry(run)
    const perfect = guard.mode === "perfectGuard" && parried
    if (parried) {
        guard.parried = true
        guard.cool = 0
        guard.drainRelief=Tarot.value(run,"parryCredit")+(perfect ? .7 : 0)
        record(run,"parries")
        if (rank(run,"parry")) {
            guard.drainRelief += .85 + rank(run,"parry")*.28 + Gear.perk(run,"parryCredit")*.15 + Gear.kitBonus(run,"parryCredit")*.15
            passiveVisual(run,"parry",origin,"guard","shield",null,"PARRY RECHARGE")
        }
    } else {
        const reserve=Math.max(1,guard.charges)
        guard.cool=Math.max(0,Math.min(guard.recovery,guard.cool+Math.max(.10,.33/reserve)*guard.recovery-rank(run,"coolGuard")*.5))
    }
    const foil = rank(run,"foilGuard")
    const mirror = !(payload && payload.mirror) && (perfect
        || criticalRoll(run,Math.min(.68,rank(run,"mirrorGuard")*.22 + Gear.kitBonus(run,"reflect"))))
    const timed = foil && isTimedParry(run,(foil-1)*.035+Gear.perk(run,"shieldParryWindow"))
    const returned = projectile && (timed || mirror) && returnProjectile(run,payload,timed ? 1 : perfect ? .9 : .56)
    const cinder = rank(run,"cinderGuard") > 0 && !projectile
    if (mirror && !returned || cinder) {
        const attacker = payload && payload.sourceId ? target(run,payload.sourceId) : run.enemies.find(function(enemy) {
            return enemy.type === type && enemy.front === origin && enemy.hp > 0 && !enemy.warp
        })
        if (attacker)
            run.reflections.push({ id:attacker.id,damage:mirror ? amount*(perfect ? .9 : .56) : 0,burn:cinder })
    }
    if (guard.cool>=guard.recovery-1e-7)
        lowerShield(run)
    announce(run, returned ? "Projectile returned" : critical ? "Critical hit blocked" : parried ? "Parry" : "Shield blocked the attack",
        parried ? "parryBlock" : returned ? "returnBolt" : "fieldBlock")
}

function refreshRemaining(run, preview) {
    const terms=run.covenant || preview
    const extra=terms && terms.ranks ? terms.ranks.rerolls || 0 : 0
    return Math.max(0,1+extra-run.refreshUsed)+run.refreshBank+Number(!run.rewireCredit && rank(run,"rewire")>0)
}

function rerollPrice(run, preview) {
    return refreshRemaining(run,preview)>0 ? 0 : Math.round(55*Math.pow(1.65,Math.min(32,run.paidRerolls)))
}

function canReroll(run, preview) {
    return Draw.canRefresh(run.phase) && Gear.availableGold(run)>=rerollPrice(run,preview)
        && (run.phase!=="shop" || run.shopStock.some(function(card){return !card.sold && !card.paid && !Draw.isFrozen(run,card)}))
        && (run.phase!=="reward" || run.offers.some(function(card){return Gear.groupOf(card) && !Draw.isFrozen(run,card)}))
}

function refresh(run, preview) {
    if (!canReroll(run,preview)) return false
    const price=rerollPrice(run,preview)
    const pick=function(){return random(run)}
    if (run.phase==="ready") {
        run.petOffers=Pets.draft(run.unlocks,pick,run.petOffers)
        run.petChoice=run.petOffers[0]
        run.starterOffers=draftStarters(run,run.starterOffers)
        run.starterChoice=""
    } else if (run.phase==="bossReward") {
        run.bossOffers=Draw.draftBoss(pick,run.bossOffers)
    } else if (run.phase==="shop") {
        const next=Draw.rerollShop(run,pick)
        if (!next) return false
        run.shopStock=next
        run.shopEdition++
    } else {
        const next=Draw.rerollRewards(run,pick)
        if (next.every(function(card,index){return card.id===run.offers[index].id})) return false
        run.offers=next
    }
    if (price) {
        spendGold(run,price)
        record(run,"shopSpent",price)
        run.paidRerolls++
    } else {
        const terms=run.covenant || preview
        const extra=terms && terms.ranks ? terms.ranks.rerolls || 0 : 0
        if (run.refreshUsed<1+extra) run.refreshUsed++
        else if (run.refreshBank>0) run.refreshBank--
        else run.rewireCredit=true
    }
    announce(run,price ? "Rerolled · "+price+" gold" : "Free reroll used","refresh")
    return true
}

function freezeOffer(run,id) {
    if (!Draw.canFreeze(run)) return false
    const stock=run.phase==="shop" ? run.shopStock : run.offers
    const card=stock.find(function(entry){return entry.id===id})
    if (!Draw.freezable(run,run.phase,card)) return false
    if (Draw.isFrozen(run,card)) {
        run.frozenOffer=null
        announce(run,card.title+" thawed","refresh")
        return true
    }
    run.frozenOffer={phase:run.phase,wave:run.wave,card:Object.assign({},card)}
    announce(run,card.title+" frozen for next "+(run.phase==="shop" ? "shop" : "reward"),"frost")
    return true
}

function beginBossReward(run) {
    run.phase = "bossReward"
    run.bossOffers = Draw.draftBoss(function() { return random(run) }, [])
}

function chooseBoon(run, id) {
    if (run.phase !== "bossReward")
        return false
    const card = run.bossOffers.find(function(offer) { return offer.id === id })
    if (!card)
        return false
    run.boons[id] += card.amount
    if (id === "health")
        run.health = Math.min(Gear.maxHealth(run), run.health + card.amount)
    run.bossOffers = []
    openShop(run)
    announce(run, card.title + " " + card.display, "boon")
    return true
}

function blindness(run) {
    return run.enemies.some(function(enemy) { return enemy.type === "mystery" && enemy.hp > 0 })
        ? .97 : 0
}

function night(run) {
    return Conditions.isNight(run.skyPhase) || Conditions.isNight(run.weatherEffect)
}

function bloodMoon(run) {
    return run.skyPhase === "bloodMoon" || run.weatherEffect === "bloodMoon"
}

function attackBlindRank(run) {
    return Math.max(run.elements.blind,bloodMoon(run) ? 2 : 0)
}

function blindRank(run) {
    return Math.max(attackBlindRank(run),night(run) ? 1 : 0)
}

function skyRanks(dark,red) {
    return {health:dark ? 1.05 : 1, damage:red ? 1.15 : dark ? 1.05 : 1,
        speed:red ? 1.20 : dark ? 1.05 : 1, cadence:red ? 1.10 : dark ? 1.05 : 1}
}

function takeoverActive(run) {
    return run.weatherEffect==="incursion" && !run.abyssSeal.closed
}

function tickTakeover(run,dt) {
    if (!takeoverActive(run)) return false
    const before=Math.ceil(Conditions.abyssSeconds-run.takeoverTime)
    run.takeoverTime=Math.min(Conditions.abyssSeconds,run.takeoverTime+dt)
    const seconds=Math.ceil(Conditions.abyssSeconds-run.takeoverTime)
    if (seconds<=0) {
        record(run,"damageTaken",run.health)
        run.health=0
        run.hurtThisWave=true
        run.phase="defeat"
        run.finishReason="death"
        announce(run,"The Abyss swallowed the Shrine","loss")
        return true
    }
    if (seconds<=10 && seconds<before)
        announce(run,null,seconds<=3 ? "takeoverFinal" : "takeoverTick")
    return false
}

function thunderStrike(run) {
    const viable=run.enemies.filter(function(enemy) {
        const spec=enemyTypes[enemy.type]
        return enemy.hp>0 && !enemy.warp && !enemy.waitingBoss && !enemy.stormCharged && !ghosted(enemy)
            && !["boss","hazard","illusion"].includes(spec.role) && enemy.front===run.playerFront
            && !(enemy.type==="archfellanus" && Abyss.mirror(enemy.age))
    })
    const enemy=viable.length ? viable[Math.floor(ambientRandom(run)*viable.length)] : null
    const point=enemy ? arcPoint(enemy) : {lane:(ambientRandom(run)-.5)*990,elevation:12,depth:1360}
    const empowered=enemy && ambientRandom(run)>=.50
    run.stormBursts.push(Object.assign(point,{id:run.nextId++,front:run.playerFront,life:.68,span:.68,charged:!!empowered,seed:Math.floor(ambientRandom(run)*600)}))
    announce(run,empowered ? enemyTypes[enemy.type].title+" is supercharged" : null,"thunderStrike")
    if (!enemy) return
    if (empowered) {
        enemy.stormCharged=true
        enemy.travelSpeed*=1.5
        enemy.attack/=1.5
        enemy.ranged/=1.5
    } else {
        // The bolt reaches the demon directly and takes down any barrier with it.
        enemy.barrier=0
        wound(run,enemy,enemy.hp+1,"storm")
    }
}

function blindStrength(run, ignoreSky) {
    return Elements.kinds.blind.intensity[ignoreSky ? run.elements.blind : blindRank(run)] * Math.max(.55,1-rank(run,"nightFilter")*.13)
}

function turnDuration(run) {
    const base = Math.max(145, 345 / (1 + run.boons.speed + (run.fastTurn > 0 ? .44 : 0)))
    const weight = run.shield.raised && run.shield.mode === "bulwark" ? 1.34 : 1
    return Math.round(base * (1-Tarot.value(run,"turn")) * weight * (run.hexes.turn ? 1.65 : 1) / Elements.pace(run.elements))
}

function sealTarget(run, view) {
    return view==="down" && (run.wave>=11 || takeoverActive(run)) ? run.abyssSeal : null
}

function blockedBySeal(run, type) {
    const spec = enemyTypes[type]
    return run.abyssSeal.closed && spec.abyss && spec.role !== "boss" && spec.role !== "illusion"
}

function advanceSeal(run, amount) {
    const seal = run.abyssSeal
    if (seal.closed || run.wave<11 && !takeoverActive(run))
        return false
    seal.progress = Math.min(1,seal.progress+amount)
    if (seal.progress < 1-1e-8)
        return true
    seal.progress = 1
    seal.closed = true
    run.pending = run.pending.filter(function(entry) { return !blockedBySeal(run,entry.type) })
    run.reinforcements = run.reinforcements.filter(function(entry) { return !blockedBySeal(run,entry.type) })
    record(run,"seals")
    run.health = Math.min(Gear.maxHealth(run),run.health + rank(run,"riftHabit")*4)
    announce(run,"Rift sealed for this wave",run.weatherEffect==="incursion" ? "takeoverSeal" : "seal")
    return true
}

function raiseBarrier(run, duration, charges) {
    if (duration <= 0)
        return
    run.barrier = Math.max(run.barrier, duration)
    run.barrierMax = Math.max(run.barrierMax, charges || 2)
    run.barrierHp = run.barrierMax
    run.barrierBreak = 0
    run.barrierRefill = .47
}

function breakBarrier(run, enemy) {
    if (!enemy.barrier)
        return false
    enemy.barrier = 0
    enemy.shatter = .48
    record(run, "shatters")
    return true
}

function barrierCooldown(run) {
    const sources = ["ward", "arcshield", "voidaegis", "threadstep"]
    const timers = run.slots.active.filter(function(slot) { return slot.item && sources.includes(slot.item.id) })
        .map(function(slot) { return activeCooldown(run, slot.item.id) })
    return timers.length ? Math.min(...timers) : -1
}

function enemySize(enemy) {
    return enemyTypes[enemy.type].size * Math.pow(.72, enemy.generation || 0)
}

function rank(run, id) {
    return Gear.passiveRank(run, id)
}

function magazine(run) {
    return Gear.magazine(run)
}

function bossType(wave) {
    return Mission.boss(wave)
}

function isBossWave(wave) {
    return !!bossType(wave)
}

function enemyScale(wave, difficulty) {
    return 1 + Math.floor(wave / 10) * Mission.difficulty(difficulty).scale
}

function waveSize(wave, difficulty) {
    return Mission.waveSize(wave, difficulty)
}

function weather(wave) {
    return Mission.weather(wave)
}

function remainingEnemies(run) {
    return run.pending.reduce(function(total,entry) { return total+(entry.units || 1) },0)
        + run.enemies.filter(function(enemy) { return !enemy.summoned }).length
}

// A freeze, roar and electric strike share one player recovery window.
function playerStatus(run, kind, level, perks) {
    const state = run.elements
    const roll = function() { return random(run) }
    if (kind !== "freeze" && kind !== "stun") {
        Elements.apply(state,kind,level,roll,perks)
        return
    }
    const protectedTime = Math.max(state.stunGate || 0,stunTime(run))
    if (kind === "stun" && protectedTime > 0) return
    const options = Object.assign({},perks)
    options.preventFreeze = protectedTime > 0
    Elements.apply(state,kind,level,roll,options)
    if (!protectedTime && stunTime(run) > 0)
        state.stunGate = stunTime(run) + 2.5
}

function stunTime(run) {
    return Math.max(run.stun, run.elements.stunned,run.elements.frozen)
}

function canAct(run) {
    return run.phase === "combat" && !run.scareTime && stunTime(run) <= 0 && (!run.grab || !run.grab.constrict)
}

function random(run) {
    run.rng = (Math.imul(1664525, run.rng) + 1013904223) >>> 0
    return run.rng / 4294967296
}

function ambientRandom(run) {
    run.ambientRng = (Math.imul(1664525, run.ambientRng) + 1013904223) >>> 0
    return run.ambientRng / 4294967296
}

function sample(run, list) {
    return list[Math.floor(random(run) * list.length)]
}

function announce(run, note, cue) {
    if (note !== null) {
        run.note = note
        run.noteUntil = run.time + 2.3
    }
    run.cue = cue || ""
    run.event += 1
    if (cue) {
        run.cues.push({ id:run.event, cue:cue })
        if (run.cues.length > 16)
            run.cues.shift()
    }
}

function makeSchedule(run) {
    return Mission.planWave(run.wave,run.seed,run.difficulty).schedule
}

function prepareStage(run) {
    const wave=run.phase==="ready" && run.debug ? run.startAt : Math.max(run.wave+1,run.entryWave)
    if (!run.nextStage || run.nextStage.wave !== wave || run.nextStage.difficulty !== run.difficulty)
        run.nextStage = Mission.planWave(wave,run.seed,run.difficulty,run.desktop?.resonance,
            run.debug ? run.debugWeather : "",run.debug ? run.debugLayer : "")
    return run.nextStage
}

function applyCovenant(run,terms) {
    if (!terms || run.debug || run.training || run.covenant) return
    run.covenant=terms
    run.entryWave=Meta.startWave(terms)
    const parcel=terms.pending
    const rarity=parcel.legendary ? "legendary" : parcel.epic ? "epic" : ""
    if (rarity) run.starterChoice=Gear.covenantOffer(run,"weapon",[rarity],0x178ca4)
    if (parcel.basket) {
        run.slots.active[0].item=Gear.makeItem(Gear.covenantOffer(run,"active",["common","rare"],0x30f1e))
        run.slots.passive[0].item=Gear.makeItem(Gear.covenantOffer(run,"passive",["common","rare"],0x99f32))
    }
    run.health=Gear.maxHealth(run)
    run.barrierCell.hp=Meta.benefits(run).barrier
}

function attackInterval(enemy) {
    const creature = enemyTypes[enemy.type]
    const interval = enemy.type === "faeel" ? creature.interval
        : (creature.ship && enemy.turrets ? Ship.frequency(enemy) : creature.interval) * Mission.attackIntervalScale
    return interval/skyRanks(enemy.night,enemy.bloodMoon).cadence/(enemy.stormCharged ? 1.5 : 1)
}

function startWave(run) {
    if (run.phase !== "ready" && run.phase !== "between")
        return false
    const stage = prepareStage(run)
    if (run.phase === "ready") {
        run.pet = run.petChoice ? Pets.deploy(run.petChoice) : null
        if (run.starterChoice)
            run.slots.weapon[0].item = Gear.makeItem(run.starterChoice)
        run.wave=stage.wave-1
        if (run.debug) {
            if (run.debugBuild === "star") {
                run.slots.weapon[0].item = Gear.makeItem("starDestroyerPlus")
                run.health = Gear.maxHealth(run)
            } else if (run.debugBuild === "custom") {
                run.slots.weapon[0].item=Gear.makeItem(weapons[run.debugWeapon] ? run.debugWeapon : "pistol")
            } else if (run.debugBuild === "random") {
                Gear.practiceBuild(run, function() { return random(run) })
            }
        }
    }
    run.phase = "combat"
    run.paidRerolls=0
    run.shield.absorbed = run.shield.cool = run.shield.rejected = run.shield.drainRelief = 0
    run.shield.raised = run.shield.held = false
    run.playerFront = "front"
    run.viewReady = true
    run.abyssSeal = {progress:run.nextSeal,closed:false}
    run.nextSeal = 0
    run.grab = run.hypnosis = null
    run.inkStains = false
    run.dizzyLeft = 0
    run.fearCut = false
    run.souls = run.scytheSouls = run.boneTime = run.gustLeft = 0
    run.scareTime = 0
    run.windAt = 20
    run.cursed = false
    run.smokes = []
    run.smokeRoster += 1
    run.fastTurn = run.remoteGuard = 0
    run.wave += 1
    const carried=Gear.loadRating(run)
    record(run,"loadSamples")
    record(run,"loadBurden",carried.burden)
    run.metrics.bestWave = run.wave
    run.progress += 1
    run.hurtThisWave = false
    run.waveKills = 0
    if (run.pet) {
        run.pet = Pets.deploy(run.pet.id,run.pet.level)
        run.pet.stamina += rank(run,"sparePart") * 2 + Gear.perk(run,"petDuty")
    }
    run.guestPet = null
    run.tarotPet = Tarot.value(run,"jacko") ? Pets.deploy("jacko") : null
    if (run.tarotPet) {
        run.tarotPet.lane=195
        run.tarotPet.elevation=128
        run.tarotPet.next=2.8
    }
    run.omenCounts={}
    run.guestTime = 0
    run.infiniteAmmo = 0
    run.maxGearTime = 0
    run.burnSource = ""
    run.arcBursts = []
    run.rumble = 0
    run.blast = null
    run.elements = Elements.fresh()
    run.hexes = {}
    run.taxedCooldowns = {}
    run.detonations = []
    run.flames = []
    run.venomClouds = []
    run.bursts = []
    run.axes = []
    run.lunge = null
    run.meleeImpact = 0
    holdShield(run,false)
    run.criticalFlash = run.criticalRoll = run.sharpenTime = run.carefulAim = run.axePower = 0
    run.incomingCriticalUntil = run.hostileMissUntil = 0
    run.lastKillTime = -1
    run.sureAttack = false
    run.lastCritical = run.criticalNumber = run.surePower = 0
    run.reflections = []
    run.reinforcements = []
    run.links = []
    run.gore = []
    run.splits = []
    run.holes = []
    run.soulReturns = []
    run.dodgeWindow = run.turnEvadeUntil = run.dodgeFlash = run.bayonetTime = 0
    run.parry = run.counterTarget = run.meleeRush = run.honedHit = run.breachRounds = run.lockfeed = 0
    run.waveTime = 0
    run.abilityEvents=[]
    run.passiveFxReady={}
    run.salvoTime=run.sprayTime=run.vampireReady=0
    run.deathCoins = run.coinsSent = run.guardFlash = 0
    run.nextCoin = rank(run,"deathMint") ? .85 + random(run) * .76 : 0
    run.ambientAt = 4.8 + ambientRandom(run) * 4.4
    run.splatterAt = run.deathVoiceAt = 0
    run.bonusAmmo = run.nextAmmo
    run.nextAmmo = 0
    run.slots.weapon.forEach(function(slot, index) {
        if (slot.item)
            Object.assign(slot.item, Gear.makeItem(slot.item.id), { level:slot.item.level, ammo:Gear.magazine(run, index),
                charge:slot.item.charge || 0, streak:slot.item.streak || 0 })
    })
    run.stun = 0
    raiseBarrier(run, Math.max(run.nextBarrier, rank(run, "plate") * .75), 2)
    run.nextBarrier = 0
    run.distortion = 0
    run.voidStorm = false
    run.fastFire = 0
    run.giftRate = 0
    run.giftDamage = run.nextDamageBoost
    run.nextDamageBoost = 0
    run.frozenTime = 0
    run.decoyTime = 0
    run.impactTime = 0
    run.powerFlash = 0
    run.health = Math.min(Gear.maxHealth(run), run.health + rank(run, "medic") * 6 + Gear.perk(run, "heal") + rank(run,"trainingWheels")*(run.wave<=20 ? 2 : 1))
    run.stage = stage
    run.nextStage = null
    run.pending = stage.schedule.map(function(entry) { return Object.assign({},entry) })
    run.waveSize = stage.enemyCount
    run.weatherEffect = stage.weather
    run.takeoverTime=0
    run.skyPhase=stage.sky
    run.bloodMoonSeen=bloodMoon(run)
    if (run.bloodMoonSeen) {
        record(run,"bloodMoonNights")
        announce(run,null,"bloodMoonArrival")
    } else if (night(run)) {
        announce(run,null,"nightArrival")
    }
    run.stormAt=run.weatherEffect==="thunder" ? 4.6+ambientRandom(run)*3.5 : 0
    run.stormBursts=[]
    run.nextFirePulse = 0
    run.nextFrostPulse = 5
    tarotEvent(run,"wave")
    const sky = Conditions.entries[run.weatherEffect]
    const cue = {inferno:"inferno",incursion:"takeoverWarn",winter:"winterArrival",windy:"windArrival",
        glitch:"glitchArrival",rain:"rainArrival",thunder:"rainArrival",meteor:"meteorArrival"}
    announce(run,"Wave "+run.wave+(sky.id === "clear" ? " incoming" : " · "+Conditions.weatherLabel(sky.id,stage)),cue[sky.id] || "wave")
    return true
}

function spawn(run, entry) {
    const creature = enemyTypes[entry.type]
    if (blockedBySeal(run,entry.type))
        return null
    const preset = Mission.difficulty(run.difficulty)
    const dark = night(run)
    const red = bloodMoon(run)
    const scale = enemyScale(run.wave, run.difficulty) * (entry.tuning || 1) * (dark ? 1.05 : 1)
    const health = creature.health * scale * preset.health
    const enemy = {
        id: run.nextId++, type: entry.type, front: entry.front, lane: entry.lane, depth: creature.distance || Mission.spawnDistance,
        hp:health,maxHp:health,baseHp:health,damage:creature.damage * scale * preset.damage * (red ? 1.15/1.05 : 1),
        travelSpeed:creature.speed * preset.speed * (red ? 1.20 : dark ? 1.05 : 1),
        night:dark,bloodMoon:red,stormCharged:false,crumble:0,
        dodgeIn:0, dodgeOffset:0, dodgeLift:0, dodgeAge:0, dodgeAim:0,
        dodgeLaneGoal:0, dodgeLiftGoal:0, maneuverIn:0,
        lateral:entry.lane || 0, driftHeight:0, driftLane:entry.lane || 0, heightGoal:0,
        fuse:entry.type === "seraphijus" ? 15 : 0, recover:0, anger:false, marked:false,
        attackFlash:0, wreck:0, activeGun:"", cursed:false,
        barrier: (creature.barrier || 0) * (dark ? 1.05 : 1), shatter: 0, attack: 0, summoned: !!entry.summoned, calledSummons: false,
        peonCount:0, peonReadyAt:0, slimeRetreat:false,
        ranged:creature.rangedInterval ? .89 : 0, rangedReady:false, firstStrike:creature.role === "boss",
        beamWarning:0, beamLeft:0, beamTick:0, goldAttackAt:run.time + (creature.beamsEvery || 0),
        stolenGold:0, bloodAt:0, bled:false,
        generation: entry.generation || 0, parent: entry.parent || 0, brood: 9, slow: 0, mark: 0, sightMark:0,
        shiftIn:3, sideIn:creature.role === "boss" ? 4.5 + random(run) * 2.0 : 0,
        sideDirection:0, sideTo:"", retreat:false, elements: Elements.fresh(),
        diagonal: entry.lane >= 0 ? -1 : 1, seal: 0, age: 0, flash: 0, roar: 0, roared: false,
        hitStop:0,hurtFace:0,hurtVoiceAt:0,weaponSource:"",elementWeapon:"",
        warp:0, warpDuration:0, warpKind:"", nextFront:"",
        linked:false, triad:entry.triad || 0, triadHeight:entry.triadHeight || 0,
        sniperHeight:0, sniperPerch:-1, feed:null, feedAfter:run.time + 4.7, feedYaw:0, feedingHeal:0,
        shadeAt:run.time + 15,
        waitingBoss:creature.role === "boss", firstBossView:false, interruptIn:0,
        eyeCount:entry.type === "endme" ? 8 : 0, eyesTime:0, blindStep:0, blindLane:0,
        lureUsed:-1, lureOff:0, inkFired:false, orbAt:0, special:null, lastSpecial:"",
        illusionForm:entry.form || 0,
        soulChannel:false,soulWarm:creature.windup,soulTick:0,stolenHealth:0,scareUsed:false
    }
    if (enemy.type === "princoratus")
        enemy.elements.explosive = 2
    if (run.weatherEffect === "inferno" && !statusImmune(enemy,"burn") && !enemy.waitingBoss) {
        enemy.infernoBurn = true
        Elements.apply(enemy.elements,"burn",1,function() { return random(run) })
    }
    if (entry.type === "hasasasa") {
        enemy.turrets = Ship.arm(health, function() { return run.nextId++ })
        enemy.coreHp = health * .10
    } else if (creature.leviathan) {
        enemy.fangs = [-1,0,1].map(function(side) {
            return {id:run.nextId++,side:side,hp:health*.046,maximum:health*.046,rebuildAt:0}
        })
    }
    if (creature.role !== "boss") {
        if (creature.role !== "illusion")
            beginArrival(enemy,entry.generation ? .38 : .72)
        enemy.attack = attackInterval(enemy)
    }
    run.enemies.push(enemy)
    run.roster += 1
    if (creature.triad && !entry.triad) {
        enemy.triad = enemy.id
        enemy.triadHeight = 135
        for (const shift of [-148, 148]) {
            spawn(run, Object.assign({},entry,{ summoned:!!entry.summoned,triad:enemy.triad,lane:enemy.lane+shift,triadHeight:-78 }))
        }
    }
    if (creature.role === "boss") {
        announce(run, creature.title + " incoming · " + front(enemy.front).title, "bossSiren")
        if (run.playerFront === enemy.front && run.viewReady)
            engageBoss(run,enemy)
    }
    else if (enemy.type === "mystery")
        announce(run, "A shadow entered the Abyss", "shade")
    else if (enemy.type === "gojemarus")
        announce(run, "Gojemarus · " + front(enemy.front).title, "warning")
    else if (creature.role !== "illusion")
        announce(run, null, enemy.type === "crufixicatus" ? "crufiWeep" : enemy.type === "lalaBubu" ? "lalaLaugh" : creature.abyss ? "voidArrival"
            : creature.angel || creature.role === "angel" ? "angelArrival" : creature.role === "alien" ? "alienArrival" : "arrive")
    return enemy
}

function beginArrival(enemy, length) {
    const spec = enemyTypes[enemy.type]
    beginWarp(enemy,spec.leviathan ? "rise" : Abyss.startsFromPool(spec) ? "liquid"
        : spec.angel || spec.role === "angel" ? "divine" : spec.role === "alien" ? "alienArrival" : "spawn",length)
}

function engageBoss(run, enemy) {
    if (!enemy.waitingBoss)
        return
    enemy.waitingBoss = false
    enemy.firstBossView = true
    run.bossHurt = false
    enemy.engagedAt=run.waveTime
    enemy.shadeAt = run.time+15
    if (enemy.type === "hasasasa")
        beginWarp(enemy,"drop",2.45)
    else
        beginArrival(enemy,enemy.type === "reapfast" ? 3.85 : 1.39)
    run.rumble = enemy.type === "reapfast" ? .95 : .54
    announce(run,enemyTypes[enemy.type].title+" entering","summon-"+enemy.type)
}

function summon(run, entry) {
    if (blockedBySeal(run,entry.type))
        return false
    if (!run.reinforcements.length && roomToSpawn(run,entry))
        spawn(run, entry)
    else
        run.reinforcements.push(entry)
    return true
}

function roomToSpawn(run, entry) {
    const total=run.training ? 5 : Mission.maxConcurrent(run.wave,run.difficulty)
    return run.enemies.length + (enemyTypes[entry.type].triad ? 3 : 1) <= total
}

function rebuildLinks(run) {
    run.links = []
    for (const enemy of run.enemies)
        enemy.linked = false
    const magnets = run.enemies.filter(function(enemy) { return enemy.triad > 0 && enemy.hp > 0 && !enemy.warp })
    if (!magnets.length)
        return
    const live = run.enemies.filter(function(enemy) { return enemy.hp > 0 && !enemy.warp })
    for (const magnet of magnets) {
        for (const ally of live) {
            if (ally === magnet || ally.front !== magnet.front)
                continue
            if (ally.triad === magnet.triad) {
                if (magnet.id < ally.id)
                    run.links.push({ a:magnet.id,b:ally.id,front:magnet.front,triangle:true })
            } else if (Math.hypot(ally.depth-magnet.depth,lanePosition(ally)-lanePosition(magnet),
                elevation(ally)-elevation(magnet)) <= 325) {
                ally.linked = true
                if (!ally.triad || magnet.id < ally.id)
                    run.links.push({ a:magnet.id,b:ally.id,front:magnet.front,triangle:false })
            }
        }
    }
}

function broodCount(run, parent) {
    return run.enemies.concat(run.reinforcements).filter(function(enemy) { return enemy.parent === parent }).length
}

function beginWarp(enemy, kind, duration) {
    enemy.warpKind = kind
    enemy.warpDuration = duration
    enemy.warp = duration
}

function warpColor(enemy) {
    return enemy.warpKind === "perchOut" || enemy.warpKind === "perchIn" ? "#f99767"
        : enemy.warpKind === "liquid" || enemy.warpKind === "rise" ? "#3b214f"
        : enemy.warpKind === "divine" ? "#ffdb7a" : enemy.warpKind === "alienArrival" ? "#83f4ff" : enemy.type === "mystery" ? "#e5bbff"
        : enemy.warpKind === "flee" ? "#ffe766" : enemy.warpKind === "spawn" ? "#ffb166" : "#bd87ff"
}

function warpFraction(enemy) {
    return enemy.warp > 0 ? enemy.warp / enemy.warpDuration : 0
}

function materialization(enemy) {
    if (enemy.waitingBoss)
        return 0
    if (enemy.warp <= 0)
        return 1
    const fraction = warpFraction(enemy)
    return enemy.warpKind === "departure" || enemy.warpKind === "perchOut" || enemy.warpKind === "flee" || enemy.retreat
        ? fraction : 1 - fraction
}

function elevation(enemy) {
    return baseElevation(enemy) + (enemy.gravityLift || 0) + (enemy.trainingHeight || 0)
        + (enemy.warpKind === "liquid" ? -230*warpFraction(enemy) : enemy.warpKind === "sink" ? -460*(1-warpFraction(enemy))
            : enemy.warpKind === "divine" ? 300*warpFraction(enemy) : 0)
}

function baseElevation(enemy) {
    const role = enemyTypes[enemy.type].role
    if (enemy.type === "veilskate")
        return 120
    if (role === "illusion")
        return (enemy.illusionY || 0)*enemy.depth*1.0634+Math.sin(enemy.age*2.1)*5
    if (enemy.type === "reapfast")
        return -132 - (enemy.warpKind === "rise" ? 910*warpFraction(enemy) : 0)
    if (enemy.type === "tenmani")
        return 37+Math.sin(enemy.age*.95)*102
    if (enemy.type === "lantis" || enemy.type === "nightosphere")
        return 27+Math.sin(enemy.age*1.59)*41
    if (enemyTypes[enemy.type].sniper)
        return (enemy.sniperHeight || 0) + 46 + Math.sin(enemy.age*3)*9
    if (role === "void")
        return -18
    if (enemy.type === "hasasasa")
        return enemy.warpKind === "drop" && enemy.warp > 0 ? 1100 * warpFraction(enemy)
            : enemy.wreck > 0 ? (3.25 - enemy.wreck) * 107 : 32
    if (enemyTypes[enemy.type].battlestar)
        return 44 + Math.sin(enemy.age * 1.14) * 132
    if (enemyTypes[enemy.type].maneuver)
        return (enemy.driftHeight || 0) + (enemy.dodgeLift || 0)
    if (enemy.type === "meteor")
        return 45 + Math.sin(enemy.age * 1.8) * 25
    if (role === "phantom")
        return 18 + Math.sin(enemy.age * 5) * 34 + (enemy.retreat ? (1 - warpFraction(enemy)) * 220 : 0)
    if (role === "gold")
        return Math.sin(enemy.age * 2.9) * 122
    if (enemy.type === "princoratus")
        return -10 + Math.sin(enemy.age * 4.05) * 73
    return (role === "alien" ? 28 : -12) + Math.sin(enemy.age * 4.2) * 9 + (enemy.dodgeLift || 0) + (enemy.triadHeight || 0)
}

function lanePosition(enemy) {
    if (enemy.type === "hallucination")
        return (enemy.illusionX || 0)*enemy.depth*(enemy.illusionAspect || 1.6)*1.0634
    if (enemy.type === "tenmani")
        return enemy.lane + Math.cos(enemy.age*.95)*156
    if (enemy.type === "nightosphere")
        return enemy.lane + Math.sin(enemy.age*.67)*179
    const creature = enemyTypes[enemy.type]
    if (creature.role === "gold")
        return enemy.lane + Math.sin(enemy.age * creature.speed / 132) * 186
    if (enemy.type === "mastafangenbus")
        return enemy.lane + Math.sin(enemy.age * (charging(enemy) ? 1.55 : .95)) * 115
    const shake = creature.shake
    const intensity = Math.max(enemy.flash / 0.14, charging(enemy) ? 0.25 : 0)
    return enemy.lane + (enemy.dodgeOffset || 0) + Math.sin(enemy.age * shake[3]) * shake[0] * intensity
}

function ghosted(enemy) {
    const age = enemy.age + 1e-6
    return enemy.type === "ghorimagous" && age >= 5 && age % 5 < 3
}

function cameraJolt(run) {
    let x = 0
    let y = 0
    if (run.impactTime > 0) {
        const shake = enemyTypes[run.impactType].shake
        const strength = run.impactTime / shake[2]
        const elapsed = shake[2] - run.impactTime
        x = Math.sin(elapsed * shake[3]) * shake[0] * strength
        y = Math.cos(elapsed * shake[3] * 0.78) * shake[1] * strength
    }
    const stunned = stunTime(run)
    if (stunned > 0) {
        x += Math.sin(run.time * 71) * 12 * stunned
        y += Math.cos(run.time * 58) * 17 * stunned
    }
    if (run.rumble > 0) {
        x += Math.sin(run.time * 113) * run.rumble * 6
        y += Math.cos(run.time * 89) * run.rumble * 8
    }
    return { x: x, y: y }
}

function byId(entries, id) {
    return entries.find(function(entry) { return entry.id === id })
}

function target(run, id) {
    return byId(run.enemies, id)
}

function goldPerKill(wave, type) {
    const base = killGold + Math.max(0, Math.floor(wave / 10)) * 2
    const multiplier = type === "gojemarus" ? 5 : type ? killGoldMultiplier[Mission.tier(type)] : 1
    return Math.round(base * multiplier)
}

function lootFlight(run,kind,amount,source,point) {
    run.lootEvents.push(Object.assign({id:++run.lootSerial,kind:kind,amount:amount,front:source.front},point))
    if (run.lootEvents.length>20) run.lootEvents.shift()
}

function bossGems(wave,seed) {
    const roll=Conditions.roll(wave,seed,0x49a13f6f)
    return roll<.016 ? 4 : roll<.13 ? 3 : roll<.44 ? 2 : 1
}

function grantFieldGems(run,kind,amount,source,point) {
    const key=kind+"-"+run.wave
    if (kind==="boss" && run.fieldGems[key]) return
    run.fieldGems[key]=(run.fieldGems[key] || 0)+amount
    run.gemSerial++
    lootFlight(run,"gem",amount,source,point)
}

function remove(run, index, paid, source) {
    if (index < 0 || index >= run.enemies.length)
        return
    const enemy = run.enemies.splice(index, 1)[0]
    if (run.training && enemy.type === "oblogabgalus")
        return
    if (enemy.type === "harvester" && enemy.hp <= 0) {
        const restored = Math.max(0,Math.min(enemy.stolenHealth,Gear.maxHealth(run)-run.health))
        run.health += restored
        run.soulReturns.push(Object.assign(arcPoint(enemy),{front:enemy.front,life:2.5,span:2.5,amount:restored}))
        announce(run,"The stolen souls return · +"+Math.round(restored)+" HP","soulRelease")
    }
    if (enemy.type === "voidGlitch")
        run.voidStorm = false
    if (enemy.type === "hallucination") {
        if (run.hypnosis && --run.hypnosis.left <= 0) {
            run.hypnosis = null
            announce(run,"Hypnosis broken","lureBreak")
        }
        run.roster += 1
        return
    }
    if (enemy.type === "reapfast") {
        const left = run.bolts.filter(function(bolt) { return !bolt.bubble || bolt.sourceId !== enemy.id })
        if (left.length !== run.bolts.length) {
            run.bolts = left
            run.boltRoster += 1
        }
    }
    if (enemy.triad || enemy.linked)
        rebuildLinks(run)
    run.roster += 1
    if (paid === false)
        return
    if (!enemy.bled)
        blood(run, enemy, source, true)
    run.kills += 1
    run.lastKillTime = run.time
    run.waveKills += 1
    record(run, "kills")
    record(run,"enemyKills_"+enemy.type)
    if (enemy.weaponSource && (["gun","burn","electric","grenade","explosion","ability"].includes(source) || enemy.type === "hasasasa"))
        record(run,"weaponKills_"+enemy.weaponSource)
    const current = Gear.current(run)
    const relay = enemy.elements.burn ? rank(run, "thermalRelay") : 0
    const echo = enemy.depth < 445 && enemy.front === run.playerFront ? rank(run, "echoReload") : 0
    if (relay || echo) {
        const before=current.ammo
        current.ammo = Math.min(magazine(run), current.ammo + relay + Number(echo > 0))
        if (echo && current.reload > 0)
            current.reload = Math.max(.01, current.reload - .24 * echo)
        if (current.ammo>before)
            passiveVisual(run,relay ? "thermalRelay" : "echoReload",run.playerFront,"reload","reload",null,"+"+(current.ammo-before)+" ROUNDS")
    }
    const pact = rank(run,"bloodPact")
    if (pact && source === "gun" && run.time >= run.vampireReady) {
        const healed=recoverBlood(run,1.5+pact)
        if (healed>0) passiveVisual(run,"bloodPact",enemy.front,"blood","drain",arcPoint(enemy),"+"+Number(healed.toFixed(1))+" HP")
        run.vampireReady=run.time+1.5
    }
    const battery = rank(run, "wardBattery")
    if (battery && run.waveKills % 6 === 0) {
        raiseBarrier(run, 2.3 + battery * 1.25, 1)
        passiveVisual(run,"wardBattery",run.playerFront,"guard","shield",null,"BARRIER CHARGE")
    }
    const role = enemyTypes[enemy.type].role
    const baseGold = Math.round(goldPerKill(run.wave,enemy.type)
        + rank(run,"liquidAssets") + Gear.passiveSockets(run,"killGold",4))
    const value = bloodMoon(run) ? Math.round(baseGold*1.25) : baseGold
    run.gold += value
    record(run, "goldEarned", value)
    const position=arcPoint(enemy)
    lootFlight(run,"gold",value,enemy,position)
    if (role === "boss") {
        grantFieldGems(run,"boss",bossGems(run.wave,run.seed),enemy,position)
        record(run, "bossKills")
        if (run.wave===100) record(run,"wave100Boss")
        if (bloodMoon(run))
            record(run,"bloodMoonBosses")
        if (run.waveTime-(enemy.engagedAt || 0)<35)
            record(run,"fastBosses")
        if (!run.bossHurt) {
            record(run,"hitlessBosses")
            if (enemy.type === "lucifoverus")
                record(run,"hitlessLuci")
        }
    }
    if (role === "alien")
        record(run, "alienKills")
    if (enemy.type === "papapoganus")
        record(run,"papapoganusKills")
    if (enemy.elements.poison && rank(run,"cleanLungs"))
        run.health=Math.min(Gear.maxHealth(run),run.health+1.5*rank(run,"cleanLungs"))
    if (elementalKill(enemy,"electric") && rank(run,"runeRelay") && run.time>=run.runeReady) {
        for (const slot of run.slots.weapon)
            if (slot.item && weapons[slot.item.id].staff)
                chargeStaff(slot.item,Gear.effectiveWeaponStats(run,slot.item),1)
        run.runeReady=run.time+Math.max(3,8-rank(run,"runeRelay"))
    }
    if (enemy.type === "battlestar")
        record(run, "battlestarKills")
    if (enemy.stolenGold) {
        enemy.returnedCoins = Math.floor(enemy.stolenGold * .60)
        run.gold += enemy.returnedCoins
        announce(run, "Recovered " + enemy.returnedCoins + " stolen gold", "coinReturn")
    }
    if (enemy.type === "mastafangenbus")
        record(run, "spinningBossKills")
    if (enemy.type === "lucifoverus")
        record(run, "lucifoverusKills")
    if (enemy.type === "gojemarus")
        record(run, "gojemarusKills")
    if (enemy.type === "shadow")
        record(run,"shadowKills")
    if (enemy.type === "fearme")
        record(run,"fearmeKills")
    if (rank(run,"soulReaper")) {
        run.souls = Math.min(15,run.souls+1)
        passiveVisual(run,"soulReaper",enemy.front,"void","drain",arcPoint(enemy),run.souls+" SOULS")
    }
    if (source === "pet" || source && typeof source === "object")
        record(run, "petKills")
    const fury = rank(run, "fury")
    if (fury) {
        for (const id of Object.keys(run.cooldowns))
            run.cooldowns[id] = Math.max(0, run.cooldowns[id] - 2 - (fury - 1) * .65)
    }
    if (role !== "boss" && (run.enemies.length || run.pending.length)
        && run.gifts.length < 3 && !run.gifts.some(function(gift) { return gift.front === enemy.front })) {
        const roll = random(run)
        if (roll < .058) {
            const mega = roll < .011
            const cursed = !mega && random(run) < 1 / 6
            const kind=mega && random(run)<.13 ? "gems" : sample(run,mega ? megaGifts : Object.keys(cursed ? curses : giftNames))
            run.gifts.push({ id:run.nextId++, kind:kind,
                mega:mega, cursed:cursed, front:enemy.front, lane:lanePosition(enemy) * .84,
                depth:Math.max(320, enemy.depth), remaining:5, flashes:true })
            run.giftRoster += 1
        }
    }
}

function callGuest(run, view, seconds) {
    const pool = Pets.available(run.unlocks).filter(function(pet) { return !run.pet || pet.id !== run.pet.id })
    const helper = sample(run, pool)
    run.guestPet = Pets.deploy(helper.id)
    run.guestPet.front = view
    run.guestPet.next = 1.5
    run.guestTime = seconds
    return helper.title
}

function giftVisibility(gift) {
    return gift.flashes && gift.remaining <= 3 && Math.floor(gift.remaining*7)%2===0 ? 0 : 1
}

function claimMega(run, gift) {
    switch (gift.kind) {
    case "gems": {
        const gained=1+Math.floor(random(run)*3)
        grantFieldGems(run,"mega",gained,gift,{lane:gift.lane,elevation:gift.elevation ?? -68,depth:gift.depth})
        return "Mega gift · +"+gained+" dark gems"
    }
    case "coins": {
        const value = 100 + Math.floor(random(run) * 61) + Gear.perk(run, "coins")
        run.gold += value
        record(run, "goldEarned", value)
        lootFlight(run,"gold",value,gift,{lane:gift.lane,elevation:gift.elevation ?? -68,depth:gift.depth})
        return "Mega gift · +" + value + " gold"
    }
    case "refresh":
        run.refreshBank += 1
        return "Mega gift · banked a refresh"
    case "guest":
        return "Mega gift · " + callGuest(run, gift.front, 21) + " joins for 21s"
    case "infinite":
        run.infiniteAmmo = 12
        Gear.current(run).reload = 0
        return "Mega gift · infinite rounds for 12s"
    case "overclock":
        run.maxGearTime = 20
        for (let index=0; index<run.slots.weapon.length; ++index) {
            const weapon=run.slots.weapon[index].item
            if (weapon)
                weapon.ammo=Gear.magazine(run,index)
        }
        return "Mega gift · all weapons at maximum upgrade for 20s"
    case "bomb": {
        const targets = run.enemies.filter(function(enemy) { return enemy.front === gift.front && enemy.hp > 0 && !enemy.waitingBoss })
        for (const enemy of targets)
            wound(run, enemy, enemy.hp + enemy.barrier + 1, "mega")
        run.bursts.push({ front:gift.front, lane:gift.lane, depth:gift.depth, elevation:-58, radius:680, life:.61 })
        run.rumble = .74
        return "Mega gift · super bomb"
    }
    }
    return ""
}

function giftCue(gift) {
    return gift.token ? "deathCoin" : gift.mega ? "mega" : gift.cursed ? "curse" : "gift"
}

function redeemCoins(run) {
    if (run.deathCoins < 5)
        return ""
    const targets = run.enemies.filter(function(enemy) { return enemy.hp > 0 && !enemy.warp && !enemy.retreat && !enemy.waitingBoss })
    if (!targets.length)
        return ""
    const enemy = sample(run, targets)
    run.deathCoins -= 5
    wound(run, enemy, enemy.hp * 12 + enemy.barrier + 10, "mega")
    return "Death mint · " + enemyTypes[enemy.type].title + " executed"
}

function stepDeathCoins(run) {
    const claim = redeemCoins(run)
    if (claim)
        announce(run, claim, "deathCoin")
    const level = rank(run, "deathMint")
    if (!level || run.waveTime < run.nextCoin || run.coinsSent >= 11 + Math.min(2, level - 1))
        return
    const destination = sample(run, fronts)
    run.gifts.push({ id:run.nextId++, token:true, front:destination.id,
        lane:(random(run)-.5)*530, elevation:(random(run)-.5)*275, depth:680+random(run)*275,
        remaining:8.2 + Gear.perk(run,"coinTime") + (Gear.hasKit(run,"mintKit") ? 2 : 0) })
    run.coinsSent += 1
    run.nextCoin = run.waveTime + 1.05 + random(run)*.87
    run.giftRoster += 1
}

function claimGift(run, gift) {
    run.gifts.splice(run.gifts.indexOf(gift), 1)
    run.giftRoster += 1
    if (gift.token) {
        run.deathCoins += 1
        passiveVisual(run,"deathMint",gift.front,"coin","mint",gift,run.deathCoins+" / 5 COINS",.05)
        return redeemCoins(run) || "Death coin · " + run.deathCoins + " / 5"
    }
    record(run, "gifts")
    if (gift.mega)
        return claimMega(run, gift)
    if (gift.cursed) {
        if (gift.kind === "dizzy") {
            run.dizzyLeft = Math.max(run.dizzyLeft,6)
            return "Cursed gift · "+curses.dizzy
        }
        run.hexes[gift.kind] = true
        if (gift.kind === "cooldowns") {
            for (const slot of run.slots.active) {
                if (slot.item) {
                    const id = slot.item.id
                    run.taxedCooldowns[id] = Math.max(run.taxedCooldowns[id] || 0, activeAbilities[id].cooldown)
                }
            }
        }
        return "Cursed gift · " + curses[gift.kind]
    }
    switch (gift.kind) {
    case "heal":
        run.health = Math.min(Gear.maxHealth(run), run.health + 8)
        return "Gift · +8 health"
    case "speed":
        run.giftRate = 6
        return "Gift · faster shots for 6s"
    case "damage":
        run.giftDamage = 6
        return "Gift · +2 damage for 6s"
    case "blast": {
        const targets = run.enemies.filter(function(enemy) {
            return enemy.front === gift.front && enemy.warp <= 0 && !ghosted(enemy)
        })
        for (const enemy of targets)
            wound(run, enemy, 5)
        return "Gift · repellent burst"
    }
    }
    return ""
}

function callSummons(run, boss) {
    boss.calledSummons = true
    const pool = Mission.introductions.filter(function(entry) {
        return entry.front !== "up" && entry.front !== "down" && !entry.rare && entry.wave < run.wave
    }).map(function(entry) { return entry.type })
    for (const lane of [-145, 0, 145]) {
        if (!pool.length)
            break
        const type = pool.splice(Math.floor(random(run) * pool.length), 1)[0]
        summon(run, { type:type, front:boss.front, lane:boss.lane + lane, summoned:true,
            tuning:run.wave === 10 ? .72 : 1 })
    }
}

function elementalPerks(run, kind) {
    if (kind === "freeze")
        return { chance:.023 * rank(run, "cryojacket") + (Gear.hasKit(run, "iceCircuit") ? .06 : 0),
            duration:Gear.perk(run, "frostDuration") }
    if (kind === "burn")
        return { duration:Gear.perk(run, "burnDuration") }
    if (kind === "blind")
        return {duration:Gear.kitBonus(run,"blindDuration")}
    return null
}

function statusImmune(enemy, kind) {
    const creature = enemyTypes[enemy.type]
    return !!kind && (creature.immune || creature.poisonImmune && kind === "poison"
        || creature.electricImmune && kind === "electric"
        || creature.explosionImmune && kind === "explosive" || creature.blindImmune && kind === "blind"
        || enemy.type === "iceterapus" && kind === "freeze")
}

function knockBack(run, enemy, distance) {
    const spec = enemyTypes[enemy.type]
    if (!spec.speed || enemy.waitingBoss || enemy.warp)
        return
    enemy.depth = Math.min((spec.distance || Mission.spawnDistance)+480,enemy.depth+distance*windForce(run))
    if (enemy.depth > spec.reach) {
        enemy.attack = Math.max(enemy.attack,spec.windup)
        enemy.attackFlash = 0
        enemy.beamWarning = enemy.beamLeft = 0
        if (enemy.type !== "shadow" || enemy.depth > 1500)
            enemy.special = null
        enemy.soulChannel = false
        enemy.soulWarm = spec.windup
    }
}

function applyKnockback(run, enemy, level, bonus) {
    if (level < 1 || statusImmune(enemy,"wind"))
        return
    const tier = Math.min(3,level + Number(rank(run,"downwind") > 0))
    const distance = Elements.kinds.wind.push[tier] + (bonus || 0) + (Gear.hasKit(run,"windKit") ? 55 : 0)
        + rank(run,"tidalAnchor")*24 + rank(run,"seamAnchor")*18 + Gear.perk(run,"pushDistance") + Gear.kitBonus(run,"pushDistance")
    const before = enemy.depth
    knockBack(run,enemy,distance * (enemyTypes[enemy.type].role === "boss" ? .46 : 1))
    if (enemy.depth > before)
        run.bursts.push(Object.assign(arcPoint(enemy),{front:enemy.front,radius:102+tier*22,life:.31,span:.31,color:"#9bfcdf"}))
}

function windForce(run) {
    return Conditions.hasWeather(run.weatherEffect,run.stage,"windy") ? 1.7 : 1
}

function interruptAttack(enemy) {
    const spec = enemyTypes[enemy.type]
    if (enemy.interruptIn || enemy.attackFlash)
        return false
    if (enemy.special) {
        if (enemy.special.time >= enemy.special.warning)
            return false
        enemy.special.time = 0
        enemy.interruptIn = spec.role === "boss" ? 4.2 : 2.25
        return true
    }
    if (charging(enemy)) {
        enemy.attack = Math.max(enemy.attack,spec.windup+.40)
        enemy.ranged = Math.max(enemy.ranged,1.1)
        if (enemy.beamWarning > 0)
            enemy.beamWarning = Math.max(enemy.beamWarning,.77)
        enemy.interruptIn = spec.role === "boss" ? 4.2 : 2.25
        return true
    }
    return false
}

function applyToEnemy(run, enemy, kind, level, options) {
    if (statusImmune(enemy, kind) || kind === "burn" && Conditions.isRain(run.weatherEffect))
        return
    if (kind === "wind" && level > 0) {
        applyKnockback(run,enemy,level)
        return
    }
    const weatherPerks = kind === "freeze" && Conditions.isRain(run.weatherEffect) ? {forceFreeze:true} : null
    Elements.apply(enemy.elements, kind, level, function() { return random(run) },
        Object.assign({},elementalPerks(run,kind),kind==="burn" ? {duration:.6*rank(run,"slowEmbers")} : null,weatherPerks,options))
    enemy.maxHp = Math.max(1, enemy.baseHp * Elements.healthFactor(enemy.elements))
    enemy.hp = Math.min(enemy.hp, enemy.maxHp)
}

function arcPoint(enemy) {
    return { lane:lanePosition(enemy), elevation:elevation(enemy), depth:enemy.depth }
}

function chainElectric(run, origin, damage, level, extraReach) {
    const spec = Elements.kinds.electric
    const rain = Conditions.isRain(run.weatherEffect)
    const hops = rain ? run.enemies.length : spec.passes[level] + (Gear.hasKit(run, "resonance") ? 1 : 0)
    const radius = spec.radius[level] + Gear.perk(run, "arcRadius") + (extraReach || 0)
    const retain = Math.min(.82, spec.retain[level] + .036 * rank(run, "conductor"))
    const visited = new Set([origin.id])
    const hallucinationsOnly = !!run.hypnosis || origin.type === "hallucination"
    let current = origin
    let charged = damage
    for (let index = 0; index < hops; index += 1) {
        const from = arcPoint(current)
        const nearby = run.enemies.filter(function(enemy) {
            return enemy.hp > 0 && !enemy.warp && !visited.has(enemy.id)
                && !ghosted(enemy) && !enemy.waitingBoss
                && (!hallucinationsOnly || enemy.type === "hallucination")
                && (rain || enemy.front === origin.front && Math.hypot(lanePosition(enemy)-from.lane,elevation(enemy)-from.elevation,
                    (enemy.depth-from.depth)*.76)<=radius)
        })
        if (!nearby.length)
            break
        const enemy = sample(run, nearby)
        charged = rain ? Math.max(damage*.34,charged*retain) : charged*retain
        visited.add(enemy.id)
        const span = .37
        const point = arcPoint(enemy)
        const start = current.front === enemy.front ? from : {lane:point.lane-85,elevation:point.elevation+110,depth:point.depth}
        run.arcBursts.push({ front:enemy.front, from:start, to:point, span:span, life:span + index * .065,
            power:charged / Math.max(.01, damage), hop:index })
        wound(run, enemy, charged, "electric", "electric", level,{weaponId:origin.weaponSource})
        current = enemy
        record(run, "electricJumps")
        run.rumble = Math.max(run.rumble, .19)
    }
}

function recoverBlood(run, amount) {
    const heal = Math.max(0,Math.min(amount,Gear.maxHealth(run)-run.health))
    if (heal > 0) {
        run.health += heal
        run.powerFlash = Math.max(run.powerFlash,.21)
    }
    return heal
}

function feedVeinDrinker(run, amount) {
    const bonus = Gear.kitBonus(run,"vampirism","veinDrinker")
    return recoverBlood(run,Math.min(bonus ? 3.5 : 2.5,amount*(.16+bonus)))
}

function bankDamage(run, enemy, amount) {
    const before = enemy.barrier
    if (!before)
        return amount
    const absorbed = Math.min(before, amount)
    if (absorbed >= before)
        breakBarrier(run, enemy)
    else
        enemy.barrier -= absorbed
    return 0
}

function hitShip(run, enemy, part, damage, critical, weaponId, scoped) {
    if (enemy.waitingBoss || enemy.warp || enemy.wreck || enemy.hp <= 0 || part && part.hp <= 0)
        return ""
    const intact = Ship.remaining(enemy)
    if (!part && intact.length)
        return "Aim at Hasasasa's gun tubes"
    if (scoped) enemy.sightMark = 4
    hurtReaction(run,enemy)
    if (weaponId)
        enemy.weaponSource = weaponId
    const value = bankDamage(run,enemy,damage*(weaponId ? 1+Tarot.value(run,"bossDamage") : 1)
        *((critical || 1)+(weaponId && critical>1 ? Tarot.value(run,"bossCrit") : 0)))
    const hullBefore = part ? part.hp : enemy.coreHp
    if (weaponId === "veinDrinker" && value > 0)
        feedVeinDrinker(run, Math.min(hullBefore, value))
    if (value > 0)
        blood(run, enemy, "ship", false)
    if (part) {
        part.flash = .18
        part.hp = Math.max(0, part.hp - value)
        if (!part.hp) {
            enemy.barrier = enemyTypes.hasasasa.barrier * (enemy.night ? 1.05 : 1)
            enemy.shatter = 0
            enemy.attack = attackInterval(enemy)
            run.rumble = .35
            for (const lane of [-180, 180]) {
                const type = sample(run, ["spartalien","spartalien","spartalien","fizzalien","fizzalien","jon","jon","claptrap"])
                summon(run, { type:type, front:"up", lane:lane, summoned:true, tuning:.74 })
            }
            announce(run, "Gun tube destroyed · incoming ships", "tube")
        }
    } else {
        enemy.coreHp = Math.max(0, enemy.coreHp - value)
    }
    enemy.hp = enemy.coreHp + enemy.turrets.reduce(function(total, tube) { return total + tube.hp }, 0)
    if (critical > 1 && value > 0)
        criticalHit(run, value, enemy.hp <= 0)
    enemy.flash = .14
    if (!enemy.hp) {
        enemy.wreck = 3.25
        run.bolts = run.bolts.filter(function(bolt) { return bolt.source !== "hasasasa" })
        run.boltRoster += 1
        run.rumble = .60
        announce(run, "Hasasasa Forum is breaking up", "wreck")
    }
    return ""
}

var dodgeTimings = [null, { dwell:.35, rest:2.5 }, { dwell:.23, rest:1.88 }, { dwell:.13, rest:1.39 }]

function trackDodge(run, enemy, aim, dt) {
    const creature = enemyTypes[enemy.type]
    const tier = creature.dodge
    if (!tier)
        return
    const timing = dodgeTimings[tier]
    if (!enemy.dodgeAge && enemy.dodgeIn < .68) {
        enemy.dodgeLaneGoal *= Math.max(0, 1 - dt * 2.5)
        enemy.dodgeLiftGoal *= Math.max(0, 1 - dt * 2.5)
    }
    const glide = 1 - Math.exp(-dt * 12)
    enemy.dodgeOffset += (enemy.dodgeLaneGoal - enemy.dodgeOffset) * glide
    enemy.dodgeLift += (enemy.dodgeLiftGoal - enemy.dodgeLift) * glide
    if (!aim || enemy.front !== run.playerFront || enemy.dodgeIn > 0) {
        enemy.dodgeAim = 0
        return
    }
    const halfHeight = enemy.depth * Math.tan(28 * Math.PI / 180)
    const halfWidth = halfHeight * aim.aspect
    const lane = lanePosition(enemy)
    const height = elevation(enemy)
    const dx = lane - (aim.x * 2 - 1) * halfWidth
    const dy = height - (1 - aim.y * 2) * halfHeight
    const size = enemySize(enemy)
    const inside = Math.hypot(dx, dy * 1.16) < (124 + 15 * tier) * size
    enemy.dodgeAim = inside ? enemy.dodgeAim + dt : 0
    if (enemy.dodgeAim < timing.dwell)
        return

    const stretch = 100 + tier * 41
    const boundary = halfWidth * .82
    const side = dx < 0 ? -1 : 1
    const target = Math.max(-boundary, Math.min(boundary, lane + side * stretch))
    enemy.dodgeLaneGoal = target - enemy.lane
    const canLift = creature.maneuver || Math.abs(target - lane) < stretch * .55
    const lift = (dy < 0 ? -1 : 1) * (51 + tier * 22)
    enemy.dodgeLiftGoal = canLift ? Math.max(-halfHeight * .47, Math.min(halfHeight * .47, lift)) : 0
    enemy.dodgeIn = timing.rest
    enemy.dodgeAge = .47
    enemy.dodgeAim = 0
    announce(run, null, "dodge")
}

function cloak(run, enemy) {
    let cloud = run.smokes.find(function(smoke) { return smoke.owner === enemy.id })
    if (!cloud) {
        cloud = { id:run.nextId++, owner:enemy.id, front:enemy.front, radius:258, height:203, lane:0, depth:0, life:10 }
        run.smokes.push(cloud)
        run.smokeRoster += 1
        announce(run, null, "smoke")
    }
    cloud.front = enemy.front
    cloud.lane = lanePosition(enemy)
    cloud.elevation = elevation(enemy)
    cloud.depth = enemy.depth
    if (cloud.life < 9)
        announce(run, null, "smoke")
    cloud.life = 10
}

function curseKiller(run, source) {
    if (source && typeof source === "object" && source.id) {
        source.cursed = true
    } else if (source !== "hostileBlast" && !run.cursed) {
        run.cursed = true
        run.rumble = Math.max(run.rumble, .26)
        announce(run, "Cursed · shots can misfire", "curse")
    }
}

function callSlimePeon(run, boss) {
    if (boss.peonCount >= 6 || run.time < boss.peonReadyAt || broodCount(run, boss.id) >= 3
        || random(run) >= .20)
        return false
    const side = boss.peonCount % 2 ? -1 : 1
    boss.peonCount += 1
    boss.peonReadyAt = run.time + 3
    summon(run, { type:"saslimigus", front:boss.front, lane:Math.max(-350, Math.min(350, boss.lane + side * 160)),
        summoned:true, parent:boss.id })
    announce(run, "Stinkaturumus called Saslimigus", "brood")
    return true
}

function blood(run, enemy, style, fatal) {
    if (!fatal && run.time < enemy.bloodAt)
        return
    const spec = enemyTypes[enemy.type]
    const boss = spec.role === "boss"
    const crystal = enemy.type === "nightosphere" && fatal
    enemy.bloodAt = run.time + .083
    enemy.bled = fatal
    const life = fatal ? (boss ? 2.36 : 1.12) : .42
    run.gore.push(Object.assign(arcPoint(enemy), { id:run.nextId++, front:enemy.front, type:enemy.type,
        style:typeof style === "string" ? style : "gun",
        life:life, span:life, fatal:fatal, boss:boss, size:enemySize(enemy), dark:!!spec.abyss, crystal:crystal,
        tint:crystal ? "#5d3682" : spec.abyss ? "#130d22" : enemy.type === "hasasasa" || enemy.type === "battlestar" ? "#772440" : "#a91735" }))
    if (run.gore.length > 58)
        run.gore.shift()
    if (fatal || run.time >= run.splatterAt) {
        run.splatterAt = run.time + .18
        announce(run, null, crystal ? "voidShatter" : boss && fatal ? "death-"+enemy.type : fatal ? "goreKill" : "goreHit")
    }
    if (fatal && !crystal && !boss && enemy.front===run.playerFront && run.time>=run.deathVoiceAt) {
        const chance=Conditions.roll(enemy.id,run.seed,0x27a9e581)
        if (chance<.27) {
            run.deathVoiceAt=run.time+1.9
            announce(run,null,chance<.135 ? "deathGroan" : "deathRasp")
        }
    }
}

var sniperPerches = [[-735,312],[724,337],[-862,-244],[904,-175],[191,478]]

function changeSniperPerch(run, enemy) {
    const otherPerches = sniperPerches.map(function(_,index) { return index }).filter(function(index) {
        return index !== enemy.sniperPerch
    })
    enemy.sniperPerch = sample(run,otherPerches)
    enemy.attack = Math.max(enemy.attack,1.10)
    beginWarp(enemy,"perchOut",.23)
    announce(run,"Feta Spotter is changing perches","sniperShift")
}

function splitBody(run, enemy, blade) {
    if (!["katana","chainsaw","darksaber","emberslash","mechasword","duoknives","reaperscythe","breakerGlaive","fearScythe","zeroHour"].includes(blade)
        || ["meteor","nightosphere","hallucination"].includes(enemy.type))
        return
    const life = enemyTypes[enemy.type].role === "boss" ? 1.42 : 1.02
    run.splits.push(Object.assign(arcPoint(enemy),{ id:run.nextId++,front:enemy.front,type:enemy.type,
        size:enemySize(enemy),blade:blade,life:life,duration:life }))
    if (run.splits.length > 9)
        run.splits.shift()
    announce(run,null,blade === "chainsaw" ? "sawSplit" : blade === "katana" ? "bladeSplit" : "plasmaSplit")
}

function elementalKill(enemy,element) {
    return enemy.lastElement===element || element==="electric" && enemy.elements.electric>0
}

function hurtReaction(run, enemy) {
    enemy.hitStop = .20
    enemy.hurtFace = .38
    if (run.time >= enemy.hurtVoiceAt) {
        enemy.hurtVoiceAt = run.time+.18
        announce(run,null,"hurt"+enemyTypes[enemy.type].origin)
    }
}

function wound(run, enemy, amount, source, element, level, impact) {
    if (!enemy || enemy.hp <= 0 || enemy.waitingBoss || !Number.isFinite(amount) || amount < 0)
        return ""
    const spec = enemyTypes[enemy.type]
    const weaponId=impact && impact.weaponId
    if (source==="ability" && !weaponId) amount*=Meta.benefits(run).active*(1+Gear.perk(run,"activeDamage"))
    const bossWeaponHit=spec.role==="boss" && (source==="gun" || !!weaponId) && !(impact && impact.bossPart)
    if (run.training && spec.trainer) {
        const mode=run.training.mode
        if (mode==="lesson") {
            if (run.training.step===0 && source==="gun") record(run,"trainingHits")
            if (impact?.scoped && amount > 0) enemy.sightMark = 4
            hurtReaction(run,enemy)
            return ""
        }
        if (!["phase1","phase2"].includes(mode)) return ""
        if (enemy.hp-amount*(impact && impact.critical || 1)<=0) {
            if (mode==="phase1") {
                enemy.hp=1
                run.training.mode="molt"
                run.training.age=0
                enemy.attackFlash=0
                run.bolts=[];run.boltRoster++
                announce(run,"That was only the beginning","tutorialMolt")
            } else {
                run.training.mode="won"
                blood(run,enemy,"gun",true)
                run.enemies=[];run.bolts=[];run.roster++;run.boltRoster++
                record(run,"trainingWins")
                announce(run,"Shrine graduate · Graduation pistol unlocked","clear")
            }
            return ""
        }
    }
    if (rank(run,"giantKiller") && spec.role==="boss") amount*=1+.18*rank(run,"giantKiller")
    if (element) enemy.lastElement=element
    if (spec.explosionImmune && (source === "explosion" || source === "hostileBlast" || impact?.explosion))
        return spec.title+" drinks the blast"
    if ((source === "ability" || source === "grenade") && !impact?.attackRolled && !(enemy.sightMark > 0) && attackMisses(run,attackBlindRank(run),true))
        return ""
    if (element === "electric" && Conditions.isRain(run.weatherEffect) && source !== "electric")
        amount *= 2
    const critical = !spec.critImmune && impact && impact.critical>1 ? impact.critical : 1
    if (enemy.type === "hasasasa") {
        if (source === "mega") {
            for (const part of Ship.remaining(enemy))
                part.hp = 0
            enemy.barrier = 0
        }
        return hitShip(run,enemy,null,amount,critical,bossWeaponHit ? weaponId || Gear.current(run).id : "",impact?.scoped)
    }
    if (bossWeaponHit) amount*=1+Tarot.value(run,"bossDamage")
    const multiplier=critical+(bossWeaponHit && critical>1 ? Tarot.value(run,"bossCrit") : 0)
    if (source !== "mega" && ghosted(enemy))
        return "Ghorimagous is phasing"
    if (enemy.type === "archfellanus" && Abyss.mirror(enemy.age) && amount > 0) {
        if (source === "mirror")
            return ""
        if (impact && impact.attackerId)
            wound(run,target(run,impact.attackerId),amount*multiplier,"mirror")
        else if (source === "pet" || source && typeof source === "object") {
            const pet = typeof source === "object" ? source : run.pet
            if (pet) {
                pet.stamina = 0
                pet.resting = Math.max(pet.resting,pet.stats.rest)
            }
        } else if (source !== "bubble" && source !== "hazard" && (source !== "burn" || !enemy.infernoBurn))
            damagePlayer(run,amount*multiplier,enemy.front,enemy.type,false,{sourceId:enemy.id,mirror:true})
        enemy.flash = .38
        return "Archfellanus reflected the hit"
    }
    if (impact?.scoped && amount > 0) enemy.sightMark = 4
    const resisted = statusImmune(enemy, element)
    if (resisted)
        amount *= .85
    if (source !== "mega" && enemy.type === "jos" && enemy.front === run.playerFront)
        amount *= .10
    if (source !== "mega" && enemy.type === "helboranius" && !element && source !== "burn" && source !== "electric")
        amount *= .80
    if (amount > 0 && source === "gun") {
        hurtReaction(run,enemy)
        enemy.weaponSource = impact?.weaponId || Gear.current(run).id
        if (element)
            enemy.elementWeapon = enemy.weaponSource
    } else if (impact?.weaponId) {
        enemy.weaponSource = impact.weaponId
    } else if (source === "burn") {
        enemy.weaponSource = enemy.elementWeapon
    } else {
        enemy.weaponSource = ""
    }
    if (element)
        enemy.elementWeapon = enemy.weaponSource
    const shield = enemy.barrier
    const frosted = enemy.elements.frozen > 0 && (source === "gun" || source === "grenade")
        ? 1 + rank(run,"iceSight")*.10 + Gear.perk(run,"coldDamage")+Gear.kitBonus(run,"coldDamage") : 1
    const damage = amount * multiplier * frosted * (enemy.eyesTime > 0 ? 2 : 1)
    const dealt = bankDamage(run, enemy, impact && impact.breakBarrier && shield > 0 ? Math.max(shield,damage) : damage)
    const shattered = shield > 0 && !enemy.barrier
    if (dealt > 0 && !shield && source === "gun" && enemy.weaponSource === "veinDrinker")
        feedVeinDrinker(run,Math.min(enemy.hp,dealt))
    enemy.hp -= dealt
    if (dealt > 0 && enemy.hp > 0 && source !== "burn" && source !== "mirror") {
        if (enemy.type === "endme" && enemy.eyeCount > 0 && !--enemy.eyeCount) {
            enemy.eyesTime = 6
            announce(run,"Endme exposed for six seconds","endmeBreak")
        }
        if (enemy.type === "jos" && (source === "gun" || impact && impact.ranged))
            knockBack(run,enemy,43)
        if (!spec.soulDrain && (!resisted || element !== "electric")
            && (source === "gun" || source === "ability" || source === "grenade" || element === "electric"))
            interruptAttack(enemy)
    }
    if (impact && dealt > 0 && enemy.hp > 0)
        applyKnockback(run,enemy,impact.knockback || 0,impact.pushBonus)
    if (enemy.type === "voidGlitch" && enemy.hp > 0 && enemy.hp <= enemy.maxHp*.50 && !run.voidStorm) {
        run.voidStorm = true
        announce(run,"The Void is distorting every view","voidStorm")
    }
    if (multiplier > 1 && dealt > 0)
        criticalHit(run, dealt, enemy.hp <= 0)
    if (dealt > 0 && (source !== "burn" || enemy.hp <= 0))
        blood(run, enemy, impact && impact.blood || source, enemy.hp <= 0 && enemy.type !== "mystery")
    if (element === "electric" && dealt > 0) {
        if (source !== "electric" && (!resisted || Conditions.isRain(run.weatherEffect)))
            chainElectric(run, enemy, amount, level, impact && impact.arcReach)
        if (!resisted && enemy.hp > 0 && random(run) < Elements.electricStun(level))
            applyToEnemy(run, enemy, "stun", 1)
    } else if (element && dealt > 0) {
        applyToEnemy(run, enemy, element, level, impact?.durationScale ? {durationScale:impact.durationScale} : null)
        if (element === "burn" && run.weatherEffect !== "rain")
            enemy.infernoBurn = false
    }
    enemy.flash = .14
    if (enemy.type === "nindumipus" && dealt > 0)
        cloak(run, enemy)
    if (enemy.type === "iceterapus" && dealt > 0 && !enemy.anger) {
        enemy.anger = true
        enemy.attackFlash = .55
    }
    if (enemy.hp <= 0) {
        if (enemy.type === "mystery") {
            enemy.hp = 0
            enemy.retreat = true
            beginWarp(enemy, "retreat", 1.30)
            run.kills += 1
            record(run, "kills")
            record(run,"enemyKills_"+enemy.type)
            if(enemy.weaponSource)record(run,"weaponKills_"+enemy.weaponSource)
            if (source === "pet" || source && typeof source === "object")
                record(run, "petKills")
            return "The shadow drifts away"
        }
        if (impact)
            splitBody(run,enemy,impact.blood)
        if (impact && impact.blood === "fearScythe" && enemy.type !== "hallucination")
            run.scytheSouls = Math.min(15,run.scytheSouls+1)
        if (enemy.type === "gendoustagus" && source !== "devour" && source !== "mirror")
            curseKiller(run, source)
        if (enemy.type === "lalaBubu") {
            curseKiller(run,"gun")
            run.dizzyLeft = 10
            announce(run,"Lala Bubu's curse · reversed turns","lalaLaugh")
        }
        const blast = Math.max(enemy.type === "princoratus" ? 2 : enemy.elements.explosive, impact ? impact.deathLevel || 0 : 0)
        if (blast)
            run.detonations.push({ front:enemy.front, lane:lanePosition(enemy), elevation:elevation(enemy),
                depth:enemy.depth, level:blast, danger:enemy.type === "princoratus", enemyType:enemy.type,weaponId:enemy.weaponSource })
        remove(run, run.enemies.indexOf(enemy), source !== "devour", source)
        if (enemy.type === "rerogorubus" && enemy.generation < 2) {
            record(run, "splits")
            for (const offset of [-70, 70]) {
                summon(run, { type:enemy.type, front:enemy.front, lane:enemy.lane + offset,
                    generation:enemy.generation + 1, summoned:true })
            }
            return "Rerogorubus split in two"
        }
        return enemy.returnedCoins ? "Recovered " + enemy.returnedCoins + " stolen gold" : ""
    }

    if (enemyTypes[enemy.type].sniper && dealt > 0 && !enemy.warp && impact && impact.ranged)
        changeSniperPerch(run,enemy)
    if (enemy.type === "humontafagus" && !enemy.calledSummons && enemy.hp <= enemy.maxHp / 2) {
        callSummons(run, enemy)
        return "Humontafagus summoned three demons"
    }
    if (enemy.type === "stinkaturumus" && dealt > 0 && !enemy.warp && ["gun", "ability", "grenade"].includes(source)
        && callSlimePeon(run, enemy))
        return "Stinkaturumus called Saslimigus"
    return shattered ? enemyTypes[enemy.type].title + " barrier shattered"
        : resisted ? enemyTypes[enemy.type].title + " resists " + Elements.kinds[element].title : ""
}

function projectilePoint(bolt) {
    if (bolt.bubble)
        return {lane:bolt.lane,elevation:bolt.elevation,depth:bolt.depth}
    if (bolt.returning) {
        const ratio = Math.min(1,Math.max(0,bolt.remaining/bolt.duration))
        return {lane:bolt.lane+(bolt.origin.lane-bolt.lane)*ratio,
            elevation:bolt.elevation+(bolt.origin.elevation-bolt.elevation)*ratio,
            depth:bolt.depth+(bolt.origin.depth-bolt.depth)*ratio}
    }
    const distance = Math.max(0, bolt.remaining / bolt.duration)
    const height = bolt.elevation === undefined ? 28 : bolt.elevation
    return { lane:bolt.lane * distance, elevation:height * distance, depth:50 + bolt.depth * distance }
}

function meleeReturnWindow(run) {
    const parry = rank(run,"edgeReturn")
    const weapon = weapons[Gear.current(run).id]
    if (!parry || !weapon.melee && !weapon.stab)
        return 0
    return .18 + Math.max(0,parry-1)*.032 + Gear.perk(run,"returnWindow")
}

function pickableBolt(bolt, view, returnWindow) {
    return bolt.front === view && !bolt.returning && bolt.remaining > 0 && bolt.remaining <= bolt.duration
        && (bolt.hp > 0 || bolt.remaining <= (returnWindow || 0))
}

function boltRadius(bolt) {
    return bolt.bubble ? 65 : bolt.fang ? 48 : bolt.core ? 27 : bolt.slug ? 22 : bolt.source === "hasasasa" ? 23 : 16
}

function returnProjectile(run, bolt, strength) {
    if (!bolt || bolt.bubble || bolt.returning || bolt.front !== run.playerFront)
        return false
    const enemy = target(run,bolt.sourceId) || run.enemies.find(function(foe) {
        return foe.type === bolt.source && foe.front === bolt.front && foe.hp > 0 && !foe.warp
    })
    if (!enemy || enemy.front !== bolt.front)
        return false
    const index = run.bolts.indexOf(bolt)
    if (index >= 0)
        run.bolts.splice(index,1)
    const origin = projectilePoint(bolt)
    const duration = Math.min(1.12,.4+enemy.depth/4300)
    run.bolts.push(Object.assign(arcPoint(enemy),{ id:run.nextId++, front:bolt.front, origin:origin,
        returning:true,duration:duration,remaining:duration,damage:bolt.damage*strength, color:"#fff0bf",
        source:bolt.source,sourceId:enemy.id,element:bolt.element,elementLevel:bolt.elementLevel,hp:0 }))
    run.boltRoster += 1
    record(run,"intercepts")
    return true
}

function intercept(run, bolt, damage) {
    const index = run.bolts.indexOf(bolt)
    if (index < 0 || !(bolt.hp > 0))
        return false
    bolt.hp -= damage
    if (bolt.hp > 0)
        return false
    run.bolts.splice(index, 1)
    run.boltRoster += 1
    if (bolt.bubble) {
        burstBubble(run,bolt,false)
        return true
    }
    if (bolt.fang) {
        run.bursts.push(Object.assign(projectilePoint(bolt),{front:bolt.front,radius:104,
            life:.42,span:.42,color:"#f7e5bd"}))
        announce(run,"Flying fang shattered","fangCrack")
    }
    record(run, "intercepts")
    return true
}

function throwGrenade(run, view, id, aim, damage, radius, duration, strength, effect) {
    const targetEnemy = target(run, id)
    const bag = byId(run.gifts, id)
    const turret = Ship.turretAt(run, id)
    const bolt = byId(run.bolts, id)
    const fang = fangAt(run,id,view)
    const point = targetEnemy ? arcPoint(targetEnemy) : bag ? {lane:bag.lane,elevation:bag.elevation ?? -68,depth:bag.depth}
        : turret ? { lane:turret.part.lane, elevation:elevation(turret.boss) + turret.part.height, depth:turret.boss.depth - 110 }
        : bolt ? projectilePoint(bolt) : fang ? fangPoint(fang.boss,fang.part)
            : {lane:(aim.x - .5) * 670, elevation:(.5 - aim.y) * 510,depth:760}
    run.grenades.push(Object.assign(point, { front:view, kind:aim.kind, x:aim.x, y:aim.y, targetId:id,
        damage:damage, radius:radius, remaining:duration, duration:duration, strength:strength || 0, effect:effect,
        illusionOnly:!!run.hypnosis }))
}

function explode(run, grenade) {
    const within = function(point) {
        return Math.hypot(point.lane - grenade.lane, point.elevation - grenade.elevation,
            (point.depth - grenade.depth) * .66) <= grenade.radius
    }
    const targets = run.enemies.filter(function(enemy) {
        return enemy.front === grenade.front && enemy.hp > 0 && enemy.warp <= 0 && !ghosted(enemy)
            && (!grenade.illusionOnly || enemy.type === "hallucination")
            && within(arcPoint(enemy))
    })
    const turret = Ship.turretAt(run, grenade.targetId)
    const fang = fangAt(run,grenade.targetId,grenade.front)
    if (turret && turret.boss.front === grenade.front)
        hitShip(run, turret.boss, turret.part, grenade.damage, grenade.effect.critical,grenade.effect.weaponId,grenade.effect.scoped)
    if (fang)
        hitFang(run,fang.boss,fang.part,grenade.damage,grenade.effect.critical,grenade.effect.scoped)
    for (const bolt of run.bolts.slice()) {
        if (!grenade.illusionOnly && bolt.front === grenade.front && bolt.hp > 0 && within(projectilePoint(bolt)))
            intercept(run, bolt, grenade.damage * (grenade.effect.critical || 1))
    }
    for (const enemy of targets) {
        if (grenade.kind !== "staff")
            record(run, "grenadeHits")
        if (turret?.boss === enemy || fang?.boss === enemy)
            continue
        if (grenade.kind === "gravitywell" && enemy.type !== "hasasasa")
            knockBack(run,enemy,145)
        const effect = grenade.effect
        const exposed = enemy.barrier <= 0
        wound(run, enemy, grenade.damage * (enemy.id===grenade.targetId ? effect.directArmour ?? 1 : 1) * (1 + (enemy.barrier ? effect.breachBonus || 0 : 0)),
            grenade.kind === "staff" ? "ability" : "grenade", effect.element, effect.elementLevel,
            { arcReach:effect.spell === "electric" && Gear.hasKit(run,"thunderKit") ? 45 : 0,
                critical:enemy.id === grenade.targetId ? (effect.directCritical ?? effect.critical) : effect.critical,
                ranged:grenade.kind === "launcher",breakBarrier:grenade.kind === "nullgrenade",
                attackRolled:effect.attackRolled,scoped:effect.scoped && enemy.id===grenade.targetId,
                explosion:!effect.spell,weaponId:effect.weaponId,durationScale:effect.durationScale })
        if (effect.spell && effect.element === "freeze" && exposed && !statusImmune(enemy,"freeze"))
            enemy.elements.frozen = Math.max(enemy.elements.frozen, 1.45 + (Gear.hasKit(run,"iceKit") ? .50 : 0))
        if (effect.element === "freeze" && enemy.elements.frost)
            enemy.elements.frostLeft = Math.max(enemy.elements.frostLeft,
                (2.9 + grenade.strength * .75 + (Gear.hasKit(run, "breacher") ? 2 : 0))*(effect.durationScale || 1))
        if (grenade.kind === "gravitywell" && enemy.hp > 0)
            applyToEnemy(run, enemy, "weaken", Math.min(3, effect.elementLevel - 1))
    }
    if (grenade.effect.spell) {
        const element = grenade.effect.element
        run.bursts.push({ front:grenade.front,lane:grenade.lane,elevation:grenade.elevation,depth:grenade.depth,
            radius:grenade.radius,span:.74,life:.74,style:element,color:Elements.kinds[element].color })
        if (grenade.effect.spell === "aurora")
            raiseBarrier(run, 3.4 + Number(Gear.hasKit(run,"auroraKit")), 1)
        run.rumble = Math.max(run.rumble, .26)
        announce(run, null, element === "electric" ? "electric" : element === "freeze" ? "frost" : "staffImpact")
        return
    }
    run.blast = { front:grenade.front, x:grenade.x, y:grenade.y, radius:grenade.radius, kind:grenade.kind, life:.45 }
    const bag = run.gifts.find(function(gift) {
        return gift.front === grenade.front && Math.hypot(gift.lane - grenade.lane,
            -68 - grenade.elevation, (gift.depth - grenade.depth) * .66) < grenade.radius
    })
    if (grenade.kind==="launcher" && (targets.length || bag || turret || fang)) record(run,"hitShots")
    run.rumble = Math.max(run.rumble, .38)
    announce(run, bag ? claimGift(run, bag) : targets.length ? "Blast · " + targets.length + " targets" : "",
        bag ? giftCue(bag) : grenade.kind === "cryogrenade" ? "frost" : "detonation")
}

function outgoing(run) {
    const hunger = Math.min(.60, .32 + .10 * Math.max(0, rank(run,"redHunger") - 1)) * missingHealth(run,"redHunger")
    const fragile = rank(run,"glassCannon")
    const risk = fragile ? Math.min(.72, .48 + .08 * (fragile - 1)) : 0
    const soulDamage = rank(run,"soulReaper") ? run.souls*(.012+Gear.perk(run,"soulStrength")) : 0
    return (run.hexes.damage ? .69 : 1) * (1 + run.boons.damage) * (1+rank(run,"closingShift")*(run.wave>20 ? .12 : .03))
        * (1 + hunger + risk + soulDamage + Gear.kitBonus(run,"damage",Gear.current(run).id)
            + (run.health >= Gear.maxHealth(run)-.01 && rank(run,"oathglass") ? .12+.03*(rank(run,"oathglass")-1) : 0))
        * Elements.damageFactor(run.elements)
}

function missingHealth(run, ability) {
    return rank(run,ability) ? Math.max(0, 1 - run.health / Gear.maxHealth(run)) : 0
}

function orbitGuard(run) {
    const level = rank(run,"orbitWard")
    return level ? { x:.5 + Math.sin(run.time*.91) * .35, half:.115 + Gear.perk(run,"guardWidth"),
        defence:.30 + Math.min(.24, (level - 1)*.055) + (Gear.hasKit(run,"orbitKit") ? .06 : 0) } : null
}

function activeCooldown(run, id) {
    return Math.max(run.cooldowns[id] || 0, run.taxedCooldowns[id] || 0)
}

function unlimitedAmmo(run) {
    return run.desktop?.cpuMode || run.infiniteAmmo > 0 || run.debugBuild === "star" && Gear.current(run).id === "starDestroyerPlus"
}

function impactContact(run, id, view) {
    if (run.hypnosis) {
        const phantom = target(run,id)
        return phantom && phantom.type === "hallucination" && phantom.hp > 0 && phantom.front === view
            ? {point:arcPoint(phantom),enemy:phantom} : null
    }
    const bolt = byId(run.bolts, id)
    if (bolt && pickableBolt(bolt, view, meleeReturnWindow(run)))
        return { point:projectilePoint(bolt), bolt:bolt }
    const fang = fangAt(run,id,view)
    if (fang)
        return {point:fangPoint(fang.boss,fang.part),fang:fang}
    const tube = Ship.turretAt(run, id)
    if (tube && !tube.boss.waitingBoss && !tube.boss.warp && tube.boss.front === view) {
        const point = { lane:tube.part.lane, elevation:elevation(tube.boss) + tube.part.height, depth:tube.boss.depth - 110 }
        return { point:point, tube:tube }
    }
    const enemy = target(run, id)
    if (enemy && enemy.front === view && enemy.hp > 0 && !enemy.warp && !enemy.waitingBoss && !ghosted(enemy))
        return { point:arcPoint(enemy), enemy:enemy }
    const gift = byId(run.gifts, id)
    if (gift && gift.front === view)
        return { point:{ lane:gift.lane, elevation:gift.elevation ?? -68, depth:gift.depth }, gift:gift }
    return null
}

function strikeContact(run, contact, damage, element, level, blade, critical) {
    if (contact.bolt) {
        const melee = weapons[blade] && (weapons[blade].melee || weapons[blade].stab) || blade === "bayonet"
        if (melee && contact.bolt.remaining <= meleeReturnWindow(run) && returnProjectile(run,contact.bolt,1))
            announce(run,"Melee return","returnBolt")
        else if (intercept(run, contact.bolt, damage * (critical || 1)))
            announce(run, "Projectile intercepted", "intercept")
    } else if (contact.tube) {
        hitShip(run, contact.tube.boss, contact.tube.part, damage, critical,weapons[blade] ? blade : Gear.current(run).id)
    } else if (contact.fang) {
        hitFang(run,contact.fang.boss,contact.fang.part,damage,critical)
    } else if (contact.enemy) {
        const stats = weapons[blade] && blade === Gear.current(run).id ? Gear.effectiveWeaponStats(run,Gear.current(run)) : null
        const note = wound(run, contact.enemy, damage, "gun", element, level, { blood:blade, critical:critical,
            knockback:stats ? stats.knockback : 0,pushBonus:stats ? stats.pushBonus : 0 })
        if (blade==="zeroHour") {
            for (const enemy of blastNeighbours(run,contact.enemy,360).slice(0,2))
                wound(run,enemy,damage*.50,"gun","",0,{blood:blade,weaponId:blade})
            passiveVisual(run,"zeroHour",contact.enemy.front,"cut","slice",arcPoint(contact.enemy),"",.18)
        }
        if (note)
            announce(run, note, "")
    } else if (contact.gift) {
        announce(run, claimGift(run, contact.gift), giftCue(contact.gift))
    }
}

function lungeAim(run, view, aim) {
    if (!aim)
        return 0
    let best = 0
    let gap = .134
    for (const enemy of run.enemies) {
        if (enemy.front !== view || enemy.hp <= 0 || enemy.warp > 0 || enemy.waitingBoss || ghosted(enemy)
            || run.hypnosis && enemy.type !== "hallucination")
            continue
        const ids = enemy.turrets && Ship.remaining(enemy).length ? Ship.remaining(enemy).map(function(part) { return part.targetId }) : [enemy.id]
        for (const id of ids) {
            const point = impactContact(run,id,view).point
            const height = point.depth * 1.0634
            const x = .5 + point.lane / (height * run.aspect)
            const y = .5 - point.elevation / height
            const distance = Math.hypot(x - aim.x, y - aim.y)
            if (distance < gap) {
                best = id
                gap = distance
            }
        }
    }
    return best
}

function meleeDefeat(run, gun, weapon, enemy) {
    if (!enemy || enemy.hp > 0)
        return
    record(run, "meleeKills")
    run.honedHit = Math.max(run.honedHit, rank(run,"bloodhone") * 2.2)
    if (weapon.signature === "sawVent")
        gun.heat = Math.max(0, gun.heat - .28)
    if (weapon.signature === "soulHarvest")
        run.health = Math.min(Gear.maxHealth(run), run.health + 3)
}

function lungeOffset(run) {
    if (run.grab)
        return grabOffset(run.grab)
    if (!run.lunge)
        return { depth:0, lane:0 }
    const dive = Math.sin(Math.PI * Math.min(1, run.lunge.elapsed / .68))
    return { depth:run.lunge.depth * dive, lane:run.lunge.lane * dive }
}

function grabOffset(grab) {
    const ratio = Math.min(1,grab.time/grab.length)
    const drift = grab.constrict ? Math.sin(Math.PI*ratio) : Math.min(1,ratio*6,(1-ratio)*6)
        * (.36+.64*Math.pow(Math.sin(ratio*Math.PI*3),2))
    return {depth:grab.depth*drift,lane:grab.lane*drift}
}

function beginGrab(run, enemy, length, constrict) {
    if (run.grab || run.hypnosis && constrict || run.playerFront !== enemy.front || !run.viewReady)
        return false
    if (constrict && run.shield.raised) {
        blockWithShield(run,enemy.damage,enemy.front,enemy.type,{sourceId:enemy.id},false,false)
        return false
    }
    run.lunge = null
    if (constrict)
        holdShield(run,false)
    run.grab = {id:enemy.id,front:enemy.front,time:0,length:length,constrict:constrict,hit:false,
        depth:Math.min(constrict ? 675 : 375,enemy.depth*.67*windForce(run)),lane:lanePosition(enemy)*.47*windForce(run)}
    return true
}

function tickGrab(run, dt) {
    const grab = run.grab
    if (!grab)
        return
    const enemy = target(run,grab.id)
    if (!enemy || enemy.hp <= 0 || enemy.front !== grab.front) {
        run.grab = null
        return
    }
    grab.time += dt
    if (grab.constrict && !grab.hit && grab.time >= 1.42) {
        grab.hit = true
        enemy.attackFlash = .52
        damagePlayer(run,enemy.damage*Elements.damageFactor(enemy.elements),enemy.front,enemy.type,false,{sourceId:enemy.id})
        announce(run,null,"tentacleBite")
    }
    if (grab.time >= grab.length)
        run.grab = null
}

function insideLure(run, enemy, aim) {
    if (!aim || !run.viewReady || enemy.front !== run.playerFront)
        return false
    const span = Math.max(180,enemy.depth)*1.0634
    const x = .5+lanePosition(enemy)/(run.aspect*span)
    const y = .5-elevation(enemy)/span
    return Math.hypot((aim.x-x)*run.aspect,aim.y-y) < Math.min(.15,106*enemySize(enemy)/span)
}

function lureActive(enemy) {
    return enemy.type === "lantis" && !(enemy.lureOff > 0) && Abyss.lampCycle(enemy.age) >= 0
}

function mirrorActive(enemy) {
    return enemy.type === "archfellanus" && Abyss.mirror(enemy.age)
}

function hypnotise(run, enemy) {
    if (run.hypnosis)
        return
    const count = 6 + Math.floor(random(run)*3)
    run.hypnosis = {id:enemy.id,left:count}
    run.lunge = null
    holdShield(run,false)
    const positions=[[-.26,-.17],[0,.19],[.28,-.12],[-.27,.16],[.02,-.20],[.28,.18],[-.13,.02],[.15,.04]]
    for (let i=0; i<count; ++i) {
        const position=positions[i]
        const phantom = spawn(run,{type:"hallucination",front:enemy.front,summoned:true,form:i%6,
            lane:0,tuning:.57})
        phantom.illusionX=position[0]+(random(run)-.5)*.05
        phantom.illusionY=position[1]+(random(run)-.5)*.045
        phantom.illusionAspect=run.aspect
        phantom.depth = 1420+random(run)*450
        phantom.attack = 2.4 + i*.64
    }
    announce(run,"Hypnotised · destroy the hallucinations","lureStart")
}

function driftBlind(run, enemy, dt) {
    enemy.blindStep -= dt
    if (enemy.blindStep <= 0) {
        enemy.blindStep = .4+random(run)*.54
        enemy.blindHeading = random(run)*2*Math.PI
    }
    const step = enemy.travelSpeed * dt * .85
    const laneLimit = Math.max(112,enemy.depth*.34)
    enemy.lane = Math.max(-laneLimit,Math.min(laneLimit,enemy.lane+Math.cos(enemy.blindHeading)*step))
    const spec = enemyTypes[enemy.type]
    enemy.depth = Math.max(spec.reach,Math.min((spec.distance || Mission.spawnDistance)+340,
        enemy.depth+Math.sin(enemy.blindHeading)*step))
}

function burstBubble(run, bolt, swallowed) {
    const point = projectilePoint(bolt)
    run.bursts.push(Object.assign(point,{id:run.nextId++,bubble:true,front:bolt.front,radius:240,life:.72,span:.72,color:"#aaeff6"}))
    if (swallowed) {
        const boss = target(run,bolt.sourceId)
        if (boss && boss.hp > 0)
            wound(run,boss,Math.max(26,boss.maxHp*.044),"bubble")
    } else if (run.playerFront === bolt.front) {
        damagePlayer(run,bolt.damage,bolt.front,"reapfast",false,{blast:true,sourceId:bolt.sourceId})
    }
    run.rumble = Math.max(.45,run.rumble)
    announce(run,swallowed ? "Bubble burst inside the leviathan" : "Explosive bubble burst","bubbleBurst")
}

function releaseBubbles(run, enemy) {
    const bubbles = run.bolts.filter(function(bolt) { return bolt.bubble && bolt.sourceId === enemy.id })
    const wanted = Math.min(5,8-bubbles.length)
    let made = 0
    for (let attempt=0; attempt<56 && made<wanted; ++attempt) {
        const depth = 620+random(run)*790
        const lane = (random(run)-.5)*depth*.93
        const lift = (random(run)-.5)*depth*.78
        if (bubbles.some(function(other) {
            return Math.hypot(other.lane-lane,other.elevation-lift,(other.depth-depth)*.58)<225
        }))
            continue
        const bubble = {id:run.nextId++,bubble:true,source:enemy.type,sourceId:enemy.id,front:enemy.front,
            lane:lane,elevation:lift,depth:depth,hp:1,maximum:1,duration:32,remaining:32,
            damage:enemy.damage*.43,color:"#8be5e8"}
        bubbles.push(bubble)
        run.bolts.push(bubble)
        made += 1
    }
    if (made)
        run.boltRoster += 1
}

function drawBubbles(run, enemy, teeth) {
    for (let i=run.bolts.length-1; i>=0; --i) {
        const bubble = run.bolts[i]
        if (!bubble.bubble || bubble.sourceId !== enemy.id)
            continue
        if (teeth) {
            run.bolts.splice(i,1)
            run.boltRoster += 1
            burstBubble(run,bubble,true)
            if (enemy.hp <= 0)
                return
        } else {
            bubble.lane += (lanePosition(enemy)-bubble.lane)*.28*windForce(run)
            bubble.elevation += (elevation(enemy)-bubble.elevation)*.21*windForce(run)
            bubble.depth += Math.min(390,(enemy.depth-bubble.depth)*.58*windForce(run))
        }
    }
}

function fangAt(run,id,view) {
    const boss = run.enemies.find(function(foe) {
        return foe.fangs && foe.front === view && foe.hp > 0 && !foe.waitingBoss && !foe.warp
    })
    if (!boss)
        return null
    const part = boss.fangs.find(function(fang) { return fang.id === id && fang.hp > 0 })
    return part ? {boss:boss,part:part} : null
}

function fangPoint(enemy,fang) {
    const open = enemy.special ? Math.min(1,enemy.special.time/Math.max(.1,enemy.special.warning)) : .20
    return {lane:lanePosition(enemy)+fang.side*156,elevation:elevation(enemy)+7+65*open,
        depth:Math.max(237,enemy.depth-526+Math.abs(fang.side)*27)}
}

function hitFang(run, boss, fang, amount, critical, scoped) {
    const power=(critical || 1)+(critical>1 ? Tarot.value(run,"bossCrit") : 0)
    const dealt = Math.min(fang.hp,amount*power*(1+Tarot.value(run,"bossDamage")))
    fang.hp -= dealt
    if (!fang.hp) {
        fang.rebuildAt = run.time+30
        announce(run,"A leviathan fang broke in its jaw","fangCrack")
    }
    if (critical > 1 && dealt > 0)
        criticalHit(run,dealt,boss.hp <= dealt)
    wound(run,boss,dealt,"gun","",0,{bossPart:true,scoped:scoped})
}

function launchFangs(run, enemy) {
    for (const fang of enemy.fangs) {
        if (fang.hp <= 0)
            continue
        const mouth = fangPoint(enemy,fang)
        const health = Math.max(9,enemy.maxHp*.0115)
        const duration = 1.85
        run.bolts.push(Object.assign(mouth,{id:run.nextId++,front:enemy.front,fang:true,source:"reapfast",sourceId:enemy.id,
            remaining:duration,duration:duration,damage:enemy.damage*.37,
            color:"#f8d5b9",hp:health,maximum:health,localOnly:true,blindAtFire:enemy.elements.blind}))
        fang.hp = 0
        fang.rebuildAt = run.time+30
    }
    run.boltRoster += 1
    announce(run,"Leviathan · fang volley","fangLaunch")
}

function stepLeviathan(run, enemy, dt) {
    const enraged = enemy.hp <= enemy.maxHp*.5
    const fangs = enemy.fangs
    for (const fang of fangs) {
        if (fang.rebuildAt && run.time >= fang.rebuildAt) {
            fang.hp = fang.maximum
            fang.rebuildAt = 0
        }
    }
    if (!enemy.special) {
        enemy.attack -= dt
        if (enemy.attack > 0)
            return
        const readyFangs = enraged && fangs.some(function(fang) { return fang.hp > 0 })
        const choices = Abyss.attacks.filter(function(plan) {
            return readyFangs ? plan.id === "fangs" : !plan.enraged && plan.id !== enemy.lastSpecial
        })
        const plan = sample(run,choices)
        enemy.lastSpecial = plan.id
        enemy.special = {kind:plan.id,warning:plan.warning,span:plan.span+plan.warning,time:0,beats:0}
        announce(run,"Reapfast · "+plan.title,"leviathan-"+plan.id)
        return
    }
    const attack = enemy.special
    attack.time += dt
    const age = attack.time-attack.warning
    if (age < 0)
        return
    const nearPlayer = run.playerFront === enemy.front && run.viewReady
    const damage = enemy.damage*Elements.damageFactor(enemy.elements)
    switch (attack.kind) {
    case "suction": {
        const pulls = [.39,1.51,2.78]
        if (!attack.beats && nearPlayer && !run.grab)
            beginGrab(run,enemy,4,false)
        if (attack.beats < pulls.length && age >= pulls[attack.beats]) {
            attack.beats += 1
            drawBubbles(run,enemy,false)
            run.rumble = Math.max(.62,run.rumble)
        }
        if (attack.beats === 3 && age >= 3.45) {
            attack.beats += 1
            drawBubbles(run,enemy,true)
            if (enemy.hp > 0 && nearPlayer)
                damagePlayer(run,damage*1.20,enemy.front,enemy.type,false,{sourceId:enemy.id})
            enemy.attackFlash = .54
            announce(run,null,"leviathanBite")
        }
        break
    }
    case "bubbles":
        if (!attack.beats && age >= .43) {
            attack.beats = 1
            releaseBubbles(run,enemy)
        }
        break
    case "charge":
        enemy.depth = 1750-1090*Math.pow(Math.sin(Math.PI*Math.min(1,age/2.25)),1.8)
        if (!attack.beats && age >= .96) {
            attack.beats = 1
            enemy.attackFlash = .57
            if (nearPlayer)
                damagePlayer(run,damage*.86,enemy.front,enemy.type,false,{sourceId:enemy.id})
            announce(run,null,"leviathanBite")
        }
        break
    case "roar":
        if (!attack.beats && age >= .41) {
            attack.beats = 1
            for (const side of [-1,1])
                summon(run,{type:"crawler",front:enemy.front,lane:side*260,summoned:true,parent:enemy.id})
            if (nearPlayer)
                Elements.apply(run.elements,"weaken",2,function() { return random(run) },{duration:3})
            run.rumble = .72
        }
        break
    case "fangs":
        if (!attack.beats && age >= .22) {
            attack.beats = 1
            launchFangs(run,enemy)
        }
        break
    }
    if (attack.time >= attack.span) {
        enemy.depth = 1750
        enemy.special = null
        enemy.attack = (3.9+random(run)*1.85)*(enraged ? .77 : 1)
    }
}

function stepAbyss(run, enemy, dt, aim) {
    if (enemy.type === "harvester")
        return stepHarvester(run,enemy,dt)
    if (enemy.type === "reapfast") {
        stepLeviathan(run,enemy,dt)
        return true
    }
    if (enemy.type === "endme" && enemy.eyesTime > 0) {
        enemy.eyesTime = Math.max(0,enemy.eyesTime-dt)
        if (!enemy.eyesTime)
            enemy.eyeCount = 8
        return true
    }
    if (enemy.type === "lantis") {
        enemy.lureOff = Math.max(0,enemy.lureOff-dt)
        const cycle = Abyss.lampCycle(enemy.age)
        if (lureActive(enemy) && cycle !== enemy.lureUsed && !run.hypnosis && !run.grab && insideLure(run,enemy,aim)) {
            enemy.lureUsed = cycle
            hypnotise(run,enemy)
        }
    }
    if (enemy.type === "shadow" && !enemy.inkFired && enemy.depth <= 1500 && enemy.front === run.playerFront && run.viewReady) {
        if (!enemy.special) {
            enemy.special = {kind:"ink",time:0,warning:1.15,span:1.15}
            announce(run,"Shadow · ink blast incoming","inkWindup")
        }
        enemy.special.time += dt
        if (enemy.special.time >= enemy.special.span) {
            enemy.inkFired = true
            enemy.special = null
            launchBolts(run,enemy,{boltTime:.96,boltHealth:4.8,accent:"#1c0a29",ink:true})
        }
        return true
    }
    if (enemy.type === "nightosphere") {
        if (!enemy.orbAt)
            enemy.orbAt = run.time+10
        else if (run.time >= enemy.orbAt) {
            enemy.orbAt += 10
            const pool = Mission.introductions.filter(function(entry) {
                return entry.wave <= run.wave && enemyTypes[entry.type].abyss && entry.type !== enemy.type
            })
            if (pool.length && broodCount(run,enemy.id) < 3 && summon(run,{type:sample(run,pool).type,
                front:enemy.front,lane:enemy.lane+(random(run)<.5 ? 205 : -205),summoned:true,parent:enemy.id}))
                announce(run,"Nightosphere opened the deep","voidBrood")
        }
    }
    return false
}

function stepHarvester(run, enemy, dt) {
    const spec = enemyTypes.harvester
    if (enemy.depth > spec.reach) {
        enemy.soulChannel = false
        enemy.soulWarm = spec.windup
        return false
    }
    enemy.soulWarm = Math.max(0,enemy.soulWarm-dt)
    if (!enemy.soulChannel && !enemy.soulWarm) {
        enemy.soulChannel = true
        enemy.soulTick = 0
        announce(run,"Harvester opened its mouth","harvesterCry")
    }
    if (enemy.soulChannel) {
        enemy.soulTick -= dt
        if (enemy.soulTick <= 0) {
            enemy.soulTick += .4
            if (attackMisses(run,enemy.elements.blind))
                hostileMiss(run,spec,enemy.elements.blind)
            else {
                const health = run.health
                damagePlayer(run,enemy.damage*Elements.damageFactor(enemy.elements),enemy.front,enemy.type,true,
                    {sourceId:enemy.id,soulDrain:true,critical:false,element:""})
                enemy.stolenHealth += Math.max(0,health-run.health)
            }
        }
    }
    return true
}

function updateLunge(run, dt) {
    const strike = run.lunge
    if (!strike)
        return
    strike.elapsed += dt
    if (!strike.hit && strike.elapsed >= .32) {
        strike.hit = true
        const contact = impactContact(run, strike.target, strike.front)
        if (contact) {
            strikeContact(run,contact,strike.damage,strike.element,strike.level,strike.weapon.id,strike.critical)
            record(run,"hitShots")
            meleeDefeat(run,strike.gun,strike.weapon,contact.enemy)
            run.meleeImpact = strike.weapon.afterglow
            announce(run, "Charged strike", "combo")
        }
    }
    if (strike.elapsed >= .68)
        run.lunge = null
}

function meleeStrike(run, gun, weapon, stats, aimed, view, power) {
    const melee = weapon.melee
    const charged = gun.primed
    gun.primed = false
    gun.chargedStrike = charged
    if (weapon.id === "katana") {
        gun.combo = run.time <= gun.comboUntil ? gun.combo % 3 + 1 : 1
        gun.comboUntil = run.time + .64 + (Gear.hasKit(run,"quickSteel") ? .06 : 0)
    }
    const range = melee.reach + rank(run, "longguard") * 38
    const finisher = weapon.id === "katana" && gun.combo === 3
    const combo = finisher ? 1.58 : 1
    const honed = run.honedHit
    run.honedHit = 0
    const limit = melee.targets + Number(weapon.id === "darksaber" && Gear.hasKit(run, "darkSet"))
    const level = Math.min(3, stats.elementLevel + Number(charged && (weapon.signature==="chargedFlame"
        || weapon.id === "mechasword" && Gear.hasKit(run,"mechaSet"))))
    let struck = 0
    for (const id of new Set(aimed)) {
        const contact = impactContact(run, id, view)
        if (!contact)
            continue
        const close = contact.point.depth <= range
        if (!close && (!charged || struck))
            continue
        const enemy = contact.enemy
        const finished = weapon.signature === "knifeFinisher" && enemy && enemy.hp <= enemy.maxHp * .48
        const base = (close ? stats.damage : melee.rangedDamage || stats.damage)
            * (charged ? (melee.boost + Gear.kitBonus(run,"lunge")) * (1+(power.primed || 0)) : 1)
        const harvest = weapon.signature === "harvest" ? 1+run.scytheSouls*.018 : 1
        const poisedBonus=(charged || finisher) ? rank(run,"edgeRhythm")*.90 : 0
        const sharpenBonus=run.sharpenTime>0 ? 2.4 : 0
        const damage = (base * combo + (finished ? 2 : 0) + (power.damage || 0) + rank(run,"caliber") * .52 + honed
            + poisedBonus + sharpenBonus)
            * outgoing(run) * Math.pow(.68, struck) * (run.meleeRush > 0 ? 1.20 : 1) * harvest
        if (!close) {
            run.lunge = { target:id,front:view,elapsed:0,hit:false,damage:damage,element:stats.element,level:level,weapon:weapon,gun:gun,critical:1,
                depth:Math.max(0,contact.point.depth-365),lane:contact.point.lane*.77 }
            announce(run, "Closing the distance", "turn")
            return
        }
        strikeContact(run, contact, damage, stats.element, level, weapon.id, 1)
        if (enemy && close && enemy.hp > 0 && weapon.signature === "clubSwing" && enemyTypes[enemy.type].role !== "boss") {
            const push = Gear.hasKit(run,"clubSet") ? 111 : 56
            enemy.depth = Math.min(range - 12, enemy.depth + push)
        }
        meleeDefeat(run,gun,weapon,enemy)
        if (++struck >= limit || !close)
            break
    }
    if (struck) record(run,"hitShots")
    if (finisher && struck) {
        record(run, "katanaCombos")
        announce(run, "Katana · finishing cut", "combo")
    }
}

function throwAxe(run, gun, stats, view, id, aim, damage, critical) {
    const contact = impactContact(run, id, view)
    const point = contact ? contact.point : { lane:(aim.x - .5) * 1630, elevation:(.5 - aim.y) * 1200, depth:1160 }
    const duration = .25 + point.depth / 4750
    run.axes.push(Object.assign(point, { id:run.nextId++, front:view, targetId:id, damage:damage, owner:gun,
        remaining:duration, duration:duration, critical:critical, mark:Gear.hasKit(run,"axeSet") }))
    gun.prep = gun.prepLength = stats.reload
    announce(run, null, "axeThrow")
}

function axePoint(axe) {
    const step = Math.min(1, 1 - axe.remaining / axe.duration)
    return { lane:64 + (axe.lane - 64) * step, elevation:-33 + (axe.elevation + 33) * step + 61 * Math.sin(Math.PI * step),
        depth:128 + (axe.depth - 128) * step, spin:-25 + step * 1110 }
}

function updateAxes(run, dt) {
    for (let i = run.axes.length - 1; i >= 0; i -= 1) {
        const axe = run.axes[i]
        axe.remaining = Math.max(0, axe.remaining - dt)
        const contact = impactContact(run, axe.targetId, axe.front)
        const point = axePoint(axe)
        const inReach = contact && Math.hypot(point.lane - contact.point.lane, point.elevation - contact.point.elevation,
            (point.depth - contact.point.depth) * .64) < (contact.bolt ? 70 : 134)
        if (axe.remaining && !(inReach && contact.bolt))
            continue
        if (inReach) {
            strikeContact(run, contact, axe.damage, "", 0, "tomahawk", axe.critical)
            if (axe.mark && contact.enemy && contact.enemy.hp > 0)
                contact.enemy.mark = 4
            record(run, "hitShots")
            record(run, "axeHits")
            axe.owner.prep = Math.max(0, axe.owner.prep - rank(run,"returnSpring") * .13)
            run.bursts.push(Object.assign(point, { front:axe.front, radius:96, life:.33, span:.33, color:"#ffd397" }))
        }
        run.axes.splice(i, 1)
        announce(run, null, "axeImpact")
    }
}

function blastNeighbours(run, enemy, range) {
    return run.enemies.filter(function(other) {
        return other !== enemy && other.front === enemy.front && !other.warp && !ghosted(other)
            && Math.abs(other.depth - enemy.depth) < range && Math.abs(lanePosition(other) - lanePosition(enemy)) < range * .66
    })
}

function depositHole(run, point, view, level, amplified) {
    const radius = 465 + rank(run,"tidalAnchor")*23 + Gear.perk(run,"gravityRange")
    const pull = (amplified ? 83 : 54) + level*5 + rank(run,"tidalAnchor")*8 + (Gear.hasKit(run,"blackHoleKit") ? 21 : 0)
    run.holes.push(Object.assign({},point,{ id:run.nextId++,front:view,radius:radius,pull:pull,
        life:3,duration:3,tick:1,pulse:0 }))
    if (run.holes.length > 6)
        run.holes.shift()
    announce(run,null,"blackHoleOpen")
}

function tickHoles(run, dt) {
    for (let i = run.holes.length - 1; i >= 0; --i) {
        const hole = run.holes[i]
        hole.life -= dt
        hole.tick -= dt
        hole.pulse = Math.max(0,hole.pulse - dt)
        if (hole.tick <= 1e-8) {
            hole.tick += 1
            hole.pulse = .34
            for (const enemy of run.enemies) {
                const kind = enemyTypes[enemy.type]
                if (enemy.front !== hole.front || enemy.warp || enemy.hp <= 0 || ghosted(enemy) || kind.distance && !kind.speed
                    || kind.ship || enemy.feed)
                    continue
                const dx = hole.lane - lanePosition(enemy)
                const dy = hole.elevation - elevation(enemy)
                const dz = hole.depth - enemy.depth
                const gap = Math.hypot(dx,dy,dz)
                if (gap <= 1 || gap > hole.radius)
                    continue
                const mass = kind.role === "boss" ? .35 : kind.devour ? .53 : 1
                const step = Math.min(gap,hole.pull*mass*windForce(run)) / gap
                enemy.depth = Math.max(138,enemy.depth + dz*step)
                const safe = enemy.depth*.40
                enemy.lane = Math.max(-safe,Math.min(safe,enemy.lane + dx*step))
                enemy.gravityLift = Math.max(-155,Math.min(155,(enemy.gravityLift || 0) + dy*step))
            }
        }
        if (hole.life <= 1e-8)
            run.holes.splice(i,1)
    }
}

var avatarElements = ["wind","burn","freeze","electric","stun","weaken"]
var jesterElements = ["burn","freeze","electric","blind","poison","weaken"]

function drawJesterStatus(run,gun) {
    const deck = gun.jesterDeck?.length ? gun.jesterDeck : jesterElements.slice()
    const available = deck.length > 1 ? deck.filter(function(kind) { return kind !== gun.jesterTint }) : deck
    const next = sample(run,available)
    deck.splice(deck.indexOf(next),1)
    gun.jesterDeck = deck
    gun.jesterTint = next
    return next
}

function chargeStaff(gun, stats, amount) {
    gun.charge = Math.min(stats.chargeCost, gun.charge + amount)
}

function castStaff(run, gun, weapon, stats, hits, view, aim) {
    if (gun.charge < stats.chargeCost) {
        announce(run,"Spell charge · "+gun.charge+" / "+stats.chargeCost+" attacks","empty")
        return false
    }
    if (gun.castTime > 0)
        return false
    const kind = weapon.staff.kind
    if (weapon.id==="hourhand") rewindBolts(run,view,.65+Gear.weaponLevel(run,gun)*.10)
    const element = kind === "avatar" ? sample(run, avatarElements) : kind === "aurora" ? "electric" : kind
    const range = element === "wind" ? 598 : element === "stun" ? 423 : element === "electric" ? 239 : 370
    const focus = hits && hits.find(function(id) { return id > 0 }) || 0
    const pointer = aim || { x:.5, y:.5 }
    const damage = (stats.damage * (kind === "avatar" ? 1.32 : 1.12) + Gear.perk(run,"magicForce")) * outgoing(run)
    throwGrenade(run, view, focus, { x:pointer.x, y:pointer.y, kind:"staff" }, damage,
        range + (kind === "burn" && Gear.hasKit(run,"fireKit") ? 60 : 0), element === "burn" ? .62 : .33, Gear.weaponLevel(run,gun),
        { element:element, elementLevel:kind === "stun" ? Math.min(3, 2 + Number(Gear.weaponLevel(run,gun) >= 2)) : ["common","rare"].includes(weapon.rarity) ? stats.elementLevel : 3, spell:kind,weaponId:weapon.id })
    gun.charge = 0
    gun.castLength=gun.castTime=(kind === "wind" ? .78 : .92)*(Gear.weaponSocket(run).castRecovery || 1)
    gun.sequence += 1
    gun.recovery = Math.max(.40, gun.recovery)
    record(run, "staffCasts")
    announce(run, weapon.staff.cast + " · " + Elements.kinds[element].title, "staffCast")
    return true
}

function queuedShot(run) {
    const gun = Gear.current(run)
    return !!(gun.burstLeft > 0 && gun.burstWait <= 1e-7 && canAct(run) && !run.shield.raised && !gun.reload)
}

function shoot(run, hits, view, aim, continuation) {
    const frontId = view || run.playerFront
    const gun = Gear.current(run)
    const weapon = weapons[gun.id]
    const stats = Gear.effectiveWeaponStats(run,gun)
    const unlimited = unlimitedAmmo(run)
    const ammoWeapon = Gear.usesAmmo(weapon)
    if (run.hypnosis) {
        hits = hits.filter(function(id) { return target(run,id)?.type === "hallucination" })
        // Throwers and launchers keep their actual wind-up and ammo cycle.
    }
    if (!canAct(run) || run.desktop?.cpuMode && run.desktop.locked && (ammoWeapon || weapon.sustain) || run.shield.raised || run.lunge || gun.reload > 0 || gun.prep > 0 || gun.cool > 0
        || (continuation ? !queuedShot(run) : gun.recovery > 0 || gun.burstLeft > 0))
        return false
    if (ammoWeapon && gun.ammo === 0 && !unlimited) {
        reload(run,hits,frontId,aim)
        return false
    }
    if (weapon.spinup && gun.spin<1) return false

    if (weapon.melee && gun.primed)
        hits = hits.concat(lungeAim(run,frontId,aim))
    if (run.cursed && !weapon.melee && !weapon.throwing && random(run) < .13
        && !hits.some(function(id) { return sightLocked(run,id,frontId) })) {
        record(run,"shots")
        gun.streak = 0
        if (continuation) {
            gun.burstLeft -= 1
            gun.burstWait = weapon.burst.interval
        } else {
            gun.recovery = Math.max(.12, stats.delay * .44)
        }
        announce(run, "Cursed shot misfired", "misfire")
        return false
    }

    const power = Gear.weaponSocket(run)
    if (weapon.element)
        stats.damage *= 1+(power.elementalDamage || 0)+Gear.passiveSockets(run,"elementDamage",.12)
    if (weapon.signature === "coinShot") {
        const cost = weapon.coinCost-Gear.kitBonus(run,"coinDiscount")
        gun.coinShot = Gear.availableGold(run) >= cost
        if (gun.coinShot)
            spendGold(run,cost)
        stats.damage *= gun.coinShot ? 1 : .22
    }
    if (weapon.signature === "unbroken" && !run.hurtThisWave)
        stats.damage *= 1.22
    if (ammoWeapon && !unlimited)
        gun.ammo -= 1
    const healthyCycle=Tarot.value(run,"healthyCycle")
    gun.cycle = stats.delay * (run.hexes.fire ? 1.42 : 1)
        * Math.max(.52, 1 - rank(run, "cycling") * .064 - Gear.perk(run, "cycle") - Tarot.value(run,"cycle")
            - (healthyCycle && run.health>=Gear.maxHealth(run)*.80 ? healthyCycle : 0)) * (run.fastFire > 0 ? .68 : 1) * (run.salvoTime>0 ? 1-run.salvoBonus : 1)
        * (run.giftRate > 0 ? .73 : 1) * (power.recovery || 1)
        * (weapon.melee ? 1-Gear.passiveSockets(run,"meleeRecovery",.14) : 1)
        * (gun.id === "carbine" && Gear.hasKit(run, "carbine") ? .85 : 1)
        * Math.max(.79, 1 - Gear.kitBonus(run,"recovery",gun.id))
    if (!continuation) {
        gun.recovery = gun.cycle
        if (weapon.burst) {
            gun.burstLeft = Math.min(weapon.burst.count - 1, unlimited ? weapon.burst.count - 1 : gun.ammo)
            gun.burstRefunded = false
        }
    } else {
        gun.burstLeft -= 1
    }
    if (weapon.burst)
        gun.burstWait = weapon.burst.interval
    const burstLast = continuation && !gun.burstLeft
    record(run,"shots")
    if (run.desktop?.cpuMode && (ammoWeapon || weapon.sustain)) {
        run.desktop.heat=Math.min(100,run.desktop.heat+Math.min(18,5+stats.damage*.7))
        if(run.desktop.heat>=100)run.desktop.locked=true
    }
    gun.sequence = (gun.sequence || 0) + 1
    if (weapon.chargeEachShot)
        gun.spin = 0
    if (weapon.sustain && !gun.firing) {
        const limit = heatLimit(run, weapon, stats)
        gun.heat = Math.min(limit, (gun.heat || 0) + Math.min(.14, stats.delay))
        if (gun.heat >= limit)
            coolWeapon(run, gun, weapon, stats)
    }
    const blindness = attackBlindRank(run)
    if (attackMisses(run,blindness,true)) {
        // One volley can cross both a marked enemy and an unmarked enemy.
        hits = hits.filter(function(id) { return sightLocked(run,id,frontId) || byId(run.gifts,id) })
        if (!hits.length) {
            gun.streak = gun.focus = gun.lastTarget = 0
            if (weapon.melee)
                meleeStrike(run,gun,weapon,stats,[],frontId,power)
            else if (weapon.staff)
                chargeStaff(gun,stats,1)
            missFeedback(run,"Your attack",blindness)
            return true
        }
    }
    if (weapon.melee) {
        meleeStrike(run, gun, weapon, stats, hits, frontId, power)
        return true
    }
    const scoped = !!aim?.scoped && Gear.hasGunSights(weapon)
    const primary = hits.find(function(id) { return id > 0 }) || 0
    const critical = weaponCritical(run,weapon,gun,target(run,primary))
    function criticalAt(id) {
        return aim?.eyeTargets?.includes(id) || aim?.contacts?.some(contact => contact.id===id && contact.zone==="eye")
            ? Math.max(critical,criticalProfile(run,weapon).power) : critical
    }
    const previousCriticals = run.metrics.criticalHits || 0
    gun.focus = primary && gun.lastTarget === primary ? gun.focus + 1 : Number(primary > 0)
    gun.lastTarget = primary
    const signature = weapon.signature
    const staffReady = weapon.staff && gun.charge >= stats.chargeCost
    if (weapon.staff)
        chargeStaff(gun, stats, 1)
    const breachRoundsBonus = run.breachRounds > 0 && ammoWeapon ? .65 + (Gear.hasKit(run,"leadKit") ? .15 : 0) : 0
    if (breachRoundsBonus)
        run.breachRounds -= 1
    const armour=aim?.contacts?.find(contact => contact.id===primary)?.zone==="outer" ? .8 : 1
    if (weapon.throwing) {
        throwAxe(run, gun, stats, frontId, primary, aim || {x:.5,y:.5},
            (stats.damage + (power.damage || 0) + rank(run,"caliber") * .66) * outgoing(run) * (1 + run.axePower) * armour, criticalAt(primary))
        run.axePower = 0
        return true
    }
    if (weapon.blast) {
        throwGrenade(run, frontId, primary, Object.assign({ x:.5, y:.5 }, aim, { kind:"launcher" }),
            (stats.damage + rank(run, "booster") * .78 + (power.damage || 0) + (run.giftDamage > 0 ? 2 : 0)) * outgoing(run),
            weapon.blast * (1 + Gear.perk(run, "blastRadius")), primary ? .28 : .55, 0,
            Object.assign({}, stats, { breachBonus:breachRoundsBonus, critical:critical,
                directCritical:criticalAt(primary),directArmour:armour,attackRolled:true,scoped:scoped,weaponId:weapon.id }))
        announce(run, "", "shot")
        return true
    }

    const landed = new Map()
    const zones = new Map()
    for (const contact of aim?.contacts || []) {
        if (!zones.has(contact.id)) zones.set(contact.id,[])
        zones.get(contact.id).push(contact.zone)
    }
    for (const id of hits) {
        if (id > 0)
            landed.set(id, (landed.get(id) || 0) + 1)
    }

    let message = ""
    let cue = ""
    let hit = false
    const broken = run.metrics.shatters || 0
    const jumped = run.metrics.electricJumps || 0
    const staticRank = rank(run, "staticPrimer")
    const element = signature === "jesterDeck" ? drawJesterStatus(run,gun)
        : signature === "avatar" ? sample(run, avatarElements)
        : stats.element || (staticRank && random(run) < .085 * staticRank ? "electric" : "")
    const elementLevel = signature === "jesterDeck" ? 1+Number(Gear.weaponLevel(run,gun) >= 2)
        : stats.elementLevel || Number(element === "electric")
    const impact = { deathLevel:stats.deathLevel, arcReach:signature === "longArcs" ? 72 : 0, critical:critical,ranged:true,
        breakBarrier:signature === "breachArmor",scoped:scoped,
        knockback:stats.knockback,pushBonus:stats.pushBonus,weaponId:weapon.id }
    const pressure = signature === "rotaryRamp" ? .26 * Math.min(1, (gun.hold || 0) / 2.25)
        : signature === "hitStreak" ? Math.min(10, gun.streak) * .12 : 0
    const surge = (burstLast ? rank(run,"burstanchor") * .18 + (Gear.hasKit(run,"burstCrew") ? .18 : 0) : 0)
        + (staffReady ? rank(run,"condenser") * .13 : 0)
    let layer = 0
    for (const [key, count] of landed) {
        if (weapon.penetration && layer >= weapon.penetration)
            break
        const through = weapon.penetration && !weapon.debugOnly
            ? Math.pow(Math.min(1,(weapon.pierceRetain || .80)+(power.retention || 0)), layer) : 1
        layer += 1
        const gift = byId(run.gifts, key)
        if (gift && gift.front === frontId) {
            message = claimGift(run, gift) || message
            cue = giftCue(gift)
            hit = true
            continue
        }
        const turret = Ship.turretAt(run, key)
        const fang = fangAt(run,key,frontId)
        const bolt = run.bolts.find(function(projectile) { return projectile.id === key && pickableBolt(projectile, frontId) })
        const focus = key === primary && (signature === "beamFocus" && gun.focus >= 5 ? .35
            : signature === "pairedHit" && gun.focus % 2 === 0 ? .55 : 0)
        if (turret && turret.boss.front === frontId || bolt || fang) {
            const amount = (stats.damage * count + (power.damage || 0)) * outgoing(run) * through * (1 + pressure + focus + surge)
            if (turret) {
                const heated = signature === "thermalBreach" && turret.boss.barrier > 0
                const shot = signature === "breachArmor" ? Math.max(turret.boss.barrier,amount) : amount
                message = hitShip(run, turret.boss, turret.part, shot * (1 + (heated ? .65 : 0)
                    + (turret.boss.barrier ? breachRoundsBonus : 0)), critical,weapon.id,scoped) || message
            } else if (fang) {
                hitFang(run,fang.boss,fang.part,amount,critical,scoped)
            } else if (intercept(run, bolt, amount * critical)) {
                cue = "intercept"
            }
            if (signature === "blackHole")
                depositHole(run,bolt ? projectilePoint(bolt) : fang ? fangPoint(fang.boss,fang.part) : {
                    lane:turret.part.lane,elevation:elevation(turret.boss)+turret.part.height,depth:turret.boss.depth-110
                },frontId,Gear.weaponLevel(run,gun))
            hit = true
            continue
        }
        const enemy = target(run, key)
        if (!enemy || enemy.front !== frontId || enemy.warp > 0 || enemy.hp <= 0 || enemy.waitingBoss)
            continue
        if (ghosted(enemy)) {
            message = message || "Ghorimagous is phasing"
            continue
        }
        const shield = enemy.barrier
        const hotBurst = signature === "flareUp" && enemy.elements.burn > 0
        const iceSplinters = signature === "iceSplinters" && enemy.elements.frozen > 0
        const relay = signature === "rimeRelay" && enemy.elements.frozen > 0 && shield <= 0
        const poisonSeed = signature === "sporeSeed" && enemy.elements.poison > 0
        const breach = charging(enemy) ? 1.55 * rank(run, "exploit") : 0
        const kitBonus = !Gear.hasKit(run, gun.id) ? 0
            : gun.id === "pistol" ? 1 : gun.id === "rail" && enemy.barrier > 0 ? 2 : 0
        const shieldBonus = enemy.barrier > 0 ? (weapon.shieldDamage || 0) + rank(run, "hunter") : 0
        const targetMarked = isMarked(enemy)
        const marked = (enemy.mark > 0 ? 1.35 : 0)
            + (targetMarked ? rank(run, "markSight") * 1.10 : 0)
        const chill = enemy.elements.frost ? rank(run, "frostBite") * .84 : 0
        const reaction = (element === "burn" && enemy.elements.frost || element === "freeze" && enemy.elements.burn)
            ? rank(run, "ashenChar") * 1.30 : 0
        enemy.mark = 0
        const falloff = weapon.effect === "spread" ? .40 + 1.12 * Math.max(0, Math.min(1, (1160 - enemy.depth) / 900)) : 1
        const frostCrush = signature === "frostCrush" && enemy.elements.frozen > 0 ? 3.4 : 0
        const heatBonus = signature === "thermalBreach" && shield > 0 ? .65
            : signature === "guardShot" && run.shield.cool > 0 && run.shield.blocked > 0 ? .27 : 0
        const closeBonus = 1 + (enemy.depth<=500 ? .09*rank(run,"chokeRing") : 0)
            + (enemy.depth<=430 ? power.close || 0 : 0)
        const parts = zones.get(key) || [aim?.eyeTargets?.includes(key) ? "eye" : "body"]
        let weighted = 0, boosted = 0
        for (let pellet=0;pellet<count;pellet++) {
            const zone=parts[pellet] || "body"
            const armour=zone==="outer" && !weapon.staff ? .8 : 1
            weighted+=armour
            boosted+=armour*(zone==="eye" ? criticalAt(key) : critical)
        }
        const damage = (stats.damage * count * falloff * closeBonus + rank(run, "caliber") * .78
            + breach + kitBonus + shieldBonus + marked + chill + reaction + frostCrush + (power.damage || 0) + (run.giftDamage > 0 ? 2 : 0))
            * outgoing(run) * (weapon.id==="graduate" && run.wave<=20 ? 1.5 : 1) * through * (1 + pressure + focus + heatBonus + surge + (shield ? breachRoundsBonus : 0)) * (enemy.marked ? 1.27 : 1)
        if (weapon.marksman)
            enemy.marked = true
        if (enemy.type === "gojemarus") {
            run.gold += 2
            record(run, "goldEarned", 2)
            lootFlight(run,"gold",2,enemy,arcPoint(enemy))
            message = enemy.hp <= damage ? "Gojemarus defeated · +" + (goldPerKill(run.wave) * 5 + 2) + " gold" : "Gojemarus hit · +2 gold"
        }
        const level = Math.min(3, elementLevel + Number(signature === "concentratedBlast" && count >= 3))
        if (enemy.depth <= 500 && count >= 4 && !enemy.barrier) {
            if (signature === "rimeBell") applyToEnemy(run,enemy,"freeze",level,{forceFreeze:true})
            if (signature === "furnaceDoor") applyToEnemy(run,enemy,"explosive",Math.min(3,1+Math.floor(Gear.weaponLevel(run,gun)/2)))
        }
        if (signature === "blackHole")
            depositHole(run,arcPoint(enemy),frontId,Gear.weaponLevel(run,gun))
        message = wound(run, enemy, damage * weighted/count, "gun", element, level,
            Object.assign({},impact,{critical:boosted/weighted})) || message
        if (relay) {
            for (const neighbour of blastNeighbours(run,enemy,310+Gear.kitBonus(run,"shardRadius")).slice(0,4))
                wound(run,neighbour,2+Gear.weaponLevel(run,gun)*.55,"gun","freeze",Math.max(1,level-1))
            run.bursts.push(Object.assign(arcPoint(enemy),{front:frontId,radius:240,life:.49,span:.49,color:"#acdefe"}))
        }
        if (signature === "deepFreeze" && key === primary && gun.focus >= 6 && enemy.hp > 0 && shield <= 0) {
            applyToEnemy(run,enemy,"freeze",level,{forceFreeze:true})
            gun.focus = 0
        }
        if (signature === "closeCycle" && enemy.depth < 450)
            gun.recovery = Math.min(gun.recovery,gun.cycle*.81)
        if (signature === "reclaimSpark" && shield > 0 && !enemy.barrier)
            gun.ammo = Math.min(magazine(run), gun.ammo + 1)
        if (enemy.hp <= 0 && weapon.burst) {
            record(run, "burstKills")
            gun.recovery = Math.max(.01, gun.recovery - rank(run,"followThrough") * .09)
        }
        if (enemy.hp <= 0 && weapon.staff) {
            record(run, "staffKills")
            chargeStaff(gun, stats, Math.min(2, rank(run,"runicgrip")))
        }
        if (signature === "closeKick" && count >= 3 && enemy.hp > 0 && enemy.depth < 440 && enemyTypes[enemy.type].role !== "boss")
            enemy.depth += 109
        if (signature === "prismLock" && count >= 3 && enemy.elements.frost)
            enemy.elements.frostLeft = Math.max(enemy.elements.frostLeft, 4.5)
        if (iceSplinters || poisonSeed) {
            const kind = iceSplinters ? "freeze" : "poison"
            for (const nearby of blastNeighbours(run, enemy, 195))
                applyToEnemy(run, nearby, kind, 1)
            run.bursts.push(Object.assign(arcPoint(enemy), { front:frontId, radius:172, life:.39, span:.39, color:Elements.kinds[kind].color }))
        }
        if (weapon.splash) {
            for (const other of blastNeighbours(run, enemy, hotBurst ? 330 : 260))
                message = wound(run, other, weapon.splash * (hotBurst ? 1.65 : 1) * (Gear.weaponLevel(run,gun) ? 1.17 : 1) * outgoing(run),
                    "gun", element, elementLevel) || message
        }
        hit = true
    }
    if (hit)
        record(run, "hitShots")
    if (signature === "hitStreak")
        gun.streak = hit ? Math.min(10, gun.streak + 1) : 0
    if (hit && weapon.burst && run.lockfeed > 0 && !gun.burstRefunded) {
        gun.burstRefunded = true
        gun.ammo = Math.min(magazine(run), gun.ammo + 1)
    }
    const criticalRounds = Math.min(3,Math.max(rank(run,"critLoader"),Number(signature === "critRound")))
    if (ammoWeapon && gun.critLoaded < criticalRounds && (run.metrics.criticalHits || 0) > previousCriticals) {
        gun.critLoaded += 1
        gun.ammo = Math.min(magazine(run), gun.ammo + 1)
    }
    const sound = cue || ((run.metrics.electricJumps || 0) > jumped ? "electric"
        : (run.metrics.shatters || 0) > broken ? "shieldBreak" : "")
    announce(run, message, sound)
    return true
}

function spread(run, scoped) {
    const closeGun = weapons[Gear.current(run).id].effect === "spread"
    return (closeGun ? 1.84 : 1) * Math.max(.46, 1 - rank(run, "steadyaim") * .075) * (run.carefulAim > 0 ? .61 : 1)
        * (scoped ? Gear.weaponSocket(run).scopedSpread || 1 : 1)
}

function reload(run, hits, view, aim) {
    const gun = Gear.current(run)
    const weapon = weapons[gun.id]
    if (!canAct(run) || run.lunge || gun.reload > 0 || gun.prep > 0)
        return false
    const stats = Gear.effectiveWeaponStats(run,gun)
    if (weapon.staff)
        return !run.shield.raised && castStaff(run, gun, weapon, stats, hits || [], view || run.playerFront, aim)
    if (weapon.stab) {
        if (gun.recovery > 0 || run.shield.raised)
            return false
        gun.prep = gun.prepLength = stats.reload
        const range = weapon.stab.reach + rank(run,"longguard")*38 + (Gear.hasKit(run,"tridentKit") ? 65 : 0)
        const contact = (hits || []).map(function(id) { return impactContact(run,id,view || run.playerFront) })
            .find(function(candidate) { return candidate && candidate.point.depth <= range && !candidate.gift })
        if (closeAttackHits(run,contact)) {
            const damage = (weapon.stab.damage + (stats.damage - weapon.damage)) * outgoing(run)
            strikeContact(run,contact,damage,stats.element,stats.elementLevel,"helltrident",1)
            if (contact.enemy && contact.enemy.hp <= 0)
                record(run, "meleeKills")
        }
        announce(run, "Trident thrust", "reload")
        return true
    }
    if (weapon.melee) {
        if (gun.primed || gun.cool > 0 || gun.recovery > 0)
            return false
        gun.prep = gun.prepLength = stats.reload * (weapon.id === "duoknives" && Gear.hasKit(run,"knifeSet") ? .82 : 1)
            * Math.max(.56, 1 - rank(run,"hone") * .10)
        gun.spin = 0
        announce(run, weapon.melee.trick, "reload")
        return true
    }
    if (!Gear.usesAmmo(weapon) || gun.ammo === magazine(run))
        return false
    const kit = weapon.id === "twinpistols" && Gear.hasKit(run, "twinSet") ? .78 : 1
    const hunger = Math.min(.61, .40 + .075 * Math.max(0,rank(run,"redHunger") - 1))
        * missingHealth(run,"redHunger") * (Gear.hasKit(run,"redHungerKit") ? 1.10 : 1)
    gun.reloadLength = Math.max(.32, stats.reload * kit * (1 - hunger)
        * Math.max(.54, 1 - rank(run, "reload") * .095 - Gear.perk(run, "reload") - Gear.kitBonus(run,"reload",gun.id)
            - Tarot.value(run,"reload") - (Tarot.dark(run) ? Tarot.value(run,"nightReload") : 0)))
        * (run.hexes.reload ? 1.43 : 1) * (Gear.weaponSocket(run).reload || 1)
    gun.reload = gun.reloadLength
    gun.burstLeft = 0
    gun.spin = 0
    gun.focus = 0
    record(run,"reloads")
    announce(run, "Reloading", "reload")
    const blade = rank(run, "bayonet")
    if (blade && !run.shield.raised) {
        run.bayonetTime = .32
        const reach = 385 + Gear.perk(run, "stabReach")
        const contact = (hits || []).map(function(id) { return impactContact(run, id, view || run.playerFront) })
            .find(function(candidate) { return candidate && candidate.point.depth <= reach && !candidate.gift })
        const landed = closeAttackHits(run,contact)
        if (landed)
            strikeContact(run, contact, (4.5 + blade * 1.5) * outgoing(run), "", 0, "bayonet")
        passiveVisual(run,"bayonet",view || run.playerFront,"cut","slice",contact?.point,"BAYONET",.25)
        announce(run, landed ? "Bayonet strike" : null, "bayonet")
    }
    return true
}

function selectWeapon(run, index) {
    const slot = run.slots.weapon[index]
    if (!canAct(run) || run.lunge || !slot || !slot.item || index === run.selectedWeapon)
        return false
    Gear.current(run).reload = 0
    Gear.current(run).spin = 0
    Gear.current(run).firing = false
    Gear.current(run).burstLeft = 0
    run.selectedWeapon = index
    announce(run, weapons[slot.item.id].title + " equipped", "")
    return true
}

function expansionActive(run, id, stats, view, aimId, available) {
    const strength = stats.strength
    const local = available.filter(function(enemy) { return enemy.hp > 0 })
    const pointed = local.find(function(enemy) { return enemy.id === aimId })
        || local.reduce(function(near, foe) { return !near || foe.depth < near.depth ? foe : near }, null)
    switch (id) {
    case "bloodLibation": {
        const victims = local.filter(function(foe) { return foe.depth<=720 })
        if (!victims.length) return false
        let drained = 0
        for (const foe of victims) {
            const before = foe.hp
            wound(run,foe,12*(1+.22*strength)*outgoing(run),"ability")
            drained += Math.max(0,before-Math.max(0,foe.hp))
        }
        recoverBlood(run,Math.min(12,drained*.35))
        return "bloodDrain"
    }
    case "doorstop":
    case "kilnRing": {
        const close = local.filter(function(foe) { return foe.depth <= 500 })
        if (!close.length) return false
        for (const foe of close) {
            const damage = activeAbilities[id].damage * (1 + .22 * strength) * outgoing(run)
            wound(run,foe,damage * (id === "kilnRing" && foe.depth <= 300 ? 2 : 1),"ability",stats.element,stats.elementLevel)
        }
        return id === "kilnRing" ? "burn" : "detonation"
    }
    case "openingSalvo":
        run.salvoTime=6+strength*.35
        run.salvoBonus=run.wave<=20 ? .34 : .19
        return "boon"
    case "borrowedBeat":
        rewindBolts(run,view,.55+strength*.10)
        for (const slot of run.slots.weapon)
            if (slot.item && weapons[slot.item.id].staff) chargeStaff(slot.item,Gear.effectiveWeaponStats(run,slot.item),1)
        return "frost"
    case "lateBloom": case "breachOrder": case "fieldLesson":
    case "emberPulse": case "draftCircle": case "yellowNoon": case "staticLatch": {
        if (!local.length) return false
        const factor=id==="lateBloom" ? (run.wave>20 ? 2.2 : 1) : id==="fieldLesson" && run.wave<=20 ? 2 : 1
        const element=stats.element || (id==="lateBloom" ? "stun" : "")
        const list=id==="staticLatch" ? [pointed] : local.slice()
        for (const foe of list)
            wound(run,foe,(stats.damage || activeAbilities[id].damage || 5)*(1+strength*.22)*factor*outgoing(run)
                *(id==="breachOrder" && enemyTypes[foe.type].role==="boss" ? 2.5 : 1),"ability",element,stats.elementLevel || 1)
        return element==="electric" ? "electric" : element==="burn" ? "burn" : element==="freeze" ? "frost" : element==="poison" ? "poisonImpact" : "detonation"
    }
    case "oathWard":
        run.dodgeWindow = Math.max(run.dodgeWindow,1.2+strength*.16)
        run.dodgeFlash = .35
        return "playerDodge"
    case "liquidation": {
        if (!local.length || Gear.availableGold(run) < 20)
            return false
        const coins = Math.min(80,Gear.availableGold(run))
        spendGold(run,coins)
        for (const enemy of local.slice()) {
            wound(run,enemy,coins*.25*(1+strength*.14)*outgoing(run),"ability",coins>=50 ? "weaken" : "",2)
            run.bursts.push(Object.assign(arcPoint(enemy),{front:view,radius:210,life:.6,span:.6,color:"#ffdf63"}))
        }
        return "coinReturn"
    }
    case "eventFold":
        if (!pointed)
            return false
        depositHole(run,arcPoint(pointed),view,strength,true)
        return "seal"
    case "guardPulse": {
        const guard = run.shield
        if (!guard.absorbed || !local.length)
            return false
        const damage = (3.5 + Math.min(19,guard.absorbed*.40) + strength) * outgoing(run)
        lowerShield(run)
        guard.absorbed = 0
        run.bursts.push({ front:view,lane:0,elevation:0,depth:350,radius:420,span:.62,life:.62,color:guard.tint })
        for (const enemy of local.slice().sort(function(a,b) { return a.depth-b.depth }).slice(0,3))
            wound(run,enemy,damage,"ability","wind",1)
        return "fieldBlock"
    }
    case "reserveGuard": {
        const replenishes = run.barrier > 0 && run.barrierHp > 0 && run.barrierHp < run.barrierMax
        if (!run.shield.cool && !replenishes)
            return false
        run.shield.cool = Math.max(0,run.shield.cool - 4 - strength*.40)
        if (replenishes) {
            run.barrierHp += 1
            run.barrierRefill = .47
        }
        return "fieldGuard"
    }
    case "sureStrike":
        if (run.sureAttack)
            return false
        run.sureAttack = true
        run.surePower = strength*.28
        return "combo"
    case "sharpen":
        run.sharpenTime = 6 + strength*.6
        return "combo"
    case "riskCharge":
        if (run.health <= 15)
            return false
        run.health -= 15
        run.criticalRoll = 6 + strength*.7
        return "goreHit"
    case "critMark": {
        const aim = local.find(function(enemy) { return enemy.id === aimId })
        if (!aim)
            return false
        aim.criticalMark = 6 + strength*.80
        return "warning"
    }
    case "criticalEcho": {
        const near = local.filter(function(enemy) { return enemy.depth < 780 })
        if (!run.lastCritical || !near.length)
            return false
        const damage = Math.min(22,run.lastCritical * (.52 + strength*.055))
        run.lastCritical = 0
        run.bursts.push({ front:view,lane:0,elevation:0,depth:470,radius:320,span:.52,life:.52,color:"#ffe187" })
        for (const enemy of near)
            wound(run,enemy,damage,"ability")
        return "combo"
    }
    case "immolate":
        if (!local.length)
            return false
        for (const enemy of local)
            wound(run, enemy, (3.3 + strength + (Gear.hasKit(run,"sermonSet") ? 1.8 : 0)) * outgoing(run),
                "ability", stats.element, stats.elementLevel)
        return "burn"
    case "whiteout": {
        const targets = run.enemies.filter(function(enemy) {
            return enemy.hp > 0 && !enemy.warp && !ghosted(enemy)
                && !statusImmune(enemy, "freeze")
        })
        if (!targets.length)
            return false
        for (const enemy of targets) {
            applyToEnemy(run, enemy, "freeze", stats.elementLevel)
            enemy.elements.frozen = 2 + strength * .35 + (Gear.hasKit(run,"whiteSet") ? .50 : 0)
        }
        return "frost"
    }
    case "execution": {
        const targets = local.filter(function(enemy) { return enemyTypes[enemy.type].role !== "boss" })
        if (!targets.length)
            return false
        const enemy = sample(run, targets)
        applyToEnemy(run, enemy, "explosive", stats.elementLevel)
        wound(run, enemy, (enemy.hp + enemy.barrier + 1) * (enemy.type === "jos" && run.playerFront === view ? 10 : 1),
            "ability")
        return "detonation"
    }
    case "stormcall":
        if (!pointed)
            return false
        wound(run, pointed, (9 + strength * 1.8 + (Gear.hasKit(run,"stormSet") ? 2.6 : 0)) * outgoing(run),
            "ability", "electric", stats.elementLevel)
        return "electric"
    case "remoteward":
        run.remoteGuard = 8 + strength * 2 + (Gear.hasKit(run,"remoteSet") ? 3 : 0)
        return "seal"
    case "antidote":
        if (!run.elements.poison && run.health >= Gear.maxHealth(run)
            && !(run.elements.weaken && Gear.hasKit(run,"antidoteSet")))
            return false
        Elements.clearPoison(run.elements)
        if (Gear.hasKit(run,"antidoteSet"))
            run.elements.weaken = run.elements.weakenLeft = 0
        run.health = Math.min(Gear.maxHealth(run), run.health + 9 + 4 * strength)
        return "seal"
    case "threadstep":
        run.fastTurn = 7 + strength * 2 + (Gear.hasKit(run,"threadSet") ? 3 : 0)
        raiseBarrier(run, 2.1 + strength * .6, 1)
        return "turn"
    case "mirrormine": {
        const intercepted = run.bolts.filter(function(bolt) { return bolt.front === view })
        if (!intercepted.length)
            return false
        run.bolts = run.bolts.filter(function(bolt) { return bolt.front !== view })
        run.boltRoster += 1
        record(run, "intercepts", intercepted.length)
        if (pointed)
            wound(run, pointed, intercepted.length * (2.5 + strength + (Gear.hasKit(run,"mirrorSet") ? 2 : 0)) * outgoing(run), "ability")
        return "intercept"
    }
    case "voidaegis": {
        if (!sealTarget(run,view) || !advanceSeal(run,.34 + strength*.09 + (Gear.hasKit(run,"voidSet") ? .22 : 0)))
            return false
        for (const enemy of local)
            if (enemyTypes[enemy.type].abyss)
                applyKnockback(run,enemy,2)
        raiseBarrier(run, 2.6 + strength * .53, 1)
        return "seal"
    }
    case "panicbell": {
        const targets = run.enemies.filter(charging)
        if (!targets.length)
            return false
        const affected = new Set()
        for (const enemy of targets) {
            if (affected.has(enemy.front) || enemyTypes[enemy.type].ship)
                continue
            affected.add(enemy.front)
            enemy.attack = attackInterval(enemy)
            knockBack(run,enemy,118 + strength * 46 + (Gear.hasKit(run,"panicSet") ? 130 : 0))
        }
        return affected.size ? "warning" : false
    }
    case "searingmark":
        if (!pointed)
            return false
        pointed.marked = true
        for (const enemy of local) {
            if (Math.hypot(enemy.lane - pointed.lane, enemy.depth - pointed.depth) <= 189 + (Gear.hasKit(run,"markSet") ? 85 : 0))
                wound(run, enemy, (1.5 + strength) * outgoing(run), "ability", "burn", stats.elementLevel)
        }
        return "burn"
    case "bloodbattery": {
        const cost = Gear.hasKit(run,"bloodSet") ? 4 : 8
        if (run.health <= cost)
            return false
        run.health -= cost
        run.hurtThisWave = true
        run.infiniteAmmo = Math.max(run.infiniteAmmo, 8 + strength * 3)
        Gear.current(run).reload = 0
        return "mega"
    }
    case "snaretrap":
        if (!pointed || enemyTypes[pointed.type].ship)
            return false
        pointed.attack = Math.max(pointed.attack, 1.65 + strength)
        pointed.slow = 3 + strength * 1.3 + (Gear.hasKit(run,"snareSet") ? 2 : 0)
        return "seal"
    case "dronebeacon":
        if (run.guestTime > 0)
            return false
        callGuest(run, view, 12 + strength * 4 + (Gear.hasKit(run,"droneSet") ? 5 : 0))
        return "pet"
    case "purge": {
        const targets = run.enemies.filter(function(enemy) {
            return enemy.hp > 0 && enemy.front !== view && !enemy.warp && !enemyTypes[enemy.type].immune
        })
        if (!targets.length)
            return false
        for (const enemy of targets) {
            applyToEnemy(run, enemy, "poison", stats.elementLevel)
            enemy.attack += 1.2 + strength * .7
        }
        if (Gear.hasKit(run,"purgeSet"))
            raiseBarrier(run, 3, 1)
        return "curse"
    }
    case "mireCloud":
        if (!pointed)
            return false
        run.venomClouds.push(Object.assign(arcPoint(pointed), {
            front:view, level:stats.elementLevel, radius:235 + strength * 35,
            remaining:3.8, duration:3.8, damage:(4.5 + strength) * outgoing(run), exposed:new Set()
        }))
        if (Gear.hasKit(run,"hazmatSet"))
            run.elements.sticky = run.elements.stickyLeft = 0
        return "poisonCloud"
    case "sporeBurst": {
        const poisoned = local.filter(function(enemy) { return enemy.elements.poison > 0 })
        if (!poisoned.length)
            return false
        for (const enemy of poisoned) {
            const loss = enemy.elements.poisonLoss
            Elements.clearPoison(enemy.elements)
            run.bursts.push(Object.assign(arcPoint(enemy), {
                front:view, radius:205, life:.61, color:"#bcfa81"
            }))
            wound(run, enemy, (5 + strength * 2 + loss * enemy.baseHp * .65
                + (Gear.hasKit(run, "sporeBreach") ? 2 : 0)) * outgoing(run), "ability")
        }
        return "poisonBurst"
    }
    case "tarpit": {
        const targets = local.filter(function(enemy) {
            return !enemyTypes[enemy.type].ship && !statusImmune(enemy, "sticky")
                && enemy.elements.sticky < stats.elementLevel && (enemy.elements.sticky || !enemy.elements.stickyGuard)
        })
        if (!targets.length)
            return false
        const kit = Gear.hasKit(run, "tarpitSet")
        for (const enemy of targets) {
            applyToEnemy(run, enemy, "sticky", stats.elementLevel)
            const extra = strength * .40 + (kit && enemyTypes[enemy.type].role !== "boss" ? 1 : 0)
            enemy.elements.stickyLeft += extra
            enemy.elements.stickyGuard += extra
            run.bursts.push(Object.assign(arcPoint(enemy), { front:view, radius:115, life:.61, color:"#deff78" }))
        }
        return "slimeImpact"
    }
    case "sidestep":
        if (run.dodgeWindow > 0)
            return false
        run.dodgeWindow = .75 + strength * .15 + (Gear.hasKit(run,"katanaSet") ? .30 : 0) + (Gear.hasKit(run,"glassKit") ? .12 : 0)
        run.dodgeFlash = .27
        return "playerDodge"
    case "riposte":
        if (!weapons[Gear.current(run).id].melee || run.parry > 0)
            return false
        run.parry = 1.1 + strength * .14
        if (Gear.hasKit(run,"reaperKit"))
            run.meleeRush = 4
        return "playerDodge"
    case "bladesweep": {
        const weapon = weapons[Gear.current(run).id]
        if (!weapon.melee)
            return false
        const close = local.filter(function(enemy) {
            return enemy.depth <= weapon.melee.reach + rank(run,"longguard") * 38 + (Gear.hasKit(run,"gravKit") ? 90 : 0)
        })
        if (!close.length)
            return false
        for (const enemy of close)
            wound(run, enemy, (7.4 + strength * 2.3) * outgoing(run), "ability")
        run.bursts.push({ lane:0,elevation:-12,depth:280,front:view,radius:275,life:.42,span:.42,color:weapon.color })
        return "combo"
    }
    case "salvo":
        if (!Gear.usesAmmo(weapons[Gear.current(run).id]) || run.breachRounds)
            return false
        run.breachRounds = 3 + Number(Gear.hasKit(run,"deadeyeSet")) + strength
        return "buy"
    case "lockfeed":
        if (!weapons[Gear.current(run).id].burst || run.lockfeed > 0)
            return false
        run.lockfeed = 4 + strength * .55
        return "buy"
    case "runefill": {
        const staff = Gear.current(run)
        const lance = Gear.effectiveWeaponStats(run,staff)
        if (!lance.chargeCost || staff.charge >= lance.chargeCost)
            return false
        chargeStaff(staff, lance, 2 + strength + Number(Gear.hasKit(run,"earthKit")))
        return "staffCast"
    }
    case "guststep":
        if (!local.length)
            return false
        for (const enemy of local)
            applyToEnemy(run, enemy, "wind", stats.elementLevel)
        run.fastTurn = Math.max(run.fastTurn, 4 + strength * .5)
        return "playerDodge"
    case "emberharvest": {
        const burning = local.filter(function(enemy) { return enemy.elements.burn > 0 })
        if (!burning.length)
            return false
        for (const enemy of burning) {
            const level = enemy.elements.burn
            enemy.elements.burn = enemy.elements.burnLeft = enemy.elements.burnTick = 0
            run.bursts.push(Object.assign(arcPoint(enemy), { front:view,radius:235,life:.44,span:.44,style:"burn",color:"#ff9855" }))
            for (const nearby of blastNeighbours(run, enemy, 230))
                wound(run, nearby, (2.7 + level * 1.5 + strength) * outgoing(run), "ability")
        }
        return "burn"
    }
    case "axeHook":
        if (!pointed || enemyTypes[pointed.type].ship)
            return false
        pointed.depth = Math.max(enemyTypes[pointed.type].reach, pointed.depth - 320 - strength * 56 - (Gear.hasKit(run,"hookKit") ? 100 : 0))
        pointed.attack = Math.max(pointed.attack, 1.95)
        return "axeImpact"
    case "runesurge": {
        const staff = Gear.current(run)
        if (!weapons[staff.id].staff || !staff.charge || !local.length)
            return false
        const power = staff.charge
        staff.charge = 0
        for (const enemy of local)
            wound(run, enemy, (3 + 2.7 * power + strength + (Gear.hasKit(run,"avatarKit") ? 3 : 0)) * outgoing(run), "ability")
        return "staffImpact"
    }
    default:
        return utilityActive(run, activeAbilities[id], stats, local, pointed, view, aimId)
    }
}

function utilityActive(run, card, stats, local, pointed, view, aimId) {
    if (!card || !card.form)
        return false
    const strength=stats.strength
    const power = card.value
    const damage = (power + strength*.9) * Gear.affinity(run,card) * outgoing(run)
    const gun = Gear.current(run)
    const near = local.filter(function(enemy) { return enemy.depth <= 575 && !enemyTypes[enemy.type].ship })
    switch (card.form) {
    case "clearRound":
        if (!Gear.usesAmmo(weapons[gun.id]) || gun.ammo>=magazine(run) && !gun.reload) return false
        gun.ammo=Math.min(magazine(run),gun.ammo+power+strength)
        if (gun.reload>0) gun.reload=Math.max(.02,gun.reload-.45)
        return "reload"
    case "stormPush": {
        const targets=near.slice().sort(function(a,b){return a.depth-b.depth}).slice(0,3)
        const tier=Math.min(3,1+Number(Tarot.weather(run))+Number(strength>=2))
        for (const foe of targets) applyKnockback(run,foe,tier)
        return targets.length && "turn"
    }
    case "solarCone":
    case "nightVeil": {
        const hot=card.form==="solarCone"
        const tier=stats.elementLevel
        const targets=(hot ? local.filter(function(foe){return foe.depth<=925}) : local.slice())
            .sort(function(a,b){return a.depth-b.depth}).slice(0,hot ? 3 : 4)
        for (const foe of targets) wound(run,foe,damage,"ability",hot ? "burn" : "blind",tier)
        return targets.length && (hot ? "burn" : "voidIntrusion")
    }
    case "stormGlass": {
        const bolts=run.bolts.filter(function(bolt){return bolt.front===view && !bolt.returning && !bolt.bubble})
            .sort(function(a,b){return a.remaining-b.remaining}).slice(0,4)
        if (!bolts.length) return false
        const ids=new Set(bolts.map(function(bolt){return bolt.id}))
        run.bolts=run.bolts.filter(function(bolt){return !ids.has(bolt.id)})
        run.boltRoster++
        record(run,"intercepts",bolts.length)
        const nearFoe=local.slice().sort(function(a,b){return a.depth-b.depth})[0]
        if (nearFoe) wound(run,nearFoe,bolts.length*damage,"ability")
        return "intercept"
    }
    case "lunarWard":
        if (run.barrierHp===0) {
            run.barrierMax=0
            raiseBarrier(run,6+strength*.6,1)
        }
        else if (!run.shield.cool) return false
        run.shield.cool=Math.max(0,run.shield.cool-2-strength*.3)
        return "shieldBlock"
    case "repelShield":
        for (const enemy of near)
            applyToEnemy(run,enemy,"wind",run.shield.raised ? 3 : 1 + Number(strength >= 2))
        return near.length && "fieldBlock"
    case "edgeRing":
        for (const enemy of near)
            wound(run,enemy,damage,"ability","",0,{blood:"katana"})
        return near.length && "combo"
    case "seekMark":
        if (!pointed)
            return false
        wound(run,pointed,damage,"ability")
        pointed.mark = 4 + strength
        return "warning"
    case "electrify":
        if (!pointed)
            return false
        wound(run,pointed,damage,"ability","electric",Math.min(3,1 + strength))
        return "electric"
    case "abyss": {
        if (!sealTarget(run,view) || !advanceSeal(run,power + strength*.09))
            return false
        for (const enemy of local)
            if (enemyTypes[enemy.type].abyss)
                enemy.attack += .72 + strength*.33
        return "seal"
    }
    case "wideSlow": {
        const first = run.enemies.filter(function(enemy) { return !enemy.warp && enemy.hp > 0 && enemy.attack > 0 })
            .sort(function(a,b) { return a.depth-b.depth }).slice(0,3)
        for (const enemy of first)
            enemy.attack += power + strength*.34
        return first.length && "warning"
    }
    case "reloadCut":
        if (!gun.reload && !pointed)
            return false
        if (gun.reload)
            gun.reload = Math.max(.02,gun.reload*(.5 - Math.min(.28,strength*.075)))
        if (pointed)
            applyToEnemy(run,pointed,"weaken",1)
        return "buy"
    case "axePrep":
        if (!weapons[gun.id].throwing || run.axePower)
            return false
        gun.prep *= .33
        run.axePower = power + strength*.16
        return "axeThrow"
    case "sight":
        run.carefulAim = power + strength*.8
        return "buy"
    case "cleanFrost":
        run.elements.frost = run.elements.frostLeft = run.elements.frozen = 0
        run.fastTurn = Math.max(run.fastTurn,power + strength*.7)
        return "turn"
    case "shieldWindow":
        if (!run.shield.raised || run.shield.bolstered)
            return false
        run.shield.bolstered = true
        run.shield.charges += 1
        run.shield.capacity += 1
        gun.recovery *= .58
        return "fieldGuard"
    case "ember": {
        const closest = Object.create(null)
        for (const enemy of run.enemies) {
            if (!enemy.warp && (!closest[enemy.front] || enemy.depth < closest[enemy.front].depth))
                closest[enemy.front] = enemy
        }
        for (const enemy of Object.values(closest))
            wound(run,enemy,damage,"ability","burn",strength >= 2 ? 3 : 2)
        return Object.keys(closest).length && "burn"
    }
    case "interrupt": {
        const threats = run.enemies.filter(charging).slice(0,2)
        for (const enemy of threats) {
            enemy.attack = Math.max(enemy.attack,attackInterval(enemy))
            enemy.ranged = Math.max(enemy.ranged,1.7)
            wound(run,enemy,damage,"ability","stun",1)
        }
        return threats.length && "warning"
    }
    case "corrode":
        if (!pointed)
            return false
        wound(run,pointed,damage,"ability","poison",strength >= 2 ? 3 : 2)
        applyToEnemy(run,pointed,"weaken",1)
        return "poisonCloud"
    case "burstPulse":
        if (!pointed)
            return false
        wound(run,pointed,damage*(weapons[gun.id].burst ? 1.72 : 1),"ability","stun",1)
        return "combo"
    case "mint": {
        const gift = byId(run.gifts,aimId)
        if (!gift || gift.front !== view)
            return false
        claimGift(run,gift)
        for (const enemy of near)
            wound(run,enemy,(2.8 + strength) * outgoing(run),"ability","electric",1)
        return giftCue(gift)
    }
    case "pierceScroll": {
        if (!pointed)
            return false
        const lane = lanePosition(pointed) / Math.max(1,pointed.depth)
        const lineup = local.filter(function(enemy) {
            return Math.abs(lanePosition(enemy) / Math.max(1,enemy.depth) - lane) <= .17
        }).sort(function(a,b) { return a.depth-b.depth }).slice(0,3)
        for (let i = 0; i < lineup.length; ++i)
            wound(run,lineup[i],damage*Math.pow(.84,i),"ability","stun",1)
        return "combo"
    }
    default:
        return false
    }
}

function useAbility(run, slot, view, aimId, aim) {
    const equipped = run.slots.active[slot]
    const id = equipped && equipped.item ? equipped.item.id : ""
    const thawAvailable = id === "thawCoil" && run.phase === "combat" && !run.stun && !run.elements.stunned
        && (!run.grab || !run.grab.constrict)
    if ((!canAct(run) && !thawAvailable) || run.hypnosis)
        return false
    if (!id) {
        announce(run, "Equip an active ability at Droid Lab", "")
        return false
    }
    if (activeCooldown(run, id) > 0)
        return false
    if (!Gear.environmentMatches(run,activeAbilities[id].environment)) {
        announce(run,activeAbilities[id].title+" requires "+Gear.environmentNames[activeAbilities[id].environment],"")
        return false
    }
    const slotBonus = Gear.socketEffect(run,"active",equipped)
    const stats = Gear.activeStats(equipped.item, slotBonus.strength)
    const strength = stats.strength
    const gun = Gear.current(run)
    const healthBefore=run.health

    const available = run.enemies.filter(function(enemy) {
        return enemy.front === view && enemy.warp <= 0 && !enemy.waitingBoss && !ghosted(enemy)
    })
    const before=available.map(function(enemy) {return SkillArt.footprint(enemy)})
    const boon=Meta.benefits(run)
    const timing=boon.duration>1 ? captureActiveTiming(run,available) : null
    const grenadesBefore=run.grenades.length
    const ammoBefore=gun.ammo
    const barrierBefore=run.barrierHp
    const boltsBefore=run.bolts.length
    let feedback = ""
    let sound = "seal"
    switch (id) {
    case "boneShatter":
        run.boneRank = Math.min(4,1+strength)
        run.boneTime = 8+strength*.85
        sound = "boneShatter"
        break
    case "colourSpill": {
        const targets = available.slice().sort(function(a,b) { return a.depth-b.depth }).slice(0,3)
        if (!targets.length)
            return false
        const effects = ["poison","electric","freeze","burn","blind","weaken"]
        for (const foe of targets) {
            const kind = effects.splice(Math.floor(random(run)*effects.length),1)[0]
            wound(run,foe,(5+strength*1.5)*outgoing(run),"ability",kind,Math.min(3,1+Math.floor(strength)))
        }
        sound = "colourSpill"
        break
    }
    case "riftWeld":
        if (!sealTarget(run,view) || !advanceSeal(run,.27+strength*.08))
            return false
        for (const enemy of available)
            if (enemyTypes[enemy.type].abyss)
                applyKnockback(run,enemy,2)
        break
    case "blackWake":
        if (!available.length)
            return false
        for (const enemy of available.slice().sort(function(a,b) { return a.depth-b.depth }).slice(0,4))
            wound(run,enemy,(4.2+strength*1.25)*outgoing(run),"ability","blind",stats.elementLevel)
        sound = "inkFire"
        break
    case "undertow":
        if (!available.length)
            return false
        for (const enemy of available) {
            applyKnockback(run,enemy,3,strength*45)
            interruptAttack(enemy)
        }
        sound = "voidPush"
        break
    case "breakLamp": {
        const lamps = available.filter(function(enemy) { return enemy.type === "lantis" })
        if (!lamps.length)
            return false
        for (const enemy of lamps)
            enemy.lureOff = 8+strength*2.2
        sound = "lureBreak"
        break
    }
    case "quietWater":
        if (!run.elements.blind && !available.length)
            return false
        run.elements.blind = run.elements.blindLeft = 0
        for (const enemy of available) {
            interruptAttack(enemy)
            enemy.attack += 2.4+strength*.6
        }
        sound = "voidPush"
        break
    case "brineFlare": {
        const foes = available.filter(function(enemy) { return enemyTypes[enemy.type].abyss })
        if (!foes.length)
            return false
        for (const enemy of foes)
            wound(run,enemy,(7.4+strength*1.8)*outgoing(run),"ability","burn",stats.elementLevel)
        sound = "burn"
        break
    }
    case "iceBloom": {
        const cold = available.filter(function(enemy) { return !statusImmune(enemy,"freeze") }).slice(0,3+Number(strength>1))
        if (!cold.length)
            return false
        for (const enemy of cold)
            applyToEnemy(run,enemy,"freeze",stats.elementLevel,{forceFreeze:true})
        sound = "frost"
        break
    }
    case "thawCoil":
        if (!run.elements.frost && !gun.recovery)
            return false
        run.elements.frost = run.elements.frostLeft = run.elements.frozen = 0
        gun.recovery = Math.max(0,gun.recovery-.55-strength*.11)
        sound = "winterPulse"
        break
    case "quickload":
        if (gun.ammo === magazine(run) && (!strength || !gun.recovery))
            return false
        gun.ammo = magazine(run)
        gun.critLoaded = 0
        gun.reload = 0
        if (Gear.hasKit(run, "quartermaster"))
            gun.recovery = 0
        else if (strength)
            gun.recovery = Math.max(0, gun.recovery - .28 * strength)
        break
    case "repulse":
        if (!available.length)
            return false
        for (const enemy of available) {
            applyKnockback(run,enemy,3,strength*62+(Gear.hasKit(run,"scattergun") ? 140 : 0))
            enemy.attack = attackInterval(enemy)
        }
        break
    case "shock": {
        const targets = available.filter(function(enemy) { return enemy.hp > 0 })
        if (!targets.length)
            return false
        const enemy = targets.find(function(target) { return target.id === aimId })
            || targets.reduce(function(a, b) { return a.depth <= b.depth ? a : b })
        feedback = wound(run, enemy, (5 + strength * 1.5 + (Gear.hasKit(run, "hellbore") ? 2 : 0)) * outgoing(run),
            "ability", stats.element, stats.elementLevel)
        sound = "electric"
        break
    }
    case "ward":
        raiseBarrier(run, 3.6 + strength * .54 + (Gear.hasKit(run, "riot") ? 1.5 : 0), 2)
        break
    case "trauma":
        if (run.health >= Gear.maxHealth(run))
            return false
        run.health = Math.min(Gear.maxHealth(run), run.health + 29 + strength * 9 + (Gear.hasKit(run, "lance") ? 15 : 0))
        break
    case "interceptor": {
        const remaining = run.bolts.filter(function(bolt) { return bolt.front !== view })
        if (remaining.length === run.bolts.length)
            return false
        record(run, "intercepts", run.bolts.length - remaining.length)
        run.bolts = remaining
        run.boltRoster += 1
        if (strength) {
            for (const enemy of available.filter(function(target) { return enemyTypes[target.type].role === "alien" }))
                enemy.attack += 1.3 * strength
        }
        if (Gear.hasKit(run, "ion"))
            gun.ammo = Math.min(magazine(run), gun.ammo + 4)
        break
    }
    case "decoy":
        run.decoyFront = view
        run.decoyTime = 2.7 + strength * .75
        for (const enemy of available)
            applyToEnemy(run, enemy, stats.element, stats.elementLevel)
        break
    case "breaker": {
        const shielded = available.filter(function(enemy) { return enemy.barrier > 0 })
        if (!shielded.length)
            return false
        for (const enemy of shielded) {
            breakBarrier(run, enemy)
            enemy.flash = .14
            enemy.attack += .96 * strength
        }
        break
    }
    case "stasis":
        run.frozenFront = view
        run.frozenTime = 3 + strength * .68 + (Gear.hasKit(run, "arc") ? 1.5 : 0)
        break
    case "overdrive":
        run.fastFire = 6.5 + strength * 1.15 + (Gear.hasKit(run, "dread") ? 4 : 0)
        break
    case "sunfall": {
        const targets = run.enemies.filter(function(enemy) {
            return enemy.warp <= 0 && !ghosted(enemy)
        })
        if (!targets.length && !run.bolts.length)
            return false
        if (run.bolts.length)
            record(run, "intercepts", run.bolts.length)
        run.bolts = []
        run.boltRoster += 1
        for (const enemy of targets)
            feedback = wound(run, enemy, (8.25 + strength * 2.3 + (Gear.hasKit(run, "solar") ? 5 : 0)) * outgoing(run),
                "ability", stats.element, stats.elementLevel) || feedback
        run.powerFlash = 0.42
        break
    }
    case "reclaim":
        run.slots.weapon.forEach(function(slot, index) {
            if (slot.item) {
                slot.item.ammo = Gear.magazine(run, index)
                slot.item.recovery = 0
                slot.item.reload = 0
            }
        })
        if (Gear.hasKit(run, "crucible") || strength)
            raiseBarrier(run, 2 + .34 * strength, Gear.hasKit(run, "crucible") ? 2 : 1)
        run.powerFlash = .22
        break
    case "sealcharge": {
        if (!sealTarget(run,view) || !advanceSeal(run,(Gear.hasKit(run,"launcher") ? .76 : .48)+strength*.08))
            return false
        for (const enemy of available)
            if (enemyTypes[enemy.type].abyss) {
                applyKnockback(run,enemy,2)
                enemy.slow = Math.max(enemy.slow,3.5)
            }
        break
    }
    case "frag":
    case "cryogrenade":
    case "nullgrenade":
    case "gravitywell": {
        const focus = target(run, aimId) || available[0]
        if (!focus && !aim)
            return false
        const base = id === "frag" ? 5.4 + (Gear.hasKit(run, "minigun") ? 2 : 0)
            : id === "cryogrenade" ? 3 : id === "nullgrenade" ? 2 : 7
        sound = "throwGrenade"
        if (id === "nullgrenade" && view === "down")
            advanceSeal(run,.19+strength*.04+(Gear.hasKit(run,"volt") ? .11 : 0))
        const radius = (id === "gravitywell" ? 235 + (Gear.hasKit(run, "prism") ? 95 : 0) : 196)
            * (1 + Gear.perk(run, "blastRadius"))
        throwGrenade(run, view, focus ? focus.id : 0, Object.assign({ x:.5, y:.5 }, aim, { kind:id }),
            (base + strength * 1.25 + rank(run, "booster") * .78) * outgoing(run), radius, .46, strength, stats)
        break
    }
    case "flashflare":
        if (!available.length)
            return false
        for (const enemy of available) {
            enemy.attack += 1.15 + strength * .15 + (Gear.hasKit(run, "razor") ? .8 : 0)
            enemy.mark = 4 + strength * 1.1
            applyToEnemy(run, enemy, stats.element, stats.elementLevel)
        }
        break
    case "repairkit":
        if (!run.elements.poison && run.health === Gear.maxHealth(run) && gun.ammo === magazine(run))
            return false
        Elements.clearPoison(run.elements)
        run.health = Math.min(Gear.maxHealth(run), run.health + Math.round(Gear.maxHealth(run) * .12)
            + strength * 5 + (Gear.hasKit(run, "ember") ? 12 : 0))
        gun.ammo = magazine(run)
        gun.critLoaded = 0
        gun.reload = 0
        break
    case "arcshield": {
        const filtered = run.bolts.filter(function(bolt) { return bolt.front !== view })
        const absorbed = run.bolts.length - filtered.length
        if (absorbed) {
            record(run, "intercepts", absorbed)
            run.bolts = filtered
            run.boltRoster += 1
            const nearest = available.filter(function(enemy) { return !enemyTypes[enemy.type].ship })
                .reduce(function(near, enemy) { return !near || enemy.depth < near.depth ? enemy : near }, null)
            if (nearest) {
                run.bursts.push(Object.assign(arcPoint(nearest), {
                    front:view, radius:165, life:.37, color:Elements.kinds.electric.color
                }))
                wound(run, nearest, (3 + Math.min(3, absorbed) + strength) * outgoing(run), "ability", stats.element, stats.elementLevel)
                sound = "electric"
            }
        }
        raiseBarrier(run, 4.3 + strength * .68, Gear.hasKit(run, "harrier") ? 3 : 2)
        break
    }
    case "reversal":
        gun.ammo = magazine(run)
        gun.critLoaded = 0
        gun.reload = 0
        if (Gear.hasKit(run, "cyclone"))
            gun.spin = 1
        for (const enemy of available) {
            knockBack(run,enemy,232 + strength * 60)
            applyToEnemy(run, enemy, stats.element, stats.elementLevel)
        }
        if (run.health <= Gear.maxHealth(run) * .35)
            run.health = Math.min(Gear.maxHealth(run), run.health + 14 + strength * 5 + (Gear.hasKit(run, "cyclone") ? 8 : 0))
        break
    default:
        sound = expansionActive(run, id, stats, view, aimId, available)
        if (!sound)
            return false
        break
    }

    if (slotBonus.healRatio && run.health>healthBefore)
        recoverBlood(run,Math.min(5,(run.health-healthBefore)*slotBonus.healRatio))
    if (slotBonus.otherCooldown) {
        const other=run.slots.active[1-slot]?.item?.id
        if (other && run.cooldowns[other]>0)
            run.cooldowns[other]=Math.max(0,run.cooldowns[other]-slotBonus.otherCooldown)
    }
    if (slotBonus.weaponRecovery)
        gun.recovery=Math.max(0,gun.recovery-slotBonus.weaponRecovery)
    if (timing) extendActiveTiming(run,available,timing,boon.duration)
    for (const grenade of run.grenades.slice(grenadesBefore)) {
        grenade.damage*=boon.active*(1+Gear.perk(run,"activeDamage"))
        grenade.effect=Object.assign({},grenade.effect,{durationScale:boon.duration})
    }
    const targets=available.filter(function(enemy,index) {
        return SkillArt.footprint(enemy)!==before[index]
    }).sort(function(a,b) {return Number(b.id===aimId)-Number(a.id===aimId) || a.depth-b.depth}).slice(0,5)
    const summary=run.health>healthBefore ? "+"+Math.round(run.health-healthBefore)+" HP"
        : run.barrierHp>barrierBefore ? "+"+(run.barrierHp-barrierBefore)+" BARRIER"
        : gun.ammo>ammoBefore ? "+"+(gun.ammo-ammoBefore)+" ROUNDS"
        : run.bolts.length<boltsBefore ? (boltsBefore-run.bolts.length)+" INTERCEPTED" : ""
    abilityVisual(run,id,view,stats,aim,targets,summary)
    run.cooldowns[id] = abilityRecovery(run, equipped, stats, slotBonus)
    tarotEvent(run,"cast")
    announce(run,feedback || activeAbilities[id].title+" activated","ability:"+id)
    return true
}

var timedActives=["barrier","frozenTime","decoyTime","dodgeWindow","safeTime","boneTime","salvoTime","fastFire",
    "fastTurn","remoteGuard","infiniteAmmo","maxGearTime","carefulAim","lockfeed","sharpenTime","parry"]
var timedTargets=["slow","mark","recover"]
var timedStatus=["burnLeft","frostLeft","frozen","stunned","stunGate","blindLeft","weakenLeft","stickyLeft","poisonLeft","poisonDuration"]

function captureTimers(entity,names) {
    return names.map(function(key) {return entity[key] || 0})
}

function captureActiveTiming(run,enemies) {
    return {player:captureTimers(run,timedActives),clouds:run.venomClouds.length,
        target:enemies.map(function(enemy) {return captureTimers(enemy,timedTargets)}),
        status:enemies.map(function(enemy) {return captureTimers(enemy.elements,timedStatus)})}
}

function extendTimers(object,names,previous,factor) {
    for (let i=0;i<names.length;i++) {
        const key=names[i]
        if (object[key]>previous[i]) object[key]=previous[i]+(object[key]-previous[i])*factor
    }
}

function extendActiveTiming(run,enemies,before,factor) {
    extendTimers(run,timedActives,before.player,factor)
    for (let i=0;i<enemies.length;i++) {
        extendTimers(enemies[i],timedTargets,before.target[i],factor)
        extendTimers(enemies[i].elements,timedStatus,before.status[i],factor)
    }
    for (const cloud of run.venomClouds.slice(before.clouds)) {
        cloud.life*=factor
        cloud.span*=factor
    }
}

function rewindBolts(run,view,seconds) {
    for (const bolt of run.bolts) {
        if (bolt.front!==view || bolt.returning || bolt.bubble) continue
        bolt.remaining=Math.min(bolt.duration*1.35,bolt.remaining+seconds)
    }
}

function abilityVisual(run,id,view,stats,aim,targets,summary) {
    const ability=activeAbilities[id]
    const style=SkillArt.profile(ability)
    const rank=SkillArt.intensity(ability.rarity)
    const points=(targets || []).map(arcPoint)
    const self=style.anchor==="self"
    const target=style.anchor==="target"
    const exact=target ? points.slice(0,1) : self ? [] : points
    addSkillVisual(run,{ability:id,front:view,kind:style.kind,motif:style.motif,anchor:style.anchor,points:exact,
        color:SkillArt.colors[style.kind],x:self ? .5 : aim && style.anchor!=="field" ? aim.x : .5,
        y:self ? .73 : aim && style.anchor!=="field" ? aim.y : .47,
        power:rank,span:[0,.88,1.08,1.28,1.65][rank],label:SkillArt.caption(style.kind,rank,summary,stats.elementLevel)})
}

function addSkillVisual(run, effect) {
    run.abilityEvents=run.abilityEvents.slice(-3)
    run.abilityEvents.push(Object.assign(effect,{id:run.nextId++,life:effect.span}))
}

function passiveVisual(run,id,frontId,kind,motif,point,label,interval) {
    if (run.time<(run.passiveFxReady[id] || 0)) return
    run.passiveFxReady[id]=run.time+(interval ?? .38)
    addSkillVisual(run,{ability:id,front:frontId,kind:kind,motif:motif,anchor:point ? "target" : "self",
        points:point ? [{lane:point.lane,elevation:point.elevation,depth:point.depth}] : [], color:SkillArt.colors[kind],
        x:.5,y:.71,power:1,span:.72,label:label,passive:true})
}

function abilityRecovery(run, slot, stats, bonus) {
    const power = bonus || Gear.socketEffect(run,"active",slot)
    const ability = stats || Gear.activeStats(slot.item, power.strength)
    const kitTiming = slot.item.id === "execution" && Gear.hasKit(run,"verdictSet") ? .82 : 1
    return ability.cooldown * Meta.benefits(run).recovery * kitTiming * (run.waveTime<30 ? Math.max(.60,1-.07*rank(run,"secondHand")) : 1) * Math.max(.38, 1 - rank(run, "cooling") * .085
        - rank(run, "deepcell") * .068 - Gear.perk(run, "cooldown") - Gear.kitBonus(run,"active",slot.item.id)
        - Tarot.value(run,"cooldown") - (Tarot.weather(run) ? 0 : Tarot.value(run,"clearCooldown"))) * (power.cooldown || 1)
}

function evadesImpact(run, projectile) {
    if (run.dodgeWindow > 0) {
        run.dodgeWindow = 0
    } else {
        const evasive = rank(run, "slipstream")
        if (!projectile || !evasive || run.time >= run.turnEvadeUntil || run.time < run.dodgeReadyAt)
            return false
        run.turnEvadeUntil = 0
        run.dodgeReadyAt = run.time + Math.max(6, 11 - (evasive - 1) * 1.25)
    }
    run.dodgeFlash = .34
    if (rank(run,"slipstream"))
        passiveVisual(run,"slipstream",run.playerFront,"wind","evade",null,"DODGED")
    record(run, "dodges")
    run.health = Math.min(Gear.maxHealth(run), run.health + rank(run,"secondWind") * 2.5)
    announce(run, "Attack dodged", "playerDodge")
    return true
}

function damagePlayer(run, amount, origin, type, burningTick, payload, projectile) {
    const attacker = enemyTypes[type]
    const rain = Conditions.isRain(run.weatherEffect)
    const source = payload && payload.sourceId ? target(run,payload.sourceId)
        : run.enemies.find(function(enemy) { return enemy.type === type && enemy.front === origin && enemy.hp > 0 && !enemy.warp })
    const charged = !burningTick && !payload?.environment && (payload?.stormCharged || (!projectile && source?.stormCharged))
    const affected = charged ? Object.assign({},payload,{element:"electric",elementLevel:1,electricStun:.08,forceStun:0})
        : payload && payload.element !== undefined ? payload : type === "gigafinterus" ? {element:"burn",elementLevel:3} : attacker
    if (burningTick && rain && !payload?.soulDrain)
        return
    if (affected.element === "electric" && rain)
        amount *= 2
    if (!burningTick && !payload?.mirror && !payload?.environment
        && attackMisses(run,payload?.blindAtFire ?? source?.elements.blind ?? 0)) {
        hostileMiss(run,attacker,payload?.blindAtFire ?? source?.elements.blind)
        return
    }
    const chance = payload && payload.critChance !== undefined ? payload.critChance : (attacker.crit || 0) + (source && source.linked ? .14 : 0)
    const critical = !burningTick && (payload && payload.critical !== undefined ? payload.critical : criticalRoll(run,chance))
    const areaHit = !burningTick && !projectile && (payload && (payload.beam || payload.blast)
        || ["gigafinterus","stinkaturumus","battlestar","seraphijus","meteor"].includes(type))
    if (run.shield.raised && origin===run.playerFront && !burningTick && !areaHit) {
        blockWithShield(run,amount,origin,type,payload,projectile,critical)
        return
    }
    if (!burningTick && run.parry > 0) {
        run.parry = 0
        const attacker = run.enemies.find(function(enemy) {
            return enemy.type === type && enemy.front === run.playerFront && enemy.depth <= 530 && !enemy.warp
        })
        run.counterTarget = attacker ? attacker.id : 0
        announce(run, "Riposte · parried", "combo")
        return
    }
    if (!burningTick && evadesImpact(run, projectile))
        return
    if (!burningTick) record(run,"unblockedHits")
    if (!burningTick && (run.barrier > 0 && run.barrierHp > 0 || run.barrierCell.hp > 0)) {
        if (run.barrierHp > 0)
            run.barrierHp -= 1
        else
            run.barrierCell.hp -= 1
        const charges = run.barrierHp+run.barrierCell.hp
        record(run, "blocks")
        if (!charges)
            run.barrierBreak = .47
        announce(run, charges ? "Barrier absorbed the attack" : "Barrier shattered",charges ? "shieldBlock" : "shieldBreak")
        return
    }
    const padding=Gear.passiveSockets(run,"armour",.18)
    const insulation = attacker.role === "alien" ? rank(run, "insulation") * .085 : 0
    const ground = affected.element === "electric" ? rank(run, "arcGround") * .08 : 0
    const blast = affected.blast || affected.element === "explosive" || ["princoratus","meteor","seraphijus"].includes(type)
        ? rank(run, "blastPlating") * .09 + Gear.passiveSockets(run,"blastResist",.16) : 0
    const steady = Gear.current(run).reload > 0 ? rank(run, "holdFirm") * .079 : 0
    const first = !run.hurtThisWave ? rank(run, "survivor") * .15 : 0
    const fragile = rank(run,"glassCannon")
    const exposure = fragile ? Math.min(1.59, 1.35 + (fragile - 1)*.068) : 1
    const guard = !burningTick && origin === run.playerFront ? orbitGuard(run) : null
    let guarded = 1
    if (guard) {
        const enemy = run.enemies.find(function(candidate) { return candidate.type === type && candidate.front === origin && candidate.hp > 0 })
        const emitter = payload && Number.isFinite(payload.lane) ? payload : enemy ? arcPoint(enemy) : null
        const screenX = emitter ? .5 + emitter.lane / (Math.max(55,emitter.depth) * run.aspect * 1.0634) : .5
        if (Math.abs(screenX - guard.x) <= guard.half) {
            guarded = 1 - guard.defence
            run.guardFlash = .39
            passiveVisual(run,"orbitWard",origin,"guard","shield",null,"ORBITAL BLOCK")
        }
    }
    const criticalPower = critical ? Math.max(1, 1.5 - rank(run,"hardplate")*.25 - Gear.perk(run,"critResist")) : 1
    const lining = run.shield.raised && origin===run.playerFront && areaHit ? Math.max(.44,1 - rank(run,"guardInsulation")*.16) : 1
    const brine = attacker.abyss ? rank(run,"brinePlate")*.083 : 0
    const apron = !burningTick && source && source.depth <= 500 ? .08 * rank(run,"furnaceApron") : 0
    const damage = Math.max(1, amount * (1-apron) * (1-rank(run,"firstShift")*(run.wave<=20 ? .08 : .02)) * (projectile ? Math.max(.70,1-rank(run,"leeSide")*.04) : 1) * (run.cursed ? 1.20 : 1) * criticalPower * lining * exposure * guarded * Math.max(.25,
        1 - rank(run, "armour") * .095 - padding - insulation - ground - blast - steady - first - brine - Gear.perk(run, "armor") - (run.covenant && run.covenant.tarot ? Tarot.armor(run,Gear.maxHealth(run),projectile) : 0)))
    if (run.desktop?.gpuMode)run.desktop.pressure=Math.min(1,run.desktop.pressure+.06+damage/400)
    const before=run.health
    run.health = Math.max(0, run.health - damage)
    if (critical) {
        run.incomingCriticalUntil=run.time+1.15
        run.incomingCriticalDamage=before-run.health
    }
    record(run,"damageTaken",before-run.health)
    if (type === "crufixicatus" && source && !source.scareUsed && !burningTick && run.health > 0) {
        source.scareUsed = true
        run.scareTime = 3
        run.shield.held = false
        lowerShield(run)
        announce(run,"The face is too close","crufiScream")
    }
    if (source?.type === "blandromedus" && payload?.drain && !burningTick)
        feedHeal(run,source,.045)
    run.hurtThisWave = true
    if (run.enemies.some(function(enemy) {return enemyTypes[enemy.type].role === "boss" && !enemy.waitingBoss}))
        run.bossHurt = true
    run.impactType = attacker.id
    run.impactTime = burningTick ? .15 : attacker.shake[2]
    if (!burningTick)
        run.injury += 1
    if (type === "zadrrimus")
        run.distortion = 5
    if (!burningTick && payload && payload.ink)
        run.inkStains = true
    if (!burningTick && affected.element && !(rain && affected.element === "burn")) {
        const effect = affected.element
        const level = affected.elementLevel
        if (effect === "electric") {
            for (const slot of run.slots.active)
                if (slot.item)
                    run.cooldowns[slot.item.id] = Math.max(run.cooldowns[slot.item.id] || 0,abilityRecovery(run,slot))
            if (affected.forceStun)
                playerStatus(run,"stun",1,{stunDuration:affected.forceStun})
            else if (random(run) < (affected.electricStun ?? (type === "hasasasa" ? .045 : Elements.electricStun(level))) * (1 - rank(run,"arcGround") * .13))
                playerStatus(run,"stun",1)
        } else if (effect === "explosive") {
            run.rumble = Math.max(run.rumble, .15 + level * .075)
        } else {
            const poisonResistance = effect === "poison"
                ? { durationScale:Math.max(.5, 1 - rank(run,"sporeMask") * .11 - rank(run,"sporeScreen") * .10 - rank(run,"cleanLungs")*.10) } : null
            const frostResist = Math.max(.45,1-rank(run,"sleetLining")*.11-Gear.perk(run,"frostResistance"))
            const resistance = effect === "freeze" ? {forceFreeze:rain,durationScale:frostResist,freezeChance:type === "hasasasa" ? .045 : undefined} : effect === "blind"
                ? {durationScale:Math.max(.35,1-rank(run,"nightFilter")*.15-Gear.perk(run,"blindResistance"))}
                : poisonResistance
            playerStatus(run,effect,level,resistance)
        }
        if (effect === "burn") {
            run.burnOrigin = origin
            run.burnSource = payload?.environment ? "" : type
        }
        const prior=run.health
        run.health = Math.min(run.health, Gear.maxHealth(run))
        if (prior>run.health) record(run,"damageTaken",prior-run.health)
    }
    if (!burningTick || run.health === 0)
        announce(run, burningTick ? "Burn damage" : (critical ? "Critical hit · " : "") + attacker.title + " hit you"
            + (affected.element === "electric" ? " · active cooldowns restarted" : " · "+front(origin).title),
            type === "zadrrimus" ? "distortion" : affected.element === "burn" ? "burn"
                : affected.element === "freeze" ? "frost" : affected.element === "electric" ? "electric"
                    : affected.element === "sticky" ? "slimeImpact" : affected.element === "poison" ? "poisonImpact" : "damage")
    if (run.health === 0) {
        if (!payload?.environment)
            record(run,"enemyDeaths_"+type)
        run.phase = "defeat"
        run.finishReason="death"
        announce(run, "The Shrine fell", "loss")
    }
}

function launchBolts(run, enemy, creature) {
    const burst = enemy.type === "mothergalian" ? 5 : ["fizzalien","skorochiyus"].includes(enemy.type) ? 2 : 1
    const duration = creature.boltTime || .72
    for (let shot = 0; shot < burst; shot += 1) {
        const stagger = enemy.type === "fizzalien" ? shot*.26 : 0
        const spread = enemy.type === "mothergalian" ? 53 : enemy.type === "skorochiyus" ? 128 : 36
        run.bolts.push({ id: run.nextId++, front: enemy.front, lane: lanePosition(enemy) + (shot-(burst-1)*.5)*spread,
            elevation:elevation(enemy) + (creature.serpent ? 59 : creature.sniper ? 26 : 0),
            depth:enemy.depth-(creature.distance ? 135 : 0),duration:duration,remaining:duration + stagger,
            damage:enemy.damage * (burst === 5 ? .40 : burst > 1 ? .72 : 1) * Elements.damageFactor(enemy.elements),
            color:enemy.type === "veilskate" ? creature.accent : enemy.stormCharged ? "#e2c9ff" : enemy.type === "nightosphere" ? "#cb63ff" : creature.serpent ? "#e4c1ff" : creature.accent,
            source:enemy.type, sourceId:enemy.id, element:creature.element || "", stormCharged:!!enemy.stormCharged,
            hp:creature.boltHealth || 0, maximum:creature.boltHealth || 0,sniper:!!creature.sniper,voidShot:!!creature.voidBoss || !!creature.ink,
            ink:!!creature.ink,localOnly:!!creature.ink || ["nightosphere","lalaBubu","blandromedus"].includes(enemy.type),
            crystal:enemy.type === "nightosphere",drain:!!creature.vampire,
            elementLevel:creature.elementLevel || 0, electricStun:creature.electricStun || 0,
            critChance:(creature.crit || 0) + (enemy.linked ? .14 : 0),blindAtFire:enemy.elements.blind })
    }
    run.boltRoster += 1
    announce(run, null, creature.ink ? "inkFire" : enemy.type === "veilskate" ? "veilBolt" : enemy.type === "nightosphere" ? "orbBolt" : creature.vampire ? "bloodBolt" : creature.voidBoss ? "voidFire" : creature.sniper ? "sniperFire"
        : creature.serpent ? "snakeBolt" : creature.triad ? "magnetFire" : "attack:"+enemy.type)
}

function launchBreath(run, enemy) {
    run.flames.push({ front:enemy.front, lane:lanePosition(enemy), elevation:elevation(enemy) - 21, depth:enemy.depth,
        remaining:1.22, duration:1.22, hit:false, damage:enemy.damage * Elements.damageFactor(enemy.elements) })
    announce(run, "Gigafinterus breathes fire", "breath")
}

function launchPoisonCloud(run, enemy, damage) {
    const point = arcPoint(enemy)
    point.elevation += 25 * enemySize(enemy)
    run.venomClouds.push(Object.assign(point, {
        front:enemy.front, hostile:true, hit:false, impactDelay:.82, remaining:2.5, duration:2.5,
        radius:440, damage:damage, level:3
    }))
    announce(run, front(enemy.front).label + " · Stinkaturumus breathes poison", "poisonCloud")
}

function poisonFog(run, view) {
    let fog = 0
    for (const cloud of run.venomClouds) {
        if (cloud.hostile && cloud.front === view) {
            const arrive = Math.max(0, Math.min(1, (cloud.duration - cloud.remaining - .42) / .65))
            fog = Math.max(fog, arrive * Math.min(1, cloud.remaining / .65))
        }
    }
    return fog * Math.max(.40, 1 - rank(run,"sporeScreen") * .16 - Gear.perk(run,"poisonClarity"))
}

function updatePoisonClouds(run, dt) {
    for (let i = run.venomClouds.length - 1; i >= 0; i -= 1) {
        const cloud = run.venomClouds[i]
        cloud.remaining = Math.max(0, cloud.remaining - dt)
        if (!cloud.remaining) {
            run.venomClouds.splice(i, 1)
            continue
        }
        if (cloud.hostile) {
            if (!cloud.hit && cloud.front === run.playerFront && cloud.duration - cloud.remaining >= cloud.impactDelay) {
                cloud.hit = true
                damagePlayer(run, cloud.damage, cloud.front, "stinkaturumus", false, { element:"poison", elementLevel:cloud.level })
                if (run.phase === "defeat")
                    return
            }
            continue
        }
        for (const enemy of run.enemies.slice()) {
            if (enemy.front !== cloud.front || enemy.hp <= 0 || enemy.warp
                || ghosted(enemy) || cloud.exposed.has(enemy.id))
                continue
            const position = arcPoint(enemy)
            if (Math.hypot(position.lane - cloud.lane, position.elevation - cloud.elevation,
                (position.depth - cloud.depth) * .78) <= cloud.radius) {
                cloud.exposed.add(enemy.id)
                wound(run, enemy, cloud.damage, "ability", "poison", cloud.level)
            }
        }
    }
}

function launchSlime(run, enemy, damage) {
    run.bolts.push({
        id:run.nextId++, front:enemy.front, lane:lanePosition(enemy), elevation:elevation(enemy), depth:enemy.depth,
        duration:1.13, remaining:1.13, damage:damage, hp:1.8, maximum:1.8,
        color:"#c9ed5e", source:enemy.type, sourceId:enemy.id, slug:true, parent:enemy.parent,
        element:"sticky", elementLevel:3, critChance:enemy.linked ? .14 : 0, blindAtFire:enemy.elements.blind
    })
    run.boltRoster += 1
    announce(run, null, "slimeSpit")
}

function fireSpinShard(run, enemy) {
    enemy.attackFlash = .38
    run.bolts.push({
        id:run.nextId++, front:enemy.front, lane:lanePosition(enemy), elevation:elevation(enemy), depth:enemy.depth,
        duration:1.18, remaining:1.18, damage:enemy.damage * .36 * Elements.damageFactor(enemy.elements),
        hp:1.8, maximum:1.8, color:"#8af4de", source:enemy.type, sourceId:enemy.id, shard:true,
        critChance:enemyTypes[enemy.type].crit + (enemy.linked ? .14 : 0),blindAtFire:enemy.elements.blind
    })
    run.boltRoster += 1
    announce(run, null, "spinShard")
}

function updateBreaths(run, dt) {
    for (let i = run.flames.length - 1; i >= 0; i -= 1) {
        const flame = run.flames[i]
        flame.remaining = Math.max(0, flame.remaining - dt)
        if (!flame.hit && flame.duration - flame.remaining >= .42) {
            flame.hit = true
            damagePlayer(run, flame.damage, flame.front, "gigafinterus")
            if (run.phase === "defeat")
                return
        }
        if (!flame.remaining)
            run.flames.splice(i, 1)
    }
}

function updateDetonations(run, dt) {
    run.bursts = run.bursts.filter(function(burst) {
        burst.life = Math.max(0, burst.life - dt)
        return burst.life > 0
    })
    for (const origin of run.detonations.splice(0)) {
        const explosive = Elements.kinds.explosive
        const fuse = origin.danger ? 0 : rank(run, "chainfuse")
        const radius = (origin.radius || explosive.radius[origin.level]) * (1 + (origin.danger ? 0 : Gear.perk(run, "blastRadius")
            + (Gear.hasKit(run, "demolition") ? .12 : 0)))
        const damage = origin.damage || explosive.damage[origin.level] * (origin.danger ? enemyScale(run.wave, run.difficulty)
            : outgoing(run) * (1 + fuse * .095))
        const nearby = run.enemies.filter(function(enemy) {
            return enemy.front === origin.front && enemy.warp <= 0 && !ghosted(enemy)
                && Math.hypot(lanePosition(enemy) - origin.lane, elevation(enemy) - origin.elevation, enemy.depth - origin.depth) < radius
        })
        for (const enemy of nearby)
            wound(run, enemy, damage, origin.danger ? "hostileBlast" : "explosion",
                fuse ? "explosive" : "", Math.max(1, origin.level - 1),{weaponId:origin.weaponId})
        const playerInRange = origin.enemyType === "seraphijus" ? origin.front === run.playerFront
            : Math.hypot(origin.lane, origin.elevation, origin.depth) < radius
        if (origin.danger && playerInRange)
            damagePlayer(run, damage, origin.front, origin.enemyType || "princoratus", false, { blast:true })
        run.rumble = Math.max(run.rumble, .12 + origin.level * .055)
        run.bursts.push(Object.assign({ radius:radius, life:.61 }, origin))
        if (fuse && nearby.length)
            passiveVisual(run,"chainfuse",origin.front,"explosive","shockwave",origin,"CHAIN EXPLOSION",.13)
        if (run.phase === "defeat")
            return
        announce(run, origin.danger ? enemyTypes[origin.enemyType || "princoratus"].title + " detonated" : "Volatile target detonated", "detonation")
    }
}

function petIntercept(run, pet) {
    const index = run.bolts.findIndex(function(bolt) { return bolt.front === pet.front && !bolt.returning && !bolt.bubble })
    if (index < 0)
        return false
    run.bolts.splice(index, 1)
    run.boltRoster += 1
    record(run, "intercepts")
    pet.flash = .45
    return true
}

function petStrike(run, pet, helper, enemy) {
    pet.aimLane = lanePosition(enemy)
    pet.aimElevation = elevation(enemy)
    pet.aimDepth = enemy.depth
    pet.flash = .45
    pet.strikes += 1
    announce(run, null, "pet")
    const power = helper.power
    const secondary=Pets.secondary[helper.id]
    const charged=!!secondary && pet.chargePending && pet.chargeLeft<=0
    if (charged) {
        pet.chargePending=false
        pet.chargedFlash=.72
        if (helper.id==="beetle") {
            petIntercept(run,pet)
            petIntercept(run,pet)
        }
    }
    if (power === "seal" && enemy.front === "down" && enemyTypes[enemy.type].abyss)
        advanceSeal(run,(pet.id === "firefly" ? .23 : .16)+pet.level*.045)
    const damage = (helper.damage + (power === "peck" && enemy.depth <= 425 ? .57 : 0))
        * pet.stats.damageScale * (power === "break" && enemy.barrier ? 3 : 1)
        * (charged ? secondary.power : 1)
    if (power === "delay")
        enemy.attack += .75 + pet.level * .28
    else if (power === "mark")
        enemy.mark = (charged ? 5.7 : pet.id === "archive" ? 6 : 3.5) + pet.level * .42
    else if (power === "slow")
        enemy.slow = 1.45 + pet.level * .44
    else if (power === "ammo" && pet.strikes % 2 === 0) {
        const gun = Gear.current(run)
        gun.ammo = Math.min(magazine(run), gun.ammo + 1)
    }
    const third = pet.strikes % 3 === 0
    const element=charged && secondary.kind==="burn" || power==="greenfire" && third ? "burn"
        : power==="blind" ? "blind" : power==="mind" ? "weaken" : power==="spark" && third ? "electric" : ""
    wound(run, enemy, damage * (pet.cursed ? .78 : 1), pet,
        element,power==="blind" ? 2 : 1)
    if (charged && helper.id==="owl") recoverBlood(run,3)
    if (charged && helper.id==="chicken" && enemy.hp>0)
        applyKnockback(run,enemy,1)
    if (power === "mend" && third)
        run.health = Math.min(Gear.maxHealth(run), run.health + 2 + pet.level * .70)
    if (power === "heal" && enemy.hp <= 0)
        run.health = Math.min(Gear.maxHealth(run), run.health + 2 + pet.level * 1.15)
    if (power === "splash" || power==="greenfire" && charged) {
        const nearby = run.enemies.filter(function(other) {
            return other.id !== enemy.id && other.front === pet.front
                && other.warp <= 0 && !ghosted(other) && Math.abs(other.depth - enemy.depth) < (charged ? 290 : 190)
                && Math.abs(other.lane - enemy.lane) < (charged ? 280 : pet.id === "wyvern" ? 220 : 165)
        }).slice(0, charged ? 3 : 2)
        for (const other of nearby)
            wound(run, other, damage * .61, pet, charged ? "burn" : "", 1)
    }
    if (charged)
        passiveVisual(run,helper.id,pet.front,secondary.kind,"companion",arcPoint(enemy),secondary.title.toUpperCase(),.5)
    else if (secondary) {
        pet.ordinaryStrikes=(pet.ordinaryStrikes || 0)+1
        if (pet.ordinaryStrikes%secondary.every===0) {
            pet.chargeLength=secondary.charge*(1-pet.level*.09)
            pet.chargeLeft=pet.chargeLength
            pet.chargePending=true
            pet.next=pet.chargeLength
        }
    }
}

function updatePet(run, pet, dt) {
    if (!pet)
        return
    const helper = Pets.spec(pet.id)
    const fallen = run.enemies.find(function(enemy) {
        return enemy.type === "archfellanus" && enemy.front === run.playerFront && enemy.hp > 0 && !enemy.warp
    })
    pet.hostile = !!fallen
    pet.next = Math.max(0, pet.next - dt)
    pet.flash = Math.max(0, pet.flash - dt)
    pet.chargedFlash=Math.max(0,(pet.chargedFlash || 0)-dt)
    if (pet.resting > 0) {
        pet.resting = Math.max(0, pet.resting - dt)
        if (!pet.resting)
            pet.stamina = pet.stats.duty + rank(run,"sparePart") * 2 + Gear.perk(run,"petDuty")
        return
    }
    pet.stamina = Math.max(0, pet.stamina - dt)
    if (!pet.stamina) {
        pet.restLength=pet.resting = Math.max(3, pet.stats.rest - rank(run,"sparePart") * .80 - Gear.passiveSockets(run,"petRest",2))
        pet.targetId = 0
        return
    }
    if (pet.travel > 0) {
        pet.travel = Math.max(0, pet.travel - dt)
        if (pet.travel === 0) {
            pet.front = pet.destination
            pet.lane = -pet.heading * 290
            pet.next = Math.max(pet.next, .45)
        } else {
            pet.lane += pet.heading * dt * 430 / pet.stats.travel
        }
        return
    }

    if (fallen) {
        if (pet.front !== run.playerFront) {
            const direction = directionToward(pet.front,run.playerFront)
            pet.destination = turnFrom(pet.front,direction)
            pet.heading = direction === "left" || direction === "down" ? -1 : 1
            pet.travelLimit = pet.travel = pet.stats.travel
        } else if (!pet.next) {
            pet.next = pet.stats.interval
            pet.aimLane = 0
            pet.aimElevation = 0
            pet.aimDepth = 65
            pet.flash = .45
            damagePlayer(run,4.5+helper.damage*pet.stats.damageScale*2.15,pet.front,"archfellanus",false,{sourceId:fallen.id})
            announce(run,helper.title+" turned against you","petBetray")
        }
        return
    }
    const candidates = run.enemies.filter(function(enemy) {
        return enemy.hp > 0 && enemy.warp <= 0 && !enemy.waitingBoss && enemy.type !== "hallucination" && !ghosted(enemy)
    })
    let focused = candidates.find(function(enemy) { return enemy.id === pet.targetId })
    if (!focused) {
        candidates.sort(function(a, b) {
            const score = function(enemy) {
                return enemy.depth + (enemy.front === pet.front ? 0 : 160)
                    - (helper.power === "seal" && enemy.type === "crawler" ? 440 : 0)
            }
            return score(a) - score(b)
        })
        focused = candidates[0]
        pet.targetId = focused ? focused.id : 0
        if (focused)
            pet.next = Math.max(pet.next, run.wave <= 3 ? 2.1 : .75)
    }
    if (!pet.next && !pet.chargePending && helper.power === "guard" && petIntercept(run, pet)) {
        pet.next = pet.stats.interval
        return
    }
    if (focused && focused.front !== pet.front) {
        const direction = directionToward(pet.front, focused.front)
        pet.destination = turnFrom(pet.front, direction)
        pet.heading = direction === "left" || direction === "down" ? -1 : 1
        pet.travelLimit = pet.stats.travel
        pet.travel = pet.travelLimit
        return
    }

    const targetLane = focused ? lanePosition(focused) + pet.heading * 95 : Math.sin(run.time * 1.4) * 120 - 142
    const targetDepth = focused ? Math.max(220, focused.depth - 104) : 725
    const targetElevation = helper.crawl ? -124 : focused ? elevation(focused) + 81 : 76
    const approach = Math.min(1, dt * 3.1)
    pet.lane += (targetLane - pet.lane) * approach
    pet.depth += (targetDepth - pet.depth) * approach
    pet.elevation += (targetElevation - pet.elevation) * approach
    if (focused && pet.chargePending)
        pet.chargeLeft=Math.max(0,pet.chargeLeft-dt)
    if (focused && pet.next === 0 && (!pet.chargePending || pet.chargeLeft===0)) {
        pet.next = pet.stats.interval
        petStrike(run, pet, helper, focused)
    }
}

function adjacentGround(run, current) {
    return sample(run, groundFronts.filter(function(id) {
        return Math.abs(groundFronts.indexOf(id) - groundFronts.indexOf(current)) === 1
    }))
}

function moveBoss(run, enemy, dt, movement) {
    if (enemy.hitStop > 0)
        return false
    const speed = enemy.travelSpeed * movement * (enemy.slimeRetreat ? 1.65 : 1)
    const voidBoss = enemy.type === "voidGlitch"
    if (enemy.sideTo) {
        const boundary = voidBoss ? 875 : Math.max(223,Math.min(495,enemy.depth*.72))
        enemy.lane += enemy.sideDirection * speed * dt
        if (Math.abs(enemy.lane) >= boundary) {
            enemy.front = enemy.sideTo
            enemy.lane = -enemy.sideDirection * boundary
            enemy.sideTo = ""
            enemy.slimeRetreat = false
            enemy.sideIn = (voidBoss ? 4.3 : 6.35) + random(run) * 2.6
            announce(run, enemyTypes[enemy.type].title + " moved to " + front(enemy.front).label, "moveBoss")
        }
        return
    }
    enemy.sideIn = Math.max(0, enemy.sideIn - dt)
    enemy.lane -= Math.sign(enemy.lane) * Math.min(Math.abs(enemy.lane), speed * dt)
    if (!enemy.sideIn && voidBoss && (enemy.front === "down" || enemy.front === "front" && random(run) < .28)) {
        enemy.sideTo = enemy.front === "down" ? sample(run,["left","right"]) : "down"
        enemy.sideDirection = enemy.sideTo === "left" || enemy.sideTo === "down" && random(run) < .5 ? -1 : 1
    } else if (!enemy.sideIn && groundFronts.includes(enemy.front)) {
        enemy.sideTo = adjacentGround(run, enemy.front)
        enemy.sideDirection = groundFronts.indexOf(enemy.sideTo) > groundFronts.indexOf(enemy.front) ? 1 : -1
    }
}

function bossMovement(enemy) {
    const spec = enemyTypes[enemy.type]
    return spec.role === "boss" && !spec.ship && !spec.leviathan && enemy.hp <= enemy.maxHp * .25 ? 1.43 : 1
}

function wander(run, enemy, dt) {
    enemy.maneuverIn = Math.max(0, enemy.maneuverIn - dt)
    if (!enemy.maneuverIn) {
        const fighter = ["jon","endme","lalaBubu"].includes(enemy.type)
        enemy.driftLane = (random(run) * 2 - 1) * (fighter ? 293 : 173)
        enemy.heightGoal = (random(run) * 2 - 1) * (fighter ? 152 : 105)
        enemy.maneuverIn = .54 + random(run) * (fighter ? .78 : 1.35)
    }
    const step = enemy.travelSpeed * dt
    enemy.lane += Math.max(-step, Math.min(step, enemy.driftLane - enemy.lane))
    enemy.driftHeight += Math.max(-step * .68, Math.min(step * .68, enemy.heightGoal - enemy.driftHeight))
}

function smashHazard(run, enemy, index) {
    const origin = arcPoint(enemy)
    const danger = enemy.type === "seraphijus" ? 670 : 472
    run.detonations.push(Object.assign(origin, { radius:danger, damage:enemy.damage, danger:true,
        level:3, front:enemy.front, enemyType:enemy.type }))
    remove(run, index, false)
    announce(run, enemy.type === "meteor" ? "Meteor impact" : "Seraphijus detonated", "meteor")
}

function fireShip(run, enemy) {
    const intact = Ship.remaining(enemy)
    const part = intact.length ? sample(run, intact) : null
    enemy.activeGun = part ? part.id : "core"
    enemy.attackFlash = .33
    if (part)
        part.flash = .31
    const time = part ? .99 : 1.88
    const shift = part ? [part.lane] : [-162, 0, 162]
    for (const lane of shift) {
        run.bolts.push({ id:run.nextId++, front:"up", lane:lane, elevation:part ? elevation(enemy)+part.height : 18, depth:enemy.depth - 185,
            duration:time, remaining:time, hp:part ? 3.2 : 10.6, maximum:part ? 3.2 : 10.6,
            damage:enemy.damage * (part ? part.damage : .26) * Elements.damageFactor(enemy.elements),
            color:part ? part.tint : "#fff2a7", source:"hasasasa", sourceId:enemy.id, core:!part,
            critChance:enemy.linked ? .14 : 0,blindAtFire:enemy.elements.blind,
            element:part ? part.element : "", elementLevel:part ? part.elementLevel : 0, blast:!!part && part.blast })
    }
    run.boltRoster += 1
    announce(run, null, part ? "turret" : "cannon")
}

function stepBattlestar(run, enemy, dt) {
    const beam = enemyTypes.battlestar.beam
    if (enemy.beamWarning > 0) {
        enemy.beamWarning = Math.max(0, enemy.beamWarning - dt)
        if (!enemy.beamWarning) {
            enemy.beamLeft = beam.duration
            enemy.beamTick = .24
            announce(run, null, "beamFire")
        }
        return true
    }
    if (enemy.beamLeft <= 0)
        return false
    enemy.beamLeft = Math.max(0, enemy.beamLeft - dt)
    enemy.beamTick -= dt
    if (enemy.beamTick <= 0) {
        enemy.beamTick += beam.tick
        if (enemy.front === run.playerFront)
            damagePlayer(run, enemy.damage * Elements.damageFactor(enemy.elements), enemy.front, enemy.type, false,
                { sourceId:enemy.id,beam:true })
    }
    return true
}

function stepGoldRay(run, enemy, creature, dt) {
    if (enemy.beamWarning > 0) {
        enemy.beamWarning = Math.max(0, enemy.beamWarning - dt)
        if (!enemy.beamWarning) {
            enemy.beamLeft = .48
            enemy.attackFlash = .40
            let taken = 0
            if (enemy.front === run.playerFront) {
                const before = run.health
                damagePlayer(run, enemy.damage * .40, enemy.front, enemy.type, false, { sourceId:enemy.id,beam:true })
                if (run.health < before) {
                    taken = Math.min(run.debug && run.debugMoney ? 0 : run.gold, Math.round(goldPerKill(run.wave) * 1.45))
                    enemy.stolenGold += taken
                    Gear.chargeGold(run,taken)
                }
            }
            announce(run, taken ? "Skarabatunus stole " + taken + " gold" : null, "goldRay")
        }
        return true
    }
    if (enemy.beamLeft > 0) {
        enemy.beamLeft = Math.max(0, enemy.beamLeft - dt)
        return true
    }
    if (run.time >= enemy.goldAttackAt) {
        enemy.goldAttackAt = run.time + creature.beamsEvery
        enemy.beamWarning = .77
        announce(run, front(enemy.front).title + " · Skarabatunus lining up a gold ray", "goldWarn")
        return true
    }
    return false
}

function feedHeal(run, enemy, fraction) {
    const health = enemy.hp
    enemy.hp = Math.min(enemy.maxHp,enemy.hp + enemy.maxHp*fraction)
    if (enemy.hp > health) {
        enemy.feedingHeal = .77
        announce(run,"Nosferapabakus healed from a bite","feedBite")
    }
}

function stepFeeding(run, enemy, dt, bites) {
    if (!enemy.feed) {
        if (run.time < enemy.feedAfter || enemy.hp > enemy.maxHp*.94)
            return false
        enemy.feedAfter = run.time + .56
        const prey = run.enemies.filter(function(candidate) {
            const role = enemyTypes[candidate.type].role
            return candidate !== enemy && candidate.front === enemy.front && candidate.hp > 0 && !candidate.warp
                && !ghosted(candidate) && role !== "void" && role !== "boss" && role !== "hazard"
                && Math.hypot(candidate.lane-enemy.lane,candidate.depth-enemy.depth) <= 535
        }).sort(function(a,b) {
            return Math.hypot(a.lane-enemy.lane,a.depth-enemy.depth) + (a.depth < enemy.depth ? 120 : 0)
                - Math.hypot(b.lane-enemy.lane,b.depth-enemy.depth) - (b.depth < enemy.depth ? 120 : 0)
        })[0]
        if (!prey)
            return false
        enemy.feedAfter = run.time + 6.8
        enemy.feed = { id:prey.id, time:0, lane:enemy.lane, depth:enemy.depth, targetLane:prey.lane, targetDepth:prey.depth,
            yaw:Math.atan2(prey.lane-enemy.lane,enemy.depth-prey.depth)*180/Math.PI, hit:false }
        announce(run,"Nosferapabakus is turning on another demon","feedWindup")
    }
    const feed = enemy.feed
    feed.time += dt
    const blend = Math.max(0,Math.min(1,(feed.time-.22)/.30,(1.02-feed.time)/.50))
    const eased = blend*blend*(3-2*blend)
    enemy.lane = feed.lane + (feed.targetLane-feed.lane)*eased*.85
    enemy.depth = feed.depth + (feed.targetDepth-feed.depth)*eased*.85
    const turn = Math.max(0,Math.min(1,feed.time/.24,(1.02-feed.time)/.33))
    enemy.feedYaw = feed.yaw*turn
    if (!feed.hit && feed.time >= .52) {
        feed.hit = true
        enemy.attackFlash = .40
        bites.push({ biter:enemy.id,target:feed.id })
    }
    if (feed.time >= 1.02)
        enemy.feed = null
    return true
}

function landBites(run, bites) {
    for (const bite of bites) {
        const biter = target(run,bite.biter)
        const prey = target(run,bite.target)
        if (!biter || !prey || prey.front !== biter.front || prey.warp || prey.hp <= 0 || ghosted(prey)
            || Math.hypot(prey.lane-biter.lane,prey.depth-biter.depth) > 215)
            continue
        const before = prey.hp
        wound(run,prey,biter.damage*.50*Elements.damageFactor(biter.elements),"devour","",0,{ blood:"feedingBite",attackerId:biter.id })
        if (prey.hp < before) {
            feedHeal(run,biter,.10)
            if (prey.type === "gendoustagus" && prey.hp <= 0)
                biter.cursed = true
        }
    }
}

function strike(run, enemy, creature) {
    if (enemy.type === "lalaBubu" && enemy.front !== run.playerFront)
        return
    enemy.attackFlash = enemy.type === "lucifoverus" ? .22 : .33
    const damage = enemy.damage * Elements.damageFactor(enemy.elements) * (enemy.cursed ? .8 : 1)
    if (enemy.type === "fearme") {
        if (enemy.front !== run.playerFront || !run.viewReady)
            return
        announce(run,null,"attack:"+enemy.type)
        if (attackMisses(run,enemy.elements.blind)) {
            hostileMiss(run,creature,enemy.elements.blind)
            return
        }
        if (run.shield.raised) {
            blockWithShield(run,Gear.maxHealth(run)*.5,enemy.front,enemy.type,{sourceId:enemy.id},false,false)
            knockBack(run,enemy,1120)
            enemy.attack=Math.max(enemy.attack,creature.interval)
            run.bursts.push(Object.assign(arcPoint(enemy),{front:enemy.front,radius:164,life:.45,span:.45,color:"#c880f6"}))
            announce(run,"Shield repelled Fearme","")
            return
        }
        run.fearCut = true
        const prior=run.health
        run.health = Math.min(run.health,Gear.maxHealth(run))
        record(run,"unblockedHits")
        record(run,"damageTaken",prior-run.health)
        run.impactType = enemy.type
        run.impactTime = .64
        run.hurtThisWave = true
        run.injury += 1
        run.rumble = .74
        enemy.retreat = true
        beginWarp(enemy,"sink",1.61)
        announce(run,"Fearme took half your maximum health for this wave","soulTaken")
    } else if (creature.battlestar) {
        enemy.beamWarning = creature.beam.warning
        announce(run, front(enemy.front).title + " · Go Go Battlestar locking on", "beamWarn")
    } else if (enemy.type === "tenmani") {
        if (beginGrab(run,enemy,2.75,true))
            announce(run,"Constricted · break free after the bite","tentacleGrab")
    } else if (enemy.type === "faeel") {
        damagePlayer(run,damage,enemy.front,enemy.type,false,{sourceId:enemy.id,element:"electric",elementLevel:2,forceStun:2})
        announce(run,null,"faeelBite")
    } else if (creature.role === "alien" || creature.serpent || creature.voidBoss || creature.vampire || ["nightosphere","skorochiyus"].includes(enemy.type)) {
        launchBolts(run, enemy, creature)
    } else if (enemy.type === "gigafinterus") {
        launchBreath(run, enemy)
    } else if (enemy.type === "stinkaturumus") {
        launchPoisonCloud(run, enemy, damage)
    } else if (enemy.type === "saslimigus") {
        launchSlime(run, enemy, damage)
    } else if (enemy.type === "hasasasa") {
        fireShip(run, enemy)
    } else if (enemy.type === "lucifoverus") {
        announce(run,null,"attack:"+enemy.type)
        const status = sample(run, ["burn","freeze","electric","stun","blind","poison","weaken","explosive"])
        damagePlayer(run, damage, enemy.front, enemy.type, false, { sourceId:enemy.id, element:status, elementLevel:1 })
        enemy.nextFront = adjacentGround(run, enemy.front)
        enemy.sideTo = ""
        enemy.recover = 5
        beginWarp(enemy, "departure", .46)
    } else if (creature.devour) {
        announce(run,null,"attack:"+enemy.type)
        const before = run.health
        damagePlayer(run,damage,enemy.front,enemy.type,false,{ sourceId:enemy.id })
        if (run.health < before)
            feedHeal(run,enemy,.12)
    } else {
        announce(run,null,"attack:"+enemy.type)
        damagePlayer(run, damage, enemy.front, enemy.type, false, { sourceId:enemy.id })
    }
}

function heatLimit(run, weapon, stats) {
    const longBurn = weapon.id === "furnacebeam" && Gear.hasKit(run, "furnaceSet")
        || weapon.id === "chainsaw" && Gear.hasKit(run, "sawSet")
    return stats.heat + (longBurn ? .6 : 0)
}

function coolWeapon(run, gun, weapon, stats, slot) {
    gun.firing = false
    gun.cool = stats.cooling * (Gear.weaponSocket(run,slot).heatRecovery || 1)
    gun.spin = 0
    gun.focus = 0
    announce(run, weapon.title + " cooling", "overheat")
}

function tickWeapon(run, slot, index, dt, firingHeld) {
    const gun = slot.item
    if (!gun)
        return
    const weapon = weapons[gun.id]
    const stats = Gear.effectiveWeaponStats(run,gun)
    gun.castTime=Math.max(0,(gun.castTime || 0)-dt)
    gun.recovery = Math.max(0, gun.recovery - dt)
    gun.burstWait = Math.max(0, (gun.burstWait || 0) - dt)
    if (gun.prep > 0) {
        gun.prep = Math.max(0, gun.prep - dt)
        if (!gun.prep && weapon.melee)
            gun.primed = true
    }
    gun.cool = Math.max(0, (gun.cool || 0) - dt)
    const held = firingHeld && !run.shield.raised && !stunTime(run) && index === run.selectedWeapon && !gun.reload && !gun.prep && !gun.cool
        && (!Gear.usesAmmo(weapon) || gun.ammo > 0 || unlimitedAmmo(run))
    if (stats.spinup) {
        const kitCharge = gun.id === "starDestroyer" && run.infiniteAmmo > 0 && Gear.hasKit(run, "starSet") ? .75 : 1
        gun.spin = held ? Math.min(1, gun.spin + dt / (stats.spinup * kitCharge * Math.max(.32, 1 - rank(run, "flywheel") * .17)))
            : Math.max(0, gun.spin - dt * 2.5)
    }
    const running = held && (!stats.spinup || gun.spin >= 1)
    if (weapon.signature === "rotaryRamp")
        gun.hold = Math.max(0, Math.min(2.25, (gun.hold || 0) + dt * (running ? 1 : -2.2)))
    gun.firing = !!(weapon.sustain && running)
    if (weapon.sustain) {
        const limit = heatLimit(run, weapon, stats)
        if (gun.cool > 0) {
            gun.heat = limit * gun.cool / stats.cooling
        } else if (gun.firing) {
            gun.heat = Math.min(limit, gun.heat + dt)
            if (gun.heat >= limit)
                coolWeapon(run, gun, weapon, stats,slot)
        } else {
            gun.heat = Math.max(0, gun.heat - dt * .80)
            if (weapon.signature === "beamFocus")
                gun.focus = 0
        }
    }
    if (gun.reload > 0) {
        gun.reload = Math.max(0, gun.reload - dt)
        if (!gun.reload) {
            gun.ammo = Gear.magazine(run, index)
            gun.critLoaded = 0
        }
    }
}

function update(run, dt, sealing, firingHeld, aim, viewReady) {
    if (run.phase !== "combat")
        return
    if (tickTakeover(run,dt)) return
    if (run.scareTime > 0) {
        run.scareTime = Math.max(0,run.scareTime-dt)
        return
    }
    run.time += dt
    const overclocked=run.maxGearTime > 0
    run.maxGearTime = Math.max(0,run.maxGearTime-dt)
    if (overclocked && !run.maxGearTime)
        Gear.clampStats(run)
    if (run.desktop) {
        const desktop=run.desktop
        const floor=desktop.locked ? 0 : Math.min(37,(desktop.cpu || 0)*42)
        desktop.heat=Math.max(floor,(desktop.heat || 0)-dt*(desktop.locked ? 28 : 13))
        if(desktop.heat<45)desktop.locked=false
        desktop.pressure=Math.max(0,(desktop.pressure || 0)-dt*.022)
    }
    run.waveTime += dt
    if (run.weatherEffect==="thunder") {
        run.stormBursts=run.stormBursts.filter(function(strike) {strike.life-=dt;return strike.life>0})
        if (run.waveTime>=run.stormAt) {
            run.stormAt=run.waveTime+6.4+ambientRandom(run)*5.8
            thunderStrike(run)
        }
    }
    run.salvoTime=Math.max(0,run.salvoTime-dt)
    run.sprayTime=Math.max(0,run.sprayTime-dt)
    run.abilityEvents=run.abilityEvents.filter(function(effect) {effect.life-=dt;return effect.life>0})
    if (run.hypnosis && !run.enemies.some(function(enemy) {return enemy.type==="hallucination" && enemy.hp>0}))
        run.hypnosis=null
    run.dizzyLeft = Math.max(0,run.dizzyLeft-dt)
    run.boneTime = Math.max(0,run.boneTime-dt)
    run.gustLeft = Math.max(0,run.gustLeft-dt)
    run.soulReturns = run.soulReturns.filter(function(souls) {
        souls.life -= dt
        return souls.life > 0
    })
    run.viewReady = viewReady !== false
    run.meleeImpact = Math.max(0, run.meleeImpact - dt)
    run.criticalFlash = Math.max(0,run.criticalFlash - dt)
    run.criticalRoll = Math.max(0,run.criticalRoll - dt)
    run.sharpenTime = Math.max(0,run.sharpenTime - dt)
    run.carefulAim = Math.max(0,run.carefulAim - dt)
    tickShield(run,dt)
    tickGrab(run,dt)
    if (run.phase === "defeat")
        return
    if (sealing && run.viewReady && run.playerFront === "down" && canAct(run) && !run.hypnosis && !run.grab) {
        const speed = 1 + rank(run,"seal")*.25 + rank(run,"voidliner")*.27 + rank(run,"primer")*.18
            + rank(run,"seamAnchor")*.21 + Gear.perk(run,"sealSpeed")+Gear.kitBonus(run,"sealSpeed")
        advanceSeal(run,dt*speed/Abyss.sealSeconds)
    }
    if (run.waveTime >= run.ambientAt) {
        const ambience = ["distantSnigger","distantLaugh","distantBreath","distantCry","distantEcho","distantMetal"]
        announce(run, null, ambience[Math.floor(ambientRandom(run) * ambience.length)])
        run.ambientAt = run.waveTime + 7.4 + ambientRandom(run)*9.3
    }
    if (aim && aim.aspect > 0)
        run.aspect = aim.aspect
    run.guardFlash = Math.max(0, run.guardFlash - dt)
    run.fastTurn = Math.max(0, run.fastTurn - dt)
    run.dodgeWindow = Math.max(0, run.dodgeWindow - dt)
    run.dodgeFlash = Math.max(0, run.dodgeFlash - dt)
    run.bayonetTime = Math.max(0, run.bayonetTime - dt)
    run.parry = Math.max(0, run.parry - dt)
    run.meleeRush = Math.max(0, run.meleeRush - dt)
    run.lockfeed = Math.max(0, run.lockfeed - dt)
    for (let i = run.gore.length - 1; i >= 0; i -= 1) {
        run.gore[i].life -= dt
        if (run.gore[i].life <= 0)
            run.gore.splice(i, 1)
    }
    for (let i = run.splits.length - 1; i >= 0; --i) {
        run.splits[i].life -= dt
        if (run.splits[i].life <= 0)
            run.splits.splice(i,1)
    }
    run.remoteGuard = Math.max(0, run.remoteGuard - dt)
    run.infiniteAmmo = Math.max(0, run.infiniteAmmo - dt)
    run.guestTime = Math.max(0, run.guestTime - dt)
    if (!run.guestTime)
        run.guestPet = null
    run.rumble = Math.max(0, run.rumble - dt * 1.8)
    for (const arc of run.arcBursts)
        arc.life = Math.max(0, arc.life - dt)
    run.arcBursts = run.arcBursts.filter(function(arc) { return arc.life > 0 })
    for (let index = run.smokes.length - 1; index >= 0; index -= 1) {
        const smoke = run.smokes[index]
        smoke.life -= dt
        if (smoke.life <= 0) {
            run.smokes.splice(index, 1)
            run.smokeRoster += 1
        }
    }
    if (run.weatherEffect === "winter" && run.waveTime >= run.nextFrostPulse) {
        run.nextFrostPulse += 5
        playerStatus(run,"freeze",1)
        for (const enemy of run.enemies)
            if (!enemy.waitingBoss)
                applyToEnemy(run,enemy,"freeze",1)
        announce(run,null,"winterPulse")
    }
    if (Conditions.hasWeather(run.weatherEffect,run.stage,"windy") && run.waveTime >= run.windAt) {
        run.windAt += 20
        run.gustLeft = 1.26
        for (const enemy of run.enemies.slice()) {
            if (!enemy.waitingBoss && !enemy.warp && enemy.hp > 0) {
                applyKnockback(run,enemy,1)
                wound(run,enemy,1.8,"hazard")
            }
        }
        announce(run,"A gust strikes every wallpaper","windGust")
    }
    if (run.weatherEffect === "inferno" && run.waveTime >= run.nextFirePulse) {
        run.nextFirePulse = run.waveTime + 1.04
        run.burnOrigin = run.playerFront
        if (run.elements.burn <= 1)
            run.burnSource = ""
        Elements.apply(run.elements,"burn",1,function() { return random(run) })
        for (const enemy of run.enemies) {
            if (!enemy.waitingBoss && !statusImmune(enemy,"burn") && enemy.hp > 0) {
                enemy.infernoBurn = true
                Elements.apply(enemy.elements,"burn",1,function() { return random(run) })
            }
        }
    }
    const priorPoisonLoss = run.elements.poisonLoss
    const fireDamage = Elements.advance(run.elements, dt)
    if (run.elements.poisonLoss > priorPoisonLoss) {
        const prior=run.health
        run.health = Math.min(run.health, Gear.maxHealth(run))
        if (run.health<prior) record(run,"damageTaken",prior-run.health)
    }
    if (fireDamage > 0) {
        damagePlayer(run, fireDamage, run.burnOrigin,run.burnSource || "gigafinterus",true,{environment:!run.burnSource})
        if (run.phase === "defeat")
            return
    }
    run.barrier = Math.max(0, run.barrier - dt)
    if (!run.barrier) {
        run.barrierHp = 0
        run.barrierMax = 0
    }
    run.barrierBreak = Math.max(0, run.barrierBreak - dt)
    run.barrierRefill = Math.max(0, run.barrierRefill - dt)
    run.distortion = Math.max(0, run.distortion - dt)
    run.stun = Math.max(0, run.stun - dt)
    run.fastFire = Math.max(0, run.fastFire - dt)
    run.frozenTime = Math.max(0, run.frozenTime - dt)
    run.decoyTime = Math.max(0, run.decoyTime - dt)
    run.impactTime = Math.max(0, run.impactTime - dt)
    run.powerFlash = Math.max(0, run.powerFlash - dt)
    run.giftRate = Math.max(0, run.giftRate - dt)
    run.giftDamage = Math.max(0, run.giftDamage - dt)
    if (run.blast)
        run.blast.life = Math.max(0, run.blast.life - dt)
    for (const id of Object.keys(run.cooldowns))
        run.cooldowns[id] = Math.max(0, run.cooldowns[id] - dt)
    for (const id of Object.keys(run.taxedCooldowns))
        run.taxedCooldowns[id] = Math.max(0, run.taxedCooldowns[id] - dt)
    run.slots.weapon.forEach(function(slot, index) { tickWeapon(run, slot, index, dt, firingHeld) })
    for (let index = run.gifts.length - 1; index >= 0; index -= 1) {
        run.gifts[index].remaining -= dt
        if (run.gifts[index].remaining <= 0) {
            run.gifts.splice(index, 1)
            run.giftRoster += 1
        }
    }
    stepDeathCoins(run)

    while (run.reinforcements.length && roomToSpawn(run,run.reinforcements[0]))
        spawn(run, run.reinforcements.shift())
    while (run.pending.length && run.pending[0].at <= run.waveTime && roomToSpawn(run,run.pending[0])) {
        const next = run.pending[0].type
        if (enemyTypes[next].role === "boss" && (run.enemies.length || run.bolts.length))
            break
        spawn(run, run.pending.shift())
    }
    rebuildLinks(run)

    tickHoles(run,dt)
    // Check the queues too. Statues do not collapse while another species is
    // still scheduled or waiting to reinforce the current wave.
    const statuesAlone = run.enemies.length && run.enemies.every(function(enemy) { return enemy.type === "jos" })
        && run.pending.every(function(entry) { return entry.type === "jos" })
        && run.reinforcements.every(function(entry) { return entry.type === "jos" })
    const bites = []
    const hastened = new Set(run.enemies.filter(function(enemy) {
        return enemy.type === "gojemarus" && enemy.warp <= 0 && enemy.age < 10.72
    }).map(function(enemy) { return enemy.front }))
    for (let index = run.enemies.length - 1; index >= 0; index -= 1) {
        const enemy = run.enemies[index]
        const creature = enemyTypes[enemy.type]
        if (enemy.type === "jos" && statuesAlone && !enemy.warp) {
            if (!enemy.crumble) announce(run,"The last statues are crumbling","stoneBreak")
            enemy.crumble = (enemy.crumble || 0)+dt
            if (enemy.crumble >= 1) {
                blood(run,enemy,"collapse",true)
                remove(run,index,false)
                continue
            }
        } else if (enemy.crumble) enemy.crumble = 0
        if (enemy.waitingBoss) {
            if (enemy.front === run.playerFront && run.viewReady)
                engageBoss(run,enemy)
            continue
        }
        const frozenPose=enemy.elements.frozen>0 || (enemy.front===run.frozenFront && run.frozenTime>0 && !statusImmune(enemy,"freeze"))
        if (!frozenPose || enemy.warp>0) enemy.age += dt
        enemy.interruptIn = Math.max(0,enemy.interruptIn-dt)
        enemy.attackFlash = Math.max(0, enemy.attackFlash - dt)
        enemy.feedingHeal = Math.max(0,enemy.feedingHeal - dt)
        enemy.gravityLift = (enemy.gravityLift || 0)*Math.max(0,1-dt*.66)
        enemy.dodgeIn = Math.max(0, enemy.dodgeIn - dt)
        enemy.dodgeAge = Math.max(0, enemy.dodgeAge - dt)
        if (enemy.type === "hasasasa") {
            if (!enemy.hitStop)
                Ship.sway(enemy)
            for (const part of enemy.turrets)
                part.flash = Math.max(0, part.flash - dt)
            if (enemy.wreck > 0) {
                enemy.wreck = Math.max(0, enemy.wreck - dt)
                if (Math.floor(enemy.wreck * 7) % 3 === 0)
                    run.rumble = Math.max(run.rumble, .18)
                if (!enemy.wreck) {
                    run.bursts.push(Object.assign(arcPoint(enemy), { front:"up", radius:900, life:.91, span:.91 }))
                    run.rumble = .64
                    blood(run,enemy,"ship",true)
                    remove(run, index, true)
                    announce(run, "Hasasasa Forum destroyed", "shipFinal")
                }
                continue
            }
        }
        enemy.flash = Math.max(0, enemy.flash - dt)
        enemy.hurtFace = Math.max(0,(enemy.hurtFace || 0)-dt)
        enemy.roar = Math.max(0, enemy.roar - dt)
        enemy.shatter = Math.max(0, enemy.shatter - dt)
        enemy.slow = Math.max(0, enemy.slow - dt)
        enemy.mark = Math.max(0, enemy.mark - dt)
        enemy.sightMark = Math.max(0,(enemy.sightMark || 0) - dt)
        enemy.criticalMark = Math.max(0,(enemy.criticalMark || 0) - dt)
        const burning = Elements.advance(enemy.elements, dt)
        enemy.maxHp = Math.max(1, enemy.baseHp * Elements.healthFactor(enemy.elements))
        enemy.hp = Math.min(enemy.hp, enemy.maxHp)
        if (burning > 0 && enemy.hp > 0 && !ghosted(enemy)) {
            const bonus = .29 * rank(run, "cinder") + (Gear.hasKit(run, "hotChamber") ? .45 : 0)
            wound(run, enemy, (burning + bonus) * outgoing(run), "burn")
            if (enemy.hp <= 0)
                continue
        }
        if (enemy.type === "fhantamegus" && enemy.age > .74)
            enemy.shiftIn = Math.max(0, enemy.shiftIn - dt)

        if (enemy.warp > 0) {
            enemy.warp = Math.max(0, enemy.warp - dt)
            if (enemy.retreat) {
                if (!enemy.warp)
                    remove(run, index, false)
                continue
            }
            if (enemy.warpKind === "flee") {
                enemy.depth += creature.speed * dt * 2.7
                if (enemy.warp === 0) {
                    remove(run, index, false)
                    announce(run, "Gojemarus escaped", "")
                }
                continue
            }
            if (!enemy.warp && enemy.warpKind === "perchOut") {
                const perch = sniperPerches[enemy.sniperPerch]
                enemy.lane = perch[0]
                enemy.sniperHeight = perch[1]
                beginWarp(enemy,"perchIn",.31)
            } else if (enemy.warp === 0 && enemy.warpKind === "departure") {
                enemy.front = enemy.nextFront
                if (enemy.type === "lucifoverus") {
                    enemy.depth = Mission.spawnDistance
                    enemy.lane = 0
                    enemy.attack = 0
                } else if (enemy.type === "fhantamegus") {
                    const visibleLane = enemy.depth * .22
                    enemy.lane = Math.max(-visibleLane, Math.min(visibleLane, enemy.lane))
                }
                beginWarp(enemy, "shift", .55)
            } else if (!enemy.warp && enemy.warpKind === "drop") {
                announce(run, "Hasasasa Forum · aim for the gun tubes", "boss")
            } else if (!enemy.warp && enemy.warpKind === "rise") {
                announce(run,"Reapfast Leviathan · watch its mouth","leviathanReady")
            } else if (enemy.warpKind === "rise") {
                run.rumble = Math.max(.75,run.rumble)
            }
            continue
        }
        enemy.hitStop = Math.max(0,(enemy.hitStop || 0)-dt)
        if (creature.trainer || run.training && enemy.trainingPeon)
            continue
        if (enemy.type === "fhantamegus" && enemy.shiftIn === 0 && !enemy.elements.frozen) {
            enemy.shiftIn = 3
            enemy.nextFront = sample(run, groundFronts.filter(function(id) { return id !== enemy.front }))
            beginWarp(enemy, "departure", .32)
            announce(run, "Fhantamegus warping to " + front(enemy.nextFront).title, "shift")
            continue
        }
        if (enemy.type === "gojemarus") {
            if (!frozenPose && enemy.age >= 10.72)
                beginWarp(enemy, "flee", .47)
            continue
        }
        if (enemy.eyesTime > 0) {
            stepAbyss(run,enemy,dt,aim)
            continue
        }
        if (enemy.type === "seraphijus") {
            enemy.fuse = Math.max(0, enemy.fuse - dt)
            if (!enemy.fuse) {
                smashHazard(run, enemy, index)
                continue
            }
        }
        if (enemy.recover > 0) {
            enemy.recover = Math.max(0, enemy.recover - dt)
            continue
        }
        if (enemy.type === "jos" && enemy.front === run.playerFront
            || enemy.elements.frozen > 0 || enemy.elements.stunned > 0
            || enemy.front === run.frozenFront && run.frozenTime > 0 && !statusImmune(enemy, "freeze")) {
            if (creature.beam || creature.beamsEvery)
                enemy.beamWarning = enemy.beamLeft = 0
            if (creature.soulDrain) {
                enemy.soulChannel = false
                enemy.soulWarm = creature.windup
            }
            continue
        }
        if (creature.sprayer && stepSprayer(run,enemy,dt))
            continue
        if (creature.beamsEvery && stepGoldRay(run, enemy, creature, dt)) {
            if (run.phase === "defeat")
                return
            continue
        }
        if (creature.abyss && stepAbyss(run,enemy,dt,aim)) {
            if (run.phase === "defeat")
                return
            continue
        }
        const pinned = enemy.elements.sticky > 0 || enemy.hitStop > 0
        if (creature.devour && (!pinned || enemy.feed) && stepFeeding(run,enemy,dt,bites))
            continue
        const blindDrift = !pinned && enemy.elements.blind && enemy.travelSpeed > 0 && enemy.type !== "veilskate"
        if (blindDrift)
            driftBlind(run,enemy,dt)
        else if (!pinned) {
            trackDodge(run, enemy, aim, dt)
            if (creature.maneuver)
                wander(run, enemy, dt)
        }
        if (enemy.type === "seraphijus")
            continue
        if (creature.voidBoss && run.time >= enemy.shadeAt) {
            enemy.shadeAt += 15
            if (!run.enemies.concat(run.reinforcements).some(function(other) {
                return other.type === "mystery" || other.type === "crawler"
            })) {
                if (summon(run,{ type:"mystery",front:enemy.front,lane:enemy.lane*.47,summoned:true,parent:enemy.id }))
                    announce(run,"A shade answered the Void","shade")
            }
        }
        if (enemy.type === "mothergalian") {
            enemy.brood = Math.max(0, enemy.brood - dt)
            if (enemy.brood <= 1e-7 && broodCount(run, enemy.id) < 3) {
                enemy.brood = 9
                summon(run, { type:sample(run, ["spartalien", "fizzalien"]), front:enemy.front,
                    lane:Math.max(-180, Math.min(180, enemy.lane + (random(run) < .5 ? -115 : 115))),
                    parent:enemy.id, summoned:true })
                announce(run, "Mothergalian released an alien", "brood")
            }
        }
        const speed = (hastened.has(enemy.front) ? 1.2 : 1) * (enemy.slow > 0 ? .62 : 1) * Elements.pace(enemy.elements)
        const movement = speed * bossMovement(enemy) * (enemy.linked ? 1.30 : 1)
        const cadence = speed * (enemy.linked ? 1.28 : 1)
        if (enemy.type === "veilskate" && !pinned) {
            const limit = enemy.depth*.26
            enemy.lane += enemy.diagonal*enemy.travelSpeed*movement*dt
            if (Math.abs(enemy.lane) >= limit) {
                enemy.lane = Math.sign(enemy.lane)*limit
                enemy.diagonal *= -1
            }
        }
        if (creature.role === "boss" && !creature.ship && !pinned)
            moveBoss(run, enemy, dt, movement)
        if (creature.rangedInterval && enemy.depth > creature.reach && enemy.depth <= 1380
            && !(enemy.front === run.decoyFront && run.decoyTime > 0)) {
            const previous = enemy.ranged
            enemy.ranged = Math.max(0, enemy.ranged - dt * cadence)
            if (!enemy.rangedReady || previous > .83 && enemy.ranged <= .83) {
                enemy.rangedReady = true
                announce(run, front(enemy.front).title + " · " + creature.title + " winding up a shard", "warning")
            }
            if (!enemy.ranged) {
                enemy.ranged = creature.rangedInterval * Mission.attackIntervalScale / (enemy.stormCharged ? 1.5 : 1)
                fireSpinShard(run, enemy)
            }
        }
        if (enemy.depth > creature.reach && enemy.type !== "veilskate") {
            if (pinned || blindDrift)
                continue
            const before = enemy.depth
            const charge = creature.chargeSpeed && enemy.depth-creature.reach <= creature.chargeDistance
                && enemy.attack<=creature.windup ? creature.chargeSpeed : 1
            enemy.depth = Math.max(creature.reach, enemy.depth - enemy.travelSpeed * movement * dt * charge * (enemy.anger ? 1.63 : 1))
            if (enemy.type === "fhantamegus") {
                const visibleLane = enemy.depth * .26
                enemy.lane = Math.max(-visibleLane, Math.min(visibleLane, enemy.lane))
            }
            if (enemy.type === "ghorimagous") {
                enemy.lane += (before - enemy.depth) * enemy.diagonal * 0.49
                if (Math.abs(enemy.lane) >= 165) {
                    enemy.lane = Math.max(-165, Math.min(165, enemy.lane))
                    enemy.diagonal *= -1
                }
            }
            if (enemy.depth > creature.reach)
                continue
        }
        if (enemy.type === "meteor") {
            smashHazard(run, enemy, index)
            continue
        }
        if (enemy.type === "hosphoragus" && !enemy.roared) {
            enemy.roared = true
            enemy.roar = 1
            playerStatus(run,"stun",1)
            announce(run, "Hosphoragus roar · stunned", "roar")
        }

        if (creature.beam && stepBattlestar(run, enemy, dt)) {
            if (run.phase === "defeat")
                return
            continue
        }
        if (enemy.front === run.decoyFront && run.decoyTime > 0)
            continue
        const previous = enemy.attack
        const remote = enemy.front === run.playerFront ? 1 : Math.max(.46, .84 - rank(run, "offscreenWard") * .087
            - (run.remoteGuard > 0 ? .30 : 0))
        enemy.attack -= dt * cadence * remote * (1 - Elements.visibilityLoss(enemy.elements) * .54)
        if (previous > creature.windup && enemy.attack <= creature.windup)
            announce(run, front(enemy.front).title + " · " + creature.title + " charging", "warning")
        if (enemy.attack <= 0) {
            enemy.firstStrike = false
            enemy.attack = attackInterval(enemy)
            strike(run, enemy, creature)
            if (enemy.type === "bergensus")
                remove(run, index, false)
            if (run.phase === "defeat")
                return
        }
    }

    landBites(run,bites)
    for (let index = run.grenades.length - 1; index >= 0; index -= 1) {
        const grenade = run.grenades[index]
        grenade.remaining = Math.max(0, grenade.remaining - dt)
        if (grenade.remaining === 0) {
            run.grenades.splice(index, 1)
            explode(run, grenade)
        }
    }
    if (run.counterTarget) {
        const attacker = target(run, run.counterTarget)
        if (attacker)
            wound(run, attacker, 9.6 * outgoing(run), "ability")
        run.counterTarget = 0
    }
    updatePet(run, run.pet, dt)
    updatePet(run, run.guestPet, dt)
    updatePet(run, run.tarotPet, dt)
    updateDetonations(run, dt)
    if (run.phase === "defeat")
        return
    updateBreaths(run, dt)
    if (run.phase === "defeat")
        return
    updatePoisonClouds(run, dt)
    if (run.phase === "defeat")
        return
    updateAxes(run, dt)
    updateLunge(run, dt)

    for (let index = run.bolts.length - 1; index >= 0; index -= 1) {
        const bolt = run.bolts[index]
        if (bolt.front === run.frozenFront && run.frozenTime > 0)
            continue
        bolt.remaining -= dt
        if (bolt.remaining <= 0) {
            run.bolts.splice(index, 1)
            run.boltRoster += 1
            if (bolt.returning) {
                const source = target(run,bolt.sourceId)
                if (source && source.front === bolt.front && !source.warp)
                    wound(run,source,bolt.damage,"return",bolt.element,bolt.elementLevel)
                continue
            }
            if (bolt.bubble || (bolt.slug || bolt.localOnly) && bolt.front !== run.playerFront)
                continue
            const couldTurn = canTurn(run)
            const blastDamage = bolt.blast ? Elements.kinds.explosive.damage[1] : 0
            damagePlayer(run, bolt.damage + blastDamage, bolt.front, bolt.source, false, bolt, true)
            if (bolt.slug && couldTurn && !canTurn(run)) {
                const boss = target(run, bolt.parent)
                if (boss && boss.type === "stinkaturumus" && boss.front === bolt.front && !boss.warp) {
                    boss.sideIn = 0
                    boss.slimeRetreat = true
                    boss.attack = Math.max(boss.attack, attackInterval(boss))
                    announce(run, "Stuck · Stinkaturumus is retreating", "moveBoss")
                } else {
                    announce(run, "Stuck · Keep firing to clear the peons", "")
                }
            }
            if (bolt.blast) {
                run.rumble = Math.max(run.rumble, .17)
                run.bursts.push({ lane:0, elevation:0, depth:165, front:bolt.front,
                    radius:Elements.kinds.explosive.radius[1], life:.61 })
            }
            if (run.phase === "defeat")
                return
        }
    }

    const reflections = run.reflections.splice(0)
    for (const reflection of reflections) {
        const attacker = target(run,reflection.id)
        if (attacker && attacker.hp > 0)
            wound(run,attacker,reflection.damage,"ability",reflection.burn ? "burn" : "",reflection.burn ? 1 : 0)
    }
    if (!run.enemies.length && !run.pending.length && !run.reinforcements.length && !run.bolts.length && !run.flames.length && !run.axes.length && !run.lunge
        && !run.holes.length && !run.splits.length
        && !run.venomClouds.some(function(cloud) { return cloud.hostile && !cloud.hit })
        && !run.detonations.length && !run.bursts.some(function(burst) { return burst.life > .30 })
        && !run.gore.some(function(event) { return event.boss && event.fatal && event.life > .55 })) {
        if (!run.training && run.time-(run.lastKillTime ?? -1) >= .5-1e-7)
            finishWave(run)
    }
}

function finishWave(run) {
    if (takeoverActive(run)) return false
    record(run, "waves")
    run.metrics.bestClearedWave = Math.max(run.metrics.bestClearedWave || 0,run.wave)
    if (run.waveTime<30) record(run,"quickWaves")
    if (run.waveTime<60) {run.metrics.bestTimedWave=Math.max(run.metrics.bestTimedWave || 0,run.wave);run.progress++}
    if (!run.hurtThisWave)
        record(run, "flawless")
    if (!run.hurtThisWave) {
        run.metrics.bestFlawlessWave = Math.max(run.metrics.bestFlawlessWave || 0,run.wave)
        run.progress += 1
    }
    if (run.health / Gear.maxHealth(run) <= .35)
        record(run, "lowHealthWaves")
    if (Conditions.isRain(run.weatherEffect))
        record(run, "rainWaves")
    if (run.bloodMoonSeen || run.weatherEffect==="bloodMoon") {
        record(run,"bloodMoonClears")
        if (!run.hurtThisWave) record(run,"bloodMoonFlawless")
    }
    Elements.clearPoison(run.elements)
    run.fearCut = false
    const cap = Gear.maxHealth(run)
    const recovery=Math.round(cap*Mission.difficulty(run.difficulty).recovery) + Gear.passiveSockets(run,"waveHeal",8)+Tarot.value(run,"waveHeal")
        +(Tarot.weather(run) ? Tarot.value(run,"weatherHeal") : 0)+(!run.hurtThisWave ? Tarot.value(run,"flawlessHeal") : 0)
    const heal = Math.max(0, Math.min(recovery, cap - run.health))
    run.health += heal
    tarotEvent(run,"clear")
    run.gifts = []
    run.venomClouds = []
    run.grenades = []
    run.hexes = {}
    run.taxedCooldowns = {}
    run.giftRoster += 1
    if (isBossWave(run.wave))
        beginBossReward(run)
    else if (isGearRewardWave(run.wave)) {
        run.offers = draft(run)
        run.phase = "reward"
    } else {
        run.offers = []
        run.phase = "between"
    }
    announce(run, heal ? "Wave cleared · +" + Math.round(heal) + " HP" : "Wave cleared", "clear")
}

function retire(run) {
    if (!run.metrics.waves || !["between","reward","bossReward","shop"].includes(run.phase)
        || run.shopStock.some(function(card) {return card.paid && !card.sold})) return false
    run.phase="defeat"
    run.finishReason="retired"
    return true
}

function charging(enemy) {
    const creature = enemyTypes[enemy.type]
    if (!creature.interval || enemy.hp <= 0 || enemy.waitingBoss || enemy.eyesTime > 0 || enemy.recover || enemy.wreck || enemy.warp > 0
        || enemy.elements?.stunned || enemy.elements?.frozen)
        return false
    if (creature.soulDrain)
        return enemy.depth <= creature.reach
    const ranged = creature.rangedInterval && enemy.depth > creature.reach && enemy.depth <= 1380 && enemy.ranged <= .83
    const approaching = (enemy.firstStrike || creature.chargeSpeed && enemy.attack <= creature.windup)
        && !creature.ship && enemy.depth - creature.reach < (creature.chargeDistance || enemy.travelSpeed*.95)
    return !!enemy.special || enemy.attackFlash > 0 || enemy.beamWarning > 0 || ranged || approaching
        || enemy.depth <= creature.reach && enemy.attack <= creature.windup
}

function warningProgress(enemy) {
    if (!charging(enemy) || enemy.attackFlash > 0)
        return 0
    const creature = enemyTypes[enemy.type]
    if (creature.soulDrain)
        return enemy.soulChannel ? 1 : 1-enemy.soulWarm/creature.windup
    if (enemy.special)
        return Math.min(1,.14+enemy.special.time/Math.max(.1,enemy.special.warning)*.86)
    if (enemy.beamWarning > 0)
        return Math.max(.18,1 - enemy.beamWarning / (creature.beam ? creature.beam.warning : .77))
    if (creature.rangedInterval && enemy.depth > creature.reach && enemy.depth <= 1380 && enemy.ranged <= .83)
        return Math.max(.12,1 - enemy.ranged/.83)
    if ((enemy.firstStrike || creature.chargeSpeed) && enemy.depth > creature.reach && !creature.ship)
        return Math.max(.12,1 - (enemy.depth - creature.reach)/(creature.chargeDistance || enemy.travelSpeed*.95))
    return Math.max(.12,Math.min(1,1 - enemy.attack/creature.windup))
}

function drawPowerup(run, pool) {
    const tiers = Object.keys(rarities)
    let roll = random(run) * 100
    let tier = 0
    while (tier < tiers.length - 1 && roll >= rarities[tiers[tier]].chance) {
        roll -= rarities[tiers[tier]].chance
        tier += 1
    }
    for (; tier >= 0; tier -= 1) {
        const eligible = pool.filter(function(card) { return card.rarity === tiers[tier] })
        if (eligible.length)
            return Gear.pickRarityItem(run,eligible,random(run))
    }
    // When lower tiers are unavailable, use the least rare eligible tier.
    const lowest = tiers.find(function(id) { return pool.some(function(card) { return card.rarity === id }) })
    return Gear.pickRarityItem(run,pool.filter(function(card) { return card.rarity === lowest }),random(run))
}

function isGearRewardWave(wave) {
    return wave > 0 && wave % 2 === 0 && !isBossWave(wave)
}

var abilityCadence = { legendary:[12, 18], epic:[4, 6] }

function nextAbilityWave(run, rarity) {
    const span = abilityCadence[rarity]
    return run.wave + span[0] + Math.floor(random(run) * (span[1] - span[0] + 1))
}

function draft(run) {
    let pool=Draw.rewardPool(run)
    const offers=[]
    function add(card) {
        if (!card) return
        offers.push(Gear.describeOffer(run,card))
        pool=pool.filter(function(candidate){return candidate.id!==card.id})
    }

    const stored=Draw.frozenFor(run,"reward")
    if (stored) {
        const group=Gear.groupOf(stored)
        add(group ? Gear.catalogs[group][stored.id] : stored)
    }

    // Rare or better appears in each draft, with long-run protection against
    // streaks without higher tiers. Any category can fill any of these places.
    for (const tier of Object.keys(abilityCadence)) {
        if (run.abilitySchedule[tier]===undefined)
            run.abilitySchedule[tier]=nextAbilityWave(run,tier)-1
        if (run.abilitySchedule[tier]>run.wave || offers.length>=3) continue
        if (!offers.some(function(card){return card.rarity===tier})) {
            const eligible=pool.filter(function(card){return card.rarity===tier})
            if (!eligible.length) continue
            add(Gear.pickRarityItem(run,eligible,random(run)))
        }
        run.abilitySchedule[tier]=nextAbilityWave(run,tier)
    }
    while (offers.length<3 && pool.length) {
        const needRare=offers.length===2 && offers.every(function(card){return !card.rarity || card.rarity==="common"})
        const useful=needRare ? pool.filter(function(card){return card.rarity!=="common"}) : pool
        if (offers.length===2 && !needRare && !offers.some(function(card){return card.category==="Supply"}) && random(run)<.13)
            add(run.health<Gear.maxHealth(run) && random(run)<.38 ? dressing : reserve)
        else
            add(drawPowerup(run,useful.length ? useful : pool))
    }
    // A pinned card keeps its leading position; everything else can appear in any slot.
    for (let i=offers.length-1;i>(stored ? 1 : 0);i--) {
        const first=stored ? 1 : 0
        const j=first+Math.floor(random(run)*(i-first+1))
        const saved=offers[i]
        offers[i]=offers[j]
        offers[j]=saved
    }
    return offers
}

function choose(run, id, slot) {
    if (run.phase !== "reward")
        return false
    const card = run.offers.find(function(offer) { return offer.id === id })
    if (!card)
        return false

    if (card.category !== "Supply") {
        const previous = Gear.ownedItem(run, Gear.groupOf(card), card.id)
        if (!Gear.equip(run, card, slot))
            return false
        if (previous)
            record(run, "upgrades")
        recordKits(run)
    } else if (id === "dressing") {
        run.health = Math.min(Gear.maxHealth(run), run.health + 40)
    } else {
        run.nextAmmo = 3
    }
    Draw.leaveFrozen(run,card)
    run.offers = []
    run.phase = "between"
    return true
}

function recordKits(run) {
    for (const kit of Gear.kits) {
        const key = kit.key || kit.weapon
        if (!run.earnedKits[key] && Gear.completeKit(run, kit)) {
            run.earnedKits[key] = true
            record(run, "kits")
        }
    }
}

function swapInventory(run, cell, group, slot) {
    if (!canEditLoadout(run) || !Gear.swapInventory(run, cell, group, slot))
        return false
    recordKits(run)
    return true
}

function canEditLoadout(run) {
    return ["ready","reward","bossReward","shop","between"].includes(run.phase)
}

function openShop(run) {
    run.phase = "shop"
    run.shopEdition += 1
    run.shopCleared = false
    const card=Draw.frozenFor(run,"shop")
    const fresh=Gear.makeShop(run,function(){return random(run)},card ? [card.id] : [],run.shopCapacity-Number(!!card))
    run.shopStock=card ? [card].concat(fresh) : fresh
}

function buy(run, id, slot, confirmed) {
    const card = id==="expand-counter" ? Gear.counterOffer(run) : run.shopStock.find(function(item) { return item.id === id })
    const rankUp = card && (card.action === "upgrade" || card.action === "item-upgrade" || card.action === "power-upgrade" || card.action === "pet" || card.action === "shield-upgrade"
        || card.action === "repeat-upgrade" || card.action === "shop-stat" || card.action==="shop-quality"
        || card.action === "gear" && Gear.ownedItem(run, card.group, card.gearId))
    const before = run.gold
    if (!Gear.buy(run, id, slot, function() { return random(run) }, confirmed))
        return false
    if (Draw.isFrozen(run,card)) run.frozenOffer=null
    const spent = before-run.gold
    if (spent > 0) {
        run.spentGold += spent
        run.metrics.bestRunSpent = run.spentGold
        run.progress += 1
        record(run,"shopBuys")
        record(run,"shopSpent",spent)
    }
    if (rankUp)
        record(run, "upgrades")
    if (card.action === "expand-shop") {
        const extra = Gear.makeShop(run,function() { return random(run) },run.shopStock.map(function(row) { return row.id }),
            Math.max(0,run.shopCapacity-run.shopStock.length))
        run.shopStock.push(...extra)
    }
    if (!run.shopCleared && run.shopStock.length >= 5 && run.shopStock.every(function(row) {return row.sold})) {
        run.shopCleared = true
        record(run,"completeShops")
    }
    recordKits(run)
    return true
}

function refundAbility(run,group,id) {
    const amount=Gear.refundAbility(run,group,id)
    if (!amount) return false
    run.spentGold=Math.max(0,run.spentGold-amount)
    run.metrics.bestRunSpent=run.spentGold
    run.metrics.shopSpent=Math.max(0,(run.metrics.shopSpent || 0)-amount)
    run.metrics.shopBuys=Math.max(0,(run.metrics.shopBuys || 0)-1)
    announce(run,"Refunded "+Gear.catalogs[group][id].title+" rank · "+amount+" gold","buy")
    return true
}

function leaveShop(run) {
    if (run.phase !== "shop" || run.shopStock.some(function(card) { return card.paid && !card.sold }))
        return false
    Draw.leaveFrozen(run)
    run.shopStock = []
    run.offers = []
    run.phase = "between"
    return true
}

function offscreenThreats(view, status) {
    const result = {}
    for (const location of fronts) {
        const entry = status[location.id]
        const direction = directionToward(view, location.id)
        if (direction && (entry.count > 0 || entry.dangerous))
            result[direction] = Math.max(result[direction] || 0, entry.dangerous ? 2 : 1)
    }
    return result
}

function threatCounts(run) {
    const counts = {}
    for (const location of fronts)
        counts[location.id] = { count: 0, dangerous: false, coin: false }
    for (const enemy of run.enemies) {
        const entry = counts[enemy.front]
        entry.count += 1
        entry.dangerous = entry.dangerous || charging(enemy)
    }
    for (const bolt of run.bolts)
        counts[bolt.front].dangerous = true
    for (const gift of run.gifts) {
        if (gift.token)
            counts[gift.front].coin = true
    }
    for (const cloud of run.venomClouds) {
        if (cloud.hostile)
            counts[cloud.front].dangerous = true
    }
    return counts
}

function stepSprayer(run,enemy,dt) {
    if (enemy.depth>enemyTypes[enemy.type].reach) return false
    enemy.sprayLeft=Math.max(0,(enemy.sprayLeft || 0)-dt)
    enemy.sprayNext=Math.max(0,(enemy.sprayNext || 0)-dt)
    if (enemy.sprayLeft>0) {
        enemy.attackFlash=.2
        if (enemy.front===run.playerFront && !enemy.sprayNext) {
            enemy.sprayNext=.32
            damagePlayer(run,enemy.damage,enemy.front,enemy.type,false,{sourceId:enemy.id,element:"poison",elementLevel:2},true)
            run.sprayTime=5
            if(run.time>=(run.coughAt || 0)) {run.coughAt=run.time+1.4;announce(run,null,"cough")}
        }
    } else {
        enemy.attack-=dt
        if (enemy.attack<=0) {
            enemy.attack=attackInterval(enemy)+5
            enemy.sprayLeft=5
            announce(run,"Papapoganus is spraying","spray")
        }
    }
    return true
}

function roman(value) {
    if (!value) return "—"
    const values=[1000,900,500,400,100,90,50,40,10,9,5,4,1],letters=["M","CM","D","CD","C","XC","L","XL","X","IX","V","IV","I"]
    let text="",count=Math.max(0,Math.floor(value))
    for (let i=0;i<values.length;i++) while (count>=values[i]) {text+=letters[i];count-=values[i]}
    return text
}
