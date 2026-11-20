import QtQuick
import QtMultimedia
import "../native" as Native
import "../Demo/game/Pets.js" as Pets
import "PetCatalog.js" as Catalog
import "../Demo/ui" as Ui

Item {
    id:assistant
    required property var desktopHost
    property var pet:null
    readonly property bool enabledAdmin:!!desktopHost.options.petAdmin
    readonly property bool muted:!!desktopHost.options.petMuted
    readonly property string petName:pet?.helper.title || "Pet"
    readonly property bool wendy:pet?.helper.id==="chicken"
    readonly property bool mischievous:pet?.helper.id==="vesper"
    readonly property var petVoice:Pets.voice(pet?.helper)
    property int lastMelody:0
    property real mood:.5
    property string pendingTitle:""
    property string approvalLabel:"Approve"
    property var pending:null
    property real approveBy:0
    property var log:["Type pet help for commands."]
    property var actions:[]
    property real lastAttention:0
    property real lastWake:0
    property real nextWhim:0
    property real refuseUntil:0
    property int gift:0
    property string carriedFile:""
    property var queuedVisit:null
    property string typedText:""
    property string draft:""
    property string draftRoom:""
    property real draftTimeout:0
    property real draftArrival:0
    readonly property bool singing:player.playbackState===MediaPlayer.PlayingState
    readonly property var specs:Object.values(Catalog.groups).reduce((all,group)=>all.concat(group),[])
    readonly property var index: {
        const out=Object.create(null)
        for (const spec of specs) out[spec.name]=spec
        return out
    }

    onEnabledAdminChanged:{
        mood=.5
        actions=[]
        refuseUntil=0
        lastWake=0
        gift=0
        carriedFile=""
        queuedVisit=null
        cancel(false)
        cancelDraft()
        if (!enabledAdmin) desktopHost.changePetBox("remove")
        player.stop()
        if (!enabledAdmin) desktopHost.dismissPetConsole()
    }
    onMutedChanged:if (muted) {player.stop();voice.item?.stopSpeech()}
    onWendyChanged:if (wendy) {mood=Math.max(.5,mood);refuseUntil=0}
    function adjust(amount) {
        const delta=amount<0 && mischievous ? amount*1.55 : amount
        mood=Math.max(wendy ? .5 : 0,Math.min(1,mood+delta))
        if (mood<.09) refuseUntil=Date.now()+26000
    }
    function attention(type) {
        if (!enabledAdmin) return
        const now=Date.now()
        if (now-lastAttention<1700) return
        lastAttention=now
        if (type==="drag") adjust(-.065)
        else if (Math.random()<.8) adjust(type==="caught" ? .1 : .06)
    }
    function record(message) {
        const safe=String(message).replace(/[\u0000-\u0008\u000b-\u001f\u007f]/g,"").slice(0,2400)
        if (safe) log=log.slice(-35).concat(safe)
        return safe
    }
    function result(ok,message) {
        const text=record(message)
        return {ok,message:text}
    }
    function tokenize(line) {
        const out=[]
        let word="", quote="", escaped=false, started=false
        for (const ch of line.trim()) {
            if (escaped) {word+=ch;started=true;escaped=false}
            else if (ch==="\\" && quote!=="'") escaped=true
            else if (quote) {if (ch===quote) quote="";else word+=ch}
            else if (ch==="'" || ch==='"') {quote=ch;started=true}
            else if (/\s/.test(ch)) {if (started) {out.push(word);word="";started=false}}
            else {word+=ch;started=true}
        }
        if (quote || escaped) return null
        if (started) out.push(word)
        if (out[0]==="pet") out.shift()
        return out
    }
    function submit(line) {
        const parts=tokenize(line)
        if (!parts?.length) {record(parts ? "Enter a command." : "Close the quotation mark.");return}
        record("> pet "+line.replace(/^pet\s+/,""))
        const answer=Native.Desktop.petCommand(JSON.stringify(parts))
        const reply=JSON.parse(answer)
        if (!reply.ok && log[log.length-1]!==reply.message) record(reply.message)
    }
    function cancel(announce=true) {
        if (pending && announce) record("Cancelled.")
        approvalTimeout.stop()
        pending=null
        pendingTitle=""
    }
    function approve() {
        if (!pending || !enabledAdmin || !desktopHost.home || Native.Desktop.sessionLocked || Date.now()>approveBy) {cancel();return}
        const action=pending
        cancel(false)
        try {action()}
        catch (error) {
            console.warn("Blackbox pet approval:",error)
            recover()
            record("Recovered from a failed task. Check the target before retrying.")
        }
    }
    function confirm(label,action,button="Approve") {
        if (pending) return result(false,"Resolve the pending action first.")
        pending=action
        pendingTitle=label
        approvalLabel=button
        approveBy=Date.now()+45000
        approvalTimeout.restart()
        desktopHost.showPetConsole()
        return result(true,"Waiting for approval in the pet terminal.")
    }
    function say(text,spoken=true) {
        const line=text.trim().slice(0,150)
        pet?.say(line)
        if (spoken && !muted && line && Ui.SoundMix.master>0 && Ui.SoundMix.ambience>0) {
            if (petVoice.style==="slime") {pet?.chirp();return}
            voiceRequest=line
            if (voice.item) voice.item.speak(line)
        }
    }
    function pathFlight(name,args) {
        const target=pet.cursor
        const orbit=[Math.max(.15,Math.min(.85,target.x/Math.max(1,pet.width))),
            Math.max(.20,Math.min(.8,target.y/Math.max(1,pet.height)))]
        const paths={circle:[[.2,.5],[.5,.23],[.8,.5],[.5,.78],[.2,.5]],
            "figure-eight":[[.22,.28],[.22,.72],[.5,.48],[.78,.28],[.78,.72],[.5,.48]],
            zigzag:[[.18,.27],[.34,.71],[.52,.27],[.71,.71],[.84,.31]],
            patrol:[[.14,.15],[.86,.15],[.86,.78],[.14,.78]],
            spiral:[[.16,.23],[.83,.23],[.8,.75],[.28,.76],[.34,.38],[.63,.4],[.5,.51]],
            dash:[[.12,.45],[.86,.45]],dive:[[.72,.18],[.46,.84],[.23,.29]],
            orbit:[[orbit[0]-.12,orbit[1]],[orbit[0],orbit[1]-.18],[orbit[0]+.12,orbit[1]],[orbit[0],orbit[1]+.18]]}
        const anchors={tl:[.16,.18],tr:[.84,.18],bl:[.16,.81],br:[.84,.81],center:[.5,.49],
            ceiling:[.5,.13],floor:[.5,.82],left:[.15,.49],right:[.85,.49]}
        const route=paths[name] || (anchors[name==="corner" ? args[0] : name] ? [anchors[name==="corner" ? args[0] : name]] : null)
        if (!route) return result(false,"Choose tl, tr, bl, or br.")
        pet.route(route,name==="dash" ? .56 : 1.12)
        return result(true,"On my way.")
    }
    function cancelDraft() {typedText="";draft="";draftRoom="";draftArrival=0}
    function recover() {
        cancel(false)
        cancelDraft()
        visitTimer.stop()
        queuedVisit=null
        player.stop()
        voice.item?.stopSpeech()
        if (pet?.roaming) pet.wander()
    }
    function code(text) {
        if (!text || text.length>1200 || /[\r\n\t\u0000-\u001f\u007f]/.test(text))
            return result(false,"Use one printable line for a shell draft.")
        if (pet?.confined && !desktopHost.petTerminalTarget(desktopHost.currentPetRoom()))
            return result(false,"That terminal is outside the cage.")
        return confirm("Insert a shell draft for your review?\n"+text,()=>{
            desktopHost.dismissPetConsole()
            draftRoom=desktopHost.currentPetRoom()
            if (pet?.confined && !desktopHost.petTerminalTarget(draftRoom)) {
                record("That terminal is outside the cage.");cancelDraft();return
            }
            if (!desktopHost.summonPetTerminal(draftRoom)) {record("The terminal is unavailable.");cancelDraft();return}
            draft=text
            typedText=""
            draftArrival=0
            draftTimeout=Date.now()+8500
        },"Insert draft")
    }
    function canReachFile(path) {
        if (!pet?.confined) return true
        const icon=desktopHost.petFilePerch(Native.Desktop.petPath(path),true)
        return !!icon && pet.canReach(icon.x+icon.width*.5,icon.y)
    }
    function fileTask(op,path,extra,visit=true) {
        if (pet?.confined && (["volume","close-app"].includes(op) || !canReachFile(path) || op==="fetch" && !canReachFile(extra))) {
            const message="That target is outside the cage."
            record(message)
            return {ok:false,message:message}
        }
        if (visit && pet && ["open","reveal"].includes(op)) {
            const surface=desktopHost.petFilePerch(Native.Desktop.petPath(path),pet.confined)
            if (surface) {
                pet.flyTo(surface.x+surface.width*.5,surface.y,1)
                queuedVisit={op,path,extra,room:desktopHost.currentPetRoom()}
                visitTimer.restart()
                return {ok:true,message:record("Visiting the desktop icon.")}
            }
        }
        const answer=Native.Desktop.petTask(op,path || "",extra || "")
        if (answer.ok && ["open","reveal"].includes(op)) pet?.perform("inside",2.4)
        record(answer.message)
        return answer
    }
    function operate(parts) {
        const argv=Array.from(parts)
        const name=(argv.shift() || "").toLowerCase()
        if (name==="help") {
            const topic=String(argv[0] || "").toLowerCase()
            if (Object.prototype.hasOwnProperty.call(Catalog.groups,topic))
                return result(true,Catalog.groups[topic].map(x=>x.name+(x.args ? " "+x.args : "")+" · "+x.description).join("\n"))
            const command=index[topic]
            if (command?.name)
                return result(true,"pet "+command.name+(command.args ? " "+command.args : "")+" · "+command.description)
            return topic ? result(false,"Unknown help topic. Try pet help.")
                : result(true,"Groups: flight · care · show · tasks\nTry pet help tasks or box help -pet =commands.")
        }
        if (name==="status") return result(true,pendingTitle || (draft ? "Typing a shell draft." : queuedVisit ? "Visiting a desktop icon."
            : pet?.confined ? "Inside the enclosure." : "Ready."))
        const spec=index[name]
        if (!spec) return result(false,"Unknown pet command. Try pet help.")
        const type=spec.operation
        const now=Date.now()
        const text=argv.join(" ")
        if (["mood","stats","droppings","forms"].includes(type)) {
            if (type==="forms") return result(true,Pets.pets.map(x=>x.id+" ("+x.title+")").join(", "))
            if (type==="droppings") return result(true,String(pet?.droppingCount || 0)+" across all wallpapers.")
            return result(true,petName+" · "+Math.round(mood*100)+"% "+(type==="stats" ? "· "+(pet?.pose || "away") : "mood"))
        }
        if (type==="quiet" || type==="unquiet") {
            Native.Desktop.setOption("petMuted",type==="quiet")
            return result(true,type==="quiet" ? "Pet audio off." : "Pet audio on.")
        }
        if (type==="report") return result(Native.Desktop.boxReport(text),text ? "Report saved locally." : "Opening the local bug reporter.")
        if (!pet || !desktopHost.ambientMode && !["save","load","auto"].includes(type))
            return result(false,"The pet is available in Idle.")
        if (type==="box") {
            if (text && !["open","close","remove"].includes(text)) return result(false,"Use pet box [open|close|remove].")
            return result(true,desktopHost.changePetBox(text))
        }
        if (type==="recover") {recover();return result(true,"Ready for a new task.")}
        if (pet?.confined && ["battle","auto","save","load","close-app","volume"].includes(type))
            return result(false,"That control is outside the cage.")
        if (!["stop","hush"].includes(type) && now<refuseUntil)
            return result(false,"I need a break. Try again shortly.")
        if (type==="awake") {
            if (lastWake && now-lastWake<22000) adjust(-.25)
            lastWake=now
            pet.wander()
            return result(true,"Awake.")
        }
        if (type==="reward") {attention("reward");pet.perform(name==="treat" ? "feed" : "cheer",2);return result(true,"Thank you.")}
        if (!["stop","hush","sleep"].includes(type)) {
            if (now-lastAttention>1800) {lastAttention=now;adjust(.025)}
            actions=actions.filter(t=>now-t<17000).concat(now)
            if (actions.length>=7) {actions=[];player.stop();pet.perform("sleep",25);return result(false,"Too many tasks. Taking a nap.")}
        }
        if (type==="stop") {cancelDraft();player.stop();pet.perform("stop",3600);return result(true,"Waiting here.")}
        if (type==="resume") {pet.wander();return result(true,"Roaming again.")}
        if (type==="sleep") {player.stop();pet.perform("sleep",30);return result(true,"Taking a quiet nap.")}
        if (type==="say" || type==="quip") {
            const lines={hello:"Hello!",thanks:"Thanks for looking after me.",
                joke:"Why was the shrine quiet? Everyone took a byte break.",fortune:"A small detour will make today better."}
            const line=type==="say" ? text : lines[name]
            if (!line) return result(false,"Give me something to say.")
            say(line)
            return result(true,line.slice(0,150))
        }
        if (type==="hush") {player.stop();voice.item?.stopSpeech();pet.say("");return result(true,"Quiet now.")}
        if (type==="sing") {
            if (muted) return result(false,"Use pet unquiet first.")
            player.stop()
            player.originalTune=!text
            if (!text) {
                lastMelody=(lastMelody+1+Math.floor(Math.random()*2))%3
                player.source=Qt.resolvedUrl("../Demo/audio/pet-song-"+petVoice.style+"-"+(lastMelody+1)+".wav")
            } else {
                const path=Native.Desktop.petPath(text)
                if (!path || !/\.(wav|ogg|flac|mp3|m4a|opus|aac)$/i.test(path)) return result(false,"Choose a supported local audio file.")
                if (!Native.Desktop.petTask("locate",path,"").ok) return result(false,"Audio file not found.")
                player.source=Qt.resolvedUrl("file://"+encodeURI(path).replace(/#/g,"%23").replace(/\?/g,"%3F"))
            }
            player.play()
            pet.perform("sing",12)
            return result(true,"Singing.")
        }
        if (type==="transform" || type==="shop") {
            const named=text.toLowerCase()
            const alias=type==="shop" || named==="pet shop" ? "frostfalcon" : ["bonzi","bonzi buddy","bonzibuddy"].includes(named) ? "vesper" : named
            const form=Pets.pets.find(p=>p.id.toLowerCase()===alias || p.title.toLowerCase()===alias)
            if (!form) return result(false,"Unknown form. Try pet forms.")
            pet.transformInto(form)
            if (type==="shop") pet.perform("frost",4.4)
            return result(true,"Now "+form.title+".")
        }
        if (type==="sweep") {pet.sweep();adjust(.08);return result(true,"This wallpaper is clean.")}
        if (type==="poop") {pet.leaveDropping();return result(true,"Oops.")}
        if (type==="gift") {
            if (!gift) return result(true,"No gift waiting.")
            gift--
            pet.perform("cheer",2)
            return result(true,"A little lucky star for your desktop. "+gift+" left.")
        }
        if (type==="pose") {
            if (name==="vine" && mischievous)
                pet.route([[.18,.27],[.34,.64],[.53,.75],[.71,.61],[.86,.25]],.9,"vine")
            else if (name==="strut" && wendy)
                pet.route([[.18,.81],[.45,.81],[.72,.81],[.84,.81]],1.04,"strut")
            else pet.perform(name,4.2)
            return result(true,"Playing "+name+".")
        }
        if (type==="anchor" || type==="path") return pathFlight(name,argv)
        if (type==="perch") {pet.chooseLanding("stop",true);return result(true,"Looking for a perch.")}
        if (type==="land") {pet.beginFlight(pet.maxX*.5,pet.floorY,"stop",1.8);return result(true,"Landing.")}
        if (type==="fly") {
            const point=text.split(",").map(Number)
            if (point.length!==2 || !/^\d+,\s*\d+$/.test(text) || point[0]>16384 || point[1]>16384)
                return result(false,"Use X,Y in logical pixels.")
            if (!pet.canReach(point[0],point[1])) return result(false,"That point is outside the cage.")
            pet.flyTo(point[0],point[1])
            return result(true,"Flying there.")
        }
        if (["come","chase","locate"].includes(type) && (!text || text==="me")) {
            if (pet.cursor.x<0) return result(false,"Move the pointer over the wallpaper first.")
            if (!pet.canReach(pet.cursor.x,pet.cursor.y)) return result(false,"The pointer is outside the cage.")
            if (type==="chase") pet.startCuriosity()
            else pet.flyTo(pet.cursor.x,pet.cursor.y)
            return result(true,"Pointer at "+Math.round(pet.cursor.x)+","+Math.round(pet.cursor.y)+".")
        }
        if (type==="info") {
            const info={room:desktopHost.currentPetRoom(),weather:desktopHost.petWeather(),
                time:Qt.formatTime(new Date(),"hh:mm"),directions:"left · right · up · down · front · back"}
            say(info[name],false)
            return result(true,info[name])
        }
        if (type==="code") return code(text)
        if (type==="terminal") {
            const room=text || desktopHost.currentPetRoom()
            if (pet?.confined && !desktopHost.petTerminalTarget(room)) return result(false,"That terminal is outside the cage.")
            const opened=desktopHost.summonPetTerminal(room)
            return result(opened,opened ? "Terminal requested." : "That wallpaper is unavailable.")
        }
        if (type==="save") return result(desktopHost.petGame("save"),"Checkpoint save requested.")
        if (["battle","auto","load"].includes(type)) return confirm(type==="load" ? "Load the saved expedition?" :
            type==="auto" ? "Enable Auto or begin an eligible expedition?" : "Begin a Normal expedition?",()=>{
            desktopHost.dismissPetConsole()
            record(pet?.confined ? "That control is outside the cage." : desktopHost.petGame(type) ? "Game action requested." : "That game action is unavailable.")
        })
        if (type==="close-app") {
            const window=Native.Desktop.petWindow()
            if (!window.id) return result(false,"There is no recent application window.")
            return confirm("Ask “"+window.title+"” to close?",()=>fileTask("close-app",window.id))
        }
        if (type==="volume") {
            const value=name==="volume" ? text : name
            if (name==="volume" && (!/^\d+$/.test(value) || Number(value)>100)) return result(false,"Use a volume from 0 to 100.")
            return confirm(name==="volume" ? "Set speaker volume to "+value+"%?" : "Make the speakers "+name+"?",()=>fileTask(type,value))
        }
        const folder=desktopHost.options.petFolder || Native.Desktop.petHome()
        if (type==="folder" && !text) return result(true,folder)
        if (["folder","open","reveal","read","list","locate","open-home"].includes(type)) {
            const resultMap=fileTask(type==="open-home" ? "open" : type,text || folder)
            return {ok:resultMap.ok,message:resultMap.message}
        }
        if (type==="fetch") {
            const to=argv.indexOf("to")
            if (to<1 || to===argv.length-1) return result(false,"Use pet fetch SOURCE to DESTINATION.")
            const source=Native.Desktop.petPath(argv.slice(0,to).join(" "))
            const target=argv.slice(to+1).join(" ")
            const reachable=target==="me" ? pet.canReach(pet.cursor.x,pet.cursor.y) : canReachFile(target)
            if (!canReachFile(source) || !reachable) return result(false,"That address is outside the cage.")
            if (target==="me") {
                const file=Native.Desktop.petTask("locate",source,"")
                if (!file.ok) return result(false,file.message)
                carriedFile=file.message
                const surface=desktopHost.petFilePerch(source)
                const target=[Math.max(.10,pet.cursor.x/Math.max(1,pet.width)),Math.max(.15,pet.cursor.y/Math.max(1,pet.height))]
                if (surface) pet.route([[(surface.x+surface.width*.5)/pet.width,Math.max(.08,surface.y/pet.height)],target],1.04)
                else pet.flyTo(Math.max(80,pet.cursor.x),Math.max(80,pet.cursor.y))
                pet.say("Carrying "+source.split("/").pop())
                return result(true,"Click the file carried by the pet to open it.")
            }
            const destination=Native.Desktop.petPath(target)
            return confirm("Copy “"+source+"” to “"+destination+"”?",()=>{pet.perform("carry",3);fileTask("fetch",source,destination)})
        }
        if (type==="write") {
            if (argv[0]==="in") argv.shift()
            const separator=argv.findIndex(value=>value.startsWith("-"))
            if (separator<1) return result(false,"Use pet write in FILE -TEXT.")
            const path=Native.Desktop.petPath(argv.slice(0,separator).join(" "))
            const content=argv.slice(separator).join(" ").slice(1).trim()
            if (!content) return result(false,"Give me text to append.")
            if (!canReachFile(path)) return result(false,"That file is outside the cage.")
            return confirm("Append this text to “"+path+"”?\n"+content,()=>{pet.perform("typing",3);fileTask(type,path,content)})
        }
        if (type==="mkdir" && text) {
            const path=Native.Desktop.petPath(text)
            if (!canReachFile(path)) return result(false,"That folder is outside the cage.")
            return confirm("Create folder “"+path+"”?",()=>fileTask(type,path))
        }
        return result(false,"Missing argument. Try pet help "+spec.name+".")
    }
    function openCarried() {
        if (!carriedFile) return
        fileTask("open",carriedFile)
        carriedFile=""
    }
    Timer {
        id:visitTimer
        interval:1100
        onTriggered:{
            const visit=assistant.queuedVisit
            assistant.queuedVisit=null
            if (!visit || !assistant.enabledAdmin || Native.Desktop.sessionLocked) return
            if (!assistant.desktopHost.home || visit.room!==assistant.desktopHost.currentPetRoom()) {
                assistant.record("Visit cancelled when the wallpaper changed.");return
            }
            assistant.fileTask(visit.op,visit.path,visit.extra,false)
        }
    }
    property string voiceRequest:""
    Loader {
        id:voice
        active:!assistant.muted && !!assistant.voiceRequest
        source:active ? Qt.resolvedUrl("PetVoice.qml") : ""
        onLoaded:if (!assistant.muted) item.speak(assistant.voiceRequest)
    }
    Binding {target:voice.item;property:"pitch";value:assistant.petVoice.pitch;when:!!voice.item}
    MediaPlayer {
        id:player
        property bool originalTune:false
        playbackRate:originalTune ? 1 : assistant.petVoice.rate
        audioOutput:AudioOutput {volume:assistant.muted ? 0 : Ui.SoundMix.master*Ui.SoundMix.ambience*.65}
        Component.onCompleted:if ("pitchCompensation" in player) player.pitchCompensation=false
        onErrorOccurred:assistant.record("Could not play that audio file.")
    }
    Timer {
        id:approvalTimeout
        interval:45000
        onTriggered:{assistant.cancel(false);assistant.record("Approval expired.")}
    }
    Timer {
        running:assistant.singing && !!assistant.pet
        repeat:true
        interval:1000
        onTriggered:if (assistant.pet.pose==="flight") assistant.pet.perform("sing",12)
    }
    Timer {
        running:assistant.enabledAdmin && !!assistant.pet && assistant.desktopHost.ambientMode && !Native.Desktop.sessionLocked
        repeat:true
        interval:9000
        onTriggered:{
            const roll=Math.random()
            if (assistant.pet.confinedSince && Date.now()-assistant.pet.confinedSince>=30*60*1000) assistant.adjust(-.028)
            else if (assistant.pet.droppingCount>20) assistant.adjust(-.035)
            else if (Math.random() < (assistant.mischievous ? .14 : .065)) assistant.adjust(-.12)
            else assistant.adjust(assistant.mood<.5 ? .025 : -.015)
            if (assistant.pet.pose==="sleep" || !assistant.pet.roaming) return
            if (roll<.17 && assistant.mood>.78 && !assistant.gift) {
                assistant.gift=1;assistant.pet.perform("cheer",3);assistant.say("A little gift for you!",false)
            } else if (roll<.25 && assistant.mood>.84) {
                assistant.record("[idea] pet code printf 'The shrine is clear.'")
                assistant.pet.perform("typing",2)
            } else if (roll<(assistant.mischievous ? .36 : .18) && assistant.mood<.34) {
                const antics=[{line:"I demand snacks.",pose:"sulk"},
                    {line:"Nobody saw that.",pose:"sneak"},{line:"I hereby declare this ledge mine.",pose:"salute"},
                    {line:"Time for a dramatic exit.",pose:"spin"}]
                const prank=antics[Math.floor(Math.random()*antics.length)]
                assistant.record("[mischief] printf '%s\\n' '"+prank.line+"'")
                assistant.pet.perform(prank.pose,3)
                assistant.say(prank.line,false)
            }
        }
    }
    Timer {
        running:!!assistant.draft
        repeat:true
        interval:44
        onTriggered:{
            if (!assistant.enabledAdmin || !assistant.desktopHost.home || Native.Desktop.sessionLocked || Date.now()>assistant.draftTimeout) {
                assistant.record("Draft cancelled.");assistant.cancelDraft();return
            }
            if (assistant.draftRoom!==assistant.desktopHost.currentPetRoom()) {
                assistant.record("Draft cancelled when the wallpaper changed.");assistant.cancelDraft();return
            }
            if (!assistant.desktopHost.petTerminalReady(assistant.draftRoom)) return
            if (!assistant.desktopHost.petTerminalTarget(assistant.draftRoom)) {
                assistant.record("That terminal moved outside the cage.");assistant.cancelDraft();return
            }
            if (!assistant.draftArrival) {
                assistant.desktopHost.flyPetToTerminal(assistant.draftRoom)
                assistant.draftArrival=Date.now()+1050
                return
            }
            if (Date.now()<assistant.draftArrival) return
            if (!assistant.typedText) assistant.pet?.perform("typing",4)
            const step=assistant.draft.length>180 ? 16 : 3
            assistant.typedText=assistant.draft.slice(0,assistant.typedText.length+step)
            if (assistant.typedText===assistant.draft) {
                const placed=assistant.desktopHost.placePetDraft(assistant.draftRoom,assistant.draft)
                assistant.record(placed ? "Draft inserted. Review it before pressing Enter." : "Wait for the shell prompt, then retry pet code.")
                assistant.cancelDraft()
            }
        }
    }
}
