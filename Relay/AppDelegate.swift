import Cocoa
import Defaults
import KeyboardShortcuts
import Settings
import SwiftUI
import os

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,
  NSWindowDelegate
{
  private lazy var state: UserState = UserState(userConfig: config)
  private lazy var controller: Controller = Controller(userState: state, userConfig: config)

  let statusItem = StatusItem()
  let config = UserConfig()

  lazy var settingsWindowController = SettingsWindowController(
    panes: [
      Settings.Pane(
        identifier: .general, title: "General",
        toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)
          ?? NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil) ?? NSImage(),
        contentView: { GeneralPane().environmentObject(self.config) }
      ),
      Settings.Pane(
        identifier: .advanced, title: "Advanced",
        toolbarIcon: NSImage(named: NSImage.advancedName)
          ?? NSImage(systemSymbolName: "slider.horizontal.3", accessibilityDescription: nil)
          ?? NSImage(),
        contentView: {
          AdvancedPane().environmentObject(self.config)
        }),
    ],
    style: .segmentedControl,
  )

  func applicationDidFinishLaunching(_: Notification) {

    guard
      ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"
    else { return }
    #if DEBUG
      guard !isRunningTests() else { return }
    #endif

    NSApp.mainMenu = MainMenu()

    config.ensureAndLoad()
    // Access lazy vars to trigger initialization in the correct order
    _ = controller

    statusItem.handlePreferences = {
      self.showSettings()
    }
    statusItem.handleAbout = {
      NSApp.orderFrontStandardAboutPanel(nil)
    }
    statusItem.handleReloadConfig = {
      self.config.reloadFromFile()
    }
    statusItem.handleRevealConfig = {
      NSWorkspace.shared.activateFileViewerSelecting([self.config.url])
    }
    Task {
      for await value in Defaults.updates(.showMenuBarIcon) {
        if value {
          self.statusItem.enable()
        } else {
          self.statusItem.disable()
        }
      }
    }

    // Initialize status item according to current preference
    if Defaults[.showMenuBarIcon] {
      statusItem.enable()
    } else {
      statusItem.disable()
    }

    // Activation policy is managed solely by the Settings window

    registerGlobalShortcuts()
  }

  func activate() {
    if self.controller.window.isKeyWindow {
      switch Defaults[.reactivateBehavior] {
      case .hide:
        self.hide()
      case .reset:
        self.controller.userState.clear()
      case .nothing:
        return
      }
    } else if self.controller.window.isVisible {
      // should never happen as the window will self-hide when not key
      self.controller.window.makeKeyAndOrderFront(nil)
    } else {
      self.show()
    }
  }

  public func registerGlobalShortcuts() {
    KeyboardShortcuts.removeAllHandlers()

    KeyboardShortcuts.onKeyDown(for: .activate) {
      self.activate()
    }

    for groupKey in Defaults[.groupShortcuts] {
      #if DEBUG
        Logger(subsystem: "com.brnbw.Relay", category: "shortcuts").debug(
          "Registering shortcut for \(groupKey, privacy: .private)")
      #endif
      KeyboardShortcuts.onKeyDown(for: KeyboardShortcuts.Name("group-\(groupKey)")) {
        if !self.controller.window.isVisible {
          self.activate()
        }
        self.processKeys([groupKey])
      }
    }
    if Defaults[.groupShortcuts].isEmpty && !KeyboardShortcuts.isEnabled(for: .activate) {
      showSettings()
    }
  }

  func applicationWillTerminate(_ notification: Notification) {
    // Config saves automatically on changes
  }

  @IBAction
  func settingsMenuItemActionHandler(_: NSMenuItem) {
    showSettings()
  }

  func show() {
    controller.show()
  }

  func hide() {
    controller.hide()
  }

  #if DEBUG
    func isRunningTests() -> Bool {
      let environment = ProcessInfo.processInfo.environment
      guard environment["XCTestSessionIdentifier"] != nil else { return false }
      return true
    }
  #endif

  // MARK: - URL Scheme Handling

  func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      handleURL(url)
    }
  }

  private func handleURL(_ url: URL) {
    let action = URLSchemeHandler.parse(url)

    switch action {
    case .settings:
      showSettings()
    case .about:
      NSApp.orderFrontStandardAboutPanel(nil)
    case .configReload:
      config.reloadFromFile()
    case .configReveal:
      NSWorkspace.shared.selectFile(config.path, inFileViewerRootedAtPath: "")
    case .activate:
      activate()
    case .hide:
      hide()
    case .reset:
      state.clear()
    case .navigate(let keys, let execute):
      show()
      processKeys(keys, execute: execute)
    case .show:
      show()
    case .invalid:
      return
    }
  }

  private func processKeys(_ keys: [String], execute: Bool = true) {
    guard !keys.isEmpty else { return }

    controller.handleKey(keys[0], execute: execute)

    if keys.count > 1 {
      let remainingKeys = Array(keys.dropFirst())

      var delayMs = 100
      for key in remainingKeys {
        delay(delayMs) { [weak self] in
          self?.controller.handleKey(key, execute: execute)
        }
        delayMs += 100
      }
    }
  }

  // MARK: - Activation Policy: Only Settings Visibility Controls It

  private func showSettings() {
    // Behave like a normal app while Settings is open
    NSApp.setActivationPolicy(.regular)
    settingsWindowController.show()
    NSApp.activate(ignoringOtherApps: true)
    settingsWindowController.window?.delegate = self
    // Suppress toolbar item labels that macOS renders below the segmented control
    settingsWindowController.window?.toolbar?.displayMode = .iconOnly
  }

  // Revert to accessory when Settings window closes
  func windowWillClose(_ notification: Notification) {
    guard let win = notification.object as? NSWindow,
      win == settingsWindowController.window
    else { return }
    NSApp.setActivationPolicy(.accessory)
  }

}
