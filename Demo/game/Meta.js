.pragma library

var grades=["F","D","C","B","A","S","SSS"]
var colors={F:"#8b9cac",D:"#b5a5bc",C:"#91c9ed",B:"#9cdebd",A:"#f0b87d",S:"#e3acff",SSS:"#ffe283"}
var vows=[
    {id:"weapon",title:"Edge of the bargain",glyph:"✧",cap:50,price:16,growth:1.095,description:"Every rank adds 2% of the original weapon damage.",line:"Hehe. Steel has a memory. Teach it what you need it to remember."},
    {id:"health",title:"Heart of tallow",glyph:"♥",cap:50,price:18,growth:1.106,description:"Every rank adds 5% of your original 200 HP. That is ten HP per rank.",line:"The last customer wanted a larger heart. They did live longer. A little."},
    {id:"duration",title:"Longer shadows",glyph:"◐",cap:12,price:31,growth:1.23,description:"Adds 2.5% to timed active effects per rank. Instant effects keep their duration.",line:"Night clings to you a little longer. I could do the same, if you asked nicely."},
    {id:"recovery",title:"Clock of bone",glyph:"◴",cap:16,price:36,growth:1.19,description:"Takes 1.5% off active cooldowns per rank, up to 24%.",line:"Even a clock has to catch its breath. This one never learned how."},
    {id:"passive",title:"Familiar whisper",glyph:"◇",cap:15,price:24,growth:1.20,description:"Each rank improves the extra stat bonuses granted by passive item upgrades by 2%.",line:"What's the trick? You have to listen very closely. Closer. Hehe."},
    {id:"barrier",title:"Borrowed glass",glyph:"⬡",cap:3,prices:[145,395,960],description:"Start each regular run with one extra barrier charge per rank. Spent charges stay broken.",line:"Three panes, three promises. Try to keep your end of at least one of them."},
    {id:"shield",title:"Patient buckler",glyph:"⛨",cap:8,price:46,growth:1.32,description:"Reduces field shield recovery by 0.12 seconds per rank.",line:"Every shield wants to be put down eventually. This one is less stubborn."},
    {id:"parry",title:"The opening",glyph:"✴",cap:4,price:76,growth:1.46,description:"Widens the perfect shield parry timing by 0.015 seconds per rank.",line:"A heartbeat before the crash. Can you hear it? I always can."}
]
var parcels=[
    {id:"vitality",title:"Extra heartbeat",glyph:"♥",price:34,description:"Begin the next regular run with 35 extra maximum HP.",line:"There's a beat in the box. That's probably a good sign."},
    {id:"force",title:"Gravesalt",glyph:"✧",price:60,description:"Gain 12% weapon and active impact for the next regular run.",line:"Just a pinch. If you spill the whole pouch I'll have to find another grave."},
    {id:"quickening",title:"A little haste",glyph:"◴",price:52,description:"Active cooldowns are 10% shorter for the next regular run.",line:"Running late already? They haven't even opened the gates."},
    {id:"basket",title:"Wrapped favours",glyph:"◇",price:105,description:"Start with one random Common or Rare active and one Common or Rare passive.",line:"I tied that ribbon myself. If it moves, try pulling the other end. Hehe."},
    {id:"epic",title:"Violet reliquary",glyph:"✦",price:180,rarity:"epic",description:"Start the next regular run with one random eligible Epic weapon.",line:"I knew its last owner. This is where I'd say I miss them, isn't it?"},
    {id:"legendary",title:"Gilded casket",glyph:"✷",price:430,rarity:"legendary",description:"Start the next regular run with one random eligible Legendary weapon.",line:"You're sure? Good. I want to see what it does in your hands."}
]

function fresh() {
    return {gems:0,ranks:{},pending:{},settled:{},started:{},best:null,last:null,archive:[]}
}

function level(state,id) {return state?.ranks?.[id] || 0}

function price(state,offer) {
    const rank=level(state,offer.id)
    return offer.prices ? offer.prices[rank] : Math.ceil(offer.price*Math.pow(offer.growth || 1,rank))
}

function canBuy(state,offer) {
    if (offer.cap && level(state,offer.id)>=offer.cap) return false
    if (!offer.cap && (state.pending[offer.id] || offer.rarity && (state.pending.epic || state.pending.legendary))) return false
    return state.gems>=price(state,offer)
}

