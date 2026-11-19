.pragma library
.import "Tarot.js" as Tarot

var families=["F","D","C","B","A","S"]
var thresholds=[0,23,40,55,70,84,100]
var grades=[]
for (const family of families) {
    if (family==="F") grades.push("F")
    else grades.push(family+"-",family,family+"+")
}
grades.push("SSS")

function familyOf(mark) {return mark.replace(/[+-]$/,"")}
var colors={F:"#8b9cac",D:"#b5a5bc",C:"#91c9ed",B:"#9cdebd",A:"#f0b87d",S:"#e3acff",SSS:"#ffe283"}
var vows=[
    {id:"weapon",title:"Edge of the bargain",glyph:"✧",cap:50,price:9,growth:1.18,description:"Every rank adds 2% of the original weapon damage.",line:"Hehe. Steel has a memory. Teach it what you need it to remember."},
    {id:"health",title:"Heart of tallow",glyph:"♥",cap:50,price:11,growth:1.19,description:"Every rank adds 5% of your original 200 HP. That is ten HP per rank.",line:"The last customer wanted a larger heart. They did live longer. A little."},
    {id:"duration",title:"Longer shadows",glyph:"◐",cap:12,price:31,growth:1.46,description:"Adds 2.5% to timed active effects per rank. Instant effects keep their duration.",line:"Night clings to you a little longer. I could do the same, if you asked nicely."},
    {id:"recovery",title:"Clock of bone",glyph:"◴",cap:16,price:36,growth:1.39,description:"Takes 1.5% off active cooldowns per rank, up to 24%.",line:"Even a clock has to catch its breath. This one never learned how."},
    {id:"passive",title:"Familiar whisper",glyph:"◇",cap:15,price:24,growth:1.41,description:"Each rank improves the extra stat bonuses granted by passive item upgrades by 2%.",line:"What's the trick? You have to listen very closely. Closer. Hehe."},
    {id:"barrier",title:"Borrowed glass",glyph:"⬡",cap:3,prices:[145,495,1690],description:"Start each regular run with one extra barrier charge per rank. Spent charges stay broken.",line:"Three panes, three promises. Try to keep your end of at least one of them."},
    {id:"shield",title:"Patient buckler",glyph:"⛨",cap:8,price:46,growth:1.58,description:"Reduces field shield recovery by 0.12 seconds per rank.",line:"Every shield wants to be put down eventually. This one is less stubborn."},
    {id:"parry",title:"The opening",glyph:"✴",cap:4,price:76,growth:1.84,description:"Widens the perfect shield parry timing by 0.015 seconds per rank.",line:"A heartbeat before the crash. Can you hear it? I always can."},
    {id:"rerolls",title:"Another turn",glyph:"⟳",cap:4,price:45,growth:2.54,
        description:"One additional free reroll per regular run at each rank. At maximum rank you start with five.",
        line:"I could turn the wheel again. For you, I might even do it for free."},
    {id:"freezeStock",title:"Winter’s keeping",glyph:"❄",cap:1,price:125,
        description:"Freeze one field-shop item or wave reward. It survives rerolls and returns at the next visit of that kind.",
        line:"Want me to keep that one on ice? I can be very patient."}
]
var parcels=[
    {id:"vitality",title:"Extra heartbeat",glyph:"♥",price:34,description:"Begin the next regular run with 35 extra maximum HP.",line:"There's a beat in the box. That's probably a good sign."},
    {id:"force",title:"Gravesalt",glyph:"✧",price:60,description:"Gain 12% weapon and active impact for the next regular run.",line:"Just a pinch. If you spill the whole pouch I'll have to find another grave."},
    {id:"quickening",title:"A little haste",glyph:"◴",price:52,description:"Active cooldowns are 10% shorter for the next regular run.",line:"Running late already? They haven't even opened the gates."},
    {id:"basket",title:"Wrapped favours",glyph:"◇",price:105,description:"Start with one random Common or Rare active and one Common or Rare passive.",line:"I tied that ribbon myself. If it moves, try pulling the other end. Hehe."},
    {id:"epic",title:"Violet reliquary",glyph:"✦",price:180,rarity:"epic",description:"Start the next regular run with one random eligible Epic weapon.",line:"I knew its last owner. This is where I'd say I miss them, isn't it?"},
    {id:"legendary",title:"Gilded casket",glyph:"✷",price:430,rarity:"legendary",description:"Start the next regular run with one random eligible Legendary weapon.",line:"You're sure? Good. I want to see what it does in your hands."}
]
var passages=[105,235,530,1190,2680].map(function(price,index) {
    const wave=(index+1)*10
    return {id:"pass"+wave,wave:wave,title:"Passage to Wave "+wave,glyph:"◇",price:price,
        description:"Start your next regular run on Wave "+wave+" with your chosen starter gear. One passage per run.",
        line:["I can take you past the first few doors.","The second bell is already beginning to ring.",
            "There are things up there that remember my name.","You won’t want to look down. Or up, come to think of it.",
            "This is as far as I open the way. Beyond that, you walk alone."][index]}
})
parcels=parcels.concat(passages)

