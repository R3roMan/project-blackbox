# PROJECT BLACKBOX · project plan

Use the [implementation and learning plan](IMPLEMENTATION-PLAN.md) to take the 0.1 template through the Plasma trial, the first Play release, Blender assets, and the four Home modes. This brief records the game concept and candidate mechanics.

**Baseline:** the original 0.1.0 wallpaper template.  
**Target:** Звезден Дъщ / Star Rain, Arch Linux, KDE Plasma 6.8.2 on Wayland, RX 9070 XT and a BenQ 4K display at up to 144 Hz. Installed shader plugin: Shader Wallpaper 4.2.4 (`online.knowmad.shaderwallpaper`).

## What the user specified

BLACKBOX itself becomes a shooter **inside the wallpaper**. The mouse aims within the current view. It never turns the camera. The arrow keys look towards the left, right, sky and floor. View changes should feel like turning your head. Use **3D demons** approaching through depth, with a camera that settles at a fixed angle for each view. There is no walking or mouse-look in this design.

The run is an **endless wave defence roguelike**. Difficulty rises as waves continue, with bosses to be added. The player has ammo, shield, health, an active ability and passives. After each wave, Droid Lab offers a random choice of rewards. Spawned threats can come from all directions, so what you leave out of view matters.

- **Forward / Home Shrine:** the central view. Regular demons tend to attack in melee and move towards you.
- **Left and right:** also defendable approaches. Give each view distinct routes and readable signs of how far away enemies are.
- **Up / Star Sky:** alien demons descend from space and fire back, wearing down shield and health. You can shoot the attackers.
- **Down / the Void:** different creatures crawl up towards you. They require a special counter instead of gunfire. This is its own gameplay mechanic. Its relationship to the normal Abyss desktop or artwork can be chosen during design.
- **Droid Lab:** reward selection between waves. It can still be the existing rightward site. The exact entry and return flow are open.

The mood is **eerie, gory and epic**, with Doom as a tonal reference and strong background music. Build that through the threat of hearing enemies approach from the dark, heavy combat impact, and a soundtrack that builds into the wave and boss peaks. Use original or appropriately licensed assets and music for anything distributed.

The prior 0.2 standalone range and Flooded Station mission were experiments. Their timed drills, shooter progression unlocks and Godot launch flow are outside the game brief. Build from this archive's 0.1 template.

## Keep the existing wallpaper

The ordinary BLACKBOX wallpaper has two axes through the Shrine.

- Vertical: Star Sky ↔ Home Shrine ↔ Abyss.
- Horizontal: Media ↔ Home Shrine ↔ Droid Lab.

Keep the Moriya-inspired Shrine fixed, the interactive constellation, art replacements, Abyss variants, Media and Droid Lab. Keep the original first-person travel ideas for the ordinary wallpaper. In the shooter, the arrows have combat meaning. Keep a single game session and switch views inside it so enemies, projectiles, ammo and health persist. The game does not depend on KDE changing virtual desktops for aim or wave progression. Return to the ordinary wallpaper and its controls when the run ends or the player exits.

0.1 implements the standalone preview and includes a trial wallpaper package. A switch in the template changes its own scene, and real KDE desktop routing, broadcast now-playing information, window tabs and live sensor integration are still separate work. Gameplay is also future work.

## Design proposals to test

These are candidate mechanics, not fixed requirements.

| Area | First thing to try | What to decide after testing |
| --- | --- | --- |
| Camera | Render one 3D scene, with a handful of fixed orientations and short turns. Mouse position defines an aim ray from the active view. | Set the turn duration, decide whether firing is available during turns, and test pointer alignment across fractional scaling. |
| Offscreen threats | Allow enemies to advance between view changes. Show a readable directional warning before an attack lands. Use distinct sounds plus visual cues for ground, sky and Void threats. | How quickly can a player react without cycling views constantly? |
| Void counter | Hold a seal shut with the cursor. Leaving interrupts it and lets the creature regain ground. | Whether seals need positioning, timing or another clear action. Keep the task readable under pressure. |
| Other counterplay | Consider letting players shoot down some alien projectiles. Give one active ability a clear first job, such as buying time on the current front. | Final shield recovery, reload behaviour, ability inputs, upgrade effects and damage rules. |
| Rewards | Draft one of three options from a seeded pool. Try upgrades that change where the player looks or when they reload, such as shield recovery from a Void counter. | Number of offers, rarity, rerolls, dead ends, pacing and how secret items enter the pool. |
| Escalation | Raise pressure through enemy counts, overlaps and mixed patterns before increasing health. Start with a budget for each wave and reserve enough space between urgent attacks for a deliberate response. | Wave lengths, downtime, elite cadence and the difficulty curve. |
| Bosses | Prototype a threat that telegraphs in one view, then moves to another and exposes a weak spot. Let secret summons be deliberate choices. | Boss designs, side effects and trigger conditions. |
| Gore | Start with readable hit reactions, blood, marks on scenery and strong sound. Limit how long effects and debris remain on screen. | Intensity, reduced-gore setting and silhouettes that stay visible through effects. |
| Music | Use an uneasy ambient layer between waves, heavy rhythmic combat stems and a distinct boss layer. Keep attack warnings distinct once the music ramps up. | Composition, mixing, track switching, soundtrack volume and what happens to ordinary desktop audio when play starts. |

