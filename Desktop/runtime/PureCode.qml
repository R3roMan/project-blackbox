import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../native" as Native
import "TerminalLayout.js" as LayoutTree

FocusScope {
    id:workbench
    objectName:"pureCodeWallpaper"
    required property bool dark
    property bool exposed:false
    signal returnRequested()
    function stageDraft(text) {
        for (let index=0;index<panes.count;++index) {
            const pane=panes.get(index)
            if (pane.paneId!==activePane) continue
            if (!sessions[pane.shellId]?.stageDraft(text)) return false
            focusPane(pane.shellId)
            return true
        }
        return false
    }
    readonly property color base:terminalColors.background || (dark ? "#10151a" : "#eff4f1")
    readonly property bool darkChrome:base.r*.213+base.g*.715+base.b*.072<.46
    readonly property color chrome:terminalColors.background ? (darkChrome ? Qt.lighter(base,1.28) : Qt.darker(base,1.09))
        : darkChrome ? "#19252a" : "#dbe8e2"
    readonly property color lineColor:darkChrome ? "#37524c" : "#9bb4a8"
    readonly property color ink:terminalColors.foreground || (darkChrome ? "#e8f6ed" : "#18352b")
    readonly property color accent:terminalColors.accent || (darkChrome ? "#9adbbe" : "#225b47")
    palette.window:chrome
    palette.windowText:ink
    palette.button:chrome
    palette.buttonText:ink
    palette.base:base
    palette.text:ink
    palette.highlight:accent
    property int preferredFont:16
    property string paletteJson:"{}"
    property url wallpaperImage:""
    property real surfaceOpacity:.87
    readonly property var terminalColors: {
        try {return JSON.parse(paletteJson)} catch (_) {return {}}
    }
    readonly property int baseFont:Math.max(10,Math.min(26,preferredFont+localFontChange))
    property int localFontChange:0
    property int nextId:0
    property int activePane:0
    property var sessions:({})
    property var tree:null
    readonly property var placement:LayoutTree.arrange(tree,width,height)
    readonly property int paneCount:panes.count
    ListModel {id:panes}
    ListModel {id:dividers}
    Component {id:shellFactory;Native.TerminalSession {}}

    function openSession(id,posix) {
        const shell=shellFactory.createObject(workbench)
        sessions=Object.assign({},sessions)
        const next=Object.assign({},sessions)
        next[id]=shell
        sessions=next
        Qt.callLater(()=>{if (sessions[id]===shell) shell.start(Qt.resolvedUrl("terminal"),posix)})
    }
    function start() {
        if (tree) return
        const id=++nextId
        tree={pane:id}
        panes.append({paneId:id,shellId:id,outputOnly:false,posix:false})
        openSession(id,false)
        focusPane(id)
    }
    function focusPane(id) {
        activePane=id
        Qt.callLater(()=>{
            if (!workbench.exposed || workbench.activePane!==id) return
            for (let i=0;i<panes.count;++i)
                if (panes.get(i).paneId===id) {terminalPanes.itemAt(i)?.takeFocus();break}
        })
    }
    function split(pane,shell,across,output,posix) {
        const region=placement.panes[pane]
        if (panes.count>=12 || !region || (across ? region.w<258 : region.h<178)) return
        const id=++nextId
        tree=LayoutTree.replacePane(tree,pane,{divider:id,across,ratio:.5,first:{pane},second:{pane:id}})
        dividers.append({dividerId:id})
        panes.append({paneId:id,shellId:output ? shell : id,outputOnly:output,posix})
        if (!output) openSession(id,posix)
        focusPane(id)
    }
    function closePane(id,shell,output) {
        if (panes.count<2) return
        let survivingShells=0
        for (let i=0;i<panes.count;++i) {
            const pane=panes.get(i)
            if (!pane.outputOnly && pane.paneId!==id) survivingShells++
        }
        if (!output && !survivingShells) return
        for (let i=panes.count-1;i>=0;--i) {
            const pane=panes.get(i)
            if (pane.paneId===id || (!output && pane.shellId===shell)) {
                tree=LayoutTree.replacePane(tree,pane.paneId,null)
                panes.remove(i)
            }
        }
        for (let i=dividers.count-1;i>=0;--i)
            if (!placement.dividers[dividers.get(i).dividerId]) dividers.remove(i)
        if (!output) {
            const terminal=sessions[shell]
            const remaining=Object.assign({},sessions)
            delete remaining[shell]
            sessions=remaining
            terminal?.destroy()
        }
        focusPane(panes.get(0).paneId)
    }
    function restart(shell,posix) {
        sessions[shell]?.start(Qt.resolvedUrl("terminal"),posix)
        focusPane(shell)
    }
    onExposedChanged:if (exposed) {
        start()
        focusPane(activePane)
    }
    Component.onCompleted:if (exposed) start()

    Shortcut {
        sequence:"Alt+Left"
        context:Qt.WindowShortcut
        enabled:workbench.exposed && workbench.activeFocus
        onActivated:workbench.returnRequested()
    }
    Rectangle {
        anchors.fill:parent
        gradient:Gradient {
            GradientStop {position:0;color:Qt.lighter(workbench.base,1.46)}
            GradientStop {position:.58;color:Qt.darker(workbench.base,1.18)}
            GradientStop {position:1;color:Qt.lighter(workbench.base,1.16)}
        }
    }
    Image {anchors.fill:parent;source:workbench.wallpaperImage;asynchronous:true;fillMode:Image.PreserveAspectCrop}
    Repeater {
        id:terminalPanes
        model:panes
        Item {
            id:pane
            required property int paneId
            required property int shellId
            required property bool outputOnly
            required property bool posix
            readonly property var bounds:workbench.placement.panes[paneId]
            readonly property var terminal:workbench.sessions[shellId] || null
            readonly property bool current:workbench.activePane===paneId
            readonly property bool allowSplit:panes.count<12
            readonly property bool canSplitAcross:allowSplit && width>=258
            readonly property bool canSplitDown:allowSplit && height>=178
            property bool found:true
            x:bounds?.x || 0;y:bounds?.y || 0
            width:bounds?.w || 0;height:bounds?.h || 0
            clip:true
            function takeFocus() {if (search.visible) pattern.forceActiveFocus();else screen.forceActiveFocus()}
            function searchFor(backwards) {found=screen.find(pattern.text,backwards)}
            function showFind() {search.visible=true;pattern.forceActiveFocus();pattern.selectAll()}

            ColumnLayout {
                anchors.fill:parent
                spacing:0
                Rectangle {
                    Layout.fillWidth:true
                    Layout.preferredHeight:34
                    color:workbench.chrome
                    Rectangle {
                        anchors.left:parent.left;anchors.right:parent.right;anchors.bottom:parent.bottom
                        height:1;color:pane.current ? workbench.accent : workbench.lineColor
                    }
                    RowLayout {
                        anchors.fill:parent
                        anchors.leftMargin:9;anchors.rightMargin:4
                        spacing:6
                        Label {
                            Layout.fillWidth:true
                            text:pane.outputOnly ? "Output · "+pane.shellId
                                : (pane.paneId===1 ? "Pure Code" : pane.posix ? "POSIX shell" : "Shell "+pane.shellId)
                            elide:Text.ElideRight
                            color:workbench.ink;font.bold:pane.current
                        }
                        ToolButton {
                            visible:pane.width>=300
                            text:"Split right"
                            enabled:pane.canSplitAcross
                            onClicked:workbench.split(pane.paneId,pane.shellId,true,false,false)
                        }
                        ToolButton {
                            visible:pane.width>=400
                            text:"Split below"
                            enabled:pane.canSplitDown
                            onClicked:workbench.split(pane.paneId,pane.shellId,false,false,false)
                        }
                        ToolButton {
                            id:menuButton
                            text:"⋯"
                            Accessible.name:"Terminal pane menu"
                            onClicked:terminalMenu.popup(menuButton,0,menuButton.height)
                        }
                    }
                }
                RowLayout {
                    id:search
                    Layout.fillWidth:true
                    visible:false
                    spacing:4
                    TextField {
                        id:pattern
                        Layout.fillWidth:true
                        placeholderText:"Find in terminal"
                        color:workbench.ink
                        onTextEdited:{screen.find("");pane.searchFor(false)}
                        onAccepted:pane.searchFor(false)
                        Keys.onEscapePressed:{search.visible=false;screen.forceActiveFocus()}
                    }
                    ToolButton {text:"↑";Accessible.name:"Previous match";onClicked:pane.searchFor(true)}
                    ToolButton {text:"↓";Accessible.name:"Next match";onClicked:pane.searchFor(false)}
                    ToolButton {text:"×";Accessible.name:"Close search";onClicked:{search.visible=false;screen.forceActiveFocus()}}
                }
                Label {
                    visible:search.visible && pattern.text.length>0 && !pane.found
                    text:"No matches"
                    color:workbench.ink
                }
                Native.TerminalView {
                    id:screen
                    objectName:"pureCodeTerminalView"
                    Layout.fillWidth:true;Layout.fillHeight:true
                    session:pane.terminal
                    readOnly:pane.outputOnly
                    dark:workbench.darkChrome
                    surfaceOpacity:workbench.darkChrome ? workbench.surfaceOpacity : (String(workbench.wallpaperImage) ? .78 : 1)
                    backgroundColor:workbench.terminalColors.background || "transparent"
                    foregroundColor:workbench.terminalColors.foreground || "transparent"
                    cursorColor:workbench.accent
                    fontSize:Math.max(9,Math.min(workbench.baseFont,Math.floor(width/24),Math.floor(height/4.1)))
                    onActiveFocusChanged:if (activeFocus) workbench.activePane=pane.paneId
                    TapHandler {
                        acceptedButtons:Qt.RightButton
                        onTapped:function(point) {workbench.activePane=pane.paneId;terminalMenu.popup(screen,point.position.x,point.position.y)}
                    }
                }
                Button {
                    visible:!pane.outputOnly && !!pane.terminal && !pane.terminal.running
                    text:pane.terminal?.error ? pane.terminal.error + "  Retry" : "Restart shell"
                    Layout.fillWidth:true
                    onClicked:workbench.restart(pane.shellId,pane.posix)
                }
            }
            Shortcut {
                sequence:"Ctrl+F";context:Qt.WindowShortcut
                enabled:workbench.exposed && pane.current && workbench.activeFocus
                onActivated:pane.showFind()
            }
            Menu {
                id:terminalMenu
                popupType:Popup.Item
                MenuItem {text:"Split shell right";enabled:pane.canSplitAcross;onTriggered:workbench.split(pane.paneId,pane.shellId,true,false,false)}
                MenuItem {text:"Split shell below";enabled:pane.canSplitDown;onTriggered:workbench.split(pane.paneId,pane.shellId,false,false,false)}
                Menu {
                    title:"New POSIX shell"
                    enabled:pane.allowSplit
                    MenuItem {text:"On the right";enabled:pane.canSplitAcross;onTriggered:workbench.split(pane.paneId,pane.shellId,true,false,true)}
                    MenuItem {text:"Below";enabled:pane.canSplitDown;onTriggered:workbench.split(pane.paneId,pane.shellId,false,false,true)}
                }
                Menu {
                    title:"Split out linked output"
                    enabled:pane.allowSplit
                    MenuItem {text:"On the right";enabled:pane.canSplitAcross;onTriggered:workbench.split(pane.paneId,pane.shellId,true,true,false)}
                    MenuItem {text:"Below";enabled:pane.canSplitDown;onTriggered:workbench.split(pane.paneId,pane.shellId,false,true,false)}
                }
                MenuSeparator {}
                MenuItem {text:"Copy";enabled:screen.hasSelection;onTriggered:{screen.copy();screen.forceActiveFocus()}}
                MenuItem {text:"Paste";enabled:!pane.outputOnly;onTriggered:{screen.paste();screen.forceActiveFocus()}}
                MenuItem {text:"Find…";onTriggered:pane.showFind()}
                MenuItem {text:"Command reference";onTriggered:Qt.openUrlExternally(Qt.resolvedUrl("terminal/COMMANDS.md"))}
                MenuItem {text:"Larger text";enabled:workbench.baseFont<26;onTriggered:workbench.localFontChange++}
                MenuItem {text:"Smaller text";enabled:workbench.baseFont>11;onTriggered:workbench.localFontChange--}
                MenuSeparator {}
                MenuItem {text:"Close pane";enabled:pane.outputOnly || Object.keys(workbench.sessions).length>1;onTriggered:workbench.closePane(pane.paneId,pane.shellId,pane.outputOnly)}
                MenuItem {text:"Leave Pure Code";onTriggered:workbench.returnRequested()}
            }
        }
    }
    Repeater {
        model:dividers
        Rectangle {
            id:divider
            required property int dividerId
            readonly property var bounds:workbench.placement.dividers[dividerId]
            x:bounds?.x || 0;y:bounds?.y || 0
            width:bounds?.w || 0;height:bounds?.h || 0
            color:drag.active || hover.hovered ? workbench.accent : workbench.lineColor
            z:1
            HoverHandler {id:hover;cursorShape:divider.bounds?.across ? Qt.SplitHCursor : Qt.SplitVCursor}
            DragHandler {
                id:drag
                target:null
                property real originalRatio:.5
                property real extent:1
                onActiveChanged:if (active && divider.bounds) {
                    originalRatio=divider.bounds.ratio
                    extent=Math.max(1,divider.bounds.usable)
                }
                onActiveTranslationChanged:if (active && divider.bounds) {
                    const delta=divider.bounds.across ? activeTranslation.x : activeTranslation.y
                    const ratio=Math.min(.85,Math.max(.15,originalRatio+delta/extent))
                    workbench.tree=LayoutTree.changeRatio(workbench.tree,divider.dividerId,ratio)
                }
            }
        }
    }
}
