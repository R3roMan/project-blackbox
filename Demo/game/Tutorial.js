.pragma library
.import "Rules.js" as Rules
.import "Loadout.js" as Gear
.import "Elements.js" as Elements

var lessons=[
    {title:"Meet Oblogabgalus",text:"A large target. A loaded pistol. Aim at his belly and land three shots.",goal:"Land three pistol shots.",kind:"shoot",front:"front"},
    {title:"Keep the chamber fed",text:"Press R, or right-click, to reload. Watch the magazine fill before firing again.",goal:"Complete one reload.",kind:"reload",front:"front"},
    {title:"Stand your ground",text:"Hold Space to raise your shield. His open mouth warns of a bite. Release Space after the block. Raising it costs 10% charge. Holding it up drains the meter.",goal:"Block his bite with Space.",kind:"melee",front:"front"},
    {title:"Catch the warning",text:"This time he will spit. Hold Space before the projectile reaches you. You can also shoot hostile projectiles in ordinary battles.",goal:"Block the incoming projectile.",kind:"projectile",front:"front"},
    {title:"Perfect parry",text:"Wait for the final flash of his windup. Press Space just before the bite, within the last fifth of a second. A perfect parry instantly restores the shield to 100%.",goal:"Wait for the flash, then press Space.",kind:"parry",front:"front"},
    {title:"Let the shield recover",text:"Watch the blue field-shield bar. It fills while the shield is lowered. The marker at 20% shows when you can raise it again.",goal:"Release Space and let the meter cross the 20% marker.",kind:"recharge",front:"front"},
    {title:"Thin the crowd",text:"Shoot the small demon beside him. These practice targets will wait for you.",goal:"Defeat the stationary peon.",kind:"peon",front:"front"},
    {title:"A threat to the left",text:"Tap A or the left arrow, or move your mouse to the left edge. Find and shoot the peon. Return with D or the right edge.",goal:"Look left and defeat the peon.",kind:"peon",front:"left"},
    {title:"Watch both sides",text:"Reach the right-hand laboratory. Hold Shift and shoot the final peon. A scoped gun hit marks a demon for four seconds, so follow-up attacks on it bypass miss rolls. Release Shift before turning.",goal:"Look right. Hold Shift and shoot the peon.",kind:"peon",front:"right",scope:true}
]

var moltDuration=4.2

function create(seed,unlocks) {
    const run=Rules.create(seed,unlocks)
    run.debug=true
    run.wave=1
    run.phase="combat"
    run.nextStage=null
    run.pending=[]
    run.pet=null
    run.slots=Gear.starter()
    run.training={mode:"dialogue",step:0,age:0,front:"front",base:{},attempt:0,phase:1,bossId:0,message:"",lessonMap:2}
    const boss=Rules.spawn(run,{type:"oblogabgalus",front:"front",lane:0})
    boss.depth=980
    boss.hp=boss.maxHp=boss.baseHp=60
    boss.damage=7
    run.training.bossId=boss.id
    return run
}

function boss(run) {return Rules.target(run,run.training.bossId)}
function frozen(run) {return run.training && ["dialogue","activeDialogue","encouragement","molt","rewind","won"].includes(run.training.mode)}
function dialogue(run) {return run.training && ["dialogue","activeDialogue","encouragement","won"].includes(run.training.mode)}
function title(run) {
    const mode=run.training.mode
    return mode==="activeDialogue" ? "One more tool" : mode==="encouragement" ? "You've got this" : mode==="won" ? "Shrine graduate" : lessons[run.training.step].title
}
function text(run) {
    const mode=run.training.mode
    return mode==="activeDialogue" ? "He is smaller and angrier. Shock pulse is now in Q. Close this message, then press Q while facing him. Each active has its own cooldown."
        : mode==="encouragement" ? "Well done. Now finish the fight. Watch his mouth, block his charge, and follow the arrows when he changes wallpaper."
        : mode==="won" ? "The shrine remembers. Graduation pistol is unlocked for future runs. Its matching kit is strongest in the early waves."
        : lessons[run.training.step].text
}
function prompt(run) {
    const t=run.training,mode=t.mode
    if(mode==="lesson" && lessons[t.step].kind==="parry" && t.age>=2.02 && !t.struck) return "PARRY NOW   ·   SPACE"
    return mode==="lesson" ? lessons[run.training.step].goal : mode==="activeLesson" ? "Press Q to use Shock pulse." : mode==="phase1" ? "Try it on your own. Defeat Oblogabgalus."
        : mode==="phase2" ? "Phase II · Follow him. Block the charge. Use Q." : mode==="molt" ? "Oblogabgalus is molting…" : ""
}

