# Project Blackbox handoff

Start with the [build and teaching plan](BUILD-AND-LEARN.md), the [V0.1 rebuild](BUILD-V0.1.md), and the [detailed implementation plan](IMPLEMENTATION-PLAN.md). The [demo guide](../Demo/README.md) documents the active rules and includes source exercises.

## What to run

- `qml6 Demo/Demo.qml` opens the standalone demo. Play is the fixed-aim, five-view shooter. Idle offers a room tour with the new shared backgrounds. The separate XD Shrine study remains in the source for future work.
- `qml6 V0.1/Preview.qml` opens the archived wallpaper. Its original code and artwork stay in V0.1.
- `QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software /usr/lib/qt6/bin/qmltestrunner -input Demo/tests` exercises the game rules.
- **Debug** can start at waves 10 through 150, with Standard, a scaled random build, or Star Destroyer+. Enable **Unlock all gear**, start a run, then use **Esc → Debug gear** to equip and test a reward. Regular runs track career progress.

## Current implementation

- `Encounters.js` owns spawn distance, pacing and the difficulty presets. It introduces one new enemy at a time and reserves the final scheduled spawn for the boss. The eight-boss rotation begins with Humontafagus at wave 10, brings in the Void boss at wave 70 and repeats at wave 90.
- `Rules.js` owns the fixed-step simulation, attacks, view changes and progression. `Elements.js` and `Ship.js` own status tiers and ship segments. `World3D.qml` and `ProjectedWorld.qml` share live actor records through `ActorRoster.qml` so a spawn or removal preserves unrelated models.
- Equipment lives in `Loadout.js` and `Expansion.js`. The run starts with 200 HP, four passive slots and five inventory slots. The shop can raise capacity to eight passives and ten inventory slots. Every wave restores a share of maximum health. Rewards appear on even nonboss waves. Boss rewards are a permanent boon for this run and the five-listing shop. The combat timer starts the next wave automatically once any screen closes.
- `PlayScene.qml` handles input and the HUD. Q/E cooldowns, the five-dot minimap and signal arrows sit beside the weapon. The camera follows one eased turn between views. Auto sizes the 3D target to the display, and framing, resolution cap and mouse edge turns persist with the other display settings.
- `Demo/audio` contains original effects and music. Regenerate them through `Demo/tools` when changing sound. The music tracks adapt to wave blocks, bosses and pause. The Achievements page tracks all 26 rewards and previews their gear or pet. Career progress and discoveries persist in the user's Qt config directory.

## Verification and remaining native work

All 35 Qt checks passed. The saved rules tests cover waves 1–120, both early boss transitions, ship tubes, immunity, healing, equipment replacement, inventory, Debug and gold. The earlier 4K virtual KDE check produced a 3840×2160 render target and confirmed the 1080p cap. The window tests cleared Humontafagus and Mastafangenbus, hit a Hasasasa gun tube, and exercised Retry, reward dragging, inventory swaps, right-click reload, scroll-wheel switching, edge turns and barrier recharge. At 760×530 the inventory and achievement reward cards fit, and Star Destroyer+ hit two aligned targets. Qt decoded all 129 audio assets.

An isolated test cleared both reported crash waves. The original host crashes lack a usable crash record. Keep collecting the Qt error and Plasma session log if a crash recurs on the real machine. Next for the native wallpaper is the input probe in the teaching plan. Verify focus and Escape, click delivery, cover, lock, workspace changes and display scaling at the Home gate before porting the combat viewport. The player's current run is window-local and the template's saved room edits remain separate.

## Balance and slime boss checkpoint

Scheduled spawn gaps are 16% longer and standard attack intervals are 22% longer. Clears restore 8%, 6% or 4% of maximum health by difficulty. Boss health boons award +45 to +85 HP. In five scripted runs per difficulty, all Normal runs cleared wave 40. Two Normal seeds and one seed each on Hard and Insane cleared through wave 65. Hasasasa Forum stopped the other three Normal runs, which makes wave 50 the place to start the next balance playtest.

To practise the slime fight, start Debug at wave 60. Stinkaturumus has level 3 Poison and rolls a 20% chance on an eligible hit to summon a Saslimigus. It can have three live peons, with at least three seconds between calls and up to six calls per fight. Intercept the peons' slime globs or turn before they land. A hit puts a green film and countdown on the screen and blocks all turns for 3.3 seconds. Aim and weapons keep working. The boss uses the opening to change ground fronts.

The new gear is Bilecaster, Mire charge, Spore detonation, Spore screen and the Legendary Tarpit. The same dose of Poison cannot extend its duration. Elemental shots deal 85% impact damage against matching immunity and skip the status. Emergency solder clears Poison and heals 12% of maximum health. Arc shield discharges intercepted projectiles into the nearest demon. Upgraded equipment and purchased slot abilities gain colour-matched rims.

The software and isolated KDE 3D window tests hit Stinkaturumus with the Bilecaster, took a real slime projectile, blocked turns through WASD, arrows, the minimap and the mouse edge, then restored turning. Tarpit pinned the boss and started the correct HUD cooldown. The software test also fired Arc shield and checked the Electric jump. Restart cleared the Debug gear unlock while preserving the test profile's earned achievement.

## Arsenal and Battlestar checkpoint

The next pass covers Fhantamegus landing inside the visible field, first attacks as bosses reach range, and readable, interceptable Hasasasa shots. The new arsenal adds six melee weapons with distinct reload-button tricks, a thrown tomahawk, twin pistols, sustained lasers with heat, a reload bayonet and two evasion abilities. A loaded melee trick primes a stronger attack with a ranged option for space fights. Implement and verify the rules, both renderers, sound, Debug access and the new Go Go Battlestar before treating this pass as complete.

