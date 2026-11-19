.pragma library

var modes = {
    standard:{ title:"Field shield", tint:"#65c8ff", hits:1,limit:0,cooldown:4.5 },
    fleetShell:{ title:"Fleet shell", tint:"#6df6cb", hits:1,limit:1.40,cooldown:3.2 },
    perfectGuard:{ title:"Perfect guard", tint:"#d9deff", hits:1,limit:.73,cooldown:5.5 },
    jesterWard:{ title:"Jester ward", tint:"#ce86ff", hits:1,limit:0,cooldown:7.4 },
    bulwark:{ title:"Bulwark", tint:"#ffc77c", hits:2,limit:0,cooldown:12.1 }
}

var kits = [
    { key:"wardline", title:"Wardline kit", weapon:"paleward",active:"guardPulse",passive:"guardSeam",
        stat:"shieldCooldown",value:.68,bonus:"Your field shield recharges another 0.68 seconds sooner." },
    { key:"shieldCourier", title:"Courier kit", weapon:"shortRam",active:"reserveGuard",passive:"fleetShell",
        stat:"shieldCooldown",value:.51,bonus:"The field shield recharges another 0.51 seconds sooner." },
    { key:"returnFire", title:"Return fire kit", weapon:"verdictRifle",active:"guardKick",passive:"mirrorGuard",
        stat:"reflect",value:.12,bonus:"Your shield gains another 12 percentage points of reflection chance." },
    { key:"sparksInAmber", title:"Sparks in amber", weapon:"cinderDouble",active:"glassVault",passive:"bulwark",
        stat:"shieldHits",value:1,bonus:"Bulwark can absorb one more hit while raised." },
    { key:"blackMint", title:"Black mint kit", weapon:"weathered",active:"flashCoins",passive:"guardToll",
        stat:"guardGold",value:1,bonus:"The first three blocks per shield raise earn one extra gold." },
    { key:"paleJudgement", title:"Pale judgement kit", weapon:"gallows",active:"critMark",passive:"criticalLens",
        stat:"crit",value:.06,scope:"gallows",bonus:"The Gallows rifle gains another 6 percentage points of critical chance." },
    { key:"kindling", title:"Kindling kit", weapon:"emberslash",active:"sharpen",passive:"edgeRhythm",
        stat:"lunge",value:.14,bonus:"Charged melee strikes deal another 14% damage." },
    { key:"silentVerdict", title:"Silent verdict kit", weapon:"feint",active:"sureStrike",passive:"deepCut",
        stat:"critPower",value:.22,scope:"feint",bonus:"Feint pistol critical hits add another ×0.22 to their multiplier." },
    { key:"risingCoil", title:"Rising coil kit", weapon:"splitPin",active:"coilTrigger",passive:"critLoader",
        stat:"active",value:.12,scope:"coilTrigger",bonus:"Coil trigger recharges another 12% sooner." }
]