function startWave(terms) {
    const pending=terms && terms.pending || {}
    const passage=passages.find(function(item) {return pending[item.id]})
    return passage ? passage.wave : 1
}

var reading = {id:"tarot",title:"The witch’s reading",glyph:"✶",price:44,
    description:"Turn one card from a hand of five. Its omen follows your next regular expedition.",
    line:"Five doors. Behind each, a different way to come back alive."}
var offers = vows.concat(parcels,[reading])

function fresh() {
    return {gems:0,earned:0,purchases:0,receipts:{},legacyReceipts:{},ranks:{},pending:{},settled:{},closed:{},started:{},best:null,last:null,archive:[],
        reading:null,sale:{discount:0,free:""},field:{}}
}

function level(state,id) {return state?.ranks?.[id] || 0}

function basePrice(state,offer) {
    const rank=level(state,offer.id)
    return offer.prices ? offer.prices[Math.min(rank,offer.prices.length-1)] : Math.ceil(offer.price*Math.pow(offer.growth || 1,rank))
}

function discount(state,offer) {
    const sale=state.sale
    return sale?.free===offer.id ? 100 : sale?.discount || 0
}

function price(state,offer) {
    return Math.ceil(basePrice(state,offer)*(100-discount(state,offer))/100)
}

function inStock(state,offer) {
    if (offer.id===reading.id) return !state.reading
    if (offer.cap) return level(state,offer.id)<offer.cap
    if (offer.wave) return startWave(state)===1
    return !(state.pending[offer.id] || offer.rarity && (state.pending.epic || state.pending.legendary))
}

function canBuy(state,offer,unlimited) {
    return inStock(state,offer) && (unlimited || state.gems>=price(state,offer))
}

function buy(state,id,random,unlimited) {
    const offer=offers.find(function(item) {return item.id===id})
    if (!offer || !canBuy(state,offer,unlimited)) return false
    const paid=unlimited ? 0 : price(state,offer)
    state.gems-=paid
    if (state.sale.free===id) state.sale.free=""
    state.purchases++
    if (id===reading.id) state.reading={cards:Tarot.draw(random || Math.random),chosen:""}
    else if (offer.cap) {
        if (!state.receipts[id]) state.receipts[id]=[]
        state.receipts[id].push(paid)
        state.ranks[id]=level(state,id)+1
    }
    else state.pending[id]=true
    return true
}

function refundValue(state,id) {
    const rank=level(state,id)
    if (!rank) return 0
    const receipts=state.receipts[id] || []
    return receipts.length ? receipts[receipts.length-1] : 0
}

function refund(state,id) {
    if (!known(id,vows) || !level(state,id)) return false
    state.gems+=refundValue(state,id)
    if (state.receipts[id]?.length) state.receipts[id].pop()
    state.ranks[id]--
    if (state.legacyReceipts[id]>state.ranks[id]) state.legacyReceipts[id]=state.ranks[id]
    state.purchases=Math.max(0,state.purchases-1)
    return true
}

function practiceLedger() {
    const ledger=fresh()
    ledger.gems=0
    for (const vow of vows) ledger.ranks[vow.id]=vow.cap
    return ledger
}

function turnCard(state,id) {
    if (!state.reading || state.reading.chosen || !state.reading.cards.includes(id)) return false
    state.reading.chosen=id
    return true
}

function contract(state) {
    const terms={ranks:Object.assign({},state.ranks),pending:Object.assign({},state.pending)}
    if (state.reading?.chosen) terms.tarot=state.reading.chosen
    return terms
}

