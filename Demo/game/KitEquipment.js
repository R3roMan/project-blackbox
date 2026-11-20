.pragma library

// Kit-specific equipment keeps each named bonus while giving reused pieces
// their own IDs, handling and availability. Each row identifies its kit key.
var weaponVariants = [
    ["iceCircuit","rimeLance","Rime lance",.89,.86,"#89dedf","A lighter Frost lance that cycles sooner and trades away impact."],
    ["hotChamber","kilnRifle","Kiln rifle",1.13,1.23,"#f58450","A slower, hotter take on the Solar rifle with heavier Burn shots."],
    ["resonance","feedbackIon","Feedback ion",.95,.88,"#d384f5","A quick ion gun built to keep Electric chains moving between targets."],
    ["demolition","fuseDriver","Fuse driver",1.14,1.19,"#f7ad65","A deliberate heavy gun tuned for explosive finishing hits."],
    ["quartermaster","supplySidearm","Supply sidearm",.93,.78,"#f7cf91","A light service pistol for short gaps between reloads."],
    ["sporeBreach","sporeBore","Spore bore",1.17,1.24,"#a9c467","A heavy weapon for a slower but harder breach through enemy defenses."],
    ["tarpitSet","resinProjector","Resin projector",.86,.81,"#d5a55e","A lighter Bilecaster that applies Sticky faster at the cost of shot damage."],
    ["remoteSet","watchCarbine","Watch carbine",1.13,1.19,"#8ec6c3","A hard-hitting carbine for deliberate bursts while watching another room."],
    ["antidoteSet","breatherPistol","Breather pistol",1.10,1.17,"#85d1a0","An armored-frame service pistol with slow, weighty shots."],
    ["threadSet","seamIon","Seam ion",1.07,1.14,"#aa9aff","A high-impact ion gun with a longer gap between pulses."],
    ["mirrorSet","mirrorVolt","Mirror volt",.91,.79,"#94dce9","A quick Electric sidearm for returning fire after a block."],
    ["voidSet","riftMortar","Rift mortar",1.18,1.32,"#a297d3","A launcher that trades cycle time for a stronger direct hit."],
    ["panicSet","alarmRiot","Alarm riot",1.08,.90,"#fa9b79","A responsive riot weapon with a narrow magazine for short emergencies.",.70],
    ["bloodSet","bloodKiln","Blood kiln",1.18,1.26,"#f06d84","A heavy Solar-pattern gun for individual, high-impact shots."],
    ["snareSet","tripwireLance","Tripwire lance",.92,.81,"#a4cdff","A Frost lance that places light shots quickly around a trap."],
    ["droneSet","hangarArc","Hangar arc",.90,.85,"#7cd7bd","A fast Electric arc gun to use while a companion holds the line."],
    ["purgeSet","quarantineBore","Quarantine bore",.92,.86,"#cee79a","A quick-cycling breach weapon designed to follow up a shield purge."],
    ["hookKit","grapnelAxe","Grapnel axe",.93,.85,"#cad4e1","A lighter throwing axe with a shorter draw animation between throws."],
    ["quickSteel","flashKatana","Flash katana",.94,.84,"#d5e4ff","A lighter katana with faster swings for maintaining its three-strike combo."],
    ["leadKit","leadArc","Lead arc",1.16,1.24,"#9db6d7","A high-impulse Electric arc gun that cycles slowly after each attack."],
    ["redHungerKit","sanguineBore","Sanguine bore",1.15,1.21,"#ee728e","A heavy Hellbore-pattern weapon with time to breathe between strong hits."],
    ["glassKit","glasspoint","Glasspoint",1.18,1.32,"#dfd4fc","A slow precision weapon with higher impact and a small magazine.",.72],
    ["mintKit","mintageCarbine","Mintage carbine",.90,.80,"#eec974","A light Kestrel-pattern carbine with quick trigger recovery."],
    ["orbitKit","orbitSaber","Orbit saber",1.11,1.20,"#80e1ef","A heavy mechanical sword with stronger close-range hits and slower swings."]
]

