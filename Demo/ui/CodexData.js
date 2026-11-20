.pragma library
.import "../game/Loadout.js" as Gear
.import "../game/Encounters.js" as Mission
.import "../game/Elements.js" as Elements
.import "../game/EnemyLore.js" as Lore
.import "../game/Conditions.js" as Conditions
.import "../game/Pets.js" as Pets
.import "../game/Meta.js" as Meta
.import "../game/Tarot.js" as Tarot

var chapters = [
    { id:"enemies", title:"Demons" }, { id:"weapons", title:"Weapons" },
    { id:"abilities", title:"Abilities" }, { id:"pets", title:"Pets" },
    { id:"kits", title:"Kits" }, { id:"shop", title:"Shop" }, { id:"weather", title:"Weather" },
    { id:"achievements", title:"Medals" }, { id:"controls", title:"Manual" }
]

var manual = [
    { id:"look", title:"Look and aim", category:"Aiming",
        rows:[["A / D · ← / →","Turn to the adjacent front. Move back through the Shrine to cross sides."],
            ["W / S · ↑ / ↓","Look up to Star Sky or down to the Abyss from the Shrine."],
            ["Mouse edges","Cross an edge once to turn. Move away from it before turning again."],
            ["Hold Shift","Aim a gun or lean forward with a staff or melee weapon. A scoped gun hit marks a demon for four seconds. Attacks on that demon bypass the 5% miss roll, wind and blindness."],
            ["F11","Toggle full screen."]],
        description:"Threat markers show where a demon is approaching. A boss receives a separate marker before it enters." },
    { id:"fight", title:"Fire and defend", category:"Combat",
        rows:[["Left mouse","Aim and fire. Hold to repeat with automatic weapons."],
            ["R / right mouse","Reload, draw a thrown weapon, perform a melee trick, or cast a charged staff spell."],
            ["Hold Space","Raise your field shield. Release it to fire. A successful block spends a charge."],
            ["Perfect guard","Raise the shield within 0.2 seconds of impact for a shorter recharge."],
            ["Hold F in the Abyss","Seal the pool for the current wave. Partial work stays when you turn away."]],
        description:"Use Tutorial battle from Home to practise shooting, reload timing, blocks and switching fronts." },
    { id:"loadout", title:"Build and survive", category:"Loadout",
        rows:[["1 / 2 / wheel","Select your weapon."],["Q / E","Cast the corresponding active ability. Each has its own cooldown."],
            ["T / Esc","Pause to inspect loadout, inventory and settings."],
            ["Between waves","Check the next roster and rearrange your items. Hover an entry and use + for its Grimoire page."],
            [". / 1×","Toggle the timer with period. Use the speed button to choose half, normal or double speed."]],
        description:"Passives take effect while equipped. A weapon, a passive and an active from one kit activate its listed bonus." },
    { id:"controller", title:"Controller reference", category:"Controller",
        description:"Reference diagram for the gamepad layout." }
]