function begin(state,id) {
    if (!id || state.settled[id] || state.closed[id]) return null
    if (state.started[id]) return state.started[id]
    const terms=contract(state)
    state.pending={}
    if (terms.tarot) state.reading=null
    state.started[id]=terms
    return terms
}

var unmodified={health:0,weapon:1,active:1,duration:1,recovery:1,passive:1,barrier:0,shield:0,parry:0}

function benefits(run) {
    const terms=run?.covenant
    if (!terms) return unmodified
    const rank=terms.ranks || {}, parcels=terms.pending || {}
    const omen=terms.tarot ? Tarot.stats(run) : {}
    return {health:(rank.health || 0)*10+(parcels.vitality ? 35 : 0)+(omen.health || 0),
        weapon:(1+(rank.weapon || 0)*.02)*(parcels.force ? 1.12 : 1), active:parcels.force ? 1.12 : 1,
        duration:1+(rank.duration || 0)*.025+(omen.duration || 0), recovery:(1-(rank.recovery || 0)*.015)*(parcels.quickening ? .90 : 1),
        passive:1+(rank.passive || 0)*.02, barrier:rank.barrier || 0, shield:(rank.shield || 0)*.12,
        parry:(rank.parry || 0)*.015}
}

function clamp(number) {return Math.max(0,Math.min(1,number))}
function curve(value, scale) {return 1-Math.exp(-Math.max(0,value)/scale)}
function round(value) {return Math.round(value*10)/10}

function validGrade(value) {return grades.includes(value) || value==="F+" || value==="F-"}

function grade(score) {
    let band=0
    while (band<families.length-1 && score>=thresholds[band+1]) band++
    if (band===0) return "F"
    const fraction=(score-thresholds[band])/(thresholds[band+1]-thresholds[band])
    return families[band]+(fraction<1/3 ? "-" : fraction<2/3 ? "" : "+")
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
    const waveScore=round(100*clamp(cleared/120))
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
    const survival=round(100*clamp(.27*curve(cleared,35)+.73*(.62*Math.exp(-impact/(125+cleared*21))
        +.23*(flawless/Math.max(1,cleared)) +.15*curve(bosses,2.5))*(.48+.52*curve(cleared,9))))
    const burden=m.loadSamples ? m.loadBurden/m.loadSamples : load.burden
    const restraint=round(4.5*curve(cleared,28)*clamp((2.3+cleared*.17-burden)/Math.max(2.3,cleared*.17)))
    const risk=run.difficulty==="insane" ? 4.5 : run.difficulty==="hard" ? 2.5 : 0
    const engaged=kills>=2 || blocks>=2 || shots>=6 && accuracy>=.55
    const score=round(Math.max(engaged ? 10 : 0,Math.min(100,
        waveScore*.38+skill*.27+finance*.13+survival*.22+restraint+risk*experience)))
    const perfect=reason==="retired" && cleared>=120 && bosses>=8 && shots>=350 && hits===shots
        && kills>=420 && seals>=8 && blocks>=28 && parries>=8 && purchases>=10
        && damage===0 && contacts===0 && flawless===cleared && skill>=90 && finance>=80 && survival>=98 && score>=91
    const overall=perfect ? "SSS" : grade(score)
    const eligible=!run.debug && !run.training && !run.rehearsal && !!run.attemptId
    // Side awards scale with cleared waves so combat farming cannot outpay progress.
    const quality=overall==="SSS" ? 1 : (grades.indexOf(overall)+1)/grades.length
    const bonus=Math.floor(cleared*.40*quality)
    const lootGems=fieldGems(run.fieldGems)
    const waveGems=cleared
    const combatGems=Math.min(Math.floor(cleared*.20),Math.floor(bosses*.8+Math.sqrt(kills)*.16+seals*.20+risk*.25))
    const gems=eligible ? waveGems+combatGems+bonus : 0
    return {id:run.attemptId,date:Math.floor(Date.now()/1000),reason:reason,difficulty:run.difficulty,wave:stage,cleared:cleared,
        grades:{skill:grade(skill),finance:grade(finance),survival:grade(survival),overall:overall},
        points:{skill:skill,finance:finance,survival:survival,overall:score}, gems:gems,bonus:eligible ? bonus : 0,eligible:eligible,
        stats:{accuracy:round(accuracy*100),shots:shots,hits:hits,damage:round(damage),contacts:contacts,kills:kills,bosses:bosses,
            seals:seals,blocks:blocks,parries:parries,intercepts:intercepts,purchases:purchases,earned:gained,spent:spent,wallet:wallet,
            flawless:flawless,items:load.items,upgrades:load.upgrades,restraint:restraint,waveScore:waveScore,fieldGems:lootGems,waveGems:waveGems,combatGems:combatGems}}
}

