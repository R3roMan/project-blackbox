import QtQuick
import QtTest
import "../game" as Game
import "../game/Controls.js" as Controls

Item {
    width:800
    height:600

    Game.AmbientGallery {
        id: gallery
        anchors.fill:parent
        mouseLook:true
        motionAllowed:false
    }

    Game.IdleCompanion {
        id: pet
        width:800
        height:600
        front:"front"
        roaming:false
        software:true
    }

    Game.WallpaperTurn {
        id:wide
        width:800;height:600
        artDirectory:Qt.resolvedUrl("../../V0.1/kde/contents/images/")
        frontId:"front";previousFront:"front";direction:"up";progress:1;lab:false
        framing:"16:9";motion:false
    }

    TestCase {
        name:"IdleInput"
        when:windowShown

        function test_requiresControlForKeyboardAndPointerTurns() {
            gallery.forceActiveFocus()
            gallery.go("shrine",true)
            keyClick(Qt.Key_Down)
            compare(gallery.liveFront,"front")
            keyClick(Qt.Key_Down,Qt.ControlModifier)
            compare(gallery.liveFront,"down")
            keyClick(Qt.Key_Up,Qt.ControlModifier)
            compare(gallery.liveFront,"front")
            verify(!gallery.trackEdge(Qt.point(400,598),Qt.NoModifier))
            compare(gallery.liveFront,"front")
            verify(gallery.trackEdge(Qt.point(400,598),Qt.ControlModifier))
            compare(gallery.liveFront,"down")
            gallery.changeMode("performance")
            gallery.leaveEdge()
            verify(gallery.trackEdge(Qt.point(400,2),Qt.ControlModifier))
            compare(gallery.liveFront,"front")
            compare(Controls.idleDirection(Qt.Key_Left,Qt.ControlModifier|Qt.ShiftModifier),"")
        }

        function test_codeIsAnOptionalRearFace() {
            gallery.pureCode=false
            gallery.go("sky",true)
            gallery.move("up")
            compare(gallery.liveFront,"up")
            gallery.pureCode=true
            for (const [room,direction,exit,expected] of [
                ["media","left","left","right"],["lab","right","right","left"],
                ["sky","up","down","up"],["abyss","down","up","down"]]) {
                gallery.go(room,true)
                gallery.move(direction)
                compare(gallery.liveFront,"back")
                gallery.move(exit)
                compare(gallery.liveFront,expected)
            }
            gallery.go("shrine",true)
            gallery.pureCode=false
        }

        function test_sixteenNineComposition() {
            const composition=findChild(wide,"wallpaperComposition")
            compare(composition.width,800)
            compare(composition.height,450)
            compare(composition.y,75)
        }

        function test_petBobsAndReactsToReachingThePointer() {
            const body=findChild(pet,"idlePetBody")
            pet.beginFlight(480,160,"flight",4)
            const origin=body.x
            pet.tick(.9)
            verify(body.x!==origin)
            verify(Math.abs(pet.bob)>.01)
            pet.observePointer(body.x+body.width*.5,body.y+body.height*.48)
            pet.startCuriosity()
            compare(findChild(pet,"idlePetReaction").text,"?")
            pet.tick(.033)
            compare(findChild(pet,"idlePetReaction").text,"!")
            pet.beginFlight(55,130,"sleep",.5)
            pet.tick(.6)
            compare(pet.pose,"sleep")
            verify(pet.poseEnd-pet.clock>=23)
            compare(pet.bob,0)
        }

        function test_petScalesWithLogicalViewport() {
            pet.width=1920
            pet.height=1080
            const normal=pet.petWidth
            verify(normal>300)
            pet.width=3840
            pet.height=2160
            fuzzyCompare(pet.petWidth,normal*2,1)
            pet.width=340
            pet.height=600
            verify(pet.petWidth<130)
        }

        function test_petEnclosureAndClickReactions() {
            pet.width=800;pet.height=600
            const body=findChild(pet,"idlePetBody")
            body.x=190;body.y=145
            pet.enclosure=Qt.rect(100,90,370,300)
            pet.enclosureArmed=true
            pet.updateEnclosure(1000)
            compare(pet.confinedSince,1000)
            pet.flyTo(750,540,.1)
            pet.tick(.2);pet.updateEnclosure(1200)
            verify(body.x+body.width<=470 && body.y+body.height<=390)
            verify(!pet.canReach(750,540))
            pet.mood=.13
            mouseClick(body,body.width*.50,body.height*.51)
            compare(pet.clickMood,"upset")
            pet.mood=.9
            mouseClick(body,body.width*.50,body.height*.51)
            compare(pet.clickMood,"happy")
            compare(findChild(pet,"idlePetReaction").text,"♥ ♥ ♥ ♥ ♥")
            pet.enclosureArmed=false
            pet.updateEnclosure(1300)
            verify(!pet.confined)
            verify(pet.canReach(750,540))
            pet.mood=.5
        }
    }
}
