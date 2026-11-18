.pragma library

function motion(piece, side, animated) {
    const age = 1 - piece.life / piece.duration
    const drift = Math.min(1,age*2)
    const plasma = piece.blade === "darksaber" || piece.blade === "emberslash"
    const cut = piece.blade === "katana" ? 31 : plasma ? -22 : -5
    const strength = piece.blade === "chainsaw" ? 1.23 : 1
    return {cut:cut,offset:side*(17 + 123*drift)*strength,
        rise:24*Math.sin(age*Math.PI) - 120*age*age,
        yaw:animated ? side*98*age : 0,roll:animated ? -side*113*age : 0,
        alpha:Math.min(1,piece.life/.40), seam:plasma ? "#ff77df" : piece.blade === "chainsaw" ? "#bd223c" : "#e33b52"}
}

function hemisphere(cap) {
    const positions = []
    const normals = []
    const indexes = []
    if (cap) {
        positions.push(Qt.vector3d(-.10,0,0))
        normals.push(Qt.vector3d(-1,0,0))
        for (let i = 0; i <= 20; ++i) {
            const angle = i * Math.PI/10
            positions.push(Qt.vector3d(-.10,Math.cos(angle)*50,Math.sin(angle)*50))
            normals.push(Qt.vector3d(-1,0,0))
            if (i)
                indexes.push(0,i+1,i)
        }
    } else {
        for (let y = 0; y <= 12; ++y) {
            const latitude = Math.PI*(y/12-.5)
            for (let x = 0; x <= 12; ++x) {
                const longitude = Math.PI*(x/12-.5)
                const a = Math.cos(latitude)*Math.cos(longitude)
                const b = Math.sin(latitude)
                const c = Math.cos(latitude)*Math.sin(longitude)
                positions.push(Qt.vector3d(50*a,50*b,50*c))
                normals.push(Qt.vector3d(a,b,c))
                if (x < 12 && y < 12) {
                    const first = x+13*y
                    indexes.push(first,first+13,first+1,first+1,first+13,first+14)
                }
            }
        }
    }
    return {positions:positions,normals:normals,indexes:indexes}
}

function wing() {
    return {
        positions:[Qt.vector3d(21,26,3),Qt.vector3d(69,46,-16),Qt.vector3d(127,62,-27),
            Qt.vector3d(100,-22,-25),Qt.vector3d(74,-12,-11),Qt.vector3d(58,-37,-7),Qt.vector3d(24,-13,3)],
        indexes:[0,1,6,1,2,4,2,3,4,1,4,6,4,5,6],
        normals:Array(7).fill(Qt.vector3d(.11,.15,.98))
    }
}
