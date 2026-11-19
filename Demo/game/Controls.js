.pragma library

var keyboard = [
    {id:"left",title:"Turn left",keys:[Qt.Key_A,Qt.Key_Left]},
    {id:"right",title:"Turn right",keys:[Qt.Key_D,Qt.Key_Right]},
    {id:"up",title:"Look up",keys:[Qt.Key_W,Qt.Key_Up]},
    {id:"down",title:"Look down",keys:[Qt.Key_S,Qt.Key_Down]},
    {id:"weapon1",title:"Weapon slot 1",keys:[Qt.Key_1]},
    {id:"weapon2",title:"Weapon slot 2",keys:[Qt.Key_2]},
    {id:"fire",title:"Fire with keyboard",keys:[]},
    {id:"reload",title:"Reload or use weapon skill",keys:[Qt.Key_R]},
    {id:"aim",title:"Hold to aim",keys:[Qt.Key_Shift]},
    {id:"shield",title:"Hold to raise shield",keys:[Qt.Key_Space]},
    {id:"active1",title:"Active ability 1",keys:[Qt.Key_Q]},
    {id:"active2",title:"Active ability 2",keys:[Qt.Key_E]},
    {id:"seal",title:"Hold to seal the Abyss",keys:[Qt.Key_F]},
    {id:"pause",title:"Pause or go back",keys:[Qt.Key_Escape]},
    {id:"confirm",title:"Confirm or begin wave",keys:[Qt.Key_Return,Qt.Key_Enter]},
    {id:"timer",title:"Toggle wave timer",keys:[Qt.Key_Period]},
    {id:"loadout",title:"Open loadout",keys:[Qt.Key_T]},
    {id:"grimoire",title:"Open Grimoire",keys:[Qt.Key_I]}
]
var desktop = [
    {id:"idleControls",title:"Show or hide Idle controls",keys:[Qt.Key_Control]},
    {id:"quickMouse",title:"Quick start mouse shortcut",pointer:true,button:Qt.LeftButton,mods:Qt.ControlModifier},
    {id:"quickStart",title:"Quick start keyboard shortcut (hold)",keys:[Qt.Key_Space],mods:Qt.ControlModifier}
]
var navigation = ["left","right","up","down"]
var buttons = [Qt.LeftButton,Qt.RightButton,Qt.MiddleButton,Qt.BackButton,Qt.ForwardButton]
var buttonNames = ["Left button","Right button","Middle button","Back button","Forward button"]
var modifierMask = Qt.ControlModifier | Qt.AltModifier | Qt.ShiftModifier | Qt.MetaModifier
var ownModifiers = {
    [Qt.Key_Control]:Qt.ControlModifier,
    [Qt.Key_Alt]:Qt.AltModifier,
    [Qt.Key_Shift]:Qt.ShiftModifier,
    [Qt.Key_Meta]:Qt.MetaModifier
}

function definition(id) {
    return keyboard.concat(desktop).find(entry=>entry.id===id)
}

function binding(profile,id) {
    const entry=definition(id)
    if (entry?.pointer) return []
    const value=profile?.[id]
    if (value) return [value]
    return entry ? entry.keys.map(key=>({key:key,mods:entry.mods || 0})) : []
}

function normalizeModifiers(key,mods) {
    return mods & modifierMask & ~(ownModifiers[key] || 0)
}

function matches(profile,id,event) {
    return binding(profile,id).some(chord=>chord.key===event.key
        && chord.mods===normalizeModifiers(event.key,event.modifiers))
}

function releases(profile,id,key) {
    return binding(profile,id).some(chord=>chord.key===key || (chord.mods & (ownModifiers[key] || 0)))
}

function action(profile,actions,event) {
    return actions.find(entry=>matches(profile,typeof entry==="string" ? entry : entry.id,event))
}

function keyName(key) {
    const names={
        [Qt.Key_Control]:"Ctrl",[Qt.Key_Shift]:"Shift",[Qt.Key_Alt]:"Alt",[Qt.Key_Meta]:"Meta",
        [Qt.Key_Space]:"Space",[Qt.Key_Escape]:"Esc",[Qt.Key_Return]:"Return",[Qt.Key_Enter]:"Enter",
        [Qt.Key_Left]:"Left",[Qt.Key_Right]:"Right",[Qt.Key_Up]:"Up",[Qt.Key_Down]:"Down",
        [Qt.Key_Backspace]:"Backspace",[Qt.Key_Delete]:"Del",[Qt.Key_Insert]:"Ins",
        [Qt.Key_Tab]:"Tab",[Qt.Key_Backtab]:"Backtab",[Qt.Key_Home]:"Home",[Qt.Key_End]:"End",
        [Qt.Key_PageUp]:"PgUp",[Qt.Key_PageDown]:"PgDown"
    }
    if (names[key]) return names[key]
    if (key>=Qt.Key_F1 && key<=Qt.Key_F35) return "F"+(key-Qt.Key_F1+1)
    if (key>=33 && key<=0xfffd) return String.fromCharCode(key)
    return ""
}

function quickPointer(profile) {
    const entry=definition("quickMouse")
    return profile?.quickMouse || {button:entry.button,mods:entry.mods}
}

function sequence(chord) {
    const keys=[]
    if (chord.mods & Qt.ControlModifier) keys.push("Ctrl")
    if (chord.mods & Qt.AltModifier) keys.push("Alt")
    if (chord.mods & Qt.ShiftModifier) keys.push("Shift")
    if (chord.mods & Qt.MetaModifier) keys.push("Meta")
    keys.push(chord.button ? buttonNames[buttons.indexOf(chord.button)] : keyName(chord.key))
    return keys.join("+")
}

function sequences(profile,id) {return binding(profile,id).map(sequence)}
function label(profile,id) {
    return id==="quickMouse" ? sequence(quickPointer(profile)) : sequences(profile,id).join(" / ") || "Unassigned"
}

function conflict(profile,id,chord) {
    const inIdle=desktop.some(entry=>entry.id===id)
    const group=inIdle ? desktop.concat(keyboard.filter(entry=>navigation.includes(entry.id)))
        : navigation.includes(id) ? keyboard.concat(desktop) : keyboard
    return group.find(entry=>entry.id!==id && binding(profile,entry.id).some(other=>other.key===chord.key && other.mods===chord.mods))
}

function mouse(profile,action) {
    return profile?.[action] || (action==="mouseFire" ? Qt.LeftButton : Qt.RightButton)
}

function valid(payload) {
    if (typeof payload!=="string" || payload.length>2800) return false
    try {
        const data=JSON.parse(payload)
        if (!data || typeof data!=="object" || Array.isArray(data)) return false
        for (const id of Object.keys(data)) {
            const item=data[id]
            if (id==="mouseFire" || id==="mouseReload") {
                if (!buttons.includes(item)) return false
            } else if (id==="quickMouse") {
                if (!item || !buttons.includes(item.button) || !Number.isInteger(item.mods) || (item.mods & modifierMask)!==item.mods)
                    return false
            } else if (!definition(id) || !item || !Number.isInteger(item.key) || !keyName(item.key)
                || !Number.isInteger(item.mods) || item.mods!==normalizeModifiers(item.key,item.mods)
                || conflict(data,id,item)) return false
        }
        return mouse(data,"mouseFire")!==mouse(data,"mouseReload")
    } catch (error) {
        return false
    }
}

function read(payload) {return valid(payload) ? JSON.parse(payload) : {}}
