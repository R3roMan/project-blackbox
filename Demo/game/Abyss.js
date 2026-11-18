.pragma library

var sealSeconds = 14

var enemies = {
    tenmani:{
        id:"tenmani",title:"Tenmani",role:"abyss",abyss:true,health:24,damage:22,speed:59,pace:"Low",
        reach:840,interval:9.3,windup:1.65,skin:"#30233e",accent:"#c58ae6",size:1.45,shake:[19,12,.51,63],
        description:"Circles slowly. Watch for its arms to reach out. A caught player is pulled in, disarmed and bitten."
    },
    lantis:{
        id:"lantis",title:"Lantis",role:"abyss",abyss:true,health:44,damage:23,speed:128,pace:"Medium",
        reach:365,interval:4.8,windup:1.30,skin:"#523725",accent:"#ffda72",size:1.72,shake:[17,15,.45,69],
        description:"Its angler lamp is lit for four of every five seconds. Aim away from the lure. If hypnotised, defeat every hallucination to recover your controls."
    },
    shadow:{
        id:"shadow",title:"Shadow",role:"abyss",abyss:true,health:28,damage:29,speed:154,pace:"Medium-high",
        reach:308,interval:4.7,windup:1.25,skin:"#17121d",accent:"#d2b4ff",size:1.27,shake:[18,8,.36,87],
        description:"A knife-wielding shade wearing a floating cape. It telegraphs one long-range ink bolt before closing. An unblocked ink hit stains your view for the wave."
    },
    faeel:{
        id:"faeel",title:"Faeel",role:"abyss",abyss:true,health:38,damage:20,speed:135,pace:"Medium",
        reach:436,interval:5,windup:1.35,dodge:3,electricImmune:true,element:"electric",elementLevel:2,
        skin:"#24392a",accent:"#ecde66",size:1.47,shake:[20,10,.40,100],
        description:"An Electric-immune eel with level 3 Dodge. Its charged bite stuns for two seconds and restarts ability cooldowns. Watch the jaw open before it strikes."
    },
    nightosphere:{
        id:"nightosphere",title:"Nightosphere",role:"abyss",abyss:true,health:75,damage:8,speed:44,pace:"Very low",
        reach:1090,interval:6.9,windup:1.6,immune:true,element:"blind",elementLevel:1,boltTime:1.5,boltHealth:3.8,
        skin:"#27152f",accent:"#ba64da",size:1.47,shake:[6,9,.32,41],
        description:"A black crystal immune to statuses. It hovers sideways at range, fires blinding bolts and summons a Void creature every ten seconds. It shatters on death."
    },
    harvester:{
        id:"harvester",title:"Harvester",role:"abyss",abyss:true,health:62,damage:.62,speed:131,pace:"Medium",
        reach:1050,interval:6.5,windup:1.35,soulDrain:true,
        skin:"#342042",accent:"#e8c4ff",size:1.90,shake:[5,7,.19,59],
        description:"It is borrowing your soul. Push it away and collect the debt."
    },
    endme:{
        id:"endme",title:"Endme",role:"abyss",abyss:true,health:124,damage:15,speed:289,pace:"Extreme",
        reach:347,interval:5,windup:1.28,poisonImmune:true,element:"poison",elementLevel:2,maneuver:true,
        skin:"#171220",accent:"#e58fff",size:1.71,shake:[12,18,.40,71],
        description:"Eight bright eyes track you. Each landed attack closes one. Close all eight to stop its movement and double damage for six seconds. It resists Poison and delivers level 2 Poison."
    },
    fearme:{
        id:"fearme",title:"Fearme",role:"abyss",abyss:true,health:157,damage:0,speed:61,pace:"Very low",
        distance:3260,reach:420,interval:6.5,windup:2.05,earlyArrival:true,
        skin:"#22172e",accent:"#f06dba",size:2.15,shake:[19,24,.64,69],
        description:"A distant reaper with a black scythe. A hit removes half your maximum health for this wave, bypasses shields and barriers, and sends Fearme back into the Void."
    },
    archfellanus:{
        id:"archfellanus",title:"Archfellanus",role:"angel",angel:true,health:61,damage:25,speed:206,pace:"High",
        reach:347,interval:4.1,windup:1.44,skin:"#382130",accent:"#fadc8c",size:1.79,shake:[17,13,.42,67],
        description:"A fallen angel with a torn cape. A gold mirror reflects damage for 4.5 seconds on an eight-second cycle. Pets turn against you while you share its wallpaper."
    },
    reapfast:{
        id:"reapfast",title:"Reapfast Leviathan",role:"boss",abyss:true,leviathan:true,health:378,damage:43,
        speed:0,pace:"Stationary",distance:1750,reach:1750,interval:3.85,windup:1.44,poisonImmune:true,
        skin:"#384452",accent:"#87f5cd",size:4.75,shake:[27,25,.72,53],
        description:"A Poison-immune leviathan with a suction bite, explosive bubbles, a charge and a weakening roar. Below half health it attacks faster and can fire its three breakable fangs. Fangs regrow in 30 seconds."
    },
    hallucination:{
        id:"hallucination",title:"Hallucination",role:"illusion",abyss:true,health:2.2,damage:2.8,speed:118,pace:"Medium",
        reach:720,interval:6.4,windup:.73,skin:"#261130",accent:"#ed86ff",size:.84,shake:[5,5,.21,77],
        description:"An imagined threat from Lantis's lamp. Defeat every shadow to break the hypnosis."
    }
}

var introductions = [
    {wave:16,type:"tenmani",front:"down",weight:.90,heavy:true,rare:true},
    {wave:25,type:"lantis",front:"down",weight:.71,heavy:true,rare:true},
    {wave:38,type:"shadow",front:"down",weight:.83,heavy:true,rare:true},
    {wave:44,type:"harvester",front:"down",weight:.66,heavy:true,rare:true},
    {wave:49,type:"faeel",front:"down",weight:.64,heavy:true,rare:true},
    {wave:58,type:"nightosphere",front:"down",weight:.49,heavy:true,rare:true},
    {wave:64,type:"archfellanus",front:"left",weight:.63,heavy:true,rare:true},
    {wave:66,type:"endme",front:"down",weight:.45,heavy:true,rare:true},
    {wave:73,type:"fearme",front:"down",weight:.42,heavy:true,rare:true}
]

var attacks = [
    {id:"suction", title:"Suction bite", span:4, warning:1.05},
    {id:"bubbles", title:"Explosive bubbles", span:2.6, warning:.96},
    {id:"charge", title:"Charge", span:2.25, warning:1.05},
    {id:"roar", title:"Call of the deep", span:2.9, warning:1.14},
    {id:"fangs", title:"Fang volley", span:2.45, warning:1.3, enraged:true}
]

function startsFromPool(spec) {
    return spec.abyss && spec.role !== "illusion" && !spec.leviathan
}

function lampCycle(age) {
    return age < 5 || (age-5)%5 >= 4 ? -1 : Math.floor((age-5)/5)
}

function mirror(age) {
    return age >= 8 && age%8 < 4.5
}

function phase(attack) {
    return attack ? Math.min(1,attack.time/attack.span) : 0
}
