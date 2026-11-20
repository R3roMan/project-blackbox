import QtQuick
import QtQuick3D
import QtTest
import "../game" as Game
import "../game/Rules.js" as Rules
TestCase {
    name:"CreatureRigSelection"
    Component {id:model;Game.Threat3D {animate:false}}
    function test_fatBodyLoadsOnlyForItsTwoSpecies() {
        const run=Rules.create(123)
        for(const type of ["silophosus","fhantamegus","spartalien","mystery","harvester","crufixicatus","lucifoverus","hasasasa","papapoganus","oblogabgalus"]) {
            const enemy=Rules.spawn(run,{type:type,front:"front",lane:0})
            const actor=model.createObject(null,{enemy:enemy,revision:1})
            verify(actor!==null,type)
            const loader=findChild(actor,"fatDemonLoader")
            verify(loader!==null,type)
            const expected=["papapoganus","oblogabgalus"].includes(type)
            compare(loader.active,expected,type)
            if(!expected)compare(loader.item,null,type)
            else verify(loader.item!==null,type)
            actor.destroy()
        }
    }
}
