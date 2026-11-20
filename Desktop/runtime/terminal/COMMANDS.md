# Pure Code command reference

Pure Code runs your usual Linux shell inside the Blackbox wallpaper. Ordinary commands work normally. Use `cd` to change folders, `&&` to continue after success, and `|` to pass output to another command. Each shell pane has its own working directory. An output pane shows the transcript of its linked shell.

| Input | Action |
| --- | --- |
| Up and Down | Recall commands using the shell’s history |
| Ctrl+C | Interrupt the foreground command |
| Ctrl+Shift+C and Ctrl+Shift+V | Copy selected text and paste from the desktop clipboard |
| Ctrl+click a link | Open it through KDE |
| Ctrl+F | Search the terminal, including scrollback |
| Shift+Page Up and Shift+Page Down | Scroll by a page |
| Right-click | Split, mirror output, search, copy, paste, or adjust text size |
| Drag a divider | Resize the panes on either side |
| Alt+Left | Leave Pure Code without closing its shells |

## Learn by example

```sh
box help
box help -options
box help -options =graphics
box help -options =graphics .framing
box help -pet =commands .tasks
box help -pet =commands '.flight+.care'
box get framing
box set framing 16:9
box theme custom --background '#10131c' --accent '#bc91e8'
cd "$(box location ~/Projects)" && ls
box set backgroundIdle on && box room front
```

Quote tokens beginning with `=` when using a shell that expands them, for example `box help -options '=graphics'`. Pure Code starts Zsh with that expansion disabled so the unquoted examples work there.

## Commands

| Command | What it does |
| --- | --- |
| `box help [COMMAND [TOPIC]]` | Show the full command tree or expand one branch. The last line links to this reference. |
| `box manual [--open]` | Print this reference, or open it with KDE’s file association. |
| `box me` | Run the animated ASCII cube and leave a large drawing in the transcript. |
| `box status [--json]` | Inspect the game, room, pet, and terminal panes as text or JSON. |
| `box options [SECTION]` | List current settings, optionally limited to one section. |
| `box get KEY` | Print the value of one setting as JSON, suitable for scripts. |
| `box set KEY VALUE` | Validate and apply one setting. `box help -options =KEY` shows its accepted type. |
| `box theme [NAME]` | List or select `bloodShrine`, `armory`, `terminal`, `dossier`, `lockdown`, or `dark`. |
| `box theme custom [--foreground HEX] [--background HEX] [--accent HEX]` | Change one or more Pure Code colours. Quote values such as `'#b585ee'` so the shell treats the hash as text. |
| `box theme reset` | Restore the terminal colours supplied by the active KDE appearance. |
| `box wallpaper ROOM FILE` | Choose an image. Use `default` as the file to restore bundled art. `cube` is the overview backdrop. |
| `box room ROOM` | Go directly to `front`, `left`, `right`, `up`, `down`, or `back` in Idle. |
| `box exit` | Return to the Shrine. Terminal panes stay open for your next visit. |
| `box look DIRECTION` | Turn one step left, right, up, or down. |
| `box files [FOLDER]` | List a local folder, including hidden entries. Defaults to your current folder. |
| `box location [FOLDER]` | Resolve a folder to an absolute path. Use `cd "$(box location FOLDER)"` to enter it. |
| `box pet COMMAND [ARGS]` or `pet COMMAND [ARGS]` | Give the roaming pet a task. Try `pet help`, `pet fly 600,240`, or `pet say hello`. Enable Pet admin in BX or Desktop settings first. [Pet command reference](PET.md) |
| `box report [TEXT]` | Save a report to the local issue ledger. With no text, open the reporter where you can add an optional screenshot. |
| `box reset settings --yes` | Restore Blackbox desktop preferences and keep your artwork and saves. |
| `box reset images --yes` | Restore bundled images and keep your preferences and saves. |
| `box admin [-password =PHRASE]` | Unlock game practice for your Blackbox desktop profile until you lock it. The interactive prompt keeps the phrase out of shell history. |
| `box admin --lock` | Lock game practice for this desktop profile. |

## Game practice

`box admin` enables Blackbox game-practice commands in your desktop profile across shells and restarts. Normal Linux account permissions still apply. Practice commands apply to the setup screen before a wave. For example, run `box debug practice 20 --difficulty hard --build star && box debug money on`.

| Command | What it does |
| --- | --- |
| `box debug practice WAVE [--difficulty normal\|hard\|insane] [--build standard\|star\|random]` | Set up a practice run at wave 10–150 in ten-wave steps. |
| `box debug money on\|off` | Toggle unlimited run gold. |
| `box debug weapon WEAPON_ID` | Equip a specific catalogued weapon for a practice run. |
| `box debug weather WEATHER_ID` | Set the practice wave’s weather. Try `rain`, `fog`, or `winter`. |
| `box debug unlocks on\|off` | Toggle all unlocks for this practice run. |

## Settings and value types

Use `box help -options =SECTION` for the names and permitted values, and `box options SECTION` for live values. The sections are **idle**, **graphics**, **audio**, **play**, **desktop**, **terminal**, and **pet**. Values include switches, ranges, named choices, local file paths, text, and JSON objects. Coordinates use `X,Y`.

```sh
box set idleFps 20
box set audioAmbience 0.6
box set terminalFontSize 18
box set terminalImage ~/Pictures/terminal.webp
box set terminalOpacity 0.82
box set petFolder ~/Documents
box set terminalPalette '{"background":"#151924","foreground":"#e9e7f8","accent":"#b585ee"}'
box set controlBindings '{}'
```

The terminal’s split layout and running shells are kept while visiting other rooms in this wallpaper session. Closing a shell pane closes its linked output panes. Unloading the Blackbox wallpaper ends the embedded shell sessions.