var passiveRows = [
    ["mirrorGuard","Mirror guard","rare","A shield block has a 22% chance to reflect some damage to the attacker.","critChance",.018,"Critical chance +1.8%"],
    ["guardToll","Guard toll","rare","The first three blocks per raise each earn two gold.","heal",2,"Heal 2 at wave start"],
    ["coolGuard","Quick return","rare","Each block removes half a second from the shield's next recovery.","shieldCool",.35,"Shield recovery −0.35s"],
    ["guardSeam","Long seam","rare","Reduce shield recovery by 0.45 seconds per rank. Lv 3 adds one more block per raise.","shieldCool",.35,"Shield recovery −0.35s"],
    ["cinderGuard","Cinder guard","epic","Blocking a close attacker sets it on fire.","burnDuration",.60,"Burn lasts another 0.6s"],
    ["guardInsulation","Guard lining","rare","Take less damage from ground explosions and beams while the shield is raised.","armor",.03,"Damage taken −3%"],
    ["fleetShell","Fleet shell","epic","A quick teal shield. A block speeds your turns. It recharges after a short raise, including when released early.","shieldCool",.23,"Shield recovery −0.23s"],
    ["perfectGuard","Perfect guard","legendary","A brief silver guard with a cooldown on release. A block in the first 0.2 seconds reflects damage and shortens the recharge.","shieldLimit",.13,"Parry shield stays raised 0.13s longer"],
    ["jesterWard","Jester ward","legendary","A shifting violet guard. Each first block rolls a surprise benefit and a variable recovery time.","shieldCool",.30,"Shield recovery −0.30s"],
    ["bulwark","Bulwark","legendary","An amber shield that absorbs two hits. Its weight slows turns while raised, and its recovery is longer.","shieldCool",.46,"Shield recovery −0.46s"],
    ["criticalLens","Critical lens","rare","Increase weapon critical chance by 7 percentage points per rank.","critChance",.032,"Critical chance +3.2%"],
    ["deepCut","Deep cut","epic","Multiply critical hits by another 0.30 per rank.","critPower",.18,"Critical multiplier +0.18"],
    ["critLoader","Impact feeder","rare","Return one round on a critical hit, up to one refund per rank in each magazine.","reload",.055,"Reload time −5.5%"],
    ["edgeRhythm","Edge rhythm","epic","Charged melee strikes and Katana finishers gain critical chance.","critChance",.027,"Critical chance +2.7%"],
    ["critFuel","Critical fuel","epic","Critical kills briefly speed up shots and melee swings.","cycle",.051,"Attack recovery −5.1%"],
    ["hardplate","Soft landing","epic","Reduce the bonus damage of a critical hit against you.","critResist",.14,"Reduce the critical multiplier by another 0.14"]
]

var passives = {}
var perks = {}
for (const item of passiveRows) {
    const [id,title,rarity,description,stat,value,text] = item
    passives[id] = { id:id,title:title,category:"Passive",rarity:rarity,description:description,locked:id === "hardplate" }
    perks[id] = { [stat]:value,text:text }
}

var actives = {
    guardPulse:{ id:"guardPulse",title:"Guard pulse",category:"Active",rarity:"epic",cooldown:22,
        description:"Spend the force stored by recent shield blocks to release a shockwave. A raised shield drops when you spend it." },
    reserveGuard:{ id:"reserveGuard",title:"Reserve guard",category:"Active",rarity:"epic",cooldown:19,
        description:"Take four seconds off your shield recovery. If a temporary barrier is up, restore one barrier charge." },
    sureStrike:{ id:"sureStrike",title:"Sure strike",category:"Active",rarity:"rare",cooldown:22,
        description:"Your next weapon attack is a guaranteed critical if it connects. The strength upgrade raises its critical damage." },
    sharpen:{ id:"sharpen",title:"Sharpen",category:"Active",rarity:"rare",cooldown:21,
        description:"For six seconds, melee strikes have higher critical chance and critical damage." },
    riskCharge:{ id:"riskCharge",title:"Blood gamble",category:"Active",rarity:"legendary",cooldown:24,
        description:"Spend 15 HP for six seconds of greatly increased critical chance." },
    critMark:{ id:"critMark",title:"Fatal mark",category:"Active",rarity:"epic",cooldown:20,
        description:"Mark the enemy under your aim. Attacks against it gain critical chance for six seconds." },
    criticalEcho:{ id:"criticalEcho",title:"Critical echo",category:"Active",rarity:"epic",cooldown:23,locked:true,
        description:"Release your last critical hit as a smaller pulse into nearby enemies. Consumes the stored hit." }
}

