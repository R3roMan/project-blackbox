# Project Blackbox gameplay demo

Open Konsole and run these commands from the project folder.

~~~bash
cd /home/blaxim/Projects/PROJECT-BLACKBOX
qml6 Demo/Demo.qml
~~~

Choose **New game**, choose a difficulty, then pick a companion and a starting weapon from their three offers. Start the wave or choose **Skip pet** to play solo with your selected weapon. **Controls** has the keyboard and mouse guide and the current input reference. The demo pauses on focus loss or minimisation. The [desktop plugin bundle](../Desktop/README.md) supplies wallpaper, panel, visibility and optional styling. Try `./Desktop/preview.sh` in a visible nested desktop first.

## Controls

| Input | Action |
| --- | --- |
| Mouse | Aim. The reticle follows the equipped gun's actual spread. Frost slows the reticle and turns. |
| Left click or hold | Fire. The cycle meter fills until the next shot is ready. Hold through the spin-up on a rotary gun. |
| Hold Shift | Aim through the equipped weapon's scope. Marksman scopes zoom farther than iron sights and wide sights. |
| Mouse at a screen edge | Turn immediately toward a reachable view. Hold Shift to aim near an edge. |
| A / ← and D / → | Turn one ground view. Right from the Shrine reaches Droid Lab and Left returns to the Shrine. |
| W / ↑ and S / ↓ | From the Shrine, look up into Star Sky or down into the Abyss. Reverse the direction to return. |
| 1 / 2 or mouse wheel | Switch weapons. Each gun has its own magazine. |
| R or right click | Reload, perform a melee trick, cast a charged staff spell, or thrust the Demonic trident. |
| Hold Space | Keep the field shield raised. Release it to fire. A standard shield recharges for 4.5 seconds after a block or a release. |
| Q / E | Use an active ability. The two side tiles show each ability's own cooldown. |
| Hold F | Look into the Abyss and hold for fourteen seconds to seal the rift for this wave. Progress stays when you look away. |
| T | Pause and open the combined Loadout. Inspect gear at any time in Pause and move it between waves. |
| Esc | Pause or resume. The menu has Loadout, Waves, Settings, Save run, Restart run and Quit to Home. Unlock all gear in Debug to show the Debug gear tab. |
| . | Toggle the wave timer. The corner speed button cycles 1×, 2× and 0.5×. |
| F11 | Toggle full screen on the current display. |

The five dots in the bottom corner show your current view in mint and threatened views in red. Click a reachable dot or use the turn keys. Red triangles point to offscreen threats. When a boss is waiting, follow the yellow exclamation arrow and siren. An orange ring fills around a demon during its attack windup. A hit splashes blood along the display, and the edges pulse below 35% health. **Mouse edge turns** is on for new profiles. Toggle it in Settings. Move a short distance away from an edge to use it again.

The melee trick prepares one stronger hit. After the animation, aim at a distant enemy on the current wallpaper and click to dash forward, strike, and return. Attack without the trick for faster close-range swings. Three closely timed Katana attacks make a slash, a swipe, and a stronger third hit. Katana, Dark lightsaber, Ember edge and Chainsaw kills cut enemies into two falling pieces. Hold the Chainsaw through rev-up and let its motor cool when the heat meter fills. Normal staff attacks charge the staff's R spell. Watch the runes and the weapon itself to see when the spell is ready. The held weapon leans toward your mouse. Each scope zooms around that same aim point and tightens the shot spread. Its gauge shows attack readiness.

## Display settings

