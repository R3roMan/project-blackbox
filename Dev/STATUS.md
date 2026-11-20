# Current status and remaining work

Updated 18 November 2026. This is the current checklist; earlier HANDOFF entries are historical checkpoints. Earlier sections describe the November 18 baseline. The Grimoire build section records the work since that baseline.

## November 18 checkpoint

- The front practice peon was behind the trainer. Software mouse/keyboard checks now reach graduation through all seven lessons and both boss phase boundaries. Native input from Home → Tutorial also reached graduation after adding a solid-centre hit test for the trainer and practice peons.
- Fixed the selection panel retaining both centering and bottom constraints. At 3840 × 2160 its paused height fell from 2,108 to its actual content height of 630 pixels. Verified first-wave and between-wave preview regions at 760 × 530 and 4K, with visible rendered enemies in native wave 1 and wave 10 screenshots. Reserved space below the header when the window allows it.
- The fresh Plasma preview now applies its wallpaper after the temporary activity is created. The private desktop reported the wallpaper, 200 HP and the automatic visibility helper ready. A second launcher test verified the icon-free Desktop containment, wave 1, pause, save and Performance mode. A separate two-host test verified one owner, preferred-screen changes and a paused transfer of the same wave. Physical desktop and widget clicks in a daily-use session still need a human check.
- Verified two consecutive installations and reversals in a temporary folder, with edits and unrelated files retained. Verified output analysis shuts down on release, opt-out and Performance mode, then resumes on reclaim.
- Hasa's frost and electric control-loss chances are 4.5% on ordinary hits. Freeze, stun, roar and Faeel share at least 2.5 seconds of recovery after loss of control. Rain still freezes eligible targets. The standard shield now takes 4.5 seconds and Fleet shell takes 3.2. Hosphoragus has 14 base HP. Discovered demon pages show base combat stats.
- Shotguns gained 8% base pellet damage and a stronger close-range multiplier. Two additional kits are Door knell (Rime Bell, Doorstop, Choke ring) and Kiln keeper (Furnace Door, Kiln ring, Furnace apron). Both guns have generated fire and reload audio.
- Six conventional Hellborne species now have enlarged stomach mouths in the 3D and software models. Hellborne now have curved horn meshes and scalloped wing membranes. Saslimigus keeps its explicitly hornless design. Editable OBJ sources are in Dev/models. Individual species art review remains.
- The final Qt suite passed 124 checks with zero failures, including the two-shotgun regression. Native Debug wave selection, Escape, staff right-click, shop, save/Continue, and gallery filters passed. Seven hallucinations during a Void incursion remained playable by the rules in a 3840 × 2132 rendered frame. Synchronous readback using software OpenGL took 97 ms median, 100 ms p95 over 36 samples. This includes copying a frame and does not measure GPU gameplay FPS. A hardware-backed nested client hit a DMA-BUF import error here. Auto now caps the field at 1080p during hallucinations and Void incursions on normal detail, and only builds visible enemy meshes. A second draw captured six illusions at 88 ms median, 91 ms p95. The different illusion counts preclude a direct speedup claim. Physical GPU frame timing remains open.

## Implemented on disk

- Standalone QML demo opens again. The new fat rig is limited to Papapoganus/Oblogabgalus; it no longer overlays other enemies.
- 97 playable weapons, 97 passives, 97 actives in complete primary kits;52 achievements. Ten regular species are Normal. Ghorimagous is Ascended, keeping Crufixicatus Normal.
- Deterministic per-wave rosters, rank/concurrency limits, preview models, boss-last scheduling, late Void pressure and more late Void variety.
- Harvester, Crufixicatus, Papapoganus and tutorial-only Oblogabgalus; new twin SMGs/shotguns, RPG and Common/Rare/Legendary staffs.
- Seven-lesson tutorial and two-phase battle, dialogue/rewind/molt/active lesson. Rules-level flow passes, including critical damage across the phase boundary. Both rendering paths passed the scene-input regression described above.
- Wider shared item tooltips with upgrades/damage/cooldowns, stronger equipment upgrades, extra magazines, max-rank mega gift, all-active visual events and staff charge UI.
- Combined equipped loadout/inventory in Pause and preparation. Mid-wave editing is disabled. Replacement moves old gear into an available inventory slot.
- One saved run, Continue/New game, validated backup export/import, enemy kill/death and weapon statistics.
- Animated grimoire with unknown pages, pencil shader, red/blood styling, page count, chapter skips and medals. Controller reference retained. See the Grimoire build below for the revised book and links.
- Effect texture/refresh limits, lower-cost hallucinations at hittable range, offscreen model reduction and1440p auto field cap with native wallpaper framing. Frame-update target, timer and1×/2×/0.5× controls.
- Separate Plasma wallpaper, control widget, visibility helper and optional style. Shared game code, user-package installer/rollback, read-only CPU/GPU inputs and opt-in speaker-output spectrum.
- Visible nested preview launcher in Desktop/preview.sh; own runtime/config/data/cache/state and session bus. No core KDE component replacements or live layout changes.
- Current implementation/teaching/maintenance guides in Demo/README.md, Desktop/README.md, Desktop/MAINTENANCE.md, Dev/LEARN-CURRENT-BUILD.md and Dev/WAVE-DESIGN.md.

