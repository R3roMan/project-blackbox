import QtQuick
import QtQuick3D.Helpers

ProceduralMesh {
    id:gem
    readonly property var facets: {
        const vertices = [], normals = []
        const crown = Qt.vector3d(0,66,0), tip = Qt.vector3d(0,-58,0)
        const ring = Array.from({length:6},function(_,i) {
            return Qt.vector3d(Math.cos(i*Math.PI/3)*43,6+Math.sin(i*2.4)*9,Math.sin(i*Math.PI/3)*43)
        })
        function add(a,b,c) {
            const n = b.minus(a).crossProduct(c.minus(a)).normalized()
            vertices.push(a,b,c)
            normals.push(n,n,n)
        }
        for (let i=0;i<6;i++) {
            const next=ring[(i+1)%6]
            add(crown,next,ring[i])
            add(tip,ring[i],next)
        }
        return {positions:vertices,normals:normals}
    }
    positions:facets.positions
    normals:facets.normals
}
