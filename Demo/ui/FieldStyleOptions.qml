import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:options
    Layout.fillWidth:true
    spacing:8
    readonly property color foreground:"#f5e9ef"
    readonly property color surface:"#2b2130"
    readonly property color outline:"#806279"
    component Caption:Label {
        Layout.fillWidth:true
        color:options.foreground
        font.pixelSize:UiMetrics.text(14)
        wrapMode:Text.WordWrap
    }
    component ColorEntry:RowLayout {
        id:row
        required property string title
        required property color current
        signal chosen(color value)
        Layout.fillWidth:true
        Caption {text:row.title}
        Rectangle {Layout.preferredWidth:18;Layout.preferredHeight:18;radius:4;color:row.current;border.color:options.outline}
        TextField {
            text:String(row.current);Layout.preferredWidth:105
            color:options.foreground
            selectionColor:"#744c68";selectedTextColor:"white"
            background:Rectangle {radius:4;color:options.surface;border.color:parent.activeFocus ? "#ffc398" : options.outline}
            Accessible.name:row.title
            validator:RegularExpressionValidator {regularExpression:/^#[0-9a-fA-F]{6}$/}
            onEditingFinished:{if (acceptableInput) row.chosen(text);text=String(row.current)}
        }
    }
    ColorEntry {title:"HUD accent";current:FieldStyle.hudColor;onChosen:value=>FieldStyle.hudColor=value}
    ColorEntry {title:"Companion glow";current:FieldStyle.petGlow;onChosen:value=>FieldStyle.petGlow=value}
    ColorEntry {title:"Aim colour";current:FieldStyle.aimColor;onChosen:value=>FieldStyle.aimColor=value}
    RowLayout {
        Layout.fillWidth:true
        Caption {text:"Aim shape"}
        ComboBox {
            id:shape
            Layout.preferredWidth:129
            model:["Weapon","Ring","Cross","Dot"]
            currentIndex:Math.max(0,model.indexOf(FieldStyle.aimShape))
            Accessible.name:"Aim shape"
            palette.button:options.surface
            palette.buttonText:options.foreground
            palette.base:options.surface
            palette.text:options.foreground
            background:Rectangle {radius:4;color:options.surface;border.color:shape.activeFocus ? "#ffc398" : options.outline}
            onActivated:FieldStyle.aimShape=currentText
        }
    }
    RowLayout {
        Layout.fillWidth:true
        Caption {text:"Aim response · "+Math.round(FieldStyle.aimSpeed*100)+"%"}
        Slider {
            Layout.preferredWidth:129
            from:.40;to:1.6;stepSize:.05
            value:FieldStyle.aimSpeed;Accessible.name:"Aim response"
            onMoved:FieldStyle.aimSpeed=value
        }
    }
}