## Verification already completed

- The November 18 results above supersede earlier test counts.
-21,600 seeded wave plans audited across waves1–180 and all three difficulties after the Normal-rank correction.
-416 sound/music assets decoded by Qt.
- Private virtual audio graph played the new weapons/cues/book/tutorial scores; speaker-output analysis produced non-zero RMS/bands. Ownership-based stop/resume also passed.
- Full software-window preparation, save/continue, backup/import rejection, graphics, gallery filtering and staff R/right-click checks passed without warnings.
- Native window tests exercised models, staff casts, held weapons, shop, save/continue and descent. Final exit and gallery passed in the November 18 native run.
- Actual nested Plasma loaded wallpaper/widget/helper, started combat, paused/resumed, saved, switched modes and paused on app activation.
- Installer upgrade/rollback preserved edited package files and unrelated files in a temporary install root. The two-install manifest chain passed on November 18.

## Earlier work to finish first

- [x] Reproduce tutorial progression through actual PlayScene mouse/button/key input, diagnose the user's stuck phase and fix it. Keep the phase-boundary critical regression check.
- [x] Complete the final native GUI regression, including actual Debug wave entry and Escape, staff input, pause/menu interactions, grimoire filters and tooltips.
- [x] Verified the actual clean-profile launcher, standard Desktop containment, automatic visibility helper, start/pause/save commands and a simulated preferred-screen handoff.
- [ ] Check direct desktop and widget clicks, key focus, lock/unlock and physical monitor hotplug on the target desktop.
- [x] Recheck optional output analyser shutdown when the host is released/Performance mode is selected.
- [x] Recheck multi-install rollback chaining and final native-library build/package metadata.
- [x] Measure/render the worst hallucination/Void scenes and check4K framing/render budgets. Do not claim universal zero lag.
- [x] Close out balance findings with human-readable notes. Scripted Normal runs can stall on Jospharemus tactics; sampled Hard reached79, Insane27. No claim of fully proven human balance.
- [x] Finish the progress report with exact verification results and activation/revert commands.

Physical multi-monitor hotplug, lock/unlock and a long session on the actual display/driver remain daily-use compatibility checks. These should be distinguished from completed automated/nested checks.

## Grimoire build · 0.3.0

### Game and storybook

- [x] Ship the narrower, thick hardcover, opaque inside cover and delayed left page. The book includes Demons, Weapons, Abilities, Pets, Kits, Weather, Medals and Manual. Click either marked page corner to turn.
- [x] Show discovered demon stats and tactics. Sort by debut wave by default. Preserve the origin and kill/death filters.
- [x] Open the exact Grimoire page from an item or forecast hover. Follow references to gear, demons and kits and use the history button to return. Closing the book preserves the contents of the run.
- [x] Stain the pages with irregular dark red splashes. Use a compact entry picker, readable font sizes and distinct coloured active/passive glyphs, including in kits. Show staff portraits side-on and at a larger scale.
- [x] Reserve space for the forecast after every wave, keep Begin and other important buttons pinned, and match native hover to 3D geometry. Keep health bars free of combat messages.
- [x] Make death effects shorter and centre the held guns higher. Add stronger shadows, local light and atmosphere in High graphics.
- [x] Require Shift for the last tutorial target. Reset the front and input focus synchronously before asking for Q. Show phase-change progress during Oblogabgalus's molt.
- [x] Show Continue next to New game, greyed out with no valid checkpoint. Keep a previous valid checkpoint as fallback and support optional normal-run autosave.
- [x] Use a softer keys, bass and brushes arrangement for the book. Add swung fills to pressure and climax tracks. The original main combat loops remain available.

### Encounter and art updates

- [x] Add the smaller Night and Blood Moon behind the battlefield. About 10% of ordinary nights are Blood Moon, including possible boss nights. Night's 5% health/barrier bonus still applies. Blood Moon adds 25% gold, +15% damage, +20% movement, +10% attack rate and player Blindness II.
- [x] Place exactly one late-wave Blandromedus in the same roster the player previews. Its blood bolts inflict Weaken III. A landed bolt restores 4.5% max health to Blandromedus.
- [x] Add the Scarlet covenant kit and three Blood Moon achievements. The weapon, active and passive heal within individual caps.
- [x] Give Nightosphere a transparent crystal shell, a rotating purple core, crystal projectiles and 15% critical chance.
- [x] Speed up Lucifoverus's final charge, raise Stinkaturumus's base HP from 168 to 187, use 0.85×/1.00×/1.15× optional weather rates and permit multiple simultaneous Void enemies within the wave's global cap.
- [x] Make Josphoramus crumble once the live and queued rosters contain only statues.
- [x] Refine short arms, horn attachment, scalloped wings and staggered teeth. Add fighter hulls with horned pylons and give fallen angels black halos and horns.
- [x] The user kept design A. It is the belly-mouth model across the eligible Hellborne roster. The new arm mounts separate the darker arm from the torso. The [three original studies](models/belly-mouth-options.png) remain available.
- [x] Current companion art uses Blender-sculpted feathers and bills plus new game rigs. The editable source is [companion-studies.blend](models/companion-studies.blend).

