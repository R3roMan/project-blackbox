import QtQuick
import QtTest
import "../game/Rules.js" as Rules
import "../game/Encounters.js" as Encounters
import "../game/Loadout.js" as Gear
import "../game/SaveData.js" as Saves
import "../game/Conditions.js" as Conditions

TestCase {
    name: "BloodMoonAndVoid"

    function runAt(wave, bloodMoon) {
        const run=Rules.create(489214)
        verify(Rules.configure(run,"normal",wave))
        verify(Rules.setPracticeWeather(run,bloodMoon))
        verify(Rules.startWave(run))
        run.weatherEffect="clear"
        return run
    }

    function materialize(run,type,front) {
        const actor=Rules.spawn(run,{type:type,front:front || "front",lane:0})
        actor.warp=0
        actor.travelSpeed=0
        actor.attack=999
        return actor
    }

    function test_seededWeatherAndLateGuest() {
        const events={normal:0,hard:0,insane:0}
        let nights=0, redNights=0
        for (const difficulty of Object.keys(events)) {
            for (let seed=1;seed<=240;seed++) {
                for (let wave=5;wave<=60;wave++) {
                    const condition=Encounters.stageWeather(wave,seed*37813,difficulty)
                    if (condition!=="clear") events[difficulty]++
                    const sky=Conditions.waveSky(wave,seed*37813)
                    if (Conditions.isNight(sky)) {
                        compare(wave%4,3)
                        nights++
                        if (sky==="bloodMoon") redNights++
                    }
                }
            }
        }
        verify(events.normal < events.hard && events.hard < events.insane)
        verify(redNights/nights>.04 && redNights/nights<.06)
        for (const wave of [5,10,21,40,80]) {
            const wavePlan=Encounters.planWave(wave,7632,"normal","","bloodMoon")
            const guest=wavePlan.schedule.filter(function(entry) { return entry.type==="blandromedus" })
            compare(guest.length,1)
            compare(guest[0].units,1)
            verify(wavePlan.schedule.indexOf(guest[0])>=Math.floor(wavePlan.schedule.length*.7))
            compare(wavePlan.schedule.reduce(function(count,entry) { return count+entry.units },0),wavePlan.enemyCount)
            if (Encounters.boss(wave)) compare(wavePlan.schedule[wavePlan.schedule.length-1].type,Encounters.boss(wave))
        }
    }

    function test_redNightStatsAndVampirism() {
        const red=runAt(10,true), clear=runAt(10,false)
        compare(red.metrics.bloodMoonNights,1)
        compare(Rules.blindRank(red),2)
        const ordinary=Rules.spawn(clear,{type:"silophosus",front:"front",lane:0})
        const enhanced=Rules.spawn(red,{type:"silophosus",front:"front",lane:0})
        fuzzyCompare(enhanced.damage,ordinary.damage*1.15,1e-6)
        fuzzyCompare(enhanced.travelSpeed,ordinary.travelSpeed*1.2,1e-6)
        fuzzyCompare(enhanced.attack,ordinary.attack/1.1,1e-6)
        compare(Encounters.enemyTypes.nightosphere.crit,.15)
        const vampire=materialize(red,"blandromedus")
        vampire.hp*=.5
        const before=vampire.hp
        const bloodBolt={drain:true,sourceId:vampire.id,critical:false,element:"weaken",elementLevel:3}
        Rules.holdShield(red,true)
        Rules.damagePlayer(red,vampire.damage,"front",vampire.type,false,bloodBolt,true)
        compare(vampire.hp,before)
        Rules.holdShield(red,false)
        Rules.damagePlayer(red,vampire.damage,"front",vampire.type,false,bloodBolt,true)
        fuzzyCompare(vampire.hp,before+vampire.maxHp*.045,1e-6)
        compare(red.elements.weaken,3)
        const fragile=materialize(red,"silophosus")
        fragile.hp=1
        const hp=red.health
        const gold=red.gold
        Rules.wound(red,fragile,100,"gun","",0,{weaponId:"veinDrinker"})
        fuzzyCompare(red.health,hp+.16,1e-6)
        compare(red.gold-gold,Math.round(Rules.goldPerKill(10)*1.25))
    }

    function test_voidSlotsAndStatueQueue() {
        const run=runAt(40,false)
        verify(Rules.summon(run,{type:"crawler",front:"down",lane:0}))
        verify(Rules.summon(run,{type:"faeel",front:"down",lane:40}))
        compare(run.enemies.length,2)
        compare(run.reinforcements.length,0)
        run.enemies=[]
        run.reinforcements=[]
        const statue=materialize(run,"jos")
        run.pending=[{type:"crawler",at:1000,front:"down",lane:0}]
        for (let i=0;i<66;i++) Rules.update(run,1/60,0,false)
        compare(statue.crumble,0)
        run.pending=[]
        for (let i=0;i<66;i++) Rules.update(run,1/60,0,false)
        compare(run.enemies.length,0)
        for (let i=0;i<180 && run.phase==="combat";i++) Rules.update(run,1/60,0,false)
        compare(run.phase,"bossReward")
    }

    function test_checkpointFallback() {
        const run=runAt(20,true)
        run.slots.weapon[0].item=Gear.makeItem("veinDrinker")
        const backup=Saves.encodeRun(run)
        compare(Saves.savedChoice("broken",backup,[]).wave,20)
        verify(Saves.savedChoice("broken",backup,[]).restored)
        compare(Saves.savedChoice("broken","also broken",[]),null)
    }
}
