import QtQuick
import QtQuick3D.Helpers

// Geometry from Dev/models/sickleHorn.obj. Shared by both sides of the creature.
ProceduralMesh {
    readonly property var vertices: [
        Qt.vector3d(7.06,-8.604,0), Qt.vector3d(4.992,-6.084,7.87), Qt.vector3d(0,-0,11.13),
        Qt.vector3d(-4.992,6.084,7.87), Qt.vector3d(-7.06,8.604,0), Qt.vector3d(-4.992,6.084,-7.87),
        Qt.vector3d(-0,0,-11.13), Qt.vector3d(4.992,-6.084,-7.87), Qt.vector3d(10.637,-2.382,0.099),
        Qt.vector3d(8.826,-0.555,6.311), Qt.vector3d(4.453,3.858,8.884), Qt.vector3d(0.081,8.271,6.311),
        Qt.vector3d(-1.731,10.099,0.099), Qt.vector3d(0.081,8.271,-6.113), Qt.vector3d(4.453,3.858,-8.687),
        Qt.vector3d(8.826,-0.555,-6.113), Qt.vector3d(15.417,2.904,0.395), Qt.vector3d(13.429,4.491,6.535),
        Qt.vector3d(8.63,8.321,9.079), Qt.vector3d(3.83,12.151,6.535), Qt.vector3d(1.842,13.738,0.395),
        Qt.vector3d(3.83,12.151,-5.745), Qt.vector3d(8.63,8.321,-8.289), Qt.vector3d(13.429,4.491,-5.745),
        Qt.vector3d(17.967,10.025,0.889), Qt.vector3d(16.298,11.01,5.567), Qt.vector3d(12.269,13.389,7.505),
        Qt.vector3d(8.241,15.767,5.567), Qt.vector3d(6.572,16.753,0.889), Qt.vector3d(8.241,15.767,-3.789),
        Qt.vector3d(12.269,13.389,-5.727), Qt.vector3d(16.298,11.01,-3.789), Qt.vector3d(20.954,16.786,1.58),
        Qt.vector3d(19.253,17.453,5.991), Qt.vector3d(15.146,19.062,7.818), Qt.vector3d(11.04,20.671,5.991),
        Qt.vector3d(9.339,21.337,1.58), Qt.vector3d(11.04,20.671,-2.831), Qt.vector3d(15.146,19.062,-4.657),
        Qt.vector3d(19.253,17.453,-2.831), Qt.vector3d(21.436,24.435,2.469), Qt.vector3d(20.161,24.7,5.614),
        Qt.vector3d(17.082,25.34,6.916), Qt.vector3d(14.003,25.979,5.614), Qt.vector3d(12.728,26.244,2.469),
        Qt.vector3d(14.003,25.979,-0.675), Qt.vector3d(17.082,25.34,-1.978), Qt.vector3d(20.161,24.7,-0.675),
        Qt.vector3d(21.743,32.061,3.556), Qt.vector3d(20.634,32.108,6.237), Qt.vector3d(17.955,32.222,7.347),
        Qt.vector3d(15.276,32.336,6.237), Qt.vector3d(14.167,32.384,3.556), Qt.vector3d(15.276,32.336,0.874),
        Qt.vector3d(17.955,32.222,-0.236), Qt.vector3d(20.634,32.108,0.874), Qt.vector3d(19.978,39.935,4.84),
        Qt.vector3d(19.315,39.869,6.45), Qt.vector3d(17.712,39.71,7.117), Qt.vector3d(16.109,39.551,6.45),
        Qt.vector3d(15.445,39.485,4.84), Qt.vector3d(16.109,39.551,3.229), Qt.vector3d(17.712,39.71,2.562),
        Qt.vector3d(19.315,39.869,3.229), Qt.vector3d(17.683,48.085,6.321), Qt.vector3d(17.298,48.002,7.272),
        Qt.vector3d(16.367,47.802,7.666), Qt.vector3d(15.437,47.603,7.272), Qt.vector3d(15.052,47.52,6.321),
        Qt.vector3d(15.437,47.603,5.37), Qt.vector3d(16.367,47.802,4.975), Qt.vector3d(17.298,48.002,5.37),
        Qt.vector3d(14.109,56.531,8), Qt.vector3d(14.079,56.522,8.077), Qt.vector3d(14.005,56.5,8.109),
        Qt.vector3d(13.932,56.478,8.077), Qt.vector3d(13.901,56.469,8), Qt.vector3d(13.932,56.478,7.923),
        Qt.vector3d(14.005,56.5,7.891), Qt.vector3d(14.079,56.522,7.923)
    ]
    readonly property var vertexNormals: [
        Qt.vector3d(0.863,-0.494,0.109), Qt.vector3d(0.641,-0.225,0.734), Qt.vector3d(0.212,0.314,0.925),
        Qt.vector3d(-0.163,0.803,0.573), Qt.vector3d(-0.273,0.956,-0.107), Qt.vector3d(-0.063,0.688,-0.723),
        Qt.vector3d(0.356,0.153,-0.922), Qt.vector3d(0.743,-0.337,-0.578), Qt.vector3d(0.812,-0.583,-0.014),
        Qt.vector3d(0.614,-0.404,0.678), Qt.vector3d(0.148,0.092,0.985), Qt.vector3d(-0.314,0.625,0.715),
        Qt.vector3d(-0.492,0.87,0.018), Qt.vector3d(-0.285,0.675,-0.681), Qt.vector3d(0.179,0.168,-0.97),
        Qt.vector3d(0.632,-0.349,-0.692), Qt.vector3d(0.857,-0.515,-0.015), Qt.vector3d(0.621,-0.375,0.688),
        Qt.vector3d(0.081,0.058,0.995), Qt.vector3d(-0.442,0.538,0.717), Qt.vector3d(-0.632,0.775,0.018),
        Qt.vector3d(-0.387,0.626,-0.678), Qt.vector3d(0.141,0.187,-0.972), Qt.vector3d(0.655,-0.283,-0.701),
        Qt.vector3d(0.93,-0.367,-0.021), Qt.vector3d(0.68,-0.284,0.676), Qt.vector3d(0.09,0.059,0.994),
        Qt.vector3d(-0.495,0.474,0.728), Qt.vector3d(-0.706,0.708,0.025), Qt.vector3d(-0.427,0.609,-0.669),
        Qt.vector3d(0.151,0.253,-0.956), Qt.vector3d(0.707,-0.147,-0.691), Qt.vector3d(0.97,-0.242,-0.022),
        Qt.vector3d(0.695,-0.218,0.685), Qt.vector3d(0.041,0.015,0.999), Qt.vector3d(-0.605,0.329,0.725),
        Qt.vector3d(-0.842,0.538,0.023), Qt.vector3d(-0.542,0.51,-0.668), Qt.vector3d(0.092,0.268,-0.959),
        Qt.vector3d(0.713,-0.042,-0.7), Qt.vector3d(0.998,-0.049,-0.031), Qt.vector3d(0.734,-0.09,0.673),
        Qt.vector3d(0.055,0.019,0.998), Qt.vector3d(-0.639,0.225,0.735), Qt.vector3d(-0.912,0.409,0.032),
        Qt.vector3d(-0.605,0.448,-0.658), Qt.vector3d(0.056,0.325,-0.944), Qt.vector3d(0.71,0.121,-0.694),
        Qt.vector3d(0.996,0.086,-0.036), Qt.vector3d(0.736,-0.015,0.677), Qt.vector3d(0.04,-0.03,0.999),
        Qt.vector3d(-0.678,0.055,0.733), Qt.vector3d(-0.98,0.197,0.035), Qt.vector3d(-0.689,0.302,-0.659),
        Qt.vector3d(-0.013,0.306,-0.952), Qt.vector3d(0.675,0.217,-0.705), Qt.vector3d(0.966,0.25,-0.063),
        Qt.vector3d(0.748,0.106,0.655), Qt.vector3d(0.072,-0.015,0.997), Qt.vector3d(-0.657,-0.034,0.753),
        Qt.vector3d(-0.996,0.066,0.064), Qt.vector3d(-0.74,0.217,-0.637), Qt.vector3d(-0.08,0.324,-0.943),
        Qt.vector3d(0.612,0.337,-0.715), Qt.vector3d(0.937,0.333,-0.109), Qt.vector3d(0.765,0.161,0.624),
        Qt.vector3d(0.121,-0.041,0.992), Qt.vector3d(-0.607,-0.15,0.78), Qt.vector3d(-0.989,-0.099,0.11),
        Qt.vector3d(-0.789,0.079,-0.609), Qt.vector3d(-0.156,0.27,-0.95), Qt.vector3d(0.545,0.373,-0.751),
        Qt.vector3d(0.846,0.423,-0.326), Qt.vector3d(0.859,0.284,0.427), Qt.vector3d(0.334,0.043,0.941),
        Qt.vector3d(-0.405,-0.151,0.902), Qt.vector3d(-0.924,-0.182,0.336), Qt.vector3d(-0.906,-0.032,-0.422),
        Qt.vector3d(-0.377,0.201,-0.904), Qt.vector3d(0.334,0.384,-0.861)
    ]
    // The ninth vertex duplicates the first at the UV seam.
    property bool textured:false
    readonly property int sides:8
    readonly property int rings:vertices.length/sides
    readonly property int stride:sides+(textured ? 1 : 0)

    function sourceIndex(index) {
        return Math.floor(index/stride)*sides + index%stride%sides
    }

    positions:textured ? Array.from({length:rings*stride}, (_, index) => vertices[sourceIndex(index)]) : vertices
    normals:textured ? Array.from({length:rings*stride}, (_, index) => vertexNormals[sourceIndex(index)]) : vertexNormals
    uv0s:textured ? Array.from(positions, (_, index) =>
        Qt.vector2d((index%stride)/sides, Math.floor(index/stride)/(rings-1))) : []
    tangents:textured ? Array.from(normals, (normal, index) => {
        const start=Math.floor(index/stride)*sides
        const side=index%stride%sides
        const tangent=vertices[start+(side+1)%sides].minus(vertices[start+(side+sides-1)%sides])
        return tangent.minus(normal.times(tangent.dotProduct(normal))).normalized()
    }) : []
    binormals:textured ? Array.from(normals, (normal, index) => tangents[index].crossProduct(normal)) : []
    indexes: {
        const faces=[]
        for (let ring=0; ring<rings-1; ++ring) {
            const row=ring*stride
            for (let side=0; side<sides; ++side) {
                const a=row+side
                const b=row+(side+1)%stride
                faces.push(a,a+stride,b+stride,a,b+stride,b)
            }
        }
        return faces
    }
}