### KDE and remaining verification

- [x] Test real mouse and keyboard input in the isolated nested Plasma desktop. Debug, Star Destroyer+, Begin Wave 10 and Escape responded, with KDE's launcher, task manager, Blackbox widget and clock present.
- [x] Build the 0.3.0 stage from the current source. The complete Qt suite passed 130 checks. Native-window checks covered exact hover links, the tutorial and both phases, Continue, forecasts after waves 1 and 2, and the new Blood Moon visuals. The largest text preset fit the setup and pause actions at both 760 × 530 and 3840 × 2160. Those size checks used software rendering.
- [ ] Validate the final build on the actual GPU and displays. Include long runs at 4K, physical monitor hotplug, screen lock/unlock and a full reward → preparation → boss → shop → preparation playthrough.
- [ ] Decide when to activate the release on the live desktop. Follow Desktop/README.md for installation and reversion. Continue future per-application abilities and further XD environments as separate features.

## Workshop build · 0.3.1

- [x] Default nested preview to Qt Quick 3D. Report the renderer in the panel. Direct nested startup and combat stayed in 3D after the renderer check.
- [x] Face the native gun toward the centre of aim. The 2D combat fallback uses its own forward-facing view. Weapon book art still shows the side-on shape.
- [x] Separate and bevel Hellborne shoulders without negative scale on the left arm.
- [x] Give companions distinct features and animated flights. Rest tucks the wings and closes the eyes. Crow, Owl, Drake, Beetle and Wendy have secondaries that charge during combat and pause their charge while resting.
- [x] Add a public Shop chapter, unique stock catalogue, sequential counter expansions and three ranks of Curated stock. Slot replacement needs confirmation of the current effect and rank.
- [x] Add 30 conditional slot powers alongside the seven originals. Present the effect, compatible gear and current slot state in the listing, loadout and Grimoire.
- [x] Add cosmetic sunrise and sunset at equal odds on all difficulty modes, with distant lightning and slowly moving light.
- [x] Ground active and visible passive feedback in the action or actual target. Use bounded 3D bursts plus 2D effects and labels.
- [x] Verify the 0.3.1 source and staged packages. All 138 Qt checks passed. Captured all 19 Quick 3D companion models. A standalone window exercised shop offers, replacement confirmation, new stock, the ledger, Storm call and pet recovery. The shop controls also worked at the 760 × 530 minimum with the largest text preset.
- [x] Start wave 10 and pause through direct input in both versions of the visible Plasma preview. The default stayed in Qt Quick 3D and the explicit software option stayed in the 2D renderer. The KDE panel remained available in both sessions.

### Live desktop checks remaining

- [ ] Measure frame pacing during long 4K runs on the actual GPU. Compare the standard detail setting with High and the 1080p cap in busy weather waves.
- [ ] Exercise physical display hotplug, mixed scaling and lock/unlock when running a live user installation. Check that leaving the desktop pauses Play and stops Idle and XD animation work.
- [ ] Run another full reward → preparation → boss → shop → preparation playthrough on the target desktop. Check Continue before and after the shop and restore a backup through Import.
- [ ] After the next major Plasma or Qt upgrade, rebuild the public extension packages and repeat the nested startup and rollback checks in the desktop guide.

## How to inspect now

From the project root:

```sh
qml6 Demo/Demo.qml
./Desktop/preview.sh
```

Reopen an already-running demo after source edits. It caches QML/JS components. The preview is a separate visible desktop in a window; closing it ends that temporary session.

For code and automated checks:

```sh
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software /usr/lib/qt6/bin/qmltestrunner -input Demo/tests
```

Installation is optional and has not been applied to the live desktop. Read Desktop/README.md before using `python Desktop/manage.py install`; removal/rollback is documented there. Standalone and installed desktop share the game save/progress file; nested previews deliberately use temporary settings.

## Witch’s Vault and weather cycle · 0.4.0

- [x] Separate sky time from environmental weather and add rolling daylight, sunset, night and sunrise. Give the left view the moving 3D sun and Star Sky an orbiting moon. Layer Fog and Thunderstorm over the cycle.
- [x] Add the Witch’s Vault art and interface. Store permanent ranks, one-run parcels, dark gems and expedition reports in the shared profile. Award grades after defeat or retirement and give the seven grade achievements full equipment kits.
- [x] Connect the combat win and loss splashes, empty-magazine reload, centre reload meter, quick weapon swap, staff framing and parry and recharge lessons.
- [x] Run the full suite. All 145 checks passed, including the real-input parry tutorial, weather transitions, the two lightning outcomes, the payout guard and permanent and one-run purchases.
- [x] Exercise shop hover and purchases, parcel use, automatic reload, a weapon swap, both outcome splashes, postcard archiving, best record and Continue in the demo window. Confirm the Vault and Skip pet at 760 × 530 at the largest text setting.
- [x] Inspect the sun, Blood Moon through Fog, lightning, storm casts and held staff animations in a separate visible KDE 3D window. Stage 0.4.0 and start and pause wave 10 in the packaged Plasma preview with the regular panel visible.
- [ ] Sample live 4K performance and longer regular expeditions on the target desktop. The Wave 100 shelf is visible and gated. Its stock remains reserved for a later release.