The follow-up adds a cap that queues summons as well as normal arrivals, a timed three-hit Katana combo with distinct swings, a gun that builds a hit streak, timed bursts on some existing guns and a new Rare burst gun. Add Wind, Fire, Ice, Thunder, Earth and Avatar staffs. Their regular attacks charge a unique R spell, with built-in charge effects and a visible counter. Give Wind a reusable ranked knockback effect and Earth ranked Stun. Add two achievement melee weapons, two achievement staffs and four more achievements with new ability rewards, plus seven generally available actives and seven passives built around the arsenal.

Presentation tasks include the first wave on every enemy gallery entry, distinctive silhouette and surface details across demons, props and pets, a Chicken companion, distinct pet attack poses with angry eyes, and three large flask-shaped wave rewards with a selection sound. Give each boss its own pentagram entrance and menacing cue. Keep the original music's arrangements and add variants for low health and the second half of a boss fight. Verify gear, actors, statuses, catalogue counts and combat controls together.

The latest follow-up requests long and correctly held Katana geometry, darker metal and surface wear on melee equipment, and visible impact blood with larger death spills, blade-specific patterns and boss-scale gore. Add Skarabatunus as a skeletal demon with glowing yellow gem eyes. It stops to fire a golden gold-stealing beam every five seconds and returns part of the stolen gold when defeated.

Also cover Pause slot-effect hover details and weapon portraits. Add a health-percentage damage and reload passive, Glass Cannon, Death Mint with shootable coins across all five views, and a visible sweeping guard that reduces damage from lined-up attackers. Add a Fairy and a pink-haired flying chibi pet. Cross-check equipment rarity and introduce Normal, Ascended, Nightmare and Overlord enemy tiers in the gallery.

Give the gallery tier-specific borders, Nightmare shadow and Overlord ember effects. Add a temporary gallery reveal for Debug. Set standard Star Destroyer to 17 base damage, review unfair gear, and add wet impacts, distant screams and echoes, and a loop for rain during play.

Use the equipment portraits for guns, weapons, actives and passives across both Pause and Inventory. Show item names and effects on hover in Build, Inventory, wave rewards, the boss shop and the companion draft.

Raise the durability of Hasasasa's projectiles while keeping their shot target in front of the tubes. Give mobile bosses a final-quarter movement boost. Lucifoverus charges with the trident pointed forward, and three kills unlock the firebolt-and-thrust Demonic trident. Rework fire around the trident and on burning enemies.

The 50-weapon arsenal passed 47 rules checks and the software and isolated KDE 3D window flows, including Fhantamegus after teleporting, Hasasasa projectile interception, the Katana combo, staff charge and cast, axe flight, weapon heat, equipment portraits and flask rewards. The two early boss fights and Retry were exercised in the window. Qt decoded 216 assets. The original soundtrack returned alongside variations for low health and the second half of boss fights.

Next release checkpoint. Keep Normal to ten enemies, mostly from early waves. Make the fallen angels' haloes visible, then add real camera movement and a targeted hit to a distant charged melee attack. Add the separate two-second Shield on F, eight-second recovery, shop upgrades, ten shield passives and two shield actives. The next wave must preserve a live barrier. Add global critical chance and power, shield-critical achievements and equipment, slower base burst recovery, stronger critical Mastafangenbus attacks, Capablancamus and the Trispiramahedus lightning group. Balance the three equipment catalogues, assign kit memberships, and show kits in Galleries. Verify charges, crits, telegraphs, linked enemies, shops and the shared UI before release.

Shield and critical pass landed in the standalone demo. The ten Normal enemies and dark angel haloes are in both renderers. R primes a distant melee dash and its attack resolves at mid-lunge in either renderer. F raises the innate guard. Barrier timing and charge state survive entry into combat. Four shield transformations, ten primary shield passives, shield actives, critical effects and four achievement rewards are in the progression data. The guard-block achievement stores a best single-run count. The standard player critical chance is 5% at ×2. Mastafangenbus has a 30% critical chance with 43 base melee damage and ranged shards at 36% of that before scaling. Capablancamus debuts on wave 53. The three Trispiramahedus debut on wave 56, reserve space together, and draw their Electric links only to live actors.

Each of the three equipment groups has 73 ordinary items. Every item has a primary three-piece kit. The searchable gallery presents the sets, and Pause, Inventory, the shop and rewards show portraits and effect hover details. Audio regeneration added distinct reports and reloads for the new weapon variants and cues for the field shield and critical hits.

The scope follow-up adds O, pointer-following weapon poses, eight reticle families and per-weapon zoom. A frustum camera anchors native zoom at the pointer. The software projection uses the same magnification and centre. Helesepeptium debuts on wave 62 at 3,950 units, stays planted, and fires interceptable Electric bolts. The ordinary spawn plane is 1,750 units. See `Demo/game/Optics.js` for scope profiles and `Demo/game/SerpentRig.qml` for the enemy model and attack geometry.

All 52 Qt rules checks passed. Qt decoded all 268 audio assets. Private KDE 3D and software window checks aimed and landed shots on Helesepeptium, activated the shield with F, crossed views with it raised, and tested the lunge, triad links, scopes, interception, kit search and gear portraits. Separate window checks covered the wave 10, 20 and 50 boss encounters, Retry, the stock and confirmation flow, drag and click placement, and 760×530 layouts. The temporary window harnesses and screenshots are under `/tmp/blackbox-arsenal`. Whole-run difficulty tuning still needs human play. The native Plasma wallpaper work can resume at the input probe in `Dev/BUILD-AND-LEARN.md`.

One parallel offscreen window check exited with code 139. Three isolated software window runs then passed. If it recurs, capture the native backtrace and note the last checkpoint printed by the window harness.

## Hold-to-aim and mouse turns

