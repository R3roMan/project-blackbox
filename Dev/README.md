# PROJECT BLACKBOX

An editable KDE Plasma wallpaper and desktop simulation for **Звезден Дъщ**.

- [Build and learning plan](BUILD-AND-LEARN.md)
- [V0.1 tutorial walkthrough](BUILD-V0.1.md)
- [Playable game demo](../Demo/README.md)
- [Plasma desktop integration](PLASMA-INTEGRATION.md)
- [Design brief](PLAN.md) and [implementation roadmap](IMPLEMENTATION-PLAN.md)

The reference wallpaper package is version 0.1.0 in `V0.1/`. [HANDOFF.md](HANDOFF.md) records the current state of the project.

## Launch the preview

Open a terminal in the project's `V0.1` directory and run:

    qml6 Preview.qml

Arch ships `qml6` in `qt6-declarative`. If you already have PySide6, this is another way to run the same scene:

    python tools/preview.py

Click the arrows or use the arrow keys. Home or the house button returns to the Shrine. The bottom tabs jump to a room directly. Select **Edit** to rename a room, choose its image, restore the sample, or adjust transitions and ambient FPS. Escape closes the editor or returns from **Artwork only**. Custom images stay in their original locations, so keep them somewhere stable. The preview saves your edits and mode locally.

Try **Up** from the Shrine, click a star, then use **New constellation** to move the points while keeping the project destinations. Try **Down** from the Shrine three times to see the drop, the vault passage and the emergence of stars. **Performance** makes the same navigation instant and stops ambient motion. The editor can simulate coverage and show adjustable sample CPU/GPU values. **Demo pulse** shows synthetic timing and track labels.

This is a working simulation built from layered 2D views. Its tabs and actions operate on the scene. Actual virtual desktop switching, window thumbnails, music metadata, system sensors and automatic fullscreen detection are native integration work described in [PLAN.md](PLAN.md).

## Identify and try the shaders plugin

From a terminal on Star Rain:

    bash tools/inspect-kde.sh

The script lists Plasma/KWin versions, wallpaper package IDs and versions, and the wallpaper types referenced in Plasma's configuration. It only reads local information. Star Rain previously reported Plasma 6.8.2 and Shader Wallpaper 4.2.4, ID `online.knowmad.shaderwallpaper`.

For that plugin, try its own **Playback** settings at 20–24 fps and 1920×1080 render resolution or equivalent scaling, if your installed version exposes it. Enable fullscreen pause. Start with a light single-pass shader and with audio input disabled. When you know the baseline, enable sound on a compatible shader and compare again.

The optional `shaders/blackbox-star-drift.frag` sample is a single-pass Shadertoy-compatible starfield. In upstream versions with **Advanced → code editor**, use the file's contents as the image pass. The developer guide also documents local imports by placing a copy in `~/.local/share/shaderwallpaper/Shaders/Imported/` and refreshing the gallery. Keep the source file in this project and follow the import method your version offers.

## Optional Plasma wallpaper trial

The archive includes a Plasma 6 wallpaper package in `kde/`. Its scene code is shared with the tested Qt preview. The Plasma installation, desktop input routing and settings persistence still need to be tested against Star Rain's exact versions. Use the preview first.

1. Note your current wallpaper type and preset so you can return to it.
2. From the extracted directory, install per user.

       kpackagetool6 -t Plasma/Wallpaper -i ./kde

3. Right-click the desktop, open **Configure Desktop and Wallpaper**, select **PROJECT BLACKBOX**, then apply. If a live settings window was already open, close and reopen it after installation.
4. Test pointer controls on exposed desktop space. In this wallpaper trial, the room changes within the wallpaper. Application windows stay on their existing KDE virtual desktops.
5. To stop the trial, switch the wallpaper type back to your previous selection. To remove the package after switching:

       kpackagetool6 -t Plasma/Wallpaper -r local.starrain.projectblackbox

Use `-u ./kde` instead of `-i ./kde` when upgrading a previously installed BLACKBOX package. The package runs as your user and uses Plasma's own wallpaper configuration. The standalone preview has its own settings.

## Edit the template

| Path | What to change |
| --- | --- |
| `kde/contents/ui/Rooms.js` | Room titles, directions, transition assignments, star coordinates and actions |
| `kde/contents/ui/Scene.qml` | Camera simulation, rendering policy, controls and image editor |
| `kde/contents/images/` | Default images and the two Abyss plates |
| `kde/contents/config/main.xml` | Plasma wallpaper defaults |
| `Preview.qml` | Standalone window and settings |
| `tools/make-placeholders.py` | Deterministic source for the seven simple non-Shrine plates. Requires Pillow. |
| `shaders/blackbox-star-drift.frag` | Optional external shader experiment |

The generated Home Shrine plate is `kde/contents/images/shrine.png`, 1672×941. Other plates are 1600×900. The file picker accepts replacement images and scales them to fill the scene. Keep the same filenames if you want to replace package defaults directly. For the final 4K artwork, keep important subjects clear of the bottom panel and leave extra framing around directional scenes.

The Shrine plate was generated with the built-in image generator from this brief: a first-person stone path through cedar trees to a remote Japanese mountain shrine inspired by Touhou's Moriya Shrine, red torii, warm lanterns, deep blue dusk and a clear upper band of sky. Widescreen painted game environment with no characters, lettering or interface. The remaining plates are editable procedural placeholders.
