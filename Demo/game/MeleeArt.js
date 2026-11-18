.pragma library

function part(mesh, x, y, z, width, height, length, material, pitch, yaw, roll) {
    return { mesh:"#"+mesh, x:x,y:y,z:z, width:width,height:height,length:length,
        material:material,pitch:pitch || 0,yaw:yaw || 0,roll:roll || 0 }
}

function handle(length, material) {
    return part("Cylinder", 0,0,9,19,length,19,material,90)
}

var parts = {
    zeroHour:[
        handle(112,"dark"),
        part("Cylinder",0,0,69,24,13,24,"bronze",90),
        part("Cube",0,0,-44,97,14,17,"bronze"),
        part("Cone",-42,0,-57,19,52,18,"accent",0,0,-50),
        part("Cone",42,0,-57,19,52,18,"accent",0,0,50),
        part("Cube",0,0,-162,40,12,235,"metal"),
        part("Cube",-20,0,-165,6,10,228,"accent"),
        part("Cube",20,0,-165,6,10,228,"accent"),
        part("Cube",0,6,-169,7,1,196,"dark"),
        part("Cone",0,0,-284,41,45,13,"accent",-90)
    ],
    nailclub:[
        handle(124,"wood"),
        part("Cylinder", 0,0,-72,37,124,37,"wood",90),
        part("Cylinder", 0,0,-101,41,15,41,"dark",90),
        part("Cylinder", 0,0,-53,40,14,40,"dark",90),
        part("Cylinder", 0,0,64,26,12,26,"metal",90)
    ],
    katana:[
        handle(78,"wrap"),
        part("Cube", 0,0,-34,49,17,9,"bronze"),
        part("Cube", 0,0,-42,24,10,11,"bronze"),
        part("Cylinder", 0,0,50,22,7,22,"bronze",90)
    ],
    mechasword:[
        handle(80,"dark"),
        part("Cube", 0,0,-35,67,20,40,"metal"),
        part("Cube", 0,0,-90,41,14,92,"dark"),
        part("Cube", 0,0,-148,32,10,146,"metal"),
        part("Cube", -15,0,-148,5,15,147,"accent"),
        part("Cube", 15,0,-148,5,15,147,"accent"),
        part("Cube", 0,5.5,-152,5,1,144,"white"),
        part("Cone", 0,0,-228,26,28,10,"white",-90)
    ],
    duoknives:[
        handle(68,"wrap"),
        part("Cube", 0,0,-29,27,9,8,"bronze"),
        part("Cube", 2,0,-63,19,5,66,"metal",0,-7),
        part("Cone", 9,0,-102,19,29,5,"white",-90,-12),
        part("Cube", -6,1,-61,3,5,58,"white",0,-7),
        part("Cube", 0,0,49,17,8,10,"dark")
    ],
    darksaber:[
        handle(85,"dark"),
        part("Cylinder", 0,0,-33,33,17,29,"metal",90),
        part("Cylinder", 0,0,-49,29,9,25,"accent",90),
        part("Cube", 0,0,-145,23,8,195,"accent"),
        part("Cube", 0,0,-145,15,10,184,"shadow"),
        part("Cone", 0,0,-253,20,27,8,"accent",-90)
    ],
    chainsaw:[
        part("Cube", 0,0,1,72,53,79,"red"),
        part("Cube", 0,20,10,80,18,57,"dark"),
        part("Cube", 0,0,-117,55,14,204,"dark"),
        part("Cube", 0,8,-117,40,6,188,"metal"),
        part("Cylinder", 0,0,-211,50,14,50,"metal"),
        part("Cube", -38,-8,-7,10,45,75,"dark"),
        part("Cube", 38,-8,-7,10,45,75,"dark"),
        part("Cube", 0,-27,35,44,16,26,"wrap"),
        part("Cube", 0,27,21,11,4,22,"accent")
    ],
    tomahawk:[
        handle(123,"wood"),
        part("Cylinder", 0,0,38,23,49,23,"wrap",90),
        part("Cylinder", 0,0,-60,24,18,24,"bronze",90),
        part("Cube", 0,0,-72,85,12,36,"dark"),
        part("Cube", -37,1,-76,31,16,56,"metal",0,-13),
        part("Cube", -51,2,-74,9,13,57,"white",0,7),
        part("Cone", 55,0,-72,28,22,13,"metal",90,0,-90)
    ],
    gravhammer:[
        handle(148,"wrap"),
        part("Cube", 0,0,-76,123,38,52,"dark"),
        part("Cube", -54,0,-76,20,50,64,"metal"),
        part("Cube", 54,0,-76,20,50,64,"metal"),
        part("Cube", 0,19,-76,75,7,25,"accent"),
        part("Cone", 0,0,-121,34,42,29,"metal",-90)
    ],
    reaperscythe:[
        handle(216,"dark"),
        part("Cylinder", 0,0,-105,32,39,32,"bronze",90),
        part("Cube", 32,0,-129,76,9,34,"metal",0,-28),
        part("Cube", 77,0,-122,57,9,26,"dark",0,29),
        part("Cone", 112,0,-96,20,61,9,"metal",-90,134),
        part("Cube", 38,1,-139,90,9,5,"accent",0,-20)
    ],
    helltrident:[
        handle(242,"dark"),
        part("Cylinder", 0,0,-110,26,39,26,"bronze",90),
        part("Cube", 0,0,-131,71,12,21,"dark"),
        part("Cone", 0,0,-169,17,71,15,"metal",-90),
        part("Cone", -27,0,-158,14,53,12,"bronze",-90,-12),
        part("Cone", 27,0,-158,14,53,12,"bronze",-90,12),
        part("Cube", 0,5,-145,8,6,69,"accent"),
        part("Cube", 25,3,-148,5,6,41,"accent"),
        part("Cube", -25,3,-148,5,6,41,"accent")
    ],
    breakerGlaive:[
        handle(218,"dark"), part("Cylinder",0,0,-76,31,22,31,"bronze",90),
        part("Cube",0,0,-145,34,8,130,"metal",0,5),
        part("Cube",15,0,-153,8,10,126,"white",0,5),
        part("Cone",3,0,-212,30,47,9,"white",-90,4),
        part("Cube",-13,4,-154,5,1.5,109,"accent"),
        part("Cylinder",0,0,106,21,27,21,"wrap",90)
    ],
    fearScythe:[
        handle(249,"dark"),
        part("Cylinder",0,0,-102,34,63,34,"metal",90),
        part("Cube",31,0,-139,92,12,25,"shadow",0,-24),
        part("Cube",89,0,-161,81,8,29,"metal",0,-11),
        part("Cube",122,0,-158,61,8,21,"accent",0,16),
        part("Cone",148,0,-134,19,70,10,"white",-90,138),
        part("Cone",27,7,-169,12,37,15,"accent",-90,12),
        part("Cylinder",0,0,114,24,19,23,"red",90)
    ]
}

