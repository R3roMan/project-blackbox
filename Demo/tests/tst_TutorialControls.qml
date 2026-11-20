import QtQuick
import QtTest
import "../game" as Game
import "../game/Rules.js" as Rules
import "../game/Tutorial.js" as Tutorial
import "../game/Loadout.js" as Gear
Item {
    width:1000;height:700
    property int wins:0
    Game.PlayScene {
        id:scene
        anchors.fill:parent
        artDirectory:Qt.resolvedUrl("../../V0.1/kde/contents/images/")
        allowed:true
        tutorial:true
        seed:1
        software:GraphicsInfo.api===GraphicsInfo.Software
        sound:false
        motion:false
        onCareerDelta:function(delta) {if(delta.trainingWins)parent.wins+=delta.trainingWins}
    }
    TestCase {
        name:"TutorialSceneInput"
        when:windowShown
        function ready() {
            const button=findChild(scene,"tutorialContinue")
            verify(button!==null)
            tryVerify(function(){return button.visible && button.enabled},1500)
            const prompt=Tutorial.title(scene.run)
            mouseClick(button,button.width/2,button.height/2)
            tryVerify(function(){return !scene.trainingDialogue},1500,"advance the "+prompt+" prompt")
        }
        function aimAndShoot(enemy) {
            tryCompare(scene,"shotTime",0,1500)
            const world=scene.worldItem
            const point=world.projection(Rules.lanePosition(enemy),Rules.elevation(enemy),enemy.depth)
            const mapped=world.mapToItem(scene,point.x,point.y)
            mouseClick(scene,mapped.x,mapped.y)
            wait(300)
        }
        function test_realButtonsShotsReloadShieldAndPhases() {
            tryVerify(function(){return scene.run.training && scene.trainingDialogue})
            ready()
            const run=scene.run
            for(let i=0;i<3;i++)aimAndShoot(Tutorial.boss(run))
            tryVerify(function(){return run.training.step===1},1600)
            ready();keyClick(Qt.Key_R)
            tryVerify(function(){return run.training.step===2},2000)
            ready();keyPress(Qt.Key_Space)
            tryVerify(function(){return run.training.step===3},3500)
            keyRelease(Qt.Key_Space)
            ready();keyPress(Qt.Key_Space)
            tryVerify(function(){return run.training.step===4},4000)
            keyRelease(Qt.Key_Space)
            ready()
            tryVerify(function(){return run.training.age>=2.04},3200)
            keyPress(Qt.Key_Space)
            tryVerify(function(){return run.training.step===5},1800)
            keyRelease(Qt.Key_Space)
            verify(Rules.shieldCharge(run)>.99)
            ready()
            tryVerify(function(){return run.training.step===6},5000)
            for(let step=6;step<=8;step++) {
                ready()
                tryCompare(scene,"frontId","front")
                if(step===7)keyClick(Qt.Key_A)
                if(step===8)keyClick(Qt.Key_D)
                const destination=["front","left","right"][step-6]
                tryCompare(scene,"frontId",destination,1500)
                let peon
                tryVerify(function(){
                    peon=run.enemies.find(function(e){return e.trainingPeon})
                    return !!peon
                },1500,"missing practice peon for lesson "+step)
                if(step===8) {
                    aimAndShoot(peon)
                    compare(peon.hp,3)
                    keyPress(Qt.Key_Shift)
                    tryVerify(function(){return scene.magnification>1},1000)
                }
                for(let i=0;i<3 && peon.hp>0;i++)aimAndShoot(peon)
                if(step===8)keyRelease(Qt.Key_Shift)
                verify(peon.hp<=0,"peon step "+step)
            }
            compare(run.training.mode,"phase1")
            Tutorial.boss(run).hp=2
            aimAndShoot(Tutorial.boss(run))
            tryVerify(function(){return run.training.mode==="molt"},1200)
            tryVerify(function(){return run.training.mode==="activeDialogue"},7500)
            ready();keyClick(Qt.Key_Q)
            tryVerify(function(){return run.training.mode==="encouragement"},1400)
            ready();wait(350)
            compare(run.training.mode,"phase2")
            Tutorial.boss(run).hp=2
            aimAndShoot(Tutorial.boss(run))
            tryVerify(function(){return run.training.mode==="won"},1400)
            compare(run.metrics.trainingWins,1)
        }
    }
}
