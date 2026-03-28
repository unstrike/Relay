import AppKit
import KeyboardShortcuts
import ObjectiveC

private class ClosureTarget: NSObject {
  let handler: () -> Void
  init(_ handler: @escaping () -> Void) { self.handler = handler }
  @objc func go() { handler() }
}

/// Custom shortcut recorder button that uses local event monitors instead of the responder chain.
/// KeyboardShortcuts.RecorderCocoa relies on flagsChanged via the responder chain, which
/// NSOutlineView intercepts — so modifier keys are never tracked. This implementation
/// uses NSEvent.addLocalMonitorForEvents to capture both keyDown and flagsChanged directly.
class GlobalShortcutButton: NSButton {
  private let shortcutName: KeyboardShortcuts.Name
  private let onChange: (Bool) -> Void

  private var isRecording = false
  private var pendingModifiers: NSEvent.ModifierFlags = []
  private var keyMonitor: Any?
  private var flagsMonitor: Any?

  init(name: KeyboardShortcuts.Name, onChange: @escaping (Bool) -> Void) {
    self.shortcutName = name
    self.onChange = onChange
    super.init(frame: .zero)
    bezelStyle = .rounded
    controlSize = .regular
    updateTitle()
    let closureTarget = ClosureTarget { [weak self] in self?.toggleRecording() }
    target = closureTarget
    action = #selector(ClosureTarget.go)
    objc_setAssociatedObject(
      self, Unmanaged.passUnretained(self).toOpaque(), closureTarget,
      .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

  deinit { stopRecording() }

  private func updateTitle() {
    if isRecording {
      title = "Type shortcut…"
      contentTintColor = .white
      bezelColor = .systemBlue
    } else if let shortcut = KeyboardShortcuts.getShortcut(for: shortcutName) {
      title = shortcut.description
      contentTintColor = nil
      bezelColor = nil
    } else {
      title = "Record Shortcut"
      contentTintColor = nil
      bezelColor = nil
    }
  }

  private func toggleRecording() {
    if isRecording {
      stopRecording()
    } else {
      startRecording()
    }
  }

  private func startRecording() {
    isRecording = true
    pendingModifiers = []
    updateTitle()

    flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
      self?.pendingModifiers = event.modifierFlags.intersection([
        .command, .option, .control, .shift,
      ])
      return event
    }

    keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return event }

      // Escape cancels recording
      if event.keyCode == 53 {
        self.stopRecording()
        return nil
      }

      // Backspace/Delete clears the shortcut
      if event.keyCode == 51 || event.keyCode == 117 {
        KeyboardShortcuts.reset([self.shortcutName])
        self.onChange(false)
        self.stopRecording()
        return nil
      }

      // Reject reserved system keys (Tab)
      if event.keyCode == 48 {
        self.window?.shake()
        return nil
      }

      // Require at least one modifier key
      guard !self.pendingModifiers.isEmpty else { return nil }

      if let shortcut = KeyboardShortcuts.Shortcut(event: event) {
        KeyboardShortcuts.setShortcut(shortcut, for: self.shortcutName)
        self.onChange(true)
      }
      self.stopRecording()
      return nil
    }
  }

  private func stopRecording() {
    isRecording = false
    pendingModifiers = []
    if let monitor = keyMonitor {
      NSEvent.removeMonitor(monitor)
      keyMonitor = nil
    }
    if let monitor = flagsMonitor {
      NSEvent.removeMonitor(monitor)
      flagsMonitor = nil
    }
    updateTitle()
  }
}
