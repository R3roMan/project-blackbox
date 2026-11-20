import QtQuick
import QtTest
import "../game/Rules.js" as Rules
import "../game/Encounters.js" as Encounters
import "../game/Elements.js" as Elements
import "../game/Loadout.js" as Gear
import "../game/Progress.js" as Progress
import "../game/Pets.js" as Pets

TestCase {
    name: "AbyssAndWeather"

    function fight(wave, weather) {
        const run = Rules.create(3139)
        run.wave = wave - 1
        run.petChoice = ""
        verify(Rules.startWave(run))
        run.weatherEffect = weather || "clear"
        run.pending = [{ at:900,type:"silophosus",front:"front",lane:0 }]
        return run
    }

    function put(run, type, front, depth) {
        const foe = Rules.spawn(run,{type:type,front:front || run.playerFront,lane:0})
        verify(!!foe,type)
        if (!foe.waitingBoss)
            foe.warp = 0
        foe.travelSpeed = 0
        foe.attack = 500
        foe.sideIn = 500
        if (depth)
            foe.depth = depth
        return foe
    }

    function tick(run, seconds, seal, aim, settled) {
        for (let index = 0; index < Math.ceil(seconds * 60); ++index)
            Rules.update(run,1/60,!!seal,false,aim || 0,settled)
    }

    function test_scheduleSealAndArrivalTypes() {
        const debuts = {crawler:11, tenmani:16, lantis:25, shadow:38, lalaBubu:42, faeel:49,
            nightosphere:58, archfellanus:64, endme:66, reapfast:80}
        for (const [name,wave] of Object.entries(debuts))
            compare(Encounters.firstWave(name),wave,name)
        const run = fight(80)
        run.pending.push({at:800,type:"faeel",front:"left",lane:0},
            {at:810,type:"reapfast",front:"down",lane:0})
        compare(put(run,"archfellanus","right",800).warpKind,"divine")
        compare(put(run,"crawler","down",860).warpKind,"liquid")
        compare(put(run,"lalaBubu","up",1080).warpKind,"alienArrival")
        verify(Rules.lookFront(run,"down"))
        tick(run,5,true)
        fuzzyCompare(run.abyssSeal.progress,5/14,1e-5)
        verify(Rules.lookFront(run,"front"))
        tick(run,2,true)
        fuzzyCompare(run.abyssSeal.progress,5/14,1e-5)
        verify(Rules.lookFront(run,"down"))
        tick(run,9.04,true)
        verify(run.abyssSeal.closed)
        verify(!run.pending.some(function(entry) { return entry.type === "faeel" }))
        verify(run.pending.some(function(entry) { return entry.type === "reapfast" }))
        verify(run.enemies.some(function(foe) { return foe.type === "crawler" }))
        verify(!Rules.summon(run,{type:"crawler",front:"left",lane:0}))

        const invasion = Rules.create(3139)
        invasion.wave = 17
        verify(Rules.startWave(invasion))
        compare(invasion.weatherEffect,"incursion")
        const deep = invasion.pending.filter(function(entry) { return Rules.enemyTypes[entry.type].abyss })
        verify(deep.length > 0 && deep.length <= 5)
        verify(deep.some(function(entry) { return entry.front !== "down" }))
    }

    function test_grabAndHypnosis() {
        const run = fight(25)
        const tenmani = put(run,"tenmani","front",740)
        Rules.holdShield(run,true)
        Rules.strike(run,tenmani,Rules.enemyTypes.tenmani)
        verify(!run.grab)
        const hp = run.health
        Rules.holdShield(run,false)
        Rules.strike(run,tenmani,Rules.enemyTypes.tenmani)
        verify(run.grab && run.grab.constrict)
        verify(!Rules.canTurn(run))
        verify(!Rules.shoot(run,[tenmani.id],"front"))
        verify(!Rules.raiseShield(run))
        run.slots.active[0].item = Gear.makeItem("frag")
        verify(!Rules.useAbility(run,0,"front",tenmani.id))
        tick(run,1)
        verify(Rules.grabOffset(run.grab).depth > 150)
        tick(run,.5)
        verify(run.health < hp)
        tick(run,1.27)
        verify(Rules.canTurn(run))

        tenmani.depth = 1150
        const lantis = put(run,"lantis","front",1100)
        lantis.age = 5.2
        const aim = {x:.5,y:.5,aspect:1.43}
        tick(run,.03,false,aim)
        verify(!!run.hypnosis)
        const phantoms = run.enemies.filter(function(foe) { return foe.type === "hallucination" })
        verify(phantoms.length >= 6 && phantoms.length <= 8)
        verify(!Rules.lookFront(run,"left"))
        verify(!Rules.raiseShield(run))
        verify(!Rules.useAbility(run,0,"front",lantis.id))
        const lantisHp = lantis.hp
        run.weatherEffect = "rain"
        Rules.wound(run,phantoms[0],100,"gun","electric",2)
        for (const phantom of phantoms)
            Rules.wound(run,phantom,100,"gun")
        compare(lantis.hp,lantisHp)
        verify(!run.hypnosis)
        tick(run,.05,false,aim)
        verify(!run.hypnosis)
        verify(!run.metrics.kills)
    }

    function test_endmeNightosphereAndShadow() {
        const run = fight(68)
        const endme = put(run,"endme","down")
        for (let i=0; i<8; ++i)
            Rules.wound(run,endme,1,"gun","poison",3)
        compare(endme.eyeCount,0)
        compare(endme.eyesTime,6)
        compare(endme.elements.poison,0)
        const health = endme.hp
        Rules.wound(run,endme,4,"gun")
        fuzzyCompare(health-endme.hp,8,1e-5)
        tick(run,6.1)
        compare(endme.eyeCount,8)
        const orb = put(run,"nightosphere","down")
        for (const effect of ["burn","freeze","electric","weaken","blind","poison","stun","wind","sticky","explosive"])
            verify(Rules.statusImmune(orb,effect),effect)
        tick(run,10.25)
        verify(run.enemies.some(function(foe) { return foe.parent === orb.id }))
        Rules.wound(run,orb,9999,"gun")
        verify(run.gore.some(function(event) { return event.dark && event.crystal }))

        verify(Rules.lookFront(run,"down"))
        const shadow = put(run,"shadow","down",1425)
        tick(run,.6)
        compare(shadow.special.kind,"ink")
        tick(run,1.7)
        verify(run.inkStains && shadow.inkFired)
        tick(run,3)
        verify(!run.bolts.some(function(bolt) { return bolt.ink }))
        for (let i=0; i<10; ++i)
            Rules.wound(run,i ? put(run,"shadow","down",1100) : shadow,2000,"gun")
        verify(Progress.unlocked(Progress.merge({},run.metrics)).includes("minishade"))
        verify(Pets.spec("minishade").locked)
    }

    function test_attackInterruptionAndReflections() {
        const run = fight(64)
        run.slots.active[0].item = Gear.makeItem("frag")
        const eel = put(run,"faeel","down",450)
        verify(Rules.statusImmune(eel,"electric"))
        Rules.lookFront(run,"down")
        Rules.strike(run,eel,Rules.enemyTypes.faeel)
        compare(Rules.stunTime(run),2)
        verify(Rules.activeCooldown(run,"frag") >= Gear.activeAbilities.frag.cooldown)
        tick(run,2.1)
        const crawler = put(run,"crawler","down",290)
        crawler.attack = .2
        Rules.wound(run,crawler,.8,"gun")
        verify(crawler.attack > 1)
        const angel = put(run,"archfellanus","down",1200)
        angel.age = 8.3
        const before = run.health
        const angelHp = angel.hp
        Rules.wound(run,angel,5,"gun")
        compare(angel.hp,angelHp)
        compare(run.health,before-5)
        run.pet = Pets.deploy("crow",0)
        tick(run,.02)
        verify(run.pet.hostile)
        verify(Rules.lookFront(run,"front"))
        tick(run,.02)
        verify(!run.pet.hostile)

        const pilot = put(run,"spartalien","front",650)
        pilot.damage = 2
        run.pet = null
        run.slots.weapon[0].item = Gear.makeItem("katana")
        run.slots.passive[0].item = Gear.makeItem("edgeReturn")
        Rules.launchBolts(run,pilot,Rules.enemyTypes.spartalien)
        const incoming = run.bolts[0]
        incoming.remaining = .12
        compare(incoming.hp,0)
        verify(Rules.pickableBolt(incoming,"front",Rules.meleeReturnWindow(run)))
        const shipHp = pilot.hp
        verify(Rules.shoot(run,[incoming.id],"front"))
        verify(run.bolts[0].returning)
        const origin = Rules.projectilePoint(run.bolts[0]).depth
        tick(run,.18)
        verify(Rules.projectilePoint(run.bolts[0]).depth > origin)
        tick(run,.65)
        verify(pilot.hp < shipHp)
        run.slots.passive[0].item = Gear.makeItem("foilGuard")
        Rules.launchBolts(run,pilot,Rules.enemyTypes.spartalien)
        run.bolts[0].remaining = .06
        verify(Rules.raiseShield(run))
        tick(run,.08)
        verify(run.bolts.some(function(bolt) { return bolt.returning }))
    }

    function test_reapfastWaitsAndAllFourAttacks() {
        const run = fight(80)
        const levi = put(run,"reapfast","down")
        verify(levi.waitingBoss && !levi.special && !levi.warp)
        const original = levi.hp
        Rules.wound(run,levi,200,"gun")
        compare(levi.hp,original)
        tick(run,9)
        compare(levi.age,0)
        verify(Rules.lookFront(run,"down"))
        tick(run,.3,false,0,false)
        verify(levi.waitingBoss)
        tick(run,.05)
        verify(!levi.waitingBoss && levi.warpKind === "rise" && levi.warp > 3.7)
        tick(run,3.9)
        verify(Rules.statusImmune(levi,"poison"))
        const attack = function(kind, span) {
            levi.special = {kind:kind,time:0,warning:1,span:span,beats:0}
            levi.lastSpecial = kind
        }
        attack("bubbles",3.6)
        tick(run,1.5)
        const bubbles = run.bolts.filter(function(bolt) { return bolt.bubble })
        compare(bubbles.length,5)
        for (const bubble of bubbles)
            for (const other of bubbles)
                if (bubble.id < other.id)
                    verify(Math.hypot(bubble.lane-other.lane,bubble.elevation-other.elevation,
                        (bubble.depth-other.depth)*.58) >= 225)
        const health = run.health
        Rules.intercept(run,bubbles[0],10)
        verify(run.health < health)
        attack("suction",5)
        const bitten = run.health
        tick(run,3.9)
        verify(!!run.grab)
        verify(Rules.raiseShield(run))
        tick(run,1.2)
        compare(run.health,bitten)
        verify(!run.grab)
        verify(!run.bolts.some(function(bolt) { return bolt.bubble }))
        verify(levi.hp < original)
        attack("charge",3.25)
        tick(run,2)
        verify(levi.depth < 1750)
        verify(run.health < bitten)
        attack("roar",3.9)
        tick(run,1.55)
        verify(run.enemies.filter(function(foe) { return foe.parent === levi.id && foe.type === "crawler" }).length === 2)
        verify(run.elements.weakenLeft > 7.8)
        levi.special = null
        levi.attack = 0
        tick(run,.02)
        verify(levi.special.kind !== "roar")
    }

    function test_weatherAndColdWeapons() {
        const clear = fight(12)
        const night = fight(12,"night")
        const start = put(clear,"fizzalien","up")
        const dark = put(night,"fizzalien","up")
        fuzzyCompare(dark.hp / start.hp,1.05,1e-5)
        fuzzyCompare(dark.damage / start.damage,1.05,1e-5)
        fuzzyCompare(dark.barrier / start.barrier,1.05,1e-5)
        compare(Rules.blindRank(night),1)
        compare(Rules.attackBlindRank(night),0)
        fuzzyCompare(Rules.missChance(night,Rules.attackBlindRank(night),true),.05,1e-6)
        night.elements.blind=2
        compare(Rules.attackBlindRank(night),2)
        fuzzyCompare(Rules.missChance(night,Rules.attackBlindRank(night),true),.126,1e-6)
        fuzzyCompare(Rules.missChance(night,2,false),.08,1e-6)

        const rain = fight(48,"rain")
        const first = put(rain,"hosphoragus","front",380)
        const far = put(rain,"lantis","down",1500)
        const other = put(rain,"faeel","right",950)
        const life = first.hp
        const distant = far.hp
        const immune = other.hp
        Rules.wound(rain,first,2,"gun","electric",1)
        fuzzyCompare(life-first.hp,4,1e-5)
        verify(far.hp < distant && other.hp < immune)
        compare(rain.arcBursts.length,2)
        Rules.wound(rain,first,1,"gun","burn",3)
        compare(first.elements.burn,0)
        Rules.wound(rain,first,1,"gun","freeze",1)
        compare(first.elements.frozen,2)
        const health = rain.health
        Rules.damagePlayer(rain,5,"front","faeel",false,{element:"electric",elementLevel:2,critical:false},true)
        compare(rain.health,health-10)
        Rules.damagePlayer(rain,1,"front","claptrap",false,{element:"freeze",elementLevel:1,critical:false},true)
        compare(rain.elements.frozen,2)
        rain.slots.active[0].item = Gear.makeItem("thawCoil")
        verify(Rules.useAbility(rain,0,"front",0))
        compare(rain.elements.frozen,0)
        Rules.damagePlayer(rain,1,"front","gigafinterus",false,{element:"burn",elementLevel:3,critical:false})
        compare(rain.elements.burn,0)

        const winter = Rules.create(3139)
        winter.wave = 11
        verify(Rules.startWave(winter))
        compare(winter.weatherEffect,"winter")
        winter.pet = null
        winter.pending = [{at:900,type:"silophosus",front:"front",lane:0}]
        const normal = put(winter,"hosphoragus","right",800)
        const yeti = put(winter,"iceterapus","front",780)
        tick(winter,4.95)
        compare(winter.elements.frost,0)
        tick(winter,.1)
        compare(winter.elements.frost,1)
        compare(normal.elements.frost,1)
        compare(yeti.elements.frost,0)
        tick(winter,5)
        verify(winter.elements.frostLeft > 1.9)

        const frost = fight(30)
        frost.slots.weapon[0].item = Gear.makeItem("rimeRelay")
        const core = put(frost,"hosphoragus","front",570)
        const neighbour = put(frost,"hosphoragus","front",620)
        neighbour.lane = 120
        Rules.applyToEnemy(frost,core,"freeze",1,{forceFreeze:true})
        const nearHealth = neighbour.hp
        verify(Rules.shoot(frost,[core.id],"front"))
        verify(neighbour.hp < nearHealth && neighbour.elements.frost > 0)
        frost.slots.weapon[0].item = Gear.makeItem("whiteoutCoil")
        core.baseHp = core.maxHp = core.hp = 100
        core.elements = Elements.fresh()
        const gun = Gear.current(frost)
        for (let i=0; i<6; ++i) {
            gun.recovery = 0
            verify(Rules.shoot(frost,[core.id],"front"))
        }
        compare(core.elements.frozen,2)
    }

    function test_shopDurabilityRepeatLuckAndPaidCache() {
        const run = fight(50)
        Rules.openShop(run)
        run.gold = 10000
        const common = [Gear.weapons.pistol,Gear.weapons.carbine]
        compare(Gear.pickRarityItem(run,common,.038).id,"pistol")
        compare(Gear.pickRarityItem(run,common,.94).rarity,"common")
        compare(Gear.mysteryItem(run,.799,.25).rarity,"epic")
        compare(Gear.mysteryItem(run,.801,.25).rarity,"legendary")
        const custom = {id:"cache",action:"mystery",cost:670,tierRoll:.75,itemRoll:.74,sold:false}
        run.shopStock = [custom,{id:"repeat",action:"repeat-upgrade",cost:430,sold:false},
            {id:"barrier",action:"barrier-core",cost:375,sold:false},
            {id:"calibrate",action:"shop-stat",stat:"damage",amount:.085,cost:380,sold:false},
            {id:"expand",action:"expand-shop",cost:475,sold:false}]
        verify(Rules.buy(run,"repeat"))
        compare(run.repeatRank,1)
        fuzzyCompare(Gear.repeatChance(run.repeatRank),.095,1e-6)
        verify(Rules.buy(run,"barrier"))
        compare(run.barrierCell.hp,2)
        verify(Rules.buy(run,"calibrate"))
        compare(run.boons.damage,.085)
        verify(Rules.buy(run,"expand"))
        compare(run.shopCapacity,6)
        compare(Gear.shopCards(run).length,6)
        verify(!Rules.buy(run,"expand"))
        const cash = run.gold
        verify(Rules.buy(run,"cache"))
        compare(run.gold,cash-670)
        const revealed = run.shopStock[0]
        verify(revealed.paid && !revealed.sold)
        verify(!Rules.leaveShop(run))
        verify(Rules.refresh(run))
        compare(run.shopStock[0].gearId,revealed.gearId)
        verify(Rules.buy(run,"cache",Gear.inventoryDestination))
        compare(run.inventory[0].item.id,revealed.gearId)
        compare(run.gold,cash-670)
        verify(Rules.leaveShop(run))
        verify(Rules.startWave(run))
        compare(run.barrierCell.hp,2)
        const life = run.health
        for (let i=0; i<2; ++i)
            Rules.damagePlayer(run,700,"front","spartalien",false,{critical:false},true)
        compare(run.health,life)
        compare(run.barrierCell.hp,0)
        verify(Rules.lookFront(run,"right"))
        compare(run.barrierCell.hp,0)
        compare(run.barrierCell.level,1)
    }

    function test_lalaCursedGiftAndCriticalReadout() {
        const run = fight(43)
        const doll = put(run,"lalaBubu","up",720)
        Rules.strike(run,doll,Rules.enemyTypes.lalaBubu)
        compare(run.bolts.length,0)
        verify(Rules.lookFront(run,"up"))
        Rules.strike(run,doll,Rules.enemyTypes.lalaBubu)
        compare(run.bolts.length,1)
        Rules.wound(run,doll,500,"gun")
        verify(run.cursed)
        compare(run.dizzyLeft,10)
        compare(Rules.turnInput(run,"up"),"down")
        tick(run,10.1)
        verify(run.cursed)
        compare(Rules.turnInput(run,"up"),"up")
        const gift = {id:2000,kind:"dizzy",cursed:true,front:"up",remaining:5,depth:400,lane:0}
        run.gifts.push(gift)
        Rules.claimGift(run,gift)
        compare(run.dizzyLeft,6)
        compare(Rules.turnInput(run,"left"),"right")
        Rules.criticalHit(run,9.25,false)
        compare(run.criticalNumber,9.25)
        tick(run,.1)
        compare(run.criticalNumber,9.25)
    }

    function test_reapfastFangsBreakLaunchAndRegrow() {
        const run = fight(80)
        Rules.lookFront(run,"down")
        const boss = put(run,"reapfast","down")
        const first = boss.fangs[0]
        verify(first.hp > 20)
        const life = boss.hp
        verify(Rules.shoot(run,[first.id],"down"))
        verify(first.hp < first.maximum && boss.hp < life)
        Rules.hitFang(run,boss,first,first.hp+99)
        verify(first.hp === 0 && first.rebuildAt >= run.time+29.9)
        boss.hp = boss.maxHp*.49
        boss.attack = 0
        tick(run,1/60)
        compare(boss.special.kind,"fangs")
        tick(run,1.55)
        const shots = run.bolts.filter(function(bolt) { return bolt.fang })
        compare(shots.length,2)
        verify(shots[0].hp > 10 && Rules.pickableBolt(shots[0],"down"))
        verify(!Rules.intercept(run,shots[0],.5))
        run.slots.weapon[0].item = Gear.makeItem("breakwater",3)
        run.sureAttack = true
        run.aimSeed = 1000
        verify(Rules.shoot(run,[shots[0].id],"down"))
        verify(!run.bolts.includes(shots[0]))
        verify(run.bursts.some(function(burst) {return burst.front==="down" && burst.color==="#f7e5bd"}))
        verify(Rules.lookFront(run,"front"))
        boss.special = null
        boss.attack = 200
        tick(run,30.1)
        verify(boss.fangs.every(function(fang) { return fang.hp === fang.maximum }))
    }

    function test_veilskateHoldsRangeAndFiresGreenPlasma() {
        const stage=Encounters.planWave(18,987,"normal")
        verify(stage.schedule.some(function(entry) {return entry.type==="veilskate" && entry.front==="up"}))
        const run=fight(18)
        run.skyPhase="daytime"
        Rules.lookFront(run,"up")
        const foe=Rules.spawn(run,{type:"veilskate",front:"up",lane:0})
        const spec=Rules.enemyTypes.veilskate
        verify(foe.depth>Rules.enemyTypes.fetaSpotter.distance)
        const height=Rules.elevation(foe)
        tick(run,1.8)
        verify(foe.lane<0)
        compare(foe.depth,spec.distance)
        compare(Rules.elevation(foe),height)
        foe.lane=-foe.depth*.26
        tick(run,.1)
        compare(foe.diagonal,1)
        verify(foe.lane>-foe.depth*.26)
        foe.attack=.01
        tick(run,.05)
        const shot=run.bolts.find(function(bolt) {return bolt.source==="veilskate"})
        verify(shot)
        compare(shot.color,"#66ff35")
        compare(shot.critChance,.4)
        verify(foe.attack>6)
        run.criticalSeed=0
        const health=run.health
        tick(run,shot.remaining+.05)
        fuzzyCompare(health-run.health,shot.damage*1.5,1e-5)
        verify(run.incomingCriticalUntil>run.time)
        fuzzyCompare(run.incomingCriticalDamage,shot.damage*1.5,1e-5)
        Rules.applyToEnemy(run,foe,"blind",3)
        Rules.strike(run,foe,spec)
        const blindShot=run.bolts[0]
        compare(blindShot.blindAtFire,3)
        const prior=run.health
        run.aimSeed=2000
        tick(run,blindShot.remaining+.05)
        compare(run.health,prior)
        compare(run.hostileMissName,spec.title)
        verify(run.hostileMissUntil>run.time)
        compare(foe.depth,spec.distance)
        compare(Rules.elevation(foe),height)
    }

    function test_waveEndsHalfASecondAfterFinalKill() {
        const run=fight(1)
        run.pending=[]
        const foe=put(run,"silophosus","front")
        Rules.wound(run,foe,999,"gun")
        compare(run.waveKills,1)
        tick(run,.45)
        compare(run.phase,"combat")
        tick(run,.05)
        verify(run.phase!=="combat")
    }

    function test_fearmeAndSkullVolleys() {
        compare(Encounters.firstWave("skorochiyus"),6)
        compare(Encounters.firstWave("fearme"),73)
        const run = fight(73)
        const skull = put(run,"skorochiyus","front",750)
        Rules.strike(run,skull,Rules.enemyTypes.skorochiyus)
        compare(run.bolts.length,2)
        verify(run.bolts.every(function(shot) { return shot.element === "burn" && shot.elementLevel === 2 }))
        compare(run.bolts[0].remaining,run.bolts[1].remaining)
        verify(Math.abs(run.bolts[0].lane-run.bolts[1].lane)>100)
        const mother = put(run,"mothergalian","up",750)
        Rules.strike(run,mother,Rules.enemyTypes.mothergalian)
        compare(run.bolts.filter(function(shot) { return shot.sourceId === mother.id }).length,5)
        run.bolts = []
        const reaper = put(run,"fearme","front")
        verify(reaper.depth > 3000)
        const maximum = Gear.maxHealth(run)
        Rules.holdShield(run,true)
        Rules.raiseBarrier(run,15,2)
        reaper.depth=410
        Rules.strike(run,reaper,Rules.enemyTypes.fearme)
        compare(Gear.maxHealth(run),maximum)
        compare(run.barrierHp,2)
        compare(Rules.shieldCharge(run),1)
        Rules.holdShield(run,false)
        verify(reaper.depth>1400 && !reaper.retreat)
        reaper.depth=410
        Rules.strike(run,reaper,Rules.enemyTypes.fearme)
        compare(Gear.maxHealth(run),maximum/2)
        compare(run.barrierHp,2)
        compare(reaper.warpKind,"sink")
        tick(run,1.7)
        verify(!run.enemies.includes(reaper) && !run.metrics.fearmeKills)
        Rules.wound(run,put(run,"fearme","down"),9999,"gun")
        verify(Progress.unlocked(Progress.merge({},run.metrics)).includes("fearScythe"))
        run.phase = "between"
        verify(Rules.startWave(run))
        compare(Gear.maxHealth(run),maximum)
    }

    function test_windyGlitchAndSightMisses() {
        const run = fight(34,"windy")
        fuzzyCompare(Rules.missChance(run,0),.15,1e-6)
        verify(Rules.missChance(run,3) > Rules.missChance(run,1))
        const foe = put(run,"hosphoragus","front",690)
        const hp = foe.hp
        const ammo = Gear.current(run).ammo
        run.aimSeed = 2000
        verify(Rules.shoot(run,[foe.id],"front"))
        compare(foe.hp,hp)
        compare(Gear.current(run).ammo,ammo-1)
        run.aimSeed = 2000
        const life = run.health
        Rules.damagePlayer(run,12,"front",foe.type,false,{sourceId:foe.id,critical:false})
        compare(run.health,life)
        run.waveTime = 19.99
        tick(run,.06)
        verify(run.gustLeft > 1 && foe.depth >= 690+187 && foe.hp < hp)
        run.weatherEffect = "glitch"
        compare(Rules.slotInput(run,0),1)
        compare(Rules.turnInput(run,"left"),"right")
        run.weatherEffect = "clear"
        run.elements.blind = 3
        run.elements.blindLeft = 6
        run.aimSeed = 2000
        Gear.current(run).recovery = 0
        const now = foe.hp
        verify(Rules.shoot(run,[foe.id],"front"))
        compare(foe.hp,now)
    }

    function test_newEquipmentAndIntermissionEditLock() {
        const run = fight(74)
        run.slots.passive[0].item = Gear.makeItem("soulReaper")
        run.slots.passive[1].item = Gear.makeItem("parry")
        run.slots.active[0].item = Gear.makeItem("boneShatter")
        const before = Rules.criticalProfile(run,Gear.weapons.pistol)
        verify(Rules.useAbility(run,0,"front",0))
        const after = Rules.criticalProfile(run,Gear.weapons.pistol)
        verify(after.chance > before.chance+.23 && after.power > before.power+.49)
        Rules.wound(run,put(run,"silophosus","front",270),1000,"gun")
        compare(run.souls,1)
        verify(Rules.outgoing(run) > 1)
        verify(Rules.raiseShield(run))
        Rules.damagePlayer(run,10,"front","hosphoragus",false,{critical:false})
        compare(Rules.shieldCharge(run),1)
        verify(run.shield.drainRelief>0)
        compare(run.metrics.parries,1)
        run.inventory[0] = {group:"active",item:Gear.makeItem("frag")}
        verify(!Rules.swapInventory(run,0,"active",0))
        verify(!Rules.canEditLoadout(run))
        Rules.openShop(run)
        run.gold = 3400
        run.shopStock = [{id:"dice",action:"scramble",cost:560,sold:false}]
        const passives = run.slots.passive.filter(function(slot) { return slot.item })
            .map(function(slot) { return slot.item.id })
        verify(Rules.buy(run,"dice"))
        compare(run.inventory[0].item.id,"frag")
        verify(run.slots.passive.filter(function(slot) { return slot.item })
            .every(function(slot) { return !passives.includes(slot.item.id) && slot.item.level === 0 }))
        compare(run.gold,2840)
        verify(Rules.leaveShop(run))
        verify(Rules.startWave(run))
        compare(run.souls,0)
        const gun = Gear.makeItem("jesterScatter")
        const deck = new Set()
        for (let i=0; i<6; ++i)
            deck.add(Rules.drawJesterStatus(run,gun))
        compare(deck.size,6)
    }
}
