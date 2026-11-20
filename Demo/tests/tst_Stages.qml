import QtQuick
import QtTest
import "../game/Rules.js" as Rules
import "../game/Loadout.js" as Gear
import "../game/Encounters.js" as Encounters
import "../game/Elements.js" as Elements
import "../game/MusterData.js" as Muster

TestCase {
    name:"StagesAndSouls"

    function fight(wave) {
        const run=Rules.create(81637)
        run.wave=wave-1
        run.petChoice=""
        verify(Rules.startWave(run))
        run.weatherEffect="clear"
        run.pending=[{at:900,type:"silophosus",front:"front",lane:0}]
        return run
    }
    function enemy(run,type,depth) {
        const foe=Rules.spawn(run,{type:type,front:"front",lane:0})
        foe.warp=0
        foe.travelSpeed=0
        foe.depth=depth || Rules.enemyTypes[type].reach
        foe.attack=999
        return foe
    }
    function tick(run,seconds) {
        for (let i=0; i<Math.ceil(seconds*60); ++i)
            Rules.update(run,1/60,0,false)
    }

    function test_rosterAndThreatQuotasStayFixed() {
        for (const mode of ["normal","hard","insane"]) {
            for (let wave=1; wave<=150; ++wave) {
                const budget=Encounters.waveBudget(wave,mode)
                for (const seed of [91,876,62817]) {
                    const plan=Encounters.planWave(wave,seed,mode)
                    compare(plan.enemyCount,Rules.waveSize(wave,mode))
                    if (plan.night==="bloodMoon") {
                        // An early event can use an ordinary slot for its
                        // guaranteed Nightmare encounter.
                        verify(plan.ranks.Nightmare>=budget.ranks.Nightmare
                            && plan.ranks.Nightmare<=budget.ranks.Nightmare+1)
                    } else compare(plan.ranks,budget.ranks)
                    compare(plan.groups.reduce(function(sum,row) {return sum+row.count},0),plan.enemyCount)
                    compare(plan.schedule.reduce(function(sum,row) {return sum+row.units},0),plan.enemyCount)
                    compare(new Set(plan.groups.map(function(row) {return row.type})).size,plan.variety)
                    verify(plan.schedule.every(function(row) {return Encounters.firstWave(row.type) <= wave}))
                    if (Rules.isBossWave(wave))
                        compare(plan.schedule[plan.schedule.length-1].type,Rules.bossType(wave))
                }
                if (wave%10 === 1 && wave>10)
                    verify(Rules.waveSize(wave,mode)<Rules.waveSize(wave-1,mode))
            }
        }
        for (const wave of [8,19,44,80]) {
            const easy=Encounters.waveBudget(wave,"normal")
            const hard=Encounters.waveBudget(wave,"hard")
            const insane=Encounters.waveBudget(wave,"insane")
            verify(easy.total<hard.total && hard.total<insane.total)
            verify(easy.gap>hard.gap && hard.gap>insane.gap)
        }
    }

    function test_previewOwnsTheCombatRoster() {
        const run=Rules.create(91416)
        verify(Rules.configure(run,"hard",50,"random"))
        const stage=Rules.prepareStage(run)
        const promised=JSON.stringify(stage.schedule)
        const rng=run.rng
        for (let i=0; i<6; ++i)
            compare(Rules.prepareStage(run),stage)
        compare(run.rng,rng)
        verify(Rules.refresh(run))
        compare(JSON.stringify(Rules.prepareStage(run).schedule),promised)
        verify(Rules.startWave(run))
        compare(JSON.stringify(run.pending),promised)
        compare(run.waveSize,stage.enemyCount)
        compare(run.weatherEffect,stage.weather)
        run.pending.shift()
        compare(JSON.stringify(stage.schedule),promised)
        run.phase="between"
        const next=Rules.prepareStage(run)
        compare(next.wave,51)
        const fixed=JSON.stringify(next)
        Gear.swap(run,"passive",0,1)
        compare(JSON.stringify(Rules.prepareStage(run)),fixed)
        const fresh=Rules.create(91416)
        Rules.configure(fresh,"hard",50)
        compare(JSON.stringify(fresh.nextStage.schedule),promised)
        Rules.configure(fresh,"insane",50)
        verify(JSON.stringify(fresh.nextStage.schedule)!==promised)
    }

    function test_knownEnemyHoverAndBossSecrecy() {
        const group={type:"harvester",count:2}
        const unknown=Muster.tooltip(group,[])
        verify(unknown.startsWith("Unknown"))
        verify(unknown.includes("Void") && unknown.includes("Nightmare"))
        verify(!unknown.includes("×2"))
        verify(!unknown.includes("soul"))
        const known=Muster.tooltip(group,["harvester"])
        verify(known.startsWith("Harvester") && known.includes("soul"))
        verify(Muster.tooltip({type:"humontafagus",count:1},[]).startsWith("Unknown"))
        verify(Muster.tooltip({type:"hasasasa",count:1},["hasasasa"]).includes("Space"))
        verify(Muster.tooltip({type:"crufixicatus",count:1},["crufixicatus"]).includes("Hellborne"))
        verify(Object.values(Rules.enemyTypes).every(function(spec) {return spec.description.length<115}))
    }

    function test_harvesterDrainsReturnsAndRespectsPush() {
        const run=fight(44)
        const harvester=enemy(run,"harvester",1040)
        const hp=run.health
        tick(run,1.25)
        compare(run.health,hp)
        tick(run,2)
        verify(harvester.soulChannel && run.health<hp)
        fuzzyCompare(harvester.stolenHealth,hp-run.health,1e-5)
        Rules.applyKnockback(run,harvester,1)
        verify(harvester.depth>1050 && !harvester.soulChannel)
        const hurt=run.health
        tick(run,1)
        compare(run.health,hurt)
        harvester.depth=1050
        tick(run,1.7)
        verify(harvester.soulChannel && run.health<hurt)
        const debt=harvester.stolenHealth
        const before=run.health
        Rules.wound(run,harvester,1000,"gun")
        fuzzyCompare(run.health,before+debt,1e-5)
        compare(run.health,hp)
        compare(run.soulReturns.length,1)
        tick(run,2.6)
        compare(run.soulReturns.length,0)
    }

    function test_knockbackStopsReadyMeleeAndBeams() {
        const run=fight(43)
        const brute=enemy(run,"hosphoragus",320)
        brute.attack=.02
        brute.attackFlash=.27
        const life=run.health
        Rules.applyKnockback(run,brute,1)
        verify(brute.depth>320 && brute.attack>=Rules.enemyTypes.hosphoragus.windup)
        compare(brute.attackFlash,0)
        tick(run,.1)
        compare(run.health,life)
        const laser=enemy(run,"battlestar",1170)
        laser.beamLeft=2.5
        Rules.applyKnockback(run,laser,1)
        compare(laser.beamLeft,0)
    }

    function test_explodersResistBlastAndStatus() {
        const run=fight(36)
        for (const id of ["princoratus","seraphijus","meteor"]) {
            const foe=enemy(run,id,900)
            verify(Rules.statusImmune(foe,"explosive"))
            const hp=foe.hp
            Rules.wound(run,foe,25,"explosion")
            compare(foe.hp,hp)
            Rules.wound(run,foe,25,"hostileBlast")
            compare(foe.hp,hp)
            Rules.wound(run,foe,2,"gun","explosive",3)
            fuzzyCompare(hp-foe.hp,1.7,1e-5)
            compare(foe.elements.explosive,id==="princoratus" ? 2 : 0)
            verify(foe.hp>0)
        }
    }

    function test_crufixicatusScaresOnlyOnItsFirstLandedHit() {
        const run=fight(67)
        const demon=enemy(run,"crufixicatus",280)
        verify(Rules.statusImmune(demon,"blind"))
        Rules.holdShield(run,true)
        Rules.strike(run,demon,Rules.enemyTypes.crufixicatus)
        compare(run.scareTime,0)
        Rules.holdShield(run,false)
        Rules.strike(run,demon,Rules.enemyTypes.crufixicatus)
        compare(run.scareTime,3)
        verify(demon.scareUsed && !Rules.canAct(run) && !Rules.canTurn(run))
        const clock=run.waveTime
        const hp=run.health
        tick(run,2.98)
        compare(run.health,hp)
        compare(run.waveTime,clock)
        verify(run.scareTime>0)
        tick(run,.04)
        compare(run.scareTime,0)
        verify(Rules.canAct(run) && Rules.canTurn(run))
        Rules.strike(run,demon,Rules.enemyTypes.crufixicatus)
        compare(run.scareTime,0)
    }
}