function buy(state,id) {
    const offer=vows.concat(parcels).find(function(item) {return item.id===id})
    if (!offer || !canBuy(state,offer)) return false
    state.gems-=price(state,offer)
    if (offer.cap) state.ranks[id]=level(state,id)+1
    else state.pending[id]=true
    return true
}

function contract(state) {
    return {ranks:Object.assign({},state.ranks),pending:Object.assign({},state.pending)}
}

function begin(state,id) {
    if (!id || state.settled[id]) return null
    if (state.started[id]) return state.started[id]
    const terms=contract(state)
    state.pending={}
    state.started[id]=terms
    return terms
}

var unmodified={health:0,weapon:1,active:1,duration:1,recovery:1,passive:1,barrier:0,shield:0,parry:0}

function benefits(run) {
    const terms=run?.covenant
    if (!terms) return unmodified
    const rank=terms?.ranks || {}, parcels=terms?.pending || {}
    return {health:(rank.health || 0)*10+(parcels.vitality ? 35 : 0),
        weapon:(1+(rank.weapon || 0)*.02)*(parcels.force ? 1.12 : 1), active:parcels.force ? 1.12 : 1,
        duration:1+(rank.duration || 0)*.025, recovery:(1-(rank.recovery || 0)*.015)*(parcels.quickening ? .90 : 1),
        passive:1+(rank.passive || 0)*.02, barrier:rank.barrier || 0, shield:(rank.shield || 0)*.12,
        parry:(rank.parry || 0)*.015}
}

function clamp(number) {return Math.max(0,Math.min(1,number))}
function curve(value, scale) {return 1-Math.exp(-Math.max(0,value)/scale)}
function round(value) {return Math.round(value*10)/10}

function grade(score) {
    return score>=84 ? "S" : score>=70 ? "A" : score>=55 ? "B" : score>=36 ? "C" : score>=19 ? "D" : "F"
}

function report(run, reason, load) {
    const m=run.metrics, cleared=m.waves || 0, shots=m.shots || 0, hits=Math.min(shots,m.hitShots || 0)
    const kills=m.kills || 0, damage=m.damageTaken || 0, contacts=m.unblockedHits || 0
    const bosses=m.bossKills || 0, seals=m.seals || 0, blocks=m.shieldBlocks || 0
    const parries=m.parries || 0, intercepts=m.intercepts || 0, purchases=m.shopBuys || 0
    const gained=m.goldEarned || 0, spent=m.shopSpent || 0, wallet=run.gold || 0
    const flawless=m.flawless || 0, stage=Math.max(1,run.wave)
    const accuracy=shots ? hits/shots : 0
    const experience=curve(cleared,18)
    const precision=accuracy*curve(shots,38)+(hits/(shots+10))*(1-curve(shots,38))
    const killPressure=curve(kills,Math.max(18,cleared*3.1))
    const guard=curve(blocks+2.0*parries+intercepts*.45,Math.max(6,cleared*.9))
    const shelter=curve(seals,Math.max(1,cleared*.12))
    const arsenal=curve(load.items+load.upgrades*.45,6.2)
    const income=curve(gained,Math.max(900,cleared*48))
    const reserve=curve(wallet,Math.max(280,cleared*17))
    const used=curve(spent,Math.max(450,cleared*31))
    const deals=curve(purchases,Math.max(2,bosses*1.45))
    const impact=damage+contacts*1.7
    const skill=round(100*clamp(.46*precision+.20*killPressure+.13*guard+.08*shelter+.13*experience+.035*curve(bosses,2.2)))
    const finance=round(100*clamp(.31*income+.21*reserve+.22*used+.14*deals+.12*arsenal))
    const survival=round(100*clamp((.62*Math.exp(-impact/(125+cleared*21))+.23*(flawless/Math.max(1,cleared))
        +.15*curve(bosses,2.5))*(.56+.44*curve(cleared,6))))
    const burden=m.loadSamples ? m.loadBurden/m.loadSamples : load.burden
    const restraint=round(4.5*curve(cleared,28)*clamp((2.3+cleared*.17-burden)/Math.max(2.3,cleared*.17)))
    const risk=run.difficulty==="insane" ? 4.5 : run.difficulty==="hard" ? 2.5 : 0
    const engaged=kills>=2 || blocks>=2 || shots>=6 && accuracy>=.55
    const score=round(Math.max(engaged ? 19 : 0,Math.min(100,
        (skill*.43+finance*.22+survival*.35)*(.63+.37*curve(cleared,12))+restraint+risk*experience)))
    const perfect=reason==="retired" && cleared>=50 && bosses>=5 && shots>=180 && hits===shots
        && damage===0 && contacts===0 && flawless===cleared && score>=84
    const overall=perfect ? "SSS" : grade(score)
    const eligible=!run.debug && !run.training && !run.rehearsal && !!run.attemptId
    const bonus=[0,4,11,26,50,92,235][grades.indexOf(overall)]
    const base=Math.floor(cleared*1.10+bosses*6+Math.sqrt(kills)*1.25+seals*1.6+skill/15)
    const gems=eligible ? Math.floor((base+bonus)*(1+risk*.045)) : 0
    return {id:run.attemptId,date:Math.floor(Date.now()/1000),reason:reason,difficulty:run.difficulty,wave:stage,cleared:cleared,
        grades:{skill:grade(skill),finance:grade(finance),survival:grade(survival),overall:overall},
        points:{skill:skill,finance:finance,survival:survival,overall:score}, gems:gems,bonus:eligible ? bonus : 0,eligible:eligible,
        stats:{accuracy:round(accuracy*100),shots:shots,hits:hits,damage:round(damage),contacts:contacts,kills:kills,bosses:bosses,
            seals:seals,blocks:blocks,parries:parries,intercepts:intercepts,purchases:purchases,earned:gained,spent:spent,wallet:wallet,
            flawless:flawless,items:load.items,upgrades:load.upgrades,restraint:restraint}}
}