The current controls use hold Shift for the scope, Space for the field shield, and hold F for Void sealing. Mouse edge turns are enabled for new display profiles. Each edge has its own crossing state, so moving into a corner starts a single turn. The passive hover observer still tracks movement over the HUD. A separate mouse-drag path keeps edge turns available while the fire button is down. Holding Shift lets the cursor work near a screen edge while keeping the view steady. Pausing or leaving combat clears held input. Use `Demo/tests/tst_Controls.qml` to verify these cases.

The HUD and pause panels use new corner plating, streaks and pooled blood. A hit places fresh blood near the screen edges, and a wound deepens the red at low HP. The blood also appears on the pause and inventory framing. The central aim area and gear labels remain readable.

The control regression tests exposed key repeat carrying Space from a shield press into the reward screen. Buttons now ignore repeated Space presses. A fresh keyboard press still selects the focused reward. The Pause Build tab also shows combat stats on solo runs.

All 62 Qt checks passed. Software and private KDE 3D window tests exercised immediate edge turns, Shift scopes, Space shield, Void sealing and sticky movement lock. Window checks covered waves 10, 20 and 50, Retry, a 760×530 window, reward placement and inventory moves. All 268 audio files decoded. The real key-repeat check and visual snapshots are under `/tmp/blackbox-controls`.

## Sniper, feeding and Inferno checkpoint

Feta Spotter debuts on wave 65 beyond the serpent and warps to another perch on the same wallpaper when shot. Nosferapabakus debuts on wave 68. A wounded Nosferapabakus may turn and dash at a nearby demon to bite and recover health. The Black Hole weapon opens a three-second pull on impact, and the kit expands it. Inferno can ignite both sides across all views. Players draft a weapon alongside the companion, and shop tokens improve companion damage, cadence, duty, rest and travel. Both renderers have the effects, including split-body finishes with the Katana, Dark lightsaber and Chainsaw.

The first starter draft implementation triggered a Qt JavaScript garbage-collection crash during the rules run. A backtrace and isolated copy under `/tmp/blackbox-new` narrowed it to the callback-heavy draft. The rewrite uses an independent seed and four numeric rolls in one pass. Repeat normal Qt tests during integration.

## Held melee, shield and seventh boss

The three-dimensional held camera frames the entire melee weapon, including the tip and grip during tricks. The software poses share `MeleeArt.js` and the gallery keeps full silhouettes. Long metal blades have brighter cutting edges. The seventh boss first spawns in the Abyss on wave 70. It fires interceptable bolts with a 50% critical chance, calls a shade every 15 seconds subject to the Void enemy limit, and distorts the battlefield even under Shift once it drops to half health.

Hold Space to raise the standard shield and release it to shoot. A clean release spends nothing. A block spends a charge, then the depleted shield recharges. Fleet shell and Perfect guard have timed raises, Bulwark has extra charges, and Jester ward rerolls its recovery and bonus on the first block. Guard pulse spends force accumulated in the current wave. Guard lining can soften area damage. See `Demo/tests/tst_Arsenal.qml` for timing and ability checks.

The old soundtrack recordings are in place with four additional Void boss tracks. Fire, reload and sustained sounds use the revised mix, and both combat and Inferno have ambient loops. Buffs in this pass target Black Hole, Grav hammer, Gallows rifle, Frostwing carbine, Weathered sixgun and Prism Array. Two scripted Normal runs cleared waves 10 and 20. Late-run balance can be checked with Debug at waves 60 and 70.

All 69 Qt checks passed. The software and isolated KDE 3D windows exercised the starter draft, Feta's perches, Nosferapabakus feeding, the Black Hole pull, split bodies, Inferno, and the Void storm with Shift held. A real dark projectile hit the raised shield and started its recharge. Both renderers passed the compact melee and Debug setup checks for all eleven held melee variants. The 4K window exercised the Katana and Mecha-sword tricks with the weapon render budget capped. The main-window regression cleared the first two bosses, broke a Hasasasa tube, and exercised Retry, reward placement and inventory swaps.

Qt decoded all 289 audio files. A private sound device confirmed gun, rail, staff and Black Hole reports and reloads, the Prism and Chainsaw loops, Inferno ambience and the Void score fading into its pause arrangement. The isolated Qt 3D harness still logs a render-resource cleanup warning during shutdown. Logs and temporary harnesses are under `/tmp/blackbox-new`.

## Abyss expansion checkpoint

The roster schedules Tenmani at wave 16, Lantis at 25, Shadow at 38, Lala Bubu at 42, Faeel at 49, Nightosphere at 58, Archfellanus at 64, Endme at 66 and Reapfast Leviathan at 80. Void Crawler stays at wave 11 and gains ordinary combat health. Nightosphere resists all statuses, Faeel resists Electric and Endme and Reapfast resist Poison. The catalogue adds six Abyss kits and two Frost kits, bringing each equipment group to 82. Ten Shadow kills unlock Mini Shadow. Achievement reward access is a saved gallery toggle that leaves earned records intact.

The current implementation has persistent within-wave Abyss sealing, delayed boss entrances with destination arrows, all four Leviathan attacks, and shield recovery on release or charge depletion. The shop has expandable listings, repeat luck within a rolled rarity, permanent run upgrades, a paid mystery cache and a purchaseable barrier that absorbs the whole breaking hit. The mystery cache uses the requested 88:22 as weights. Normal and mega gifts have separate silhouettes. Night raises enemy combat stats by 5% and adds Blindness I. Rain removes Burn, guarantees complete Frost and makes Electric do double damage with cross-front chains. Winter applies Frost I every five seconds. Original effects and new music for the supply counter and Leviathan are in the audio folder.

Both renderers and the main menu share these rules. The follow-up exercises the new shield recovery, barrier absorption, encounter timing and seal across the game and its tests.

## Weather, supply room and combat follow-up