function rotation(state,id) {
    let seed=0x811c9dc5
    for (let i=0;i<id.length;i++) seed=Math.imul(seed^id.charCodeAt(i),0x01000193)
    return rollSale(state,function() {
        seed=(Math.imul(seed,1664525)+1013904223)>>>0
        return seed/4294967296
    })
}

function rollSale(state,random) {
    const rolled=random()
    const discount=rolled<.0014 ? 50 : rolled<.0147 ? 20 : rolled<.07 ? 10 : 0
    if (random()>=.001) return {discount:discount,free:""}
    const stock=offers.filter(function(offer) {return inStock(state,offer)})
    return {discount:discount,free:stock[Math.floor(random()*stock.length)]?.id || ""}
}

function settle(state,card) {
    if (!card.eligible || state.settled[card.id] || state.closed[card.id]) return false
    state.settled[card.id]=card.grades.overall
    delete state.started[card.id]
    delete state.field[card.id]
    state.gems+=card.gems
    state.earned+=card.gems
    state.sale=rotation(state,card.id)
    state.last=card
    const best=state.best
    const place=grades.indexOf(card.grades.overall), previous=best ? grades.indexOf(best.grades.overall) : -1
    if (place>previous || place===previous && card.points.overall>best.points.overall)
        state.best=card
    return true
}

function fieldGems(claims) {
    return claims ? Object.values(claims).reduce(function(sum,count){return sum+count},0) : 0
}

function validField(claims) {
    return object(claims) && Object.keys(claims).every(function(key) {
        return /^(boss|mega)-[1-9][0-9]{0,4}$/.test(key) && Number.isInteger(claims[key])
            && claims[key]>0 && claims[key]<=(key.startsWith("boss-") ? 4 : 10000)
    })
}

function depositField(state,id,claims) {
    if (!validId(id) || state.settled[id] || state.closed[id] || !validField(claims)) return false
    const deposited=state.field[id] || {}
    let added=0
    for (const key of Object.keys(claims)) {
        const prior=deposited[key] || 0
        if (claims[key]<=prior) continue
        added+=claims[key]-prior
        deposited[key]=claims[key]
    }
    if (!added) return false
    state.field[id]=deposited
    state.gems+=added
    state.earned+=added
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
        && (data.tarot===undefined || typeof data.tarot==="string" && !!Tarot.card(data.tarot))
        && Object.keys(data.ranks).every(function(id) {
            const item=vows.find(function(offer) {return offer.id===id})
            return item && Number.isInteger(data.ranks[id]) && data.ranks[id]>=0 && data.ranks[id]<=item.cap
        }) && Object.keys(data.pending).every(function(id) {return data.pending[id]===true && known(id,parcels)})
        && !(data.pending.epic && data.pending.legendary)
        && passages.filter(function(item){return data.pending[item.id]}).length<=1
}

function validCard(card) {
    return object(card) && validId(card.id) && typeof card.eligible === "boolean" && validNumber(card.gems) && validNumber(card.bonus)
        && validNumber(card.date) && validNumber(card.wave) && validNumber(card.cleared) && ["death","retired"].includes(card.reason)
        && ["normal","hard","insane"].includes(card.difficulty) && object(card.grades) && object(card.points) && object(card.stats)
        && ["skill","finance","survival","overall"].every(function(axis) {return validGrade(card.grades[axis]) && validNumber(card.points[axis])})
        && Object.values(card.stats).every(validNumber)
}

