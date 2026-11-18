.pragma library

var emitters = [
    { id:"ice", baseLane:-238, baseHeight:-151, tint:"#5be4ff", element:"freeze", elementLevel:3, damage:.42 },
    { id:"spark", baseLane:0, baseHeight:-184, tint:"#bf83ff", element:"electric", elementLevel:3, damage:.57 },
    { id:"fire", baseLane:238, baseHeight:-151, tint:"#ff6a41", element:"burn", elementLevel:3, damage:.64, blast:true }
]

function arm(health, nextId) {
    return emitters.map(function(spec) {
        return Object.assign({}, spec, { targetId:nextId(), hp:health * .30, maximum:health * .30, flash:0,
            lane:spec.baseLane,height:spec.baseHeight })
    })
}

function sway(ship) {
    for (let i=0; i<ship.turrets.length; ++i) {
        const tube = ship.turrets[i]
        const phase = ship.age+i*1.9
        tube.lane = tube.baseLane + Math.sin(phase*1.29)*(i === 1 ? 47 : 64)
        tube.height = tube.baseHeight + Math.sin(phase*1.83)*37
    }
}

function remaining(ship) {
    return ship.turrets.filter(function(turret) { return turret.hp > 0 })
}

function frequency(ship) {
    const active = remaining(ship).length
    return active === 3 ? 3.75 : active === 2 ? 2.48 : active === 1 ? 1.34 : 2.65
}

function turretAt(run, id) {
    const boss = run.enemies.find(function(enemy) { return enemy.type === "hasasasa" && enemy.hp > 0 && !enemy.warp })
    if (!boss)
        return null
    const part = boss.turrets.find(function(turret) { return turret.targetId === id && turret.hp > 0 })
    return part ? { boss:boss, part:part } : null
}