The follow-up landed in the standalone demo. The catalogue now has 84 weapons, 84 actives, 84 passives and 41 achievements. Skorochiyus debuts on wave 6 with two Burn II fireballs. Fearme arrives early on wave 73 at 3,260 units. Its unguardable slash halves maximum health until the wave ends and it sinks back into the Void. The first kill unlocks Fearme's Harvest. The new gear also includes Bone shatter, Soul reaper, Parry, Colour spill and Jester's Verdict. Mothergalian fires five shots in its attack. Blindness tiers add 8%, 17% and 30% miss chance. High winds add a 15% miss chance that compounds with Blindness and apply a damaging gust to enemies every 20 seconds. Glitch reverses aim, directions and paired controls. The weather descriptions are available in Galleries.

Reapfast's half-health phase adds a faster cadence and a fang volley. Each fang can be broken in its mouth to wound the boss or intercepted in flight. It regrows thirty seconds after loss. Hasasasa is larger and tougher and the emitters now sway at the ends of separate hanging tubes. All eight bosses have distinct death effects and cues. Ordinary Abyss arrivals still share one scheduled slot in non-incursion waves. Lantis's hallucinations and boss-driven summons use their encounter rules.

Last Stop Supply uses the full-window backdrop in `Demo/art/last-stop-workshop.png` and the procedural models in `ShopCounter3D.qml`. The wallpaper was generated from a prompt for an empty moonlit brick workshop with rusty shelving, bloody stains and an open foreground for the models and UI. The software renderer uses the drawn version of the bench. Loaded dice replaces occupied gear with same-rarity level-zero gear. Opening a paid cache requires claiming its item before leaving. Mid-wave Pause permits inspecting Build and Inventory. Move items before the next wave. The Home menu records the highest wave reached by a regular run.

After the damage pass, the three scripted Normal builds all cleared wave 80. Hasasasa has increased health, moving weak points and lower damage on its core and turret salvos. Tenmani, Lantis, Faeel, Endme, the wave-70 Void boss and the Leviathan's fang volley also hit less hard. The sampled Hard and Insane runs stopped on waves 50 and 40 with melee builds. Human difficulty testing remains open.

The latest rules run passed 84 checks. Software and private KDE 3D runs exercised the new shop and gallery, Glitch input, paid and equipped purchases, the critical readout, a real fang hit, the moving gun emitter and waves 10, 20 and 50. They also tested Retry, reward drag and inventory moves. The full-screen test confirmed a 3840×2160 automatic render target, the 1080p cap and complete framing for Fearme's Harvest and Katana during their tricks. The wave record and achievement override survived reopening the application with the same test profile. Qt decoded 372 assets. The private audio graph produced recorded, non-silent output and played the new cues, loops and shop and Leviathan scores. The virtual KDE run still logs a resource cleanup warning at shutdown. Temporary harnesses, captures and logs live in `/tmp/blackbox-abyss`.

Next for the real desktop, follow [Plasma integration](PLASMA-INTEGRATION.md). It starts with the exposed Home input trial and local file pickers, then covers moving combat into the wallpaper, building a panel applet and Plasma Style, and trying CPU, GPU and music inputs. The game is ready to open as a standalone window. The wallpaper host still needs its own focus and visibility verification on the real desktop.

## Stage preparation in progress

The new wave planner fixes the complete roster using the run seed, wave and difficulty before preparation. The counts and threat quotas follow a ten-wave curve, with a breather after a boss. Loadout edits and reward refreshes use independent random state. A frozen copy of the displayed schedule enters combat. Preparation now waits for Begin wave. The preview uses native enemy models and a distant black boss silhouette with discovery-gated hover details. Origin labels use Hellborne, Space and Void. A wave-nine omen also shows the following boss's silhouette.

Harvester enters on wave 44 with a pencil-animated skull and torn robes. It stops at range and channels a continuous drain. Knocking it beyond range stops the song, and killing it returns the health it stole. Exploding enemies resist explosive status and blast damage. Crufixicatus debuts on wave 67 as a Normal Hellborne. Its first damaging hit per individual triggers a three-second scare that holds the simulation while the image plays. The new art is `Demo/art/crufixicatus-scream.png`. The skull model now has nasal holes and no teeth. The supply room backdrop and menu surface are opaque.

The stage planner audit covered 21,600 seeded plans across difficulties and waves 1–180. Full GUI, sound and balance checks are still being run. Update this section with the final results before considering this work done.

### Additional requested work after stage validation

- Replacing equipped gear through a reward or shop purchase moves the old item into a free inventory cell. A full inventory keeps the existing replacement behavior.
- One saved run from Pause, holding wave/loadout/stats/state, with Continue and New game on Home.
- Six achievements, two complete weapon/passive/active kits. One kit rewards hitless boss/wave feats. One rewards unspent run wealth, total spending and buying a whole shop. Its ornate gold gun spends coins per powerful coin shot and uses visibly weak ordinary bullets when broke.
- Main-menu settings export/import complete validated game progress and the single run save.
- Enemy gallery origin filtering and sorting by kills/deaths. Weapon filtering by gun/staff/melee and per-weapon kills.
- Additional graphics and transition settings. The Abyss should use a descent transition. Meteor shower remains a weather entry.

### Preview and combat steering

Hide per-species counts in the muster and hover cards. Retain the internally fixed roster. Put the floating models outside selection-panel borders, preserve native relative sizes, raise preview render resolution, widen hover cards and colour origin/rank labels. All direct weapon hits briefly halt enemies for 0.2 seconds with angry hurt poses and noises. Make held-weapon aim more reactive, add scope designs, raise each magnet's health, and make three-dimensional nearby Electric connections visually clear.

### Current implementation checkpoint

The preview now hides species counts, moves above the loadout panel and uses a shared high-resolution native scene. A deterministic scattered layout and larger boss silhouette are in progress. Tooltips have fixed width, coloured origin/rank lines and edge-clamped placement. Individual origin/rank captions have been removed following the latest steering.

