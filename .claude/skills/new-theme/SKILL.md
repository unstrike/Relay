---
name: new-theme
description: "Scaffold a new Relay theme — generates the Swift file, patches Theme.swift, and walks through Xcode target registration. Use whenever the user wants to add a theme, create a new visual style or layout variant, or asks how to theme Relay."
---

# New Theme Skill

Scaffold a new theme for Relay. Themes subclass `MainWindow`, provide a SwiftUI `MainView`, and must be registered in `Theme.swift`.

## Steps

### 1. Collect details

Ask the user for:
- **Class name** — PascalCase, used as the Swift enum name (e.g. `Compact`)
- **Display name** — shown in Settings UI (e.g. `"Compact"`)

### 2. Run the scaffold script

```bash
bin/new-theme <ClassName> "<Display Name>"
```

Example:
```bash
bin/new-theme Compact "Compact"
```

This:
- Creates `Relay/Themes/<ClassName>.swift` with boilerplate `Window` + `MainView`
- Patches `Relay/Theme.swift` with the new enum case, `classFor`, `name`, and `all` entries

### 3. Show the user what was created

Read and display both modified files:
- `Relay/Themes/<ClassName>.swift` — the new theme
- `Relay/Theme.swift` — verify the patch looks correct

### 4. Xcode target registration

The script cannot add files to the Xcode project. Instruct the user:

> In Xcode: right-click `Relay/Themes/` in the Project Navigator → **Add Files to "Relay"** → select `<ClassName>.swift` → ensure **Target: Relay** is checked.

### 5. Customise

Point the user to the key areas to customise in the generated file:
- `static let size` — window dimensions
- `show(on:after:)` — positioning and animation
- `hide(after:)` — dismissal animation
- `cheatsheetOrigin(cheatsheetSize:)` — where the cheatsheet appears relative to the window
- `MainView.body` — the SwiftUI visual content

## Theme Anatomy

```
enum ThemeName {
  static let size: CGFloat        // window size constant(s)

  class Window: MainWindow {      // handles positioning, animation, keyboard
    required init(controller:)    // set up frame + SwiftUI content view
    func show(on:after:)          // position on screen, animate in
    func hide(after:)             // animate out
    func notFound()               // feedback when key not found (e.g. shake())
    func cheatsheetOrigin(...)    // where to place the cheatsheet popover
  }

  struct MainView: View {         // SwiftUI visual — receives UserState via @EnvironmentObject
    var body: some View
  }
}
```

## Available Animations (from NSWindow+Animations)

- `fadeIn`, `fadeOut`
- `fadeInAndUp`, `fadeOutAndDown`
- `shake()`
