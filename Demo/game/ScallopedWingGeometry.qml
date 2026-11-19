import QtQuick
import QtQuick3D.Helpers

// Geometry from Dev/models/scallopedWing.obj. Shared by both sides of the creature.
ProceduralMesh {
    property bool textured:false
    uv0s: textured ? Array.from(positions, point =>
        Qt.vector2d(point.x / 124, (point.y + 25) / 93)) : []
    tangents: textured ? Array.from(normals, normal => Qt.vector3d(1, 0, 0)
        .minus(normal.times(normal.x)).normalized()) : []
    binormals: textured ? Array.from(normals, (normal, index) =>
        tangents[index].crossProduct(normal)) : []
    positions: [
        Qt.vector3d(54,37,7), Qt.vector3d(0,0,0), Qt.vector3d(23,35,-4),
        Qt.vector3d(59,54,4), Qt.vector3d(124,68,-12), Qt.vector3d(113,50,-15),
        Qt.vector3d(109,19,-19), Qt.vector3d(91,30,-10), Qt.vector3d(80,25,-11),
        Qt.vector3d(73,0,-16), Qt.vector3d(64,10,-8), Qt.vector3d(54,6,-9),
        Qt.vector3d(44,-19,-14), Qt.vector3d(32,-7,-6), Qt.vector3d(23,-10,-6),
        Qt.vector3d(19,-25,-9)
    ]
    normals: [
        Qt.vector3d(-0.194,0.195,-0.961), Qt.vector3d(0.076,0.078,-0.994), Qt.vector3d(0.336,-0.301,-0.892),
        Qt.vector3d(-0.023,-0.167,-0.986), Qt.vector3d(-0.319,0.146,-0.937), Qt.vector3d(-0.386,0.245,-0.889),
        Qt.vector3d(-0.371,0.181,-0.911), Qt.vector3d(0.226,0.97,0.094), Qt.vector3d(-0.39,0.4,-0.83),
        Qt.vector3d(-0.44,0.3,-0.846), Qt.vector3d(-0.194,0.421,-0.886), Qt.vector3d(-0.37,0.426,-0.826),
        Qt.vector3d(-0.343,0.383,-0.858), Qt.vector3d(-0.191,0.365,-0.911), Qt.vector3d(-0.708,0.579,-0.404),
        Qt.vector3d(-0.113,0.307,-0.945)
    ]
    indexes: [
        0,1,2,0,2,3,0,3,4,0,4,5,0,5,6,0,6,7,0,7,8,0,8,9,
        0,9,10,0,10,11,0,11,12,0,12,13,0,13,14,0,14,15,0,15,1
    ]
}