function escape(text) {
    return String(text).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")
        .replace(/"/g,"&quot;").replace(/'/g,"&#39;")
}

function link(chapter, id, label) {
    return '<a style="color:#781525; font-weight:600" href="'+chapter+"/"+encodeURIComponent(id)+'">'+escape(label)+"</a>"
}

function kitKey(kit) { return kit.key || kit.weapon }

function groupChapter(group) {
    return group === "weapon" ? "weapons" : group === "pet" ? "pets" : "abilities"
}

function kitEntries() {
    return Gear.kits.map(function(kit) {
        return Object.assign({id:kitKey(kit),category:"Kit"},kit)
    }).sort(function(a,b) { return a.title.localeCompare(b.title) })
}

var destinations = [
    {chapter:"enemies", entries:Mission.enemyTypes},
    {chapter:"weapons", entries:Gear.weapons},
    {chapter:"abilities", entries:Object.assign({},Gear.activeAbilities,Gear.passives)},
    {chapter:"weather", entries:Conditions.entries}
]

function references() {
    const results = []
    for (const group of destinations) {
        for (const entry of Object.values(group.entries)) {
            if (!entry.debugOnly && !["meteor","hallucination"].includes(entry.id))
                results.push({chapter:group.chapter,id:entry.id,title:entry.title})
        }
    }
    for (const kit of Gear.kits)
        results.push({chapter:"kits",id:kitKey(kit),title:kit.title})
    return results.sort(function(a,b) { return b.title.length-a.title.length })
}

var relatedEntries = references()

function linkText(text, chapter, id) {
    const source = String(text || "")
    const matches = []
    for (const target of relatedEntries) {
        if (target.chapter === chapter && target.id === id)
            continue
        const title = target.title.replace(/[.*+?^$(){}|\[\]\\]/g,"\\$&")
        // Single generic words such as Guard can be ordinary prose. Only
        // match their exact case. Longer catalogue names match in either case.
        const flags = target.title.includes(" ") ? "gi" : "g"
        const pattern = new RegExp("(^|[^A-Za-z0-9])("+title+")(?=$|[^A-Za-z0-9])",flags)
        let match
        while ((match = pattern.exec(source)) !== null) {
            const start = match.index + match[1].length
            const end = start + match[2].length
            if (!matches.some(function(span) { return start < span.end && end > span.start }))
                matches.push({start:start,end:end,html:link(target.chapter,target.id,match[2])})
        }
    }
    let html = ""
    let cursor = 0
    for (const span of matches.sort(function(a,b) { return a.start-b.start })) {
        html += escape(source.slice(cursor,span.start)) + span.html
        cursor = span.end
    }
    return (html+escape(source.slice(cursor))).replace(/\n/g,"<br>")
}

function kitLinks(entry, group) {
    const kit=Gear.kitFor(group,entry.id)
    return kit ? link("kits",kitKey(kit),kit.title) : ""
}

function entryText(entry, chapter, live, terms) {
    if (!entry) return ""
    if (chapter === "enemies") {
        const notes = Lore.tactics[entry.id] || ""
        const skills = entry.element && Elements.kinds[entry.element]
            ? "<br>On hit · "+escape(Elements.kinds[entry.element].title)+" "+(entry.elementLevel || 1) : ""
        const health = '<br><br><b>Base combat stats</b><br>Health '+entry.health+' HP · Damage '+entry.damage
        const attack = "<br>Speed "+entry.speed+" u/s · Reach "+entry.reach+" u"
            +"<br>Attack interval "+entry.interval+" s · Tell "+entry.windup+" s"
        const bonuses = (entry.crit ? " · "+Math.round(entry.crit*100)+"% critical" : "")
            +(entry.barrier ? "<br>Barrier "+entry.barrier+" HP" : "")
        return linkText(entry.description,chapter,entry.id)
            +(notes ? "<br><br><b>Field notes</b><br>"+linkText(notes,chapter,entry.id) : "")
            +health+attack+bonuses+skills
    }
    if (chapter === "kits")
        return "<b>Complete set</b><br>"+linkText(entry.bonus,chapter,entry.id)
            +"<br><br><b>Weapon</b> · "+link("weapons",entry.weapon,Gear.weapons[entry.weapon].title)
            +"<br><b>Active</b> · "+link("abilities",entry.active,Gear.activeAbilities[entry.active].title)
            +"<br><b>Passive</b> · "+link("abilities",entry.passive,Gear.passives[entry.passive].title)
    if (chapter === "weapons" || chapter === "abilities") {
        const group = chapter === "weapons" ? "weapon" : entry.category === "Active" ? "active"
            : entry.category === "Passive" ? "passive" : ""
        const item=(live && group ? Gear.ownedItem(live,group,entry.id) : null) || {id:entry.id,level:0}
        let details = group ? Gear.itemDetails(live,group,item) : entry.description
        if (!live && group==="weapon") details=details.replace(/^Damage /m,"Base damage ")
        if (!live && group==="active") details=details.replace(/^Ability damage:/m,"Base ability damage ·")
        const kits = group ? kitLinks(entry,group) : ""
        const opening={covenant:terms,skyPhase:"daytime",weatherEffect:"clear",playerFront:"front",health:Gear.startingHealth}
        const boosts=Meta.benefits(opening)
        const next=live ? "" : group==="weapon" ? (Gear.weaponStats(item).damage*boosts.weapon
            *Gear.affinity(opening,entry)*Tarot.weaponFactor(opening,Gear.startingHealth)).toFixed(2)+" per hit at the Shrine in clear daylight"
            : group==="active" ? Gear.abilityDamageDescription(null,item,boosts.active) : ""
        return linkText(details,chapter,entry.id)+(next ? "<br><br><b>Next run damage</b><br>"+escape(next) : "")
            +(kits ? "<br><br><b>Kit pages</b><br>"+kits : "")
    }
    if (chapter === "controls")
        return (entry.rows || []).map(function(row) { return "<b>"+escape(row[0])+"</b><br>"+escape(row[1]) })
            .join("<br><br>")+"<br><br>"+escape(entry.description)
    if (chapter === "shop") {
        const introduction=entry.id==="counter" ? "<br><br>"+["expand-counter","shop-quality","slot-work","mystery-cache"].map(function(id) {
            const other=Gear.shopEntries().find(function(item) {return item.id===id})
            return link("shop",id,other.title)
        }).join("<br>") : link("shop","counter","Return to the counter index")
        return escape(entry.description)+(entry.price ? "<br><br><b>Base price</b><br>"+escape(entry.price) : "")
            +(entry.levels ? "<br><br><b>Ranks</b><br>"+entry.levels.map(escape).join("<br><br>") : "")
            +"<br><br>"+introduction
    }
    if (chapter === "achievements") {
        const item = entry.group === "pet" ? Pets.spec(entry.reward) : Gear.catalogs[entry.group][entry.reward]
        return linkText(entry.requirement,chapter,entry.id)+"<br><br><b>Reward</b><br>"
            +link(groupChapter(entry.group),entry.reward,item.title)
    }
    if (chapter==="pets") {
        const charge=Pets.secondary[entry.id]
        return escape(entry.description)+"<br><br><b>On duty</b> · "+entry.duty+" seconds<br><b>Rest</b> · "+entry.rest+" seconds"
            +(charge ? "<br><br><b>"+escape(charge.title)+"</b><br>Charges for "+charge.charge
                +" seconds after every "+charge.every+" ordinary strikes. "+escape(charge.description) : "")
    }
    return linkText(entry.description,chapter,entry.id)
}
