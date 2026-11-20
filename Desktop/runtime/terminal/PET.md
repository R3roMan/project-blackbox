# Blackbox pet commands

Turn on **Pet admin** in BX or **Desktop settings → Desktop**. This also enables the roaming pet. **Ctrl+P** and the wallpaper’s **Pet terminal** menu open the mini console. In Pure Code, write `pet COMMAND` or `box pet COMMAND`. `box help -pet =commands .tasks` expands a group and `box help -pet =commands .write` opens a command.

```sh
pet say hello
pet transform Vesper
pet banana
pet locate me
pet folder "~/Projects"
pet fetch "notes.txt" to me
pet write in "notes.txt" -Remember the Shrine
pet terminal left
pet code 'printf "Hello from the Shrine\\n"'
pet report 'The pet flew under a window.'
box help -options =graphics .framing
box help -pet =commands .care +show
```

In this reference, **[ ]** mark optional arguments, **+** adds a second help branch or joins related steps, and **:** introduces a named value or label. Example: `pet terminal left` + `pet code COMMAND` places a draft on West Approach. Quote paths with spaces, for example `pet folder "~/My Notes"`. Relative paths use the quick-access folder. `me` means the most recently observed pointer position on the desktop.

The mini console shows the mood and pending actions. Approve file copies, text appends, folder creation, app closes, volume changes, battle or load requests, and terminal drafts there. The pet can open a local file or show its location. A fetch to `me` produces a clickable file card. Pass a shell draft as one quoted argument to preserve its own quoting. The pet types it into a Blackbox shell while its prompt has focus. Press Enter yourself to run the draft. Idle antics use the pet’s own log and animation.

Mute pet audio with `pet quiet` and restore it with `pet unquiet`. `pet sing` pitches playback of a supported local audio file and animates singing. Mood changes come from attention, dragging, repeated waking, droppings and occasional whims. A rush of commands makes the pet nap. Vesper gets annoyed faster. Wendy moves faster and stays at neutral or higher. Switching Pet admin off and back on resets mood and cancels pending actions.

## Flight

| Command | Arguments | Action |
| --- | --- | --- |
| `pet fly` | X,Y | Fly to logical screen coordinates. |
| `pet come` | — | Fly to the current cursor. |
| `pet chase` | — | Follow the cursor for a few seconds. |
| `pet stop` | — | Cancel the current activity and hover in place. |
| `pet resume` | — | Resume ordinary roaming. |
| `pet perch` | — | Land on an available folder, file, widget, or window. |
| `pet land` | — | Land at the bottom of this wallpaper. |
| `pet circle` | — | Fly a circle around the work area. |
| `pet figure-eight` | — | Fly a figure eight. |
| `pet zigzag` | — | Cut across the wallpaper in a zigzag. |
| `pet patrol` | — | Visit the corners of the work area. |
| `pet spiral` | — | Spiral towards the middle. |
| `pet dash` | — | Make a fast horizontal pass. |
| `pet dive` | — | Dive and climb back. |
| `pet orbit` | — | Circle the last known pointer position. |
| `pet corner` | tl\|tr\|bl\|br | Go to a selected corner. |
| `pet center` | — | Hover in the middle. |
| `pet ceiling` | — | Fly near the top without shrinking. |
| `pet floor` | — | Fly near the floor. |
| `pet left` | — | Fly to the west side of the screen. |
| `pet right` | — | Fly to the east side of the screen. |

## Care

| Command | Arguments | Action |
| --- | --- | --- |
| `pet mood` | — | Read the current mood. |
| `pet stats` | — | Show mood, form and current activity. |
| `pet sleep` | — | Take a silent nap. |
| `pet awake` | — | Wake the pet. Repeated attempts lower mood. |
| `pet petting` | — | Give a little attention. |
| `pet praise` | — | Praise the pet. |
| `pet treat` | — | Offer a treat. |
| `pet apologize` | — | Offer a small mood recovery after a cooldown. |
| `pet quiet` | — | Mute all pet sounds and stop singing. |
| `pet unquiet` | — | Allow pet sounds again. |
| `pet transform` | NAME | Change into any listed pet form. |
| `pet forms` | — | List all available pet forms. |
| `pet sweep` | — | Clean droppings from this wallpaper. |
| `pet droppings` | — | Count droppings across wallpapers. |
| `pet gift` | — | Open or inspect the latest pet gift. |
| `pet poop` | — | Ask the pet to leave a dropping here. |

