.pragma library
.import "GradeGear.js" as Grades
.import "WeatherGear.js" as Weather

// The rewards are real catalogue IDs. Multiple achievements can progress during one run.
var achievements = [
    { id:"firstLight", title:"First light", metric:"waves", target:1, requirement:"Clear your first wave.", group:"weapon", reward:"breacher" },
    { id:"watch", title:"Night watch", metric:"bestWave", target:5, requirement:"Reach wave 5.", group:"passive", reward:"sparebox" },
    { id:"closeEnough", title:"Close enough", metric:"grenadeHits", target:8, requirement:"Hit 8 enemies with explosions.", group:"active", reward:"cryogrenade" },
    { id:"clearSky", title:"Clear sky", metric:"alienKills", target:8, requirement:"Defeat 8 aliens.", group:"weapon", reward:"volt" },
    { id:"boltCatcher", title:"Bolt catcher", metric:"intercepts", target:6, requirement:"Intercept 6 alien bolts.", group:"passive", reward:"insulation" },
    { id:"riftRepair", title:"Rift repair", metric:"seals", target:4, requirement:"Close 4 Void seals.", group:"active", reward:"nullgrenade" },
    { id:"sharpEye", title:"Sharp eye", metric:"hitShots", target:80, requirement:"Land 80 shots.", group:"weapon", reward:"razor" },
    { id:"leanIn", title:"Lean into it", metric:"flawless", target:6, requirement:"Clear 6 waves without losing health.", group:"passive", reward:"steadyaim" },
    { id:"openWide", title:"Open wide", metric:"kills", target:90, requirement:"Defeat 90 enemies.", group:"active", reward:"flashflare" },
    { id:"splitDecision", title:"Split decision", metric:"splits", target:3, requirement:"Trigger 3 Rerogorubus splits.", group:"weapon", reward:"ember" },
    { id:"fieldTested", title:"Field tested", metric:"upgrades", target:8, requirement:"Upgrade equipment or a slot ability 8 times.", group:"passive", reward:"booster" },
    { id:"signedFor", title:"Signed for", metric:"gifts", target:6, requirement:"Shoot open 6 gift bags.", group:"active", reward:"repairkit" },
    { id:"heavyWeather", title:"Heavy weather", metric:"rainWaves", target:5, requirement:"Clear 5 waves during rain.", group:"weapon", reward:"harrier" },
    { id:"secondSkin", title:"Second skin", metric:"blocks", target:10, requirement:"Block 10 hits with a barrier.", group:"active", reward:"arcshield" },
    { id:"deepWatch", title:"Deep watch", metric:"seals", target:14, requirement:"Close 14 Void seals.", group:"passive", reward:"voidliner" },
    { id:"headOn", title:"Head on", metric:"spinningBossKills", target:1, requirement:"Defeat Mastafangenbus.", group:"weapon", reward:"prism" },
    { id:"wallet", title:"Heavy pockets", metric:"goldEarned", target:2400, requirement:"Earn 2,400 gold over your runs.", group:"passive", reward:"deepcell" },
    { id:"crowdControl", title:"Crowd control", metric:"grenadeHits", target:60, requirement:"Hit 60 enemies with explosions.", group:"active", reward:"gravitywell" },
    { id:"thrill", title:"Thrill of the hunt", metric:"bossKills", target:5, requirement:"Defeat 5 bosses.", group:"weapon", reward:"cyclone" },
    { id:"glassHouse", title:"Glass house", metric:"shatters", target:30, requirement:"Shatter 30 enemy barriers.", group:"passive", reward:"hunter" },
    { id:"lastStand", title:"Last stand", metric:"lowHealthWaves", target:4, requirement:"Clear 4 waves with 35% health or less.", group:"active", reward:"reversal" },
    { id:"wingmates", title:"Wingmates", metric:"petKills", target:45, requirement:"Let your pet defeat 45 enemies.", group:"pet", reward:"archive" },
    { id:"induction", title:"Induction", metric:"kits", target:7, requirement:"Complete 7 gear kits across your runs.", group:"pet", reward:"wyvern" },
    { id:"goldenHour", title:"Golden hour", metric:"gojemarusKills", target:4, requirement:"Defeat Gojemarus 4 times before it escapes.", group:"pet", reward:"firefly" },
    { id:"ironHorizon", title:"Iron horizon", metric:"bestWave", target:36, requirement:"Reach wave 36.", group:"pet", reward:"warden" },
    { id:"neuralLoop", title:"Neural loop", metric:"electricJumps", target:40, requirement:"Land 40 Electric jumps.", group:"pet", reward:"brain" },
    { id:"threeCuts", title:"Three cuts", metric:"katanaCombos", target:6, requirement:"Land six Katana finishing cuts.", group:"weapon", reward:"gravhammer" },
    { id:"closeWork", title:"Close work", metric:"meleeKills", target:32, requirement:"Defeat 32 enemies with melee weapons.", group:"weapon", reward:"reaperscythe" },
    { id:"runeScript", title:"Rune script", metric:"staffCasts", target:10, requirement:"Cast ten charged staff spells.", group:"weapon", reward:"abyssstaff" },
    { id:"lightsOut", title:"Lights out", metric:"battlestarKills", target:3, requirement:"Destroy three Go Go Battlestars.", group:"weapon", reward:"aurorastaff" },
    { id:"hatchetWork", title:"Hatchet work", metric:"axeHits", target:12, requirement:"Land 12 Tomahawk throws.", group:"active", reward:"axeHook" },
    { id:"threeRounds", title:"Three rounds", metric:"burstKills", target:18, requirement:"Defeat 18 foes with timed burst fire.", group:"passive", reward:"followThrough" },
    { id:"conductor", title:"Conductor", metric:"staffKills", target:35, requirement:"Defeat 35 foes with normal staff attacks.", group:"active", reward:"runesurge" },
    { id:"closeCall", title:"Close call", metric:"dodges", target:12, requirement:"Dodge 12 incoming strikes.", group:"passive", reward:"secondWind" },
    { id:"breakTrident", title:"Fallen three times", metric:"lucifoverusKills", target:3, requirement:"Defeat Lucifoverus three times.", group:"weapon", reward:"helltrident" },
    { id:"fiveGuardCrits", title:"No fatal opening", metric:"bestShieldCrits", target:5, requirement:"Block five critical hits with the field shield in one run.", group:"passive", reward:"hardplate" },
    { id:"hammerFall", title:"Hammer fall", metric:"criticalHits", target:45, requirement:"Land 45 critical hits.", group:"weapon", reward:"gallows" },
    { id:"emberExecution", title:"Ember execution", metric:"criticalKills", target:20, requirement:"Defeat 20 enemies with critical hits.", group:"weapon", reward:"emberslash" },
    { id:"guardBreak", title:"Standing ground", metric:"shieldBlocks", target:30, requirement:"Block 30 hits with the field shield.", group:"active", reward:"criticalEcho" },
    { id:"shadowKin", title:"Kindred shadow", metric:"shadowKills", target:10, requirement:"Defeat ten Shadows.", group:"pet", reward:"minishade" },
    { id:"reapFear", title:"A name to fear", metric:"fearmeKills", target:1, requirement:"Defeat Fearme before it claims you.", group:"weapon", reward:"fearScythe" },
    {id:"trainingVictory",title:"Shrine graduate",metric:"trainingWins",target:1,requirement:"Complete Oblogabgalus's tutorial battle.",group:"weapon",reward:"graduate"},
    {id:"fiveHoles",title:"Close those holes",metric:"papapoganusKills",target:5,requirement:"Defeat five Papapoganus demons.",group:"active",reward:"yellowNoon"},
    {id:"quickHands",title:"Quick hands",metric:"quickWaves",target:3,requirement:"Clear three regular waves in under thirty seconds each.",group:"active",reward:"borrowedBeat"},
    {id:"clockbreaker",title:"Clockbreaker",metric:"fastBosses",target:1,requirement:"Defeat an Overlord within thirty-five seconds of its entrance.",group:"weapon",reward:"hourhand"},
    {id:"keepPace",title:"Keep pace",metric:"bestTimedWave",target:25,requirement:"Clear wave 25 or later in under sixty seconds.",group:"passive",reward:"secondHand"},
    {id:"unbrokenBoss",title:"An unbroken oath",metric:"hitlessBosses",target:1,requirement:"Defeat a boss without losing health during its encounter.",group:"weapon",reward:"stillwater"},
    {id:"untarnishedWave",title:"Untarnished",metric:"bestFlawlessWave",target:20,requirement:"Clear wave 20 or later without losing health in that wave.",group:"passive",reward:"oathglass"},
    {id:"silentTrident",title:"Silence the trident",metric:"hitlessLuci",target:1,requirement:"Defeat Lucifoverus without losing health during his encounter.",group:"active",reward:"oathWard"},
    {id:"royalReserve",title:"Royal reserve",metric:"bestWallet",target:3500,requirement:"Hold 3,500 unspent gold at once in one run.",group:"weapon",reward:"kingsRansom"},
    {id:"moneyMoves",title:"Money moves",metric:"bestRunSpent",target:5000,requirement:"Spend 5,000 gold in one run, including weapon and ability costs.",group:"passive",reward:"liquidAssets"},
    {id:"scarletDawn",title:"Scarlet dawn",metric:"bloodMoonClears",target:1,requirement:"Survive your first Blood Moon Night.",group:"passive",reward:"bloodPact"},
    {id:"threeRedNights",title:"Three red nights",metric:"bloodMoonNights",target:3,requirement:"Witness three Blood Moon Nights in regular play.",group:"weapon",reward:"veinDrinker"},
    {id:"redOverlord",title:"Moon over the Overlord",metric:"bloodMoonBosses",target:1,requirement:"Defeat an Overlord during a Blood Moon Night.",group:"active",reward:"bloodLibation"},
    {id:"lastCustomer",title:"The last customer",metric:"completeShops",target:1,requirement:"Buy and claim every listing during a single shop visit.",group:"active",reward:"liquidation"}
].concat(Grades.achievements,Weather.achievements)