The gear catalogue has grown to 86 of each category and 47 achievements. MilestoneGear.js contains the Unbroken oath and Dead man's dividend kits. New progress records cover per-enemy kills/deaths, direct weapon kills, hitless bosses/waves, held wealth and spending. King's Ransom spends gold per shot and falls back to weak bullets. Its gold model, coin flight feedback and original reports are present. Three hurt sounds and brief movement hit-stop are added. Normal now has 22% block scaling, 6% lower damage, 2% lower speed and a 4% longer arrival gap. A base parry credits 25% of shield recovery before other bonuses.

SaveData.js serializes a full single-run snapshot and validates imported data. Pause has Save run, Home has Continue/New game, and MainSettings.qml has progress export/import via a portable .blackbox.ini file. Export includes saved run, records, discoveries, achievement override and settings. Full native-window persistence and import checks remain pending. There are new tests in tst_SaveProgress.qml. Old shield/stat expectations have been adjusted to the requested balance changes.

DisplaySettings now includes edge quality and transition style/depth. World3D and the held gun use the edge quality. AbyssDescent3D.qml adds a translated 3D rock shaft during entry/exit, with dissolve/zoom backgrounds and covered camera-pitch changes. These changes still require visual verification. Do not claim completion before the final tests, native windows, audio and docs have been checked.

### Latest steering and next verification

- Preview now uses an orthographic camera, a 24 fps idle timer and forward-facing poses. A Node property named position accidentally collided with its built-in transform and has been renamed spot. This is the likely source of the stretched preview. The roster's redundant counts, stage labels and boss captions are removed. A plated wave/scaling badge remains. The preview can occupy the full area above the loadout.
- Weapon upgrades now have much larger damage and handling gains. Active cooldowns/effects and passive final ranks are stronger. Go Go Battlestar is the assumed black alien and has received a small health/damage reduction.
- Pending latest items are a 3D bubble model and explosion, increased base and upgrade magazines, a 20-second max-weapon-rank mega gift, and one combined Pause loadout/inventory tab. Keep all previous requests in scope.
- Software GUI already exercised saving, Continue, actual backup writing/reading, invalid import rejection, graphics settings and enemy/weapon gallery filters. It exposed an old undefined polygon call in the Jester weapon sprite, which is fixed. A full rules run hit a native Qt JS crash once during the optics test. Re-run repeatedly and diagnose if it recurs. Scope lookup maps now reuse module constants.

The latest pass has 104 passing Qt checks. Weapon base magazines have increased and each upgrade adds capacity. The mega gift Arsenal overclock gives effective Lv 3 weapons for twenty seconds while retaining their earned levels. Rule and UI calculations now share effectiveWeaponStats. Bubble3D and BubbleBlast3D supply the Leviathan's bubble shell and native explosion. Pause now has one Loadout tab containing equipped slots and inventory, with read-only editing during combat. The initial native round exercised all save/continue and export/import flows. Remaining work includes a fresh native check after the final framing and bubble/loadout changes, actual Debug wave selection, new scopes and coin gun, full audio checks, repeated rules runs, wave audit, balancing and documentation.

### New continuation on 17 November

Priority fixes are hallucination lockups/near-camera targets, 4K Canvas upload lag during Void incursions, Crufixicatus eye separation and thicker tears. Increase later-wave Void variety, favour late arrivals, make Crawlers common and include Void in most waves after 20. Merge pre-wave inventory into one loadout view. Fix gallery kill/death/weapon records, classify the trident as a staff and rename Chicken to Wendy. Improve the shop and controls reference.

Add twin SMGs, twin shotguns and a Legendary RPG, with three complete kits around early waves, late waves and boss fights. Add interesting Common/Rare staffs and another Legendary staff. Add Papapoganus, a poison-immune grey round horror spraying yellow liquid, vision stains and Poison II with coughing, plus an active unlocked by five kills and a complete kit. Add a toggled wave timer (period key/settings), timer achievements and matching kits, bloody Roman remaining count, and one speed button cycling 1×/2×/0.5×.

The interactive tutorial is a major required deliverable. Oblo gabgalus is spelled Oblogabgalus. Train pistol shooting, reload, melee block, projectile block and stationary peons on front/left/right. Dialogue pauses gameplay with idle animation. Failed lessons rewind with a black fade and replay the current lesson. Then fight 60-HP phase one with flight/projectiles. Long 3D green vomit/deflation leads to a smaller angry phase two. Teach one basic active, then fight a faster roaming boss with projectiles, a clear same-front melee charge and one basic summon every ten seconds. Winning unlocks an early-game reward achievement, in a complete kit. Tutorial is accessible from Home.

The previous tool call failed atomically before making RunSetup editable, EnemyHint objectName or money-sprite alias changes. Reapply these. The attempted extra Python GUI harness changes were also not executed. Rules last passed 104 checks. Final native/audio/4K QA, repeated test crash follow-up and updated docs are still required.

Also required in this continuation, staff models must point upward with complete visible cast/reload animations. Test R and right-click casts through actual input. Tooltips across Pause, rewards, shop, inventory and galleries must be wider and wrap, showing damage or its calculation, cooldown and current upgrade level. All new kits need actual mechanics, pictures and audio.

### Extended final scope, plugins preferred

User explicitly prefers plugins over extensive KDE changes. Build/install a separate wallpaper, control applet and theme with all changes and revert commands recorded. Real desktop features should include Home-only activity, easy background replacement, selectable Play/Idle/Performance/XD modes, CPU-ammo/GPU and music bindings, and shared panel abilities/configuration. Research native Plasma APIs and verify in a private Plasma/KWin session. Build tools and Qt6 Core/Qml/DBus/Multimedia development files are present. Avoid making unrelated core desktop changes.

