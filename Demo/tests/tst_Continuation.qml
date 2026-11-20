import QtQuick
import QtTest
import "../game/Rules.js" as Rules
import "../game/Tutorial.js" as Tutorial
import "../game/Loadout.js" as Gear
import "../game/Elements.js" as Elements
import "../game/Progress.js" as Progress
import "../game/Encounters.js" as Encounters

TestCase {
    name:"CampaignAndTutorial"
    function arena(wave) {
        const run=Rules.create(711,Progress.unlocked({},true))
        run.wave=wave-1;run.petChoice="";Rules.startWave(run)
        run.pending=[{at:900,type:"silophosus",front:"front",lane:0}];run.pet=null;run.weatherEffect="clear"
        return run
    }
    function foe(run,type) {
        const enemy=Rules.spawn(run,{type:type,front:"front",lane:0})
        enemy.warp=0;enemy.depth=enemy.type==="hallucination" ? 900 : 600;enemy.attack=500
        enemy.hp=enemy.maxHp=enemy.baseHp=500
        return enemy
    }
    function advance(run,seconds) {for(let i=0;i<Math.ceil(seconds*60);i++) Tutorial.update(run,1/60,false,false,null,true)}
    function active(run,id) {run.slots.active[0].item={id:id,level:0};run.cooldowns[id]=0;return Rules.useAbility(run,0,"front",run.enemies[0]?.id || 0,{x:.5,y:.5})}
    function test_campaignActivesHaveIndependentCooldownAndVisibleFeedback() {
        const run=arena(25);foe(run,"hosphoragus")
        for(const id of ["openingSalvo","lateBloom","breachOrder","emberPulse","draftCircle","yellowNoon","staticLatch","borrowedBeat","fieldLesson"]) {
            verify(active(run,id),id)
            verify(run.cooldowns[id]>0,id)
            compare(run.abilityEvents[run.abilityEvents.length-1].ability,id)
        }
        verify(run.salvoTime>0)
        verify(run.enemies[0].hp<500)
        verify(run.abilityEvents.length<=4)
    }
    function test_campaignThresholdsAndPoisonRecovery() {
        const run=arena(19);run.slots.passive[0].item={id:"closingShift",level:0}
        const early=Rules.outgoing(run);run.wave=21;verify(Rules.outgoing(run)>early)
        run.slots.passive[0].item={id:"cleanLungs",level:0};run.health=100
        const enemy=foe(run,"silophosus");Rules.applyToEnemy(run,enemy,"poison",1)
        Rules.wound(run,enemy,1000,"gun")
        verify(run.health>100)
    }
    function test_sprayIsPoisonousAndFreezingPausesIt() {
        const run=arena(47),enemy=foe(run,"papapoganus")
        enemy.attack=0
        advance(run,.6)
        verify(run.sprayTime>0)
        verify(run.elements.poison>0)
        compare(run.elements.poison,2)
        enemy.elements.frozen=2
        const hp=run.health;advance(run,.5)
        compare(run.health,hp)
        Rules.wound(run,enemy,1000,"gun")
        compare(run.metrics.papapoganusKills,1)
    }
    function test_hallucinationsStayVisibleAndRecoverAStaleLock() {
        const run=arena(40),enemy=foe(run,"lantis")
        run.playerFront="down";enemy.front="down"
        Rules.hypnotise(run,enemy)
        const ghosts=run.enemies.filter(function(e){return e.type==="hallucination"})
        verify(ghosts.length>=6 && ghosts.length<=8)
        const lanes=new Set(ghosts.map(function(e){return Math.round(Rules.lanePosition(e))}))
        verify(lanes.size>=5)
        advance(run,20)
        for(const ghost of ghosts) verify(ghost.depth>=720)
        run.enemies=run.enemies.filter(function(e){return e.type!=="hallucination"});advance(run,.1)
        compare(run.hypnosis,null)
    }
    function test_cpuHeatNeverWritesHardwareAndRequiresCooling() {
        const run=arena(2),enemy=foe(run,"hosphoragus")
        run.desktop={cpuMode:true,cpu:0,heat:96,locked:false,pressure:0}
        verify(Rules.shoot(run,[enemy.id],"front"))
        compare(run.desktop.heat,100);verify(run.desktop.locked)
        Gear.current(run).recovery=0
        verify(!Rules.shoot(run,[enemy.id],"front"))
        advance(run,3)
        verify(!run.desktop.locked)
        verify(run.desktop.heat<45)
    }
    function test_tutorialLessonsRewindAndCompleteBothPhases() {
        const run=Tutorial.create(87,[])
        const initialTime=run.time;advance(run,1);compare(run.time,initialTime)
        Tutorial.advance(run)
        for(let i=0;i<3;i++){verify(Rules.shoot(run,[run.training.bossId],"front"));advance(run,.4)}
        compare(run.training.step,1);compare(run.training.mode,"dialogue")
        Tutorial.advance(run);verify(Rules.reload(run));advance(run,1.4)
        compare(run.training.step,2)
        Tutorial.advance(run);advance(run,2.4)
        compare(run.training.mode,"rewind")
        advance(run,1.2);compare(run.training.mode,"lesson");compare(run.training.step,2)
        advance(run,Math.max(0,1.8-run.training.age));Rules.holdShield(run,true);advance(run,.7)
        compare(run.training.step,3)
        Tutorial.advance(run);Rules.holdShield(run,true);advance(run,2.6)
        compare(run.training.step,4)
        Tutorial.advance(run)
        advance(run,2.04)
        Rules.holdShield(run,true)
        advance(run,.18)
        compare(run.training.step,5)
        Rules.holdShield(run,false)
        verify(run.shield.cool<4.5)
        Tutorial.advance(run)
        advance(run,3.7)
        compare(run.training.step,6)
        for(let i=6;i<=8;i++) {
            Tutorial.advance(run)
            const peon=run.enemies.find(function(e){return e.trainingPeon})
            run.playerFront=peon.front
            for(let shot=0;shot<3 && peon.hp>0;shot++) {verify(Rules.shoot(run,[peon.id],peon.front));advance(run,.3)}
            verify(peon.hp<=0)
        }
        compare(run.training.mode,"phase1");compare(Tutorial.boss(run).hp,60)
        Rules.wound(run,Tutorial.boss(run),40,"gun","",0,{critical:2});compare(run.training.mode,"molt")
        advance(run,6.1);compare(run.training.mode,"activeDialogue")
        Tutorial.advance(run);verify(Rules.useAbility(run,0,"front",run.training.bossId));advance(run,.1)
        compare(run.training.mode,"encouragement")
        Tutorial.advance(run);compare(run.training.mode,"phase2")
        Rules.wound(run,Tutorial.boss(run),1000,"gun")
        compare(run.training.mode,"won");compare(run.metrics.trainingWins,1)
    }
    function test_shotgunKitsRewardOnlyCloseTargets() {
        for (const id of ["rimeBell","furnaceDoor"]) {
            const run=arena(25)
            run.slots.weapon[0].item=Gear.makeItem(id)
            const target=foe(run,"hosphoragus")
            target.depth=310
            verify(Rules.shoot(run,[target.id,target.id,target.id,target.id],"front"))
            if (id==="rimeBell") verify(target.elements.frozen>0)
            else verify(target.elements.explosive>0)
            const far=foe(run,"hosphoragus")
            far.depth=1150
            const farHp=far.hp
            verify(active(run,id==="rimeBell" ? "doorstop" : "kilnRing"))
            compare(far.hp,farHp)
            if (id==="rimeBell") verify(target.depth>310)
            else verify(target.elements.burn>0)
        }
    }

    function test_newCataloguesHaveCompleteKitsAndWorkingMenuStats() {
        for(const id of ["rimeBell","furnaceDoor","twinSmgs","twinShotguns","siegeRpg","cinderTwig","draughtStick","pollenRod","staticFork","hourhand","graduate"]) {
            verify(Gear.kits.some(function(kit){return kit.weapon===id}))
            const text=Gear.itemDetails(null,"weapon",{id:id,level:3})
            verify(text.includes("Upgrade 3 / 3"));verify(!text.includes("NaN"));verify(!text.includes("undefined"))
        }
        compare(Gear.weaponClass(Gear.weapons.helltrident),"Staffs")
        compare(Rules.roman(49),"XLIX")
    }
}