function read(text) {
    if (!text)
        return {}
    try {
        const profile = JSON.parse(text)
        return profile && typeof profile === "object" && !Array.isArray(profile) ? profile : {}
    } catch (error) {
        return {}
    }
}

function merge(profile, delta) {
    const updated = Object.assign({}, profile)
    for (const key of Object.keys(delta)) {
        const previous = Number(updated[key]) || 0
        updated[key] = keepsBest(key) ? Math.max(previous, delta[key]) : previous + delta[key]
    }
    return updated
}

function keepsBest(key) {
    return ["bestWave","bestShieldCrits","bestFlawlessWave","bestWallet","bestRunSpent","bestTimedWave"].includes(key)
}

function withGrades(profile, ledger) {
    const awarded={}
    for (const grade of Object.values(ledger.settled)) {
        const key="grade"+grade
        awarded[key]=(awarded[key] || 0)+1
    }
    awarded.vaultBuys=ledger.purchases || 0
    awarded.vaultGems=ledger.earned || 0
    const merged=Object.assign({},profile)
    for (const key of Object.keys(awarded)) merged[key]=Math.max(merged[key] || 0,awarded[key])
    return merged
}

function complete(profile, achievement) {
    return (profile[achievement.metric] || 0) >= achievement.target
}

function unlocked(profile, override) {
    return achievements.filter(function(item) { return override || complete(profile, item) })
        .map(function(item) { return item.reward })
}

function needed(group, id) {
    return achievements.find(function(item) { return item.group === group && item.reward === id }) || null
}
