# Wave design and balance

The roster is planned before preparation. The preview shows **which** species can appear, without revealing each species' count. Enemy identities remain Unknown until encountered. Bosses are distant black silhouettes; encountering one reveals its name/mechanic for later visits.

The plan is seeded independently from rewards and loadout actions. Starting a wave copies the displayed schedule. This preserves the player's ability to prepare for a real, stable challenge.

## Why this structure

PVZ player feedback emphasises meaningful seed choices and seeing upcoming threats near those choices. Here the floating preview sits directly above the loadout. It provides tactical information without publishing the exact spawn timetable. The reference is player feedback rather than a claim to reproduce PVZ's internal algorithm. [EA PVZ feedback](https://forums.ea.com/discussions/plants-vs-zombies-3-discussion-en/feedback-improving-choose-your-seeds/10296638)

Tower-defence wave discussion also favours rising pressure with occasional relief. Blackbox therefore uses a ten-wave block: pressure rises toward the boss, then drops slightly before a higher next block. Enemy origins, ranks and introduction waves act as separate constraints. Threat mix grows rather than replacing every early enemy with a stronger type. [Wave-generation discussion](https://www.reddit.com/r/gamedev/comments/ss79ak/wave_generation_algorithm_for_a_tower_defence_game/)

Arknights-style enemy intelligence and community discussion were qualitative references for clearly exposing mechanics and teaching one unfamiliar threat at a time. Blackbox uses its own introduction list and budget; the exact numeric balance does not come from those games. [Enemy-mechanic discussion](https://www.reddit.com/r/arknights/comments/1gqwill)

## Implemented budget

`Encounters.js` owns `waveSize`, `waveBudget`, `maxConcurrent` and `planWave`.

Let `block = floor((wave−1)/10)` and `step = ((wave−1) mod10)+1`.

- The opening block has `3 + floor(step ×0.55)` enemies on Normal.
- Later blocks have `5 +2×block + floor((step−1)×(0.56 +0.04×min(5,block)))`, plus a boss when applicable, capped at45 before difficulty additions.
- Ascended/Nightmare quotas rise within and between blocks. A new introduction receives room in the appropriate quota. A Trispiramahedus group uses three bodies.
- Normal has two concurrent enemies in waves1–3, three through10, then a gradual cap rising to nine. Hard/Insane add concurrency and roster pressure.
- The boss is last and waits for the player to visit its wallpaper before beginning its entrance.
- Enemy health and attack scale together every ten waves by22%,32% or40% of base for Normal, Hard and Insane.

Species selection is random within those quotas and introduction gates. Repeat types and consecutive Nightmares are discouraged. Rarer strong enemies have lower selection weights. A separate weather choice can alter a wave's mechanics. Optional music input biases eligible species when preparation first freezes the plan, without changing its budget.

## Abyss pressure

After wave20,94% of seeded ordinary plans reserve a Void Crawler. From35 and55 the planner reserves more different Void species when the rank budget permits. Ordinary schedules generally favour Void arrivals in the latter part of a wave. A newly introduced creature can still appear early to teach it, and Fearme deliberately arrives early enough to create a slow deadline.

Scheduled ordinary Void arrivals remain serial in non-incursion waves. Summons have their own limited live budget, excluding bosses and hallucinations. This allows Reapfast's pair and Nightosphere's mechanic without creating an unbounded visible crowd. Incursions move eligible Void arrivals across wallpapers.

## Current player progression

Start at200HP with four passive slots. Every second ordinary wave offers three choices; bosses offer larger run-long boons and a five-listing shop. Weapon and ability upgrades have distinct stat steps and stronger final ranks. Magazine size rises with upgrades. Replacing gear can preserve it in the inventory, giving players a way to prepare different answers for different rosters.

Rarity cadence is a constrained selection policy rather than a naive fixed Legendary probability per card. Owned-item repeat luck operates only after rarity selection, so shopping for upgrades does not silently change rarity odds. High-grade gear still needs a compatible build and damage type.

## Validation and remaining balance work

An audit checked21,600 plans across waves1–180, three difficulties and40 seeds: totals and rank budgets agree, introduction gates hold and bosses remain last. The rules tests cover the key abilities, phases, equipment and saves.

Scripted players are useful crash/degenerate-loop checks but are not a substitute for skilled human play. Current bounded Normal simulations cleared early bosses and reached the middle/later game; two stalled on a distant armoured Jospharemus that the script kept shooting instead of changing tactics. One nearly defeated Hasasasa before dying. The sampled Hard run reached79 and Insane27. These outcomes do not prove the modes are fully balanced. They identify encounter tactics and later pressure for human testing, rather than justifying blanket damage cuts.

Record wave, difficulty, build and cause of death when testing. Compare several builds and seeds, and adjust the smallest relevant stat or roster quota. Use the fixed preview to distinguish a poor build match from unreadable attacks, an incorrect hitbox or a broken mechanic.
