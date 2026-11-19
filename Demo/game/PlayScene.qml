import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Rules.js" as Rules
import "Loadout.js" as Gear
import "Pets.js" as Pets
import "Elements.js" as Elements
import "Progress.js" as Progress
import "Defense.js" as Defense
import "Optics.js" as Optics
import "Conditions.js" as Conditions
import "Scenery.js" as Scenery
import "../../V0.1/kde/contents/ui/ViewTurn.js" as ViewTurn
import "SaveData.js" as SaveData
import "Tutorial.js" as Tutorial
import "Meta.js" as Meta
import "Selection.js" as Draw
import "Tarot.js" as Tarot
import "Autoplay.js" as Autoplay
import "Controls.js" as Controls

FocusScope {
    id: play
    objectName: "playScene"
    focus: true
    clip: wallpaperInsets===Qt.rect(0,0,0,0)

    required property url artDirectory
    required property bool allowed
    property bool interactive:allowed
    property bool backgroundPlay:false
    signal backgroundPlayRequested(bool enabled)
    property bool tutorial:false
    property var backgroundFiles:({})
    property int frameLimit:60
    property bool showTimer:false
    property real gameSpeed:1
    readonly property var speedSteps:[1,2,3,5,.5]
    property bool escapeBack:false
    property rect wallpaperInsets:Qt.rect(0,0,0,0)
    property int queuedAbility:-1
    property real queuedAbilityUntil:0
    property int autoLimit:0
    property bool autoPlaying:false
    property bool autoScoped:false
    property real autoAimUntil:0
    property real autoDecisionAt:0
    property int autoShopEdition:-1
    property var autoPlan:({})
    readonly property bool autoEligible:!run.training && !run.rehearsal && wave>0 && wave<=autoLimit
    signal timerRequested(bool value)
    signal frameLimitRequested(int value)
    readonly property bool trainingBlocked:{revision;return Tutorial.frozen(run)}
    readonly property bool trainingDialogue:{revision;return Tutorial.dialogue(run)}
    property bool software: false
    property bool sound: true
    property bool motion: true
    property var knownEnemies: []
    property string resumeState:""
    property string saveNotice:""
    property int graphicsDetail:1
    property int initialDetail:graphicsDetail
    property string graphicsRestartText:"Save your run, then restart Blackbox to fully apply this preset."
    property string transitionStyle:"cinematic"
    property real transitionStrength:1
    property bool bookVisible:false
    signal codexRequested(string chapter, string id)
    property bool autoSave:false
    property var vault:null
    property int seenLoot:0
    property int seenDeposit:0
    property bool gemsShown:false
    property var attemptReport:null
    property bool attemptArchived:false
    property bool retireArmed:false
    property string outcomeKind:""
    property real deathProgress:0
    property string previousPhase:"ready"
    property real swapOffset:0
    property int swappingTo:-1
    signal checkpointClosed(string id, double seed)
    signal saveRequested(string data, bool automatic)
    signal autoSaveRequested(bool enabled)
    // Keep the centre firing lane open at small window sizes.
    readonly property real hudZoom: Math.min(Ui.UiMetrics.hudScale, Math.max(.8,(height - 88) / 390), Math.max(.85,width / 790))
    property bool hudHidden:false
    property int hudTapKey:0
    property real hudFade:hudHidden ? 0 : 1
    readonly property bool fieldHudVisible:fighting && hudFade>0
    Behavior on hudFade {NumberAnimation {duration:play.motion ? 175 : 0}}
    signal hudScaleRequested(real scale)
    signal textScaleRequested(real value)
    signal detailRequested(int value)
    signal transitionStyleRequested(string value)
    signal transitionStrengthRequested(real value)
    property string wallpaperFit: "fill"
    property int wallpaperQuality: 0
    property real wallpaperZoom: 1
    property bool mouseTurns: true
    property bool wheelSwitch:true
    property bool showEnemyPreview:true
    property string controlBindings:"{}"
    readonly property var bindings:Controls.read(controlBindings)
    readonly property int shootButton:Controls.mouse(bindings,glitchInput ? "mouseReload" : "mouseFire")
    readonly property int reloadButton:Controls.mouse(bindings,glitchInput ? "mouseFire" : "mouseReload")
    readonly property bool previewing:showEnemyPreview && preparing && !paused
    property bool keyboardFire:false
    readonly property bool compactLayout: width < 900 || height < 650
    property int crossedMouseEdges: 0
    property real lastWheelSwitch: -1
    property int seed: Math.floor(Math.random() * 2147483647)
    signal exitRequested()
    signal audioLevelRequested(string key,real value)
    signal motionRequested()
    signal fitRequested(string value)
    signal qualityRequested(int value)
    signal zoomRequested(real value)
    signal mouseTurnsRequested(bool value)
    signal graphicsUnavailable()
    signal discovered(string group, string entry)
    signal careerDelta(var delta)

    property var unlockedGear: []
    property var run: Rules.create(0)
    property int reportedProgress: 0
    property var reportedMetrics: ({})
    property string achievementText: ""
    property var labAppearance:({})
    readonly property string viewedRoom:phase==="shop" ? "" : lab && !outcomeKind ? "right" : frontId
    onViewedRoomChanged: {
        if (viewedRoom==="right") labAppearance=Scenery.labVisit()
        else if (!turning) labAppearance=({})
    }
    onTurningChanged:if (!turning && viewedRoom!=="right") labAppearance=({})
    property string previousFront: "front"
    property string turnDirection: ""
    property real turnRatio: 1
    property int turnMs: 345
    property real aimX: width / 2
    property real aimY: height / 2
    property bool aimInitialized: false
    readonly property real frost: { revision; return 1 - Elements.pace(run.elements) }
    readonly property real blindness: { revision; return Rules.blindness(run) }
    readonly property int blindRank: { revision; return Rules.blindRank(run) }
    readonly property real blindStrength: {
        revision
        return Rules.blindStrength(run)*(1-abyssDepth)+Rules.blindStrength(run,true)*abyssDepth
    }
    readonly property bool hypnotised: { revision; return !!run.hypnosis }
    readonly property var grab: { revision; return run.grab }
    readonly property bool constricted: !!grab && grab.constrict
    readonly property real scareLeft:{revision; return run.scareTime}
    onScareLeftChanged: {
        if (scareLeft > 0) {
            fireHeld = false
            sealing = false
            heldShiftKeys = []
        }
    }
    readonly property bool inkStains: { revision; return run.inkStains }
    readonly property bool cursed: { revision; return run.cursed }
    readonly property point pointer: Qt.point(aimX, aimY)
    property var heldShiftKeys: []
    readonly property bool scopeHeld: heldShiftKeys.length > 0 || autoPlaying && autoScoped
    readonly property bool gunSights: Gear.hasGunSights(weapon)
    readonly property bool shiftActive: scopeHeld && fighting && !turning && !lunging && !constricted && !stunned
    readonly property bool aimingGun: gunSights && shiftActive
    readonly property var sight: Optics.optic(weapon)
    readonly property point sightCentre: Qt.point(Math.max(0,Math.min(1,aimX / Math.max(1,width))),
        Math.max(0,Math.min(1,aimY / Math.max(1,height))))
    readonly property point weaponAim: Qt.point((sightCentre.x-.5)*2,(sightCentre.y-.5)*2)
    readonly property point zoomCentre: gunSights ? sightCentre : Qt.point(.5,.5)
    property real magnification: shiftActive ? (gunSights ? sight.zoom : 1.065) : 1
    Behavior on magnification { NumberAnimation { duration: play.motion ? 155 : 0; easing.type: Easing.OutCubic } }
    readonly property real accuracy: {
        if (!gunSights) return 1
        const progress = Math.min(1,(magnification-1)/(sight.zoom-1))
        return (1 + progress * (sight.focus-1)) * magnification
    }
    readonly property bool infiniteAmmo: { revision; return Rules.unlimitedAmmo(run) }
    readonly property bool ammoWeapon: Gear.usesAmmo(weapon)
    readonly property bool canShoot: !ammoWeapon || rounds > 0 || infiniteAmmo
    readonly property var setupTerms: { revision; return phase==="ready" && !run.debug && vault ? Meta.contract(vault.state) : null }
    readonly property int refreshes: { revision; return Rules.refreshRemaining(run,setupTerms) }
    readonly property int rerollCost: { revision; return Rules.rerollPrice(run,setupTerms) }
    readonly property bool canReroll: { revision; return Rules.canReroll(run,setupTerms) }
    readonly property bool selecting: ["ready", "shop", "bossReward", "reward"].includes(phase)
    readonly property bool projectedMode: software || useProjectedView
    readonly property var availablePets: { revision; return run.petOffers.map(Pets.spec) }
    readonly property string petChoice: { revision; return run.petChoice }
    readonly property var startingWeapons: { revision; return run.starterOffers.map(function(id) { return Gear.weapons[id] }) }
    readonly property string starterChoice: { revision; return run.starterChoice || run.starterOffers[0] || "pistol" }
    readonly property bool draftingWeapon: { revision; return phase === "ready" && run.debugBuild === "standard" }
    readonly property var flyingPet: { revision; return run.pet }
    readonly property var petSpec: Pets.spec(flyingPet ? flyingPet.id : petChoice)
    readonly property string weather: { revision; return run.weatherEffect || Rules.weather(wave) }
    readonly property bool cloudy:{revision;return Conditions.hasWeather(weather,run.stage,"cloudy")}
    readonly property bool windy:{revision;return Conditions.hasWeather(weather,run.stage,"windy")}
    readonly property string weatherLabel:{revision;return Conditions.weatherLabel(weather,run.stage)}
    readonly property var surfaceSky:{revision;return Conditions.sky(run.skyPhase,run.waveTime,"front")}
    readonly property real abyssDepth:(previousFront==="down" ? 1-turnRatio : 0)+(frontId==="down" ? turnRatio : 0)
    readonly property var sky:{
        if (!abyssDepth) return surfaceSky
        const shade=Conditions.sky(daypart,0,"down")
        const result={}
        for(const key of ["dark","warm","red","sun","moon","sunX","sunY","moonX","moonY"])
            result[key]=surfaceSky[key]+(shade[key]-surfaceSky[key])*abyssDepth
        return result
    }
    readonly property bool takeover:{revision;return Rules.takeoverActive(run)}
    readonly property real takeoverTime:{revision;return run.takeoverTime}
    readonly property string daypart:{revision;return run.skyPhase}
    readonly property real obscurity:Conditions.obscurity(weather,cloudy)
    readonly property real solarYaw:-108+(sky.sunX-.40)*116
    readonly property color surfaceLight:surfaceSky.red>.12 ? Qt.tint("#a89fce",Qt.rgba(.88,.19,.29,surfaceSky.red*.65))
        : surfaceSky.dark>.55 && surfaceSky.warm<.25 ? "#a2b4e2" : Qt.tint("#ffead2",Qt.rgba(1,.39,.08,surfaceSky.warm*.61))
    readonly property color solarColor:Qt.tint(surfaceLight,Qt.rgba(.467,.400,.612,abyssDepth))
    readonly property bool glitchInput: fighting && weather === "glitch"
    readonly property real elapsed: { revision; return run.time }
    readonly property real distortion: { revision; return run.voidStorm ? .76 : run.distortion }
    readonly property bool voidStorm: { revision; return run.voidStorm }
    readonly property real shieldBreak: { revision; return run.barrierBreak }
    readonly property int shieldHp: { revision; return run.barrierHp+run.barrierCell.hp }
    readonly property real shieldRefill: { revision; return run.barrierRefill }
    readonly property real shieldTime: { revision; return run.barrier }
    readonly property real shieldCooldown: { revision; return Rules.barrierCooldown(run) }
    readonly property int shieldCapacity: { revision; return run.barrierMax+(run.barrierCell.level ? run.barrierCell.level+1 : Meta.benefits(run).barrier) }
    readonly property int barrierLevel: { revision; return run.barrierCell.level }
    readonly property var desktopTelemetry:{revision;return run.desktop ? Object.assign({},run.desktop) : ({})}
    readonly property var fieldGuard: {
        revision
        const guard = run.shield
        const mode = guard.raised || guard.cool ? guard.mode : Rules.shieldMode(run)
        return { level:guard.level,raised:guard.raised,age:guard.age,limit:guard.limit,charges:guard.charges,
            capacity:guard.capacity,cool:guard.cool,recovery:guard.recovery,impact:guard.flash,
            charge:Rules.shieldCharge(run),rejected:guard.rejected,
            mode:mode,tint:guard.raised || guard.cool ? guard.tint : Defense.modes[mode].tint }
    }
    readonly property real criticalFlash: { revision; return run.criticalFlash }
    // Rules updates the run in place. Bindings that read it also read this counter.
    property int revision: 0
    property int seenEvent: 0
    property int seenRoster: -1
    property int seenBolts: -1
    property int seenGifts: -1
    property int seenSmokes: -1
    property var smokes: []
    readonly property var guestPet: { revision; return run.guestPet }
    readonly property var tarotPet: { revision; return run.tarotPet }
    property var actors: []
    property var bolts: []
    property var gifts: []
    property string frontId: "front"
    property bool paused: false
    property string pauseTab: "build"
    property bool sealing: false
    property bool fireHeld: false
    property real accumulated: 0
    property real shotFlash: 0
    property real rotaryAngle: 0
    property var shotRays: []
    property bool useProjectedView: false
    property string selectedOffer: ""
    property var discoveries: ({})
    readonly property var location: Rules.front(turnRatio < .5 ? previousFront : frontId)
    readonly property string phase: { revision; return run.phase }
    readonly property bool fighting: phase === "combat" && allowed && !paused
    readonly property bool turning: turn.running || turnRatio < 1
    readonly property bool lab: phase === "shop" || phase === "reward" || phase === "bossReward"
    readonly property bool preparing:phase === "between" || phase === "ready"
    readonly property var upcomingStage: {revision; return run.nextStage || run.stage || Rules.prepareStage(run)}
    readonly property bool unclaimedPurchase: {
        revision
        return phase === "shop" && run.shopStock.some(function(card) { return card.paid && !card.sold })
    }
    readonly property real stunLeft: { revision; return Rules.stunTime(run) }
    readonly property bool stunned: stunLeft > 0
    readonly property bool turnLocked: { revision; return !Rules.canTurn(run) }
    readonly property real poisonFog: { revision; return Rules.poisonFog(run, frontId) }
    readonly property var weapon: { revision; return Rules.weapons[Gear.current(run).id] }
    readonly property bool handWeapon: !!weapon.melee || !!weapon.throwing || !!weapon.stab
    readonly property var axes: { revision; return run.axes }
    readonly property int rounds: { revision; return Gear.current(run).ammo }
    readonly property real shotTime: { revision; return Gear.current(run).recovery }
    readonly property real reloadTime: { revision; return Gear.current(run).reload }
    readonly property real prepTime: { revision; return Gear.current(run).prep || 0 }
    readonly property real cooling: { revision; return Gear.current(run).cool || 0 }
    readonly property real heat: {
        revision
        const item = Gear.current(run)
        return weapon.sustain ? Math.min(1, item.heat / Rules.heatLimit(run, weapon, Gear.weaponStats(item))) : 0
    }
    readonly property bool sustainedFire: { revision; return (fireHeld || autoPlaying && !!autoPlan.point) && !fieldGuard.raised && !turning && !stunned && !!Gear.current(run).firing }
    readonly property bool primed: { revision; return !!Gear.current(run).primed }
    readonly property bool chargedStrike: { revision; return !!Gear.current(run).chargedStrike }
    readonly property int shotSequence: { revision; return Gear.current(run).sequence || 0 }
    readonly property int combo: { revision; return Gear.current(run).combo || 0 }
    readonly property bool comboLive: { revision; return combo > 0 && run.time <= Gear.current(run).comboUntil }
    readonly property int runes: { revision; return Gear.current(run).charge || 0 }
    readonly property bool casting: { revision; return Gear.current(run).castTime > 0 }
    readonly property int runeCost: { revision; return Gear.effectiveWeaponStats(run,Gear.current(run)).chargeCost }
    readonly property int streak: { revision; return Gear.current(run).streak || 0 }
    readonly property bool bayonet: { revision; return ammoWeapon && Gear.passiveRank(run,"bayonet") > 0 }
    readonly property real stab: { revision; return motion ? Math.sin(Math.PI * run.bayonetTime / .32) : 0 }
    readonly property real evade: { revision; return run.dodgeFlash / .34 }
    readonly property var orbit: { revision; return Rules.orbitGuard(run) }
    readonly property bool lunging: { revision; return !!run.lunge }
    readonly property var dash: { revision; return Rules.lungeOffset(run) }
    readonly property real strikeLife: { revision; return lunging ? run.meleeImpact : Math.max(shotFlash,run.meleeImpact) }
    readonly property real reloadRatio: {
        revision
        const gun = Gear.current(run)
        return gun.prep > 0 ? 1 - gun.prep / gun.prepLength : gun.reload > 0 ? 1 - gun.reload / gun.reloadLength : 0
    }
    readonly property real spin: { revision; return Gear.current(run).spin || 0 }
    readonly property bool winding: !!weapon.spinup && fireHeld && spin < 1 && canShoot && !reloadTime && !prepTime && !cooling && !stunned
    readonly property string gold: { revision; return Number.isFinite(Gear.availableGold(run)) ? String(run.gold) : "∞" }
    readonly property real healthRatio: { revision; return run.health / Gear.maxHealth(run) }
    property bool pressureMusic: false
    onHealthRatioChanged: {
        if (healthRatio <= .31)
            pressureMusic = true
        else if (healthRatio >= .39)
            pressureMusic = false
    }
    readonly property var selectedCard: {
        revision
        return run.offers.find(function(card) { return card.id === selectedOffer })
    }
    readonly property string selectedGroup: selectedCard ? Gear.groupOf(selectedCard) : ""
    readonly property real shotReady: {
        revision
        return prepTime || reloadTime ? reloadRatio : cooling ? 1 - heat : winding ? spin
            : sustainedFire ? 1 - heat : canShoot ? Math.max(0, 1 - shotTime / Gear.current(run).cycle) : 0
    }
    readonly property int wave: { revision; return run.wave }
    readonly property int remaining: { revision; return Rules.remainingEnemies(run) }
    readonly property int summons: {
        revision
        return run.enemies.filter(function(enemy) { return enemy.summoned }).length
    }
    readonly property var boss: {
        revision
        const active = run.enemies.find(function(enemy) { return Rules.enemyTypes[enemy.type].role === "boss" })
        return active ? { health:active.hp, maxHealth:active.maxHp, title:Rules.enemyTypes[active.type].title,
            tint:Rules.enemyTypes[active.type].accent, id:active.type, entering:active.warp > 0 && ["drop","rise"].includes(active.warpKind),
            waiting:active.waitingBoss, front:active.front,
            fangs:active.fangs ? active.fangs.filter(function(fang) { return fang.hp > 0 }).length : -1 } : null
    }
    readonly property string bossDirection: boss && boss.waiting ? Rules.directionToward(frontId,boss.front) : ""
    readonly property string musicVariation: phase === "shop" ? "" : pressureMusic ? "pressure" : boss && boss.health <= boss.maxHealth * .5 ? "climax" : ""
    readonly property string musicTrack: {
        if (phase === "ready" || phase === "defeat" || wave < 1)
            return "home"
        if (phase === "shop")
            return "shop"
        if (boss && !boss.waiting)
            return boss.entering ? "" : boss.id
        const rotation = ["frontier", "fracture", "embers"]
        return rotation[Math.floor((wave - 1) / 10) % rotation.length]
    }
    readonly property var shake: { revision; return Rules.cameraJolt(run) }
    readonly property var impact: {
        revision
        const attacker = Rules.enemyTypes[run.impactType]
        return attacker ? { color: attacker.accent, strength: run.impactTime / attacker.shake[2] }
            : { color: "transparent", strength: 0 }
    }
    readonly property real powerFlash: { revision; return run.powerFlash }
    readonly property string frozenFront:{revision;return run.frozenTime>0 ? run.frozenFront : ""}
    readonly property var turns: ({
        left: Rules.turnFrom(frontId, "left"),
        right: Rules.turnFrom(frontId, "right"),
        up: Rules.turnFrom(frontId, "up"),
        down: Rules.turnFrom(frontId, "down")
    })
    readonly property var frontStatus: { revision; return Rules.threatCounts(run) }
    readonly property var warnings: Rules.offscreenThreats(frontId, frontStatus)
    readonly property Item worldItem: worldLoader.item
    readonly property var sealState: {
        revision
        return Rules.sealTarget(run, frontId)
    }
    readonly property real sealProgress: { revision; return sealState ? sealState.progress : 0 }
    readonly property bool sealClosed: { revision; return !!sealState && sealState.closed }

    function keyTargetFocus() {if (interactive) keyTarget.forceActiveFocus()}

    function syncTrainingView() {
        if (!run.training || run.playerFront===frontId) return
        turn.stop()
        turnAnimation.stop()
        turnRatio=1
        frontId=run.playerFront
        previousFront=frontId
    }

    function advanceTraining() {
        if (run.training.mode==="won") {
            exitRequested()
            return
        }
        Tutorial.advance(run)
        syncTrainingView()
        publish()
        keyTargetFocus()
    }

    function updateAim(x, y, dt) {
        const progress = !aimInitialized || frost <= 0 ? 1 : Math.min(1, dt * (18 - frost * 21))
        if (progress <= 0)
            return
        if (glitchInput) {
            x = width-x
            y = height-y
        }
        aimX += (x - aimX) * progress
        aimY += (y - aimY) * progress
        aimInitialized = true
    }

    function edgeTurn(x, y) {
        if (!mouseTurns || !fighting || turning || x < 0 || x >= width || y < 0 || y >= height)
            return
        const boundary = Math.max(16, Math.min(30, Math.min(width, height) * .034))
        const directions = ["left", "right", "up", "down"]
        const gaps = [x, width - x, y, height - y]
        let crossed = crossedMouseEdges
        let nearest = -1
        for (let i = 0; i < directions.length; ++i) {
            const mask = 1 << i
            if (gaps[i] > boundary + 10) {
                crossed &= ~mask
            } else if (gaps[i] <= boundary && !(crossed & mask)) {
                crossed |= mask
                if (turns[Rules.turnInput(run,directions[i])] !== frontId && (nearest === -1 || gaps[i] < gaps[nearest]))
                    nearest = i
            }
        }
        crossedMouseEdges = crossed
        if (nearest >= 0 && !scopeHeld)
            turnView(directions[nearest])
    }

    function setShiftKey(code, pressed) {
        if (pressed && !heldShiftKeys.includes(code))
            heldShiftKeys = heldShiftKeys.concat(code)
        else if (!pressed)
            heldShiftKeys = heldShiftKeys.filter(function(key) { return key !== code })
    }

    function equipWeapon(slot) {
        if (swapMotion.running || !Rules.canAct(run) || !run.slots.weapon[slot]?.item || run.selectedWeapon===slot)
            return
        fireHeld=false
        if (!motion) {finishEquip(slot);return}
        swappingTo=slot
        swapMotion.restart()
    }

    function finishEquip(slot) {
        if (!Rules.selectWeapon(run,slot)) return
        fireHeld = false
        shotFlash = 0
        publish()
    }

    function tutorialControls(message) {
        const names={
            "R":Controls.label(bindings,"reload"),"right-click":Controls.buttonNames[Controls.buttons.indexOf(reloadButton)],
            "Space":Controls.label(bindings,"shield"),"SPACE":Controls.label(bindings,"shield").toUpperCase(),
            "Q":Controls.label(bindings,"active1"),"Shift":Controls.label(bindings,"aim"),
            "A or the left arrow":Controls.label(bindings,"left"),"D":Controls.label(bindings,"right")
        }
        return message.replace(/(right-click|A or the left arrow|Space|SPACE|Shift|R|Q|D)/g,term=>names[term])
    }

    function beginFiring(x,y) {
        fireHeld=true
        if (!fieldGuard.raised && weapon.spinup && canShoot && !reloadTime && !prepTime && !cooling && audio.item)
            audio.item.play(weapon.id==="chainsaw" ? "sawRev" : weapon.chargeEachShot ? "starCharge" : "spinup")
        if (aim.containsMouse) updateAim(x,y,0)
        if (!aimInitialized) updateAim(width*.5,height*.5,0)
        fire(pointer.x,pointer.y)
    }

    function reloadGun() {
        if (!fighting || bookVisible || trainingBlocked || turning || swapMotion.running)
            return
        const targets = worldItem && aim.containsMouse
            ? weapon.staff ? [aimAt(pointer.x, pointer.y)] : bayonet || weapon.stab ? swingTargets(pointer.x, pointer.y, height * .023) : []
            : []
        if (Rules.reload(run, targets, frontId, {x:pointer.x / width,y:pointer.y / height}))
            publish()
    }

    function activateAbility(index, physical) {
        if (!fighting || bookVisible || trainingBlocked || autoPlaying)
            return false
        const slot=physical ? Rules.slotInput(run,index) : index
        const id=run.slots.active[slot]?.item?.id
        const remaining=id ? Rules.activeCooldown(run,id) : 0
        if (id && (turning || remaining>0 && remaining<.24)) {
            queuedAbility=slot
            queuedAbilityUntil=run.time+(turning ? .65 : .25)
            return false
        }
        const point=worldItem && aim.containsMouse ? {x:pointer.x/width,y:pointer.y/height} : null
        const cast=Rules.useAbility(run,slot,frontId,point ? aimAt(pointer.x,pointer.y) : 0,point)
        publish()
        return cast
    }

    function abilityTile(index) {
        const slot = run.slots.active[index] || null
        if (!slot || !slot.item)
            return { available:!!slot, ability:null, level:0, cooldown:0, duration:1,
                upgradeColor:Gear.slotUpgradeColor("active", slot) }
        return { available:true, ability:Gear.activeAbilities[slot.item.id], level:slot.item.level,
            cooldown:Rules.activeCooldown(run, slot.item.id), duration:Rules.abilityRecovery(run, slot),
            upgradeColor:Gear.slotUpgradeColor("active", slot) }
    }

    function learn(group, entry) {
        const key = group + ":" + entry
        if (!discoveries[key]) {
            discoveries[key] = true
            discovered(group, entry)
        }
    }

    function announceAchievements(earned) {
        achievementText = earned.length === 1 ? "Unlocked · " + earned[0] : earned.length + " achievements unlocked"
        achievementNotice.restart()
    }

    function publish() {
        if (run.phase==="ready" && !run.debug && !run.training && !run.covenant && !run.quickStart)
            run.entryWave=vault ? Meta.startWave(vault.state) : 1
        if (run.phase === "ready" || run.phase === "between")
            Rules.prepareStage(run)
        if (seenDeposit!==run.gemSerial) {
            seenDeposit=run.gemSerial
            if (vault && run.attemptId && !run.debug && !run.training && !run.rehearsal)
                vault.deposit(run.attemptId,run.fieldGems)
        }
        if (reportedProgress !== run.progress) {
            const delta = {}
            for (const name of Object.keys(run.metrics)) {
                const value = run.metrics[name]
                const previous = reportedMetrics[name] || 0
                if (value > previous)
                    delta[name] = Progress.keepsBest(name) ? value : value - previous
            }
            reportedMetrics = Object.assign({}, run.metrics)
            reportedProgress = run.progress
            const report={}
            for(const key of Object.keys(delta))
                if(!run.rehearsal && !["loadSamples","loadBurden","damageTaken","unblockedHits","shopBuys","shopSpent"].includes(key)
                    && (!run.debug || /^(enemyKills_|enemyDeaths_|weaponKills_)/.test(key) || key==="trainingWins")) report[key]=delta[key]
            if (Object.keys(report).length)
                careerDelta(report)
        }
        if (seenRoster !== run.roster) {
            actors = run.enemies.slice()
            seenRoster = run.roster
        }
        if (seenBolts !== run.boltRoster) {
            bolts = run.bolts.slice()
            seenBolts = run.boltRoster
        }
        if (seenGifts !== run.giftRoster) {
            gifts = run.gifts.slice()
            seenGifts = run.giftRoster
        }
        if (seenSmokes !== run.smokeRoster) {
            smokes = run.smokes.slice()
            seenSmokes = run.smokeRoster
        }
        revision += 1
        if (fighting && !play.turning && worldItem) {
            for (const enemy of actors) {
                if (enemy.front === frontId && !enemy.waitingBoss && enemy.warp <= 0)
                    learn("enemies", enemy.type)
            }
        } else if (phase === "reward" && allowed && !paused) {
            for (const card of run.offers) {
                if (card.category === "Active" || card.category === "Passive")
                    learn("abilities", card.id)
            }
        } else if (phase === "shop" && allowed && !paused) {
            for (const card of run.shopStock) {
                if (card.action === "power")
                    learn("abilities", card.powerId)
                if (card.action === "gear")
                    learn("abilities", card.gearId)
            }
        }
        showLoot()
        playSounds()
    }

    function showLoot() {
        if (seenLoot===run.lootSerial) return
        for (const event of run.lootEvents) {
            if (event.id<=seenLoot || !fighting) continue
            let x=width*.52, y=height*.48
            if (worldItem && event.front===frontId) {
                const point=worldItem.projection(event.lane,event.elevation,event.depth)
                const mapped=lootLayer.mapFromItem(worldItem,point.x,point.y)
                x=Math.min(width*.92,Math.max(width*.08,mapped.x))
                y=Math.min(height*.85,Math.max(height*.18,mapped.y))
            }
            const target=lootLayer.mapFromItem(coinBalance,event.kind==="gem" ? coinBalance.width+24 : coinBalance.width*.5,coinBalance.height*.5)
            lootLayer.launch(event,Qt.point(x,y),target)
        }
        seenLoot=run.lootSerial
    }

    function playSounds() {
        if (seenEvent === run.event)
            return
        if (audio.item && allowed && !paused) {
            for (const soundEvent of run.cues) {
                if (soundEvent.id > seenEvent && (soundEvent.cue!=="loss" || outcomeKind!=="dying"))
                    audio.item.play(soundEvent.cue)
            }
        }
        seenEvent = run.event
    }

    function saveCheckpoint(automatic) {
        if (run.rehearsal || automatic && (!autoSave || run.debug || run.training)) return
        if (!run.attemptId) run.attemptId=newAttemptId()
        const saved=SaveData.encodeRun(run)
        if (saved) saveRequested(saved,automatic)
        else if (!automatic) saveNotice="Save unavailable"
    }

    function restoreRun(restored) {
        if (vault) vault.reload()
        if (!restored || SaveData.isClosed(restored,vault?.state)) return false
        stopAuto()
        if (!restored.attemptId) restored.attemptId=SaveData.checkpointId(restored)
        turn.stop()
        turnAnimation.stop()
        turnRatio=1
        paused=restored.phase==="combat"
        run=restored
        if (vault?.state.started[run.attemptId]?.autoUsed) run.usedAuto=true
        frontId=previousFront=restored.playerFront
        reportedMetrics=Object.assign({},restored.metrics)
        reportedProgress=restored.progress
        seenEvent=restored.event
        seenLoot=restored.lootSerial
        seenDeposit=0
        gemsShown=false
        lootLayer.clear()
        seenRoster=seenBolts=seenGifts=seenSmokes=-1
        selectedOffer=""
        saveNotice=""
        publish()
        Qt.callLater(giveMenuFocus)
        return true
    }

    function startWave(skipPet) {
        if (!allowed || paused || outcomeKind)
            return
        if (draftingWeapon)
            Rules.chooseStarter(run,starterChoice)
        if (skipPet && run.phase==="ready") run.petChoice=""
        if (!run.attemptId) run.attemptId=newAttemptId()
        if (run.phase==="ready" && !run.debug && !run.training && !run.covenant) {
            if (vault) Rules.applyCovenant(run,vault.reserve(run.attemptId,run.quickStart))
        }
        if (!Rules.startWave(run))
            return
        readyBattle()
        saveCheckpoint(true)
    }

    function prepareQuickRun() {
        if (!run.debug && !run.training && run.wave && SaveData.phases.includes(run.phase))
            saveCheckpoint(false)
        resetRun()
        run.quickStart=true
        run.entryWave=1
        run.nextStage=null
        Rules.chooseStarter(run,run.starterOffers[Math.floor(Math.random()*run.starterOffers.length)])
        Rules.choosePet(run,run.petOffers[Math.floor(Math.random()*run.petOffers.length)])
    }

    function newAttemptId() {
        return Date.now().toString(36)+"-"+Math.floor(Math.random()*0xffffffff).toString(36)+"-"+run.seed.toString(36)
    }

    function finishAttempt() {
        if (vault?.state.started[run.attemptId]?.autoUsed) run.usedAuto=true
        attemptReport=Meta.report(run,run.finishReason || "death",Gear.loadRating(run))
        attemptArchived=false
        const legacyId="legacy-run-"+run.seed
        if (vault && vault.settle(attemptReport,legacyId))
            careerDelta({["grade"+Meta.familyOf(attemptReport.grades.overall)]:1})
        checkpointClosed(run.attemptId,run.seed)
    }

    function readyBattle() {
        previousFront = "front"
        turnRatio = 1
        frontId = "front"
        selectedOffer = ""
        sealing = false
        heldShiftKeys = []
        fireHeld = false
        crossedMouseEdges = 0
        lastWheelSwitch = -1
        shotFlash = 0
        accumulated = 0
        publish()
        keyTargetFocus()
    }

    function resetRun() {
        stopAuto()
        outcomeTimer.stop()
        deathSequence.stop()
        deathProgress=0
        outcomeKind=""
        previousPhase="ready"
        attemptReport=null
        retireArmed=false
        turn.stop()
        turnAnimation.stop()
        turnRatio = 1
        paused = false
        sealing = false
        heldShiftKeys = []
        crossedMouseEdges = 0
        fireHeld = false
        aimInitialized = false
        accumulated = 0
        selectedOffer = ""
        shotRays = []
        rotaryAngle = 0
        reportedMetrics = {}
        reportedProgress = 0
        achievementText = ""
        seenRoster = -1
        seenBolts = -1
        seenGifts = -1
        seenSmokes = -1
        seenEvent = 0
        shotFlash = 0
        previousFront = "front"
        frontId = "front"
        seenLoot=seenDeposit=0
        gemsShown=false
        lootLayer.clear()
        run = run.training ? Tutorial.create(run.seed+1,unlockedGear) : Rules.create(run.seed+1,unlockedGear)
        publish()
        Qt.callLater(giveMenuFocus)
    }

    function skipSelection() {
        if (!allowed || paused || outcomeKind)
            return
        if (run.phase==="ready") {startWave(true);return}
        if (!Rules.skipSelection(run))
            return
        selectedOffer = ""
        publish()
        saveCheckpoint(true)
    }

    function refreshSelection() {
        if (!allowed || paused || outcomeKind || !Rules.refresh(run,setupTerms))
            return
        selectedOffer = ""
        publish()
        if (run.phase!=="ready") saveCheckpoint(true)
    }

    function directionTo(id) {
        return id === frontId ? "" : Object.keys(turns).find(function(direction) {
            return play.turns[direction] === id
        }) || ""
    }

    function turnView(direction) {
        if (!fighting || bookVisible || trainingBlocked || stunned || turnLocked || play.turning || lunging)
            return
        keyTargetFocus()
        direction = Rules.turnInput(run,direction)
        const destination = turns[direction]
        turnTo(destination,direction)
    }

    function turnTo(destination,direction) {
        if (!fighting || bookVisible || trainingBlocked || stunned || turnLocked || turning || lunging
            || !destination || !Rules.lookFront(run,destination)) return
        keyTargetFocus()
        sealing = false
        turnMs = Math.max(90,Math.round(Rules.turnDuration(run)/gameSpeed))
        if (audio.item)
            audio.item.play("turn")
        previousFront = frontId
        turnDirection = direction || Rules.directionToward(frontId,destination)
        if (motion) {
            turnRatio = 0
            turn.restart()
        }
        frontId = destination
        if (run.training) run.training.front=destination
        if (motion)
            turnAnimation.restart()
        publish()
    }

    function aimAt(x, y) {
        const point = worldItem.mapFromItem(aim, x, y)
        return worldItem.pickTarget(point.x, point.y)
    }

    function swingTargets(x, y, radius) {
        const candidates = new Set()
        for (const offset of [[0,0],[-.68,-.22],[.68,.22],[-.32,.51],[.32,-.51]]) {
            const point = worldItem.mapFromItem(aim, x + radius * offset[0], y + radius * offset[1])
            for (const target of worldItem.pickTargets(point.x, point.y))
                candidates.add(target)
        }
        return Array.from(candidates)
    }

    function fire(x, y, continuation) {
        if (!fighting || bookVisible || trainingBlocked || stunned || constricted || play.turning || lunging || fieldGuard.raised || !worldItem
            || (!continuation && shotTime > 0) || reloadTime || prepTime || cooling || swapMotion.running)
            return
        if (!Tutorial.readyToFire(run,aimingGun)) {
            fireHeld=false
            publish()
            return
        }
        const rays = weapon.spread || [[0, 0]]
        const pattern = Rules.spread(run,aimingGun) * accuracy
        const shipShots = weapon.penetration ? new Set(run.bolts.filter(function(bolt) {
            return bolt.source === "hasasasa" && Rules.pickableBolt(bolt, play.frontId)
        }).map(function(bolt) { return bolt.id })) : null
        const traces = rays.map(function(offset) {
            const px = x + offset[0] * play.height * pattern
            const py = y + offset[1] * play.height * pattern
            let hitIds = []
            const eyes=new Set(), outer=new Set()
            if (px >= 0 && px < play.width && py >= 0 && py < play.height) {
                const point = worldItem.mapFromItem(aim, px, py)
                if (weapon.penetration) {
                    const targets = worldItem.pickTargets(point.x, point.y,eyes,outer)
                    const intercept = targets.findIndex(function(id) { return shipShots.has(id) })
                    const reach = intercept < 0 ? weapon.penetration : Math.min(weapon.penetration, intercept + 1)
                    hitIds = targets.slice(0, reach)
                } else {
                    hitIds = worldItem.pickTargets(point.x,point.y,eyes,outer).slice(0,1)
                }
            }
            return { x:px, y:py, dx:px-x, dy:py-y, hit:hitIds[0] || 0, targets:hitIds,eyes:hitIds.filter(id=>eyes.has(id)),
                contacts:hitIds.map(id=>({id:id,zone:eyes.has(id) ? "eye" : outer.has(id) ? "outer" : "body"})) }
        })
        const targets = weapon.melee ? swingTargets(x, y, Math.max(weapon.aim, height * weapon.aim / 650) * .74)
            : traces.reduce(function(all, trace) { return all.concat(trace.targets) }, [])
        commitShot(targets,traces,{x:x/width,y:y/height,scoped:aimingGun,contacts:traces.reduce((all,ray)=>all.concat(ray.contacts),[])},continuation)
    }

    function commitShot(targets,traces,point,continuation) {
        const fired = Rules.shoot(run, targets, frontId,point,continuation)
        if (fired) {
            shotRays = traces
            shotFlash = motion ? weapon.afterglow : Math.min(.10, weapon.afterglow)
            if (audio.item && !weapon.sustain && !weapon.throwing)
                audio.item.play("fire")
        }
        publish()
        if (fired && weaponFeedback.ultra && motion && Gear.usesAmmo(weapon) && !Gear.current(run).coinShot) {
            const barrel = heldWeapon.muzzle
            const grip = heldWeapon.mapToItem(play, heldWeapon.width * .5, heldWeapon.height * .69)
            weaponFeedback.ejectCase(weapon, shotSequence, barrel, grip)
        }
    }

    function stopAuto() {
        if (!autoPlaying) return
        autoPlaying=false
        autoScoped=false
        autoAimUntil=0
        autoPlan=({})
        sealing=false
        fireHeld=false
        Rules.holdShield(run,false)
    }

    function toggleAuto() {
        if (autoPlaying) stopAuto()
        else if (fighting && autoEligible) {
            autoPlaying=true
            run.usedAuto=true
            if (!run.debug && vault && run.attemptId) vault.markAuto(run.attemptId)
            autoPlan=({})
            autoShopEdition=-1
            autoDecisionAt=run.time+.24
            fireHeld=false
            heldShiftKeys=[]
        }
        keyTargetFocus()
    }

    function autoCombat(frameTime) {
        if (!autoEligible) {stopAuto();return null}
        if (turning || !Rules.canAct(run)) {
            sealing=false
            return null
        }
        const deciding=run.time>=autoDecisionAt
        if (deciding) {
            autoDecisionAt=run.time+.17+Math.random()*.11
            autoPlan=Autoplay.plan(run)
            if (!gunSights || !autoPlan.enemy) autoScoped=false
            else if (run.time>=autoAimUntil) {
                autoScoped=Math.random()<(autoPlan.point.depth>1000 ? .52 : .30)
                autoAimUntil=run.time+(.8+Math.random()*1.2)*gameSpeed
            }
            Rules.holdShield(run,autoPlan.guard)
            if (autoPlan.direction && !run.shield.raised) {
                sealing=false
                turnView(Rules.turnInput(run,autoPlan.direction))
                return null
            }
        }
        sealing=!!autoPlan.seal
        if (!autoPlan.point || !worldItem) return null
        const point=autoPlan.enemy && !autoPlan.enemy.turrets ? Rules.arcPoint(autoPlan.enemy) : autoPlan.point
        const projected=Optics.project(worldItem.width,worldItem.height,point.lane,point.elevation,point.depth,Qt.point(.5,.5),1)
        const screen=worldItem.mapToItem(aim,projected.x,projected.y)
        const x=Math.max(3,Math.min(width-3,screen.x))
        const y=Math.max(3,Math.min(height-3,screen.y))
        if (!Number.isFinite(x) || !Number.isFinite(y)) return null
        const follow=1-Math.exp(-frameTime*13)
        aimX+=(x-aimX)*follow
        aimY+=(y-aimY)*follow
        const sight={x:pointer.x/width,y:pointer.y/height,aspect:width/height,scoped:aimingGun}
        const gun=Gear.current(run)
        const hits=[autoPlan.id]
        if (deciding && !run.shield.raised) {
            if (weapon.staff && runes>=runeCost || weapon.melee && !gun.primed && point.depth>280 && gun.recovery<=0)
                Rules.reload(run,hits,frontId,sight)
            const slot=run.slots.active.findIndex(entry => entry.item && !Rules.activeCooldown(run,entry.item.id)
                && Gear.environmentMatches(run,Gear.activeAbilities[entry.item.id].environment))
            if (slot>=0 && autoPlan.enemy && Math.random()<.43)
                Rules.useAbility(run,slot,frontId,autoPlan.enemy.id,sight)
        }
        const burst=Rules.queuedShot(run)
        if (burst || gun.recovery<=0 && (!weapon.spinup || gun.spin>=1)) {
            const pellets=weapon.spread?.length || 1
            const landed=Math.random()<.87 ? Math.max(1,Math.ceil(pellets*(point.depth<450 ? .76 : .40))) : 0
            const traces=[{x:pointer.x,y:pointer.y,dx:0,dy:0,hit:landed ? autoPlan.id : 0}]
            commitShot(Array(landed).fill(autoPlan.id),traces,sight,burst)
        }
        return sight
    }

    function pickReward(id, slot) {
        if (!allowed || paused || outcomeKind || phase !== "reward")
            return
        const card = run.offers.find(function(offer) { return offer.id === id })
        if (card && card.category !== "Supply" && slot === undefined && Gear.defaultSlot(run, card) === -1) {
            selectedOffer = id
            return
        }
        if (Rules.choose(run, id, slot)) {
            if (audio.item)
                audio.item.play("flask")
            selectedOffer = ""
            publish()
        }
    }

    function giveMenuFocus() {
        if (!interactive || !allowed || fighting || bookVisible || outcomeKind)
            return
        if (phase==="defeat") {postcard.item?.forceActiveFocus();return}
        const choice = phase === "reward" && !paused
            ? rewardList.itemAt(0) : phase === "bossReward" && !paused ? boonList.itemAt(0) : primaryAction
        if (choice && choice.visible && choice.enabled)
            choice.forceActiveFocus()
    }

    function mainAction() {
        if (!allowed || outcomeKind)
            return
        if (paused) {
            paused = false
            if (fighting)
                keyTarget.forceActiveFocus()
            else
                publish()
        } else if (phase === "defeat") {
            resetRun()
        } else if (phase === "shop") {
            skipSelection()
        } else if (phase === "ready" || phase === "between") {
            startWave()
        }
    }

    function handleEscape() {
        if (outcomeKind) return
        if (!paused && fighting && escapeBack && frontId!=="front" && !turning)
            turnTo("front",Rules.directionToward(frontId,"front"))
        else if (paused)
            mainAction()
        else if (phase === "combat" || phase === "between" || phase === "ready" || lab)
            pauseRun("build")
        else
            exitRequested()
    }

    function pauseRun(tab) {
        if (phase === "combat" || phase === "between" || lab || phase === "ready" && tab) {
            if (tab || !paused)
                pauseTab = tab || "build"
            paused = true
            sealing = false
            fireHeld = false
            accumulated = 0
            shotFlash = 0
            turn.stop()
            turnAnimation.stop()
            turnRatio = 1
        }
    }

    function switchToProjectedView() {
        useProjectedView = true
        graphicsUnavailable()
    }

    onAllowedChanged: {
        if (!allowed)
            pauseRun()
        else
            Qt.callLater(giveMenuFocus)
    }
    onInteractiveChanged: if (!interactive) {
        hudTapKey=0
        fireHeld=false
        heldShiftKeys=[]
        if (!autoPlaying) {
            sealing=false
            Rules.holdShield(run,false)
        }
    }
    onPhaseChanged: {
        const finished=previousPhase==="combat"
        previousPhase=phase
        if (phase==="defeat") {stopAuto();finishAttempt()}
        if (finished && ["between","reward","bossReward","defeat"].includes(phase) && !run.training) {
            if (phase==="defeat") {
                deathProgress=0
                outcomeKind="dying"
                deathSequence.restart()
                if (audio.item) audio.item.play("playerDeath")
            } else {
                outcomeKind="win"
                outcomeTimer.restart()
            }
        }
        if (phase!=="combat") {
            saveNotice=""
            Qt.callLater(giveMenuFocus)
        }
    }
    onPausedChanged: {
        if (!paused) retireArmed=false
        if (!fighting) Qt.callLater(giveMenuFocus)
    }
    onUnlockedGearChanged: Rules.updateCareerUnlocks(run, unlockedGear)
    Component.onCompleted: {
        const restored = !tutorial && resumeState ? SaveData.decodeRun(resumeState,unlockedGear) : null
        if (!restored || !restoreRun(restored)) {
            run = tutorial ? Tutorial.create(seed,unlockedGear) : Rules.create(seed,unlockedGear)
            publish()
        }
        Qt.callLater(giveMenuFocus)
    }
    onFightingChanged: {
        if (!fighting) {
            hudTapKey=0
            keyboardFire=false
            queuedAbility=-1
            sealing = false
            fireHeld = false
            shotFlash = 0
            heldShiftKeys = []
            crossedMouseEdges = 0
            swapMotion.stop()
            swapOffset=0
            Rules.holdShield(run,false)
        }
    }
    onControlBindingsChanged:if (run) {
        hudTapKey=0
        keyboardFire=false
        fireHeld=false
        heldShiftKeys=[]
        sealing=false
        Rules.holdShield(run,false)
    }
    onBookVisibleChanged: {
        if (bookVisible) {
            hudTapKey=0
            keyboardFire=false
            fireHeld = false
            sealing = false
            heldShiftKeys = []
            Rules.holdShield(run,false)
        } else if (allowed) {
            if (fighting) keyTargetFocus()
            else giveMenuFocus()
        }
    }
    onStunnedChanged: if (stunned) sealing = false

    Timer {
        interval:Math.round(460/play.gameSpeed)
        running:play.autoPlaying && play.allowed && !play.paused && !play.bookVisible && !play.outcomeKind
            && ["between","reward","bossReward","shop"].includes(play.phase)
        repeat:true
        onTriggered:{
            if (play.phase==="between") {
                if (play.wave>=play.autoLimit) play.stopAuto()
                else play.startWave()
            } else if (Autoplay.select(play.run,play.autoShopEdition===play.run.shopEdition)) {
                if (play.run.phase==="shop") play.autoShopEdition=play.run.shopEdition
                play.selectedOffer=""
                play.publish()
                play.saveCheckpoint(true)
            }
        }
    }

    Item { id: keyTarget; focus: true }

    Timer {
        id: turn
        interval: play.turnMs
    }
    Timer { id: achievementNotice; interval: 3200; onTriggered: play.achievementText = "" }
    Timer {
        id:outcomeTimer
        interval:play.outcomeKind==="loss" ? 2750 : Math.round(2350/(play.autoPlaying ? play.gameSpeed : 1))
        onTriggered:{play.outcomeKind="";if(play.achievementText) achievementNotice.restart();Qt.callLater(play.giveMenuFocus)}
    }
    NumberAnimation {
        id:deathSequence
        target:play;property:"deathProgress"
        to:1;duration:2000
        onFinished:{
            if (play.outcomeKind!=="dying") return
            play.outcomeKind="loss"
            if (audio.item) audio.item.play("loss")
            outcomeTimer.restart()
        }
    }
    SequentialAnimation {
        id:swapMotion
        NumberAnimation {target:play;property:"swapOffset";from:0;to:1;duration:73;easing.type:Easing.InCubic}
        ScriptAction {script:play.finishEquip(play.swappingTo)}
        NumberAnimation {target:play;property:"swapOffset";from:1;to:0;duration:124;easing.type:Easing.OutCubic}
    }
    NumberAnimation {
        id: turnAnimation
        target: play
        property: "turnRatio"
        from: 0
        to: 1
        duration: play.turnMs
        easing.type: Easing.InOutCubic
    }
    Timer {
        interval:Math.max(4,Math.round(1000/play.frameLimit))
        repeat:true
        running:play.fighting && !play.bookVisible
        property real previous:0
        onRunningChanged:previous=Date.now()
        onTriggered: {
            const now=Date.now()
            const frameTime=Math.min(.08,Math.max(0,(now-previous)/1000))
            previous=now
            play.accumulated=Math.min(.4,play.accumulated+frameTime*play.gameSpeed)
            const step=1/60
            if (play.interactive && !play.autoPlaying && (aim.containsMouse || !play.keyboardFire)) play.updateAim(aim.mouseX,aim.mouseY,frameTime)
            const sight=play.autoPlaying ? play.autoCombat(frameTime) : play.interactive && (aim.containsMouse || play.keyboardFire) && !play.turning && !play.stunned
                ? {x:play.pointer.x/play.width,y:play.pointer.y/play.height,aspect:play.width/play.height} : null
            if (play.queuedAbility>=0 && !play.turning) {
                const slot=play.queuedAbility
                const id=play.run.slots.active[slot]?.item?.id
                if (!id || play.run.time>play.queuedAbilityUntil) play.queuedAbility=-1
                else if (!Rules.activeCooldown(play.run,id)) {
                    play.queuedAbility=-1
                    play.activateAbility(slot,false)
                }
            }
            let steps=0
            while (play.accumulated+1e-7>=step && play.run.phase==="combat" && steps++<24) {
                Tutorial.update(play.run,step,play.sealing && !!play.sealState && !play.turning,(play.fireHeld || play.autoPlaying) && !!sight,sight,!play.turning)
                play.accumulated-=step
            }
            play.syncTrainingView()
            if (play.trainingBlocked) play.fireHeld=false
            play.shotFlash=Math.max(0,play.shotFlash-frameTime*play.gameSpeed)
            if (play.weapon.spinup) play.rotaryAngle=(play.rotaryAngle+play.spin*frameTime*play.gameSpeed*1440)%360
            play.publish()
            if (play.phase!=="combat" && play.phase!=="defeat") play.saveCheckpoint(true)
            if (!play.autoPlaying) {
                if (sight && Rules.queuedShot(play.run)) play.fire(play.pointer.x,play.pointer.y,true)
                else if (play.fireHeld && (aim.containsMouse || play.keyboardFire)) play.fire(play.pointer.x,play.pointer.y)
            }
        }
    }

    Keys.priority: Keys.BeforeItem
    Keys.onPressed:function(event) {
        if (!fighting || bookVisible || !interactive) return
        if (!event.isAutoRepeat) hudTapKey=Controls.matches(bindings,"hud",event) ? event.key : 0
        if (hudTapKey===event.key && !event.isAutoRepeat) {event.accepted=true;return}
        if (autoPlaying || trainingBlocked) return
        const control=Controls.action(bindings,Controls.keyboard,event)?.id
        if (!control || ["pause","confirm","timer","loadout","grimoire"].includes(control)) return
        event.accepted=true
        if (event.isAutoRepeat) return
        switch(control) {
        case "left": case "right": case "up": case "down": turnView(control); break
        case "weapon1": case "weapon2": equipWeapon(Rules.slotInput(run,control==="weapon1" ? 0 : 1)); break
        case "reload": reloadGun(); break
        case "fire":
            keyboardFire=true
            beginFiring(aim.mouseX,aim.mouseY)
            break
        case "shield": Rules.holdShield(run,true);publish();break
        case "aim": setShiftKey(event.nativeScanCode,true);break
        case "active1": case "active2": activateAbility(control==="active1" ? 0 : 1,true);break
        case "seal": if (!stunned && frontId==="down" && !turning) sealing=true;break
        }
    }
    Keys.onReleased:function(event) {
        if (event.isAutoRepeat) return
        if (hudTapKey===event.key) {
            hudTapKey=0
            if (fighting && interactive && !bookVisible) {hudHidden=!hudHidden;event.accepted=true}
        }
        if (Controls.releases(bindings,"aim",event.key)) {
            if (!Controls.binding(bindings,"aim").some(chord=>chord.key===event.key)) heldShiftKeys=[]
            else setShiftKey(event.nativeScanCode,false)
            event.accepted=fighting
        }
        if (Controls.releases(bindings,"shield",event.key) && run.shield.held) {
            Rules.holdShield(run,false)
            publish()
            event.accepted=true
        }
        if (Controls.releases(bindings,"seal",event.key) && sealing) {
            sealing=false
            event.accepted=fighting
        }
        if (Controls.releases(bindings,"fire",event.key) && keyboardFire) {
            keyboardFire=false
            fireHeld=false
            event.accepted=fighting
        }
    }
    Shortcut {
        sequences:Controls.sequences(play.bindings,"pause")
        enabled:play.interactive && !play.bookVisible
        context:Qt.WindowShortcut
        autoRepeat:false
        onActivated:play.handleEscape()
    }
    Shortcut {
        sequences:Controls.sequences(play.bindings,"confirm")
        context:Qt.WindowShortcut
        enabled:play.interactive && play.allowed && !play.bookVisible && !play.fighting && primaryAction.activeFocus && primaryAction.visible
        autoRepeat:false
        onActivated:play.mainAction()
    }
    Shortcut {
        sequences:Controls.sequences(play.bindings,"timer")
        enabled:play.interactive && play.allowed && !play.bookVisible
        autoRepeat:false
        onActivated:play.timerRequested(!play.showTimer)
    }
    Shortcut {
        sequences:Controls.sequences(play.bindings,"loadout")
        enabled:play.interactive && play.allowed && !play.bookVisible && (play.fighting || play.lab || play.paused || play.preparing)
        autoRepeat:false
        onActivated:{
            if (play.paused && play.pauseTab==="inventory") play.mainAction()
            else play.pauseRun("inventory")
        }
    }
    Shortcut {
        sequences:Controls.sequences(play.bindings,"grimoire")
        enabled:play.interactive && play.allowed && !play.bookVisible
        autoRepeat:false
        onActivated:play.codexRequested("enemies","")
    }

    HoverHandler {
        enabled: play.fighting && play.interactive && !play.autoPlaying && !play.bookVisible && play.mouseTurns
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        blocking: false
        onPointChanged: play.edgeTurn(point.position.x,point.position.y)
    }

    Item {
        id: battlefieldViewport
        anchors.fill: parent
        readonly property real fall:play.motion && play.outcomeKind==="dying"
            ? Math.pow(play.deathProgress,1.6) : 0
        rotation:fall*17
        scale:1+fall*.54
        transform: Translate {
            x: play.motion ? play.shake.x + (play.projectedMode && play.distortion > 0
                    ? Math.sin(play.elapsed * 19) * 13 : 0) : 0
            y: play.motion ? play.shake.y-battlefieldViewport.fall*battlefieldViewport.height*.32 : 0
        }
        WallpaperTurn {
            anchors.fill: parent
            anchors.leftMargin:-play.wallpaperInsets.x
            anchors.topMargin:-play.wallpaperInsets.y
            anchors.rightMargin:-play.wallpaperInsets.width
            anchors.bottomMargin:-play.wallpaperInsets.height
            visible: play.phase !== "shop"
            artDirectory: play.artDirectory
            sources:play.backgroundFiles
            phase:play.daypart
            weather:play.weather
            lightingWeather:play.weather==="incursion" && !play.takeover ? "clear" : play.weather
            cloudy:play.cloudy
            windy:play.windy
            clock:play.elapsed
            solarTime:{play.revision;return play.run.waveTime}
            motion:play.motion
            detail:play.graphicsDetail
            labAppearance:play.labAppearance
            swarm:Conditions.roll(play.wave,play.run.seed,0x298fd269)<.16
            frontId: play.frontId
            previousFront: play.previousFront
            direction: play.turnDirection
            progress: play.turnRatio
            lab: play.lab && !play.outcomeKind
            transitionStrength:play.transitionStrength
            transitionStyle:play.transitionStyle
            framing: play.wallpaperFit
            quality: play.wallpaperQuality
            zoom: play.wallpaperZoom
            opacity: 1 - play.blindness
            scale: play.motion ? 1 + (play.stunned || play.impact.strength > 0 || play.distortion > 0 ? .07 : 0)
                + Math.min(.32,play.dash.depth / 4500) : 1
            Behavior on scale { NumberAnimation { duration: play.motion ? 150 : 0 } }
            transform: Scale {
                origin.x: play.zoomCentre.x*play.width
                origin.y: play.zoomCentre.y*play.height
                xScale: play.magnification
                yScale: play.magnification
            }
        }
        Rectangle {
            anchors.fill:parent
            visible:play.phase === "shop"
            color:"#151018"
        }
        Image {
            objectName: "shopBackdrop"
            anchors.fill: parent
            source: play.phase === "shop" ? Qt.resolvedUrl("../art/last-stop-workshop.png") : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
        Rectangle { anchors.fill: parent; color: "#9930192e"; visible:play.lab && play.phase !== "shop" }
        Loader {
            anchors.fill:parent
            active:play.fighting && play.graphicsDetail>=2 && !play.hypnotised && play.abyssDepth<1
            opacity:1-play.abyssDepth
            sourceComponent:Atmosphere {
                clock:play.elapsed
                motion:play.motion
                tint:play.daypart==="bloodMoon" ? "#f66874" : play.solarColor
            }
        }
        Loader {
            anchors.fill:parent
            active:play.fighting && play.projectedMode && play.turning && play.previousFront!==play.frontId
            sourceComponent:ProjectedWorld {
                clip:true
                actors:play.actors;bolts:play.bolts;axes:play.axes;gifts:play.gifts
                flyingPet:play.flyingPet;guestPet:play.guestPet;tarotPet:play.tarotPet;smokes:play.smokes
                frontId:play.previousFront;revision:play.revision;motion:play.motion;elapsed:play.elapsed
                blindness:play.blindness;obscurity:play.obscurity;hypnotised:play.hypnotised;frozenFront:play.frozenFront
                readonly property bool cameraTurn:play.transitionStyle==="cinematic" && play.previousFront!=="down" && play.frontId!=="down"
                opacity:cameraTurn ? 1 : 1-play.turnRatio
                transform:Matrix4x4 {
                    matrix:cameraTurn ? ViewTurn.panel(play.width,play.height,play.turnDirection,play.turnRatio,false,play.transitionStrength)
                        : ViewTurn.identity()
                }
            }
        }
        Loader {
            anchors.fill:parent
            active:play.graphicsDetail>=2 && !play.projectedMode && play.fighting && !play.turning
                && !play.hypnotised && play.frontId==="left" && play.magnification<1.01
                && play.weather!=="winter" && !play.backgroundFiles.left && !!play.worldItem
            sourceComponent:LakeMirror {
                field:play.worldItem
                waterMotion:Qt.vector2d(play.windy ? 2.65 : ["heatwave","inferno"].includes(play.weather) ? 1.65 : 1.15,
                    play.weather==="fog" ? .63 : 1)
                framing:play.wallpaperFit
                zoom:play.wallpaperZoom
                lightAndTime:Qt.vector4d(play.sky.sunX,play.sky.dark,
                    (1-play.sky.dark)*(play.cloudy ? .24 : 1),play.motion ? play.elapsed : 0)
                opacity:1-play.blindness
            }
        }
        Loader {
            id: worldLoader
            objectName: "worldLoader"
            anchors.fill: parent
            active: (play.phase === "combat" || !!play.outcomeKind) && play.allowed
            visible: play.fighting || !!play.outcomeKind
            sourceComponent: play.projectedMode ? projected : hardware
        }
    }
    Component {
        id: hardware
        World3D {
            id: viewport
            opacity:play.transitionStyle==="cinematic" && abyssTransition ? 1-.85*Math.sin(play.turnRatio*Math.PI) : 1
            voidIncursion: play.weather === "incursion" && play.takeover
            objectName: "world3D"
            abyssDepth:play.abyssDepth
            actors: play.actors
            bolts: play.bolts
            axes: play.axes
            splits: { play.revision; return play.run.splits }
            shatters: { play.revision; return play.run.gore.filter(function(event) { return event.crystal }) }
            holes: { play.revision; return play.run.holes }
            bubbleBursts:{play.revision; return play.run.bursts.filter(function(event) {return !!event.bubble})}
            gifts: play.gifts
            frontId: play.frontId
            revision: play.revision
            previousFront: play.previousFront
            artDirectory: play.artDirectory
            backgrounds:play.backgroundFiles
            quality: play.wallpaperQuality
            frameTarget:play.frameLimit
            detail:play.graphicsDetail
            sunYaw:play.solarYaw
            sunHeight:1-play.sky.sunY
            sunColor:play.solarColor
            darkSky:play.sky.dark
            warmSky:play.sky.warm
            obscurity:play.obscurity
            frozenFront:play.frozenFront
            abilityEvents:{play.revision;return play.run.abilityEvents}
            gore:{play.revision;return play.run.gore}
            transitionStyle:play.transitionStyle
            transitionStrength:play.transitionStrength
            wallpaperZoom: play.wallpaperZoom
            turnRatio: play.turnRatio
            flyingPet: play.flyingPet
            guestPet: play.guestPet
            tarotPet: play.tarotPet
            blindness: play.blindness
            hypnotised: play.hypnotised
            meleeReturn: { play.revision; return Rules.meleeReturnWindow(play.run) }
            grabId: play.grab ? play.grab.id : 0
            smokes: play.smokes
            elapsed: play.elapsed
            motion: play.motion
            lungeDepth: play.motion ? play.dash.depth : 0
            lungeLane: play.motion ? play.dash.lane : 0
            magnification: play.magnification
            lensCentre: play.zoomCentre
            Timer {
                interval: 4900
                running: play.fighting
                onTriggered: {
                    if (viewport.effectiveTextureSize.width <= 0)
                        play.switchToProjectedView()
                }
            }
        }
    }
    Component {
        id: projected
        ProjectedWorld {
            objectName: "projectedWorld"
            clip:cameraTurn
            obscurity:play.obscurity
            frozenFront:play.frozenFront
            actors: play.actors
            bolts: play.bolts
            axes: play.axes
            gifts: play.gifts
            frontId: play.frontId
            revision: play.revision
            readonly property bool cameraTurn:play.turning && play.transitionStyle==="cinematic"
                && play.previousFront!=="down" && play.frontId!=="down"
            transform:Matrix4x4 {
                matrix:cameraTurn ? ViewTurn.panel(play.width,play.height,play.turnDirection,play.turnRatio,true,play.transitionStrength)
                    : ViewTurn.identity()
            }
            opacity:play.turning && !cameraTurn ? play.turnRatio : 1
            flyingPet: play.flyingPet
            guestPet: play.guestPet
            tarotPet: play.tarotPet
            blindness: play.blindness
            hypnotised: play.hypnotised
            meleeReturn: { play.revision; return Rules.meleeReturnWindow(play.run) }
            smokes: play.smokes
            elapsed: play.elapsed
            motion: play.motion
            lungeDepth: play.motion ? play.dash.depth : 0
            lungeLane: play.motion ? play.dash.lane : 0
            magnification: play.magnification
            lensCentre: play.zoomCentre
        }
    }

    Loader {
        anchors.fill: parent
        active: play.fighting && (play.distortion > 0 || play.hypnotised) && !play.projectedMode
        sourceComponent: DistortedView {
            battlefield: battlefieldViewport
            phase: play.motion ? play.elapsed : 0
            strength: play.hypnotised ? 1 : Math.min(1, play.distortion * 2)
            hypnotised: play.hypnotised
        }
    }
    WeatherFX {
        anchors.fill: parent
        ultra:play.graphicsDetail===3
        condition: play.fighting && (play.weather!=="incursion" || play.takeover)
            ? Scenery.roomWeather(play.weather,play.frontId) : "clear"
        gust: { play.revision; return play.run.gustLeft }
        fogDensity:play.turning ? Scenery.fogDensity(play.previousFront)*(1-play.turnRatio)
            +Scenery.fogDensity(play.frontId)*play.turnRatio : Scenery.fogDensity(play.frontId)
        nearVisibility:play.turning ? Scenery.fogNearVisibility(play.previousFront)*(1-play.turnRatio)
            +Scenery.fogNearVisibility(play.frontId)*play.turnRatio : Scenery.fogNearVisibility(play.frontId)
        opacity:1-play.blindness
        time: play.elapsed
        motion: play.motion
    }
    Loader {
        anchors.fill:parent
        active:play.fighting && play.windy && play.weather!=="windy"
        sourceComponent:WeatherFX {
            condition:"windy"
            gust:{play.revision;return play.run.gustLeft}
            opacity:1-play.blindness
            time:play.elapsed
            motion:play.motion
        }
    }
    StormFX {
        anchors.fill:parent
        ultra:play.graphicsDetail===3
        castVisible:play.fighting && play.weather==="thunder" && !play.hypnotised
        field:play.worldItem
        clock:play.elapsed
        motion:play.motion
        strikes:{play.revision;return castVisible ? play.run.stormBursts.filter(function(strike){return strike.front===play.frontId}) : []}
        charges:{
            play.revision
            if (!castVisible) return []
            return play.actors.filter(function(actor){return actor.stormCharged && actor.front===play.frontId && actor.hp>0 && !actor.warp})
                .slice(0,10).map(function(actor){return Object.assign(Rules.arcPoint(actor),{size:Rules.enemySize(actor)})})
        }
    }
    CombatSpectacle {
        objectName: "demonSpectacle"
        anchors.fill: parent
        ultra:play.graphicsDetail===3 && !play.projectedMode
        sceneLight:play.solarColor
        darkness:play.sky.dark
        obscurity:play.obscurity
        run: play.run
        revision: play.revision
        frontId: play.frontId
        world: play.worldItem
        active: play.fighting && !play.hypnotised
        motion: play.motion
        projected: play.projectedMode
    }
    Rectangle {
        id: orbitGuard
        objectName: "orbitGuard"
        visible: play.fighting && !!play.orbit
        readonly property real glow: { play.revision; return play.run.guardFlash / .39 }
        width: play.orbit ? play.orbit.half * play.width * 2 : 0
        height: play.height * .67
        y: play.height * .16
        x: play.orbit ? play.orbit.x * play.width - width*.5 : 0
        radius: Math.min(39, width*.34)
        color: Qt.rgba(.23, .71, .74, .09 + glow*.26)
        border.color: Qt.rgba(.50, .92, .87, .44 + glow*.48)
        border.width: 2
        Rectangle {
            anchors.fill: parent
            anchors.margins: 7
            radius: Math.max(2, parent.radius - 6)
            color: "transparent"
            border.color: "#5078ddd4"
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#f3090911" }
            GradientStop { position: 0.25; color: "#10090911" }
            GradientStop { position: 0.59; color: "#00090911" }
            GradientStop { position: 1; color: "#fb0c0914" }
        }
    }
    Rectangle {
        anchors.fill: parent
        color: play.impact.color
        opacity: play.impact.strength * .13
        visible: opacity > 0 && play.fighting
    }
    Loader {
        id: heldWeapon
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: play.weaponAim.x * play.width * (play.handWeapon ? .033 : .018)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (play.handWeapon || play.weapon.staff ? -5
            : 4 + play.height*.011 - play.weaponAim.y*play.height*.018 - Math.min(1,(play.magnification-1)*4)*play.height*.117)-play.swapOffset*play.height*.27
        width: play.width * (play.weapon.staff ? .70 : play.handWeapon ? .77 : play.weapon.chargeEachShot ? .49 : play.compactLayout ? .55 : .59)
        height: play.height * (play.weapon.staff ? .94 : play.handWeapon ? .89 : play.weapon.chargeEachShot ? .39 : .47)
        active: play.fighting
        transformOrigin: Item.Bottom
        scale: !play.gunSights ? 1 + Math.min(.065,play.magnification-1)*.90 : 1
        rotation: play.projectedMode && !play.handWeapon ? play.weaponAim.x*4 - play.weaponAim.y*2 : 0
        readonly property point muzzle: {
            x; y; rotation
            return item ? item.mapToItem(play,item.muzzle) : Qt.point(play.width*.5,play.height*.73)
        }
        sourceComponent: play.projectedMode ? drawnGun : modeledGun
    }
    Rectangle {
        objectName:"centreReloadMeter"
        z:22
        width:Math.min(240,play.width*.34)
        height:reloadContents.implicitHeight+15
        x:(play.width-width)*.5
        y:play.height*.585
        radius:7
        visible:play.fieldHudVisible && play.reloadTime>0 && !play.trainingDialogue
        opacity:play.hudFade
        color:"#ed18121f"
        border.color:"#e8a27d"
        ColumnLayout {
            id:reloadContents
            anchors.fill:parent
            anchors.margins:7
            spacing:4
            Text {
                Layout.fillWidth:true
                text:"RELOADING  ·  "+play.reloadTime.toFixed(1)+"s"
                horizontalAlignment:Text.AlignHCenter
                color:"#ffe1bc"
                font.family:"IBM Plex Mono"
                font.pixelSize:Ui.UiMetrics.text(12)
            }
            Rectangle {
                Layout.fillWidth:true
                implicitHeight:5
                color:"#57424e"
                radius:2
                Rectangle {width:parent.width*play.reloadRatio;height:parent.height;color:"#ffd59b";radius:2}
            }
        }
    }
    Component {
        id: modeledGun
        WeaponModel {
            detail:play.graphicsDetail
            sunYaw:play.solarYaw-play.location.yaw
            sunHeight:1-play.sky.sunY
            sunColor:play.solarColor
            darkSky:play.sky.dark
            warmSky:play.sky.warm
            weapon: play.weapon
            aimOffset: play.weaponAim
            shotLife: play.strikeLife
            reloadRatio: play.reloadRatio
            rotaryAngle: play.rotaryAngle
            motion: play.motion
            charge: play.spin
            primed: play.primed
            bayonet: play.bayonet
            stab: play.stab
            sequence: play.shotSequence
            combo: play.combo
            staffCast:{play.revision; const gun=Gear.current(play.run); return gun.castTime > 0 ? 1-gun.castTime/gun.castLength : 0}
            staffCharge: play.runeCost > 0 ? Math.min(1, play.runes / play.runeCost) : 0
            clock: play.elapsed
        }
    }
    Component {
        id: drawnGun
        WeaponSprite {
            weapon: play.weapon
            sunlight:play.sky.warm>.13 ? play.daypart : ""
            aimOffset: play.weaponAim
            shotLife: play.strikeLife
            reloadRatio: play.reloadRatio
            rotaryAngle: play.rotaryAngle
            motion: play.motion
            primed: play.primed
            bayonet: play.bayonet
            stab: play.stab
            sequence: play.shotSequence
            combo: play.combo
            staffCast:{play.revision; const gun=Gear.current(play.run); return gun.castTime > 0 ? 1-gun.castTime/gun.castLength : 0}
            staffCharge: play.runeCost > 0 ? Math.min(1, play.runes / play.runeCost) : 0
            clock: play.elapsed
        }
    }
    CombatEffects {
        anchors.fill: parent
        time: play.elapsed
        motion: play.motion
        distortion: play.fighting ? play.distortion : 0
        voidStorm: play.fighting && play.voidStorm
        shatter: play.fighting ? play.shieldBreak : 0
        shield: play.fighting ? play.shieldHp : 0
        recharge: play.fighting ? play.shieldRefill : 0
        projected: play.projectedMode
    }
    AbyssFlood {
        anchors.fill:parent
        active:play.takeover && (play.fighting || play.outcomeKind==="loss")
        time:play.takeoverTime
        motion:play.motion
        warning:play.fighting && !play.bookVisible
    }
    FieldShield {
        anchors.fill: parent
        active: play.fighting
        tint: play.fieldGuard.tint
        mode: play.fieldGuard.mode
        raised: play.fieldGuard.raised
        age: play.fieldGuard.age
        impact: play.fieldGuard.impact
        motion: play.motion
    }
    GrenadeFX {
        anchors.fill: parent
        run: play.run
        revision: play.revision
        frontId: play.frontId
        muzzle: heldWeapon.muzzle
        active: play.fighting
    }
    ElementFX {
        anchors.fill: parent
        ultra:play.graphicsDetail===3
        run: play.run
        revision: play.revision
        frontId: play.frontId
        world: play.worldItem
        active: play.fighting
        motion: play.motion
        blindness: play.blindness
        fog: play.poisonFog
        obscurity:play.obscurity
    }
    WorldLabels {
        anchors.fill: parent
        actors: play.actors
        revision: play.revision
        world: play.worldItem
        frontId: play.frontId
        active: play.fieldHudVisible
        opacity:play.hudFade
        turning: play.turning
        blindness: play.blindness
    }
    Rectangle {
        anchors.fill: parent
        visible: play.fighting && (play.frost > 0 || play.cursed)
        opacity: play.cursed ? .59 + (play.motion ? Math.sin(play.elapsed * 3.3) * .15 : 0)
            : Math.max(.24, play.frost)
        gradient: Gradient {
            GradientStop { position: 0; color: play.cursed ? "#be480b63" : "#c268b9e4" }
            GradientStop { position: .48; color: "transparent" }
            GradientStop { position: 1; color: play.cursed ? "#b13c0855" : "#bf7bc7ee" }
        }
    }
    HealthVignette {
        anchors.fill: parent
        healthRatio: play.healthRatio
        injury: { play.revision; return play.run.injury }
        pulse: {
            play.revision
            return play.fighting && play.motion ? (1 + Math.sin(play.run.time * Math.PI * 1.85)) / 2 : .42
        }
        hurt: play.fighting ? play.impact.strength * .53 : 0
    }
    Text {
        objectName: "criticalReadout"
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(parent.height*.24,combatMessages.y+combatMessages.height+22) - (play.motion ? (1-play.criticalFlash/.60)*13 : 0)
        visible: play.fieldHudVisible && play.criticalFlash > 0
        opacity: play.hudFade*Math.min(1,play.criticalFlash*3.4)
        text: { play.revision; return "CRITICAL  " + play.run.criticalNumber.toFixed(1) }
        color: "#ffdc95"
        style: Text.Outline
        styleColor: "#682837"
        font.family: "IBM Plex Mono"
        font.weight: Font.Bold
        font.pixelSize: play.compactLayout ? 15 : 19
    }
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(parent.height*.29,combatMessages.y+combatMessages.height+45)
        visible: play.fieldHudVisible
        opacity:play.hudFade
        spacing: 2
        Repeater {
            model: ["incomingCritical","hostileMiss"]
            Text {
                required property string modelData
                readonly property bool critical: modelData==="incomingCritical"
                readonly property real remaining: {
                    play.revision
                    return (critical ? play.run.incomingCriticalUntil : play.run.hostileMissUntil)-play.run.time
                }
                objectName: modelData+"Readout"
                anchors.horizontalCenter: parent.horizontalCenter
                visible: remaining>0
                opacity: Math.min(1,remaining*5)
                text: {
                    play.revision
                    return critical ? "CRITICAL HIT TAKEN  −"+play.run.incomingCriticalDamage.toFixed(1)+" HP"
                        : play.run.hostileMissName.toUpperCase()+"  MISSED"
                }
                color: critical ? "#ff9693" : "#bce2f6"
                style: Text.Outline
                styleColor: "#2c1724"
                font.family: "IBM Plex Mono"
                font.weight: Font.Bold
                font.pixelSize: play.compactLayout ? 14 : 17
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        visible: play.fighting && play.evade > 0
        color: "transparent"
        border.width: 10
        border.color: "#8affdac2"
        radius: 18
        opacity: play.evade
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#fff1a0" }
            GradientStop { position: .52; color: "#22ffe678" }
            GradientStop { position: 1; color: "#fff1a0" }
        }
        opacity: play.powerFlash * (play.motion ? .9 : .22)
        visible: opacity > 0 && play.fighting
    }

    MouseArea {
        id: aim
        objectName: "aimArea"
        anchors.fill: parent
        visible: play.fighting
        enabled: visible && play.interactive && !play.autoPlaying
        hoverEnabled: enabled
        acceptedButtons:play.shootButton | play.reloadButton
        cursorShape:play.glitchInput ? Qt.BlankCursor : play.fighting ? Qt.CrossCursor : Qt.ArrowCursor
        onPressed:function(mouse) {
            play.hudTapKey=0
            keyTarget.forceActiveFocus()
            if (mouse.button===play.reloadButton) {
                play.fireHeld=false
                play.keyboardFire=false
                play.updateAim(mouse.x,mouse.y,0)
                play.reloadGun()
            } else {
                play.beginFiring(mouse.x,mouse.y)
            }
        }
        onReleased:function(mouse) {
            if (mouse.button===play.shootButton && !play.keyboardFire) play.fireHeld=false
        }
        onWheel:function(event) {
            if (!play.wheelSwitch || !event.angleDelta.y) {event.accepted=false;return}
            if (play.run.time-play.lastWheelSwitch>=.20) {
                const other=1-play.run.selectedWeapon
                if (play.run.slots.weapon[other]?.item) {
                    play.lastWheelSwitch=play.run.time
                    play.equipWeapon(other)
                }
            }
            event.accepted=true
        }
        onEntered: play.updateAim(mouseX, mouseY, 0)
        onPositionChanged: function(mouse) {
            play.updateAim(mouse.x, mouse.y, 0)
            play.edgeTurn(mouse.x, mouse.y)
        }
        onExited: if (!play.keyboardFire) play.fireHeld=false
        onCanceled: play.fireHeld = false
    }

    WeaponFeedback {
        id:weaponFeedback
        anchors.fill: parent
        visible: play.fighting
        ultra:play.graphicsDetail===3
        clock:play.elapsed
        weapon: play.weapon
        coinShot: {play.revision; return play.weapon.id === "kingsRansom" && !!Gear.current(play.run).coinShot}
        tracerColor: {
            play.revision
            const tint = Gear.current(play.run).jesterTint
            return play.weapon.id === "kingsRansom" && !Gear.current(play.run).coinShot ? "#abb4c2"
                : play.weapon.id === "jesterScatter" && tint ? Elements.kinds[tint].color : play.weapon.color
        }
        rays: play.shotRays
        life: play.strikeLife
        muzzleLife:play.shotFlash
        sequence:{play.revision;return Gear.current(play.run).sequence || 0}
        motion:play.motion
        sustained: play.sustainedFire && play.weapon.effect === "laser"
        chargedSlash: play.chargedStrike
        combo: play.combo
        pointer: play.pointer
        spreadMultiplier: { play.revision; return Rules.spread(play.run,play.aimingGun)*play.accuracy }
        muzzle: heldWeapon.muzzle
        aiming: play.fieldHudVisible && (aim.containsMouse || play.autoPlaying)
        scoped: play.gunSights && play.magnification > 1.01
        cycling: (play.shotTime > 0 || play.prepTime > 0 || play.cooling > 0) && !play.reloadTime && play.canShoot && !play.stunned
        readiness: play.shotReady
        turning: play.turning
        stunned: play.stunned
        sealProgress: play.fieldHudVisible && play.sealing ? play.sealProgress : 0
    }
    WalletFlight {
        id:lootLayer
        anchors.fill:parent
        motion:play.motion
        onArrived:function(kind) {
            if (kind==="gem") {
                play.gemsShown=true
                gemFade.restart()
            }
            if (audio.item) audio.item.play(kind==="gem" ? "gemArrival" : "coinArrival")
        }
    }
    Timer {id:gemFade;interval:3600;onTriggered:play.gemsShown=false}
    ScopeView {
        anchors.fill: parent
        centre: play.pointer
        sight: play.sight
        ink: play.weapon.color
        magnification: play.fighting && play.gunSights ? play.magnification : 1
        readiness: play.shotReady
    }

    Repeater {
        model: ["left", "right", "up", "down"]
        delegate: Canvas {
            id: indicator
            required property string modelData
            readonly property int threat: play.warnings[modelData] || 0
            readonly property bool bossAlert: play.bossDirection === modelData
            objectName: "warning-" + modelData
            width: bossAlert ? 64 : play.width < 930 ? 42 : 55
            height: width * .82
            x: modelData === "left" ? 26 : modelData === "right" ? play.width - width - 26 : (play.width - width) / 2
            y: modelData === "up" ? 112 : modelData === "down" ? play.height - 240 : play.height * .44
            rotation: modelData === "left" ? -90 : modelData === "right" ? 90 : modelData === "down" ? 180 : 0
            visible: play.fieldHudVisible && !play.hypnotised && (threat > 0 || bossAlert)
            opacity: play.hudFade*(bossAlert || threat === 2 ? .96 : .69)
            onThreatChanged: requestPaint()
            onBossAlertChanged: requestPaint()
            onWidthChanged: requestPaint()
            onVisibleChanged: if (visible) requestPaint()
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                ctx.beginPath()
                ctx.moveTo(width * .5, 4)
                ctx.lineTo(width - 4, height - 5)
                ctx.lineTo(4, height - 5)
                ctx.closePath()
                ctx.fillStyle = bossAlert ? "#ffd752" : threat === 2 ? "#ff5072" : "#be3655"
                ctx.strokeStyle = bossAlert ? "#201501" : "#ff8a9a"
                ctx.lineWidth = bossAlert ? 4 : 2.5
                ctx.fill()
                ctx.stroke()
            }
            Text {
                visible: indicator.bossAlert
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 5
                rotation: -indicator.rotation
                text: "!"
                color: "#1a1405"
                font.pixelSize: Ui.UiMetrics.text(26)
                font.weight: Font.Black
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -82
        width: stunNotice.implicitWidth + 30
        height: 38
        radius: 5
        color: "#ec3a1b2d"
        border.color: "#fa819b"
        visible: play.fieldHudVisible && play.stunned
        opacity:play.hudFade
        Text {
            id: stunNotice
            anchors.centerIn: parent
            text: "STUNNED  ·  " + play.stunLeft.toFixed(1) + " s"
            color: "#ffe1e7"
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(15)
        }
    }

    Rectangle {
        id:fieldHeader
        objectName:"fieldHeader"
        anchors.top: parent.top
        width: parent.width
        visible:!play.outcomeKind && !play.fighting
        height: play.fighting ? Math.max(88,fieldControls.y+fieldControls.height+8,
            waveReadout.y+waveReadout.height*play.hudZoom+6,fieldTitle.y+fieldTitle.height+8) : Math.max(76,fieldControls.y+fieldControls.height+8)
        color: "#d0161b28"
        border.color: "#5c5065"
        Ui.PanelPlating {
            anchors.fill: parent
            tone: play.location.color
            blood: .29 + (1-play.healthRatio)*.47
        }
    }

    Column {
        id:fieldTitle
        objectName:"fieldTitle"
        visible:!play.outcomeKind && (!play.fighting || play.fieldHudVisible)
        opacity:play.fighting ? play.hudFade : 1
        x: play.compactLayout ? 14 : 24
        y: 16
        width:play.fighting ? Math.max(60,(play.width-waveReadout.width*play.hudZoom)/2-x-12) : play.width*.53
        spacing: 2
        Text {
            width:parent.width
            elide:Text.ElideRight
            text: play.lab ? "AFTER WAVE " + play.wave : "PROJECT BLACKBOX"
            color: play.location.color
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(12)
            font.letterSpacing: 2
            style:Text.Outline;styleColor:"#211927"
        }
        Text {
            width:parent.width
            elide:Text.ElideRight
            text: play.phase === "shop" ? "Supply room" : play.lab ? "Droid Lab" : play.location.title
            color: "#fff2e9"
            font.family: "Inter"
            font.pixelSize: Ui.UiMetrics.text(25)
            font.weight: Font.Bold
            style:Text.Outline;styleColor:"#211927"
        }
    }

    Column {
        id: waveReadout
        objectName:"waveReadout"
        scale: play.hudZoom
        transformOrigin: Item.Top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 18
        width: Math.max(136,Math.min(258,play.width*.36,(play.width-2*(fieldControls.width+22))/play.hudZoom))
        spacing: 7
        visible: play.fieldHudVisible
        enabled:!play.hudHidden
        opacity:play.hudFade

        Ui.ActionButton {
            objectName: "waveMenuButton"
            width: parent.width
            implicitHeight: 42
            text: "Wave " + play.wave
            contentItem:RowLayout {
                spacing:7
                Text {text:"Wave "+play.wave;color:"#f0dfd3";font.pixelSize:14}
                Ui.BloodNumber {value:play.remaining}
                Text {Layout.fillWidth:true;visible:play.summons>0 && waveReadout.width>=186;text:"+"+play.summons+" summoned";elide:Text.ElideRight;color:"#bfa9c9";font.pixelSize:10}
            }
            Accessible.name: text + ". Open Waves"
            font.pixelSize: Ui.UiMetrics.text(14)
            hintText:"Open Waves"
            onClicked: play.pauseRun("waves")
        }
        Row {
            anchors.horizontalCenter:parent.horizontalCenter
            spacing:8
            Text {
                id:coinBalance
                objectName:"fieldCoinBalance"
                text:play.gold+" gold"
                color:"#ffe08a"
                font.family:"IBM Plex Mono"
                font.pixelSize:Ui.UiMetrics.text(11)
                scale:1
                onTextChanged:if (play.fighting) coinPulse.restart()
                SequentialAnimation on scale {
                    id:coinPulse
                    running:false
                    NumberAnimation {to:play.motion ? 1.15 : 1;duration:78}
                    NumberAnimation {to:1;duration:160}
                }
            }
            Text {
                id:gemBalance
                objectName:"fieldGemBalance"
                text:{
                    play.revision
                    const total=play.vault && !play.run.debug && !play.run.training ? play.vault.state.gems : Meta.fieldGems(play.run.fieldGems)
                    return "◆ "+total
                }
                color:"#dfaaee"
                font.family:"IBM Plex Mono"
                font.pixelSize:Ui.UiMetrics.text(11)
                opacity:play.gemsShown ? 1 : 0
                visible:play.gemsShown || opacity>.01
                Behavior on opacity {NumberAnimation {duration:play.motion ? 410 : 0}}
                Accessible.name:"Dark gems"
            }
        }
        Text {
            objectName:"fieldConditions"
            width:parent.width
            text:play.weatherLabel+"  ·  "+Conditions.entries[play.daypart].title
            horizontalAlignment:Text.AlignHCenter
            font.family:"Inter"
            font.pixelSize:Ui.UiMetrics.text(12)
            color:"#f4ddbe"
            wrapMode:Text.WordWrap
        }
        Text {
            width: parent.width
            visible: !!play.flyingPet
            text: {
                play.revision
                return play.flyingPet ? play.petSpec.title + " · Lv " + play.flyingPet.level
                    + (play.flyingPet.resting > 0 ? " · Rest " + Math.ceil(play.flyingPet.resting) + "s" : "")
                    + (play.flyingPet.front !== play.frontId ? " · " + Rules.front(play.flyingPet.front).label : "") : ""
            }
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            color: Pets.uniqueColor
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(10)
        }
        Rectangle {
            visible: play.boss !== null
            width: parent.width
            height: 40
            radius: 5
            color: "transparent"
            Meter {
                anchors.centerIn: parent
                width: parent.width - 18
                label: play.boss ? play.boss.title.toUpperCase() + (play.boss.fangs >= 0 ? " · " + play.boss.fangs + " FANGS" : "") : ""
                value: play.boss ? play.boss.health : 0
                maximum: play.boss ? play.boss.maxHealth : 1
                tint: play.boss ? play.boss.tint : "#ffbd61"
            }
        }
    }

    Column {
        id: fieldControls
        objectName:"fieldControls"
        z:25
        anchors.right:parent.right
        anchors.top:parent.top
        anchors.topMargin:14
        anchors.rightMargin:16
        visible:!play.outcomeKind && (!play.fighting || play.fieldHudVisible)
        enabled:!play.fighting || !play.hudHidden
        opacity:play.fighting ? play.hudFade : 1
        spacing:6

        Row {
            anchors.right:parent.right
            spacing:6
            Ui.ActionButton {
                objectName:"audioButton"
                visible:play.fighting && play.width>=650
                text:"Audio"
                onClicked:play.pauseRun("settings")
            }
            Ui.ActionButton {
                visible:play.fighting || (play.lab && !play.paused)
                text:play.compactLayout ? "Pause" : "Pause · "+Controls.label(play.bindings,"pause")
                objectName:"pausePlay"
                onClicked:play.pauseRun("build")
            }
            Ui.ActionButton {
                objectName:"exitPlay"
                visible:play.phase==="ready" || play.phase==="defeat"
                text:"Home · "+Controls.label(play.bindings,"pause")
                onClicked:play.exitRequested()
            }
        }

        Row {
            anchors.right: parent.right
            spacing: 5
            visible:(play.fighting || play.autoPlaying) && !play.trainingDialogue
            Ui.ActionButton {
                objectName:"autoPlayButton"
                visible:!play.run.training
                text:play.autoPlaying ? "Auto on" : "Auto"
                hintText:play.autoLimit ? "Auto through Wave "+play.autoLimit+" · Using it reduces the expedition’s crystal payout." : "Clear a wave to unlock Auto"
                Accessible.name:play.autoPlaying ? "Turn Auto off" : "Turn Auto on"
                enabled:play.interactive && (play.autoPlaying || play.autoEligible)
                primary:play.autoPlaying
                onClicked:play.toggleAuto()
            }
            Ui.ActionButton {
                objectName:"gameSpeed"
                text:play.gameSpeed+"×"
                hintText:"Change simulation speed"
                onClicked:{play.gameSpeed=play.speedSteps[(play.speedSteps.indexOf(play.gameSpeed)+1)%play.speedSteps.length];play.keyTargetFocus()}
            }
        }
        Text {
            visible:play.fighting && play.showTimer
            anchors.right:parent.right
            text:{play.revision;const seconds=Math.floor(play.run.waveTime);return Math.floor(seconds/60)+":"+String(seconds%60).padStart(2,"0")}
            color:"#f5dfd0";font.family:"monospace";font.pixelSize:Ui.UiMetrics.text(13)
        }
    }

    Column {
        id: combatMessages
        anchors.top: parent.top
        anchors.topMargin:fieldHeader.height+12
        anchors.horizontalCenter: parent.horizontalCenter
        width:Math.min(play.width-32,780)
        spacing: 6
        visible: play.fieldHudVisible
        opacity:play.hudFade
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: { play.revision; return Gear.passiveRank(play.run,"deathMint") > 0 }
            text: { play.revision; return "DEATH COINS " + Math.min(5,play.run.deathCoins) + " / 5" }
            color: "#f6ca78"
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(12)
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: play.distortion > 0
            text: play.voidStorm ? "VOID SIGNAL DISTORTION" : "ZADRRIMUS DISTORTION · " + play.distortion.toFixed(1) + " s"
            color: "#ffacd8"
            style: Text.Outline
            styleColor: "#26152d"
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(12)
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                play.revision
                const hexes = Object.keys(play.run.hexes).map(function(key) { return Rules.curses[key] })
                for (const effect of ["frost", "weaken", "blind"]) {
                    if ((effect === "blind" ? play.blindRank : play.run.elements[effect]) > 0)
                        hexes.unshift(effect.toUpperCase() + " " + (effect === "blind" ? play.blindRank : play.run.elements[effect]))
                }
                if (play.cursed)
                    hexes.unshift("CURSED")
                if (play.run.dizzyLeft > 0)
                    hexes.unshift("REVERSED TURNS " + play.run.dizzyLeft.toFixed(1)+"s")
                if (play.glitchInput)
                    hexes.unshift("REVERSED AIM, TURNS AND PAIRED CONTROLS")
                if (play.run.fearCut)
                    hexes.unshift("HALVED MAX HP")
                if (play.run.boneTime > 0)
                    hexes.push("BONE SHATTER " + play.run.boneTime.toFixed(1)+"s")
                if (play.run.souls || play.run.scytheSouls)
                    hexes.push("SOULS " + (play.run.souls + play.run.scytheSouls))
                if (play.run.elements.burn > 0)
                    hexes.unshift("BURN " + play.run.elements.burn + " · " + play.run.elements.burnLeft.toFixed(1) + " s")
                return hexes.join("  ·  ")
            }
            width:parent.width
            horizontalAlignment:Text.AlignHCenter
            wrapMode:Text.WordWrap
            visible: text.length > 0
            color: "#ffc082"
            style: Text.Outline
            styleColor: "#291922"
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(12)
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text.length > 0
            text: {
                play.revision
                const element = play.run.elements
                if (!element.poison)
                    return ""
                return "POISON " + element.poison + "   ·   MAX HP −" + Math.round(element.poisonLoss * 100)
                    + "%   ·   " + element.poisonLeft.toFixed(1) + "s"
            }
            color: "#d4ff92"
            style: Text.Outline
            styleColor: "#263a16"
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(12)
        }
        Rectangle {
            objectName: "stickyNotice"
            anchors.horizontalCenter: parent.horizontalCenter
            width: stuckLabel.implicitWidth + 24
            height: 27
            radius: 5
            visible: { play.revision; return play.run.elements.sticky > 0 }
            border.color: "#d1fa65"
            color: "#ed293913"
            Text {
                id: stuckLabel
                anchors.centerIn: parent
                text: {
                    play.revision
                    return "STICKY " + play.run.elements.sticky + "  ·  TURNS LOCKED  "
                        + play.run.elements.stickyLeft.toFixed(1) + "s"
                }
                color: "#edffac"
                font.family: "IBM Plex Mono"
                font.weight: Font.Bold
                font.pixelSize: Ui.UiMetrics.text(12)
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: play.constricted || play.hypnotised
            text: {
                play.revision
                return play.hypnotised ? "HALLUCINATIONS LEFT  " + play.run.hypnosis.left
                    : play.constricted ? "CONSTRICTED · RELEASE IN " + Math.max(0,play.grab.length-play.grab.time).toFixed(1)+"s" : ""
            }
            color: "#ffe1f7"
            style: Text.Outline
            styleColor: "#432133"
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(14)
            font.weight: Font.Bold
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(play.width - 36, alert.implicitWidth + 22)
            height: Math.max(28,Ui.UiMetrics.text(20))
            radius: 4
            border.color: "#6d536a"
            color: "#e51e1423"
            visible: alert.text.length > 0
            Text {
                id: alert
                anchors.centerIn: parent
                width:Math.min(implicitWidth,parent.width-16)
                elide:Text.ElideRight
                text: {
                    play.revision
                    return play.run.note && play.run.time < play.run.noteUntil ? play.run.note : ""
                }
                color: "#fff2e9"
                font.family: "Inter"
                font.pixelSize: Ui.UiMetrics.text(13)
            }
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(228,Ui.UiMetrics.text(214))
            height: Math.max(45,Ui.UiMetrics.text(37))
            radius: 5
            color: "#eb25162f"
            border.color: play.sealClosed ? "#81d5be" : "#d5a3f5"
            visible: !!play.sealState && !play.hypnotised
            Meter {
                objectName: "sealMeter"
                anchors.centerIn: parent
                width: parent.width - 22
                label: play.sealClosed ? "RIFT CLOSED FOR THIS WAVE" : play.sealing ? "SEALING RIFT" : "HOLD "+Controls.label(play.bindings,"seal").toUpperCase()+" TO SEAL THE RIFT"
                value: Math.floor(play.sealProgress * 100)
                maximum: 100
                suffix: "%"
                tint: "#d7a0ff"
            }
        }
    }

    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 19
        spacing: 9
        visible: play.fieldHudVisible
        enabled:!play.hudHidden
        opacity:play.hudFade
        MiniMap {
            objectName: "combatMinimap"
            scale:play.hudZoom
            transformOrigin:Item.BottomLeft
            frontId: play.frontId
            counts: play.frontStatus
            turns: play.turns
            navigable: play.fighting && !play.stunned && !play.turnLocked && !play.turning && !play.lunging
            onTurnRequested: function(direction) { play.turnView(direction) }
        }
    }
    Item {
        id:leftHudPanel
        anchors.left:parent.left
        anchors.bottom:parent.bottom
        anchors.leftMargin:16
        anchors.bottomMargin:22+85*play.hudZoom
        width:play.width < 960 ? 159 : 194
        height:leftHud.implicitHeight+16
        scale:play.hudZoom
        transformOrigin:Item.BottomLeft
        visible:play.fieldHudVisible
        enabled:!play.hudHidden
        opacity:play.hudFade
        Column {
            id:leftHud
            x:9; y:8
            width:parent.width-18
            spacing:play.height < 640 ? 5 : 9
        ActiveTile {
            objectName: "activeHUD-Q"
            abilityState: { play.revision; return play.abilityTile(Rules.slotInput(play.run,0)) }
            shortcut:Controls.label(play.bindings,"active1")
            onCastRequested:{play.activateAbility(0,true);play.keyTargetFocus()}
            motion: play.motion
            details:ability ? Gear.itemDetails(play.run,"active",{id:ability.id,level:abilityState.level}) : ""
            onEntryRequested:function(chapter,id) {play.codexRequested(chapter,id)}
        }
        Meter {
            width: parent.width
            objectName:"healthReadout"
            prominent:true
            motion:play.motion
            label: "HEALTH"
            value: { play.revision; return play.run.health }
            maximum: { play.revision; return Gear.maxHealth(play.run) }
            tint: "#f49199"
        }
        BarrierTile {
            width: parent.width
            charges: play.shieldHp
            capacity: play.shieldCapacity
            timeLeft: play.shieldTime
            cooldown: play.shieldCooldown
            refilling: play.shieldRefill > 0
            installed: play.barrierLevel
        }
        Column {
            objectName: "fieldShieldStatus"
            width: parent.width
            spacing: 3
            RowLayout {
                width: parent.width
                spacing: 4
                Text {
                    Layout.fillWidth: true
                    text: Defense.modes[play.fieldGuard.mode].title.toUpperCase()
                    color: play.fieldGuard.tint
                    font.family: "IBM Plex Mono"
                    font.pixelSize: Ui.UiMetrics.text(12)
                    fontSizeMode: Text.HorizontalFit
                    minimumPixelSize: 8
                    elide: Text.ElideRight
                }
                Rectangle {
                    implicitWidth: 43
                    implicitHeight: 18
                    color: "#122333"
                    border.color: "#5f839c"
                    radius: 3
                    Text {
                        anchors.centerIn: parent
                        text:Controls.label(play.bindings,"shield").toUpperCase()
                        color: "#d8efff"
                        font.family: "IBM Plex Mono"
                        font.pixelSize: Ui.UiMetrics.text(11)
                    }
                }
            }
            Rectangle {
                objectName:"shieldChargeBar"
                property real charge:play.fieldGuard.charge
                property bool rejected:play.fieldGuard.rejected>0
                width: parent.width
                height: 9
                radius: 3
                color: "#394151"
                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    width:parent.width*parent.charge
                    color:play.fieldGuard.rejected>0 ? "#ff596b" : play.fieldGuard.tint
                }
                Rectangle {
                    anchors.fill:parent
                    radius:3;color:"#66ff445a"
                    visible:play.fieldGuard.rejected>0
                }
                Rectangle { x:parent.width*Defense.raiseThreshold; width:2; height:parent.height; color:"#f8ecce" }
            }
            Text {
                width:parent.width
                elide:Text.ElideRight
                text:Math.round(play.fieldGuard.charge*100)+"% · "
                    +(play.fieldGuard.raised ? "RAISED" : play.fieldGuard.charge>=Defense.raiseThreshold ? "READY" : "RECHARGING")
                color: "#c9ccdd"
                font.family: "IBM Plex Mono"
                font.pixelSize: Ui.UiMetrics.text(11)
            }
        }
    }
    }
    Item {
        id:rightHudPanel
        anchors.right:parent.right
        anchors.bottom:parent.bottom
        anchors.rightMargin:16
        anchors.bottomMargin:18
        width:play.width < 960 ? 141 : 166
        height:rightHud.implicitHeight+16
        scale:play.hudZoom
        transformOrigin:Item.BottomRight
        visible:play.fieldHudVisible
        enabled:!play.hudHidden
        opacity:play.hudFade
        Column {
            id:rightHud
            x:9; y:8
            width:parent.width-18
            spacing:play.height < 640 ? 5 : 9
        ActiveTile {
            objectName: "activeHUD-E"
            abilityState: { play.revision; return play.abilityTile(Rules.slotInput(play.run,1)) }
            shortcut:Controls.label(play.bindings,"active2")
            onCastRequested:{play.activateAbility(1,true);play.keyTargetFocus()}
            motion: play.motion
            details:ability ? Gear.itemDetails(play.run,"active",{id:ability.id,level:abilityState.level}) : ""
            onEntryRequested:function(chapter,id) {play.codexRequested(chapter,id)}
        }
        Column {
            id:ammoReadout
            width: parent.width
            spacing: 5
            HoverHandler {id:gunHover; enabled:play.fighting && !play.weapon.debugOnly}
            Ui.FieldHint {
                id:gunHint
                anchorItem:ammoReadout
                hovered:gunHover.hovered
                chapter:"weapons"
                entryId:play.weapon.id
                details:{play.revision;return gunHover.hovered || gunHint.visible ? Gear.itemDetails(play.run,"weapon",Gear.current(play.run)) : play.weapon.title}
                onEntryRequested:function(chapter,id) {play.codexRequested(chapter,id)}
            }
            AmmoDial {
                objectName:"ammoDial"
                anchors.horizontalCenter:parent.horizontalCenter
                width:Math.min(parent.width,play.compactLayout ? 78 : 96)
                height:width
                capacity:play.ammoWeapon && !play.infiniteAmmo && !play.desktopTelemetry.cpuMode ? Rules.magazine(play.run) : 0
                rounds:play.rounds
                charge:play.desktopTelemetry.cpuMode ? play.desktopTelemetry.heat/100 : play.runeCost ? play.runes/play.runeCost
                    : play.weapon.sustain ? play.heat : play.shotReady
                warning:play.desktopTelemetry.locked || !play.canShoot
                caption:play.desktopTelemetry.cpuMode ? "CPU HEAT" : play.runeCost ? "RUNES" : play.weapon.sustain ? "HEAT" : play.ammoWeapon ? "ROUNDS" : ""
                readout:play.desktopTelemetry.cpuMode ? Math.round(play.desktopTelemetry.heat)+"%"
                    : play.runeCost ? play.runes+"/"+play.runeCost : play.weapon.sustain ? Math.round(play.heat*100)+"%"
                    : play.ammoWeapon ? (play.infiniteAmmo ? "∞" : play.rounds+"/"+Rules.magazine(play.run))
                    : play.weapon.melee ? (play.primed ? "CHARGED" : "MELEE") : play.weapon.throwing ? "AXE" : "READY"
            }
            Row {
                anchors.horizontalCenter:parent.horizontalCenter
                spacing:2
                visible:!!play.desktopTelemetry.gpuMode || !!play.desktopTelemetry.resonance
                AmmoDial {
                    objectName:"gpuDial"
                    width:Math.min(64,ammoReadout.width/2);height:width
                    visible:!!play.desktopTelemetry.gpuMode
                    tint:"#b59bff"; caption:"GPU"; charge:play.desktopTelemetry.gpuLoad || 0
                    readout:Math.round(charge*100)+"%"
                    warning:charge>=.8
                }
                AmmoDial {
                    width:Math.min(64,ammoReadout.width/2);height:width
                    visible:!!play.desktopTelemetry.resonance
                    tint:"#83e4c7";caption:(play.desktopTelemetry.resonance || "").toUpperCase()
                    charge:play.desktopTelemetry.music || 0
                    readout:Math.round(charge*100)
                }
            }
            Text {
                text: { play.revision; return (play.run.selectedWeapon + 1) + " · " + play.weapon.title.toUpperCase() }
                width: parent.width
                elide: Text.ElideRight
                color: "#cfbecf"
                font.family: "IBM Plex Mono"
                font.pixelSize: Ui.UiMetrics.text(10)
            }
            Rectangle {
                objectName: "weaponCycleMeter"
                width: parent.width
                height: 5
                radius: 2.5
                color: "#6a494d"
                property real progress: play.shotReady
                Rectangle {
                    width: parent.width * parent.progress
                    height: parent.height
                    radius: parent.radius
                    color: "#ffc28b"
                }
            }
            Text {
                objectName: "weaponCycleStatus"
                width: parent.width
                elide: Text.ElideRight
                text: play.fieldGuard.raised ? "SHIELD RAISED · RELEASE "+Controls.label(play.bindings,"shield").toUpperCase()+" TO FIRE"
                    : play.runeCost && play.runes >= play.runeCost ? "SPELL READY · R"
                    : play.prepTime > 0 ? (play.weapon.throwing ? "DRAWING AXE " : play.weapon.stab ? "THRUST " : "TRICK ") + play.prepTime.toFixed(1) + "s"
                    : play.cooling > 0 ? "COOLING " + play.cooling.toFixed(1) + "s"
                    : play.reloadTime > 0 ? "RELOAD " + play.reloadTime.toFixed(1) + "s"
                    : !play.canShoot ? "EMPTY · R"
                    : play.winding ? (play.weapon.id === "chainsaw" ? "REVVING " : play.weapon.chargeEachShot ? "CHARGING " : "SPINNING UP ")
                        + Math.floor(play.spin * 100) + "%"
                    : play.sustainedFire ? (play.weapon.melee ? "CHAIN RUNNING" : "BEAM FIRING")
                    : play.shotTime > 0 ? "NEXT " + play.shotTime.toFixed(2) + "s"
                    : play.weapon.melee && !play.primed ? "READY · R TO PRIME" : "READY"
                color: "#ffd0a9"
                font.family: "IBM Plex Mono"
                font.pixelSize: Ui.UiMetrics.text(10)
            }
        }
    }

    }
    AbyssOverlay {
        anchors.fill: parent
        clock: play.elapsed
        motion: play.motion
        hypnotised: play.fighting && play.hypnotised
        projected: play.projectedMode
        ink: play.fighting && play.inkStains
        blind: play.fighting ? play.blindRank : 0
        intensity: play.blindStrength
        aim: play.pointer
        grab: play.fighting ? play.grab : null
    }
    SoulLink {
        anchors.fill:parent
        run:play.run
        revision:play.revision
        world:play.worldItem
        frontId:play.frontId
        active:play.fighting
        motion:play.motion
    }

    Rectangle {
        anchors.fill: parent
        color: play.phase === "shop" ? "#26090912" : "#83090912"
        visible: !play.fighting
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            cursorShape: Qt.ArrowCursor
        }
    }
    Rectangle {
        id: selectionPanel
        objectName:"fieldPanel"
        anchors.horizontalCenter:parent.horizontalCenter
        // Switching a bottom anchor and a centre anchor in the same update
        // can leave Qt holding a stretched height when reopening preparation.
        y:play.previewing
            ? parent.height - height - (play.compactLayout ? 14 : 26)
            : (parent.height - height) / 2
        width: Math.min(parent.width - (play.compactLayout ? 24 : 56),play.preparing ? 1120 : play.phase==="shop" ? 1110 : play.lab ? 960 : 900)
        opacity: play.fighting ? 0 : 1
        Behavior on opacity { enabled:!play.paused; NumberAnimation { duration: play.motion ? 145 : 0 } }
        readonly property int inset: play.compactLayout ? 13 : 22
        implicitHeight: screen.implicitHeight + menuFooter.implicitHeight + inset * 2 + 9
        // Always reserve a separate forecast area on preparation screens.
        height: Math.min(implicitHeight, parent.height * (play.previewing ? .63 : .91))
        radius: 7
        color: play.phase === "shop" ? "#211823" : "#f71b1622"
        border.color: play.phase === "shop" ? "#a67b77" : "#94616f"
        border.width: 1
        visible: opacity > 0 && !play.outcomeKind && play.phase!=="defeat"
        enabled: visible && !play.fighting

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 6
            radius: 3
            color: play.phase === "shop" ? "#b98866" : "#7f3d51"
        }
        Ui.PanelPlating {
            anchors.fill: parent
            tone: play.phase === "shop" ? "#dcb98d" : play.paused ? "#c78a9a" : "#aa8194"
            blood: play.phase === "defeat" ? 1 : play.paused ? .88 : play.phase === "ready" ? .20 : .43
        }

        ScrollView {
            id: sheetScroll
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.top:parent.top
            anchors.bottom:menuFooter.top
            anchors.leftMargin:selectionPanel.inset
            anchors.rightMargin:selectionPanel.inset
            anchors.topMargin:selectionPanel.inset
            anchors.bottomMargin:9
            contentWidth:availableWidth
            clip:true
            ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
            ColumnLayout {
                id: screen
                width:sheetScroll.availableWidth-(sheetScroll.contentHeight>sheetScroll.availableHeight ? 10 : 0)
                spacing:play.compactLayout ? 8 : 12

            Text {
                Layout.fillWidth: true
                visible: (!play.preparing && play.phase !== "shop") || play.paused
                text: play.paused ? "Paused · Wave " + play.wave : play.phase === "ready" ? "Defend the Shrine"
                    : play.phase === "bossReward" ? "Boss defeated"
                    : play.phase === "reward" ? (play.selectedOffer ? "Choose a " + play.selectedGroup + " slot" : "Droid Lab rewards")
                    : play.phase === "between" ? "Wave " + (play.wave + 1) + " incoming"
                    : play.phase === "defeat" ? "The Shrine fell" : ""
                font.family: "Inter"
                font.pixelSize: Ui.UiMetrics.text(play.compactLayout ? 24 : 30)
                font.weight: Font.Bold
                color: "#fff1e8"
                wrapMode: Text.WordWrap
            }
            Text {
                Layout.fillWidth: true
                visible: !play.paused && !play.preparing && play.phase !== "shop"
                text: {
                    play.revision
                    if (play.phase === "ready") return play.run.debug ? "Boss practice. Achievements are off for this run."
                        : "Defend the Shrine Path and earn equipment between waves."
                    if (play.phase === "bossReward") return "Choose one upgrade for the rest of this run."
                    if (play.phase === "reward") return play.selectedCard
                        ? "Drop " + play.selectedCard.title + " onto a slot or select one below."
                        : "Wave " + play.wave + " cleared. Claim one item before wave " + (play.wave + 1) + "."
                    if (play.phase === "between") return Rules.waveSize(play.wave + 1, play.run.difficulty) + " enemies incoming"
                        + (Rules.isBossWave(play.wave + 1)
                            ? " · " + Rules.enemyTypes[Rules.bossType(play.wave + 1)].title + " is the final enemy." : ".")
                            + " Esc or T to prepare your loadout."
                    return play.phase === "defeat"
                        ? "Wave " + play.run.wave + " · " + play.run.kills + " kills · " + play.gold + " gold" : ""
                }
                color: "#d3c2d0"
                font.family: "Inter"
                font.pixelSize: Ui.UiMetrics.text(14)
                wrapMode: Text.WordWrap
            }
            Text {
                objectName:"pausedConditions"
                visible:play.paused && play.wave>0
                Layout.fillWidth:true
                text:play.weatherLabel+"  ·  "+Conditions.entries[play.daypart].title
                font.pixelSize:Ui.UiMetrics.text(15)
                color:"#ebcba7"
            }
            RunSetup {
                Layout.fillWidth: true
                visible: play.phase === "ready" && !play.paused
                difficulty: { play.revision; return play.run.difficulty }
                startAt: { play.revision; return play.run.startAt }
                build: { play.revision; return play.run.debugBuild }
                unlockAll: { play.revision; return play.run.debugUnlockAll }
                debugWeapon:{play.revision;return play.run.debugWeapon}
                onDebugWeaponRequested:function(id) {if (Rules.setDebugWeapon(play.run,id)) play.publish()}
                bloodMoon: { play.revision; return play.run.debugWeather === "bloodMoon" }
                weatherLayer:{play.revision;return play.run.debugLayer}
                unlimitedMoney:{play.revision;return play.run.debug && play.run.debugMoney}
                onMoneyRequested:function(value) {
                    if (play.run.phase==="ready" && play.run.debug) {
                        play.run.debugMoney=value
                        play.publish()
                    }
                }
                onPracticeWeatherRequested:function(value) { if (Rules.setPracticeWeather(play.run,value)) play.publish() }
                onWeatherLayerRequested:function(value) {if (Rules.setPracticeLayer(play.run,value)) play.publish()}
                onUnlocksRequested: function(enabled) {
                    if (Rules.applyDebugUnlocks(play.run, enabled))
                        play.publish()
                }
                onConfigurationChanged: function(difficulty, startAt, build) {
                    if (Rules.configure(play.run, difficulty, startAt, build))
                        play.publish()
                }
            }
            Loader {
                Layout.fillWidth:true
                active:play.phase === "between" && !play.paused
                visible:active
                sourceComponent: StagePreparation {
                    onEntryRequested:function(chapter,id) { play.codexRequested(chapter,id) }
                    run:play.run
                    revision:play.revision
                    compact:play.compactLayout
                    motion:play.allowed && play.motion
                    onSwapRequested:function(group,from,to) {
                        if (Rules.canEditLoadout(play.run) && Gear.swap(play.run,group,from,to))
                            play.publish()
                    }
                    onInventoryRequested:function(cell,group,slot) {
                        if (Rules.swapInventory(play.run,cell,group,slot))
                            play.publish()
                    }
                }
            }
            StarterPicker {
                onEntryRequested:function(chapter,id) { play.codexRequested(chapter,id) }
                Layout.fillWidth: true
                visible: play.draftingWeapon && !play.paused && !(play.vault?.state.pending.epic || play.vault?.state.pending.legendary)
                weapons: play.startingWeapons
                selectedId: play.starterChoice
                onWeaponSelected: function(id) {
                    if (Rules.chooseStarter(play.run,id))
                        play.publish()
                }
            }
            Text {
                Layout.fillWidth:true
                visible:play.draftingWeapon && !play.paused && !!(play.vault?.state.pending.epic || play.vault?.state.pending.legendary)
                text:"The Witch has reserved a random "+(play.vault?.state.pending.legendary ? "Legendary" : "Epic")+" starting weapon."
                color:"#edbfeb"
                font.family:"Inter"
                font.pixelSize:Ui.UiMetrics.text(14)
                wrapMode:Text.WordWrap
            }
            Text {
                objectName:"reservedTarot"
                readonly property var omen:Tarot.card(play.vault?.state.reading?.chosen || "")
                Layout.fillWidth:true
                visible:!!omen && play.phase==="ready" && !play.paused && !play.run.debug && !play.run.training
                text:omen ? "Tarot · "+omen.title+"  ·  "+omen.description : ""
                color:"#f0cea7"
                font.family:"Inter"
                font.pixelSize:Ui.UiMetrics.text(13)
                wrapMode:Text.WordWrap
            }
            Text {
                objectName:"reservedPassage"
                Layout.fillWidth:true
                visible:play.phase==="ready" && !play.paused && Meta.startWave(play.setupTerms)>1
                text:"Temporary passage · Starts on Wave "+Meta.startWave(play.setupTerms)
                color:"#f0cea7"
                font.family:"Inter"
                font.pixelSize:Ui.UiMetrics.text(13)
                wrapMode:Text.WordWrap
            }
            PetPicker {
                Layout.fillWidth: true
                visible: play.phase === "ready" && !play.paused
                availablePets: play.availablePets
                selectedId: play.petChoice
                onPetSelected: function(id) {
                    if (Rules.choosePet(play.run, id))
                        play.publish()
                }
            }
            Text {
                Layout.fillWidth: true
                visible: false
                text:"Fire · "+Controls.buttonNames[Controls.buttons.indexOf(play.shootButton)]
                    +"     Reload · "+Controls.label(play.bindings,"reload")+"     Aim · "+Controls.label(play.bindings,"aim")
                    +"\nAbilities · "+Controls.label(play.bindings,"active1")+" / "+Controls.label(play.bindings,"active2")
                    +"     Shield · "+Controls.label(play.bindings,"shield")+"     Seal · "+Controls.label(play.bindings,"seal")
                lineHeight: 1.5
                wrapMode: Text.WordWrap
                color: "#ffd0a9"
                font.family: "IBM Plex Mono"
                font.pixelSize: Ui.UiMetrics.text(12)
            }
            Loader {
                Layout.fillWidth: true
                active: play.paused
                visible: active
                sourceComponent: RunOverview {
                    onEntryRequested:function(chapter,id) { play.codexRequested(chapter,id) }
                    run: play.run
                    revision: play.revision
                    tab: play.pauseTab
                    motion: play.motion
                    dense: play.compactLayout
                    wallpaperFit: play.wallpaperFit
                    wallpaperQuality: play.wallpaperQuality
                    wallpaperZoom: play.wallpaperZoom
                    mouseTurns: play.mouseTurns
                    frameLimit:play.frameLimit
                    showTimer:play.showTimer
                    autoSave:play.autoSave
                    backgroundPlay:play.backgroundPlay
                    onBackgroundPlayRequested:function(value) {play.backgroundPlayRequested(value)}
                    onAutoSaveRequested:function(value) { play.autoSaveRequested(value) }
                    onHudScaleRequested:function(value) { play.hudScaleRequested(value) }
                    onTextScaleRequested:function(value) { play.textScaleRequested(value) }
                    onFrameLimitRequested:function(value) {play.frameLimitRequested(value)}
                    onTimerRequested:function(value) {play.timerRequested(value)}
                    graphicsDetail:play.graphicsDetail
                    initialDetail:play.initialDetail
                    graphicsRestartText:play.graphicsRestartText
                    transitionStyle:play.transitionStyle
                    transitionStrength:play.transitionStrength
                    onDetailRequested:function(value) {play.detailRequested(value)}
                    onTransitionStyleRequested:function(value) {play.transitionStyleRequested(value)}
                    onTransitionStrengthRequested:function(value) {play.transitionStrengthRequested(value)}
                    onMouseTurnsRequested: function(value) { play.mouseTurnsRequested(value) }
                    onFitRequested: function(value) { play.fitRequested(value) }
                    onQualityRequested: function(value) { play.qualityRequested(value) }
                    onZoomRequested: function(value) { play.zoomRequested(value) }
                    onTabRequested: function(name) { play.pauseTab = name }
                    onAudioLevelRequested:function(key,value) {play.audioLevelRequested(key,value)}
                    onMotionRequested: play.motionRequested()
                    onDebugGearRequested: function(group, id, slot) {
                        if (Rules.equipDebugGear(play.run, group, id, slot))
                            play.publish()
                    }
                    onInventoryRequested: function(cell, group, slot) {
                        if (Rules.swapInventory(play.run, cell, group, slot))
                            play.publish()
                    }
                    onSwapRequested: function(group, from, to) {
                        if (Rules.canEditLoadout(play.run) && Gear.swap(play.run, group, from, to))
                            play.publish()
                    }
                }
            }
            Loader {
                Layout.fillWidth: true
                active: play.phase === "shop" && !play.paused
                visible: active
                sourceComponent: BossShop {
                    onEntryRequested:function(chapter,id) { play.codexRequested(chapter,id) }
                    run: play.run
                    revision: play.revision
                    compact: play.compactLayout
                    nativeScene: !play.projectedMode
                    detail:play.graphicsDetail
                    motion: play.motion
                    onRefundRequested:function(group,id) {
                        if (play.allowed && Rules.refundAbility(play.run,group,id)) {
                            play.publish()
                            play.saveCheckpoint(true)
                        }
                    }
                    onFreezeRequested:function(id) {if (play.allowed && Rules.freezeOffer(play.run,id)) {play.publish();play.saveCheckpoint(true)}}
                    onPurchaseRequested: function(offerId, slot, confirmed) {
                        if (play.allowed && Rules.buy(play.run, offerId, slot, confirmed)) {
                            if (audio.item)
                                audio.item.play("buy")
                            play.publish()
                            play.saveCheckpoint(true)
                        }
                    }
                }
            }
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                uniformCellWidths: true
                visible: play.phase === "reward" && !play.paused
                z: 5
                Repeater {
                    id: rewardList
                    model: {
                        play.revision
                        return play.phase === "reward" ? play.run.offers : []
                    }
                    delegate: ColumnLayout {
                        id:rewardListing
                        required property var modelData
                        Layout.fillWidth:true
                        Layout.alignment:Qt.AlignTop
                        spacing:4
                        RewardCard {
                            onEntryRequested:function(chapter,id) {play.codexRequested(chapter,id)}
                            Layout.fillWidth:true
                            offer:rewardListing.modelData
                            run:play.run
                            revision:play.revision
                            flask:true
                            selected:play.selectedOffer===offer.id
                            compact:play.compactLayout
                            animate:play.motion && play.allowed
                            hintStats:{
                                play.revision
                                return offer.category==="Weapon"
                                    ? Gear.weaponComparison(play.run,Gear.current(play.run),{id:offer.id,level:offer.upgradeLevel || 0}) : []
                            }
                            dragGroup:{play.revision; return offer.category!=="Supply" && Gear.defaultSlot(play.run,offer)===-1
                                ? Gear.groupOf(offer) : ""}
                            onDragStarted:play.selectedOffer=offer.id
                            onClicked:play.pickReward(offer.id)
                        }
                        Ui.ActionButton {
                            objectName:"freeze-reward-"+rewardListing.modelData.id
                            Layout.fillWidth:true
                            visible:{play.revision;return Draw.canFreeze(play.run)}
                            readonly property bool frozen:{play.revision;return Draw.isFrozen(play.run,rewardListing.modelData)}
                            enabled:{play.revision;return !!Draw.freezable(play.run,"reward",rewardListing.modelData)}
                            primary:frozen
                            accent:"#a5d6f0"
                            text:frozen ? "❄ Frozen" : "Freeze"
                            hintText:"Bring this reward back at your next wave reward."
                            onClicked:if (Rules.freezeOffer(play.run,rewardListing.modelData.id)) play.publish()
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                uniformCellSizes: true
                visible: play.phase === "bossReward" && !play.paused
                Repeater {
                    id: boonList
                    model: { play.revision; return play.run.bossOffers }
                    RewardCard {
                        required property var modelData
                        Layout.fillWidth: true
                        offer: ({ id:modelData.id, title:modelData.title, category:modelData.display, description:modelData.description })
                        compact: play.compactLayout
                        onClicked: {
                            if (play.allowed && Rules.chooseBoon(play.run, modelData.id))
                                play.publish()
                        }
                    }
                }
            }
            LoadoutGrid {
                onEntryRequested:function(chapter,id) { play.codexRequested(chapter,id) }
                Layout.fillWidth: true
                compact: true
                dense: play.compactLayout
                visible: play.phase === "reward" && !play.paused && play.selectedGroup.length > 0
                run: play.run
                revision: play.revision
                animate: play.motion
                groups: play.selectedGroup ? [play.selectedGroup] : []
                offerId: play.selectedOffer
                onPlaced: function(id, slot) { play.pickReward(id, slot) }
            }
            RowLayout {
                Layout.fillWidth: true
                visible: play.phase === "reward" && !play.paused && play.selectedOffer.length > 0
                Ui.ActionButton {
                    objectName: "stashReward"
                    enabled: { play.revision; return Gear.canStore(play.run) }
                    text: enabled ? "Store in inventory" : "Inventory full"
                    onClicked: play.pickReward(play.selectedOffer, Gear.inventoryDestination)
                }
                Ui.ActionButton {
                    text: "Back"
                    onClicked: play.selectedOffer = ""
                }
                Item { Layout.fillWidth: true }
            }
            }
        }
        RowLayout {
            id:menuFooter
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            anchors.margins:selectionPanel.inset
            spacing: 7
            Ui.ActionButton {
                id: primaryAction
                objectName:play.phase==="defeat" ? "preparationAction" : "primaryPlayAction"
                primary: true
                enabled: play.allowed
                visible: play.paused || ["ready","between","defeat"].includes(play.phase)
                text: {
                    play.revision
                    return play.paused ? "Resume" : play.preparing ? "Begin wave " + play.upcomingStage.wave
                        : "Retry"
                }
                Accessible.description:"You can also press "+Controls.label(play.bindings,"confirm")+"."
                onClicked: play.mainAction()
            }
            Ui.ActionButton {
                objectName: "refreshSelection"
                visible: play.selecting && !play.paused
                enabled: play.canReroll
                text: play.refreshes>0 ? "Free reroll · "+play.refreshes : "Reroll · "+play.rerollCost+" gold"
                onClicked: play.refreshSelection()
            }
            Ui.ActionButton {
                objectName: "skipSelection"
                visible: play.selecting && !play.paused
                enabled: !play.unclaimedPurchase
                text: play.phase === "ready" ? "Skip pet" : play.phase === "shop"
                    ? play.unclaimedPurchase ? "Claim your purchase" : "Leave shop" : "Skip"
                onClicked: play.skipSelection()
            }
            Item { Layout.fillWidth: true }
            Ui.ActionButton {
                objectName:"openRunGrimoire"
                visible:play.paused || play.preparing
                text:"Grimoire"
                onClicked:play.codexRequested("enemies","")
            }
            Ui.ActionButton {
                visible: play.preparing && !play.paused
                text: "Display"
                onClicked: play.pauseRun("settings")
            }
            Ui.ActionButton {
                objectName: "restartRun"
                visible: play.paused
                text: "Restart"
                onClicked: {
                    play.paused = false
                    play.resetRun()
                }
            }
            Ui.ActionButton {
                objectName:"saveRun"
                visible:play.paused
                enabled:SaveData.phases.includes(play.phase) && play.run.health > 0
                text:play.saveNotice || "Save run"
                onClicked: {
                    play.publish()
                    play.saveCheckpoint(false)
                }
            }
            Ui.ActionButton {
                objectName:"retireRun"
                visible:play.paused && !play.run.training && play.phase!=="combat" && play.phase!=="ready" && play.run.metrics.waves>0
                text:play.retireArmed ? "Confirm return" : "Retire"
                hintText:"End the run and receive a grade. A hitless run can qualify for SSS here."
                onClicked: {
                    if (!play.retireArmed) {play.retireArmed=true;return}
                    if (Rules.retire(play.run)) {
                        play.paused=false
                        play.retireArmed=false
                        play.publish()
                    }
                }
            }
            Ui.ActionButton {
                objectName: "quitRun"
                visible: play.paused
                text: "Home"
                onClicked: play.exitRequested()
            }
        }
    }

    Loader {
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.top:parent.top
        anchors.bottom:selectionPanel.top
        anchors.topMargin: Math.min(76, Math.max(12, selectionPanel.y - 133))
        anchors.leftMargin:play.compactLayout ? 26 : 40
        anchors.rightMargin:play.compactLayout ? 26 : 40
        anchors.bottomMargin:6
        active:play.previewing
        visible:active
        sourceComponent:EnemyMuster {
            onEntryRequested:function(chapter,id) { play.codexRequested(chapter,id) }
            stage:play.upcomingStage
            companion:play.petChoice || play.flyingPet ? play.petSpec : null
            discoveries:play.knownEnemies
            compact:play.compactLayout
            software:play.projectedMode
            detail:play.graphicsDetail
            motion:play.allowed && play.motion && !play.bookVisible
        }
    }

    Rectangle {
        objectName: "achievementNotice"
        width: achievementLabel.implicitWidth + 28
        height: Math.max(32,Ui.UiMetrics.text(22))
        x: play.fighting ? 24 : (play.width - width) / 2
        y: play.fighting ? fieldHeader.height+6 : play.height - height - 20
        radius: 5
        color: "#ee20343c"
        border.color: "#73b8aa"
        visible: !play.outcomeKind && play.achievementText.length > 0
        Text {
            id: achievementLabel
            anchors.centerIn: parent
            text: play.achievementText
            color: Pets.uniqueColor
            font.family: "Inter"
            font.pixelSize: Ui.UiMetrics.text(13)
        }
    }

    Loader {
        id:postcard
        anchors.centerIn:parent
        width:Math.min(play.width-35,820)
        height:Math.min(play.height-24,535*Math.sqrt(Ui.UiMetrics.textScale))
        z:75
        active:play.phase==="defeat" && !play.outcomeKind && !!play.attemptReport
        sourceComponent:Ui.RunPostcard {
            report:play.attemptReport
            archived:play.attemptArchived
            onRestartRequested:play.resetRun()
            onArchiveRequested:if(play.vault && play.vault.archive(play.attemptReport)) play.attemptArchived=true
            onExitRequested:play.exitRequested()
        }
    }
    Loader {
        anchors.fill:parent
        z:100
        active:!!play.outcomeKind
        sourceComponent:play.outcomeKind==="dying" ? collapseView : resultView
    }
    Component {
        id:collapseView
        PlayerDeath {progress:play.deathProgress}
    }
    Component {
        id:resultView
        OutcomeSplash {loss:play.outcomeKind==="loss";motion:play.motion}
    }
    Loader {
        id:audio
        readonly property Item gameplay:play
        active:gameplay.sound
        sourceComponent:Audio {
            allowed:audio.gameplay.interactive && audio.gameplay.allowed && !audio.gameplay.paused && !audio.gameplay.bookVisible
            weaponId:audio.gameplay.weapon.id
            continuous:audio.gameplay.sustainedFire
            sustainWeapon:!!audio.gameplay.weapon.sustain
            flooded:audio.gameplay.takeover
            inBattle:audio.gameplay.fighting
            inAbyss:audio.gameplay.frontId==="down"
            windy:audio.gameplay.windy
            weather:audio.gameplay.weather
            bossWarning:audio.gameplay.fighting && audio.gameplay.bossDirection.length>0
            soulDrain:{
                audio.gameplay.revision
                return audio.gameplay.fighting && audio.gameplay.run.enemies.some(function(enemy){return enemy.soulChannel})
            }
        }
    }
    Rectangle {
        objectName:"crufixicatusScare"
        anchors.fill:parent
        z:450
        visible:play.fighting && play.scareLeft > 0
        color:"#030105"
        clip:true
        Image {
            anchors.fill:parent
            source:Qt.resolvedUrl("../art/crufixicatus-scream.png")
            fillMode:Image.PreserveAspectCrop
            scale:play.motion ? 1.03+(3-play.scareLeft)*.035+Math.sin(play.scareLeft*39)*.013 : 1
        }
        MouseArea {anchors.fill:parent; acceptedButtons:Qt.AllButtons}
    }
    AbilityFX {
        anchors.fill:parent
        z:12
        objectName:"castEffects"
        obscurity:play.obscurity
        textureLimit:play.graphicsDetail===3 ? 2240 : 1600
        effects:{play.revision;return play.run.abilityEvents}
        world:play.worldItem
        threeDimensional:!play.projectedMode && play.graphicsDetail>0 && !play.hypnotised
        clock:play.elapsed
        frontId:play.frontId
        active:play.fighting
        motion:play.motion
        spray:{play.revision;return play.run.sprayTime/5}
    }
    PetActionMeter {
        z:14
        pet:play.fighting && !play.hypnotised && !play.turning ? play.flyingPet : null
        world:play.worldItem
        clock:play.elapsed
        revision:play.revision
        frontId:play.frontId
        motion:play.motion
    }
    PetActionMeter {
        z:14
        pet:play.fighting && !play.hypnotised && !play.turning ? play.guestPet : null
        world:play.worldItem
        clock:play.elapsed
        revision:play.revision
        frontId:play.frontId
        motion:play.motion
    }
    PetActionMeter {
        z:14
        pet:play.fighting && !play.hypnotised && !play.turning ? play.tarotPet : null
        world:play.worldItem
        clock:play.elapsed
        revision:play.revision
        frontId:play.frontId
        motion:play.motion
    }
    Rectangle {
        z:26
        visible:play.fighting && !!play.weapon.staff
        width:Math.min(270,play.width*.32);height:40
        anchors.bottom:parent.bottom;anchors.horizontalCenter:parent.horizontalCenter;anchors.bottomMargin:11
        color:"#ee171320";border.color:play.weapon.color;radius:5
        Text {
            objectName:"staffChargeStatus"
            anchors.centerIn:parent
            text:play.casting ? "CASTING" : play.runes>=play.runeCost ? "SPELL READY · R / "+(play.glitchInput ? "LEFT" : "RIGHT")+" CLICK" : "SPELL · "+play.runes+" / "+play.runeCost+" ATTACKS"
            color:"#fff1e3";font.family:"monospace";font.pixelSize:10
        }
        Rectangle {anchors.left:parent.left;anchors.bottom:parent.bottom;height:3;width:parent.width*Math.min(1,play.runes/Math.max(1,play.runeCost));color:play.weapon.color}
    }
    Rectangle {
        anchors.fill:parent;z:70
        visible:!!play.run.training && play.run.training.mode==="rewind"
        color:"black"
        opacity:{play.revision;return play.run.training ? Math.sin(Math.min(1,play.run.training.age/1.15)*Math.PI) : 0}
    }
    Rectangle {
        id:trainingCard
        z:65
        visible:play.fighting && play.trainingDialogue
        anchors.horizontalCenter:parent.horizontalCenter;anchors.bottom:parent.bottom;anchors.bottomMargin:36
        width:Math.min(700,parent.width-40)
        height:trainingContent.implicitHeight+36
        color:"#f41c1520";radius:9;border.color:"#c47762";border.width:2
        Column {
            id:trainingContent
            x:18; y:18; width:trainingCard.width-36; spacing:10
            Text {width:parent.width;text:{play.revision;return play.run.training ? Tutorial.title(play.run) : ""}
                color:"#ffcd90";font.family:"serif";font.pixelSize:Ui.UiMetrics.text(25);font.bold:true;wrapMode:Text.WordWrap}
            Text {width:parent.width;text:{play.revision;return play.run.training ? play.tutorialControls(Tutorial.text(play.run)) : ""}
                color:"#efe0d6";font.pixelSize:Ui.UiMetrics.text(15);wrapMode:Text.WordWrap}
            Ui.ActionButton {objectName:"tutorialContinue";text:play.run.training && play.run.training.mode==="won" ? "Return to Home" : "Ready";primary:true
                onClicked:play.advanceTraining()}
        }
    }
    Column {
        visible:play.fighting && !!play.run.training && !play.trainingDialogue
        z:24
        spacing:5
        anchors.horizontalCenter:parent.horizontalCenter
        anchors.top:combatMessages.bottom
        anchors.topMargin:8
        Text {
            anchors.horizontalCenter:parent.horizontalCenter
            text:{play.revision;return play.run.training ? play.tutorialControls(Tutorial.prompt(play.run)) : ""}
            color:"#fff0d4";font.pixelSize:Ui.UiMetrics.text(16);style:Text.Outline;styleColor:"#1b1120"
        }
        Rectangle {
            anchors.horizontalCenter:parent.horizontalCenter
            visible:{play.revision;return play.run.training?.mode==="molt"}
            width:190; height:4; radius:2; color:"#502a3e"
            Rectangle {
                width:{play.revision;return parent.width*Math.min(1,(play.run.training?.age || 0)/Tutorial.moltDuration)}
                height:4; radius:2; color:"#cfdd70"
            }
        }
    }

}
