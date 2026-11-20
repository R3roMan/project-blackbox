import QtQuick
import QtTest
import "../game/Rules.js" as Rules
import "../game/Encounters.js" as Encounters
import "../game/Loadout.js" as Gear
import "../game/Arsenal.js" as Arsenal
import "../game/MeleeArt.js" as Blades
import "../game/Pets.js" as Pets
import "../game/Progress.js" as Progress
import "../game/Optics.js" as Optics

TestCase {
    name: "Arsenal"

    function arena(wave, weapon) {
        const run = Rules.create(92871)
        run.wave = wave - 1
        run.petChoice = ""
        if (weapon)
            run.slots.weapon[0].item = Gear.makeItem(weapon)
        verify(Rules.startWave(run))
        run.weatherEffect = "clear"
        run.pending = [{ at:300,type:"silophosus",front:"front",lane:0 }]
        return run
    }

    function advance(run, frames, held) {
        for (let frame = 0; frame < frames; frame += 1)
            Rules.update(run, 1/60, 0, !!held)
    }

    function target(run, type, depth, front) {
        const enemy = Rules.spawn(run, {type:type || "humontafagus",front:front || "front",lane:0})
        if (enemy.waitingBoss)
            Rules.engageBoss(run,enemy)
        enemy.warp = 0
        enemy.depth = depth || 360
        enemy.travelSpeed = 0
        enemy.attack = 120
        enemy.sideIn = 120
        return enemy
    }

    function test_fieldShieldTimingAndBarrierPersistence() {
        const run = Rules.create(41)
        Rules.raiseBarrier(run,30,2)
        run.barrierHp = 1
        verify(Rules.startWave(run))
        run.pending = [{ at:100,type:"silophosus",front:"front",lane:0 }]
        compare(run.barrier,30)
        compare(run.barrierHp,1)
        Rules.holdShield(run,true)
        verify(run.shield.raised)
        fuzzyCompare(Rules.shieldCharge(run),.8,1e-6)
        const ammo = Gear.current(run).ammo
        verify(!Rules.shoot(run,[],"front"))
        compare(Gear.current(run).ammo,ammo)
        advance(run,170)
        verify(!run.shield.raised && run.shield.held)
        Rules.holdShield(run,false)
        Rules.holdShield(run,true)
        verify(!run.shield.raised && run.shield.rejected>0)
        advance(run,270)
        verify(!run.shield.raised && Rules.shieldCharge(run)>.99)
        Rules.holdShield(run,false)
        Rules.holdShield(run,true)
        const start = run.health
        Rules.damagePlayer(run,10,"front","capablancamus",false,{critical:true})
        compare(run.health,start)
        compare(run.barrierHp,1)
        compare(run.shield.absorbed,15)
        compare(run.shieldCrits,1)
        verify(run.shield.raised)
        compare(Rules.shieldCharge(run),1)
        Rules.holdShield(run,false)
        Rules.damagePlayer(run,10,"front","spartalien",false,{critical:false},true)
        compare(run.shieldCrits,1)
        compare(run.barrierHp,0)
        verify(Rules.lookFront(run,"right"))
        compare(run.barrierHp,0)
    }

    function test_eyeHitGuaranteesCriticalWithOrdinaryAim() {
        const run=arena(2,"pistol")
        const foe=target(run,"hosphoragus",640)
        run.criticalSeed=run.aimSeed=0
        verify(Rules.shoot(run,[foe.id],"front",{x:.5,y:.5,eyeTargets:[]}))
        compare(run.metrics.criticalHits || 0,0)
        advance(run,65)
        run.criticalSeed=run.aimSeed=0
        verify(Rules.shoot(run,[foe.id],"front",{x:.5,y:.4,eyeTargets:[foe.id]}))
        compare(run.metrics.criticalHits,1)
    }

    function test_pelletRegionsAndMeleeContact() {
        const run=arena(2,"scattergun")
        const foe=target(run,"hosphoragus",500)
        foe.hp=foe.maxHp=foe.baseHp=200
        const base=Gear.effectiveWeaponStats(run,Gear.current(run)).damage
        const falloff=.40+1.12*((1160-500)/900)
        run.criticalSeed=run.aimSeed=0
        const contacts=["body","eye","outer"].map(zone=>({id:foe.id,zone:zone}))
        verify(Rules.shoot(run,[foe.id,foe.id,foe.id],"front",{contacts:contacts}))
        fuzzyCompare(200-foe.hp,base*falloff*(1+1.5+.8),1e-5)
        compare(run.metrics.criticalHits,1)

        const blade=arena(2,"katana")
        const close=target(blade,"hosphoragus",200)
        close.hp=close.maxHp=close.baseHp=200
        const strike=Gear.effectiveWeaponStats(blade,Gear.current(blade)).damage
        blade.sureAttack=true
        blade.aimSeed=0
        verify(Rules.shoot(blade,[close.id],"front",{contacts:[{id:close.id,zone:"eye"}]}))
        fuzzyCompare(200-close.hp,strike,1e-5)
        verify(!blade.metrics.criticalHits)
    }

    function test_fieldShieldDoesNotBlockAnOffscreenStrike() {
        const run=arena(2)
        verify(Rules.raiseShield(run))
        const hp=run.health
        Rules.damagePlayer(run,10,"right","fhantamegus",false,{critical:false,blindAtFire:0})
        compare(run.health,hp-10)
        verify(!run.metrics.shieldBlocks)
        compare(Rules.shieldCharge(run),.8)
    }

    function test_scopedHitsMarkOnlyTheirTargetAndExpire() {
        const run = arena(2,"rail")
        const gun = Gear.current(run)
        const marked = target(run,"hosphoragus",640)
        const other = target(run,"hosphoragus",720)
        for (const foe of [marked,other]) foe.baseHp=foe.maxHp=foe.hp=1000
        fuzzyCompare(Rules.missChance(run,0,true),.05,.00001)
        compare(Rules.missChance(run,0,false),0)
        run.aimSeed=2000
        Rules.shoot(run,[marked.id],"front",{scoped:true})
        compare(marked.sightMark,0)
        compare(marked.hp,1000)
        gun.recovery=0
        run.aimSeed=1
        Rules.shoot(run,[marked.id],"front",{scoped:true})
        compare(marked.sightMark,4)
        verify(Rules.isMarked(marked))
        verify(!marked.marked && !marked.mark)
        const first=marked.hp
        gun.recovery=0
        run.weatherEffect="windy"
        run.aimSeed=2000
        Rules.shoot(run,[other.id,marked.id],"front")
        verify(marked.hp<first)
        compare(other.hp,1000)
        const second=marked.hp
        run.aimSeed=2000
        Rules.wound(run,marked,3,"ability")
        verify(marked.hp<second)
        run.aimSeed=2000
        Rules.wound(run,other,3,"ability")
        compare(other.hp,1000)
        advance(run,245)
        compare(marked.sightMark,0)
        const expired=marked.hp
        run.aimSeed=2000
        gun.recovery=0
        Rules.shoot(run,[marked.id],"front")
        compare(marked.hp,expired)
    }

    function test_mixedDisablesLeaveTimeToAct() {
        const run = arena(50)
        run.weatherEffect = "rain"
        run.healthBase = run.health = 5000
        for (let i = 0; i < 45; ++i) {
            Rules.damagePlayer(run,1,"front","hasasasa",false,{element:"freeze",elementLevel:3,critical:false},true)
            Rules.damagePlayer(run,1,"front","faeel",false,{element:"electric",elementLevel:2,forceStun:2,critical:false})
            Rules.playerStatus(run,"stun",1)
            if (i===0) compare(Rules.stunTime(run),2)
            if (i>=21 && i<=43) verify(Rules.canAct(run),"Recovery window "+i)
            advance(run,6)
        }
    }

    function test_criticalHitsAndShieldAchievement() {
        const run = arena(56)
        const gun = Gear.current(run)
        const crit = Rules.criticalProfile(run,Gear.weapons.pistol)
        compare(crit.power,1.5)
        compare(crit.chance,.05)
        const tank = target(run,"capablancamus",560)
        const hp = tank.hp
        run.sureAttack = true
        verify(Rules.shoot(run,[tank.id],"front"))
        fuzzyCompare(hp-tank.hp,Gear.weapons.pistol.damage,1e-5)
        verify(!run.metrics.criticalHits)
        const demon = target(run,"hosphoragus",560)
        const before = demon.hp
        run.sureAttack = true
        gun.recovery = 0
        verify(Rules.shoot(run,[demon.id],"front"))
        fuzzyCompare(before-demon.hp,Gear.weapons.pistol.damage*1.5,1e-5)
        compare(run.metrics.criticalHits,1)
        const health = run.health
        Rules.damagePlayer(run,10,"front","capablancamus",false,{critical:true})
        compare(run.health,health-15)
        for (let i = 0; i < 5; ++i) {
            verify(Rules.raiseShield(run))
            Rules.damagePlayer(run,10,"front","capablancamus",false,{critical:true})
            advance(run,481)
        }
        compare(run.metrics.bestShieldCrits,5)
        const prior = Progress.merge({}, { bestShieldCrits:3 })
        verify(!Progress.unlocked(Progress.merge(prior,{ bestShieldCrits:3 })).includes("hardplate"))
        verify(Progress.unlocked(Progress.merge(prior,run.metrics)).includes("hardplate"))
    }

    function test_shieldModesPerksAndShopUpgrade() {
        const run = arena(21)
        run.slots.passive[0].item = Gear.makeItem("perfectGuard")
        run.slots.passive[1].item = Gear.makeItem("guardToll")
        run.slots.passive[2].item = Gear.makeItem("coolGuard")
        run.slots.active[0].item = Gear.makeItem("reserveGuard")
        const foe = target(run,"hosphoragus",440)
        const hp = foe.hp
        verify(Rules.raiseShield(run))
        compare(run.shield.mode,"perfectGuard")
        Rules.damagePlayer(run,11,"front",foe.type,false,{sourceId:foe.id,critical:false})
        compare(run.gold,2)
        advance(run,1)
        fuzzyCompare(hp-foe.hp,9.9,1e-5)
        verify(Rules.shieldCharge(run)>.98 && run.shield.drainRelief>0)
        verify(Rules.useAbility(run,0,"front",0))
        compare(run.shield.cool,0)
        Rules.holdShield(run,true)
        Rules.holdShield(run,false)
        compare(Rules.shieldCharge(run),1)
        run.phase = "shop"
        run.gold = 2000
        const rolls = [.65,.8,.8,.80,.80,.80,.80,.80,.5,.80,.80,.25]
        run.shopStock = Gear.makeShop(run,function() { return rolls.shift() ?? .7 })
        compare(run.shopStock.length,5)
        verify(Rules.buy(run,"shield-upgrade"))
        compare(run.shield.level,1)
        compare(run.shopStock.length,5)
        verify(!Rules.buy(run,"shield-upgrade"))
    }

    function test_multiBlockAndTimedShieldVariations() {
        const run = arena(18)
        run.slots.passive[0].item = Gear.makeItem("fleetShell")
        Rules.holdShield(run,true)
        const limit = run.shield.limit
        verify(run.shield.raised && limit > 0)
        advance(run,Math.ceil(limit*60)+1)
        verify(!run.shield.raised && Rules.shieldCharge(run)<.20)
        Rules.holdShield(run,false)
        advance(run,300)
        run.slots.passive[0].item = Gear.makeItem("bulwark")
        run.slots.active[0].item = Gear.makeItem("glassVault")
        Rules.holdShield(run,true)
        compare(run.shield.charges,2)
        verify(Rules.useAbility(run,0,"front",0))
        compare(run.shield.charges,3)
        for (let i=0; i<3; ++i)
            Rules.damagePlayer(run,2,"front","spartalien",false,{critical:false},true)
        verify(run.shield.raised && Rules.shieldCharge(run)>.70)
        compare(run.health,Gear.maxHealth(run))
    }

    function test_triadQueuesTogetherAndBuffsNearbyEnemies() {
        const run = arena(56)
        const cap = Encounters.maxConcurrent(run.wave,run.difficulty)
        for (let i = 0; i < cap-2; ++i)
            target(run,"silophosus",970,i === 0 ? "up" : "front")
        run.pending.unshift({ at:0,type:"trispiramahedus",front:"up",lane:0 })
        advance(run,1)
        compare(run.enemies.length,cap-2)
        Rules.wound(run,run.enemies[cap-3],1000,"gun")
        advance(run,1)
        compare(run.enemies.length,cap)
        const trio = run.enemies.filter(function(enemy) { return enemy.type === "trispiramahedus" })
        compare(trio.length,3)
        compare(trio.filter(function(enemy) { return !enemy.summoned }).length,3)
        for (const member of trio) {
            compare(member.depth,Encounters.spawnDistance)
            member.warp = 0
            member.depth = 970
        }
        compare(new Set(trio.map(function(enemy) { return enemy.triad })).size,1)
        const ally = run.enemies[0]
        ally.travelSpeed = 80
        const initial = ally.depth
        advance(run,1)
        verify(ally.linked)
        fuzzyCompare(initial-ally.depth,80*1.30/60,1e-5)
        compare(run.links.filter(function(link) { return link.triangle }).length,3)
        verify(!run.enemies[1].linked)
        trio[0].depth = Encounters.enemyTypes.trispiramahedus.reach
        trio[0].attack = 0
        advance(run,1)
        compare(run.bolts[0].element,"electric")
        compare(run.bolts[0].electricStun,.30)
        Rules.wound(run,trio[0],1000,"gun")
        compare(run.links.filter(function(link) { return link.triangle }).length,1)
        verify(!run.links.some(function(link) { return link.a === trio[0].id || link.b === trio[0].id }))
    }

    function test_longRangeSerpentAndWeaponOptics() {
        for (const weapon of Object.values(Gear.weapons)) {
            const optic = Optics.optic(weapon)
            verify(optic.zoom > 1)
            verify(optic.focus < 1)
            verify(!!optic.label)
        }
        verify(Optics.optic(Gear.weapons.rail).zoom > Optics.optic(Gear.weapons.pistol).zoom)
        const run = arena(62,"rail")
        const spec = Encounters.enemyTypes.helesepeptium
        compare(Encounters.firstWave(spec.id),62)
        const snake = Rules.spawn(run,{ type:spec.id,front:"left",lane:70 })
        verify(snake.depth > Encounters.spawnDistance*2)
        verify(Rules.lookFront(run,"left"))
        advance(run,120)
        compare(snake.depth,spec.distance)
        Rules.applyToEnemy(run,snake,"wind",3)
        compare(snake.depth,spec.distance)
        snake.attack = .44
        verify(Rules.warningProgress(snake) > .65)
        advance(run,30)
        const bolt = run.bolts[0]
        compare(bolt.element,"electric")
        compare(bolt.elementLevel,2)
        verify(bolt.duration > 1 && bolt.duration < 2)
        verify(Rules.shoot(run,[bolt.id],"left"))
        compare(run.bolts.length,0)
        const hp = snake.hp
        Gear.current(run).recovery = 0
        verify(Rules.shoot(run,[snake.id],"left"))
        verify(snake.hp < hp)
    }

    function test_sniperPerchesAfterHits() {
        const run = arena(65,"rail")
        const kind = Encounters.enemyTypes.fetaSpotter
        const sniper = Rules.spawn(run,{ type:kind.id,front:"right",lane:0 })
        compare(Encounters.firstWave(kind.id),65)
        verify(sniper.depth > Encounters.enemyTypes.helesepeptium.distance)
        sniper.warp = 0
        const depth = sniper.depth
        Rules.wound(run,sniper,1,"burn")
        compare(sniper.warp,0)
        verify(Rules.lookFront(run,"right"))
        verify(Rules.shoot(run,[sniper.id],"right"))
        compare(sniper.warpKind,"perchOut")
        advance(run,35)
        compare(sniper.warp,0)
        compare(sniper.front,"right")
        compare(sniper.depth,depth)
        verify(Math.abs(sniper.lane) < depth*.20)
        const perch = sniper.sniperPerch
        Gear.current(run).recovery = 0
        verify(Rules.shoot(run,[sniper.id],"right"))
        verify(sniper.sniperPerch !== perch)
        advance(run,35)
        sniper.attack = 0
        advance(run,1)
        verify(run.bolts.some(function(bolt) { return bolt.sourceId === sniper.id && bolt.sniper && bolt.hp > 0 }))
    }

    function test_devourerFeedsAndShieldStopsPlayerBite() {
        const run = arena(68)
        run.weatherEffect = "clear"
        compare(Encounters.firstWave("nosferapabakus"),68)
        const demon = target(run,"nosferapabakus",780)
        const victim = target(run,"hosphoragus",1050)
        victim.lane = 230
        demon.hp -= 50
        demon.feedAfter = run.time
        const before = demon.hp
        const health = victim.hp
        advance(run,19)
        verify(demon.feed && Math.abs(demon.feedYaw) > 10 && demon.lane > 0)
        verify(demon.depth > 780)
        advance(run,16)
        verify(victim.hp < health)
        fuzzyCompare(demon.hp-before,demon.maxHp*.10,1e-5)
        advance(run,34)
        verify(!demon.feed)
        Rules.wound(run,victim,999,"gun")
        const healed = demon.hp
        demon.attack = 0
        demon.depth = Encounters.enemyTypes.nosferapabakus.reach
        const player = run.health
        Rules.holdShield(run,true)
        advance(run,1)
        compare(run.health,player)
        compare(demon.hp,healed)
        verify(Rules.shieldCharge(run)>.98)
        Rules.holdShield(run,false)
        demon.attack = 0
        advance(run,1)
        verify(run.health < player)
        fuzzyCompare(demon.hp-healed,demon.maxHp*.12,1e-5)
    }

    function test_blackHolePulsesAndSplitKills() {
        const run = arena(26,"blackHole")
        run.weatherEffect = "clear"
        const focus = target(run,"humontafagus",700)
        const neighbour = target(run,"hosphoragus",820)
        const remote = target(run,"silophosus",820,"right")
        neighbour.lane = remote.lane = 320
        verify(Rules.shoot(run,[],"front"))
        compare(run.holes.length,0)
        Gear.current(run).recovery = 0
        verify(Rules.shoot(run,[focus.id],"front"))
        compare(run.holes.length,1)
        compare(run.holes[0].duration,3)
        advance(run,59)
        compare(neighbour.lane,320)
        for (let i = 0; i < 3; ++i) {
            const lane = neighbour.lane
            advance(run,i ? 60 : 1)
            verify(neighbour.lane < lane)
        }
        compare(remote.lane,320)
        compare(run.holes.length,0)

        for (const id of ["katana","darksaber","chainsaw"]) {
            const slash = arena(20,id)
            const foe = target(slash,"silophosus",260)
            foe.hp = 1
            Gear.current(slash).spin = 1
            verify(Rules.shoot(slash,[foe.id],"front"),id)
            compare(slash.splits.length,1,id)
            compare(slash.splits[0].blade,id)
            compare(slash.splits[0].type,foe.type)
            advance(slash,90)
            compare(slash.splits.length,0)
        }
    }

    function test_voidBossDarkFireAndHalfHealthStorm() {
        const run = arena(70)
        run.weatherEffect = "clear"
        const spec = Encounters.enemyTypes.voidGlitch
        compare(spec.title,"?!:!E#DR#FJD")
        compare(spec.crit,.50)
        compare(spec.dodge,2)
        const schedule = Rules.makeSchedule(run)
        compare(schedule[schedule.length-1].type,spec.id)
        compare(schedule[schedule.length-1].front,"down")
        const boss = target(run,spec.id,spec.distance,"down")
        boss.travelSpeed = spec.speed
        boss.attack = 999
        boss.sideIn = 0
        advance(run,255)
        verify(["left","right"].includes(boss.front))
        boss.sideIn = 999
        boss.depth = spec.reach
        boss.attack = 0
        advance(run,1)
        verify(run.bolts.some(function(bolt) { return bolt.voidShot && bolt.critChance === .50 && bolt.hp > 0 }))
        boss.attack = 999
        Rules.wound(run,boss,boss.maxHp*.51,"gun")
        verify(run.voidStorm)
        advance(run,648)
        const shade = run.enemies.find(function(enemy) { return enemy.type === "mystery" })
        verify(shade && shade.summoned && shade.parent === boss.id)
        compare(shade.front,boss.front)
        verify(run.voidStorm)
        Rules.wound(run,boss,9999,"gun")
        compare(run.voidStorm,false)
    }

    function test_fieldCapQueuesRegularAndSummonedEnemies() {
        const run = arena(10)
        const cap = Encounters.maxConcurrent(run.wave, run.difficulty)
        run.pending = Array.from({length:cap+3}, function() { return {at:0,type:"silophosus",front:"front",lane:0} })
        advance(run,1)
        compare(run.enemies.length,cap)
        compare(run.pending.length,3)
        Rules.summon(run,{type:"saslimigus",front:"right",lane:0,summoned:true})
        compare(run.reinforcements.length,1)
        advance(run,120)
        compare(run.reinforcements.length,1)
        Rules.wound(run,run.enemies[0],999,"gun")
        advance(run,1)
        compare(run.enemies.length,cap)
        compare(run.reinforcements.length,0)
        compare(run.pending.length,3)
        verify(run.enemies.some(function(enemy) { return enemy.type === "saslimigus" && enemy.summoned }))
        Rules.wound(run,run.enemies[0],999,"gun")
        advance(run,1)
        compare(run.pending.length,2)
        compare(run.enemies.length,cap)
    }

    function test_teleportKeepsFhantamegusInViewAndBossesReady() {
        const run = arena(8)
        const phantom = target(run,"fhantamegus",280)
        phantom.lane = 1300
        phantom.shiftIn = .001
        phantom.age = 1.2
        advance(run,60)
        verify(phantom.front !== "front")
        verify(Math.abs(phantom.lane) <= phantom.depth * .22)
        compare(phantom.warp,0)
        verify(Rules.lookFront(run,phantom.front))
        const before = phantom.hp
        verify(Rules.shoot(run,[phantom.id],phantom.front))
        verify(phantom.hp < before)
        for (const boss of Encounters.bosses.filter(function(id) { return id !== "reapfast" })) {
            const practice = arena(60)
            const spec = Encounters.enemyTypes[boss]
            if (boss === "hasasasa")
                Rules.lookFront(practice,"up")
            const opponent = Rules.spawn(practice,{type:boss,front:boss === "hasasasa" ? "up" : "front",lane:0})
            compare(opponent.attack,0)
            opponent.depth = spec.reach
            opponent.sideIn = 90
            opponent.warp = 0
            advance(practice,1)
            verify(opponent.attack > 0,boss)
            verify(opponent.attackFlash > 0,boss)
            opponent.hp = opponent.maxHp * .25
            compare(Rules.bossMovement(opponent),boss === "hasasasa" ? 1 : 1.43)
        }
    }

    function test_allHasasasaProjectilesAreDestructibleAndDistinct() {
        const run = arena(50,"rail")
        const ship = target(run,"hasasasa",1750,"up")
        Rules.lookFront(run,"up")
        const colors = new Set()
        for (const element of ["freeze","electric","burn","core"]) {
            for (const tube of ship.turrets)
                tube.hp = tube.element === element ? tube.maximum : 0
            Rules.fireShip(run,ship)
            const shots = run.bolts.slice()
            compare(shots.length,element === "core" ? 3 : 1)
            colors.add(shots[0].color)
            const hp = ship.hp
            for (const shot of shots) {
                verify(Rules.pickableBolt(shot,"up"))
                verify(Rules.projectilePoint(shot).depth < ship.depth - 110)
                const rail = Gear.current(run)
                rail.recovery = 0
                rail.ammo = 5
                verify(Rules.shoot(run,[shot.id],"up"))
                if (element === "core") {
                    verify(shot.hp > 0 && shot.hp < shot.maximum)
                    rail.recovery = 0
                    verify(Rules.shoot(run,[shot.id],"up"))
                }
                verify(!run.bolts.includes(shot))
            }
            compare(ship.hp,hp)
        }
        compare(colors.size,4)
        compare(run.metrics.intercepts,6)
    }

    function test_bladeTricksAndKatanaFinisher() {
        for (const id of ["nailclub","katana","mechasword","duoknives","darksaber","chainsaw","gravhammer","reaperscythe"]) {
            const run = arena(30,id)
            const weapon = Gear.current(run)
            const enemy = target(run,"stinkaturumus",1280)
            const hp = enemy.hp
            weapon.spin = 1
            verify(Rules.shoot(run,[enemy.id],"front"),id)
            compare(enemy.hp,hp)
            weapon.recovery = 0
            verify(Rules.reload(run),id)
            compare(weapon.ammo,0)
            verify(weapon.prep > 0 && !weapon.primed)
            advance(run,Math.ceil(weapon.prep*60)+2)
            verify(weapon.primed,id)
            weapon.spin = 1
            verify(Rules.shoot(run,[enemy.id],"front"))
            verify(!!run.lunge,id)
            compare(enemy.hp,hp)
            advance(run,21)
            verify(enemy.hp < hp,id)
            verify(Rules.lungeOffset(run).depth > 0)
            advance(run,23)
            verify(!run.lunge)
            verify(!weapon.primed)
            compare(run.gore[run.gore.length-1].style,id)
        }
        const run = arena(30,"katana")
        const sword = Gear.current(run)
        const enemy = target(run,"stinkaturumus",320)
        let first = 0
        for (let step=1; step<=3; step+=1) {
            const before = enemy.hp
            verify(Rules.shoot(run,[enemy.id],"front"))
            compare(sword.combo,step)
            if (step === 1)
                first = before - enemy.hp
            if (step === 3)
                verify(before - enemy.hp > first * 1.55)
            advance(run,29)
        }
        compare(run.metrics.katanaCombos,1)
        advance(run,42)
        verify(Rules.shoot(run,[enemy.id],"front"))
        compare(sword.combo,1)
        verify(Blades.pose("katana",.5,0,1,1).yaw !== Blades.pose("katana",.5,0,2,2).yaw)
        verify(Blades.pose("katana",.5,0,3,3).pitch < Blades.pose("katana",.5,0,1,1).pitch)
    }

    function test_axeAndContinuousWeapons() {
        const run = arena(30,"tomahawk")
        const enemy = target(run,"stinkaturumus",970)
        const before = enemy.hp
        verify(Rules.shoot(run,[enemy.id],"front",{x:.5,y:.5}))
        compare(run.axes.length,1)
        compare(enemy.hp,before)
        const start = Rules.axePoint(run.axes[0])
        advance(run,10)
        verify(Rules.axePoint(run.axes[0]).spin > start.spin)
        advance(run,26)
        verify(enemy.hp < before)
        verify(Gear.current(run).prep > 0)
        compare(run.metrics.axeHits,1)
        for (const id of ["solar","prism","furnacebeam","chainsaw"]) {
            const fight = arena(30,id)
            const gun = Gear.current(fight)
            const foe = target(fight,"stinkaturumus",350)
            const stats = Gear.weaponStats(gun)
            if (id === "chainsaw") {
                verify(!Rules.shoot(fight,[foe.id],"front"))
                advance(fight,48,true)
            }
            verify(Rules.shoot(fight,[foe.id],"front"),id)
            compare(gun.ammo,0)
            if (id === "furnacebeam")
                compare(foe.elements.burn,2)
            for (let i=0; !gun.cool && i<270; i+=1)
                advance(fight,1,true)
            verify(gun.cool > 0 && !gun.firing,id)
            verify(!Rules.shoot(fight,[foe.id],"front"))
            advance(fight,Math.ceil((stats.cooling + stats.spinup)*60)+4,true)
            verify(Rules.shoot(fight,[foe.id],"front"),id)
        }
    }

    function test_stavesChargeThenCastAndWindHasThreeRanks() {
        for (const id of Object.keys(Arsenal.weapons).filter(function(key) { return !!Arsenal.weapons[key].staff })) {
            const run = arena(30,id)
            const gear = Gear.current(run)
            const enemy = target(run,"stinkaturumus",600)
            const cost = Gear.weaponStats(gear).chargeCost
            verify(!Rules.reload(run,[enemy.id],"front"),id)
            for (let i=0; i<cost; i+=1) {
                gear.recovery = 0
                verify(Rules.shoot(run,[enemy.id],"front"),id)
            }
            compare(gear.charge,cost)
            compare(gear.ammo,0)
            verify(Rules.reload(run,[enemy.id],"front",{x:.5,y:.5}),id)
            compare(run.grenades.length,1)
            compare(run.metrics.staffCasts,1)
            compare(gear.charge,0)
            const before = enemy.hp
            advance(run,40)
            verify(enemy.hp < before,id)
        }
        const run = arena(18)
        const enemy = target(run,"hosphoragus",550)
        Rules.applyToEnemy(run,enemy,"wind",1)
        compare(enemy.depth,660)
        Rules.applyToEnemy(run,enemy,"wind",2)
        compare(enemy.depth,850)
        Rules.applyToEnemy(run,enemy,"wind",3)
        compare(enemy.depth,1120)
    }

    function test_burstStreakAndStarDeathLevels() {
        for (const id of ["arc","razor","kestrel"]) {
            const run = arena(30,id)
            const enemy = target(run,"stinkaturumus",440)
            const gun = Gear.current(run)
            const ammo = gun.ammo
            verify(Rules.shoot(run,[enemy.id],"front"))
            compare(gun.ammo,ammo-1)
            verify(!Rules.queuedShot(run))
            for (let i=0; i<2; i+=1) {
                advance(run,6)
                verify(Rules.queuedShot(run))
                verify(Rules.shoot(run,[enemy.id],"front",null,true))
            }
            compare(gun.ammo,ammo-3)
            verify(!Rules.queuedShot(run))
        }

        const run = arena(30,"deadeye")
        run.criticalSeed = 0
        const enemy = target(run,"stinkaturumus",440)
        const gun = Gear.current(run)
        const initial = enemy.hp
        verify(Rules.shoot(run,[enemy.id],"front"))
        compare(gun.streak,1)
        const simple = initial-enemy.hp
        const before = enemy.hp
        gun.recovery = 0
        verify(Rules.shoot(run,[enemy.id],"front"))
        compare(before-enemy.hp,simple*1.12)
        gun.recovery = 0
        jsCoin(run, "front", false)
        verify(Rules.shoot(run,[run.gifts[0].id],"front"))
        compare(gun.streak,3)
        gun.recovery = 0
        verify(Rules.shoot(run,[0],"front"))
        compare(gun.streak,0)

        for (const level of [0,2,3]) {
            const fight = arena(30,"starDestroyer")
            const silo = target(fight,"silophosus",430)
            const star = Gear.current(fight)
            star.level = level
            star.spin = 1
            verify(Rules.shoot(fight,[silo.id],"front"))
            compare(fight.detonations[0].level, level || 1)
        }
    }

    function jsCoin(run, front, token) {
        const gift = {id:run.nextId++,front:front,lane:0,depth:880,remaining:8,kind:"gold",token:!!token}
        run.gifts.push(gift)
        return gift
    }

    function test_dodgeBayonetGuardAndCoinPassives() {
        const run = arena(30)
        const enemy = target(run,"hosphoragus",322)
        run.slots.active[0].item = Gear.makeItem("sidestep")
        const hp = run.health
        verify(Rules.useAbility(run,0,"front",enemy.id))
        Rules.damagePlayer(run,10,"front",enemy.type)
        compare(run.health,hp)
        Rules.damagePlayer(run,10,"front",enemy.type)
        compare(run.health,hp-10)
        run.slots.passive[0].item = Gear.makeItem("slipstream")
        Rules.lookFront(run,"right")
        Rules.damagePlayer(run,10,"right","spartalien",false,undefined,true)
        compare(run.health,hp-10)
        compare(run.metrics.dodges,2)
        Rules.lookFront(run,"front")
        run.slots.passive[1].item = Gear.makeItem("bayonet")
        Gear.current(run).ammo = 0
        const before = enemy.hp
        verify(Rules.reload(run,[enemy.id],"front"))
        compare(before-enemy.hp,6)
        verify(!Rules.reload(run,[enemy.id],"front"))
        run.slots.passive[0].item = Gear.makeItem("orbitWard")
        const guard = Rules.orbitGuard(run)
        const health = run.health
        Rules.damagePlayer(run,10,"front",enemy.type,false,{ lane:(guard.x-.5)*450*run.aspect*1.0634,depth:450 })
        compare(health-run.health,7)
        verify(run.guardFlash > 0)
        const unguarded = run.health
        Rules.damagePlayer(run,10,"front",enemy.type,false,{lane:850,depth:350})
        compare(unguarded-run.health,10)
        const fresh = arena(35,"deadeye")
        target(fresh,"hosphoragus",740)
        target(fresh,"battlestar",1290,"up")
        for (let i=0; i<10; i+=1)
            Rules.claimGift(fresh,jsCoin(fresh,"front",true))
        compare(fresh.kills,2)
        compare(fresh.deathCoins,0)
    }

    function test_demonicTridentShootsAndThrusts() {
        const run = arena(38,"helltrident")
        run.criticalSeed = 0
        const far = target(run,"skarabatunus",870)
        const hp = far.hp
        verify(Rules.shoot(run,[far.id],"front"))
        verify(far.hp < hp)
        compare(far.elements.burn,2)
        const spear = Gear.current(run)
        spear.recovery = 0
        const near = target(run,"hosphoragus",350)
        const nearHp = near.hp
        verify(Rules.reload(run,[near.id],"front"))
        compare(nearHp - near.hp,Gear.weapons.helltrident.stab.damage)
        compare(near.elements.burn,2)
        verify(!Rules.reload(run,[near.id],"front"))
        compare(spear.ammo,0)
        for (let i=0; i<3; i+=1)
            Rules.wound(run,target(run,"lucifoverus",370),999,"gun")
        compare(run.metrics.lucifoverusKills,3)
    }

    function test_battlestarAndSkarabatunusBeams() {
        const run = arena(46)
        const ship = target(run,"battlestar",1180,"up")
        const height = Rules.elevation(ship)
        ship.attack = 0
        advance(run,1)
        verify(ship.beamWarning > 0)
        advance(run,104)
        verify(ship.beamLeft > 0)
        verify(Rules.elevation(ship) !== height)
        compare(run.health,Gear.startingHealth)
        Rules.lookFront(run,"up")
        advance(run,42)
        verify(run.health < Gear.startingHealth)
        advance(run,100)
        compare(ship.beamLeft,0)
        verify(ship.attack > 0)

        const arena2 = arena(46)
        const skull = target(arena2,"skarabatunus",1120)
        arena2.gold = 100
        skull.travelSpeed = 145
        skull.goldAttackAt = arena2.time
        advance(arena2,1)
        verify(skull.beamWarning > 0)
        const distance = skull.depth
        advance(arena2,43)
        compare(skull.depth,distance)
        advance(arena2,8)
        verify(skull.stolenGold > 0)
        compare(arena2.gold,100-skull.stolenGold)
        const remaining = arena2.gold
        Rules.wound(arena2,skull,999,"gun")
        compare(arena2.gold,remaining + Math.round(20*2.8) + Math.floor(skull.stolenGold*.60))
        verify(arena2.gore.some(function(event) { return event.fatal && event.span >= 1 && event.span < 1.5 }))
        compare(Encounters.tier("skarabatunus"),"Nightmare")
        compare(Encounters.tier("hasasasa"),"Overlord")
        compare(Encounters.tier("iceterapus"),"Ascended")
        compare(Encounters.tierColors.Ascended,"#f46773")
        const regular = Object.keys(Encounters.enemyTypes).filter(function(id) { return Encounters.tier(id) !== "Overlord" })
        const normal = regular.filter(function(id) { return Encounters.tier(id) === "Normal" })
        compare(normal.length,11)
        verify(normal.filter(function(id) { return Encounters.firstWave(id) <= 21 }).length >= 9)
        verify(Pets.attackPose("chicken",.23)[0] > Pets.attackPose("crow",.23)[0])
    }
}