var activeVariants = [
    ["iceCircuit","rimeCharge","Rime charge",1.13,1,"Throw a cryogenic grenade that chills the blast area."],
    ["hotChamber","kilnFlare","Kiln flare",1.15,1,"Rain scorching damage onto the current wallpaper."],
    ["resonance","harmonicPulse","Harmonic pulse",1.07,1,"Send a stronger Electric pulse through a target."],
    ["demolition","splitCharge","Split charge",1.17,1,"Throw a heavy grenade for direct and splash damage."],
    ["quartermaster","fieldResupply","Field resupply",1.14,1,"Refill the current magazine and shorten shot recovery."],
    ["clubSet","crowdShove","Crowd shove",.91,0,"Push enemies away on your current wallpaper."],
    ["mechaSet","servoDischarge","Servo discharge",.90,0,"Send a focused Electric pulse into one enemy."],
    ["knifeSet","knifeFeint","Knife feint",.88,0,"Deploy a decoy to divert attackers."],
    ["darkSet","pitchTarpit","Pitch tarpit",1.09,1,"Pin nearby regular enemies in Sticky pitch."],
    ["sawSet","ripcordRush","Ripcord rush",1.10,1,"Increase firing speed for a short burst."],
    ["axeSet","hunterWire","Hunter wire",.87,0,"Set a quick wire trap to slow an enemy."],
    ["twinSet","crossdrawStep","Crossdraw step",.91,0,"Dodge an incoming hit during a brief window."],
    ["furnaceSet","furnaceWash","Furnace wash",1.16,1,"Burn enemies across the current wallpaper."],
    ["iceKit","glacialSnap","Glacial snap",1.13,1,"Freeze enemies on the current wallpaper."],
    ["thunderKit","stormRune","Storm rune",1.16,1,"Bring a heavy lightning strike down on the aimed target."],
    ["abyssKit","eclipseSeal","Eclipse seal",.93,0,"Advance the Abyss seal and push back a Void crawler."],
    ["auroraKit","auroraShift","Aurora shift",1.12,1,"Dodge an incoming strike through a longer opening."],
    ["quickSteel","flashRiposte","Flash riposte",.89,0,"Wait for an incoming attack and parry it."],
    ["leadKit","leadBreach","Lead breach",1.13,1,"Load a longer string of rounds that deal extra damage to barriers."],
    ["redHungerKit","redReversal","Red reversal",.91,0,"Ready your weapon, repulse enemies and recover health when badly hurt."],
    ["glassKit","glassStep","Glass step",.83,0,"Step out of the way of an incoming attack."],
    ["mintKit","coinCounter","Coin counter",1.12,1,"Prepare to parry an incoming attack."],
    ["orbitKit","orbitScreen","Orbit screen",1.14,1,"Raise a sustained two-charge barrier."],
    ["tridentKit","tridentFlare","Trident flare",.87,0,"Set nearby enemies on the current wallpaper on fire."],
    ["starSet","stellarBattery","Stellar battery",1.16,1,"Spend health for a burst of unlimited ammunition."]
]

var passiveVariants = [
    ["antidoteSet","sealedRespirator","Sealed respirator",1.15],
    ["threadSet","seamGrip","Seam grip",.82],
    ["mechaSet","servoGround","Servo ground",1.12],
    ["katanaSet","drawRhythm","Draw rhythm",.78],
    ["knifeSet","pairedGrip","Paired grip",.87],
    ["darkSet","voidHone","Void hone",.93],
    ["sawSet","ripcordFlywheel","Ripcord flywheel",.79],
    ["axeSet","huntsmanSight","Huntsman sight",.82],
    ["furnaceSet","furnaceWick","Furnace wick",1.16],
    ["deadeyeSet","rangeCaliber","Range caliber",1.09],
    ["fireKit","starEmber","Star ember",1.10],
    ["iceKit","glacierBite","Glacier bite",.94],
    ["earthKit","earthenBattery","Earthen battery",1.12],
    ["avatarKit","convergenceAsh","Convergence ash",.86],
    ["abyssKit","eclipseLining","Eclipse lining",1.14],
    ["tridentKit","tridentWick","Trident wick",.83],
    ["starSet","stellarMagazine","Stellar magazine",1.16]
]

// These fill the remaining passive positions with independent mechanics.
var newPassives = [
    ["wardLedger","Ward ledger","rare","Shield recovery is 0.35 seconds shorter.","shieldCool",.35,"armor",.04,"Damage taken −4%"],
    ["spareFuse","Spare fuse","common","Active attacks deal 6% more damage.","activeDamage",.06,"cooldown",.05,"Active cooldowns −5%"],
    ["sealThread","Seal thread","rare","Seal progress accumulates 12% faster.","sealSpeed",.12,"health",6,"Maximum health +6"],
    ["leadMantle","Lead mantle","epic","Reduce critical damage taken by 15 percentage points.","critResist",.15,"armor",.045,"Damage taken −4.5%"],
    ["temperGlass","Temper glass","rare","Your slowing and Freeze durations are extended by 0.5 seconds.","frostDuration",.50,"coldDamage",.06,"Damage to chilled enemies +6%"],
    ["echoSpring","Echo spring","common","Shots recover 5% faster.","cycle",.05,"reload",.06,"Reload time −6%"],
    ["ionPearl","Ion pearl","rare","Electric attacks can chain 32 units farther.","arcRadius",32,"activeDamage",.05,"Active attack damage +5%"],
    ["shrineCord","Shrine cord","common","Restore 3 health at the start of each wave.","heal",3,"parryWindow",.025,"Perfect parry window +0.025s"]
]