function settle(state,card) {
    if (!card.eligible || state.settled[card.id]) return false
    state.settled[card.id]=card.grades.overall
    delete state.started[card.id]
    state.gems+=card.gems
    state.last=card
    const best=state.best
    const place=grades.indexOf(card.grades.overall), previous=best ? grades.indexOf(best.grades.overall) : -1
    if (place>previous || place===previous && card.points.overall>best.points.overall)
        state.best=card
    return true
}

function saveAttempt(state,card) {
    if (!card.eligible || !state.settled[card.id] || state.archive.some(function(saved) {return saved.id===card.id})) return false
    state.archive=[card].concat(state.archive).slice(0,40)
    return true
}

function known(id, list) {return list.some(function(offer) {return offer.id===id})}
function object(value) {return value && typeof value === "object" && !Array.isArray(value)}
function validNumber(value) {return typeof value === "number" && Number.isFinite(value) && value>=0}
function validId(id) {return typeof id === "string" && /^[a-z0-9-]{8,64}$/.test(id)}

function validTerms(data) {
    return object(data) && object(data.ranks) && object(data.pending)
        && Object.keys(data.ranks).every(function(id) {
            const item=vows.find(function(offer) {return offer.id===id})
            return item && Number.isInteger(data.ranks[id]) && data.ranks[id]>=0 && data.ranks[id]<=item.cap
        }) && Object.keys(data.pending).every(function(id) {return data.pending[id]===true && known(id,parcels)})
        && !(data.pending.epic && data.pending.legendary)
}

function validCard(card) {
    return object(card) && validId(card.id) && typeof card.eligible === "boolean" && validNumber(card.gems) && validNumber(card.bonus)
        && validNumber(card.date) && validNumber(card.wave) && validNumber(card.cleared) && ["death","retired"].includes(card.reason)
        && ["normal","hard","insane"].includes(card.difficulty) && object(card.grades) && object(card.points) && object(card.stats)
        && ["skill","finance","survival","overall"].every(function(axis) {return grades.includes(card.grades[axis]) && validNumber(card.points[axis])})
        && Object.values(card.stats).every(validNumber)
}

function decode(data) {
    if (!object(data) || !validTerms(data) || !Number.isSafeInteger(data.gems) || data.gems<0 || !object(data.started) || !object(data.settled)
        || !Object.keys(data.started).every(function(id){return validId(id) && validTerms(data.started[id])})
        || !Object.keys(data.settled).every(function(id){return validId(id) && grades.includes(data.settled[id])})
        || !(data.best===null || validCard(data.best)) || !(data.last===null || validCard(data.last))
        || !Array.isArray(data.archive) || data.archive.length>40 || !data.archive.every(validCard)) return null
    return data
}

function read(value) {
    try {return decode(JSON.parse(value)) || fresh()}
    catch (error) {return fresh()}
}