One suggested first encounter combines a melee demon close to the Shrine, a shot charging above and a cracking Void seal below. The player should recognise all three pressures, choose what to deal with first and understand the outcome. Solve this before building many enemies or expanding the lore.

## Implementation sequence

1. **Prove the wallpaper host on Star Rain.** The first experiment is an opt-in play state with a visible indicator. Check that an exposed wallpaper can take mouse and arrow input while playing, that Escape exits play, and that ordinary Plasma menus and application input work outside play. Test cover/uncover, focus loss, lock, workspace changes and an exit in the middle of a turn. Put game state in one owner so opening settings or adding a display cannot start a second run.
2. **Choose how to render in the wallpaper.** Start with a minimal Qt Quick prototype using the shared 0.1 scene where practical. Test fixed viewpoints and 3D actors with Qt Quick 3D before committing. If that path fails, evaluate a renderer embedded as a background surface, with the same in-wallpaper controls. An optional developer preview is fine. The user-facing game should be the wallpaper.
3. **Build the combat slice.** Forward, left, right, up and down; no mouse-look. Use simple silhouettes first. Add a melee demon, one ranged alien, one Void crawler, aim/hit tests, ammo, shield, health, a first ability and the non-shooting Void counter. Keep simulation state independent of the visible view. Freeze simulation when play is paused.
4. **Add the whole loop.** Until then, a single encounter is enough. Next add wave completion, Droid Lab drafting, passives, failure/restart and endless escalation. Define how each reward choice returns you to the wave and stop intermission controls consuming combat input. Add tunable spawn data rather than hard-coding balancing inside scene art.
5. **Finish style and secrets.** Develop demon silhouettes, art, readable gore, reactive sound and music. Then add the first boss. Use the existing room identities and artwork as visual references.
6. **Test normal use and frame cost.** Establish the still wallpaper baseline before adding effects. Compare idle GPU use and power, 4K scaling, gameplay frame times and restoration of ordinary controls after quitting. Performance mode should keep the ordinary wallpaper usable and disable decorative work. Give gameplay its own render budget. Verify that hidden or abandoned runs stop advancing and do not leave the desktop busy.

## Shader Wallpaper's role

Keep the existing single-pass star-drift example as a shader benchmark. The plugin was previously checked for mouse and desktop-index inputs, with live behaviour on Star Rain still to verify. Use shaders for effects such as Void distortion, star glow, lighting, impact or blood and for a small isolated pointer-input experiment. Keep enemies, waves, rewards, input ownership and persistence in ordinary application/game logic. A playable wallpaper also needs a reliable exit and focus lifecycle. If the third-party plugin's API does not expose the required controls, keep its presets available as an optional visual track and implement the game in BLACKBOX's wallpaper host.

## Definition of the first playable version

- Start and exit game mode from the wallpaper, with no separate game window in the normal user flow.
- Mouse aims without rotating the camera. Arrow turns land on distinct readable views. Visible targets line up with aim at the chosen display scale.
- Melee and ranged attacks work on multiple fronts; a Void crawler is stopped through a non-gun action.
- Clear a wave, select one random offer in Droid Lab, start the next wave, and lose or restart cleanly.
- Eerie ambience and a combat music layer establish the tone while cue sounds remain understandable.
- Esc, covering the wallpaper and locking the session leave the desktop responsive. Verify exact KDE behaviour locally and record what's still missing.
