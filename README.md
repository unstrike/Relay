# Relay

**The keystroke relay — chain shortcuts to any destination.**

A macOS menu bar app that lets you define multi-key chord shortcuts that relay your intent to apps, shell commands, URLs, and more. Inspired by Vim's `<leader>` key and tmux prefix bindings.

> Forked from [mikker/LeaderKey](https://github.com/mikker/LeaderKey) — renamed per the author's request when distributing.

---

## How it works

Press your trigger key, then follow with a sequence of keys. Each key navigates a tree of shortcuts until you reach an action — which Relay fires off to its destination.

- <kbd>trigger</kbd><kbd>o</kbd><kbd>m</kbd> → Open Messages
- <kbd>trigger</kbd><kbd>m</kbd><kbd>m</kbd> → Mute audio
- <kbd>trigger</kbd><kbd>w</kbd><kbd>m</kbd> → Maximize window

No fuzzy search, no typing names — just muscle memory.

## Install

Download the latest `Relay.zip` from [Releases](https://github.com/unstrike/Relay/releases), unzip, and move `Relay.app` to `/Applications`.

**First launch:** macOS will block the app because it isn't notarized (requires a paid Apple developer account). To bypass Gatekeeper:

```sh
xattr -dr com.apple.quarantine /Applications/Relay.app
```

Then open normally.

**Build from source:**

```sh
git clone https://github.com/unstrike/Relay.git
cd Relay
open "Relay.xcodeproj"
```

## Setup

1. Click the menu bar icon → Settings
2. Set your trigger key (`Shortcut`) — any key or combo, e.g. <kbd>F12</kbd>, <kbd>⌘⌥Space</kbd>, or a hyper key via [Karabiner](https://karabiner-elements.pqrs.org/)
3. Add shortcuts in the Config tab

## Trigger key recommendations

- <kbd>F12</kbd>
- <kbd>⌘ + Space</kbd>
- <kbd>⌘⌥⌃⇧ + L</kbd> (hyper key)
- <kbd>Caps Lock</kbd> → <kbd>F12</kbd> via Karabiner (tap to trigger, hold for hyper)

## Group shortcuts

Top-level groups can be assigned a global shortcut that fires them directly — skipping the trigger key entirely. Click the shortcut field on any top-level group row in the Config editor and record a key combo.

Useful for your most-reached groups when a single chord beats a two-step sequence.

## URL Scheme

Relay supports URL scheme automation for integration with Alfred, Raycast, shell scripts, and more.

```bash
# Show the Relay window
open "relay://activate"

# Navigate and execute a shortcut sequence
open "relay://navigate?keys=o,m"

# Navigate without executing (preview)
open "relay://navigate?keys=o,m&execute=false"

# Reload config from disk
open "relay://config-reload"

# Reveal config.json in Finder
open "relay://config-reveal"

# Open settings
open "relay://settings"

# Reset navigation to root
open "relay://reset"
```

## FAQ

**Command action failing with "Command not found"?**

Your shell's `PATH` must be exported in the non-interactive config file:
- zsh: `~/.zshenv`
- bash: `~/.bash_profile`

**Disabled the menu bar icon and can't get back?**

Activate Relay, then press <kbd>⌘,</kbd>.

## License

MIT
