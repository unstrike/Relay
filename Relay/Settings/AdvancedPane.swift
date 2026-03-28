import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI
import UniformTypeIdentifiers

struct AdvancedPane: View {
  private let contentWidth = 640.0

  @EnvironmentObject private var config: UserConfig

  @Default(.configDir) var configDir
  @Default(.modifierKeyConfiguration) var modifierKeyConfiguration
  @Default(.autoOpenCheatsheet) var autoOpenCheatsheet
  @Default(.cheatsheetDelayMS) var cheatsheetDelayMS
  @Default(.reactivateBehavior) var reactivateBehavior
  @Default(.showAppIconsInCheatsheet) var showAppIconsInCheatsheet
  @Default(.screen) var screen

  var body: some View {
    Settings.Container(contentWidth: contentWidth) {
      Settings.Section(title: "Config", bottomDivider: true) {
        Text(config.url.path).lineLimit(1).truncationMode(.middle)
        HStack {
          Button("Reveal") {
            NSWorkspace.shared.activateFileViewerSelecting([config.url])
          }
          Button("Export…") {
            let panel = NSSavePanel()
            panel.nameFieldStringValue = "config.json"
            panel.allowedContentTypes = [.json]
            if panel.runModal() == .OK, let url = panel.url {
              config.exportConfig(to: url)
            }
          }
          Button("Import…") {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowedContentTypes = [.json]
            if panel.runModal() == .OK, let url = panel.url {
              config.importConfig(from: url)
            }
          }
          Button("Reset to Default…") {
            let alert = NSAlert()
            alert.messageText = "Reset configuration?"
            alert.informativeText =
              "This will replace your current config with the default. This cannot be undone."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Reset")
            alert.addButton(withTitle: "Cancel")
            if alert.runModal() == .alertFirstButtonReturn {
              configDir = UserConfig.defaultDirectory()
              config.resetToDefault()
            }
          }
        }
      }

      Settings.Section(
        title: "Modifier Keys", bottomDivider: true
      ) {
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Picker("", selection: $modifierKeyConfiguration) {
              ForEach(ModifierKeyConfig.allCases) { config in
                Text(config.description).tag(config)
              }
            }
            .frame(width: 280)
            .labelsHidden()
          }

          VStack(alignment: .leading, spacing: 8) {
            Text(
              "Group Actions: When the modifier key is held while pressing a group key, it runs all actions in that group and its sub-groups."
            )
            .font(.callout)
            .foregroundColor(.secondary)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text(
              "Sticky Mode: When the modifier key is held while triggering an action, Relay stays open after the action completes."
            )
            .font(.callout)
            .foregroundColor(.secondary)
          }
        }
        .padding(.top, 2)
      }

      Settings.Section(title: "Cheatsheet", bottomDivider: true) {
        HStack(alignment: .firstTextBaseline) {
          Picker("Show", selection: $autoOpenCheatsheet) {
            Text("Always").tag(AutoOpenCheatsheetSetting.always)
            Text("After …").tag(AutoOpenCheatsheetSetting.delay)
            Text("Never").tag(AutoOpenCheatsheetSetting.never)
          }.frame(width: 120)

          if autoOpenCheatsheet == .delay {
            TextField(
              "", value: $cheatsheetDelayMS, formatter: NumberFormatter()
            )
            .frame(width: 50)
            Text("milliseconds")
          }

          Spacer()
        }

        Text(
          "The cheatsheet can always be manually shown by \"?\" when Relay is activated."
        )
        .padding(.vertical, 2)

        Defaults.Toggle(
          "Show expanded groups in cheatsheet", key: .expandGroupsInCheatsheet)
        Defaults.Toggle(
          "Show icons", key: .showAppIconsInCheatsheet)
        Defaults.Toggle(
          "Use favicons for URLs", key: .showFaviconsInCheatsheet
        ).padding(.leading, 20).disabled(!showAppIconsInCheatsheet)
        Defaults.Toggle(
          "Show item details in cheatsheet", key: .showDetailsInCheatsheet)

      }

      Settings.Section(title: "Activation", bottomDivider: true) {
        VStack(alignment: .leading) {
          Text(
            "Pressing the global shortcut key while Relay is active should …"
          )

          Picker(
            "Reactivation behavior", selection: $reactivateBehavior
          ) {
            Text("Hide Relay").tag(ReactivateBehavior.hide)
            Text("Reset group selection").tag(ReactivateBehavior.reset)
            Text("Do nothing").tag(ReactivateBehavior.nothing)
          }
          .labelsHidden()
          .frame(width: 220)
        }
      }

      Settings.Section(title: "Show Relay on", bottomDivider: true) {
        Picker("", selection: $screen) {
          Text("Screen containing mouse").tag(Screen.mouse)
          Text("Primary screen").tag(Screen.primary)
          Text("Screen with active window").tag(Screen.activeWindow)
        }
        .labelsHidden()
        .frame(width: 220)
      }
      Settings.Section(title: "Other") {
        Defaults.Toggle("Show Relay in menubar", key: .showMenuBarIcon)
        VStack(alignment: .leading, spacing: 4) {
          Defaults.Toggle(
            "Force English keyboard layout", key: .forceEnglishKeyboardLayout)
          Text(
            "When enabled, letter keys are interpreted in US-English (QWERTY) regardless of your current keyboard layout."
          )
          .font(.caption)
          .foregroundColor(.secondary)
          .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
  }
}

struct AdvancedPane_Previews: PreviewProvider {
  static var previews: some View {
    return AdvancedPane()
    //      .environmentObject(UserConfig())
  }
}
