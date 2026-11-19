import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game/Controls.js" as Controls

ColumnLayout {
    id:editor
    property string value:"{}"
    property bool desktop:false
    property bool wheelSwitch:true
    property string activeRow:""
    property string notice:""
    readonly property var profile:Controls.read(value)
    signal bindingsRequested(string value)
    signal wheelRequested(bool value)
    spacing:10

    function update(id,replacement) {
        const next=Object.assign({},profile)
        if (replacement!==undefined) next[id]=replacement
        else delete next[id]
        const encoded=JSON.stringify(next)
        if (!Controls.valid(encoded)) {
            const conflict=typeof replacement==="object" && replacement ? Controls.conflict(profile,id,replacement) : null
            const mouseId=id==="mouseFire" ? "mouseReload" : "mouseFire"
            notice=conflict ? Controls.sequence(replacement)+" is assigned to "+conflict.title.toLowerCase()+"."
                : id.startsWith("mouse") ? "That button is assigned to "+(mouseId==="mouseFire" ? "fire." : "reload.")
                : "That binding overlaps another action. Reset the conflicting action first."
            return false
        }
        notice=""
        bindingsRequested(encoded)
        return true
    }

    Text {
        Layout.fillWidth:true
        text:"Choose an action and press a key or key combination. Escape cancels recording."
        font.pixelSize:UiMetrics.text(14)
        color:"#d6c5d4"
        wrapMode:Text.Wrap
    }
    Text {
        Layout.fillWidth:true
        visible:editor.notice.length>0
        text:editor.notice
        color:"#ffc98d"
        font.pixelSize:UiMetrics.text(14)
        wrapMode:Text.Wrap
    }
    Item {
        visible:editor.desktop
        Layout.fillWidth:true
        implicitHeight:desktopRows.implicitHeight
        ColumnLayout {
            id:desktopRows
            anchors.left:parent.left;anchors.right:parent.right
            Text {text:"Idle shortcuts";color:"#ffcfab";font.bold:true;font.pixelSize:UiMetrics.text(16)}
            Repeater {model:editor.desktop ? Controls.desktop : []; BindingRow {required property var modelData;action:modelData}}
        }
    }
    Text {text:"Gameplay keys";color:"#ffcfab";font.bold:true;font.pixelSize:UiMetrics.text(16)}
    Repeater {model:Controls.keyboard; BindingRow {required property var modelData;action:modelData}}
    Text {text:"Mouse";color:"#ffcfab";font.bold:true;font.pixelSize:UiMetrics.text(16)}
    Repeater {
        model:[{id:"mouseFire",title:"Fire"},{id:"mouseReload",title:"Reload or use weapon skill"}]
        ColumnLayout {
            required property var modelData
            Layout.fillWidth:true
            Text {Layout.fillWidth:true; text:parent.modelData.title; color:"#e8d8e4";font.pixelSize:UiMetrics.text(14);wrapMode:Text.Wrap}
            ComboBox {
                Layout.fillWidth:true
                model:Controls.buttonNames
                currentIndex:Controls.buttons.indexOf(Controls.mouse(editor.profile,parent.modelData.id))
                popup.popupType:Popup.Item
                onActivated:function(index){
                    const id=parent.modelData.id
                    if (!editor.update(id,Controls.buttons[index]))
                        currentIndex=Controls.buttons.indexOf(Controls.mouse(editor.profile,id))
                }
            }
        }
    }
    CheckBox {
        text:"Scroll to switch weapons"
        palette.windowText:"#eedfe6";palette.text:"#eedfe6"
        checked:editor.wheelSwitch
        onClicked:editor.wheelRequested(checked)
    }
    ActionButton {
        Layout.fillWidth:true
        text:"Restore default bindings"
        onClicked:{editor.notice="";editor.activeRow="";editor.bindingsRequested("{}")}
    }
    component BindingRow: ColumnLayout {
        id:row
        required property var action
        readonly property bool recording:editor.activeRow===action.id
        property int modifierCandidate:0
        Layout.fillWidth:true
        spacing:4

        function commit(key,mods) {
            if (!Controls.keyName(key) || (action.id!=="idleControls" && action.id!=="quickStart"
                    && ["pause","confirm","timer","loadout","grimoire"].includes(action.id) && Controls.ownModifiers[key])) {
                editor.notice="Choose a named key or a key combination for this action."
                return
            }
            editor.update(action.id,{key:key,mods:Controls.normalizeModifiers(key,mods)})
            editor.activeRow=""
        }

        Text {Layout.fillWidth:true; text:row.action.title; color:"#e8d8e4";font.pixelSize:UiMetrics.text(14);wrapMode:Text.Wrap}
        RowLayout {
            Layout.fillWidth:true
            ActionButton {
                id:capture
                objectName:"bind-"+row.action.id
                Layout.fillWidth:true
                Layout.minimumWidth:0
                text:row.recording ? "Press a key…" : Controls.label(editor.profile,row.action.id)
                Accessible.name:row.action.title+" · "+text
                primary:row.recording
                Keys.priority:Keys.BeforeItem
                Keys.onShortcutOverride:function(event) {if (row.recording) event.accepted=true}
                Keys.onPressed:function(event) {
                    if (!row.recording) return
                    event.accepted=true
                    if (event.isAutoRepeat) return
                    if (event.key===Qt.Key_Escape) {editor.activeRow="";return}
                    if (Controls.ownModifiers[event.key]) {
                        row.modifierCandidate=event.key
                        return
                    }
                    row.modifierCandidate=0
                    row.commit(event.key,event.modifiers)
                }
                Keys.onReleased:function(event) {
                    if (!row.recording || event.isAutoRepeat || event.key!==row.modifierCandidate) return
                    event.accepted=true
                    row.modifierCandidate=0
                    row.commit(event.key,event.modifiers)
                }
                onActiveFocusChanged:if (!activeFocus && row.recording) editor.activeRow=""
                onClicked:{
                    row.modifierCandidate=0
                    forceActiveFocus()
                    editor.notice=""
                    editor.activeRow=row.action.id
                }
            }
            ActionButton {
                text:"Reset"
                enabled:editor.profile[row.action.id]!==undefined
                Accessible.name:"Reset "+row.action.title
                onClicked:editor.update(row.action.id,undefined)
            }
        }
    }
}