New major UI request is a Necronomicon gallery. One black 3D book with a bloody pentagram cover, opening/closing animations, page flips and animated chapter skips to enemies/weapons/abilities/weather/achievements. Show every enemy page, unknown entries as a hand-drawn question mark, pencil-style art, blood-stained pages, page n/total, readable font, and new book music. Achievements need cleaner UI and unique medal sprites.

All active abilities need visible matching animations, including common abilities and stronger epic/legendary presentations. Show staff spell charge/cast recovery clearly. Add FPS/custom frame cap and more graphics settings. Fix Escape in Debug (it should pause). Refresh Debug/Star+ behavior for current equipment. Finish balance and asset/attack-telegraph improvements, then desktop integration and a quick activation README. No promises of universal zero lag without measurement.

Gameplay continuation additions already written but still need functional integration/testing are CampaignGear.js (nine complete kits, bringing catalogue target to 95 of each) and five achievements (target52). New IDs include twinSmgs, twinShotguns, siegeRpg, cinderTwig, draughtStick, pollenRod, staticFork, hourhand, graduate and their matched abilities/passives. Encounters now has Papapoganus at47 and tutorial-only Oblogabgalus at0. They still need rigs/AI. Tutorial is still to implement.

EffectCanvas.qml now caps effect textures and refreshes, and is used by weather, Abyss overlay, element effects, spectacle and soul light. Auto 3D render height is capped1440 while wallpapers retain native display resolution. Hallucinations stop at720, spawn scattered from1420–1870, and use normalized view coordinates. Void planning reserves Crawlers in94% of waves after20, then more different Void types after35/55 and favours later arrivals. Active ordinary Void cap3 excludes bosses/illusions so Leviathan's two summons remain valid. Tests passed104 before catalogue-count expectations change. StagePreparation now uses one combined InventoryPanel. Staff pose now pitches+68 degrees, right-click cancels held shooting and casts have a timer; cast rings are added. All these need real GUI checks.

### Tutorial, book and campaign integration checkpoint

Tutorial.js now owns a seven-lesson training sequence and two Oblogabgalus phases, with dialogue freezing, lesson rewind, shield/projectile lessons, long molt and an active lesson. FatDemonRig supplies the yellow triple-chinned trainer and hole-covered grey Papapoganus with moving liquid drops. Papapoganus AI/spray/poison and kill reward counter are connected. Campaign active/passive mechanics, timer achievements, staff rewind and an all-active visual-event system are connected. Escape now pauses Ready/Debug as well as combat. A simulation-rate button, Roman count and timer are in PlayScene. Staff charge has a dedicated on-screen readout.

ReferencePage has been replaced with an animated 3D-transformed book, pencil shader, unknown pages, blood-stained parchment, page count, chapter skips and per-achievement medals. Controls have a new plated layout. Native visual QA is still pending. Shared ActionButton tooltips now wrap at up to480px, and gear descriptions include upgrade/cooldown/damage information; utility/conditional effects explicitly defer to their mechanic descriptions. Catalogue counts are95 each,52 achievements. The previous104 checks passed after fixing count expectations and a MiniMap tooltip property mistake. More tutorial/content tests and full native checks remain necessary.

Desktop plugin source is the next major task. No live KDE configuration has been changed yet. Continue using separate packages, minimal system changes and a reversible installer.

### Important user steering and corrected model regression

All new compositor testing must be VISIBLE inside a nested KWin window, using `--wayland-display /run/user/1000/wayland-1`, separate XDG runtime/config/data and private dbus-run-session. The older hidden --virtual trials have ended. Do not start another hidden compositor. Desktop/preview.sh now provides a permanent visible nested preview with a temporary profile and only a Blackbox panel, avoiding the default tray services.

FatDemonRig accidentally overlaid every enemy because Loader3D.active received undefined for ordinary species and retained its default true. Fixed using a typed fatRig predicate restricted to the exact two species; the model has its own visibility guard too. tst_RigSelection verifies different categories plus the two intended users. Existing open demos need a restart to clear cached QML. A fresh native screenshot confirms distinct Crufixicatus with separated eyes and thicker tears.

The native UI pass has verified new staff R/right-click spells and new held models, Harvester/Crufi, opaque shop, pause save/Continue, actual backup/import rejection, graphics controls and Abyss descent. Its final exit check needs to account for automatic focus-loss pausing. Qt Object.fromEntries is unsupported here; publish() now uses a plain loop, fixing Debug updates.

Actual Plasma packages load and panel Begin/Pause commands work. The visibility trial exposed an unsupported workspace.showingDesktopChanged member. Removed it: the script now uses public windowActivated/windowAdded/windowRemoved/currentDesktop/currentActivity signals; native bridge listens to KWin's public D-Bus showingDesktopChanged. Repeat actual nested Plasma test to confirm focus gating before claiming integration complete. Single-run and achievement/discovery data are now shared with the standalone game's Codex settings; desktop preferences have their own file. No live desktop settings or packages have been installed yet.

### Latest user batch and ordering — save before compaction

User supplied screenshots `/home/blaxim/Pictures/Screenshots/Screenshot_20261117_221631.png` and `Screenshot_20261117_221444.png`, both already visible in conversation. They show a huge pause/loadout panel at wave81 with extreme unused space above/below its content. User explicitly says DO NOT START new batch until previous work is completed. They request: save state, finish prior work, report progress/how to check/detailed checklist, then continue working. Do not end merely after a report.

