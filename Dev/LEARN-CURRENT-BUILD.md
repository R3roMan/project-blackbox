# Learn the current build

Start with the [V0.1 walkthrough](BUILD-V0.1.md), then use this guide to follow the larger game. The [implementation plan](IMPLEMENTATION-PLAN.md) explains the longer design. [Build and Learn](BUILD-AND-LEARN.md) gives a broader lesson sequence. The [desktop guide](../Desktop/README.md) is the current activation and removal reference.

## What the languages mean

| Language/tool | Its job here | Learn first |
| --- | --- | --- |
| QML | Describes buttons, layouts, bindings and3D scenes in Qt | An `Item`, a property, an `id`, anchors and `onClicked`. |
| JavaScript | Holds the game rules and data | Objects, arrays, functions, `if`, loops and numbers. |
| C++ | Connects the desktop extensions to sensors and local commands | Read the bridge after you understand QML signals. You can learn the game without editing it. |
| Python | Builds original sounds/music and installs packages | File paths, script arguments and running a tool. |
| GLSL / `qsb` | Describes pixel effects and compiles them for Qt | Start with the pencil shader after understanding ordinary materials. |
| Blender | Creates meshes, materials and animation | Moving around a scene, editing a simple mesh and setting keyframes. |

A *binding* is a property value calculated from another value. QML can update the display when that other value changes. A *signal* announces an event; a handler such as `onClicked` responds to it. The game stores much of its state inside a JavaScript object called `run`. Because that object changes in place, `PlayScene.publish()` increments a revision counter so QML re-evaluates relevant bindings.

## A safe first session

1. Open Konsole in the project folder and run `qml6 Demo/Demo.qml`. Use Tutorial battle to learn the game itself.
2. Make a copy of any source file before your first edit. Change one thing at a time.
3. Open `Demo/game/Encounters.js`, find Silophosus and reduce its `speed` by20. Reopen the demo and compare wave1. Put the original value back.
4. Open `Demo/game/Loadout.js`, find the Service pistol's `delay`, and increase it slightly. Watch the reticle recover more slowly. Restore the value.
5. Run the checks: `QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software /usr/lib/qt6/bin/qmltestrunner -input Demo/tests`.

A speed is how far an enemy travels per simulated second. A delay is a time in seconds. Smaller delay means more frequent shots. Health and damage are game numbers; they do not measure real computer hardware.

## Follow one wave

Home's New game button calls `beginGame(false)` in `Demo.qml`. Its Loader creates `PlayScene.qml`. That creates a `run` using `Rules.create`. `prepareStage` asks `Encounters.planWave` for a fixed next roster. `EnemyMuster.qml` displays that roster and `StagePreparation.qml` displays equipment. Begin wave copies the roster into the pending arrival schedule.

The simulation advances in1/60-second steps. Drawing can update at a different rate. The speed button changes how much simulated time passes; the frame setting changes the target update frequency. Pausing stops simulation. The desktop host also pauses it when another app takes focus.

As an exercise, find `waveSize` and `maxConcurrent` in `Encounters.js`. The first decides the total roster. The second limits how many bodies can be active together. They solve different problems: stage length and pressure/readability.

## Follow one shot

`PlayScene.fire` asks the current world view which object the aim ray hit. `Rules.shoot` checks the weapon's recovery, ammunition, spin-up and player state. It applies the appropriate damage through `wound`. That function handles barriers, resistance, critical damage, status effects, reaction animation and death. `remove` records kills and awards money. `publish` refreshes the UI.

Try following a white-violet Electric hit into `chainElectric`. Each jump finds a nearby eligible target, remembers which targets were already visited and reduces the damage. Compare this with `Elements.apply`, which manages status duration and mutually exclusive Burn/Frost.

The controller page is a design reference. Actual gameplay input in this build is keyboard and mouse.

## Follow a model

`World3D.qml` creates `Threat3D.qml` for each visible enemy. Threat selects a rig appropriate to the species. Ordinary demons use the body, eye, mouth and wing parts; specialised creatures load their own rig. `FatDemonRig.qml` is restricted to Papapoganus and Oblogabgalus.

That restriction is a useful real bug lesson. A loader defaults to active. Giving it an undefined value did not reliably turn it off, and the new grey body appeared over unrelated enemies. The fix is an explicit Boolean condition using the two species names. `tst_RigSelection.qml` guards against the same regression.

Models respond to enemy state, such as warp progress, attack windup, hurt expression and status. Most current models are procedural QML geometry, so you can adjust them directly without Blender. Do not replace every rig at once while learning.

## Your first Blender asset

1. Make one low-detail floating head: a sphere body, one large eye, a separate lower jaw and two wings. Keep each moving part as its own named object.
2. Give them simple Principled materials in the game's dark/bone/accent palette. Avoid complex node effects for this first export.
3. Put the model's origin in a consistent central place. Learn local versus world axes, and apply object scale before animation.
4. Set a resting pose, then a visible windup, an attack and recovery. Animate wings separately so they can idle during dialogue.
5. Export a small `.glb` with glTF2.0. Use Blender's manual to check which animation and material features export. Imported node transforms, mesh materials and animation are separate concerns. [Blender glTF export](https://docs.blender.org/manual/en/latest/addons/scene_gltf2.html)
6. Try Qt's `balsam` importer in a practice directory and inspect the generated QML/meshes. Compare the scale with one existing rig. Wire picking and the game's state-driven animation before replacing that one species.

Your checkpoint is one imported enemy that is the right size, faces the camera, can be hit, has a readable windup and pauses correctly. More polygons alone do not achieve those things.

Open [companion-studies.blend](models/companion-studies.blend) to see the feather and hooked beak used by the bird companions. Both are separate meshes. Orbit the model in Blender, press **Tab** on a mesh to see its vertices, then compare the same shape in [BirdPet.qml](../Demo/game/BirdPet.qml). The generated QML geometry holds the shape data. The model file controls how that shape moves during flight, a strike or rest. [Pets.js](../Demo/game/Pets.js) defines when those poses and the charged-attack meter come into play.

## Follow a desktop ability

Run `./Desktop/preview.sh`. This opens a separate visible desktop in a window. The widget sends Q through the native bridge's `commandRequested` signal. `runtime/Host.qml` calls the same `Rules.useAbility` as the standalone game. A compact state snapshot then updates the panel's cooldown bar.

The wallpaper is a Plasma extension. The widget is another extension. The KWin helper reports exposure; it does not replace KWin. This separation lets you update or remove one piece without maintaining a fork of KDE. Read [Maintenance](../Desktop/MAINTENANCE.md) before your first installation.

## When something breaks

Keep the exact message, file and line. Start with a QML syntax error before changing packages. If a component imports but looks wrong, inspect visibility, size, transforms and whether the correct rig was selected. If a game rule is wrong, reproduce it at a fixed Debug wave and add a focused test for the behaviour. Debug runs do not advance the regular wave record.

Restart the demo after source edits. A running QML process keeps loaded components in memory. Export progress before experimenting with save formats. Use the nested preview for desktop experiments and keep the normal desktop available as your recovery route.