## Show

| Command | Arguments | Action |
| --- | --- | --- |
| `pet say` | TEXT | Show words in the pet’s speech bubble. |
| `pet sing` | FILE | Play an audio file in the pet’s pitched voice. |
| `pet hush` | — | Stop the current song and dismiss the bubble. |
| `pet dance` | — | Dance in place. |
| `pet spin` | — | Spin in the air. |
| `pet bow` | — | Give a bow. |
| `pet wave` | — | Wave hello. |
| `pet blink` | — | Blink and look around. |
| `pet surprise` | — | Do a startled hop. |
| `pet cheer` | — | Celebrate with stars. |
| `pet sneak` | — | Sneak past the pointer. |
| `pet sulk` | — | Turn away and sulk. |
| `pet banana` | — | Vesper peels and eats a banana. |
| `pet board` | — | Vesper sets down or picks up the surfboard. |
| `pet globe` | — | Vesper spins a tiny Earth on one finger. |
| `pet vine` | — | Vesper swings along a vine. |
| `pet scratch` | — | Scratch or preen. |
| `pet peck` | — | Wendy pecks the ground. |
| `pet strut` | — | Wendy struts across the foreground. |
| `pet feathers` | — | Wendy shakes out her feathers. |
| `pet nest` | — | Wendy settles into a nest. |
| `pet egg` | — | Wendy lays a tiny egg prop. |
| `pet stretch` | — | Stretch wings or arms. |
| `pet salute` | — | Give a quick salute. |
| `pet shake` | — | Shake the whole body. |
| `pet hop` | — | Hop in place. |
| `pet yawn` | — | Yawn slowly. |
| `pet joke` | — | Tell a short joke. |
| `pet fortune` | — | Give a tiny fortune. |
| `pet hello` | — | Greet you in a speech bubble. |
| `pet thanks` | — | Thank you in a speech bubble. |

## Tasks

| Command | Arguments | Action |
| --- | --- | --- |
| `pet locate` | [me] | Find and report the pointer location. |
| `pet folder` | [PATH] | Show or set the pet’s quick-access folder. |
| `pet home` | — | Open the quick-access folder. |
| `pet open` | PATH | Open a local file or folder through KDE. |
| `pet reveal` | PATH | Reveal a local file in the file manager. |
| `pet fetch` | SOURCE to DESTINATION\|me | Copy a file after approval, or bring a clickable file card to the pointer. |
| `pet write` | in FILE -TEXT | Append text to a file after approval. |
| `pet read` | FILE | Read a small text preview. |
| `pet list` | [FOLDER] | List entries in the quick-access folder or another folder. |
| `pet mkdir` | FOLDER | Create a folder after approval. |
| `pet code` | COMMAND | Show the pet typing a draft into the attached Blackbox shell. |
| `pet terminal` | [ROOM] | Attach a shell workspace to an Idle wallpaper. |
| `pet volume` | 0..100 | Set speaker volume after approval. |
| `pet louder` | — | Raise speaker volume one step after approval. |
| `pet quieter` | — | Lower speaker volume one step after approval. |
| `pet close-app` | — | Ask the last active normal application window to close after approval. |
| `pet battle` | — | Start an expedition from Idle after approval. |
| `pet auto` | — | Start or enable Auto within the game’s existing limits. |
| `pet save` | — | Save the current Blackbox checkpoint. |
| `pet load` | — | Load the existing expedition checkpoint after approval. |
| `pet report` | [TEXT] | Open the bug reporter or save a short local report. |
| `pet time` | — | Say the local time. |
| `pet room` | — | Say the current wallpaper. |
| `pet weather` | — | Give the current Idle weather. |
| `pet directions` | — | List the available wallpaper route names. |

