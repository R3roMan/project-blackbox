import QtQuick
import QtTest
import "../game/Meta.js" as Vault
import "../game/Rules.js" as Rules
import "../game/Loadout.js" as Gear
import "../game/Conditions.js" as Sky
import "../game/SaveData.js" as Save
import "../game/Tarot.js" as Tarot
import "../game/Pets.js" as Pets
import "../game/Progress.js" as Progress

TestCase {
    name:"VaultAndSky"

    function combat(seed) {
        const run=Rules.create(seed || 87,[])
        verify(Rules.startWave(run))
        run.pending=[]
        run.enemies=[]
        run.bolts=[]
        run.pet=null
        run.weatherEffect="clear"
        return run
    }
    function placed(run,type,depth) {
        const enemy=Rules.spawn(run,{type:type,front:"front",lane:0})
        enemy.warp=0
        enemy.depth=depth
        enemy.hp=enemy.maxHp=enemy.baseHp=180
        return enemy
    }

    function test_permanentRanksAndOneRunParcels() {
        const vault=Vault.fresh()
        vault.gems=100000
        verify(Vault.buy(vault,"weapon"))
        verify(Vault.buy(vault,"health"))
        verify(Vault.buy(vault,"health"))
        verify(Vault.buy(vault,"barrier"))
        verify(Vault.buy(vault,"duration"))
        verify(Vault.buy(vault,"recovery"))
        verify(Vault.buy(vault,"basket"))
        verify(Vault.buy(vault,"legendary"))
        verify(!Vault.buy(vault,"legendary") && !Vault.buy(vault,"epic"))
        const terms=Vault.begin(vault,"first-journey")
        compare(vault.pending,{})
        compare(Vault.begin(vault,"first-journey"),terms)
        const next=Vault.begin(vault,"second-journey")
        compare(next.pending,{})
        const run=Rules.create(15,[])
        Rules.applyCovenant(run,terms)
        compare(run.health,220)
        compare(run.barrierCell.hp,1)
        verify(run.slots.active[0].item && run.slots.passive[0].item)
        verify(Rules.startWave(run))
        compare(Gear.weapons[Gear.current(run).id].rarity,"legendary")
        fuzzyCompare(Gear.effectiveWeaponStats(run,Gear.current(run)).damage,Gear.weapons[Gear.current(run).id].damage*1.02,1e-6)
        Rules.damagePlayer(run,8,"front","silophosus",false,{environment:true})
        compare(run.health,220)
        compare(run.barrierCell.hp,0)
        compare(Save.decodeRun(Save.encodeRun(run),[]).covenant,terms)
        verify(Vault.buy(vault,"epic"))
    }

    function test_gradeHitlessOnlyAndDuplicatePayout() {
        const run=Rules.create(87,[])
        run.attemptId="deep-expedition"
        run.wave=120
        run.gold=6300
        run.metrics={waves:120,flawless:120,kills:2220,shots:2460,hitShots:2460,bossKills:12,shieldBlocks:190,parries:44,seals:38,
            goldEarned:15500,shopBuys:30,shopSpent:9200}
        const load={items:12,upgrades:15,burden:15}
        const excellent=Vault.report(run,"retired",load)
        compare(excellent.grades.overall,"SSS")
        verify(excellent.gems>120 && excellent.gems<=192)
        compare(excellent.stats.waveScore,100)
        run.metrics.waves=119
        run.metrics.flawless=119
        verify(Vault.report(run,"retired",load).grades.overall!=="SSS")
        run.metrics.waves=120
        run.metrics.flawless=120
        run.metrics.shopBuys=0
        verify(Vault.report(run,"retired",load).grades.overall!=="SSS")
        run.metrics.shopBuys=30
        run.metrics.unblockedHits=1
        const afterHit=Vault.report(run,"retired",load)
        verify(afterHit.grades.overall!=="SSS")
        run.metrics.unblockedHits=0
        run.metrics.hitShots--
        verify(Vault.report(run,"retired",load).grades.overall!=="SSS")
        run.metrics.hitShots++
        verify(Vault.report(run,"death",load).grades.overall!=="SSS")
        const ledger=Vault.fresh()
        verify(Vault.settle(ledger,excellent))
        verify(!Vault.settle(ledger,excellent))
        compare(ledger.gems,excellent.gems)
        verify(Vault.saveAttempt(ledger,excellent))
        verify(!Vault.saveAttempt(ledger,excellent))
        verify(Vault.decode(ledger))
        run.rehearsal=true
        compare(Vault.report(run,"retired",load).gems,0)
        verify(Vault.report(run,"retired",{items:4,upgrades:0,burden:4}).stats.restraint>excellent.stats.restraint)
    }

    function test_signedGradesAndWavePayout() {
        const marks=[]
        for (let score=0;score<=100;score++) {
            const mark=Vault.grade(score)
            if (!marks.includes(mark)) marks.push(mark)
        }
        compare(marks,Vault.grades.slice(0,-1))
        const run=combat()
        run.attemptId="wave-twenty-test"
        run.wave=20
        run.gold=20000
        run.metrics={waves:20,flawless:20,kills:800,shots:1000,hitShots:1000,shieldBlocks:150,
            bossKills:2,parries:100,seals:20,goldEarned:40000,shopSpent:20000,shopBuys:70}
        const load={items:15,upgrades:34,burden:15}
        let sawB=false
        for (let hits=0;hits<=1000;hits+=10) {
            run.metrics.hitShots=hits
            const report=Vault.report(run,"death",load)
            compare(report.stats.waveScore,16.7)
            if (Vault.familyOf(report.grades.overall)==="B") {
                sawB=true
                verify(report.gems<=29)
                verify(report.stats.waveGems>report.bonus+report.stats.combatGems)
            }
        }
        verify(sawB)
        const ledger=Vault.fresh()
        ledger.settled["a-graded-expedition"]="B+"
        verify(Progress.withGrades({},ledger).gradeB===1)
        verify(Vault.decode(ledger))
    }

    function test_difficultyPremiumAndAutoTax() {
        for (const [mark,premium] of [["B",50],["A",130]]) {
            const normal=Vault.expeditionBonus(mark,"normal",45)
            const hard=Vault.expeditionBonus(mark,"hard",45)
            const insane=Vault.expeditionBonus(mark,"insane",45)
            compare(insane.difficulty-normal.difficulty,premium)
            verify(hard.difficulty>normal.difficulty && hard.difficulty<insane.difficulty)
        }
        verify(Vault.autoTaxRate("A")>Vault.autoTaxRate("B"))
        const run=combat()
        run.attemptId="expedition-tax"
        run.wave=20
        run.metrics.waves=19
        run.fieldGems={"boss-10":4}
        const load={items:3,upgrades:1,burden:3}
        const before=Vault.report(run,"death",load)
        run.usedAuto=true
        const after=Vault.report(run,"death",load)
        compare(after.grades.overall,before.grades.overall)
        compare(after.gems,before.gems-Math.round((before.gems+4)*Vault.autoTaxRate(before.grades.overall)))
        verify(after.stats.autoTax>0)
    }

    function test_quickExpeditionKeepsParcelsAndTarotDealsFreshHand() {
        const state=Vault.fresh()
        state.gems=2000
        verify(Vault.buy(state,"tarot",()=>0))
        const first=state.reading.cards.slice()
        verify(Vault.turnCard(state,first[0]))
        state.pending.epic=true
        state.ranks.weapon=2
        const quick=Vault.begin(state,"shortcut-01",true)
        compare(quick.ranks.weapon,2)
        verify(!quick.tarot && !quick.pending.epic)
        compare(state.reading.chosen,first[0])
        verify(state.pending.epic)
        const standard=Vault.begin(state,"expedition-02")
        verify(standard.pending.epic && standard.tarot)
        verify(Vault.buy(state,"tarot",()=>0))
        verify(state.reading.cards.some((id,index)=>id!==first[index]))
        compare(new Set(state.reading.cards).size,5)
    }

    function test_refundsPreserveTheActualPaymentAndLegacyBudget() {
        const ledger=Vault.fresh()
        ledger.gems=100
        ledger.sale={discount:20,free:"weapon"}
        verify(Vault.buy(ledger,"weapon"))
        compare(Vault.refundValue(ledger,"weapon"),0)
        const payment=Vault.price(ledger,Vault.vows[0])
        verify(Vault.buy(ledger,"weapon"))
        compare(ledger.gems,100-payment)
        ledger.sale={discount:0,free:""}
        const restored=Vault.read(JSON.stringify(ledger))
        compare(Vault.refundValue(restored,"weapon"),payment)
        verify(Vault.refund(restored,"weapon"))
        compare(restored.gems,100)
        verify(Vault.refund(restored,"weapon"))
        compare(restored.gems,100)
        verify(!Vault.refund(restored,"weapon"))
        const legacy=Vault.fresh()
        delete legacy.receipts
        delete legacy.legacyReceipts
        legacy.ranks={weapon:2,health:1}
        legacy.gems=80
        legacy.earned=89
        const migrated=Vault.read(JSON.stringify(legacy))
        verify(Vault.refund(migrated,"health"))
        verify(Vault.refund(migrated,"weapon"))
        verify(Vault.refund(migrated,"weapon"))
        verify(migrated.gems<=89)
    }

    function test_debugMoneyAndClosedCheckpoints() {
        const run=Rules.create(77,[])
        verify(Rules.configure(run,"normal",10,"standard"))
        run.debugMoney=true
        run.attemptId="debug-money-attempt"
        verify(Rules.startWave(run))
        Rules.openShop(run)
        const card=Gear.counterOffer(run)
        verify(Rules.buy(run,card.id))
        compare(run.gold,0)
        const data=Save.encodeRun(run)
        const restored=Save.decodeRun(data,[])
        compare(restored.shopCapacity,6)
        compare(restored.debugMoney,true)
        compare(Gear.availableGold(restored),Infinity)
        const ledger=Vault.fresh()
        ledger.closed[run.attemptId]=true
        compare(Save.savedChoice(data,data,[],ledger),null)
        verify(Save.closesCheckpoint(data,run.attemptId,run.seed))
        restored.attemptId=""
        const legacy=Save.encodeRun(restored)
        verify(Save.closesCheckpoint(legacy,run.attemptId,run.seed))
        ledger.closed[Save.checkpointId(restored)]=true
        compare(Save.savedChoice("broken",legacy,[],ledger),null)
    }

    function test_tarotAndSalePersistAndApplyExactlyOnce() {
        const state=Vault.fresh()
        state.gems=100
        state.sale={discount:20,free:"health"}
        compare(Vault.price(state,Vault.vows[1]),0)
        verify(Vault.buy(state,"health"))
        compare(state.gems,100)
        compare(state.sale.free,"")
        compare(Vault.price(state,Vault.reading),36)
        const rolls=[15.5/78,.16,.64,.28,.82]
        verify(Vault.buy(state,"tarot",function() {return rolls.shift()}))
        compare(state.gems,64)
        compare(state.purchases,2)
        compare(new Set(state.reading.cards).size,5)
        verify(!Vault.buy(state,"tarot"))
        verify(!Vault.turnCard(state,"not-a-card"))
        const reloaded=Vault.read(JSON.stringify(state))
        compare(reloaded.reading,state.reading)
        verify(Vault.turnCard(reloaded,"major-15"))
        verify(!Vault.turnCard(reloaded,state.reading.cards[1]))
        const terms=Vault.begin(reloaded,"tarot-first-expedition")
        compare(terms.tarot,"major-15")
        compare(reloaded.reading,null)
        compare(Vault.begin(reloaded,"tarot-first-expedition"),terms)
        compare(Vault.begin(reloaded,"other-expedition").tarot,undefined)
        const run=Rules.create(23,[])
        const regular=run.petChoice
        Rules.applyCovenant(run,terms)
        verify(Rules.startWave(run))
        compare(run.pet.id,regular)
        compare(run.tarotPet.id,"jacko")
        verify(!Pets.available(["jacko"]).some(function(p){return p.id==="jacko"}))
        const saved=Save.decodeRun(Save.encodeRun(run),[])
        compare(saved.tarotPet.id,"jacko")
        compare(saved.covenant.tarot,"major-15")
        const done=Vault.report(run,"retired",{items:1,upgrades:0,burden:1})
        done.id="tarot-first-expedition"
        done.eligible=true
        done.gems=600
        verify(Vault.settle(reloaded,done))
        verify(!Vault.settle(reloaded,done))
        compare(reloaded.earned,600)
        verify(Progress.unlocked(Progress.withGrades({},reloaded),false).includes("barometer"))
        let saleRolls=[.001,.0003,.04]
        const sale=Vault.rollSale(reloaded,function(){return saleRolls.shift()})
        compare(sale.discount,50)
        verify(!!sale.free)
        saleRolls=[.009,.5]
        compare(Vault.rollSale(reloaded,function(){return saleRolls.shift()}),{discount:20,free:""})
        saleRolls=[.04,.5]
        compare(Vault.rollSale(reloaded,function(){return saleRolls.shift()}),{discount:10,free:""})
        verify(Vault.decode(reloaded))
    }

    function test_tarotAllCardsHaveDistinctEffectsAndWaveLimits() {
        compare(Tarot.deck.length,78)
        compare(new Set(Tarot.deck.map(function(c){return c.art})).size,78)
        compare(new Set(Tarot.deck.map(function(c){return JSON.stringify([c.stats,c.rite || []])})).size,78)
        const run=Rules.create(14,[])
        Rules.applyCovenant(run,{ranks:{},pending:{},tarot:"major-20"})
        verify(Rules.startWave(run))
        Rules.holdShield(run,true)
        Rules.blockWithShield(run,3,"front","silophosus",null,false,false)
        compare(run.gold,13)
        run.shield.cool=0
        Rules.holdShield(run,true)
        Rules.blockWithShield(run,3,"front","silophosus",null,false,false)
        compare(run.gold,13)
        delete run.covenant
        verify(!Tarot.rite(run,"parry",1))
    }

    function test_oldVaultMigrationAndBossOnlyOmen() {
        const legacy=Vault.fresh()
        for (const key of ["earned","purchases","reading","sale"]) delete legacy[key]
        legacy.gems=225
        legacy.ranks.health=2
        legacy.pending.epic=true
        const migrated=Vault.read(JSON.stringify(legacy))
        compare(migrated.earned,225)
        compare(migrated.purchases,3)
        compare(migrated.sale,{discount:0,free:""})
        compare(migrated.ranks.health,2)
        const run=combat(14)
        run.covenant={ranks:{},pending:{},tarot:"swords-14"}
        const ordinary=placed(run,"silophosus",350)
        const boss=placed(run,"humontafagus",350)
        boss.waitingBoss=false
        Rules.wound(run,ordinary,5,"gun","",0,{critical:2})
        Rules.wound(run,boss,5,"gun","",0,{critical:2})
        compare(ordinary.hp,170)
        fuzzyCompare(boss.hp,167.9,1e-6)
    }

    function test_dayNightAndOverlayGear() {
        const run=combat()
        const sun=Gear.makeItem("zenithThroat"), moon=Gear.makeItem("moonwake")
        run.skyPhase="daytime"
        const solar=Gear.effectiveWeaponStats(run,sun).damage
        const lunar=Gear.effectiveWeaponStats(run,moon).damage
        run.skyPhase="bloodMoon"
        fuzzyCompare(Gear.effectiveWeaponStats(run,sun).damage*1.38,solar,1e-6)
        fuzzyCompare(Gear.effectiveWeaponStats(run,moon).damage,lunar*1.34,1e-6)
        const gun=Gear.current(run)
        gun.ammo=0
        run.slots.active[0].item=Gear.makeItem("openSign")
        run.weatherEffect="fog"
        verify(!Rules.useAbility(run,0,"front",0))
        compare(gun.ammo,0)
        run.weatherEffect="clear"
        verify(Rules.useAbility(run,0,"front",0))
        compare(gun.ammo,3)
        run.cooldowns={}
        run.slots.active[0].item=Gear.makeItem("lastStar")
        run.skyPhase="daytime"
        verify(!Rules.useAbility(run,0,"front",0))
        run.skyPhase="night"
        verify(Rules.useAbility(run,0,"front",0))
        compare(run.barrierHp,1)
    }

    function test_emptyClickReloadsAndHeavyWeaponsTakeLonger() {
        const run=combat()
        const weapon=Gear.current(run)
        weapon.ammo=0
        verify(!Rules.shoot(run,[],"front"))
        verify(weapon.reload>0)
        compare(run.metrics.shots,undefined)
        compare(run.metrics.reloads,1)
        verify(Gear.weapons.siegeRpg.reload>Gear.weapons.launcher.reload+1)
    }

    function test_abyssalTakeoverNeedsASealBeforeTheDeadline() {
        const run=combat()
        run.wave=10
        run.weatherEffect="incursion"
        Rules.update(run,1,false,false)
        compare(run.phase,"combat")
        compare(run.takeoverTime,1)
        compare(Rules.finishWave(run),false)
        run.takeoverTime=49.96
        Rules.update(run,.05,false,false)
        compare(run.cue,"takeoverTick")
        const saved=Save.decodeRun(Save.encodeRun(run),[])
        fuzzyCompare(saved.takeoverTime,50.01,1e-6)
        verify(Rules.sealTarget(saved,"down"))
        verify(Rules.advanceSeal(saved,1))
        compare(saved.cue,"takeoverSeal")
        Rules.update(saved,1,false,false)
        compare(saved.phase,"bossReward")
        run.takeoverTime=59.99
        Rules.update(run,.03,false,false)
        compare(run.phase,"defeat")
        compare(run.health,0)
        compare(run.cue,"loss")
    }

    function test_passagesRerollsAndRetainedOffers() {
        const vault=Vault.fresh()
        vault.gems=12000
        compare(Vault.vows[0].price,9)
        compare(Vault.vows[1].price,11)
        for (let rank=0;rank<4;rank++) verify(Vault.buy(vault,"rerolls"))
        verify(Vault.buy(vault,"freezeStock"))
        verify(Vault.buy(vault,"pass30"))
        verify(!Vault.buy(vault,"pass20") && !Vault.buy(vault,"pass60"))
        compare(Vault.startWave(vault),30)
        const terms=Vault.begin(vault,"paid-wave-thirty")
        compare(Vault.startWave(vault),1)
        const run=Rules.create(77,[])
        Rules.applyCovenant(run,terms)
        compare(Rules.prepareStage(run).wave,30)
        compare(Rules.refreshRemaining(run),5)
        for (let n=0;n<5;n++) verify(Rules.refresh(run))
        verify(!Rules.canReroll(run))
        verify(Rules.startWave(run))
        compare(run.wave,30)
        compare(run.skyPhase,"sunset")
        compare(Rules.refreshRemaining(run),0)
        run.gold=3000
        Rules.openShop(run)
        const offer=run.shopStock.find(function(item){return item.action==="gear"})
        verify(!!offer)
        verify(Rules.freezeOffer(run,offer.id))
        compare(Rules.rerollPrice(run),55)
        verify(Rules.refresh(run))
        compare(run.gold,2945)
        compare(Rules.rerollPrice(run),91)
        verify(run.shopStock.some(function(item){return item.id===offer.id}))
        verify(Rules.leaveShop(run))
        verify(Rules.startWave(run))
        compare(Rules.rerollPrice(run),55)
        Rules.openShop(run)
        compare(run.shopStock[0].id,offer.id)
        verify(Rules.leaveShop(run))
        compare(run.frozenOffer,null)
        const loadout=Rules.create(99,[])
        Rules.applyCovenant(loadout,{ranks:{freezeStock:1},pending:{}})
        verify(Rules.startWave(loadout))
        loadout.phase="reward"
        loadout.offers=[Gear.weapons.scattergun,Gear.activeAbilities.ward,Gear.passives.magazine]
        verify(Rules.freezeOffer(loadout,"scattergun"))
        verify(Rules.refresh(loadout))
        compare(loadout.offers[0].id,"scattergun")
        verify(Rules.skipSelection(loadout))
        loadout.wave=2
        loadout.offers=Rules.draft(loadout)
        verify(loadout.offers.some(function(card){return card.id==="scattergun"}))
        compare(Save.decodeRun(Save.encodeRun(loadout),[]).frozenOffer.card.id,"scattergun")
    }

    function test_fieldGemsAndWeaponComparison() {
        const run=combat()
        run.wave=10
        const boss=placed(run,"humontafagus",550)
        boss.waitingBoss=false
        Rules.wound(run,boss,10000,"gun")
        const dropped=run.fieldGems["boss-10"]
        verify(dropped>=1 && dropped<=4)
        compare(run.lootEvents.map(function(e){return e.kind}),["gold","gem"])
        let four=0
        for (let seed=0;seed<3000;seed++) if (Rules.bossGems(10,seed*1337)===4) four++
        verify(four>10 && four<95)
        const gift={id:800,kind:"gems",mega:true,front:"front",lane:0,depth:850}
        run.gifts.push(gift)
        Rules.claimGift(run,gift)
        const mega=run.fieldGems["mega-10"]
        verify(mega>=1 && mega<=3)
        const vault=Vault.fresh(),id="regular-field-loot"
        verify(Vault.depositField(vault,id,run.fieldGems))
        compare(vault.gems,dropped+mega)
        verify(!Vault.depositField(vault,id,{"boss-10":dropped,"mega-10":mega}))
        verify(Vault.depositField(vault,id,{"mega-10":mega+1}))
        compare(vault.gems,dropped+mega+1)
        const stats=Gear.weaponComparison(run,Gear.makeItem("pistol"),Gear.makeItem("rail"))
        verify(stats.some(function(row){return row.label==="Damage / attack" && row.delta>0}))
        verify(stats.some(function(row){return row.label==="Fire rate" && row.delta<0}))
    }

    function test_thunderHasTwoOutcomesAndRespectsProtectionWindow() {
        let storm=0
        for(let n=1;n<=2000;n++) if(Sky.rainVariant(5,n*7937)==="thunder") storm++
        verify(storm>340 && storm<460)
        let fatal=0,charged=0
        for(let n=1;n<=38;n++) {
            const run=combat(n*8463)
            run.weatherEffect="thunder"
            const enemy=placed(run,"silophosus",560)
            const speed=enemy.travelSpeed, interval=enemy.attack
            Rules.thunderStrike(run)
            compare(run.stormBursts.length,1)
            if (enemy.stormCharged) {
                charged++
                fuzzyCompare(enemy.travelSpeed,speed*1.5,1e-6)
                fuzzyCompare(enemy.attack,interval/1.5,1e-6)
                Rules.playerStatus(run,"stun",1)
                const protected=run.elements.stunGate
                for(let i=0;i<3;i++) Rules.playerStatus(run,"stun",3)
                compare(run.elements.stunGate,protected)
            } else {
                fatal++
                verify(enemy.hp<=0)
            }
        }
        verify(fatal>0 && charged>0)
    }
}
