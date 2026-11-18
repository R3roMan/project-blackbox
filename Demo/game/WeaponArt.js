.pragma library

// Width, height and length are measured in model units. Recoil and reload travel
// describe the moving parts for each individual gun.
var designs = {
    pistol:     { form:"slide", shell:"#566074", width:49, height:43, length:85, barrel:73, bore:8, vents:3, kick:14, lift:6, tilt:5, drop:69, turn:22 },
    scattergun: { form:"pump", shell:"#786053", width:64, height:40, length:111, barrel:137, bore:10, vents:4, kick:27, lift:9, tilt:-6, drop:47, turn:28 },
    carbine:    { form:"box", shell:"#536851", width:60, height:49, length:129, barrel:109, bore:6, vents:5, kick:13, lift:4, tilt:3, drop:83, turn:30 },
    rail:       { form:"rail", shell:"#4e6687", width:58, height:43, length:117, barrel:155, bore:8, vents:6, kick:15, lift:3, tilt:-3, drop:61, turn:-29 },
    riot:       { form:"pump", shell:"#697764", width:77, height:49, length:131, barrel:116, bore:13, vents:7, kick:31, lift:12, tilt:7, drop:59, turn:-33 },
    ion:        { form:"cell", shell:"#3e747c", width:63, height:43, length:97, barrel:76, bore:8, vents:7, kick:8, lift:3, tilt:2, drop:74, turn:25 },
    hellbore:   { form:"break", shell:"#884b55", width:89, height:45, length:103, barrel:144, bore:13, vents:3, kick:36, lift:14, tilt:9, drop:49, turn:35 },
    arc:        { form:"split", shell:"#66518a", width:75, height:49, length:118, barrel:105, bore:7, vents:5, kick:19, lift:6, tilt:-5, drop:65, turn:-23 },
    lance:      { form:"rail", shell:"#4b659f", width:65, height:36, length:133, barrel:151, bore:11, vents:8, kick:16, lift:4, tilt:4, drop:64, turn:18 },
    solar:      { form:"dish", shell:"#85663e", width:73, height:47, length:119, barrel:135, bore:14, vents:5, kick:4, lift:2, tilt:-2, drop:57, turn:-15 },
    dread:      { form:"cylinder", shell:"#704d45", width:95, height:63, length:135, barrel:116, bore:20, vents:3, kick:42, lift:14, tilt:-8, drop:79, turn:-34 },
    crucible:   { form:"cell", shell:"#80507a", width:85, height:60, length:127, barrel:109, bore:10, vents:8, kick:20, lift:5, tilt:6, drop:81, turn:26 },
    minigun:    { form:"rotary", shell:"#676371", width:94, height:73, length:123, barrel:149, bore:7, vents:7, kick:9, lift:3, tilt:4, drop:88, turn:21 },
    launcher:   { form:"drum", shell:"#747153", width:106, height:55, length:127, barrel:96, bore:20, vents:4, kick:32, lift:14, tilt:-11, drop:74, turn:-37 },
    breacher:   { form:"break", shell:"#746458", width:74, height:38, length:79, barrel:113, bore:11, vents:2, kick:22, lift:8, tilt:-9, drop:54, turn:-30 },
    volt:       { form:"split", shell:"#4a7973", width:71, height:41, length:112, barrel:88, bore:7, vents:6, kick:11, lift:5, tilt:5, drop:66, turn:32 },
    razor:      { form:"box", shell:"#577a88", width:78, height:47, length:135, barrel:115, bore:6, vents:3, kick:17, lift:5, tilt:-7, drop:84, turn:-17 },
    ember:      { form:"cylinder", shell:"#925844", width:69, height:58, length:107, barrel:105, bore:16, vents:5, kick:23, lift:9, tilt:8, drop:62, turn:27 },
    harrier:    { form:"rail", shell:"#647753", width:58, height:53, length:145, barrel:165, bore:9, vents:9, kick:16, lift:6, tilt:-5, drop:72, turn:-24 },
    prism:      { form:"dish", shell:"#527787", width:83, height:57, length:133, barrel:128, bore:17, vents:7, kick:7, lift:2, tilt:3, drop:50, turn:35 },
    cyclone:    { form:"rotary", shell:"#70568a", width:112, height:80, length:132, barrel:159, bore:8, vents:8, kick:13, lift:6, tilt:-4, drop:94, turn:-25 },
    redline:    { form:"rail", shell:"#625b66", width:53, height:55, length:149, barrel:173, bore:7, vents:5, kick:24, lift:4, tilt:-7, drop:62, turn:29, scope:true },
    tesla:      { form:"split", shell:"#4d405f", width:96, height:63, length:136, barrel:121, bore:10, vents:7, kick:10, lift:4, tilt:10, drop:91, turn:-21 },
    pyre:       { form:"break", shell:"#7d4234", width:88, height:65, length:99, barrel:137, bore:15, vents:8, kick:37, lift:15, tilt:-10, drop:58, turn:39 },
    glacier:    { form:"cell", shell:"#547a9e", width:101, height:59, length:120, barrel:124, bore:13, vents:6, kick:28, lift:10, tilt:8, drop:49, turn:22 },
    shrapnel:   { form:"pump", shell:"#70634e", width:110, height:57, length:116, barrel:153, bore:18, vents:3, kick:41, lift:17, tilt:-3, drop:78, turn:-36 },
    bilecaster: { form:"cell", shell:"#454d2d", width:82, height:51, length:112, barrel:97, bore:16,
        vents:4, kick:16, lift:5, tilt:-8, drop:85, turn:26 },
    furnacebeam: { form:"dish", shell:"#712c33", width:93, height:61, length:124, barrel:112, bore:25,
        vents:9, kick:6, lift:3, tilt:2, drop:0, turn:0 },
    kestrel: { form:"box", shell:"#4a5f4f", width:67, height:46, length:117, barrel:91, bore:7,
        vents:3, kick:12, lift:7, tilt:-4, drop:65, turn:25 },
    deadeye: { form:"rail", shell:"#614f42", width:63, height:43, length:133, barrel:166, bore:8, scope:true,
        vents:4, kick:17, lift:8, tilt:-5, drop:63, turn:-29 },
    twinSmgs:{form:"box",shell:"#45746a",width:51,height:44,length:101,barrel:92,bore:7,vents:6,kick:12,lift:5,tilt:6,drop:62,turn:24},
    rimeBell:{form:"pump",shell:"#467e8d",width:55,height:44,length:119,barrel:103,bore:24,vents:5,kick:30,lift:9,tilt:-7,drop:72,turn:-28},
    furnaceDoor:{form:"pump",shell:"#974027",width:72,height:51,length:101,barrel:89,bore:29,vents:6,kick:43,lift:14,tilt:-11,drop:83,turn:-39},
    twinShotguns:{form:"pump",shell:"#8d5141",width:61,height:48,length:110,barrel:117,bore:17,vents:3,kick:35,lift:10,tilt:-9,drop:79,turn:-34},
    siegeRpg:{form:"cylinder",shell:"#56603a",width:99,height:88,length:169,barrel:184,bore:37,vents:4,kick:39,lift:17,tilt:9,drop:92,turn:23},
    graduate:{form:"slide",shell:"#a8793e",width:50,height:40,length:87,barrel:93,bore:9,vents:2,kick:18,lift:7,tilt:5,drop:54,turn:21},
    twinpistols: { form:"slide", shell:"#7a706f", width:47, height:41, length:85, barrel:75, bore:7,
        vents:4, kick:20, lift:6, tilt:5, drop:58, turn:18 },
    blackHole: { form:"dish", shell:"#413050", width:111, height:54, length:99, barrel:94, bore:24,
        vents:8, kick:13, lift:5, tilt:-8, drop:57, turn:34 },
    breakwater: { form:"rail",shell:"#66646a",width:70,height:61,length:149,barrel:193,bore:14,
        vents:4,kick:36,lift:9,tilt:9,drop:83,turn:-29,scope:true },
    nightInk: { form:"cell",shell:"#3d264c",width:85,height:63,length:116,barrel:121,bore:15,
        vents:8,kick:16,lift:6,tilt:-7,drop:57,turn:32 },
    echosix: { form:"cylinder",shell:"#566572",width:54,height:42,length:76,barrel:81,bore:10,
        vents:3,kick:19,lift:10,tilt:8,drop:75,turn:39 },
    riftScatter: { form:"pump",shell:"#46645d",width:82,height:47,length:132,barrel:148,bore:13,
        vents:5,kick:29,lift:8,tilt:9,drop:58,turn:-19 },
    siltCarbine: { form:"box",shell:"#426450",width:68,height:55,length:122,barrel:104,bore:8,
        vents:6,kick:11,lift:4,tilt:3,drop:72,turn:27 },
    rimeRelay: { form:"split",shell:"#3e7791",width:75,height:53,length:121,barrel:128,bore:13,
        vents:6,kick:13,lift:4,tilt:-4,drop:80,turn:32 },
    whiteoutCoil: { form:"dish",shell:"#546d86",width:106,height:62,length:106,barrel:110,bore:17,
        vents:9,kick:5,lift:2,tilt:-2,drop:0,turn:0 },
    jesterScatter:{form:"split",shell:"#603c70",width:94,height:63,length:110,barrel:134,bore:12,
        vents:7,kick:25,lift:8,tilt:-6,drop:76,turn:39},
    kingsRansom:{form:"slide",shell:"#b68a28",width:53,height:43,length:91,barrel:102,bore:11,
        vents:6,kick:27,lift:10,tilt:9,drop:74,turn:33},
    stillwater:{form:"rail",shell:"#b7c8c3",width:65,height:49,length:145,barrel:178,bore:9,
        vents:5,kick:20,lift:6,tilt:-4,drop:62,turn:-28,scope:true},
    starDestroyer: { form:"dish", shell:"#986521", width:98, height:58, length:111, barrel:128, bore:17,
        vents:8, kick:24, lift:9, tilt:7, drop:52, turn:13 },
    starDestroyerPlus: { form:"dish", shell:"#d39c31", width:105, height:63, length:117, barrel:137, bore:19,
        vents:10, kick:30, lift:12, tilt:8, drop:51, turn:16 }
}

