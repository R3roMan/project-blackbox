.pragma library

var sights = {
    post:     { label:"Iron sight",  zoom:1.31, focus:.67 },
    dot:      { label:"Reflex",      zoom:1.44, focus:.57 },
    buck:     { label:"Spread sight",zoom:1.27, focus:.60 },
    survey:   { label:"Rangefinder", zoom:1.93, focus:.48 },
    marksman: { label:"Marksman",    zoom:2.55, focus:.34 },
    beam:     { label:"Beam sight",  zoom:1.84, focus:.50 },
    arc:      { label:"Focus rune",  zoom:1.58, focus:.58 },
    melee:    { label:"Strike sight",zoom:1.25, focus:.70 },
    cryo:     {label:"Ice lattice",zoom:1.78,focus:.46},
    thermal:  {label:"Heat gauge",zoom:1.64,focus:.49},
    voltage:  {label:"Arc voltmeter",zoom:1.72,focus:.48},
    eclipse:  {label:"Eclipse lens",zoom:2.04,focus:.43},
    compass:  {label:"Wind compass",zoom:1.62,focus:.53},
    fault:    {label:"Seismic rune",zoom:1.54,focus:.55},
    prism:    {label:"Prismatic iris",zoom:1.68,focus:.50},
    ledger:   {label:"Gilded duplex",zoom:1.89,focus:.43},
    oath:     {label:"Oath diamond",zoom:3.15,focus:.31}
}
var personalSights = {kingsRansom:"ledger",stillwater:"oath",blackHole:"eclipse",nightInk:"eclipse",jesterScatter:"prism"}
var staffSights = {burn:"thermal",freeze:"cryo",stun:"fault",poison:"eclipse",wind:"compass",earth:"fault",fire:"thermal",ice:"cryo",electric:"voltage",avatar:"prism",void:"eclipse"}

function optic(weapon) {
    const pattern = weapon.art || weapon.id
    const marksman = !!weapon.scopeZoom || ["redline","deadeye","harrier","rail","lance"].includes(pattern)
    const style = personalSights[weapon.id] || (weapon.staff ? staffSights[weapon.staff.kind] || "arc" : "")
        || (weapon.melee || weapon.throwing ? "melee"
        : weapon.effect === "spread" ? "buck" : marksman ? "marksman"
        : weapon.element === "freeze" ? "cryo" : weapon.element === "electric" ? "voltage"
        : weapon.element === "burn" && weapon.sustain ? "thermal"
        : weapon.blast || weapon.chargeEachShot || weapon.marksman ? "survey"
        : ["laser","beam"].includes(weapon.effect) ? "beam"
        : weapon.burst || weapon.spinup || ["tracer","pulse"].includes(weapon.effect) ? "dot" : "post")
    const base = sights[style]
    const key = Array.from(weapon.id).reduce(function(seed,letter) { return seed + letter.charCodeAt(0) },0)
    return { style:style,label:base.label,zoom:weapon.scopeZoom || base.zoom + (key % 5)*.055, focus:base.focus,ticks:3 + key % 5 }
}

function project(width, height, lane, elevation, depth, centre, zoom) {
    const scale = height / (2 * Math.tan(28 * Math.PI / 180) * Math.max(45,depth))
    return { x:width*centre.x + (width*(.5-centre.x) + lane*scale)*zoom,
        y:height*centre.y + (height*(.5-centre.y) - elevation*scale)*zoom, scale:scale*zoom }
}