The exhaustive new queue is in Dev/STATUS.md. It includes responsive UI/no huge gaps, every-prewave previews, larger/accessibility fonts, more central/higher guns, faster/smoother deaths, stronger High lighting/shadows, active/passive shape distinction, thick/narrower hard-cover book, red irregular splashes, detailed enemy pages, run-preserving exact-page plus/links and all chapters including kits in-book, corner page turns, compact selector, jazzy/quieter gallery and jazz OST variations, improved saving, Nightosphere inner/outer crystal+purple crystal shots+15% crit, ordinary moon and10%-of-nights Blood Moon with bonuses/debuffs and one guaranteed Nightmare Blandromedus, three blood-kit achievements and Vampirism. Blender remodels must be LAST. Tutorial stuck phases are reported; this is also an old correctness obligation, so reproduce through actual scene input before claiming the earlier tutorial complete.

Most recent changes before this user batch: Native ownership uses per-host tokens and parks a live run across ownership changes. Optional speaker analysis now requires an owner and stops in Performance mode; needs recheck. QML pause opacity is immediate while paused, solving the automated harness's wait on a fade that could stall when a nested window is occluded. ActionButton tooltips now clamp using scene coordinates on both axes. Restored the controller reference and slot-effect gallery entries. KitGallery is lazily loaded. Added BloodNumber Canvas for the Roman count. Ghorimagous moved to Ascended so exactly10 Normal species remain. Removed unchosen MIT metadata labels. New docs LEARN-CURRENT-BUILD/WAVE-DESIGN and rewritten integration/maintenance guides. STATUS.md is now the canonical current checklist; earlier HANDOFF sections are historical.

Final prior-work verification still pending: actual tutorial input progression; complete native GUI including actual Debug SpinBox40/ESC; standalone 4K/performance scenes; permanent Desktop/preview.sh auto-helper/input check; audio stop/owner check; previous-manifest installer chain; final docs/report. No live KDE package or configuration installation has occurred. All later compositor sessions MUST be visible nested windows (no --virtual). Full software GUI passed with no warnings.119 tests last passed; the final fallback-image patch triggered a fresh run currently represented by exec session63011 (may already be finished). No CUA used. Logs/harnesses remain in /tmp/blackbox-continuation.

### November 18 verification and balance

See STATUS.md for the live queue. Fixed the tutorial lesson target behind the trainer, then confirmed a second native-only miss at the centre of his belly. Tested all seven lessons and both phase boundaries in software and native windows, shortening boss HP for the final hit of each phase. Fixed the bubble Loader3D treating regular bullets as bubbles. The corrected pause panel exactly fits its content at 4K. Verified separate temporary Plasma activity startup, audio stop/resume and two-deep installer rollback. Desktop did not receive a live installation. Native OpenGL testing used software rendering in a visible nested window. The remaining hardware DMA-BUF issue concerns the nested path.

Combat now uses a shared recovery window after freeze or stun. The 4.5% Hasa chance applies outside guaranteed rain freezes. The standard field shield recovers in 4.5 seconds. Added two complete shotgun kits, gallery base stats and Hellborne mesh revisions. The playable gear catalog now contains 97 weapons, 97 passives and 97 actives. Nightosphere, Blood Moon, the book navigation redesign and other November 17 tasks remain in STATUS.md.

Final November 18 suite: 124 passed, zero failed. Preferred-screen handoff preserved wave 1 paused with one owner. Clean nested Plasma launcher selected the correct Desktop containment and passed begin, pause, save and Performance mode. Auto normal detail now targets 1080p during hallucinations/incursions; low detail targets 900p. Six-illusion capture at 3840 × 2132 returned 88.0 ms median, 91.2 ms p95 under software OpenGL. The seven-illusion baseline had a different count, so these figures do not establish a precise performance gain.

### Grimoire build checkpoint

The latest exact-page navigation, save fallback, Blood Moon content, tutorial scope lesson and model changes are in Demo. STATUS.md is the current checklist. Desktop 0.3.0 uses standard wallpaper, widget, KWin script and optional theme packages. Play raises the wallpaper's own input layer within the Desktop containment so native clicks reach the actual game. The Plasma panel remains a separate window. The successful real-input run is recorded in `/tmp/blackbox-refit/actual-input-test-v2.log`. Use only visible nested sessions with separate runtime and settings directories for additional desktop testing.

Three actual 3D belly-mouth variants are in Demo/design/MouthStudy.qml and Dev/models/belly-mouth-options.png. A is the temporary default while the user chooses. Full Qt and native window results for the final revision use the logs in `/tmp/blackbox-refit`. Live KDE packages and settings were untouched.

The 0.3.0 stage has been refreshed. The final Qt suite passed 130 checks. Native checks reached tutorial graduation with the required Shift shot, opened precise Grimoire pages from previews and loot without losing the live run, cleared into subsequent pre-wave forecasts and reopened a saved run from Continue. The widest text setting kept the important controls within both the minimum window and 4K. Final desktop input checks also passed with the default nested renderer.

### Workshop build checkpoint

Hosphoragus uses belly-mouth design A. The arms use mirrored positions with separate materials so the far arm stays visible against the body. Guns now face the centre of aim in combat, including the software view. The store has sequential listing expansions and three stock-quality ranks, and the Grimoire's Shop chapter covers 37 slot effects and the counter's goods. Slot replacements require confirmation. Older shop checkpoints restore gold and existing purchase states when converting the previous expansion card.

The 19 companion models have separate silhouettes and more varied flight poses. Rest lowers and tucks them and pauses charged attacks. Cinder Crow, Brass Owl, Flux Drake, Cobalt Beetle and Wendy have distinct secondaries with their own meters. The editable bird geometry is in `Dev/models/companion-studies.blend`. Sunrise and Sunset roll at the same frequency on every difficulty and leave combat stats alone. Actives create effects at the real hit locations. Visible passive triggers have short, bounded effects.