function design(weapon) {
    const base = designs[weapon.art || weapon.id] || designs.pistol
    if (!weapon.frame)
        return base
    const model = weapon.frame
    return Object.assign({},base,{
        shell:Qt.darker(weapon.color,2.45),
        width:base.width + (model % 5 - 2) * 6,
        height:base.height + (model % 7 - 3) * 3,
        length:base.length + (model % 4 - 1.5) * 11,
        barrel:base.barrel + (model % 6 - 2.5) * 8,
        bore:base.bore + model % 4,
        vents:3 + model % 7,
        kick:base.kick * (.83 + model % 7*.071),
        turn:base.turn + (model % 8 - 3.5) * 4,
        drop:base.drop + (model % 5 - 2) * 9,
        scope:base.scope || model % 7 === 0
    })
}

function pose(spec, shot, reload, spinAngle) {
    const opening = reload > 0 ? Math.sin(Math.PI * reload) : 0
    const kick = Math.pow(Math.max(0, shot), spec.form === "cell" ? 1.4 : 2.65)
    const pump = spec.form === "pump" ? 35 * Math.sin(Math.PI * Math.min(1, shot * 1.20)) : 0
    const hinge = spec.form === "break" ? opening * 48 : 0
    return {
        rise: kick * spec.lift - opening * 21,
        rear: kick * spec.kick,
        roll: kick * spec.tilt + opening * spec.turn,
        pitch: -kick * spec.lift + opening * (spec.form === "rotary" ? 19 : 10),
        partTravel: pump + (spec.form === "slide" ? kick * 24 : 0),
        shellTravel: opening * spec.drop,
        hinge: hinge,
        spin: spinAngle
    }
}