// Extra active effects give each equipment group an equal number of kit pieces.
var rituals = [
    ["guardKick","Ward kick","rare",19,"repelShield",1,"Push close foes away. A charged shield makes the push stronger."],
    ["ironRing","Iron ring","rare",21,"edgeRing",4.5,"Strike every nearby demon on your current wallpaper."],
    ["glintShot","Glint shot","rare",20,"seekMark",4.2,"Hit the nearest enemy and mark it for your next attack."],
    ["paleSpark","Pale spark","rare",21,"electrify",3.4,"Hit the foremost demon with a small Electric charge."],
    ["driftSeal","Drift seal","rare",22,"abyss",.26,"Advance a visible Void seal and delay its attack."],
    ["beforeDawn","Before dawn","rare",20,"wideSlow",1.9,"Slow the attacks of the three closest enemies across all views."],
    ["saltEdge","Salt edge","rare",19,"reloadCut",.24,"Finish half of a magazine reload and weaken the nearest attacker."],
    ["slingCast","Sling cast","rare",21,"axePrep",.7,"Recover a thrown axe faster and strengthen the next throw."],
    ["pinpointDust","Pinpoint dust","rare",24,"sight",7,"Tighten your shot spread for seven seconds."],
    ["steadyCharm","Steady charm","rare",23,"cleanFrost",2.5,"Clear Frost and briefly speed up turns."],
    ["glassVault","Glass vault","epic",22,"shieldWindow",.59,"Give your raised shield one extra block and shorten your next shot recovery."],
    ["fireline","Fireline","epic",24,"ember",6.4,"Ignite the closest enemy on each wallpaper."],
    ["clawStop","Claw stop","epic",21,"interrupt",3.2,"Interrupt two charging enemies and damage them lightly."],
    ["sporeVise","Spore vise","epic",20,"corrode",5.2,"Poison one target and weaken its attack before it reaches you."],
    ["coilTrigger","Coil trigger","epic",21,"burstPulse",4.9,"Fire a kinetic pulse that gains strength from an equipped burst gun."],
    ["flashCoins","Flash mint","epic",20,"mint",1,"Aiming at a gift cashes it in and showers nearby threats with sparks."],
    ["ladderLight","Ladder light","legendary",24,"pierceScroll",8.5,"Send a piercing shock through three enemies lined up in depth."]
]
for (const row of rituals) {
    const [id,title,rarity,cooldown,mode,strength,description] = row
    actives[id] = { id:id,title:title,category:"Active",rarity:rarity,cooldown:cooldown,
        form:mode,value:strength,description:description }
}

