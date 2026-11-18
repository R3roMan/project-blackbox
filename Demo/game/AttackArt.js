.pragma library
.import "Encounters.js" as Encounters

// Each pose supplies pitch, roll, forward travel, jaw extension and a wing/arm stroke.
var poses = {
    chomp:[24,0,20,.35,16], lunge:[-28,-19,39,.25,19], roar:[-35,0,8,.49,-32],
    bolt:[-12,8,7,.06,1], doubleBolt:[16,-10,15,.12,12], sweep:[3,31,8,.06,45],
    rush:[19,-39,51,.32,-51], flutter:[-7,19,12,.06,38], headbutt:[49,4,48,.26,-10],
    spin:[25,80,19,.17,18], broodBeam:[-20,3,2,.25,-13], jawSnap:[20,-7,23,.46,8],
    tongue:[-8,15,6,.24,20], fireBreath:[13,0,20,.35,-19], spike:[41,-30,29,.11,-5],
    cryoRay:[12,6,12,.04,25], tendrils:[-16,8,4,.06,63], voidLash:[-28,-23,34,.07,45],
    impact:[38,22,22,.05,-10], armClap:[-13,0,19,.16,58], stoneHands:[8,0,14,.03,20],
    trident:[14,6,78,.11,-26], hexPuff:[-30,-44,4,.31,22], strafingBolt:[16,52,14,.04,17],
    cannon:[-5,0,12,.05,0], claws:[25,-41,26,.17,43], iceFist:[37,28,25,.15,-31],
    detonate:[-7,0,3,.10,45], poisonBreath:[-19,-5,12,.47,-26], slimeSpit:[28,13,26,.31,19],
    executioner:[44,-31,37,.14,64], magnetBolt:[-23,17,13,.08,-36], snakeLightning:[-18,13,24,.42,0],
    rifleLock:[-6,-5,15,.04,-8], feedingBite:[24,-7,22,.51,-10], fracture:[-17,22,14,.16,47],
    bloodSpit:[-18,-8,18,.23,22],soulCry:[-21,4,6,.53,-19],invertedBite:[-32,22,46,.39,26]
}

function pose(enemy) {
    return poses[Encounters.attackStyles[enemy.type]] || poses.chomp
}

function amount(enemy, warning, animate) {
    const flash = Math.max(0, Math.min(1, (enemy.attackFlash || 0) / (enemy.type==="lucifoverus" ? .22 : .33)))
    if (!animate)
        return flash > 0 || warning ? .8 : 0
    if (flash)
        return Math.sin(Math.PI * Math.pow(1 - flash, .45)) * .69 + flash * .57
    if (enemy.roar)
        return Math.min(1, enemy.roar * 1.5)
    if (warning)
        return -Math.min(.62, Math.max(.12, .62 - enemy.attack * .23))
    if (enemy.fuse > 0 && enemy.fuse < 3)
        return Math.sin(enemy.age * 18) * (3 - enemy.fuse) * .17
    return 0
}

// Shared seven-segment face for Seraphijus's chest plate.
var segments = [
    [0,-1,.75,.14], [.43,-.51,.14,.81], [.43,.51,.14,.81],
    [0,1,.75,.14], [-.43,.51,.14,.81], [-.43,-.51,.14,.81], [0,0,.75,.14]
]
var digitMasks = [63,6,91,79,102,109,125,7,127,111]

function countdownSegment(seconds, index) {
    const time = Math.max(0, Math.min(99, Math.ceil(seconds)))
    const digit = index < 7 ? Math.floor(time / 10) : time % 10
    return !!(digitMasks[digit] & (1 << (index % 7)))
}