function readyToFire(run,scoped) {
    const t=run.training
    if (!t || t.mode!=="lesson" || !lessons[t.step].scope || scoped)
        return true
    Rules.announce(run,"Hold Shift, then shoot the practice demon.")
    return false
}

function resetLesson(run) {
    const t=run.training,b=boss(run),lesson=lessons[t.step]
    run.health=200;run.elements=Elements.fresh()
    run.bolts=[];run.boltRoster++
    run.enemies=run.enemies.filter(function(e){return e.id===t.bossId});run.roster++
    run.playerFront="front";t.front="front"
    run.shield.held=run.shield.raised=false
    run.shield.cool=lesson.kind==="recharge" ? run.shield.recovery*.94 : 0
    const gun=Gear.current(run)
    Object.assign(gun,Gear.makeItem("pistol"))
    if (lesson.kind==="reload") gun.ammo=2
    b.front="front";b.depth=980;b.lane=0;b.hp=60;b.attack=2.0;b.attackFlash=0;b.warp=0
    if (lesson.kind==="melee" || lesson.kind==="parry") b.depth=280
    if (lesson.kind==="peon") {
        // Keep the practice target clear of the trainer's much larger hit volume.
        const peon=Rules.spawn(run,{type:"silophosus",front:lesson.front,lane:350})
        peon.trainingPeon=true;peon.warp=0;peon.depth=900;peon.hp=peon.maxHp=peon.baseHp=3
    }
    t.base=Object.assign({},run.metrics);t.health=run.health;t.age=0;t.struck=false;t.mode="lesson"
}

function advance(run) {
    const t=run.training
    if (t.mode==="dialogue") resetLesson(run)
    else if (t.mode==="activeDialogue") {
        t.mode="activeLesson";t.age=0
        run.playerFront="front";t.front="front"
        const b=boss(run);b.front="front";b.depth=900
        run.slots.active[0].item={id:"shock",level:0}
        run.cooldowns.shock=0
    } else if (t.mode==="encouragement") beginFight(run,2)
}

function beginFight(run,phase) {
    const t=run.training,b=boss(run)
    t.mode=phase===1 ? "phase1" : "phase2";t.phase=phase;t.age=0;t.nextPeon=10;t.nextTurn=7;t.front=run.playerFront
    b.hp=b.maxHp=b.baseHp=phase===1 ? 60 : 82
    b.depth=1000;b.attack=3;b.warp=0;b.front=run.playerFront;b.anger=phase===2
    b.damage=phase===1 ? 7 : 8
    run.health=200;run.bolts=[];run.boltRoster++;run.cooldowns.shock=0
    Gear.current(run).ammo=Rules.magazine(run)
    Rules.announce(run,phase===1 ? "Your turn. Defeat Oblogabgalus." : "Oblogabgalus · phase II","boss")
}

function rewind(run) {
    const t=run.training
    t.mode="rewind";t.age=0;t.attempt++
    run.shield.held=run.shield.raised=false
    Rules.announce(run,"Again. Watch the warning.","tutorialRewind")
}