The demo opens maximised on a 4K display. **Display** at run setup and **Pause → Settings** offer Fill, Fit entire image, Stretch, zoom and a render resolution cap. **Auto** preserves native wallpaper framing and caps the 3D field at1440p. Try **1440p** or **1080p** to reduce the cost of drawing the 3D field. These settings persist. The original wallpaper images are preserved. Filling a 4K screen scales the existing artwork. [Qt high DPI](https://doc.qt.io/qt-6/highdpi.html)

## Waves, difficulty and practice

| First wave | New encounter |
| --- | --- |
| 1 | Three Silophosus in the Shrine Path on Normal. |
| 3, 5, 6, 7, 8 | Fhantamegus warps every three seconds. Hosphoragus roars and stuns. Skorochiyus fires two Burn II fireballs. Spartalien fires from Star Sky. Iceterapus accelerates when hurt and resists Frost. |
| 10 | Humontafagus summons three demons at half health. |
| 11, 13, 15, 16, 17, 19 | Void Crawler, High Fizzalien, Ghorimagous, Tenmani, Bergensus and Gojemarus. Ready a shield if Tenmani reaches out with its tentacles. |
| 20 | Mastafangenbus crosses ground fronts and winds up spinning shards on approach. Its shards and melee swings have a 30% critical chance. |
| 21–29 | Gendoustagus, Mothergalian, Nindumipus, Zadrrimus, Lantis, Rerogorubus, Jonbosporo Fighter, Princoratus and Clap Trap. Mothergalian fires five shots at once. Aim away from Lantis's lamp when lit. Kill every hallucination to escape its trance. |
| 30 | Gigafinterus breathes level 3 Burn and lashes its tail. |
| 32, 34, 36 | Helboranius shields foes behind its bulk, Jospharemus stops and covers its eyes while watched, and Seraphijus displays its 15-second detonation countdown on its chest. |
| 38 | Shadow sends one telegraphed ink blast and leaves stains for the wave if it lands. Ten kills unlock Mini Shadow. |
| 40 | Lucifoverus strikes with a trident and a level 1 status, then warps to another ground front and recovers for five seconds. |
| 42, 43, 46, 49 | Lala Bubu's shots only land while you share her wallpaper. Her death causes Curse and ten seconds of reversed turns. Go Go Battlestar charges a sustained laser. Skarabatunus steals gold. Faeel's Electric bite stuns for two seconds. |
| 50 | Hasasasa Forum descends into Star Sky. Intercept its shots, hit the moving emitters at the ends of its tubes, then hit the exposed cannon. A broken emitter calls two reinforcements and raises a fresh barrier. |
| 53 | Capablancamus closes fast and waits between heavy strikes. Half of those strikes crit. Your critical hits deal their ordinary damage to its armor. |
| 56 | Three linked Trispiramahedus spawn together in Star Sky. Each fires Electric with a 30% Stun chance. Nearby linked allies move 30% faster and gain attack cadence and critical chance. Kill a magnet to break its links. |
| 58 | Nightosphere repels statuses, fires blinding shots and summons another Void creature every ten seconds. |
| 60 | Stinkaturumus exhales level 3 Poison and can call up to three Saslimigus at once when hit. Shoot the small peons or intercept their Sticky slime globs before they land. |
| 62 | Helesepeptium coils at 3,950 units and fires interceptable level 2 Electric bolts. Use a scope to see its head and coils at range. |
| 64, 66 | Archfellanus reflects hits during its gold mirror and turns your companions against you. Endme has eight eyes that close one at a time when hit. Close them all to expose it for six seconds. |
| 65 | Feta Spotter snipes from 5,250 units. Damaging shots send the droid to a new perch on the same wallpaper. |
| 68 | Nosferapabakus recovers health by biting you, or by turning and lunging at another demon. |
| 70 | `?!:!E#DR#FJD` starts in the Abyss, roams across the views, fires interceptable shots with 50% critical chance, and calls **???** every 15 seconds while the Void slot is clear. Its half-health glitch persists even while scoped. |
| 73 | Fearme arrives far away and early in the wave. Its slash halves maximum health for the wave and bypasses shields. Defeat it before it sinks into the Void to unlock Fearme's Harvest. |
| 80 | Reapfast Leviathan rises in the Abyss. Its saliva bubbles can harm it during suction. Watch for the charge and the weakening roar. Below half health it attacks faster and can fire its fangs. Shoot them in its mouth or in flight. They regrow after 30 seconds. |

Most enemies materialise at 1,750 units. Each stage has a limit on live enemies. Arrivals and summons wait for room. Normal waves materialise one scheduled Abyss creature at a time. Broods and Void incursions have their own rules. The boss comes last every ten waves and waits for your first visit before its entrance. The count at the top excludes summons, broods and split copies. A Trispiramahedus group is one spawn and takes three spaces. The eight bosses repeat from wave 90. Mobile bosses speed up at quarter health. Hasasasa and Reapfast hold their starting fronts. A rare shade called **???** can black out the field after wave 10 and drifts away without paying gold.

Normal introduces the roster and keeps the opening waves spaced out. Hard increases arrival pressure, enemy stats and the rate of scaling. Insane adds more enemies and increases the need for a strong build. Health and damage scale together every ten waves by 22%, 32% or 40% of base stats on Normal, Hard and Insane respectively.

Turn on **Debug** at run setup to practise from a tenth wave, up to wave 150. Choose Standard, a randomly scaled kit, or Star Destroyer+. The last option starts at 9,999 HP and fires a fast-charging 100-damage laser with infinite ammo. The scaled build raises maximum health by 25 per ten-wave block. Turn on **Unlock all gear**, then open **Esc → Debug gear** in the run to equip any weapon, passive or active from the catalogue. Debug access lasts for that run. Earn permanent achievement rewards on regular runs.

## Builds, rewards and shop

- A fresh run starts with 200 health, one weapon, one empty active slot and four empty passive slots. Clearing a wave restores 8%, 6% or 4% of maximum health on Normal, Hard or Insane. The shop can expand the build to two weapons, two actives and eight passives.
- An even-numbered clear offers three rewards. Boss waves use their boon and shop instead. The next roster then appears above the combined loadout. Edit your equipment and choose Begin wave; there is no second confirmation. A gift or reward can grant one immediate heal. A repeat gear card upgrades its item up to Lv 3 and explains the next stat change. An empty slot fills automatically. For a full group, click a destination once, drag the reward by its handle, or choose **Store in inventory**. Newly collected gear starts at Lv 0.
- **T** opens the Pause inventory with five storage spaces. A shop listing can add up to five more. During preparation, select or drag a stored item to a compatible slot. Reorder equipment within a group from the combined Loadout while between waves. Gear carries its rank and numbered slots keep their slot abilities. Hover over equipment portraits to inspect the item or slot effect.
- Each of the 97 weapons, 97 passives and 97 actives has a primary kit. Equip its three items to enable the bonus. Search **Galleries → Kits** by item or kit name. The Loadout tab shows complete kits, critical chance and multiplier. **Bone shatter** briefly boosts both critical stats and **Soul reaper** grants a small damage increase per kill until the wave ends. **Jester's Verdict** is a rainbow shotgun with a deck of six status effects. It applies one colour to all pellets each shot.
- After a boss, choose a run-long health (+75 to +135 HP), damage (+24% to +52%) or turn-speed (+17% to +38%) boon. Visit Last Stop Supply for a fresh set of listings. Buy Counter expansions to increase capacity from five to eight. Purchased rows stay sold during the visit, including through a refresh.
- Repeat luck adds a 5.5% extra chance to draw eligible owned gear after the rarity is rolled. Shop upgrades raise it to 17.5%. Wrapped mystery caches reveal Epic or Legendary gear at 80% and 20% respectively. Claim the revealed item in a slot or inventory before leaving. Loaded dice replaces equipped gear with random items of the same rarity at Lv 0.
- Pet, reward, boss boon and shop screens each have a free refresh and a skip button. **Second look** adds another refresh. Mega gifts can add a refresh you can save for later.
- Rarity colours are blue, orange, purple and glowing yellow for Common, Rare, Epic and Legendary. Mint identifies Unique companions. Every gear draw includes a Rare-or-better ability. The calendar adds an Epic around five waves and a Legendary around fifteen. The shop sometimes offers Epic and Legendary gear. Star Destroyer joins the Legendary draw at wave 18 with a 17-damage beam and a longer charge. Its kills trigger an explosion that rises to level 3 with upgrades. Regular beams lose damage as they pierce targets. [Qt View3D picking](https://doc.qt.io/qt-6/qml-qtquick3d-view3d.html#pickAll-method)
- Thirteen Unique companions are immediately available and six more can be unlocked. The starting draft offers three. Each has its own duty and rest times. Pet tokens improve damage and cadence, extend duty, shorten rest and speed up travel for the current companion.
- Regular kills start at 10 gold and add two per ten-wave block. Bosses pay ten regular kills and Gojemarus pays five, plus 2 per shot. Career progress, the best wave reached in a regular run and 52 achievement rewards persist in `project-blackbox-demo.ini`. **Unlock all achievements** is a saved override that applies to future runs. Toggle it off to see earned progress. **Debug · Reveal all** separately shows undiscovered gallery entries while browsing.

## Elements, shields and pickups

- **Burn** deals periodic damage. **Frost** slows and sometimes freezes foes for two seconds. Higher levels increase both effects. Applying one clears the other.
- **Electric** arcs in white and violet. At level 1, it passes half the damage once to a nearby foe. Higher levels give more jumps, retain more damage and increase the chance of Stun. An Electric hit on the player restarts equipped active cooldowns. Player hits can interrupt enemy attack windups. The Arc shield achievement reward turns intercepted bolts into a discharge and raises a barrier.
- **Explosive** primes a target to detonate when it dies. Higher levels increase the damage and radius. Princoratus, Seraphijus and the meteor can hurt you with their blasts.
- **Weaken** reduces damage. **Stun** interrupts actions. **Blindness** darkens the view and gives either side an 8%, 17% or 30% miss chance by rank. Blinded enemies drift off course. **Knockback** pushes harder with each rank. The Breaker glaive, Breakwater .90 and Wind staff can push enemies away.
- **Poison** lowers the maximum health cap by 1%, 2% or 3% of its normal value each second at levels 1, 2 or 3. There is one dose at a time. Stinkaturumus's green cloud has a short wind-up, so you can turn away from it. Use Spore screen to shorten the dose and Emergency solder to clear it. Bilecaster and Mire charge spread Poison to enemies, and Spore detonation converts the accumulated cap loss into a burst.
- **Sticky** coats the screen green and locks your view for 1.6, 2.3 or 3.3 seconds by level. Keep aiming and firing while the countdown runs. The Legendary **Tarpit** pins enemies on one wallpaper. Its level 2 equipment upgrade raises Sticky to level 3. Status-immune enemies take 85% of a corresponding elemental shot's damage and resist its attached status.
- Gendoustagus curses its killer for the wave. A player curse increases damage taken by 20% and gives an eligible shot a 13% chance to misfire. Misfires leave the round in the magazine. Further curses leave the penalty at the same strength.
- Enemies with **Dodge** react when you hold aim close to them. Higher tiers react and recover sooner. Shots still hit if you track their movement.
- Hold **Space** to raise the field shield. The blue HUD bar shows remaining blocks or time to recharge. Fleet shell and Perfect guard spend their charge on release or expiry, and a timed parry rewards the first 0.2 seconds of a Perfect guard. Bulwark adds a block with heavier turns and longer recovery. Jester ward varies the benefit and cooldown on its first block. Shops sometimes sell shield upgrades, and abilities can use stored impact, add a block or speed up recovery. Guard lining can soften area damage such as beams and ground blasts. The first equipped shield transformation in slot order controls the shield's form.
- A barrier is the separate blue health filter. Temporary barriers come from gear or supplies. The shop also sells a core with up to four charges per installation. Any barrier absorbs the whole hit that breaks it. Surviving charges carry through turns and waves while the timer or core lasts. Buy another rank or use a barrier-granting ability to get fresh protection.
- Weapon attacks start with a 5% critical chance at ×2 damage. Precision weapons and equipment can increase those values. Critical hits against you can be blocked with the field shield. Block five across one run to unlock Soft landing.
- Shoot gifts before they fade. Five out of six ordinary gifts help. Cursed gifts can reverse turn inputs for six seconds, tax cooldowns or weaken a combat stat. Mega gifts are larger purple and gold crates with a bright rim. They can grant gold, a refresh, a temporary pet, infinite ammo or a blast.

## Weather

Explore the full list in **Galleries → Weather**. Night adds Blindness I and makes enemies 5% stronger. Rain extinguishes Burn, guarantees a full freeze from Frost, and doubles Electric damage with chains across the five fronts. Winter applies Frost I every five seconds to you and susceptible foes. High winds add a 15% chance to miss, strengthen pulls and pushes by 70%, and strike enemies with a small damaging gust every 20 seconds. Glitch reverses aim, direction keys and paired inputs for the wave. Use right mouse to fire, left mouse to reload, E for slot one and Q for slot two. Hold Space to shield, hold Shift to scope and press Esc to pause. Void incursions bring dark tentacles and Abyss arrivals to any wallpaper.

## Audio, graphics and tests

The demo uses its original soundtrack with wave-block, boss, pause, low-health and late-boss variations. Hasasasa and Reapfast enter during a break in the music. Reapfast has a separate fast sonar-driven score, inspired by the tension of Subnautica, and Last Stop Supply has an original retro loop. Storms and arrivals have distinct sounds, and distant cries and echoes play during waves. [Subnautica Original Soundtrack](https://store.steampowered.com/app/1619300/Subnautica_Original_Soundtrack/)

The regular demo uses Qt Quick 3D. The software view uses the same rules with drawn sprites. Use the commands below from the project root.

~~~bash
QT_QUICK_BACKEND=software qml6 Demo/Demo.qml -- --software --mute
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software /usr/lib/qt6/bin/qmltestrunner -input Demo/tests
~~~

On Arch the Qt components come from `qt6-declarative`, `qt6-quick3d` and `qt6-multimedia`. The included audio files play directly. To regenerate effects, use `python Demo/tools/make-audio.py`. To regenerate the music, use `python Demo/tools/make-music.py` with NumPy and FFmpeg installed.

## Learn your way around the source

| File | What to follow |
| --- | --- |
| [Demo.qml](Demo.qml) | Home, saved settings, galleries and switching between modes. |
| [Encounters.js](game/Encounters.js) | Enemy stats, first waves, difficulties and spawn timing. |
| [Rules.js](game/Rules.js) | The simulation step. Follow `shoot` → `wound` → `remove` for a click that defeats a demon. |
| [Elements.js](game/Elements.js) and [Ship.js](game/Ship.js) | Status tiers and the gun-tube and cannon phases. |
| [Loadout.js](game/Loadout.js), [Defense.js](game/Defense.js) and [Selection.js](game/Selection.js) | Gear, kit bonuses, shield transformations, selection screens and the shop. |
| [PlayScene.qml](game/PlayScene.qml) and [LoadoutGrid.qml](game/LoadoutGrid.qml) | Input, HUD, dragging equipment and opening the menus. |
| [World3D.qml](game/World3D.qml) and [AttackArt.js](game/AttackArt.js) | The camera and model positions. Pose values translate an attack into motion. |
| [Optics.js](game/Optics.js) and [ScopeView.qml](game/ScopeView.qml) | Scope types, zoom, spread and reticles. The same aim point drives both renderers. |
| [WeaponModel.qml](game/WeaponModel.qml), [WeaponArt.js](game/WeaponArt.js) and [MeleeArt.js](game/MeleeArt.js) | Held geometry, recoil and reload pose. For blades, compare the idle grip and the centre of the spin. |
| [Pets.js](game/Pets.js) and [Progress.js](game/Progress.js) | Companion balance and persistent achievements. |

For the desktop architecture and upgrade/revert path, read [Desktop maintenance](../Desktop/MAINTENANCE.md).

Try changing Silophosus's travel speed in `Encounters.js`, then replay the first wave. Change the Service pistol's `delay` in `Loadout.js` and watch the reticle's recovery. Next follow `Qt.Key_Space` in `PlayScene.qml` into `holdShield` in `Rules.js`. Change the standard shield's recovery in `Defense.js` and watch the HUD after a successful block. Use **Debug → Wave 70** to see the half-health glitch, then find the condition that starts it in `Rules.js`. [Build synergy discussion](https://www.reddit.com/r/gamedesign/comments/x1u1ls/), [Roguelite cooldown discussion](https://www.reddit.com/r/roguelites/comments/1qoon3t/)

**Idle** opens the original room tour with interactive objects. **Performance** uses static art and immediate room switches. **XD courtyard** is a bonus 3D Shrine study. For the original wallpaper and the rebuild tutorial, open [V0.1](../Dev/BUILD-V0.1.md). For the beginner sequence, Blender exercises and KDE integration, start at the [build and learning plan](../Dev/BUILD-AND-LEARN.md).


## Current continuation additions

**Tutorial battle** on Home teaches aiming, reload, shield blocks and side views, then lets you fight Oblogabgalus in two phases. Dialogue freezes combat while the models idle. Failed lessons rewind the current step. Completion unlocks Graduation pistol. Papapoganus debuts on wave47 with a five-second poisonous spray and vision stains; five defeats unlock Yellow noon. Common and Rare staffs, twin SMGs, twin shotguns and Siege RPG fill nine new complete kits. Wendy is the chicken companion's name.

Every active produces a matching effect. Staff charge is shown both on the model and in a dedicated HUD bar. Hover cards wrap and show upgrade level, weapon damage/handling and active cooldowns. Conditional abilities explain their calculation rather than inventing a fixed damage value. The gallery is one animated grimoire with unknown pages, pencil rendering, chapters, blood-stained paper and individual achievement medals. The book and tutorial have new scores; the original combat tracks remain.

Pause → Save run updates one save slot. Home → Continue restores its wave, build and battle state. New game leaves that save intact until the next save. Main-menu Settings exports/imports achievements, discoveries, records, preferences and that saved run in a `.blackbox.ini` file. Replaced equipment moves into a free inventory cell; with a full inventory the replacement discards it. Kill/death and weapon records can be sorted in the book. The trident belongs to Staffs while retaining its right-click thrust.

Graphics settings include a20–240 custom frame-update cap, edge quality, transition depth, framing and rendering resolution. Effect textures and refresh rates are bounded, far/offscreen models skip work, and hallucinations stay at a hittable distance. This reduces rendering cost; actual performance still depends on the display, driver and chosen scene.
