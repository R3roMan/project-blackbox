.pragma library
var groups = {
  "flight": [
    {
      "name": "fly",
      "args": "X,Y",
      "description": "Fly to logical screen coordinates.",
      "operation": "fly"
    },
    {
      "name": "come",
      "args": "",
      "description": "Fly to the current cursor.",
      "operation": "come"
    },
    {
      "name": "chase",
      "args": "",
      "description": "Follow the cursor for a few seconds.",
      "operation": "chase"
    },
    {
      "name": "stop",
      "args": "",
      "description": "Cancel the current activity and hover in place.",
      "operation": "stop"
    },
    {
      "name": "resume",
      "args": "",
      "description": "Resume ordinary roaming.",
      "operation": "resume"
    },
    {
      "name": "box",
      "args": "[open|close|remove]",
      "description": "Place a movable pet enclosure, release the pet, arm it, or remove it.",
      "operation": "box"
    },
    {
      "name": "recover",
      "args": "",
      "description": "Clear a stuck action and return the pet to ordinary flight.",
      "operation": "recover"
    },
    {
      "name": "perch",
      "args": "",
      "description": "Land on an available folder, file, widget, or window.",
      "operation": "perch"
    },
    {
      "name": "land",
      "args": "",
      "description": "Land at the bottom of this wallpaper.",
      "operation": "land"
    },
    {
      "name": "circle",
      "args": "",
      "description": "Fly a circle around the work area.",
      "operation": "path"
    },
    {
      "name": "figure-eight",
      "args": "",
      "description": "Fly a figure eight.",
      "operation": "path"
    },
    {
      "name": "zigzag",
      "args": "",
      "description": "Cut across the wallpaper in a zigzag.",
      "operation": "path"
    },
    {
      "name": "patrol",
      "args": "",
      "description": "Visit the corners of the work area.",
      "operation": "path"
    },
    {
      "name": "spiral",
      "args": "",
      "description": "Spiral towards the middle.",
      "operation": "path"
    },
    {
      "name": "dash",
      "args": "",
      "description": "Make a fast horizontal pass.",
      "operation": "path"
    },
    {
      "name": "dive",
      "args": "",
      "description": "Dive and climb back.",
      "operation": "path"
    },
    {
      "name": "orbit",
      "args": "",
      "description": "Circle the last known pointer position.",
      "operation": "path"
    },
    {
      "name": "corner",
      "args": "tl|tr|bl|br",
      "description": "Go to a selected corner.",
      "operation": "anchor"
    },
    {
      "name": "center",
      "args": "",
      "description": "Hover in the middle.",
      "operation": "anchor"
    },
    {
      "name": "ceiling",
      "args": "",
      "description": "Fly near the top without shrinking.",
      "operation": "anchor"
    },
    {
      "name": "floor",
      "args": "",
      "description": "Fly near the floor.",
      "operation": "anchor"
    },
    {
      "name": "left",
      "args": "",
      "description": "Fly to the west side of the screen.",
      "operation": "anchor"
    },
    {
      "name": "right",
      "args": "",
      "description": "Fly to the east side of the screen.",
      "operation": "anchor"
    }
  ],
  "care": [
    {
      "name": "mood",
      "args": "",
      "description": "Read the current mood.",
      "operation": "mood"
    },
    {
      "name": "stats",
      "args": "",
      "description": "Show mood, form and current activity.",
      "operation": "stats"
    },
    {
      "name": "sleep",
      "args": "",
      "description": "Take a silent nap.",
      "operation": "sleep"
    },
    {
      "name": "awake",
      "args": "",
      "description": "Wake the pet. Repeated attempts lower mood.",
      "operation": "awake"
    },
    {
      "name": "petting",
      "args": "",
      "description": "Give a little attention.",
      "operation": "reward"
    },
    {
      "name": "praise",
      "args": "",
      "description": "Praise the pet.",
      "operation": "reward"
    },
    {
      "name": "treat",
      "args": "",
      "description": "Offer a treat.",
      "operation": "reward"
    },
    {
      "name": "apologize",
      "args": "",
      "description": "Offer a small mood recovery after a cooldown.",
      "operation": "reward"
    },
    {
      "name": "quiet",
      "args": "",
      "description": "Mute all pet sounds and stop singing.",
      "operation": "quiet"
    },
    {
      "name": "unquiet",
      "args": "",
      "description": "Allow pet sounds again.",
      "operation": "unquiet"
    },
    {
      "name": "transform",
      "args": "NAME",
      "description": "Change into any listed pet form.",
      "operation": "transform"
    },
    {
      "name": "shop",
      "args": "",
      "description": "Transform into the Rime Falcon and send ice around its wings.",
      "operation": "shop"
    },
    {
      "name": "forms",
      "args": "",
      "description": "List all available pet forms.",
      "operation": "forms"
    },
    {
      "name": "sweep",
      "args": "",
      "description": "Clean droppings from this wallpaper.",
      "operation": "sweep"
    },
    {
      "name": "droppings",
      "args": "",
      "description": "Count droppings across wallpapers.",
      "operation": "droppings"
    },
    {
      "name": "gift",
      "args": "",
      "description": "Open or inspect the latest pet gift.",
      "operation": "gift"
    },
    {
      "name": "poop",
      "args": "",
      "description": "Ask the pet to leave a dropping here.",
      "operation": "poop"
    }
  ],
  "show": [
    {
      "name": "say",
      "args": "TEXT",
      "description": "Show words in the pet’s speech bubble.",
      "operation": "say"
    },
    {
      "name": "sing",
      "args": "[FILE]",
      "description": "Sing an original short tune, or play a local audio file in the pet’s pitched voice.",
      "operation": "sing"
    },
    {
      "name": "hush",
      "args": "",
      "description": "Stop the current song and dismiss the bubble.",
      "operation": "hush"
    },
    {
      "name": "dance",
      "args": "",
      "description": "Dance in place.",
      "operation": "pose"
    },
    {
      "name": "spin",
      "args": "",
      "description": "Spin in the air.",
      "operation": "pose"
    },
    {
      "name": "bow",
      "args": "",
      "description": "Give a bow.",
      "operation": "pose"
    },
    {
      "name": "wave",
      "args": "",
      "description": "Wave hello.",
      "operation": "pose"
    },
    {
      "name": "blink",
      "args": "",
      "description": "Blink and look around.",
      "operation": "pose"
    },
    {
      "name": "surprise",
      "args": "",
      "description": "Do a startled hop.",
      "operation": "pose"
    },
    {
      "name": "cheer",
      "args": "",
      "description": "Celebrate with stars.",
      "operation": "pose"
    },
    {
      "name": "sneak",
      "args": "",
      "description": "Sneak past the pointer.",
      "operation": "pose"
    },
    {
      "name": "sulk",
      "args": "",
      "description": "Turn away and sulk.",
      "operation": "pose"
    },
    {
      "name": "banana",
      "args": "",
      "description": "Vesper peels and eats a banana.",
      "operation": "pose"
    },
    {
      "name": "board",
      "args": "",
      "description": "Vesper sets down or picks up the surfboard.",
      "operation": "pose"
    },
    {
      "name": "globe",
      "args": "",
      "description": "Vesper spins a tiny Earth on one finger.",
      "operation": "pose"
    },
    {
      "name": "vine",
      "args": "",
      "description": "Vesper swings along a vine.",
      "operation": "pose"
    },
    {
      "name": "scratch",
      "args": "",
      "description": "Scratch or preen.",
      "operation": "pose"
    },
    {
      "name": "peck",
      "args": "",
      "description": "Wendy pecks the ground.",
      "operation": "pose"
    },
    {
      "name": "strut",
      "args": "",
      "description": "Wendy struts across the foreground.",
      "operation": "pose"
    },
    {
      "name": "feathers",
      "args": "",
      "description": "Wendy shakes out her feathers.",
      "operation": "pose"
    },
    {
      "name": "nest",
      "args": "",
      "description": "Wendy settles into a nest.",
      "operation": "pose"
    },
    {
      "name": "egg",
      "args": "",
      "description": "Wendy lays a tiny egg prop.",
      "operation": "pose"
    },
    {
      "name": "stretch",
      "args": "",
      "description": "Stretch wings or arms.",
      "operation": "pose"
    },
    {
      "name": "salute",
      "args": "",
      "description": "Give a quick salute.",
      "operation": "pose"
    },
    {
      "name": "shake",
      "args": "",
      "description": "Shake the whole body.",
      "operation": "pose"
    },
    {
      "name": "hop",
      "args": "",
      "description": "Hop in place.",
      "operation": "pose"
    },
    {
      "name": "yawn",
      "args": "",
      "description": "Yawn slowly.",
      "operation": "pose"
    },
    {
      "name": "joke",
      "args": "",
      "description": "Tell a short joke.",
      "operation": "quip"
    },
    {
      "name": "fortune",
      "args": "",
      "description": "Give a tiny fortune.",
      "operation": "quip"
    },
    {
      "name": "hello",
      "args": "",
      "description": "Greet you in a speech bubble.",
      "operation": "quip"
    },
    {
      "name": "thanks",
      "args": "",
      "description": "Thank you in a speech bubble.",
      "operation": "quip"
    }
  ],
  "tasks": [
    {
      "name": "locate",
      "args": "[me]",
      "description": "Find and report the pointer location.",
      "operation": "locate"
    },
    {
      "name": "folder",
      "args": "[PATH]",
      "description": "Show or set the pet’s quick-access folder.",
      "operation": "folder"
    },
    {
      "name": "home",
      "args": "",
      "description": "Open the quick-access folder.",
      "operation": "open-home"
    },
    {
      "name": "open",
      "args": "PATH",
      "description": "Open a local file or folder through KDE.",
      "operation": "open"
    },
    {
      "name": "reveal",
      "args": "PATH",
      "description": "Reveal a local file in the file manager.",
      "operation": "reveal"
    },
    {
      "name": "fetch",
      "args": "SOURCE to DESTINATION|me",
      "description": "Copy a file after approval, or bring a clickable file card to the pointer.",
      "operation": "fetch"
    },
    {
      "name": "write",
      "args": "in FILE -TEXT",
      "description": "Append text to a file after approval.",
      "operation": "write"
    },
    {
      "name": "read",
      "args": "FILE",
      "description": "Read a small text preview.",
      "operation": "read"
    },
    {
      "name": "list",
      "args": "[FOLDER]",
      "description": "List entries in the quick-access folder or another folder.",
      "operation": "list"
    },
    {
      "name": "mkdir",
      "args": "FOLDER",
      "description": "Create a folder after approval.",
      "operation": "mkdir"
    },
    {
      "name": "code",
      "args": "COMMAND",
      "description": "Show the pet typing a draft into the attached Blackbox shell.",
      "operation": "code"
    },
    {
      "name": "terminal",
      "args": "[ROOM]",
      "description": "Attach a shell workspace to an Idle wallpaper.",
      "operation": "terminal"
    },
    {
      "name": "volume",
      "args": "0..100",
      "description": "Set speaker volume after approval.",
      "operation": "volume"
    },
    {
      "name": "louder",
      "args": "",
      "description": "Raise speaker volume one step after approval.",
      "operation": "volume"
    },
    {
      "name": "quieter",
      "args": "",
      "description": "Lower speaker volume one step after approval.",
      "operation": "volume"
    },
    {
      "name": "close-app",
      "args": "",
      "description": "Ask the last active normal application window to close after approval.",
      "operation": "close-app"
    },
    {
      "name": "battle",
      "args": "",
      "description": "Start an expedition from Idle after approval.",
      "operation": "battle"
    },
    {
      "name": "auto",
      "args": "",
      "description": "Start or enable Auto within the game’s existing limits.",
      "operation": "auto"
    },
    {
      "name": "save",
      "args": "",
      "description": "Save the current Blackbox checkpoint.",
      "operation": "save"
    },
    {
      "name": "load",
      "args": "",
      "description": "Load the existing expedition checkpoint after approval.",
      "operation": "load"
    },
    {
      "name": "report",
      "args": "[TEXT]",
      "description": "Open the bug reporter or save a short local report.",
      "operation": "report"
    },
    {
      "name": "time",
      "args": "",
      "description": "Say the local time.",
      "operation": "info"
    },
    {
      "name": "room",
      "args": "",
      "description": "Say the current wallpaper.",
      "operation": "info"
    },
    {
      "name": "weather",
      "args": "",
      "description": "Give the current Idle weather.",
      "operation": "info"
    },
    {
      "name": "directions",
      "args": "",
      "description": "List the available wallpaper route names.",
      "operation": "info"
    }
  ]
}
