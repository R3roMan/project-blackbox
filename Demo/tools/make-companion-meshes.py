"""Regenerate the feather and beak meshes inside Blender.

Run from the project root with blender -b --factory-startup --python
Demo/tools/make-companion-meshes.py.
"""
from math import cos, pi, sin
from pathlib import Path

import bpy

project = Path(__file__).resolve().parents[2]
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def loft(name, rings, sides, point):
    """Build a tapered solid using elliptical cross-sections."""
    vertices = [point(ring, side * 2 * pi / sides) for ring in rings for side in range(sides)]
    faces = []
    for ring in range(len(rings) - 1):
        for side in range(sides):
            edge = (side + 1) % sides
            lower, upper = ring * sides, (ring + 1) * sides
            faces.append((lower + side, lower + edge, upper + edge, upper + side))
    faces.extend((tuple(reversed(range(sides))), tuple(range(len(vertices) - sides, len(vertices)))))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    obj.select_set(False)
    for polygon in mesh.polygons:
        polygon.use_smooth = True
    return obj


def feather(ring, a):
    t, width, thickness = ring
    return (t * 100, 7 * sin(t * pi) + thickness * sin(a), -26 * t * t + width * cos(a))


def beak(ring, a):
    t, width, height = ring
    return (width * cos(a), -14 * t * t + height * sin(a), t * 47)


def qml_mesh(obj, path):
    mesh = obj.data
    mesh.calc_loop_triangles()

    def vectors(values):
        return ",\n".join("        Qt.vector3d(" + ", ".join(f"{v:.4g}" for v in item) + ")" for item in values)

    vertices = vectors([v.co for v in mesh.vertices])
    normals = vectors([v.normal for v in mesh.vertices])
    indices = [
        ", ".join(map(str, triangle.vertices))
        for triangle in mesh.loop_triangles
    ]
    rows = [", ".join(indices[i:i + 8]) for i in range(0, len(indices), 8)]
    path.write_text(
        "import QtQuick\nimport QtQuick3D.Helpers\n\n"
        "// Exported from Dev/models/companion-studies.blend.\n"
        "ProceduralMesh {\n    positions: [\n" + vertices
        + "\n    ]\n    normals: [\n" + normals
        + "\n    ]\n    indexes: [\n        " + ",\n        ".join(rows) + "\n    ]\n}\n"
    )


plume = loft("Primary feather", [(0, 2, .6), (.15, 8, 2.9), (.40, 12, 3.7), (.68, 10, 2.2), (.9, 6, 1.1), (1, .28, .12)], 8, feather)
bill = loft("Hooked bill", [(0, 10, 7), (.23, 13, 10), (.46, 11, 8), (.68, 7, 5), (.88, 4, 2.5), (1, .12, .15)], 9, beak)
qml_mesh(plume, project / "Demo/game/PetFeatherGeometry.qml")
qml_mesh(bill, project / "Demo/game/PetBeakGeometry.qml")
bill.location.x = 140
bpy.ops.wm.save_as_mainfile(filepath=str(project / "Dev/models/companion-studies.blend"))
