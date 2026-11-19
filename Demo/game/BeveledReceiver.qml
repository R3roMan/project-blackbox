import QtQuick
import QtQuick3D.Helpers

ProceduralMesh {
    // The control surfaces of the gun keep the original 100-unit cube
    // footprint. A short bevel takes the light without blunting the profile.
    readonly property var mesh:{
        const p=[],n=[],t=[],b=[],uv=[],triangles=[]
        const axis=[Qt.vector3d(1,0,0),Qt.vector3d(0,1,0),Qt.vector3d(0,0,1)]
        const edge=43, radius=7
        const grid=[-50,-46,-edge,edge,46,50]
        for (let side=0;side<3;side++) {
            const up=axis[(side+2)%3]
            for (const sign of [-1,1]) {
                const right=axis[(side+1)%3].times(sign)
                const face=axis[side].times(sign*50)
                const start=p.length
                for (const y of grid) {
                    for (const x of grid) {
                        const point=face.plus(right.times(x)).plus(up.times(y))
                        const centre=Qt.vector3d(Math.min(edge,Math.max(-edge,point.x)),
                            Math.min(edge,Math.max(-edge,point.y)),Math.min(edge,Math.max(-edge,point.z)))
                        const normal=point.minus(centre).normalized()
                        const tangent=right.minus(normal.times(right.dotProduct(normal))).normalized()
                        p.push(centre.plus(normal.times(radius)))
                        n.push(normal)
                        t.push(tangent)
                        b.push(normal.crossProduct(tangent))
                        uv.push(Qt.vector2d(.5+x/100,.5+y/100))
                    }
                }
                const stride=grid.length
                for (let row=0;row<stride-1;row++) {
                    for (let col=0;col<stride-1;col++) {
                        const index=start+row*stride+col
                        triangles.push(index,index+1,index+stride,index+1,index+stride+1,index+stride)
                    }
                }
            }
        }
        return {p:p,n:n,t:t,b:b,uv:uv,triangles:triangles}
    }
    positions:mesh.p
    normals:mesh.n
    tangents:mesh.t
    binormals:mesh.b
    uv0s:mesh.uv
    indexes:mesh.triangles
}