function katanaBlade(bevel) {
    const profile = [
        [-36,0,17.8,6.2],[-91,1.8,17.8,6.1],[-159,5.7,17.4,5.8],[-223,11.1,16.5,5.1],
        [-270,17.6,15.6,4.6],[-299,22.8,12.9,3.9],[-314,27.6,5.2,2.1],[-323,31.4,.35,.23]
    ]
    const crossSection = [[-.52,0],[-.29,.43],[.32,.52],[.48,.29],[.48,-.29],[.32,-.52],[-.29,-.43]]
    const rings = profile.map(function(section) {
        const [depth,centre,width,height] = section
        return crossSection.map(function(vertex) {
            return Qt.vector3d(centre+vertex[0]*width,vertex[1]*height,depth)
        })
    })
    const positions = []
    const normals = []
    const indexes = []
    for (let ring=0; ring<rings.length-1; ++ring) {
        const near = rings[ring]
        const far = rings[ring+1]
        for (let i=0; i<crossSection.length; ++i) {
            const edge = i===0 || i===crossSection.length-1
            if (edge !== bevel)
                continue
            const next = (i+1)%crossSection.length
            const normal = near[next].minus(near[i]).crossProduct(far[i].minus(near[i])).normalized()
            const n = positions.length
            positions.push(near[i],near[next],far[next],far[i])
            normals.push(normal,normal,normal,normal)
            indexes.push(n,n+1,n+2,n,n+2,n+3)
        }
    }
    return {positions:positions,normals:normals,indexes:indexes}
}

// The trick pivot bisects the whole weapon. The idle position lines up each grip
// near the same part of the screen regardless of blade length.
var frames = {
    zeroHour:{centre:-108,scale:1,tip:-304,lean:14,wheel:-360,lift:32,turn:23,swing:93},
    nailclub:{centre:-35, scale:1.23, tip:-135, lean:-18, wheel:360, lift:20, turn:12, swing:52},
    katana:{centre:-132, scale:1, tip:-325, lean:14, wheel:360, lift:-14, turn:26, swing:65},
    mechasword:{centre:-111, scale:1.10, tip:-245, lean:15, wheel:-360, lift:35, turn:-39, swing:54},
    duoknives:{centre:-32, scale:1.23, tip:-118, lean:5, wheel:0, lift:21, turn:0, swing:28},
    darksaber:{centre:-103, scale:1.12, tip:-267, lean:17, wheel:-360, lift:55, turn:29, swing:83},
    chainsaw:{centre:-93, scale:1.12, tip:-237, lean:-13, wheel:0, lift:-36, turn:32, swing:25},
    tomahawk:{centre:-15, scale:1.26, tip:-98, lean:20, wheel:360, lift:25, turn:31, swing:40},
    gravhammer:{centre:-42, scale:1.16, tip:-143, lean:18, wheel:0, lift:-178, turn:25, swing:28},
    reaperscythe:{centre:-15, scale:1.12, tip:-166, lean:20, wheel:360, lift:-23, turn:46, swing:75},
    helltrident:{centre:-51, scale:.96, tip:-207, lean:16, wheel:0, lift:-68, turn:-9, swing:8},
    breakerGlaive:{centre:-59, scale:1, tip:-237, lean:22, wheel:-360, lift:39, turn:14, swing:74},
    fearScythe:{centre:-53,scale:1.05,tip:-193,lean:26,wheel:360,lift:29,turn:61,swing:98}
}

function pose(id, attack, prep, combo, sequence) {
    const frame = frames[id] || frames.katana
    const progress = Math.max(0,Math.min(1,prep))
    const swing = attack > 0 ? Math.sin((1-attack)*Math.PI) : 0
    const crest = Math.sin(progress*Math.PI)
    const finish = id === "katana" && combo === 3 ? swing : 0
    const backhand = id === "katana" && combo === 2 || id === "duoknives" && sequence%2 ? -1 : 1
    const thrust = id === "helltrident" ? crest : swing
    const kick = id === "chainsaw" ? Math.sin(progress*48)*crest : 0
    const roll = frame.lean + frame.wheel*progress - frame.swing*backhand*swing + finish*39
    const gripHeight = -148-frame.centre*frame.scale
    return { x:62-47*crest-53*backhand*swing+6*kick,
        y:gripHeight*(1-crest)+thrust*(id === "helltrident" ? 73 : 18)+finish*23,
        z:-55*thrust+13*kick, pitch:84+frame.lift*crest-33*swing-47*finish,
        yaw:14+frame.turn*crest+backhand*25*swing, roll:roll,
        inner:id === "duoknives" ? progress : crest }
}
