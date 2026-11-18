.pragma library

var origins = {
    Hellborne:{title:"Hellborne",color:"#ff9a7c"},
    Space:{title:"Space",color:"#8ee5ff"},
    Void:{title:"Void",color:"#d5afff"}
}

var whispers = {
    papapoganus:"Its smile is almost as sickening as the yellow rain.",
    oblogabgalus:"A teacher with a very large appetite.",
    silophosus:"It has one hungry eye and very little patience.",
    fhantamegus:"Every few seconds, it finds a new place to haunt.",
    hosphoragus:"Cover your ears before that mouth opens.",
    skorochiyus:"Two embers are waiting in that empty mouth.",
    spartalien:"Something cold is watching from the stars.",
    fizzalien:"That thin blue shell is hiding a nasty surprise.",
    ghorimagous:"Wait until it remembers how to be flesh.",
    bergensus:"One bite is all this little horror needs.",
    gojemarus:"It is full of gold. Its friends can smell it.",
    humontafagus:"Wound it deeply and the family comes calling.",
    mothergalian:"She carries more mouths than you can see.",
    zadrrimus:"After that bite, the world will look wrong.",
    rerogorubus:"There is always something smaller inside.",
    mastafangenbus:"That spinning body has learned to throw its teeth.",
    gigafinterus:"Keep clear of the furnace in its throat.",
    princoratus:"This one seems to enjoy exploding.",
    claptrap:"Even its laughter feels frozen.",
    mystery:"You will see it best when you can see nothing else.",
    crawler:"The deep has teeth. This one brings the darkness with it.",
    meteor:"The sky has dropped something that wants to burst.",
    helboranius:"A wall of fallen grace is rushing toward you.",
    jos:"Keep your eyes on the one hiding its eyes.",
    lucifoverus:"The trident comes first. The curse comes after.",
    gendoustagus:"That skull is a promise its death will keep.",
    jon:"It knows where your crosshair wants to go.",
    hasasasa:"The mouths at the ends of those tubes are vulnerable.",
    battlestar:"Its crimson stare needs a moment to cool.",
    nindumipus:"It leaves the dark behind when you hurt it.",
    iceterapus:"The cold belongs to it. Your bullets make it angry.",
    seraphijus:"Its heart is counting down.",
    stinkaturumus:"This one stinks bad. Something worse lives inside.",
    saslimigus:"Do not let its spit glue you to the floor.",
    skarabatunus:"Those golden eyes are counting your coins.",
    capablancamus:"It knows exactly where your armour is weakest.",
    trispiramahedus:"Three hearts lend their lightning to the crowd.",
    helesepeptium:"Look closer. Something is coiled beyond the dark.",
    fetaSpotter:"Find the red lens before it finds you.",
    nosferapabakus:"It does not care whose flesh feeds it.",
    voidGlitch:"Two red eyes have torn a hole in the signal.",
    tenmani:"Raise your guard before those arms reach you.",
    lantis:"That lovely light wants you to look away forever.",
    shadow:"Its ink will stay long after its blade is gone.",
    faeel:"Its teeth remember every spell you were saving.",
    nightosphere:"An unfeeling crystal is calling things from below.",
    endme:"Make every watching eye close. Then hurt it.",
    fearme:"One touch will leave half your life in the deep.",
    archfellanus:"Your little friends like the sound of its voice.",
    reapfast:"Even its lost teeth are still hungry.",
    hallucination:"The nightmare ends when its last shadow falls.",
    lalaBubu:"You will miss its laughter when the world turns backward.",
    harvester:"It is borrowing your soul. Push it away and collect the debt.",
    crufixicatus:"The tears fall upward. Its first touch brings the face too close."
}

function origin(spec) {
    return spec.abyss ? "Void" : spec.role === "alien" || spec.ship || spec.id === "meteor" ? "Space" : "Hellborne"
}
