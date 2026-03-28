import Cocoa

class CommandRunner {
  static func run(_ command: String) {
    let task = Process()
    task.launchPath = "/bin/zsh"
    task.arguments = ["-c", command]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    task.standardOutput = outputPipe
    task.standardError = errorPipe

    task.terminationHandler = { process in
      let output =
        String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
      let error =
        String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

      guard process.terminationStatus != 0 else { return }

      let combined = [error, output].joined(separator: "\n")
        .trimmingCharacters(in: .whitespacesAndNewlines)
      let alertText = String(combined.prefix(512))

      DispatchQueue.main.async {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "Command failed with exit code \(process.terminationStatus)"
        alert.informativeText = alertText
        alert.runModal()
      }
    }

    do {
      try task.run()
    } catch {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "Failed to run command"
      alert.informativeText = error.localizedDescription
      alert.runModal()
    }
  }
}
