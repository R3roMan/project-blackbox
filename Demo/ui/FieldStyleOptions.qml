import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    Layout.fillWidth:true
    component ColorEntry:RowLayout {
        id:row
        required property string title
        required property color current
        signal chosen(color value)
        Layout.fillWidth:true
        Label {text:row.title;Layout.fillWidth:true;wrapMode:Text.WordWrap}
        Rectangle {width:21;height:21;radius:4;color:row.current;border.color:"#e3dce3"}
        TextField {
            text:String(row.current);Layout.preferredWidth:105
            Accessible.name:row.title
            validator:RegularExpressionValidator {regularExpression:/^#[0-9a-fA-F]{6}$/}
            onEditingFinished:{if (acceptableInput) row.chosen(text);text=String(row.current)}
        }
    }
    ColorEntry {title:"HUD accent";current:FieldStyle.hudColor;onChosen:value=>FieldStyle.hudColor=value}
    ColorEntry {title:"Companion glow";current:FieldStyle.petGlow;onChosen:value=>FieldStyle.petGlow=value}
    ColorEntry {title:"Aim colour";current:FieldStyle.aimColor;onChosen:value=>FieldStyle.aimColor=value}
    ComboBox {
        Layout.fillWidth:true
        model:["Weapon","Ring","Cross","Dot"]
        currentIndex:Math.max(0,model.indexOf(FieldStyle.aimShape))
        Accessible.name:"Aim shape"
        onActivated:FieldStyle.aimShape=currentText
    }
    Label {text:"Aim response · "+Math.round(FieldStyle.aimSpeed*100)+"%"}
    Slider {
        Layout.fillWidth:true;from:.40;to:1.6;stepSize:.05
        value:FieldStyle.aimSpeed;Accessible.name:"Aim response"
        onMoved:FieldStyle.aimSpeed=value
    }
}