Use `./Desktop/preview.sh` for the 0.3.1 Qt Quick 3D desktop window and `./Desktop/preview.sh --software` for the projected view. Both were exercised through real nested Wayland input with the regular KDE panel visible. The preview and the standalone art test used temporary settings. The full device and upgrade checklist is in `Dev/STATUS.md` and the installation and rollback steps are in `Desktop/README.md`.

### Witch’s Vault and weather cycle checkpoint

Sky time and environment rolls are separate. See `Conditions.js`, `Encounters.js` and `SkyDome.qml` for the continuous orbit, light and weather overlays. The Moon is behind the playfield, and a spawned Blood Moon guest stays scheduled late in its night. Thunder targets ordinary threats. The shared player stun and freeze recovery gate still applies to charged attacks.

`Meta.js` defines price curves, next-run terms, the scoring model and payout. `ProfileVault.qml` is shared by the standalone window and the Plasma host. `GradeGear.js` adds seven kits. The same rules run in both modes. A continuation of an already-scored attempt is a rehearsal. Rule tests, a live input fixture and clean nested Plasma launch are recorded under `/tmp/blackbox-eclipse`.

The built-in image generator created the witch illustration. The project uses the saved WebP at `Demo/art/witch-vault.webp`.

#### Artwork prompt

```text
Create one original wide 16:9 painterly dark-fantasy game background illustration for Project Blackbox's permanent-upgrade witch shop, a high-quality narrative PC game CG. A mysterious adult witch merchant sits at a chipped old black stone counter on the left half of the frame, roughly chest to headfully visible, imposing rounded silhouette and exaggerated character features: voluminous heavy cloak and hood, broad luxurious folds, large expressive eyes glowing softly violet from under the hood and a broad knowing half smile, playfully ambiguous and a little unnerving. Fully dressed in textured layered black robes with tarnished metal clasps, intriguing aged leather gloves and a few worn charms. A hand offers one small luminous violet gemstone. In a dark dungeon chamber, thick iron chains hang from ancient arched masonry with scattered human skeleton remains and weathered skulls naturally integrated into the environment. Candles and faint cold violet bounce illuminate her face and the counter, with realistic materials, dust and cold mist, original stylized horror concept art with beautiful restrained chiaroscuro. Composition: place the witch in the left 35–42% and confine the brightest focal details to her half. The right half should show mostly shadowy subdued dungeon architecture, muted and low contrast so that the in-game menu remains sharply readable when displayed on top. Strong legible silhouette, real depth, no other characters, no explicit gore and no letters, typography, text, UI, borders, logos, or watermark. This is a finished high-resolution wallpaper asset.
```

### The Witch’s reading · 0.4.1

The corrected Vault background lives at `Demo/art/witch-vault-tarot.webp`. It used the earlier generated Vault composition as a reference. The previous `Demo/art/witch-vault.webp` remains available. `Tarot.js` defines all 78 stable card IDs and their distinct effects. The matching faces and reverse are generated by `Demo/tools/make-tarot-art.py` and ship with both the demo and the Plasma packages.

The Witch’s Vault uses one ledger for paid hands, chosen cards, lifetime purchases, lifetime gems and the current sale. One-off free stock is redeemed from that ledger. Each graded regular attempt seeds its offer rotation from the attempt ID, so reopening the shop cannot reroll it. Old ledgers use their wallet and known rank purchases as a starting estimate for lifetime totals. Subsequent settlements and purchases count exactly. Committed terms and the companion state survive Continue and export or import.

`WeatherGear.js` holds six explicit three-piece kits with the Vault medals. The rule layer resolves overlays separately from day parts. Weapon affinity, passives, field casts and the Grimoire use those same conditions. The balance pass raised sustained damage for Whiteout Coil and Foundry minigun, trimmed King’s Ransom’s raw impact, shortened Barrier breaker recovery, gave Crufixicatus and Go Go Battlestar more warning and reduced Zadrrimus’s damage.

#### Corrected portrait prompt

```text
Edit the supplied Project Blackbox witch-vault game CG. Preserve the same wide 16:9 composition, witch on the left, subdued open right half for the UI, dark candlelit dungeon, hanging chains, weathered bones, purple gem in hand, and painterly realistic horror-fantasy materials. CHANGE THE WITCH decisively: she is a slim, slender young adult woman, age 24–26 and clearly an adult, with narrow shoulders and hips, long lean arms, a narrow waist and a lightly fitted, opaque, high-neck dark gown with layered brocade and leather. Remove the previous extra volume around her torso, waist and hips; let the dress fall straight with a controlled natural silhouette. Her hair is jet black, visibly in loose strands emerging on either side of her face and over her shoulders, distinct from the cloth with cool rim lighting. Pull the deep black embroidered hood low over her brow and across BOTH EYES, casting a solid opaque shadow so neither eye, eye glow, nor eyelids are visible. Show the lower face, youthful cheek and jaw, and relaxed straight lips. Her expression reads quiet, aloof, nonchalant, and mysterious, with no smile or smirk. Keep the pulled-back head-through-hips framing and position her around the LEFT third next to the stone counter. No text, no UI, no watermark, no eye glow, and no graphic injury.
```


### Current graphics and save work

- Make changes to shared gameplay under `Demo/game`. The Qt Quick 3D view, projected fallback and Plasma wallpaper use the same combat rules and packaged backgrounds. `Desktop/manage.py stage` rebuilds and stages the current version.
- Wall turns share a camera transform. `WallpaperTurn.qml` owns image framing and custom pictures. `RoomAtmosphere.qml` and `LandscapeEffects.qml` carry each scene’s weather and lighting.
- `SurfaceSet.qml` loads shared material maps in Ultra. The field and pre-wave lineup use the same creature materials. The gun keeps a transparent render target and reads lighting from an HDR probe.
- A closed expedition invalidates the matching current and recovery checkpoints. Expedition best and saved reports live in the profile ledger. Save imports retain newer close records. Keep the two user settings files or an exported backup.
