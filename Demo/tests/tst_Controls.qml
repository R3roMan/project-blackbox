import QtQuick
import QtTest
import "../game" as Game
import "../game/Rules.js" as Rules
import "../game/Loadout.js" as Gear
import "../game/Controls.js" as Controls
import "../ui" as Ui

Item {
    id: fixture
    width: 900
    height: 650

    Game.PlayScene {
        id: scene
        anchors.fill: parent
        artDirectory: Qt.resolvedUrl("../../V0.1/kde/contents/images/")
        allowed: true
        software: true
        sound: false
        motion: false
    }

    TestCase {
        name: "CombatControls"
        when: windowShown

        function init() {
            scene.resetRun()
            scene.hudHidden=false
            scene.controlBindings="{}"
            scene.showEnemyPreview=true
            scene.mouseTurns = true
            scene.run.petChoice = ""
            scene.run.starterOffers = ["pistol","scattergun","rail"]
            scene.startWave()
            scene.run.weatherEffect="clear"
            scene.run.pending = [{ at:300,type:"silophosus",front:"front",lane:0 }]
            scene.publish()
            tryCompare(scene,"fighting",true)
            mouseMove(scene,450,325)
        }

        function test_edgesTurnOnEntryAndAllowAnotherCrossing() {
            mouseMove(scene,3,325)
            compare(scene.frontId,"left")
            mouseMove(scene,897,325)
            compare(scene.frontId,"front")
            mouseMove(scene,895,327)
            wait(280)
            compare(scene.frontId,"front")
            mouseMove(scene,853,325)
            mouseMove(scene,897,325)
            compare(scene.frontId,"right")
            mouseMove(scene,450,3)
            compare(scene.frontId,"right")
            mouseMove(scene,3,325)
            compare(scene.frontId,"front")
            mouseMove(scene,450,3)
            compare(scene.frontId,"up")
            mouseMove(scene,450,647)
            compare(scene.frontId,"front")
            mouseMove(scene,450,598)
            mouseMove(scene,450,647)
            compare(scene.frontId,"down")
        }

        function test_clickAbilityAndSpeedCycle() {
            scene.run.slots.active[0].item=Gear.makeItem("ward")
            scene.publish()
            mouseClick(findChild(scene,"activeHUD-Q"))
            verify(Rules.activeCooldown(scene.run,"ward")>0)
            const speed=findChild(scene,"gameSpeed")
            wait(100)
            for (const value of [2,3,5,.5,1]) {
                mouseClick(speed,speed.width/2,speed.height/2,Qt.LeftButton)
                compare(scene.gameSpeed,value)
            }
        }

        function test_combatHudToggleAndShortcutScope() {
            const speed=findChild(scene,"gameSpeed")
            const ability=findChild(scene,"activeHUD-Q")
            verify(speed.visible && ability.visible)
            keyClick(Qt.Key_Control)
            tryCompare(speed,"visible",false)
            verify(!ability.visible && scene.fighting)
            keyPress(Qt.Key_Control)
            mouseClick(scene,450,300,Qt.LeftButton,Qt.ControlModifier)
            keyRelease(Qt.Key_Control)
            verify(scene.hudHidden)
            keyClick(Qt.Key_Control)
            tryCompare(speed,"visible",true)
            scene.controlBindings=JSON.stringify({hud:{key:Qt.Key_H,mods:0}})
            keyClick(Qt.Key_H)
            verify(scene.hudHidden)
            keyClick(Qt.Key_Escape)
            verify(scene.paused)
        }

        function test_shopShowsPurchasedWithoutReselecting() {
            Rules.openShop(scene.run)
            scene.run.shopStock=[{id:"item-upgrade-token",title:"Item upgrade token",action:"item-upgrade",
                cost:510,sold:false,description:"Upgrade one item."}]
            scene.run.gold=900
            scene.publish()
            const shop=findChild(scene,"bossShop")
            verify(shop)
            const targets=findChild(shop,"shopUpgradeTarget")
            targets.currentIndex=0
            const purchase=findChild(shop,"buyShopOffer")
            verify(purchase.enabled)
            shop.purchase("")
            compare(purchase.text,"Purchased")
            verify(!purchase.enabled)
        }

        function test_shopSaleRecordsAndKeepsOneWeapon() {
            Rules.openShop(scene.run)
            scene.run.slots.active[0].item=Gear.makeItem("giltRupture")
            scene.run.inventory[1]={group:"weapon",item:Gear.makeItem("starDestroyer")}
            scene.publish()
            const offers=Gear.saleOffers(scene.run)
            compare(offers.find(item=>item.id==="pistol"),undefined)
            const rare=offers.find(item=>item.id==="giltRupture")
            const legendary=offers.find(item=>item.id==="starDestroyer")
            verify(legendary.value>rare.value)
            verify(Rules.sellGear(scene.run,legendary.key))
            compare(scene.run.inventory[1],null)
            verify(!Rules.sellGear(scene.run,legendary.key))
            verify(Rules.sellGear(scene.run,rare.key))
            compare(scene.run.slots.active[0].item,null)
            compare(scene.run.metrics.gearSales,2)
            compare(scene.run.metrics.saleGold,legendary.value+rare.value)
        }

        function test_withdrawalKeepsRoomAndFrame() {
            scene.turnView("left")
            compare(scene.frontId,"left")
            verify(!findChild(scene,"fieldTitle").visible)
            keyClick(Qt.Key_Escape)
            verify(scene.paused)
            compare(scene.frontId,"left")
            verify(findChild(scene,"fieldTitle").visible)
            verify(!findChild(scene,"wavesTab"))
            const frame=findChild(scene,"fieldPanel")
            const before=Qt.rect(frame.x,frame.y,frame.width,frame.height)
            const options=findChild(scene,"settingsTab")
            mouseClick(options)
            compare(scene.pauseTab,"settings")
            compare(Qt.rect(frame.x,frame.y,frame.width,frame.height),before)
            mouseClick(findChild(scene,"buildTab"))
            compare(Qt.rect(frame.x,frame.y,frame.width,frame.height),before)
            const retire=findChild(scene,"retireRun")
            verify(retire.enabled)
            retire.click()
            verify(scene.retireArmed && scene.paused)
            retire.click()
            compare(scene.phase,"defeat")
            compare(scene.attemptReport.reason,"retired")
            compare(scene.outcomeKind,"")
            scene.resetRun()
            scene.startWave()
            scene.run.pending=[{at:300,type:"silophosus",front:"front",lane:0}]
            scene.publish()
            keyClick(Qt.Key_Left)
            compare(scene.frontId,"left")
        }

        function test_shopBarrierEquipsAndAbsorbsDamageAfterWaveStart() {
            Rules.openShop(scene.run)
            scene.run.shopStock=[{id:"barrier-core",title:"Barrier core",action:"barrier-core",cost:375,sold:false}]
            scene.run.gold=900
            scene.publish()
            const shop=findChild(scene,"bossShop")
            verify(shop)
            shop.purchase("")
            compare(findChild(shop,"buyShopOffer").text,"Purchased")
            compare(scene.run.barrierCell.hp,2)
            verify(Rules.leaveShop(scene.run))
            verify(Rules.startWave(scene.run))
            scene.publish()
            const initial=scene.run.health
            const status=findChild(scene,"barrierStatus")
            compare(status.charges,2)
            Rules.damagePlayer(scene.run,100,"front","silophosus",false,{critical:false})
            scene.publish()
            compare(scene.run.health,initial)
            compare(status.charges,1)
            Rules.damagePlayer(scene.run,100,"front","silophosus",false,{critical:false})
            scene.publish()
            compare(scene.run.health,initial)
            compare(status.charges,0)
        }

        function test_quickMouseBindingDefaultsAndRemaps() {
            compare(Controls.quickPointer({}),{button:Qt.LeftButton,mods:Qt.ControlModifier})
            const custom={quickMouse:{button:Qt.MiddleButton,mods:Qt.AltModifier}}
            verify(Controls.valid(JSON.stringify(custom)))
            compare(Controls.label(Controls.read(JSON.stringify(custom)),"quickMouse"),"Alt+Middle button")
            verify(!Controls.valid(JSON.stringify({quickMouse:{button:99,mods:0}})))
            const old={quickMouse:{button:Qt.LeftButton,mods:0},quickStart:{key:Qt.Key_B,mods:0},
                reload:{key:Qt.Key_J,mods:0}}
            verify(!Controls.valid(JSON.stringify(old)))
            compare(Controls.read(JSON.stringify(old)),{reload:old.reload})
            verify(!Controls.valid(JSON.stringify({quickStart:{key:Qt.Key_Down,mods:Qt.ControlModifier}})))
            verify(Controls.valid(JSON.stringify({quickStart:{key:Qt.Key_Y,mods:Qt.ControlModifier}})))

        }

        function test_debugAutoIgnoresCareerLimit() {
            const auto=findChild(scene,"autoPlayButton")
            scene.autoLimit=0
            verify(!auto.enabled)
            scene.run.debug=true
            scene.run.wave=120
            scene.publish()
            verify(auto.enabled)
            mouseClick(auto,auto.width/2,auto.height/2,Qt.LeftButton)
            verify(scene.autoPlaying)
            scene.stopAuto()
        }

        function test_remapDirectionsHeldControlsAndPause() {
            scene.motion=false
            const proposed={left:{key:Qt.Key_J,mods:0},shield:{key:Qt.Key_K,mods:0},pause:{key:Qt.Key_P,mods:0},
                active1:{key:Qt.Key_U,mods:Qt.ControlModifier}}
            scene.controlBindings=JSON.stringify(proposed)
            verify(Controls.valid(scene.controlBindings))
            const overlap=Object.assign({},proposed,{right:{key:Qt.Key_J,mods:0}})
            verify(!Controls.valid(JSON.stringify(overlap)))
            keyClick(Qt.Key_A)
            compare(scene.frontId,"front")
            keyClick(Qt.Key_J)
            compare(scene.frontId,"left")
            keyPress(Qt.Key_K)
            verify(scene.run.shield.raised)
            keyRelease(Qt.Key_K)
            verify(!scene.run.shield.raised)
            scene.run.slots.active[0].item=Gear.makeItem("ward")
            scene.publish()
            keyClick(Qt.Key_U,Qt.ControlModifier)
            verify(Rules.activeCooldown(scene.run,"ward")>0)
            keyClick(Qt.Key_P)
            verify(scene.paused)
        }

        function test_skipEnemyPreviewKeepsManualWaveStart() {
            scene.resetRun()
            verify(scene.preparing)
            verify(scene.previewing)
            scene.showEnemyPreview=false
            verify(!scene.previewing)
            verify(scene.preparing)
            compare(scene.phase,"ready")
            verify(findChild(scene,"primaryPlayAction").visible)
        }

        function test_enemyMissAndCriticalReadoutsSurviveOtherNotices() {
            const foe=Rules.spawn(scene.run,{type:"veilskate",front:"up",lane:0})
            scene.run.aimSeed=2000
            Rules.damagePlayer(scene.run,5,"up",foe.type,false,{sourceId:foe.id,blindAtFire:3},true)
            Rules.damagePlayer(scene.run,5,"up",foe.type,false,{sourceId:foe.id,critical:true},true)
            Rules.announce(scene.run,"Another enemy arrived","arrive")
            scene.publish()
            const miss=findChild(scene,"hostileMissReadout")
            const crit=findChild(scene,"incomingCriticalReadout")
            verify(miss && crit)
            verify(miss.visible && miss.text.includes("VEILSKATE") && miss.text.includes("MISSED"))
            verify(crit.visible && crit.text.includes("7.5 HP"))
        }

        function test_shiftAimsOnlyWhileHeldAndProtectsEdgeAim() {
            keyPress(Qt.Key_Shift)
            compare(scene.scopeHeld,true)
            tryVerify(function() { return scene.magnification > 1 })
            mouseMove(scene,897,325)
            compare(scene.frontId,"front")
            keyRelease(Qt.Key_Shift)
            compare(scene.scopeHeld,false)
            tryCompare(scene,"magnification",1)
            mouseMove(scene,895,324)
            compare(scene.frontId,"front")
            mouseMove(scene,850,325)
            mouseMove(scene,897,325)
            compare(scene.frontId,"right")

            mouseMove(scene,450,325)
            keyPress(Qt.Key_Shift)
            compare(scene.scopeHeld,true)
            scene.pauseRun("build")
            compare(scene.scopeHeld,false)
            keyRelease(Qt.Key_Shift)
            scene.mainAction()
            tryCompare(scene,"magnification",1)
        }
        function test_cornerJitterDoesNotTurnAnAlreadyCrossedEdge() {
            mouseMove(scene,897,4)
            compare(scene.frontId,"right")
            keyClick(Qt.Key_A)
            compare(scene.frontId,"front")
            mouseMove(scene,893,2)
            compare(scene.frontId,"front")
            mouseMove(scene,450,52)
            mouseMove(scene,450,3)
            compare(scene.frontId,"up")
        }
        function test_staffChargeAndLeanFollowInput() {
            scene.run.slots.weapon[0].item=Gear.makeItem("firestaff")
            scene.publish()
            const gun=Gear.current(scene.run)
            const status=findChild(scene,"staffChargeStatus")
            const scope=findChild(scene,"weaponScope")
            keyPress(Qt.Key_Shift)
            tryCompare(scene,"magnification",1.065)
            compare(scene.aimingGun,false)
            compare(scene.accuracy,1)
            compare(scope.visible,false)
            const cost=scene.runeCost
            for (let i=1;i<=cost;i++) {
                gun.recovery=0
                scene.publish()
                mouseClick(scene,450,325,Qt.LeftButton)
                compare(scene.runes,i)
                verify(status.text.includes(i===cost ? "READY" : i+" / "+cost))
            }
            mouseClick(scene,450,325,Qt.RightButton)
            compare(scene.runes,0)
            compare(status.text,"CASTING")
            tryVerify(function() {return status.text.includes("0 / "+cost)},2500)
            scene.run.slots.weapon[0].item=Gear.makeItem("katana")
            scene.publish()
            compare(scene.aimingGun,false)
            compare(scope.visible,false)
            compare(scene.accuracy,1)
            keyRelease(Qt.Key_Shift)
            tryCompare(scene,"magnification",1)
        }
        function test_mouseToggleAndDragPreserveShootingControls() {
            scene.mouseTurns = false
            mouseMove(scene,897,325)
            compare(scene.frontId,"front")
            mouseMove(scene,450,325)
            scene.mouseTurns = true
            mousePress(scene,450,325,Qt.LeftButton)
            verify(scene.fireHeld)
            mouseMove(scene,897,325,0,Qt.LeftButton)
            compare(scene.frontId,"right")
            mouseRelease(scene,897,325,Qt.LeftButton)
            compare(scene.fireHeld,false)
        }
        function test_stickyRequiresAFreshEdgeCrossing() {
            scene.run.elements.sticky = 3
            scene.run.elements.stickyLeft = 5
            scene.publish()
            mouseMove(scene,897,325)
            compare(scene.frontId,"front")
            scene.run.elements.sticky = 0
            scene.run.elements.stickyLeft = 0
            scene.publish()
            mouseMove(scene,895,324)
            compare(scene.frontId,"front")
            mouseMove(scene,850,325)
            mouseMove(scene,897,325)
            compare(scene.frontId,"right")
        }

        function test_glitchInvertsAimTurnAndPairedControls() {
            scene.run.weatherEffect = "glitch"
            scene.run.slots.active[0].item = Gear.makeItem("ward")
            scene.run.slots.active.push({item:Gear.makeItem("overdrive"),power:"",powerLevel:0})
            scene.publish()
            scene.updateAim(350,200,0)
            compare(scene.pointer,Qt.point(550,450))
            keyClick(Qt.Key_A)
            compare(scene.frontId,"right")
            keyClick(Qt.Key_D)
            compare(scene.frontId,"front")
            keyClick(Qt.Key_Q)
            verify(scene.run.fastFire > 0)
            keyClick(Qt.Key_E)
            verify(scene.run.barrierHp > 0)
            const gun = Gear.current(scene.run)
            const loaded = gun.ammo
            mouseClick(scene,420,255,Qt.RightButton)
            compare(gun.ammo,loaded-1)
            mouseClick(scene,420,255,Qt.LeftButton)
            verify(gun.reload > 0)
        }

        function test_spaceShieldsAndFHoldsTheSeal() {
            scene.run.wave = 11
            keyClick(Qt.Key_S)
            compare(scene.frontId,"down")
            const crawler = Rules.spawn(scene.run,{ type:"crawler",front:"down",lane:86 })
            crawler.warp = 0
            scene.publish()
            keyPress(Qt.Key_Space)
            verify(scene.fieldGuard.raised)
            compare(scene.sealing,false)
            compare(scene.run.abyssSeal.progress,0)
            keyPress(Qt.Key_F)
            compare(scene.sealing,true)
            tryVerify(function() { return scene.run.abyssSeal.progress > 0 })
            keyRelease(Qt.Key_F)
            compare(scene.sealing,false)
            verify(scene.fieldGuard.raised)
            keyRelease(Qt.Key_Space)
            verify(!scene.fieldGuard.raised)
            verify(scene.fieldGuard.charge>0 && scene.fieldGuard.charge<.90)
        }

        function test_pauseShowsBuildStatsOnSoloRuns() {
            verify(!scene.run.pet)
            scene.pauseRun("build")
            const stats = findChild(scene,"buildCombatStats")
            verify(stats && stats.visible)
            verify(stats.text.includes("5.0% critical chance"))
        }

        function test_pauseLoadoutFitsMinimumWindowAndKeepsFrameSize() {
            fixture.width=760;fixture.height=530
            Ui.UiMetrics.textScale=1.35
            try {
                scene.run.inventory=Array(10).fill({group:"weapon",item:Gear.makeItem("pistol")})
                scene.pauseRun("build")
                const sheet=findChild(scene,"pauseSheet"), panel=findChild(scene,"fieldPanel")
                verify(sheet && panel)
                tryCompare(sheet.contentItem,"interactive",false)
                verify(sheet.contentHeight<=sheet.availableHeight+.1)
                const original=panel.height
                scene.pauseTab="settings"
                tryCompare(sheet.contentItem,"interactive",true)
                compare(panel.height,original)
                scene.pauseTab="build"
                tryCompare(sheet.contentItem,"contentY",0)
                compare(panel.height,original)
            } finally {
                fixture.width=900;fixture.height=650
                Ui.UiMetrics.textScale=1
            }
        }

        function test_releasingShieldAfterWaveDoesNotChooseAReward() {
            keyPress(Qt.Key_Space)
            scene.run.offers = [Rules.activeAbilities.ward]
            scene.run.phase = "reward"
            scene.publish()
            tryCompare(scene,"phase","reward")
            wait(50)
            keyRelease(Qt.Key_Space)
            compare(scene.phase,"reward")
            compare(scene.run.slots.active[0].item,null)
        }
    }
}