function update(run,dt,sealing,firing,aim,viewReady) {
    const t=run.training
    if (!t) {Rules.update(run,dt,sealing,firing,aim,viewReady);return}
    if (t.mode==="won") return
    t.age+=dt
    const b=boss(run)
    if (frozen(run)) {
        for (const e of run.enemies) {
            e.age+=dt;e.warp=Math.max(0,e.warp-dt)
        }
        if (t.mode==="rewind" && t.age>=1.15) resetLesson(run)
        if (t.mode==="molt" && b) b.trainingMolt=Math.min(1,t.age/moltDuration)
        if (t.mode==="molt" && t.age>=moltDuration) {
            t.mode="activeDialogue";t.age=0;t.phase=2
            b.anger=true;b.hp=b.maxHp=b.baseHp=82
        }
        return
    }
    Rules.update(run,dt,false,firing,aim,viewReady)
    if (t.mode==="activeLesson") {
        if (run.cooldowns.shock>0) {t.mode="encouragement";t.age=0;run.bolts=[];run.boltRoster++}
        return
    }
    if (t.mode==="lesson") {
        const lesson=lessons[t.step],delta=function(key){return (run.metrics[key]||0)-(t.base[key]||0)}
        let success=false
        if (lesson.kind==="shoot") success=delta("trainingHits")>=3
        if (lesson.kind==="reload") success=delta("reloads")>0 && !Gear.current(run).reload
        if (lesson.kind==="peon") success=!run.enemies.some(function(e){return e.trainingPeon})
        if ((lesson.kind==="melee" || lesson.kind==="parry") && b) {
            b.attack=Math.max(0,2.2-t.age)
            if (t.age>=2.2 && !t.struck) {
                t.struck=true
                Rules.announce(run,null,"attack:"+b.type)
                Rules.damagePlayer(run,7,"front",b.type,false,{sourceId:b.id})
            }
            success=delta(lesson.kind==="parry" ? "parries" : "shieldBlocks")>0
            if (lesson.kind==="parry" && t.struck && !success) {rewind(run);return}
        }
        if (lesson.kind==="recharge") success=Rules.shieldCharge(run)>=.20 && !run.shield.held
        if (lesson.kind==="projectile" && b && t.age>1 && !t.struck) {
            t.struck=true
            Rules.launchBolts(run,b,{boltTime:1.2,accent:"#ffe17a",boltHealth:2})
        }
        if (lesson.kind==="projectile") success=delta("shieldBlocks")>0
        if (success) {
            t.struck=false
            Rules.announce(run,"Well done.","tutorialGood")
            if (++t.step>=lessons.length) {t.step=lessons.length-1;beginFight(run,1)}
            else {t.mode="dialogue";t.age=0}
        } else if (run.health<t.health || delta("shots")>delta("hitShots")+delta("trainingHits") && lesson.kind==="peon"
            || ["melee","projectile"].includes(lesson.kind) && t.age>5) {
            t.struck=false;rewind(run)
        }
        return
    }
    if (!["phase1","phase2"].includes(t.mode) || !b) return
    const phase=t.phase
    b.lane=Math.sin(t.age*(phase===1 ? .8 : 1.6))*b.depth*.20
    b.trainingHeight=Math.cos(t.age*1.2)*b.depth*.09
    b.attack-=dt
    if (phase===2 && b.special) {
        const charge=b.special
        // Older practice checkpoints used age for this timer.
        charge.time=(charge.time ?? charge.age ?? 0)+dt
        charge.warning=.8
        if (charge.time<charge.warning) b.attackFlash=0
        else if (charge.time<1.14) {
            b.depth=1000-(charge.time-charge.warning)/.34*720
            b.attackFlash=.20
        }
        else {
            Rules.announce(run,null,"attack:"+b.type)
            Rules.damagePlayer(run,12,b.front,b.type,false,{sourceId:b.id})
            b.depth=1000;b.special=null;b.attack=3.2
        }
    } else if (b.attack<=0 && !b.warp) {
        if (phase===2 && b.front===run.playerFront && Math.floor(t.age/3)%2===0) b.special={kind:"tutorialCharge",time:0,warning:.8}
        else {Rules.launchBolts(run,b,{boltTime:phase===1 ? 1.3 : 1.08,accent:"#ffe17a",boltHealth:2});b.attack=phase===1 ? 3.8 : 2.8;b.attackFlash=.33}
    }
    if (phase===2 && t.age>=t.nextPeon) {
        t.nextPeon+=10
        Rules.summon(run,{type:"silophosus",front:b.front,lane:100,summoned:true,tuning:.7})
    }
    if (phase===2 && t.age>=t.nextTurn && !b.special) {
        t.nextTurn+=8
        const fronts=["left","front","right"]
        b.front=fronts[(fronts.indexOf(b.front)+1)%3];Rules.beginArrival(b,.7)
    }
    if (run.phase==="defeat") {
        run.phase="combat";run.health=200;beginFight(run,phase)
        Rules.announce(run,"Take a breath. Try this phase again.","tutorialRewind")
    }
}
