import QtQuick
import QtTest
import "../game/Rules.js" as Rules
import "../game/Encounters.js" as Encounters
import "../game/Loadout.js" as Gear
import "../game/Pets.js" as Pets
import "../game/Progress.js" as Progress
import "../game/Elements.js" as Elements
import "../game/Ship.js" as Ship
import "../game/Expansion.js" as Expansion
import "../game/AttackArt.js" as Attacks

TestCase {
    name: "BlackboxRules"

    function combat(wave, chosen) {
        const run = Rules.create(42135)
        if (chosen) {
            run.petOffers = [chosen]
            verify(Rules.choosePet(run, chosen))
        }
        run.wave = wave - 1
        verify(Rules.startWave(run))
        run.weatherEffect = "clear"
        run.pending = [{ at:300, type:"silophosus", front:"front", lane:0 }]
        return run
    }

    function spawn(run, type, front) {
        const enemy = Rules.spawn(run, { type:type, front:front, lane:0 })
        if (enemy.waitingBoss)
            Rules.engageBoss(run,enemy)
        enemy.warp = 0
        return enemy
    }

    function advance(run, frames, sealId, firingHeld) {
        for (let tick = 0; tick < frames; tick += 1)
            Rules.update(run, 1 / 60, sealId || 0, !!firingHeld)
    }

    function test_threeStarterWeaponsAndCompanionTraining() {
        const run = Rules.create(41624)
        const offers = run.starterOffers.slice()
        compare(offers.length,3)
        compare(new Set(offers).size,3)
        compare(Rules.create(41624).starterOffers,offers)
        verify(offers.every(function(id) {
            const spec = Gear.weapons[id]
            return !spec.locked && !spec.debugOnly && spec.rarity !== "legendary"
        }))
        verify(!Rules.chooseStarter(run,"starDestroyer"))
        verify(Rules.refresh(run))
        verify(run.starterOffers.every(function(id) { return !offers.includes(id) }))
        const choice = run.starterOffers[2]
        verify(Rules.chooseStarter(run,choice))
        verify(Rules.choosePet(run,run.petOffers[1]))
        verify(Rules.startWave(run))
        compare(Gear.current(run).id,choice)
        verify(run.pet && run.pet.id === run.petChoice)
        const baseline = Pets.deploy(run.pet.id,0).stats
        const veteran = Pets.deploy(run.pet.id,3).stats
        verify(veteran.damageScale > baseline.damageScale*1.9)
        verify(veteran.duty > baseline.duty && veteran.interval < baseline.interval)
        verify(veteran.rest < baseline.rest && veteran.travel < baseline.travel)
    }

    function test_infernoAppliesBurnAcrossViews() {
        let seed = 1
        while (seed < 100 && !Encounters.inferno(9,seed))
            seed += 1
        verify(seed < 100)
        const run = Rules.create(seed)
        run.wave = 8
        verify(Rules.startWave(run))
        compare(run.weatherEffect,"inferno")
        run.pending = [{ at:300,type:"silophosus",front:"front",lane:0 }]
        const demon = spawn(run,"hosphoragus","right")
        const immune = spawn(run,"lucifoverus","left")
        const seal = spawn(run,"crawler","down")
        const hp = demon.hp
        const player = run.health
        advance(run,130)
        compare(run.elements.burn,1)
        compare(demon.elements.burn,1)
        compare(seal.elements.burn,1)
        compare(immune.elements.burn,0)
        verify(run.health < player)
        verify(demon.hp < hp)
    }

    function test_spacedIntroductionsAndBosses() {
        for (let wave = 1; wave <= 120; wave += 1) {
            const run = combat(wave)
            const schedule = Rules.makeSchedule(run)
            compare(schedule.reduce(function(sum,entry) {return sum+(entry.units || 1)},0), Rules.waveSize(wave))
            const introduced = schedule.filter(function(entry) { return Encounters.firstWave(entry.type) === wave })
            compare(introduced.length, wave === 1 ? 3
                : Encounters.introductions.some(function(entry) { return entry.wave === wave }) || Rules.isBossWave(wave) && Encounters.firstWave(Rules.bossType(wave)) === wave ? 1 : 0)
            verify(schedule.every(function(entry) { return Encounters.firstWave(entry.type) <= wave }))
            verify(schedule.filter(function(entry) { return entry.type === "crawler" }).length
                <= (Encounters.stageWeather(wave,run.seed) === "incursion" ? 5 : 2))
            verify(schedule.every(function(entry) { return entry.type !== "saslimigus" }))
            if (Rules.isBossWave(wave))
                compare(schedule[schedule.length - 1].type, Rules.bossType(wave))
            if (wave <= 10)
                verify(schedule[1].at - schedule[0].at > 2.35)
        }
        compare(Rules.bossType(10), "humontafagus")
        compare(Rules.bossType(20), "mastafangenbus")
        compare(Rules.bossType(30), "gigafinterus")
        compare(Rules.bossType(40), "lucifoverus")
        compare(Rules.bossType(50), "hasasasa")
        compare(Rules.bossType(60), "stinkaturumus")
        compare(Rules.bossType(70), "voidGlitch")
        compare(Rules.bossType(80), "reapfast")
        compare(Rules.bossType(90), "humontafagus")
        const run = combat(20)
        const regular = spawn(run, "silophosus", "front")
        run.pending = [{ at:0, type:"mastafangenbus", front:"front", lane:0 }]
        advance(run, 45)
        compare(run.pending.length, 1)
        Rules.wound(run, regular, 100)
        advance(run, 1)
        compare(run.enemies[0].type, "mastafangenbus")
    }

    function test_shrineOnlyVerticalTurns() {
        compare(Rules.turnFrom("front", "right"), "right")
        compare(Rules.turnFrom("right", "left"), "front")
        compare(Rules.turnFrom("right", "up"), "right")
        compare(Rules.turnFrom("left", "down"), "left")
        compare(Rules.turnFrom("front", "up"), "up")
        compare(Rules.turnFrom("front", "down"), "down")
        compare(Rules.turnFrom("up", "down"), "front")
        compare(Rules.turnFrom("down", "up"), "front")
        compare(Rules.directionToward("right", "up"), "left")
        compare(Rules.directionToward("left", "down"), "right")
    }

    function test_slowVoidAndSealCharge() {
        const run = combat(13)
        run.pet = null
        const crawler = spawn(run, "crawler", "down")
        run.pending = [{ at:300,type:"crawler",front:"down",lane:45 }, { at:300,type:"silophosus",front:"front",lane:0 }]
        const start = crawler.depth
        advance(run, 60)
        verify(start - crawler.depth > 55 && start - crawler.depth < 95)
        compare(run.enemies.length, 1)
        compare(run.pending.length, 2)
        verify(Rules.lookFront(run,"down"))
        run.slots.active[0].item = Gear.makeItem("sealcharge")
        verify(Rules.useAbility(run, 0, "down", crawler.id))
        fuzzyCompare(run.abyssSeal.progress,.48,1e-5)
        advance(run, 440,true)
        verify(run.abyssSeal.closed)
        compare(run.metrics.seals, 1)
        verify(run.enemies.some(function(enemy) { return enemy.id === crawler.id }))
        compare(run.pending.length, 1)
        compare(run.pending[0].type, "silophosus")
        compare(run.enemies.length, 1)
    }

    function test_barrierShatterAbsorptionAndGlitch() {
        const run = combat(31)
        const alien = spawn(run, "fizzalien", "up")
        const alienHealth = alien.hp
        Rules.wound(run, alien, 30)
        compare(alien.hp,alienHealth)
        compare(alien.barrier, 0)
        verify(alien.shatter > 0)
        Rules.lookFront(run, "up")
        Rules.lookFront(run, "front")
        compare(alien.barrier, 0)
        Rules.raiseBarrier(run, 6, 2)
        Rules.damagePlayer(run, 34, "front", "zadrrimus")
        Rules.damagePlayer(run, 34, "front", "zadrrimus")
        compare(run.health, Gear.startingHealth)
        compare(run.barrierHp, 0)
        verify(run.barrierBreak > 0)
        Rules.lookFront(run, "right")
        compare(run.barrierHp, 0)
        Rules.lookFront(run, "front")
        Rules.damagePlayer(run, 34, "front", "zadrrimus")
        compare(run.distortion, 5)
        advance(run, 301)
        compare(run.distortion, 0)
    }

    function test_broodAndSplitFamily() {
        const run = combat(34)
        const mother = spawn(run, "mothergalian", "up")
        advance(run, 539)
        compare(run.enemies.length, 1)
        advance(run, 2)
        const hatch = run.enemies.find(function(enemy) { return enemy.parent === mother.id })
        verify(!!hatch)
        verify(["spartalien", "fizzalien"].includes(hatch.type))
        compare(hatch.front, "up")
        compare(Rules.remainingEnemies(run), 2)

        const brute = spawn(run, "rerogorubus", "right")
        Rules.wound(run, brute, 100)
        const children = run.enemies.filter(function(enemy) { return enemy.generation === 1 })
        compare(children.length, 2)
        for (const child of children) {
            compare(child.maxHp, brute.maxHp)
            compare(child.damage, brute.damage)
            verify(Rules.enemySize(child) < Rules.enemySize(brute))
            Rules.wound(run, child, 100)
        }
        const leaves = run.enemies.filter(function(enemy) { return enemy.generation === 2 })
        compare(leaves.length, 4)
        for (const leaf of leaves)
            Rules.wound(run, leaf, 100)
        compare(run.metrics.splits, 3)
        compare(run.enemies.length, 2)
    }

    function test_minigunAndGrenades() {
        const run = combat(10)
        run.slots.weapon[0].item = Gear.makeItem("minigun")
        const gun = Gear.current(run)
        verify(!Rules.shoot(run, []))
        advance(run, 56, 0, true)
        verify(gun.spin < 1)
        verify(!Rules.shoot(run, []))
        advance(run, 6, 0, true)
        verify(Rules.shoot(run, []))
        compare(gun.ammo, Gear.magazine(run) - 1)

        run.slots.weapon[0].item = Gear.makeItem("launcher")
        const target = spawn(run, "hosphoragus", "front")
        const health = target.hp
        verify(Rules.shoot(run, [target.id], "front", { x:.5, y:.5 }))
        compare(target.hp, health)
        compare(run.grenades.length, 1)
        advance(run, 35)
        verify(target.hp < health)
        compare(run.metrics.grenadeHits, 1)
    }

    function test_petSelectionFlightAndUniqueShopToken() {
        const run = combat(12, "kite")
        verify(!Rules.choosePet(run, "owl"))
        compare(run.pet.id, "kite")
        const alien = spawn(run, "spartalien", "up")
        const health = alien.hp
        advance(run, 430)
        compare(run.pet.front, "up")
        verify(alien.hp < health)

        run.phase = "shop"
        run.gold = 1500
        run.shopStock = Gear.makeShop(run, function() { return .015 })
        compare(run.shopStock.length, 5)
        verify(run.shopStock.some(function(card) { return card.rarity === "legendary" && card.action === "gear" }))
        const token = run.shopStock.find(function(card) { return card.action === "pet" })
        verify(!!token)
        verify(token.cost >= 260)
        verify(Rules.buy(run, token.id))
        compare(run.pet.level, 1)
        compare(run.shopStock.length, 5)
        verify(!Rules.buy(run, token.id))
    }

    function test_cadenceAndRepeatUpgrades() {
        const run = Rules.create(8235)
        const counts = { rare:0, epic:0, legendary:0 }
        let tripleWeapon=false
        let tripleAbility=false
        for (let wave = 1; wave <= 120; wave += 1) {
            run.wave = wave
            if (!Rules.isGearRewardWave(wave))
                continue
            const offers = Rules.draft(run)
            compare(offers.length, 3)
            compare(new Set(offers.map(function(item) { return item.id })).size, 3)
            tripleWeapon=tripleWeapon || offers.every(function(card){return Gear.groupOf(card)==="weapon"})
            tripleAbility=tripleAbility || offers.every(function(card){return ["active","passive"].includes(Gear.groupOf(card))})
            for (const card of offers) {
                if (card.category !== "Supply" && counts[card.rarity] !== undefined)
                    counts[card.rarity] += 1
            }
        }
        // The pool can change without forcing a category into each position.
        for (const seed of [181,457,7204,16577]) {
            if (tripleWeapon && tripleAbility) break
            const extra=Rules.create(seed)
            for (let wave=2;wave<=120;wave+=2) {
                if (!Rules.isGearRewardWave(wave)) continue
                extra.wave=wave
                const offer=Rules.draft(extra)
                tripleWeapon=tripleWeapon || offer.every(card=>Gear.groupOf(card)==="weapon")
                tripleAbility=tripleAbility || offer.every(card=>["active","passive"].includes(Gear.groupOf(card)))
            }
        }
        verify(tripleWeapon && tripleAbility,"Draft slots are category independent")
        verify(counts.rare>=25 && counts.epic>=14 && counts.legendary>=6,JSON.stringify(counts))
        for (let upgrade = 1; upgrade <= 3; upgrade += 1) {
            const offer = Gear.describeOffer(run, Gear.weapons.pistol)
            compare(offer.upgradeLevel, upgrade)
            run.offers = [offer]
            run.phase = "reward"
            verify(Rules.choose(run, "pistol"))
            compare(Gear.current(run).level, upgrade)
        }
        verify(!Gear.canOffer(run, Gear.weapons.pistol))
    }

    function test_periodicTeleportAndCursedDrop() {
        const run = combat(8)
        const spectre = spawn(run, "fhantamegus", "front")
        spectre.age = 1
        verify(Rules.shoot(run, [spectre.id]))
        compare(spectre.warp, 0)
        advance(run, 176)
        compare(spectre.warp, 0)
        advance(run, 6)
        compare(spectre.warpKind, "departure")
        advance(run, 20)
        verify(spectre.front !== "front")

        run.slots.active[0].item = Gear.makeItem("ward")
        const cursed = { id:98, kind:"cooldowns", cursed:true, front:"front" }
        run.gifts.push(cursed)
        verify(Rules.claimGift(run, cursed).includes("Cursed"))
        verify(Rules.activeCooldown(run, "ward") >= 19)
        verify(!Rules.useAbility(run, 0, "front"))
        const reloadHex = { id:99, kind:"reload", cursed:true, front:"front" }
        run.gifts.push(reloadHex)
        Rules.claimGift(run, reloadHex)
        verify(Rules.reload(run))
        verify(Gear.current(run).reload > Gear.weapons.pistol.reload)
        run.phase = "between"
        verify(Rules.startWave(run))
        compare(Object.keys(run.hexes).length, 0)
        compare(Rules.activeCooldown(run, "ward"), 0)
    }

    function test_elementsAndDeathBlast() {
        const state = Elements.fresh()
        Elements.apply(state, "burn", 1, function() { return 1 })
        const firstDuration = state.burnLeft
        const firstTick = Elements.advance(state, .64)
        Elements.apply(state, "burn", 3, function() { return 1 })
        verify(state.burnLeft > firstDuration)
        verify(Elements.advance(state, .79) > firstTick)
        Elements.apply(state, "freeze", 3, function() { return .01 })
        compare(state.burn, 0)
        compare(state.frozen, 2)
        verify(Elements.pace(state) < .65)
        Elements.apply(state, "burn", 2, function() { return 1 })
        compare(state.frozen, 0)
        compare(state.frost, 0)

        const run = combat(37)
        const prince = spawn(run, "princoratus", "front")
        prince.depth = 247
        const ally = spawn(run, "hosphoragus", "front")
        ally.depth = 352
        const original = ally.hp
        Rules.wound(run, prince, 70)
        compare(run.detonations.length, 1)
        advance(run, 1)
        verify(run.health < Gear.startingHealth)
        verify(ally.hp < original)
        compare(run.bursts[0].level, 2)

        const remote = spawn(run, "princoratus", "front")
        remote.depth = 1000
        const player = run.health
        Rules.wound(run, remote, 70)
        advance(run, 1)
        compare(run.health, player)
    }

    function test_gigafinterusBreathAndBurn() {
        const run = combat(30)
        const dragon = spawn(run, "gigafinterus", "front")
        dragon.depth = 600
        dragon.attack = .01
        advance(run, 1)
        compare(run.flames.length, 1)
        compare(run.health, Gear.startingHealth)
        advance(run, 26)
        compare(run.elements.burn, 3)
        const afterBreath = run.health
        advance(run, 48)
        verify(run.health < afterBreath)
        verify(dragon.maxHp > 270)
    }

    function test_achievementRewardsAndKits() {
        compare(Progress.achievements.length, 71)
        compare(new Set(Progress.achievements.map(function(item) { return item.reward })).size, 71)
        const available=Pets.available([])
        compare(available.length, 15)
        verify(available.some(pet=>pet.id==="frostFalcon"))
        verify(available.some(pet=>pet.id==="vesper"))
        const run = combat(36)
        for (const achievement of Progress.achievements) {
            const reward = achievement.group === "pet" ? Pets.spec(achievement.reward)
                : Gear.catalogs[achievement.group][achievement.reward]
            compare(reward.id, achievement.reward)
            verify(reward.locked)
            const profile = Progress.merge({}, { [achievement.metric]:achievement.target })
            verify(Progress.unlocked(profile).includes(reward.id))
            if (achievement.group !== "pet") {
                verify(!!Gear.kitFor(achievement.group, reward.id))
                verify(!Gear.canOffer(run, reward))
                run.unlocks = [reward.id]
                verify(Gear.canOffer(run, reward))
                run.unlocks = []
            }
        }
    }
    function test_difficultyAndDebugEntry() {
        const health = []
        const damage = []
        const counts = []
        const speeds = []
        for (const mode of ["normal", "hard", "insane"]) {
            const run = Rules.create(521)
            verify(!Rules.configure(run, mode, 11))
            verify(Rules.configure(run, mode, 20))
            verify(run.debug)
            verify(Rules.startWave(run))
            compare(run.wave, 20)
            compare(run.pending[run.pending.length - 1].type, "mastafangenbus")
            counts.push(run.pending.length)
            const demon = spawn(run, "silophosus", "front")
            health.push(demon.hp)
            damage.push(demon.damage)
            speeds.push(demon.travelSpeed)
        }
        for (const values of [health, damage, counts, speeds])
            verify(values[0] < values[1] && values[1] < values[2])
        for (const mode of ["normal", "hard", "insane"]) {
            const low = combat(19)
            low.difficulty = mode
            const high = combat(20)
            high.difficulty = mode
            const before = spawn(low, "silophosus", "front")
            const after = spawn(high, "silophosus", "front")
            compare(after.hp / before.hp, after.damage / before.damage)
        }
    }

    function test_petDraftSkipRefreshAndRests() {
        const run = Rules.create(301)
        compare(new Set(run.petOffers).size, 3)
        verify(!run.petOffers.includes("brain"))
        verify(!Rules.choosePet(run, "brain"))
        const firstDraw = run.petOffers.join(",")
        compare(Rules.refreshRemaining(run), 1)
        verify(Rules.refresh(run))
        compare(Rules.refreshRemaining(run), 0)
        verify(run.petOffers.join(",") !== firstDraw)
        verify(Rules.skipSelection(run))
        compare(run.phase, "combat")
        compare(run.pet, null)

        const petRun = combat(18, "brain")
        const pet = petRun.pet
        pet.stamina = .02
        advance(petRun, 2)
        verify(pet.resting > 9)
        advance(petRun, 605)
        verify(pet.resting === 0 && pet.stamina > 17)
    }

    function test_bossSummonsMovementAndPermanentBoon() {
        const run = combat(10)
        const first = spawn(run, "humontafagus", "front")
        fuzzyCompare(first.maxHp,Rules.enemyTypes.humontafagus.health*Rules.enemyScale(10,"normal"),1e-5)
        fuzzyCompare(first.damage,Rules.enemyTypes.humontafagus.damage*Rules.enemyScale(10,"normal")*.94,1e-5)
        run.pending = []
        Rules.wound(run, first, first.hp * .51)
        advance(run, 1)
        compare(run.enemies.filter(function(enemy) { return enemy.summoned }).length, 2)
        compare(run.reinforcements.length, 1)
        compare(Rules.remainingEnemies(run), 1)
        Rules.wound(run, run.enemies.find(function(enemy) { return enemy.summoned }), 1000)
        advance(run, 1)
        compare(run.enemies.filter(function(enemy) { return enemy.summoned }).length, 2)
        compare(run.reinforcements.length, 0)
        for (const enemy of run.enemies.slice())
            Rules.wound(run, enemy, 1000)
        advance(run, 370)
        compare(run.phase, "bossReward")
        compare(Rules.refreshRemaining(run), 1)
        const amounts = run.bossOffers.map(function(card) { return card.amount })
        verify(Rules.refresh(run))
        verify(run.bossOffers.every(function(card, index) { return card.amount !== amounts[index] }))
        const health = run.bossOffers[0].amount
        verify(Rules.chooseBoon(run, "health"))
        verify(health >= 75)
        compare(Gear.maxHealth(run), Gear.startingHealth + health)
        compare(run.phase, "shop")
        compare(run.shopStock.length, 5)
        verify(Rules.skipSelection(run))
        verify(Rules.startWave(run))
        compare(run.wave, 11)
        compare(Gear.maxHealth(run), Gear.startingHealth + health)

        const next = combat(20)
        const spinner = spawn(next, "mastafangenbus", "front")
        spinner.sideIn = 0
        spinner.depth = 325
        advance(next, 540)
        verify(spinner.front !== "front")
        verify(next.health > 0)
        next.pending = []
        Rules.wound(next, spinner, 1000)
        advance(next, 310)
        compare(next.phase, "bossReward")
    }

    function test_statusChainsAndFrostAiming() {
        const run = combat(20)
        const near = spawn(run, "helboranius", "front")
        const next = spawn(run, "helboranius", "front")
        const far = spawn(run, "helboranius", "front")
        near.depth = 900
        next.depth = 930
        far.depth = 990
        const original = next.hp
        Rules.wound(run, near, 10, "shot", "electric", 1)
        compare(run.arcBursts.length, 1)
        compare(original - next.hp + original - far.hp, 5)
        const before = run.arcBursts.length
        Rules.wound(run, near, 10, "shot", "electric", 3)
        compare(run.arcBursts.length - before, 2)
        verify(Elements.kinds.electric.retain[3] > .5)

        const turn = Rules.turnDuration(run)
        Elements.apply(run.elements, "freeze", 1, function() { return .9 })
        verify(Rules.turnDuration(run) > turn)
        Elements.apply(run.elements, "burn", 1, function() { return .9 })
        compare(Rules.turnDuration(run), turn)
        Elements.apply(run.elements, "poison", 3, function() { return .9 })
        compare(Gear.maxHealth(run), Gear.startingHealth)
        advance(run, 60)
        compare(Gear.maxHealth(run), 194)
        Elements.apply(run.elements, "weaken", 2, function() { return .9 })
        verify(Elements.damageFactor(run.elements) < 1)
        const weakened = run.elements.weaken
        Elements.apply(run.elements, "weaken", 2, function() { return .9 })
        compare(run.elements.weaken, weakened)
    }

    function test_mysteryRetreatNinjaSmokeAndIce() {
        const run = combat(23)
        const shade = spawn(run, "mystery", "down")
        verify(Rules.blindness(run) >= .95)
        const gold = run.gold
        Rules.wound(run, shade, 1000, "shot")
        verify(shade.retreat)
        verify(Rules.blindness(run) < .1)
        compare(run.gold, gold)
        advance(run, 80)
        verify(!run.enemies.includes(shade))

        run.pet = null
        const ninja = spawn(run, "nindumipus", "right")
        Rules.wound(run, ninja, 1, "shot")
        compare(run.smokes.length, 1)
        compare(run.smokes[0].life, 10)
        advance(run, 610)
        compare(run.smokes.length, 0)

        const ice = spawn(run, "iceterapus", "front")
        const health = ice.hp
        Rules.wound(run, ice, 2, "shot", "freeze", 3)
        compare(ice.hp, health - 1.7)
        compare(ice.elements.frost, 0)
        compare(ice.elements.frozen, 0)
        verify(ice.anger)
        const vulnerable = spawn(run, "silophosus", "front")
        const distance = ice.depth
        run.slots.active[0].item = Gear.makeItem("stasis")
        verify(Rules.useAbility(run, 0, "front", ice.id))
        advance(run, 60)
        verify(ice.depth < distance)
        compare(vulnerable.depth, distance)
    }

    function test_angelDefenseWarpAndTimer() {
        const run = combat(40)
        const helbo = spawn(run, "helboranius", "front")
        const stone = spawn(run, "jos", "front")
        const health = stone.hp
        const depth = stone.depth
        advance(run, 60)
        compare(stone.depth, depth)
        Rules.wound(run, stone, 10, "shot")
        compare(health - stone.hp, 1)
        const armor = helbo.hp
        Rules.wound(run, helbo, 10, "shot")
        compare(armor - helbo.hp, 8)
        Rules.lookFront(run, "right")
        advance(run, 60)
        verify(stone.depth < depth)

        const angel = spawn(run, "lucifoverus", "front")
        Rules.wound(run, angel, 2, "shot", "burn", 3)
        compare(angel.elements.burn, 0)
        Rules.strike(run, angel, Rules.enemyTypes.lucifoverus)
        compare(angel.recover, 5)
        verify(angel.warp > 0)
        advance(run, 68)
        verify(angel.front !== "front")
        verify(angel.depth > 1400)

        const clock = combat(36)
        const timer = spawn(clock, "seraphijus", "front")
        advance(clock, 899)
        verify(timer.fuse > 0)
        advance(clock, 3)
        verify(!clock.enemies.includes(timer))
        verify(clock.health < Gear.startingHealth)
    }

    function test_shipTubesProjectileInterceptionAndWreck() {
        const run = combat(50)
        Rules.lookFront(run, "up")
        const ship = spawn(run, "hasasasa", "up")
        run.pending = []
        const total = ship.hp
        compare(Ship.frequency(ship), 3.75)
        Rules.fireShip(run, ship)
        compare(run.bolts.length, 1)
        const firstShot = run.bolts[0]
        compare(firstShot.elementLevel, 3)
        verify(Rules.shoot(run, [firstShot.id, firstShot.id, firstShot.id], "up"))
        compare(run.bolts.length, 0)
        compare(ship.hp, total)
        compare(run.metrics.intercepts, 1)
        for (let i = 0; i < 3; i += 1) {
            const part = ship.turrets[i]
            compare(part.maximum, total * .30)
            Rules.hitShip(run, ship, part, part.maximum + ship.barrier)
            compare(part.hp,part.maximum)
            Rules.hitShip(run, ship, part, part.maximum)
            compare(part.hp, 0)
            compare(ship.barrier, Rules.enemyTypes.hasasasa.barrier)
            compare(run.enemies.filter(function(enemy) { return enemy.summoned }).length, (i + 1) * 2)
            compare(Ship.frequency(ship), [2.48, 1.34, 2.65][i])
        }
        verify(Math.abs(ship.hp - total * .10) < 1e-6)
        Rules.fireShip(run, ship)
        compare(run.bolts.length, 3)
        verify(run.bolts.every(function(bolt) { return bolt.core && bolt.hp > firstShot.maximum }))
        Rules.hitShip(run, ship, null, 500)
        verify(!ship.wreck)
        Rules.hitShip(run, ship, null, 500)
        verify(ship.wreck > 3)
        run.bolts = []
        for (const enemy of run.enemies.slice()) {
            if (enemy !== ship) {
                if (enemy.barrier)
                    Rules.wound(run, enemy, 1000, "shot")
                Rules.wound(run, enemy, 1000, "shot")
            }
        }
        advance(run, 520)
        compare(run.phase, "bossReward")
        verify(run.gold >= Rules.goldPerKill(50) * 10)
    }

    function test_kitOwnershipIncludesStoredItems() {
        const run=Rules.create(701)
        const kit=Gear.kitFor("weapon","pistol")
        run.inventory[0]={group:"active",item:Gear.makeItem(kit.active)}
        const parts=Gear.kitMembers(run,kit)
        compare(parts.map(part=>part.owned),[true,false,true])
        const offer=Gear.passives[kit.passive]
        const fromReward=Gear.offerDetails(offer,run)
        const fromSlot=Gear.itemDetails(run,"passive",{id:offer.id,level:0})
        for (const source of [fromReward,fromSlot]) {
            verify(source.includes("You own "+Gear.weapons.pistol.title))
            verify(source.includes(Gear.activeAbilities[kit.active].title))
        }
        verify(!Gear.completeKit(run,kit))
        compare(Gear.kitStatus(run,kit),"")
        run.slots.passive[0].item=Gear.makeItem(kit.passive)
        compare(Gear.kitStatus(run,kit),"Inactive")
        const equipped=run.inventory[0].item
        run.inventory[0]=null
        run.slots.active[0].item=equipped
        compare(Gear.kitStatus(run,kit),"Active")
    }

    function test_reassignedQuartermasterKitKeepsItsBonus() {
        const run=combat(18)
        const field=Gear.kitFor("weapon","pistol")
        const kit=Gear.kitFor("weapon","supplySidearm")
        compare(field.title,"Field kit")
        compare(kit.key,"quartermaster")
        compare(kit.active,"fieldResupply")
        for (const group of Object.keys(Gear.catalogs))
            run.slots[group][0].item=Gear.makeItem(kit[group])
        const gun=Gear.current(run)
        gun.ammo=1
        gun.recovery=1
        verify(Rules.useAbility(run,0,"front",0))
        compare(gun.ammo,Rules.magazine(run))
        compare(gun.recovery,0)
        verify(Rules.activeCooldown(run,"fieldResupply")>0)
        compare(Rules.activeCooldown(run,"quickload"),0)
        run.slots.weapon[0].item=Gear.makeItem(field.weapon)
        verify(!Gear.hasKit(run,kit.key))
    }

    function test_gearKitsRankEffectsAndReplacing() {
        compare(Gear.kits.length, 137)
        compare(Object.keys(Expansion.actives).length, 19)
        compare(Object.keys(Expansion.passives).length, 18)
        verify(new Set(Object.values(Attacks.poses).map(function(pose) { return pose.join(",") })).size >= 15)
        for (const catalog of [Gear.weapons, Gear.activeAbilities, Gear.passives]) {
            const group = Gear.groupOf(Object.values(catalog)[0])
            compare(Object.values(catalog).filter(function(item) { return !item.debugOnly }).length, 137)
            compare(new Set(Gear.kits.map(function(kit) { return kit[group] })).size, 137)
            for (const card of Object.values(catalog)) {
                if (card.debugOnly)
                    continue
                verify(!!Gear.kitFor(group, card.id))
                for (let level = 1; level <= 3; level += 1)
                    verify(Gear.upgradeText(card, level).length > 0)
            }
        }
        const run = combat(21)
        run.offers = [Gear.activeAbilities.whiteout]
        run.phase = "reward"
        verify(Rules.choose(run, "whiteout"))
        compare(run.slots.active[0].item.id, "whiteout")
        const frostI = Gear.weaponStats({ id:"glacier", level:1 })
        const frostII = Gear.weaponStats({ id:"glacier", level:2 })
        compare(frostII.elementLevel, frostI.elementLevel + 1)
        compare(frostII.damage, frostI.damage)

        run.offers = [Gear.activeAbilities.immolate]
        run.phase = "reward"
        run.slots.active[0].item.level = 3
        verify(!Rules.choose(run, "immolate"))
        verify(Rules.choose(run, "immolate", 0))
        compare(run.slots.active[0].item.id, "immolate")
        compare(run.slots.active[0].item.level, 0)
    }

    function test_rewardSpacingAndScaledGold() {
        const run = Rules.create(20)
        compare(run.slots.passive.length, 4)
        compare(Gear.limits.passive, 8)
        compare(run.inventory.length, 5)
        for (let wave = 1; wave <= 12; wave += 1) {
            verify(Rules.startWave(run))
            compare(run.wave, wave)
            run.pending = []
            const enemy = spawn(run, "silophosus", "front")
            const gold = run.gold
            Rules.wound(run, enemy, 100, "shot")
            compare(run.gold - gold, wave < 10 ? 12 : 14)
            advance(run, 185)
            compare(run.phase, wave === 10 ? "bossReward" : wave % 2 ? "between" : "reward")
            if (run.phase === "bossReward") {
                verify(Rules.skipSelection(run))
                verify(Rules.skipSelection(run))
            } else if (run.phase === "reward") {
                compare(run.offers.length, 3)
                verify(run.offers.some(function(card) { return card.rarity && card.rarity !== "common" }))
                verify(Rules.skipSelection(run))
            }
        }
    }

    function test_inventoryRankPreservationCapacityAndSwaps() {
        const run = combat(12)
        run.slots.active[0].item = Gear.makeItem("ward")
        run.slots.active[0].item.level = 2
        run.offers = [Gear.activeAbilities.frag]
        run.phase = "reward"
        verify(Rules.choose(run, "frag", Gear.inventoryDestination))
        compare(run.inventory[0].item.id, "frag")
        compare(run.slots.active[0].item.id, "ward")
        run.offers = [Gear.activeAbilities.frag]
        run.phase = "reward"
        compare(Gear.describeOffer(run, Gear.activeAbilities.frag).upgradeLevel, 1)
        verify(Rules.choose(run, "frag"))
        verify(!Rules.swapInventory(run, 0, "weapon", 0))
        verify(Rules.swapInventory(run, 0, "active", 0))
        compare(run.slots.active[0].item.id, "frag")
        compare(run.slots.active[0].item.level, 1)
        compare(run.inventory[0].item.id, "ward")
        compare(run.inventory[0].item.level, 2)
        verify(!Rules.swapInventory(run, 1, "weapon", 0))

        run.gold = 10000
        run.phase = "shop"
        for (let index = 5; index < Gear.inventoryLimit; index += 1) {
            const rolls = [.75,.75,.75,.75,.75,.75,.75,.75,.4,.13,.13]
            run.shopStock = Gear.makeShop(run, function() { return rolls.shift() ?? .75 })
            const expansion = run.shopStock.find(function(card) { return card.action === "inventory" })
            verify(!!expansion)
            verify(Rules.buy(run, expansion.id))
            compare(run.inventory.length, index + 1)
            verify(!Rules.buy(run, expansion.id))
        }
        run.shopStock = Gear.makeShop(run, function() { return .3 })
        verify(!run.shopStock.some(function(card) { return card.action === "inventory" }))
    }

    function test_alternateDebugBuilds() {
        const run = Rules.create(12)
        verify(Rules.configure(run, "normal", 20, "star"))
        verify(Rules.startWave(run))
        compare(run.wave, 20)
        compare(run.health, 9999)
        const gun = Gear.current(run)
        compare(gun.id, "starDestroyerPlus")
        compare(Gear.weaponStats(gun).damage, 100)
        compare(Gear.weapons.starDestroyer.damage, 17)
        verify(Gear.weapons.starDestroyer.spinup > Gear.weapons.starDestroyerPlus.spinup)
        verify(!Rules.shoot(run, []))
        gun.ammo = 0
        advance(run, 24, 0, true)
        verify(Rules.shoot(run, []))
        compare(gun.ammo, 0)
        compare(gun.spin, 0)
        verify(!Gear.canOffer(run, Gear.weapons.starDestroyerPlus))
        verify(Gear.canOffer(run, Gear.weapons.starDestroyer))

        for (const start of [10, 20, 50, 150]) {
            const practice = Rules.create(start * 2)
            verify(Rules.configure(practice, "hard", start, "random"))
            verify(Rules.startWave(practice))
            compare(practice.wave, start)
            verify(Gear.kits.some(function(kit) { return Gear.completeKit(practice, kit) }))
            verify(practice.slots.passive.length >= 4 && practice.slots.passive.length <= 8)
            compare(practice.slots.weapon.length, start >= 20 ? 2 : 1)
            compare(practice.health, Gear.maxHealth(practice))
            verify(!Rules.unlimitedAmmo(practice))
        }
    }

    function test_sharedArrivalDistanceAndBarrierSurvivesTurn() {
        const run = combat(40)
        for (const type of Object.keys(Rules.enemyTypes)) {
            const foe = spawn(run, type, "front")
            compare(foe.depth, Rules.enemyTypes[type].distance || Encounters.spawnDistance)
        }
        run.enemies = []
        const alien = spawn(run, "fizzalien", "front")
        Rules.wound(run, alien, 3)
        compare(alien.barrier, 0)
        run.slots.active[0].item = Gear.makeItem("ward")
        verify(Rules.useAbility(run, 0, "front"))
        verify(Rules.barrierCooldown(run) > 0)
        const duration = run.barrier
        Rules.damagePlayer(run, 15, "front", "silophosus")
        verify(run.barrierHp < run.barrierMax)
        const charges = run.barrierHp
        Rules.lookFront(run, "right")
        compare(run.barrier, duration)
        compare(run.barrierHp, charges)
        compare(alien.barrier, 0)
    }

    function test_penetratingWeapons() {
        const run = combat(20)
        const near = spawn(run, "humontafagus", "front")
        const far = spawn(run, "humontafagus", "front")
        const remote = spawn(run, "humontafagus", "right")
        run.slots.weapon[0].item = Gear.makeItem("starDestroyer")
        Gear.current(run).spin = 1
        const hp = near.hp
        verify(Rules.shoot(run, [near.id, far.id, remote.id], "front"))
        compare(hp - near.hp, 17)
        compare(hp - far.hp, 13.6)
        compare(hp - remote.hp, 0)

        const debug = combat(20)
        debug.debugBuild = "star"
        debug.slots.weapon[0].item = Gear.makeItem("starDestroyerPlus")
        Gear.current(debug).spin = 1
        const first = spawn(debug, "lucifoverus", "front")
        const second = spawn(debug, "lucifoverus", "front")
        verify(Rules.shoot(debug, [first.id, second.id], "front"))
        compare(first.maxHp - first.hp, 100)
        compare(second.maxHp - second.hp, 100)
        compare(Gear.current(debug).ammo, 1)
    }

    function test_expansionActivesConsumeIndependentCooldowns() {
        for (const card of Object.values(Expansion.actives)) {
            const run = combat(31)
            const enemy = spawn(run, "hosphoragus", "front")
            enemy.depth = 260
            enemy.attack = .48
            if (card.id === "sporeBurst")
                Rules.applyToEnemy(run, enemy, "poison", 2)
            spawn(run, "spartalien", "right")
            const seal = spawn(run, "crawler", "down")
            run.bolts.push({ front:"front", remaining:.5, duration:.72 })
            run.health = 71
            run.slots.active[0].item = Gear.makeItem(card.id)
            const view = card.id === "voidaegis" ? "down" : "front"
            verify(Rules.useAbility(run, 0, view, view === "down" ? seal.id : enemy.id, {x:.5,y:.5}), card.id)
            verify(Rules.activeCooldown(run, card.id) > 0, card.id)
            verify(!Rules.useAbility(run, 0, view, enemy.id, {x:.5,y:.5}), card.id)
        }
    }

    function test_poisonTicksOneDoseAndImmunityKeepsImpactDamage() {
        const run = combat(60)
        const boss = spawn(run, "stinkaturumus", "front")
        const angel = spawn(run, "lucifoverus", "left")
        const health = boss.hp
        Rules.wound(run, boss, 20, "gun", "poison", 3)
        compare(boss.hp, health - 17)
        compare(boss.elements.poison, 0)
        Rules.wound(run, angel, 20, "gun", "burn", 3)
        compare(angel.hp, angel.maxHp - 17)
        compare(angel.elements.burn, 0)

        Rules.strike(run, boss, Rules.enemyTypes[boss.type])
        compare(run.venomClouds.length, 1)
        advance(run, 33)
        verify(Rules.poisonFog(run, "front") > 0)
        compare(Rules.poisonFog(run, "right"), 0)
        verify(Rules.lookFront(run, "right"))
        advance(run, 124)
        compare(run.elements.poison, 0)
        compare(run.health, Gear.startingHealth)

        verify(Rules.lookFront(run, "front"))
        Rules.strike(run, boss, Rules.enemyTypes[boss.type])
        advance(run, 53)
        compare(run.elements.poison, 3)
        compare(Gear.maxHealth(run), Gear.startingHealth)
        advance(run, 61)
        compare(Gear.maxHealth(run), 194)
        const left = run.elements.poisonLeft
        for (const level of [1, 2, 3])
            Elements.apply(run.elements, "poison", level)
        compare(run.elements.poisonLeft, left)
        compare(run.elements.poisonLoss, .03)

        const other = Elements.fresh()
        Elements.apply(other, "poison", 1)
        Elements.advance(other, 2.25)
        Elements.apply(other, "poison", 3)
        compare(other.poisonLeft, 6.25)
        compare(other.poisonLoss, .02)
        Elements.advance(other, .75)
        compare(other.poisonLoss, .05)
        Elements.advance(other, 5.5)
        compare(Elements.healthFactor(other), 1)

        run.slots.active[0].item = Gear.makeItem("repairkit")
        run.health = 80
        verify(Rules.useAbility(run, 0, "front", boss.id))
        compare(Gear.maxHealth(run), Gear.startingHealth)
        compare(run.health, 104)
    }

    function test_saslimigusHitsLockFourDirectionsButShootingWorks() {
        const run = combat(60)
        const boss = spawn(run, "stinkaturumus", "front")
        boss.depth = 640
        boss.attack = 30
        boss.sideIn = 30
        // Seed the first 20% roll on each eligible hit.
        for (let count = 0; count < 4; count += 1) {
            run.rng = 1972
            Rules.wound(run, boss, 1, "gun")
            const peons = run.enemies.filter(function(enemy) { return enemy.type === "saslimigus" })
            compare(peons.length, Math.min(3, count + 1))
            verify(peons.every(function(enemy) {
                return enemy.depth === Encounters.spawnDistance && enemy.summoned && enemy.parent === boss.id
            }))
            run.time += 3
        }
        compare(Rules.remainingEnemies(run), 2)

        const peon = run.enemies[1]
        peon.warp = 0
        peon.depth = 510
        verify(Rules.lookFront(run, "right"))
        Rules.strike(run, peon, Rules.enemyTypes[peon.type])
        compare(run.bolts[0].slug, true)
        advance(run, 69)
        compare(run.elements.sticky, 0)
        verify(Rules.lookFront(run, "front"))
        Rules.strike(run, peon, Rules.enemyTypes[peon.type])
        advance(run, 69)
        compare(run.elements.sticky, 3)
        for (const direction of ["left", "right", "up", "down"])
            verify(!Rules.lookFront(run, Rules.turnFrom("front", direction)))
        compare(run.playerFront, "front")
        verify(Rules.shoot(run, [peon.id], "front", { x:.52, y:.52 }))

        const awake = run.elements.stickyLeft
        Elements.apply(run.elements, "sticky", 3)
        compare(run.elements.stickyLeft, awake)
        advance(run, 163)
        verify(boss.front === "left" || boss.front === "right")
        verify(!Rules.canTurn(run))
        advance(run, 40)
        verify(Rules.canTurn(run))
        verify(Rules.lookFront(run, "up"))
    }

    function test_itemUpgradeTokenAndDebugWeapon() {
        const run=combat(21)
        run.phase="shop"
        run.gold=900
        run.inventory[0]={group:"weapon",item:Gear.makeItem("rail")}
        run.shopStock=[{id:"item-upgrade-token",action:"item-upgrade",cost:510,sold:false}]
        verify(Gear.describeOffer(run,Gear.weapons.rail).storedUpgrade)
        verify(!Rules.buy(run,"item-upgrade-token",-1,"weapon/absent"))
        compare(run.gold,900)
        verify(Rules.buy(run,"item-upgrade-token",-1,"weapon/rail"))
        compare(run.inventory[0].item.level,1)
        compare(run.gold,390)
        verify(run.shopStock[0].sold)
        verify(!Rules.buy(run,"item-upgrade-token",-1,"weapon/rail"))

        const debug=Rules.create(181)
        verify(!Rules.setDebugWeapon(debug,"katana"))
        verify(Rules.configure(debug,"normal",10,"standard"))
        verify(Rules.setDebugWeapon(debug,"katana"))
        verify(Rules.startWave(debug))
        compare(Gear.current(debug).id,"katana")
    }

    function test_mastafangenbusLaunchesDuringApproach() {
        const run = combat(20)
        const boss = spawn(run, "mastafangenbus", "front")
        boss.depth = 940
        boss.sideIn = 30
        boss.ranged = .01
        advance(run, 2)
        compare(run.bolts.length, 1)
        const shard = run.bolts[0]
        verify(shard.shard)
        compare(shard.damage,boss.damage*.36)
        verify(shard.damage > 15)
        compare(shard.critChance,.30)
        verify(Rules.shoot(run, [shard.id], "front", { x:.51, y:.49 }))
        compare(run.bolts.length, 0)
        compare(run.metrics.intercepts, 1)
        boss.depth = Rules.enemyTypes[boss.type].reach
        boss.attack = 30
        boss.ranged = .01
        advance(run, 90)
        compare(run.bolts.length, 0)
    }

    function test_clearHealsByDifficultyAndCapsRecovery() {
        for (const mode of ["normal", "hard", "insane"]) {
            const run = combat(2)
            run.difficulty = mode
            run.health = 100
            run.boons.health = 50
            run.pending = []
            advance(run, 185)
            compare(run.phase, "reward")
            const expected = { normal:120, hard:115, insane:110 }
            compare(run.health, expected[mode])
        }
        const run = combat(1)
        run.health = Gear.startingHealth - 1
        run.pending = []
        advance(run, 185)
        compare(run.health, Gear.startingHealth)
    }

    function test_debugGearUnlocksAndRims() {
        const run = Rules.create(713, ["breacher"])
        const award = Gear.activeAbilities.arcshield
        verify(!Rules.applyDebugUnlocks(run, true))
        verify(!Rules.equipDebugGear(run, "active", award.id, 0))
        verify(!Gear.canOffer(run, award))
        verify(Rules.configure(run, "normal", 20))
        verify(Rules.applyDebugUnlocks(run, true))
        compare(run.unlocks.length, 71)
        verify(Gear.canOffer(run, award))
        verify(Rules.applyDebugUnlocks(run, false))
        compare(run.unlocks, ["breacher"])
        verify(!Gear.canOffer(run, award))
        verify(Rules.applyDebugUnlocks(run, true))
        verify(Rules.configure(run, "normal", 1))
        compare(run.unlocks, ["breacher"])
        verify(!run.debugUnlockAll)

        verify(Rules.configure(run, "normal", 20))
        verify(Rules.applyDebugUnlocks(run, true))
        verify(Rules.equipDebugGear(run, "active", award.id, 0))
        const slot = run.slots.active[0]
        compare(Gear.slotUpgradeColor("active", slot), "transparent")
        verify(Rules.equipDebugGear(run, "active", award.id, 0))
        const cooldownColor = Gear.slotUpgradeColor("active", slot)
        verify(Rules.equipDebugGear(run, "active", award.id, 0))
        compare(Gear.slotUpgradeColor("active", slot), Elements.kinds.electric.color)
        verify(cooldownColor !== Gear.slotUpgradeColor("active", slot))
        verify(Rules.skipSelection(run))
        verify(!Rules.equipDebugGear(run,"active",award.id,0))

        const nearest = spawn(run, "helboranius", "front")
        const next = spawn(run, "helboranius", "front")
        nearest.depth = 650
        next.depth = 745
        run.bolts.push({ front:"front" })
        verify(Rules.useAbility(run, 0, "front", nearest.id))
        compare(run.bolts.length, 0)
        compare(run.barrierHp, 2)
        compare(run.arcBursts.length, 1)
        verify(nearest.hp < nearest.maxHp && next.hp < next.maxHp)
    }

    function test_curseMisfiresWithoutStacking() {
        const run = combat(23)
        run.pet = null
        for (let i = 0; i < 2; i += 1)
            Rules.wound(run, spawn(run, "gendoustagus", "front"), 100, "gun")
        verify(run.cursed)
        compare(run.cues.filter(function(event) { return event.cue === "curse" }).length, 1)
        Rules.damagePlayer(run, 10, "front", "silophosus")
        compare(run.health, Gear.startingHealth - 12)
        const gun = Gear.current(run)
        let failures = 0
        for (let i = 0; i < 80; i += 1) {
            gun.recovery = 0
            gun.ammo = 7
            if (!Rules.shoot(run, [0], "front")) {
                compare(gun.ammo, 7)
                compare(run.cue, "misfire")
                failures += 1
            }
        }
        verify(failures >= 4 && failures <= 22, failures)
    }

    function test_dodgeRespondsToAimBeforeFire() {
        const run = combat(23)
        run.pet = null
        const ninja = spawn(run, "nindumipus", "front")
        ninja.depth = 980
        const away = spawn(run, "nindumipus", "right")
        const aim = { x:.47, y:.51, aspect:16/9 }
        const hp = ninja.hp
        for (let frame = 0; frame < 23; frame += 1)
            Rules.update(run, 1/60, 0, false, aim)
        verify(ninja.dodgeOffset > 35)
        verify(ninja.dodgeIn > 0)
        compare(away.dodgeOffset, 0)
        compare(ninja.hp, hp)
        verify(Rules.shoot(run, [ninja.id], "front"))
        verify(ninja.hp < hp)
        verify(Attacks.countdownSegment(15, 1))
        verify(!Attacks.countdownSegment(15, 0))
    }

}