## Tarot and weather gear · 0.4.1

- [x] Replace the Witch’s Vault portrait with the slimmer adult witch. Her black hair falls under a hood that covers both eyes. The original portrait is still available in the art folder.
- [x] Add the five-card Tarot reading, 78 illustrated card faces, saved hands and a one-expedition omen. Add regular-run sale rolls and single-use free offers.
- [x] Add six purchase and dark-gem achievements with six weather kits. Add Jacko, the extra familiar from The Devil.
- [x] Require a clear of Wave 80 and minimum scores across the expedition report for SSS. Reduce Blood Moon to 5% of later nights. Let the field shield repel Fearme. Add muzzle flashes, twinkling stars and drifting Abyss particles.
- [x] Rebalance Foundry minigun, Whiteout Coil, King’s Ransom, Barrier breaker, Zadrrimus, Crufixicatus and Go Go Battlestar. Update the Grimoire's opening damage previews.
- [x] Pass 149 Qt checks, including old Vault migration, the five-card hand, Wave 80 scoring gates, the weather bonuses and the shield's interaction with Fearme.
- [x] Exercise free stock, a discounted draw, leaving and reopening the shop, a card flip and its effect in combat. Check the minimum window and 3840 × 2160 with the largest text preset. Inspect the updated witch, Jacko and muzzle flashes in Qt Quick 3D.
- [x] Start and pause Wave 10 in the isolated Plasma preview with the standard KDE panel present. Refresh the 0.4.1 stage.
- [ ] Measure frame pacing over longer 4K sessions on the target GPU. Exercise physical monitor hotplug and lock or unlock with an installed wallpaper.
- [ ] Populate the gated Wave 100 shelf and extend the XD environments in later releases.

## Sky correction, Abyssal Takeover and economy · 0.4.2

- [x] Hold one sky phase per wave, slow the sun and moon, and keep the Abyss dark.
- [x] Add a rising black flood, a 60-second seal deadline, and an audible last-ten countdown. Require a seal before the wave can end.
- [x] Wire temporary Wave 10–50 passages, cheaper starting ranks, up to five free rerolls per run, rising paid reroll prices, frozen offers and a separate Witch’s Vault debug view.
- [x] Bank boss and Mega Gift gems with checkpoint protection. Animate coins and gems and show the temporary gem balance.
- [x] Add colour-coded weapon comparisons and fire rate. Generate missing weapon clips, distinct active casts, menu and gallery sounds, and a separate Witch’s Vault score.
- [x] Verify wave phases, warning, the seal gate, a closed run after defeat and currency animation in the demo. Start and pause wave 10 in the staged Plasma preview.

## Combat, environment and expedition follow-up

- [x] Save three original CG backgrounds for the western lake, powered Droid Lab and underground Abyss. Add a per-front picture picker to the windowed demo and preserve custom picture paths in backup exports.
- [x] Rework the combat health, barrier and shield displays and add an independent 80–130% HUD scale in the windowed and desktop settings.
- [x] Measure actual audio playback of 15 sound paths using a private virtual speaker, including first-fire, reload, two active casts, a sustained beam, shop and gallery sounds. Audit all 112 weapon profiles and 111 cast files.
- [x] Verify marked shots, the staff meter and casting, restorable live checkpoints, purchase refunds and archived expeditions. Draw any category in each of the three reward slots.

## Ultra, records and audio follow-up · 0.4.2

- [x] Add personal best above the saved expedition list and a full-width report at compact window sizes.
- [x] Split the mixer into master, music, combat, ambience and interface levels. Preserve legacy mute and backup settings.
- [x] Add the two-second collapse sequence, ranked gold, Veilskate, incoming critical and miss feedback, dependable Reapfast fang volleys and shorter cooldowns on most active effects.
- [x] Add shared normal and surface maps, textured native preview models and a restart reminder. Keep a transparent gun viewport and lighting from an HDR probe.
- [x] Verify Ultra in visible Qt Quick 3D with the transparent weapon overlay, the pre-wave companion, reflective katana, fogged boss death and the field shop. Run 160 Qt checks and compile 145 QML components.
- [x] Measure distinct pistol, scattergun and railgun sounds from real input through a private PipeWire sink. Verify right-click reload, an active cast and a muted combat channel.
- [x] Stage 0.4.2. Use the actual mouse and Escape to start and pause Wave 10 in isolated Plasma with the launcher, task manager, Blackbox Controls and clock visible.
- [x] Sample a native early wave with the field at 3840 × 2160. Qt reported 58 FPS median after the first second. In an injected 21-enemy Takeover at the same output resolution, the field stepped down to 1440p. Skipping crowd shadows and tiny details raised the median from 37 to 42 FPS.
- [ ] Measure long sessions and late campaign waves on the live desktop. Verify multimonitor hotplug and lock/unlock. Hardware ray tracing has no implementation in this Qt Quick 3D preset.

## Wave 81 stability and Ultra materials · 0.4.3