var weapons = {}
var frames = [
    ["ironservice","Iron service","common","pistol",7,2.4,.31,.99,24,"#eda77e",.025,"A slow, accurate sidearm with a slightly better critical chance."],
    ["fieldRepeater","Field repeater","common","carbine",14,1.38,.157,1.05,28,"#b4e795",0,"A small magazine trades trigger speed for a harder hit."],
    ["splinter","Splinter gun","common","scattergun",4,1.49,.59,1.32,44,"#e0a184",0,"A wide close-range spread built for point-blank defence."],
    ["standardBolt","Bolt pistol","common","ion",8,2.33,.29,1.03,22,"#8fd7ee",.012,"A clear narrow shot with a short, consistent reload."],
    ["reed","Reed carbine","common","carbine",21,1.11,.131,1.52,31,"#dfcb86",0,"A long magazine supports deliberate bursts of held fire."],
    ["shortRam","Short ram","common","scattergun",5,1.27,.51,1.61,41,"#f7be8b",0,"A short barrel cycles faster at close range."],
    ["gallows","Gallows rifle","epic","deadeye",8,4.9,.45,1.58,24,"#f6ae75",.19,"A precision rifle with high critical chance. Critical hits restore one round per magazine."],
    ["verdictRifle","Verdict rifle","rare","rail",5,5.9,.69,1.42,21,"#9cc6ef",.095,"A heavy precision shot with a higher chance of critical damage."],
    ["crest","Crest shotgun","rare","riot",5,1.39,.64,1.43,51,"#f1b272",.047,"Five tight pellets share one critical roll per trigger."],
    ["frostwing","Frostwing carbine","rare","razor",14,1.86,.23,1.38,24,"#b1ddff",.025,"Light level 1 Frost helps keep moving targets in view."],
    ["weathered","Weathered sixgun","rare","pistol",6,3.64,.39,1.26,21,"#e2cd8c",.095,"Six decisive shots with a strong critical chance."],
    ["stingNeedle","Sting needle","rare","bilecaster",9,2.87,.31,1.30,24,"#b9eb85",.036,"Light Poison for a narrow, fast attack."],
    ["copperPulse","Copper pulse","rare","arc",12,2.17,.235,1.52,26,"#f3ac73",0,"Level 1 Electric pulses for groups in tight spaces."],
    ["cinderDouble","Cinder double","rare","hellbore",2,1.66,.66,1.24,47,"#ff9876",.06,"Two wide incendiary shots deal their best damage up close."],
    ["stoneRail","Stone rail","rare","harrier",6,4.83,.57,1.49,24,"#dfb981",.04,"A short Stun can interrupt an exposed target."],
    ["paleward","Paleward rifle","rare","rail",7,4.1,.45,1.49,25,"#d0dec3",.04,"This rifle deals extra damage while your shield recharges after a block."],
    ["coldSnap","Cold snap","rare","riot",4,1.59,.64,1.56,48,"#a9d9ff",.03,"A fast spread that applies level 1 Frost."],
    ["brightShot","Bright shot","rare","ion",18,1.33,.123,1.48,29,"#cdeaa8",.072,"A quick repeater with a raised critical chance for sustained hits."],
    ["omenCaster","Omen caster","rare","crucible",11,3.3,.33,1.39,25,"#d7a7f7",.032,"Bolts apply Weaken before a demon can close in."],
    ["splitPin","Split pin","rare","kestrel",16,1.71,.47,1.49,28,"#9cd3bb",.025,"Two timed rounds let you track a foe through a short burst."],
    ["feint","Feint pistol","rare","twinpistols",13,2.62,.229,1.35,27,"#e4b89c",.06,"A short cycle and elevated critical chance reward quick corrections."],
    ["grindstone","Grindstone","rare","launcher",8,4.6,.53,1.64,27,"#c0aaa3",.045,"Heavy charges push smaller foes back with Wind."],
    ["emberslash","Ember edge","epic","darksaber",0,9.4,.53,.75,73,"#ff865e",.13,"A burning blade. Its charged attack can close the distance and its criticals burn at level 3."]
]
var rangedElements = {
    frostwing:"freeze", stingNeedle:"poison", copperPulse:"electric", cinderDouble:"burn", stoneRail:"stun",
    coldSnap:"freeze", omenCaster:"weaken", grindstone:"wind", emberslash:"burn"
}
var spreadFrames = ["splinter","shortRam","crest","cinderDouble","coldSnap"]
for (let index = 0; index < frames.length; ++index) {
    const row = frames[index]
    const [id,title,rarity,art,capacity,damage,delay,reload,aim,color,crit,description] = row
    const spread = spreadFrames.includes(id)
    const spec = { id:id,title:title,category:"Weapon",rarity:rarity,art:art,frame:index+1,
        effect:spread ? "spread" : !capacity ? "melee" : id === "splitPin" ? "burst" : rangedElements[id] ? "pulse" : "ballistic",
        capacity:capacity,damage:damage,
        delay:delay,reload:reload,aim:aim,color:color,crit:crit,trace:2.9,afterglow:.17,handling:"reload",description:description }
    if (spread)
        spec.spread = [[0,0],[-.026,-.018],[.026,-.018],[-.028,.025],[.028,.025]]
    if (rangedElements[id]) {
        spec.element = rangedElements[id]
        spec.elementLevel = 1
    }
    if (id === "splitPin")
        spec.burst = { count:2,interval:.087 }
    if (id === "emberslash" || id === "gallows")
        spec.locked = true
    if (id === "gallows")
        spec.signature = "critRound"
    if (id === "paleward")
        spec.signature = "guardShot"
    if (id === "grindstone") {
        spec.effect = "launcher"
        spec.blast = 260
    }
    if (id === "shortRam")
        spec.signature = "closeCycle"
    if (id === "emberslash") {
        spec.signature = "criticalFlame"
        spec.melee = { reach:517, targets:2, trick:"Ignite the edge", boost:1.64 }
        spec.elementLevel = 2
    }
    weapons[id] = spec
}
