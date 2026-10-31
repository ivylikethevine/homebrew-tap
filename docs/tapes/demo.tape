# The README's demo: install say-hi with Homebrew on a Mac, then use it for a
# check every deploy ends in, whether prod runs what was merged. Render with
# `vhs docs/tapes/demo.tape` (https://github.com/charmbracelet/vhs) from the repo
# root, with docker running; the first render builds both images, and
# `docs/tapes/fixtures.sh down` clears the stage after.
#
# The Mac is a Linux Homebrew in a container (docs/tapes/mac.Dockerfile), so the
# render is the same on any machine; the window, palette and prompt are
# macOS's. The install is the live tap's `main` and say-hi's latest release.
#
# Hide blocks pace on sentinel text, never fixed sleeps; the quoted split in
# fixture-o''k keeps the typed command from matching its own sentinel. Visible
# sleeps are reading time only. The session's exit waits on /Disconnected/,
# which hi prints as the session ends.

Output docs/tapes/demo.gif

Require docker

# say-hi's demo geometry, in a macOS window: the traffic lights, the rounded
# corners on a backdrop, and Terminal.app's Basic profile in dark mode (the
# palette of iTerm2-Color-Schemes' vhs/Terminal Basic Dark.json). Menlo where
# the renderer has it, else DejaVu Sans Mono, the face Menlo was drawn from.
Set FontSize 16
Set FontFamily "Menlo, DejaVu Sans Mono"
Set Width 1120
Set Height 800
Set Padding 20
Set Margin 24
Set MarginFill "#5b6eae"
Set WindowBar Colorful
Set BorderRadius 10
Set TypingSpeed 40ms
Set Theme { "name": "Terminal Basic Dark", "black": "#000000", "red": "#c65339", "green": "#6ac44b", "yellow": "#b8b74a", "blue": "#6444ed", "purple": "#d357db", "cyan": "#69c1cf", "white": "#d1d1d1", "brightBlack": "#909090", "brightRed": "#eb5a3a", "brightGreen": "#77ea51", "brightYellow": "#efef53", "brightBlue": "#d09af9", "brightPurple": "#eb5af7", "brightCyan": "#78f1f2", "brightWhite": "#ededed", "background": "#1d1e1d", "foreground": "#ffffff", "cursor": "#9d9d9d", "selection": "#3f638a" }

Hide
Type "docs/tapes/fixtures.sh up >/tmp/tap-demo.log 2>&1 && echo fixture-o''k"
Enter
Wait+Screen@900s /fixture-ok/
# a login zsh in the Mac, opened the way Terminal opens a window
Type "exec docker exec -it tap-demo-mac zsh -l"
Enter
Wait+Line@30s /^maya@Mayas-MacBook-Pro .* %$/
Type `clear && printf 'Last login: %s on ttys000\n' "$(date '+%a %b %e %H:%M:%S')"`
Enter
Wait+Line@10s /^maya@Mayas-MacBook-Pro .* %$/
Show

Sleep 1s
Type "brew install ivylikethevine/tap/say-hi"
Enter
# the prompt, not a `%` alone: curl's progress bar ends in one too
Wait+Line@300s /^maya@Mayas-MacBook-Pro .* %$/
Sleep 3s

# a preset, the one question a first install asks
Type "hi --install --preset balanced"
Enter
Wait+Line@60s /^maya@Mayas-MacBook-Pro .* %$/
Sleep 3s

# Cmd-K, so the session opens on a clean window
Hide
Type "clear"
Enter
Wait+Line@10s /^maya@Mayas-MacBook-Pro .* %$/
Show

Type "hi web-prod"
Enter
Wait+Screen@60s /hi loaded:/
Sleep 3s

# the prompt names the branch and flags the edit before anything is asked
Type "cd /srv/app"
Enter
Sleep 2s
Type "git diff"
Enter
Sleep 4s

Type "exit"
Enter
Wait+Screen@30s /Disconnected/
Sleep 4s
