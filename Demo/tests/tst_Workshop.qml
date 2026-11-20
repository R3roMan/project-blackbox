import QtQuick
import QtTest
import "../game/Rules.js" as Rules
import "../game/Loadout.js" as Gear
import "../game/SaveData.js" as Saves
import "../game/Pets.js" as Pets
import "../game/Encounters.js" as Mission
import "../game/SkillArt.js" as FX
import "../game/Conditions.js" as Conditions

TestCase {
    name:"Workshop"

    function battle() {
        const run=Rules.create(74731)
        run.wave=29
        verify(Rules.startWave(run))
        run.pet=null
        run.enemies=[]
        run.weatherEffect="clear"
        run.pending=[{type:"silophosus",front:"front",lane:0,at:900}]
        return run
    }

    function target(run,depth) {
        const enemy=Rules.spawn(run,{type:"silophosus",front:"front",lane:0})
        enemy.warp=0
        enemy.depth=depth
        enemy.attack=999
        enemy.travelSpeed=0
        enemy.hp=enemy.maxHp=enemy.baseHp=200
        return enemy
    }

    function test_socketCatalogAndConditionalBenefits() {
        const seen=new Set()
        const ledger=Gear.shopEntries()
        for (const group of Object.keys(Gear.slotPowers)) {
            verify(Gear.slotPowers[group].length>=12)
            for (const socket of Gear.slotPowers[group]) {
                verify(!seen.has(socket.id))
                seen.add(socket.id)
                verify(socket.levels.every(Number.isFinite))
                compare(ledger.find(function(e){return e.id===socket.id}).levels.length,4)
            }
        }
        compare(seen.size,37)
        const run=battle(),slot=run.slots.weapon[0]
        slot.power="phaseBore"
        compare(Gear.weaponSocket(run).id,undefined)
        slot.item=Gear.makeItem("rail")
        verify(Gear.weaponSocket(run).retention>0)
        slot.power="farSightLens"
        verify(Rules.spread(run,true)<Rules.spread(run,false))
        const active=run.slots.active[0]
        active.item=Gear.makeItem("whiteout")
        const basic=Rules.abilityRecovery(run,active)
        active.power="shockClock"
        verify(Rules.abilityRecovery(run,active)<basic)
        active.item=Gear.makeItem("quickload")
        compare(Gear.socketEffect(run,"active",active).id,undefined)
        const passive=run.slots.passive[0]
        const mag=Gear.magazine(run)
        passive.item=Gear.makeItem("magazine")
        passive.power="bandolierLining"
        compare(Gear.magazine(run),mag+3)
        compare(Saves.decodeRun(Saves.encodeRun(run),[]).slots.passive[0].power,"bandolierLining")
    }

    function test_shopExpansionQualityAndReplacement() {
        const run=battle()
        Rules.openShop(run)
        run.gold=20000
        const existing=run.shopStock.map(function(card) {return card.id})
        for (let capacity=5;capacity<8;capacity++) {
            const price=Gear.counterOffer(run).cost
            const before=run.gold
            verify(Rules.buy(run,"expand-counter"))
            compare(run.shopCapacity,capacity+1)
            compare(run.shopStock.length,capacity+1)
            compare(run.shopStock.slice(0,5).map(function(card){return card.id}),existing)
            compare(run.gold,before-price)
        }
        verify(!Rules.buy(run,"expand-counter"))
        run.shopStock=[{id:"shop-quality",action:"shop-quality",title:"Curated stock",level:1,cost:515,sold:false}]
        verify(Rules.buy(run,"shop-quality"))
        compare(run.shopQuality,1)
        verify(run.shopStock[0].sold)
        const newOdds=Gear.shopOdds(3), base=Gear.shopOdds(0)
        verify(newOdds.legendary>base.legendary && newOdds.premium>base.premium)
        const slot=run.slots.weapon[0]
        slot.power="ballistics";slot.powerLevel=2
        const offer={id:"slot-power",action:"power",powerId:"markfinder",group:"weapon",index:0,title:"Markfinder",cost:395,sold:false}
        run.shopStock=[offer]
        const before=run.gold
        verify(!Rules.buy(run,offer.id,-1))
        verify(!Rules.buy(run,offer.id,-1,"ballistics:1"))
        compare(slot.power,"ballistics")
        compare(run.gold,before)
        verify(Rules.buy(run,offer.id,-1,"ballistics:2"))
        compare(slot.power,"markfinder")
        compare(slot.powerLevel,0)
        compare(run.gold,before-395)
        compare(Saves.decodeRun(Saves.encodeRun(run),[]).shopQuality,1)
    }

    function test_refundLastPaidAbilityRankAfterContinue() {
        const run=battle()
        run.gold=400
        run.slots.active[0].item=Gear.makeItem("ward")
        Rules.openShop(run)
        run.shopStock=[{id:"paid-ward-rank",title:"Ward rank",action:"upgrade",group:"active",gearId:"ward",cost:90,level:1,index:0}]
        verify(Rules.buy(run,"paid-ward-rank",0))
        compare(run.gold,310)
        compare(run.slots.active[0].item.level,1)
        const saved=Saves.decodeRun(Saves.encodeRun(run),[])
        verify(saved)
        verify(Rules.refundAbility(saved,"active","ward"))
        compare(saved.gold,400)
        compare(saved.spentGold,0)
        compare(saved.slots.active[0].item.level,0)
        verify(saved.shopStock[0].sold)
        verify(!Rules.refundAbility(saved,"active","ward"))
    }

    function test_previousShopCheckpointKeepsTheStockAndGold() {
        const run=battle()
        Rules.openShop(run)
        run.shopStock[0]=Gear.counterOffer(run)
        run.shopStock[1].sold=true
        const restored=Saves.decodeRun(Saves.encodeRun(run),[])
        verify(restored)
        compare(restored.shopStock.length,5)
        verify(restored.shopStock.every(function(card) {return card.id!=="expand-counter"}))
        compare(restored.shopStock.slice(0,4),run.shopStock.slice(1))
        compare(restored.gold,run.gold)
        compare(restored.rng,run.rng)
    }

    function test_skyStaysOnItsWaveAndWeatherIsIndependent() {
        const run=Rules.create(74731)
        verify(Rules.startWave(run))
        run.pet=null
        for (const phase of ["daytime","sunset","night","sunrise","daytime"]) {
            run.weatherEffect="fog"
            compare(run.skyPhase==="bloodMoon" ? "night" : run.skyPhase,phase)
            run.pending=[]
            run.enemies=[]
            Rules.update(run,.1,false,false)
            verify(run.phase==="reward" || run.phase==="between")
            compare(run.skyPhase==="bloodMoon" ? "night" : run.skyPhase,phase)
            compare(run.weatherEffect,"fog")
            if (run.phase==="reward") verify(Rules.skipSelection(run))
            verify(Rules.startWave(run))
        }
        verify(Conditions.fogVisibility(330)>Conditions.fogVisibility(1750))
        verify(Conditions.sky("night",25,"up").moon>0)
        compare(Conditions.sky("daytime",25,"down").dark,1)
        compare(Conditions.sky("sunset",25,"down").warm,0)
        verify(Conditions.sky("daytime",60,"left").sunX-Conditions.sky("daytime",0,"left").sunX<.04)
    }

    function test_abilityGeometryAndRestingCharge() {
        const run=battle(),foe=target(run,660)
        for (const ability of Object.values(Gear.activeAbilities))
            verify(!!FX.colors[FX.profile(ability).kind],ability.id)
        run.slots.active[0].item=Gear.makeItem("shock")
        verify(Rules.useAbility(run,0,"front",foe.id,{x:.22,y:.35}))
        const cast=run.abilityEvents[run.abilityEvents.length-1]
        compare(cast.kind,"electric")
        compare(cast.points.length,1)
        compare(cast.points[0].depth,foe.depth)
        run.slots.active[0].item=Gear.makeItem("quickload")
        Gear.current(run).ammo=0
        verify(Rules.useAbility(run,0,"front",0))
        const reload=run.abilityEvents[run.abilityEvents.length-1]
        compare(reload.kind,"reload")
        verify(reload.label.includes("ROUNDS"))

        const pet=Pets.deploy("owl")
        run.pet=pet
        run.health=100
        Rules.petStrike(run,pet,Pets.spec(pet.id),foe)
        Rules.petStrike(run,pet,Pets.spec(pet.id),foe)
        verify(pet.chargePending && pet.chargeLeft>0)
        pet.stamina=.02
        Rules.updatePet(run,pet,.03)
        verify(pet.resting>0)
        const stored=pet.chargeLeft
        Rules.updatePet(run,pet,.50)
        compare(pet.chargeLeft,stored)
        verify(Pets.flight(pet,1,false).elevation<pet.elevation)
        const waits=Math.ceil(pet.resting*60)+1
        for(let i=0;i<waits;i++)Rules.updatePet(run,pet,1/60)
        const charge=Math.ceil(pet.chargeLeft*60)+120
        for(let i=0;i<charge && pet.chargePending;i++)Rules.updatePet(run,pet,1/60)
        verify(!pet.chargePending && pet.chargedFlash>0)
        compare(run.health,103)
    }

    function test_otherChargedMovesHaveDistinctResults() {
        const setup = function(id) {
            const run=battle(), enemy=target(run,400), pet=Pets.deploy(id)
            pet.chargePending=true
            run.pet=pet
            return {run:run,enemy:enemy,pet:pet}
        }
        const crow=setup("crow")
        Rules.petStrike(crow.run,crow.pet,Pets.spec(crow.pet.id),crow.enemy)
        compare(crow.enemy.elements.burn,1)
        verify(crow.enemy.mark>5)

        const drake=setup("drake"), neighbour=target(drake.run,485)
        Rules.petStrike(drake.run,drake.pet,Pets.spec(drake.pet.id),drake.enemy)
        compare(neighbour.elements.burn,1)
        verify(neighbour.hp<neighbour.maxHp,"Flux splash health: "+neighbour.hp+" / "+neighbour.maxHp)

        const beetle=setup("beetle")
        beetle.run.bolts=[{front:"front"},{front:"front"},{front:"right"}]
        Rules.petStrike(beetle.run,beetle.pet,Pets.spec(beetle.pet.id),beetle.enemy)
        compare(beetle.run.bolts.length,1)
        compare(beetle.run.bolts[0].front,"right")

        const wendy=setup("chicken")
        Rules.petStrike(wendy.run,wendy.pet,Pets.spec(wendy.pet.id),wendy.enemy)
        verify(wendy.enemy.depth>400)
    }

    function test_rimeFalconBananaAndFairy() {
        const run=battle()
        const enemy=target(run,500)
        const falcon=Pets.deploy("frostFalcon")
        falcon.chargePending=true
        Rules.petStrike(run,falcon,Pets.spec(falcon.id),enemy)
        compare(enemy.elements.frozen,2)
        verify(falcon.chargedFlash>0)
        const primate=Pets.deploy("vesper")
        Rules.petStrike(run,primate,Pets.spec(primate.id),enemy)
        compare(enemy.elements.weaken,1)
        const fairy=Pets.deploy("fairy")
        run.health=112
        run.rng=2000
        Rules.petStrike(run,fairy,Pets.spec(fairy.id),enemy)
        compare(run.health,116)
    }

    function test_vesperTricksSpareBossesAndResetAtWaveStart() {
        const run=battle()
        const foe=target(run,500)
        const boss=Rules.spawn(run,{type:"humontafagus",front:"front",lane:80})
        const pet=Pets.deploy("vesper")
        run.waveTime=36
        pet.trickAt=35
        pet.flickerAt=50
        run.rng=0
        Rules.vesperTrick(run,pet)
        compare(pet.trickPose,"thumbs")
        verify(foe.hp<=0)
        verify(boss.hp>0)
        verify(pet.trickAt>=66 && pet.trickAt<=81)
        pet.trickAt=35
        run.rng=3
        Rules.vesperTrick(run,pet)
        compare(pet.trickPose,"laugh")
        verify(run.petHudLost)
        run.phase="between"
        verify(Rules.startWave(run))
        verify(!run.petHudLost && !run.petGlitchUntil)
    }
}