- [x] Inspect the reported abort. The game was stuck repeating an invalid Qt socket notification before it received SIGABRT. The waveform player matched a reported Qt 6.12 PipeWire freeze. Replace it in the demo, gallery and desktop runtime with bounded reusable media players. The brief isolated replay also completed on the older build, so it did not independently reproduce the original freeze. [Qt issue discussion](https://forum.qt.io/topic/165215/soundeffect-qsocketnotifier-invalid-socket-...-disabling...-floods-the-log-and-the-app-freezes-qt-6.12-linux)
- [x] Remove the always-on combat noise loop. Record silence before and after rain with music and combat audio muted. Verify the new snigger, laugh, breath, groan and rasp clips against a private speaker, along with gunshots, reload, an active ability and the effects mute.
- [x] Preserve the ordinary night vignette without changing accuracy. Lower Blindness miss penalties to 3%, 8% and 15%. Blood Moon Night continues to apply level II.
- [x] Soften scale relief. Add veined wing membranes, ringed horns, polished bone, grained wood and pitted stone. Add a dimmer, softer Abyss backdrop behind drifting banks of mist.
- [x] Pass all 160 Qt checks and compile all 146 QML components.
- [x] Clear a full 21-enemy Wave 81 roster and enter Wave 82 in the visible 3D demo with sound. Exercise repeated weapon and weather changes, wallpaper turns, pause and resume. The invalid-socket loop did not recur.
- [x] Stage 0.4.3 and verify nested Plasma starts a wave, descends to the Abyss, pauses and resumes using its panel commands. The desktop preview retains the main session's audio connection when it gets its own runtime directory.
- [x] Check the Ultra pre-wave, arms, wings, horns, skull, wooden counter and the katana in Qt Quick 3D. A short isolated Wave 1 measured 64 FPS median with a 3840 × 2160 field. The 21-enemy Takeover stress test measured 40 FPS median and Auto reduced the internal field to 1080p under sustained load.
- [ ] Verify a long normal run through multiple bosses on the player's live session. The original crash sequence remains intermittent.

## Auto, background play and Idle · 0.4.4

- [x] Add Auto beside the speed selector. It uses the current simulation speed, picks a random wave reward, and buys one random affordable item at each shop. It starts off on a new or continued run, stops on defeat, and only advances through previously cleared waves up to 90. Earlier saves can prove clears through timed clears, flawless clears, or eligible expedition records.
- [x] Add opt-in background play to demo and desktop settings. A second application in nested Plasma confirmed that the battle advances when the setting is on and pauses when it is off. Manual input and field audio follow focus.
- [x] Give the Abyss weather effects with constant underground lighting. Use the same resident wallpaper renderer in Idle and Play so a turn keeps each room's sun, sky and weather layers through its animation. Verify underground rain in Play and snow in Idle.
- [x] Separate the title, wave count, boss bar, timer and gameplay controls in the combat header. Check the layout in a 760 × 550 window at maximum text and HUD scaling.
- [x] Pass all 165 Qt checks. In the isolated 3D demo, Auto cleared two unmodified waves at 2×, kept fighting while minimized, stopped before the next uncleared wave, and switched off when a Takeover caused defeat. Stage and verify 0.4.4 in nested Plasma.

## Shield charge, eye hits and desktop controls · 0.4.5

- [x] Turn the shield into a charge meter. Raising it requires 20% and spends 10%. Holding it and blocking drain the meter. It drops when empty and recovers while lowered. A timed parry restores full charge. Update the tutorial, shield modifiers, threshold marker, red rejection flash and three sound cues.
- [x] Add eye hit regions to both field renderers and guarantee a critical roll on an eye hit for enemies that can take critical damage. Give Auto varied stretches of scoped and unscoped gunfire.
- [x] Draw magazine rounds, heat and charge in a circular HUD. Add CPU heat, GPU pressure and optional audio rings to desktop play. GPU pressure can lower graphical detail for sustained load and speaker reactivity can vary new wave lineups.
- [x] Reserve the Plasma panel work area and put the wider Grimoire filter menus above the book. Bring up the Blackbox settings drawer from the panel and provide Back to Play from Idle.
- [x] Remember the selected screen and the last idle wallpaper. Pause background play on screen lock. Add opt-in KWin workspaces for the five rooms, plus a settings action to save and restore the previous KDE wallpaper. The demon shortcut opens Blackbox again.
- [x] Pass 166 Qt checks and compile 147 QML components. A native mouse click on Silophosus's rendered eye produced a critical hit. The same run exercised shield raise, parry, ordinary block, depletion and red rejection. All three shield cues produced audio in a private PipeWire sink.
- [x] Stage 0.4.5 and verify the settings drawer, Grimoire overlay, workspace switching in both directions, Idle return and wallpaper restore/relaunch in visible nested Plasma. A simulated lock signal on the private session bus stopped Background Play until unlock. The regular desktop and its layout were untouched.
- [ ] Verify monitor hotplug and shortcut launch through the physical Plasma desktop. The nested session verified the shortcut target's restore and relaunch behavior.

## Combat tuning, clean Idle and expedition rewards · 0.4.6

- [x] Add weak points and glancing hit regions, with independent shotgun pellets, wider spread, neutral melee hit regions and a ×1.5 base critical multiplier. Tie direct shield blocks to the player's wallpaper. Give Gojemarus visible coin drops per hit and make gift boxes flash during the last three seconds of a five-second lifetime.
- [x] Freeze both the pose and materials of the entire model. Give Ultra its own fractured ice maps and glossy highlights. Rebalance preview framing, make distant enemies clearer, add lake ice, snowbanks, heat bubbles and wind waves, and blend the Shrine and Sky panoramas during turns.
- [x] Raise Humontafagus to 108 base HP and shorten its attack interval from 5.1 to 3.8 base seconds. Speed up Void Crawlers, bring Veilskate slightly closer and reduce the boss health and damage rewards.
- [x] Add an unrestricted debug weapon picker, clickable active tiles and brief buffering for just-about-ready casts. Add inventory upgrade badges, an Item Upgrade Token for equipped or stored items, visible shop locks and immediate Purchased state.
- [x] Add 3× and 5×, stabilize Auto's aim, prioritize sealing during an Abyssal Takeover, and show difficulty bonuses and Auto tax in expedition results. Count wave clears toward Survival and collapse all legacy F modifiers to F.
- [x] Start desktop sessions in clean Idle. Ctrl fades Blackbox controls, and holding Ctrl+Space starts a Normal Wave 1 with a drawn weapon and companion after a red countdown. Keep the shortcuts scoped to the wallpaper and preserve the regular KDE taskbar. Keep paid next-run items and tarot omens assigned to a regular New Game.
- [x] Fix nested Plasma panel sizing and scenery coverage, keyboard and mouse turns, Escape return and duplicate workspace changes. Add separate resets for visual assets and desktop settings. Each paid tarot reading deals a fresh hand.
- [x] Pass 173 Qt checks and compile 147 QML components. Native input verified eye and wing damage, 3× and 5× controls, and Auto sealing at 5×. Nested Plasma verified navigation, Idle controls, countdown, focus isolation, and the restore shortcut. Both settings resets passed in an isolated profile.

## Idle schedule and desktop input · 0.4.7

- [x] Cycle Idle lighting through Day, Sunset, Night and Sunrise, with 10 minutes per phase by default and a setting from 1 to 120 minutes. Roll one shared 70/30 weather forecast per phase. Consecutive active effects differ. Verify exact boundaries, solar position and the weather distribution with 1,000 sampled phases.
- [x] Split Desktop settings into six scrollable sections. Check available height, scroll limits and key capture at 350 × 510. Add a lineup toggle and preserve immediate Wave 1 entry on quick start.
- [x] Rebind gameplay keys, mouse buttons, wheel switching and both Idle shortcuts. Preserve binding and preview options in standalone backup files. Test duplicate rejection, remapped turning, shield holds, ability chords and pause.
- [x] Enable linked KWin desktops without temporarily pausing combat. Verify a turn into the Droid Lab and a KDE workspace switch back to the Shrine. Open regular KDE System Settings from the same nested desktop.
- [x] Scope wallpaper launch and restore to the current Activity. Verify that a second Activity keeps its own wallpaper plug-in and clock widget through the Blackbox shortcut and restore sequence.
- [x] Stage the desktop packages, pass 176 Qt checks and compile 148 QML components. Verify the default and a remapped quick-start chord in nested Plasma.

## Idle actions, kit ownership and the KDE panel · 0.4.8

- [x] Use the wallpaper work area for Idle turns. From the Shrine, reaching the bottom edge above the Plasma panel opens the Abyss. Re-enter the scenery before repeating a turn.
- [x] Hide the Idle toolbar while a drawer or book is open and restore it on close. Remove the bottom-left desktop controls and move Builds to Scene editor.
- [x] Add native wallpaper actions for Play and Idle settings. Start the countdown with Ctrl+left click or held Ctrl+Space, including when the toolbar is hidden. Record either binding in Idle settings. The quick start enters Normal Wave 1 with a random weapon and pet.
- [x] Color equipped and stored kit members green in Loadout. Shop, rewards, inventory and gear hovers identify other kit pieces already owned in that run.
- [x] Give the Blackbox panel badge a black background under both light and dark Plasma styles. Add a reversible Plasma Style choice through KDE and a panel action to activate the wallpaper on the current layout. Add KDE’s regular System Tray to the isolated preview.
- [x] Stage 0.4.8, pass 178 Qt checks and compile 148 demo QML components. Verify mouse turns, both native menu actions and both hidden-toolbar shortcuts in nested Plasma. Verify mouse binding capture in the settings drawer.

## Folder View, shared HUD and recovery · 0.4.9

- [x] Restore top-right clicks and start Idle edge turns immediately. Keep the native Folder View selection rectangle and its files accessible over Idle. Verify a drag to an edge selects both sample files without turning, then test the right-click menu and both quick-start shortcuts.
- [x] Put the black BX badge next to the clock in the preview. Use KDE's Bluetooth, Disks & Devices and clipboard tray widgets. Preserve real panel configuration, expose KDE Night Light and HDR, and let users apply and restore Plasma style and app colours independently. Verify clipboard transfer between two private Wayland applications.
- [x] Keep one animation while linking wallpapers to KDE virtual desktops. The private session restored its original Slide effect on unlink. Add an input boundary for background Auto and document the wallpaper-only packaging option.
- [x] Add optional roaming companions and shared appearance settings. Test the Idle pet advancing to a different model on reload and suspending under Safe rendering. Fade the transparent combat HUD with Ctrl, align the clickable Q/E tiles, and show staff and melee readiness instead of ammunition.
- [x] Add gear sales, full locked listing cards and the Pawn counter achievement kit. Raise the shield threshold to 30% and cost to 20%, preserve the parry cue, let thunderstorms inherit rain and increase Electric damage, and slightly reduce boss health boons. Verify Debug Auto at Wave 120.
- [x] Test the same Hard Wave 20 checkpoint in the standalone demo and Plasma using Ultra 3D. They agreed on phase, wave, HP and ammunition. Verify all four fog turns and their route back. Compile 152 QML components and pass 181 Qt checks and three recovery tests.
- [x] Add in-game bug reports with an optional screenshot and a persistent issue ledger. `python Desktop/checks.py` records failed runs. Live wallpaper recovery passed in nested Plasma. Service restart and layout edits were tested using a temporary config and simulated service calls.
- [ ] Recheck physical HDR and Bluetooth devices, long 4K weather sessions and every pre-wave hover. Idle effects default to 12 Hz and Safe rendering is available. Several short samples of total GPU use did not show a reliable decrease. One concurrent offscreen tutorial check crashed in Qt and the serial rerun passed. [Issue ledger](ISSUES.md)

## Idle controls, settings and weather · 0.4.10

- [x] Hold Ctrl to use an arrow or mouse edge in Idle and Performance. Verify no accidental Abyss turn when approaching the panel, and retain drag selection and both quick-start gestures in nested Plasma.
- [x] Enlarge the Idle companion and size it from the desktop work area. Verify 1080p-to-4K scaling and narrow-window fit.
- [x] Tighten numeric controls and improve text contrast in appearance settings. Test scrolling and input remapping at 450 pixels wide.
- [x] Remove visible borders between cloud layers and refine standard and Ultra rain. Check five winding cloud positions and both rain presets with captured frames.
- [x] Stage 0.4.10. Pass 185 Qt checks and three recovery checks, compile 152 QML components, and run the same Ultra Wave 20 checkpoint in the demo and nested Plasma. Verify the clipboard and live recovery in the private session.
- [x] Select Blood Shrine for the shared layout.
- [ ] Perform longer weather and hardware checks before everyday use in the main Plasma session.

## Blood Shrine and combat polish · 0.4.11

- [x] Build the Blood Shrine layout around the player portrait. Match pause, pre-wave, shops and settings. Center the forecast badge. Keep the pause and BX frames fixed across tabs.
- [x] Check dragging an active from storage into the loadout between waves and hiding its grip during combat. Show a red kit badge only for complete kits with a stored piece, and green only when all parts are equipped.
- [x] Verify the BX theme chooser in nested Plasma. Offer Blood Shrine, Armory Grid, Field Terminal, Black Dossier, Lockdown and Dark. Keep KDE appearance switches separate.
- [x] Verify countdown cancellation by Esc and right-click, plus Esc pause and resume in the West Approach. Confirm retirement ends the run with an expedition report and does not unlock Auto for the unfinished wave.
- [x] Match muzzle effects with the animated barrels on the twin pistols, SMGs and shotguns in both renderers. Capture Ultra cooling smoke. Verify a purchased barrier remains equipped into combat and absorbs damage.
- [x] Stage 0.4.11, compile 158 QML components, and compare the same Ultra Wave 20 checkpoint across the demo and nested Plasma. Pass 187 Qt checks and three recovery tests on the final run. Verify live recovery and clipboard transfer in the private session.

## Exclusive kits and deliberate Idle launch · 0.4.12

- [x] Leave unused equipment and inventory slots blank and use a chained padlock for locked slots, including the combat HUD and shop.
- [x] Share one exclusive roster of 137 kits. Add distinct equipment for repeated kit members and balance the three catalogues. Preserve named kit bonus IDs and existing gear IDs.
- [x] Validate keyboard hold and modified click end to end. Test accidental input, old remaps, intentional starts and countdown cancellation in a private Plasma session.
- [x] Remove the two legacy rooms and their placeholder assets. Keep the five-room KWin workspace mapping and the existing animation handoff.
- [x] Stage 0.4.12, compile 159 QML components, and pass 188 Qt checks and three recovery tests. Verify the Ultra Wave 20 checkpoint, clipboard and recovery in the private session.

## Workspace cube, Pure Code and live Idle scenery · 0.4.13

- [x] Open the six-face cube through KDE Peek or the wallpaper controls. Provide face selection, a custom backdrop and 16:9 framing in both hosts.
- [x] Route West, Lab, Sky and Abyss to the optional rear face without exposing Pure Code to combat. Link six ordinary KDE workspaces and restore the prior workspace on unlink.
- [x] Launch a dedicated Konsole with the normal user shell. Provide `box me`, room navigation, settings and art commands. The terminal opens as a regular window on the Pure Code workspace.
- [x] Keep Idle scenery active behind focused applications when enabled. Register remappable KWin shortcuts and show the pet in a click-through Wayland layer. Use the active non-fullscreen window and available desktop icons and widgets as perch candidates.
- [x] Animate pet flight and long sleep, add pointer curiosity and chirps, and place larger droppings below the pet. Animate stock foliage and lanterns, with cloud shafts and lake highlights in Ultra.
- [x] Stage 0.4.13 and compile 160 QML components. Pass 191 Qt checks and three recovery tests. Verify the KDE Peek action, backdrop presentation, sixth linked workspace, in-focus Konsole background turns and pet rendering in a private Plasma window.
- [ ] Test physical multi-monitor, long 4K GPU use, real speakers, and rarer pet poses on different Folder View layouts. Consider embedding the terminal as a wallpaper surface if it can preserve ordinary KDE terminal behaviour.


## Compositor cube and Pure Code input · 0.4.14

- [x] Ship optional Blackbox Cube as a declarative KWin effect. Reuse the six-room QML view and route navigation through the Qt bridge, with native shortcuts and Screen Edges configuration.
- [x] Verify the cube above windowed and fullscreen Konsole, Escape focus restoration, the configured top-right hot corner, linked KDE room selection and the wallpaper fallback. Verify Play suspends the wave while the effect is open and resumes the same wave after a room change.
- [x] Move Open terminal to the desktop input layer. Confirm a direct mouse click launches Konsole in Folder View.
- [x] Stage 0.4.14 without editing the primary desktop. Compile 160 QML components, launch the standalone demo, and pass 191 Qt checks plus five recovery and rollback tests.
- [ ] Verify focus and effect behaviour on a physical multi-monitor setup and test another supported Plasma release before wider distribution.


## Embedded Pure Code and perch tracking · 0.4.15

- [x] Keep sleep animation silent. Track visible application windows, Folder View files and folders, and widgets as Idle perch candidates. Verified actual folder and application-window landings in private Plasma.
- [x] Expose a separate background Idle toggle in Desktop settings. Verify the wallpaper turns while another app keeps focus.
- [x] Embed the user's shell with a Linux pseudo-terminal and a libvterm-backed Qt Quick view. Keep normal shell history, keyboard input, Ctrl+F, and native clipboard. Verified copy and paste with another app and returning to existing panes after a room change.
- [x] Tile independent shells and linked output panes on either axis, with draggable dividers and live palette changes. Verified divider drag and output mirrored from a live shell.
- [x] Add the animated `box me`, typed settings, expandable help, full command reference, and per-shell game-practice commands. Verified an authenticated command chain configuring a Hard wave 20 practice build.
- [x] Stage 0.4.15, launch the standalone demo, and pass 195 Qt checks and eight CLI, recovery, and rollback tests.
- [ ] Check additional Plasma versions, physical multi-monitor perches, and more full-screen terminal programs before wider distribution.

## Pet terminal and KDE dark defaults · 0.4.16

- [x] Expose Pet admin, live mood, and the Ctrl+P mini console in the wallpaper and BX. Share 93 pet commands with `box pet`, print expandable help, and write bug reports to the local issue ledger.
- [x] Verify first-activation dark Plasma and Breeze Dark app colours in an isolated profile. Retain the separate restoration controls and the user's ordinary Plasma layout.
- [x] Verify a GUI-approved append, non-overwriting copy, and graceful close of a selected Konsole. Verify drafts on Pure Code and on the West wallpaper. Both drafts wait at the shell for Enter.
- [x] Verify Vesper's banana pose, Wendy's egg pose and neutral mood floor, and WAV playback state and quiet. Add an independent Pure Code backdrop, terminal opacity, per-room droppings, flight routes and local pet antics.
- [x] Stage 0.4.16 and pass 195 Qt regression checks and nine Python tests. Keep the main desktop configuration untouched.
- [ ] Check spoken voice and speaker-volume changes on hardware, and soak-test spontaneous mood changes and perches across multiple physical displays.

## Pet enclosure and game-practice access · 0.4.17

- [x] Persist the practice unlock in the Blackbox desktop profile. Verify that a second shell can use it, explicit locking revokes it, and `box exit` returns to the Shrine.
- [x] Verify enclosure capture, resizing, moving rooms, release and blocked outside tasks. Give mood-dependent click and face reactions, and recover cleanly when an action fails.
- [x] Use original short melodies and species-specific calls. Add Rime Falcon's charged freeze, Vesper's weakening bananas and glitch tricks, and Thorn Fairy's occasional healing to the shared game.
- [x] Fit the full pause Loadout at the minimum supported window size while Settings keeps the same frame. Stage the release and pass 199 Qt checks and nine Python tests.
- [x] Reconstruct the original template and 82 archived source checkpoints and prepare the current workspace for the private GitHub repository. See [recovery details](HISTORY.md).
- [ ] Listen to the pet voices on physical speakers and check the enclosure's 30-minute mood change in a long Idle session.
