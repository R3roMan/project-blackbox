import QtQuick
import QtTest
import "../game/Rules.js" as Rules
import "../game/Loadout.js" as Gear
import "../game/Progress.js" as Progress
import "../game/SaveData.js" as Saves
import "../game/Encounters.js" as Mission
import "../game/Optics.js" as Optics

TestCase {
    name:"SavedRunsAndMilestones"

    function arena() {
        const run=Rules.create(1267,Progress.unlocked({},true))
        verify(Rules.startWave(run))
        run.pending=[{at:900,type:"silophosus",front:"front",lane:0}]
        run.pet=null
        run.weatherEffect="clear"
        return run
    }

    function test_replacementsPreserveDisplacedGearWhenSpaceExists() {
        const run=Rules.create(51)
        const old=run.slots.weapon[0].item
        old.level=3
        old.ammo=2
        verify(Gear.equip(run,Gear.weapons.rail,0))
        compare(run.inventory[0].item,old)
        compare(run.inventory[0].item.level,3)
        compare(run.slots.weapon[0].item.id,"rail")
        verify(Gear.equip(run,Gear.weapons.rail,0))
        compare(run.slots.weapon[0].item.level,1)
        compare(run.inventory.filter(function(entry) {return entry!==null}).length,1)
        run.inventory=Array(5).fill(null).map(function() {return {group:"active",item:Gear.makeItem("frag")}})
        verify(Gear.equip(run,Gear.weapons.carbine,0))
        compare(run.inventory.length,5)
        verify(!run.inventory.some(function(entry) {return entry.item.id==="rail"}))
    }

    function test_singleRunRoundTripKeepsTheBattleAndBuild() {
        const run=arena()
        run.wave=44
        run.gold=3571
        run.boons.health=125
        run.health=282
        run.cooldowns.frag=18.5
        run.metrics.enemyKills_harvester=3
        run.slots.active[0].item=Gear.makeItem("frag")
        run.slots.weapon[0].power="ballistics"
        run.slots.weapon[0].powerLevel=2
        run.inventory[0]={group:"weapon",item:Gear.makeItem("rail")}
        run.inventory[0].item.level=2
        const enemy=Rules.spawn(run,{type:"harvester",front:"down",lane:20})
        enemy.warp=0
        enemy.stolenHealth=13
        run.playerFront="down"
        const snapshot=Saves.encodeRun(run)
        const restored=Saves.decodeRun(snapshot,run.unlocks)
        verify(restored!==null)
        compare(restored.health,282)
        compare(restored.wave,44)
        compare(restored.gold,3571)
        compare(restored.rng,run.rng)
        compare(restored.playerFront,"down")
        compare(restored.metrics,run.metrics)
        compare(restored.cooldowns.frag,18.5)
        compare(restored.slots,run.slots)
        compare(restored.inventory,run.inventory)
        compare(restored.enemies[0].stolenHealth,13)
        compare(restored.pending,run.pending)
        compare(restored.shield.raised,false)
        for (const phase of ["ready","between","reward","bossReward","shop"]) {
            run.phase=phase
            verify(Saves.decodeRun(Saves.encodeRun(run),run.unlocks)!==null,phase)
        }
    }

    function test_corruptAndExecutableShapedImportsAreRejected() {
        const run=arena()
        const text=Saves.encodeRun(run)
        const data=JSON.parse(text)
        data.run.slots.weapon[0].item.level=99
        compare(Saves.decodeRun(JSON.stringify(data),[]),null)
        data.run.slots.weapon[0].item.level=0
        data.run.cooldowns.frag="bad"
        compare(Saves.decodeRun(JSON.stringify(data),[]),null)
        compare(Saves.decodeRun("{bad",[]),null)
        compare(Saves.parse('{"__proto__":{"polluted":true}}'),null)
        compare(Saves.parse('{"callback":"x","number":1e309}'),null)
        run.phase="defeat"
        compare(Saves.encodeRun(run),"")
    }

    function test_completeProgressBackupRoundTrip() {
        const display={backgroundFiles:{front:"file:///tmp/blackbox-shrine.webp"},frameLimit:60,showTimer:false,
            framing:"fill",quality:1440,zoom:1.1,mouseTurns:true,wheelSwitch:false,showEnemyPreview:false,controlBindings:'{"reload":{"key":76,"mods":0}}',detail:2,transitionStyle:"cinematic",transitionStrength:1.2,
            hudScale:1.15,textScale:1.3,autoSave:false,audioMaster:.75,audioMusic:.55,audioEffects:.9,audioAmbience:.4,audioInterface:.7}
        const profile={kills:20,bestWave:10,enemyKills_silophosus:11,weaponKills_pistol:12}
        const discoveries={enemies:["harvester"],abilities:["frag","ballistics"]}
        const save=Saves.encodeRun(arena())
        const text=Saves.bundle(profile,discoveries,true,display,true,false,save)
        const result=Saves.decodeBundle(text)
        verify(result!==null)
        compare(result.profile,profile)
        compare(result.discoveries,discoveries)
        compare(result.runSave,save)
        compare(result.display,display)
        result.display.zoom=9
        compare(Saves.decodeBundle(JSON.stringify(result)),null)
        compare(Saves.decodeBundle('{"format":"other"}'),null)
    }

    function test_paidCoinsAndFallbackBullets() {
        const run=arena()
        run.slots.weapon[0].item=Gear.makeItem("kingsRansom")
        run.gold=4
        run.criticalSeed=1
        const demon=Rules.spawn(run,{type:"hosphoragus",front:"front",lane:0})
        demon.warp=0
        demon.hp=demon.maxHp=1000
        demon.depth=800
        const hp=demon.hp
        verify(Rules.shoot(run,[demon.id],"front"))
        compare(run.gold,0)
        compare(run.metrics.bestRunSpent,4)
        verify(Gear.current(run).coinShot)
        const paid=hp-demon.hp
        Gear.current(run).recovery=0
        verify(Rules.shoot(run,[demon.id],"front"))
        verify(!Gear.current(run).coinShot)
        verify(paid>(hp-paid-demon.hp)*3)
        compare(demon.hitStop,.2)
    }

    function test_baseParryAndNormalTuning() {
        const run=arena()
        verify(Rules.raiseShield(run))
        const hp=run.health
        Rules.damagePlayer(run,12,"front","silophosus",false,{critical:false})
        compare(run.health,hp)
        compare(Rules.shieldCharge(run),1)
        compare(run.metrics.parries,1)
        verify(Mission.difficulties.normal.scale<.25)
        verify(Mission.difficulties.hard.scale>Mission.difficulties.normal.scale)
        compare(Object.keys(Optics.sights).length,17)
        verify(Optics.optic(Gear.weapons.kingsRansom).style==="ledger")
    }

    function test_magazinesAndTemporaryMaximumUpgrades() {
        const run=arena()
        compare(Gear.weapons.pistol.capacity,8)
        const weapon=Gear.current(run)
        const capacities=[]
        for (let level=0; level<=3; ++level) {
            weapon.level=level
            capacities.push(Gear.magazine(run,0))
        }
        verify(capacities[0]<capacities[1] && capacities[1]<=capacities[2] && capacities[2]<=capacities[3])
        verify(Gear.weaponStats(weapon).damage>Gear.weapons.pistol.damage*2)
        weapon.level=0
        run.gifts=[{id:run.nextId++,kind:"overclock",mega:true,cursed:false,front:"front",lane:0,depth:800,remaining:5}]
        verify(Rules.shoot(run,[run.gifts[0].id],"front"))
        compare(run.maxGearTime,20)
        compare(weapon.level,0)
        compare(Gear.weaponLevel(run,weapon),3)
        compare(Gear.effectiveWeaponStats(run,weapon).damage,Gear.weaponStats({id:"pistol",level:3}).damage)
        compare(weapon.ammo,Gear.magazine(run,0))
        for (let i=0; i<1210; ++i)
            Rules.update(run,1/60,0,false)
        compare(run.maxGearTime,0)
        compare(weapon.level,0)
        verify(weapon.ammo<=capacities[0])
    }

    function test_bubbleBurstsKeepNativeEffectData() {
        const run=arena()
        const boss=Rules.spawn(run,{type:"reapfast",front:"front",lane:0})
        boss.warp=0
        boss.waitingBoss=false
        Rules.releaseBubbles(run,boss)
        verify(run.bolts.some(function(bolt) {return bolt.bubble}))
        const bubble=run.bolts.find(function(bolt) {return bolt.bubble})
        Rules.burstBubble(run,bubble,false)
        const event=run.bursts.find(function(event) {return event.bubble})
        verify(event && event.id>0 && event.span>.6)
    }

    function test_newAchievementKitsAndRunRecords() {
        const profile=Progress.merge({}, {bestWallet:3600,bestRunSpent:5100,completeShops:1,hitlessBosses:1,bestFlawlessWave:20,hitlessLuci:1})
        for (const id of ["kingsRansom","liquidation","liquidAssets","stillwater","oathWard","oathglass"])
            verify(Progress.unlocked(profile).includes(id),id)
        const merged=Progress.merge(profile,{bestWallet:20,bestRunSpent:30})
        compare(merged.bestWallet,3600)
        compare(merged.bestRunSpent,5100)
        const run=arena()
        const demon=Rules.spawn(run,{type:"silophosus",front:"front",lane:0})
        demon.warp=0
        Rules.wound(run,demon,100,"gun")
        compare(run.metrics.enemyKills_silophosus,1)
        compare(run.metrics.weaponKills_pistol,1)
        run.health=1
        Rules.damagePlayer(run,1000,"front","hosphoragus",false,{critical:false})
        compare(run.metrics.enemyDeaths_hosphoragus,1)
    }
}