function decode(data) {
    if (!object(data) || !validTerms(data) || !Number.isSafeInteger(data.gems) || data.gems<0 || !object(data.started) || !object(data.settled)
        || !Object.keys(data.started).every(function(id){return validId(id) && validTerms(data.started[id])})
        || !Object.keys(data.settled).every(function(id){return validId(id) && validGrade(data.settled[id])})
        || !(data.best===null || validCard(data.best)) || !(data.last===null || validCard(data.last))
        || !Array.isArray(data.archive) || data.archive.length>40 || !data.archive.every(validCard)
        || (data.earned!==undefined && (!Number.isSafeInteger(data.earned) || data.earned<0))
        || (data.purchases!==undefined && (!Number.isSafeInteger(data.purchases) || data.purchases<0))
        || (data.reading!=null && !validReading(data.reading))
        || (data.sale!==undefined && !validSale(data.sale))
        || (data.field!==undefined && (!object(data.field) || !Object.keys(data.field).every(function(id) {
            return validId(id) && !data.settled[id] && validField(data.field[id])
        })))) return null
    if (data.closed===undefined) data.closed={}
    if (!object(data.closed) || !Object.keys(data.closed).every(function(id){return validId(id) && data.closed[id]===true})) return null
    if (data.earned===undefined) data.earned=Math.max(data.gems,data.last?.gems || 0)
    if (data.purchases===undefined) data.purchases=Object.values(data.ranks).reduce(function(sum,rank){return sum+rank},0)+Object.keys(data.pending).length
    if (data.reading===undefined) data.reading=null
    if (data.sale===undefined) data.sale={discount:0,free:""}
    if (data.field===undefined) data.field={}
    if (data.receipts===undefined) migrateReceipts(data)
    if (!object(data.receipts) || !object(data.legacyReceipts)
        || !Object.keys(data.receipts).every(function(id) {
            const amounts=data.receipts[id]
            return known(id,vows) && Array.isArray(amounts) && amounts.length<=level(data,id)
                && amounts.every(function(amount){return Number.isSafeInteger(amount) && amount>=0})
        }) || !Object.keys(data.legacyReceipts).every(function(id) {
            return known(id,vows) && Number.isInteger(data.legacyReceipts[id])
                && data.legacyReceipts[id]>=0 && data.legacyReceipts[id]<=level(data,id)
        })) return null
    for (const id of Object.keys(data.settled)) {
        if (familyOf(data.settled[id])==="F") data.settled[id]="F"
    }
    for (const card of [data.best,data.last].concat(data.archive)) {
        if (!card) continue
        for (const axis of Object.keys(card.grades))
            if (familyOf(card.grades[axis])==="F") card.grades[axis]="F"
    }
    return data
}

// Old ledgers saved balances and ranks, but did not store discounts per purchase.
// Allocate at most the recorded net spend across the former catalogue prices.
function migrateReceipts(data) {
    const oldPrices={weapon:[5,1.078],health:[6,1.086],duration:[31,1.23],recovery:[36,1.19],passive:[24,1.20],
        shield:[46,1.32],parry:[76,1.46],rerolls:[45,2.04],freezeStock:[125,1]}
    data.receipts={}
    data.legacyReceipts={}
    let total=0
    for (const vow of vows) {
        const rank=level(data,vow.id)
        if (!rank) continue
        data.legacyReceipts[vow.id]=rank
        const amounts=[]
        for (let i=0;i<rank;i++) {
            const price=vow.id==="barrier" ? [145,395,960][i] : Math.ceil(oldPrices[vow.id][0]*Math.pow(oldPrices[vow.id][1],i))
            amounts.push(price)
            total+=price
        }
        data.receipts[vow.id]=amounts
    }
    const ratio=total ? clamp((data.earned-data.gems)/total) : 0
    for (const id of Object.keys(data.receipts))
        data.receipts[id]=data.receipts[id].map(function(amount){return Math.floor(amount*ratio)})
}

function validReading(hand) {
    return object(hand) && Array.isArray(hand.cards) && hand.cards.length===5 && new Set(hand.cards).size===5
        && hand.cards.every(function(id){return typeof id==="string" && !!Tarot.card(id)})
        && (hand.chosen==="" || hand.cards.includes(hand.chosen))
}

function validSale(sale) {
    return object(sale) && [0,10,20,50].includes(sale.discount) && (sale.free==="" || known(sale.free,offers))
}
function read(value) {
    try {return decode(JSON.parse(value)) || fresh()}
    catch (error) {return fresh()}
}
