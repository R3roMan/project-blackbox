.pragma library
.import "Encounters.js" as Mission
.import "Elements.js" as Elements
.import "Ship.js" as Ship

function actor(type) {
    const spec = Mission.enemyTypes[type]
    const enemy = {
        id:1,type:type,front:"front",lane:0,depth:0,hp:1,maxHp:1,age:0,attack:999,attackFlash:0,
        warp:0,warpDuration:1,warpKind:"",waitingBoss:false,flash:0,roar:0,shatter:0,
        barrier:0,anger:false,diagonal:0,generation:0,eyeCount:8,eyesTime:0,
        driftHeight:0,dodgeOffset:0,dodgeLift:0,dodgeAge:0,dodgeLaneGoal:0,fuse:type === "seraphijus" ? 15 : 0,
        wreck:0,recover:0,feed:null,feedYaw:0,feedingHeal:0,beamWarning:0,beamLeft:0,
        lureOff:1,special:null,elements:Elements.fresh(),soulChannel:false,soulWarm:999,
        illusionForm:0,gravityLift:0,sniperHeight:0,triadHeight:0,lateral:0,scareUsed:false
    }
    if (spec.ship)
        enemy.turrets = Ship.arm(1,function() { return 0 })
    return enemy
}

function known(type, discoveries) {
    return discoveries.includes(type)
}

function placements(groups, seed, boss) {
    const spots = boss ? [[.29,.34],[.71,.36],[.25,.67],[.75,.68],[.42,.75],[.59,.72],[.15,.47],[.86,.51]]
        : [[.30,.29],[.53,.54],[.73,.27],[.23,.65],[.49,.20],[.74,.65],[.40,.66],[.64,.40]]
    let state = (seed^0x54e129cd) >>> 0
    function random() {
        state=(Math.imul(state,1664525)+1013904223) >>> 0
        return state/4294967296
    }
    const order = groups.map(function(group,index) {return index}).sort(function(a,b) {
        return Mission.enemyTypes[groups[b].type].size-Mission.enemyTypes[groups[a].type].size
    })
    const placed = Array(groups.length)
    for (let i=0; i<order.length; ++i) {
        const base=spots[i%spots.length]
        placed[order[i]]={x:base[0]+(random()-.5)*.04,y:base[1]+(random()-.5)*.055}
    }
    return placed
}

function radius(groups, positions, aspect) {
    return groups.reduce(function(bound,group,index) {
        const spot=positions[index] || {x:.5,y:.5}
        const size=Mission.enemyTypes[group.type].size
        return Math.max(bound,180*size/(1-2*Math.abs(spot.y-.5)),132*size/Math.max(.01,aspect)/(1-2*Math.abs(spot.x-.5)))
    },155)
}

function tooltip(group, discoveries) {
    const spec = Mission.enemyTypes[group.type]
    if (!spec)
        return ""
    const seen = known(group.type,discoveries)
    return (seen ? spec.title : "Unknown") + "\n" + spec.origin + " · " + Mission.tier(group.type)
        + (seen ? "\n" + spec.description : "")
}
