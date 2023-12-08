import Foundation
import Combine

class terminal: ObservableObject {
    @Published var history: [String] = []
    @Published var output: String = ""
    var historyIndex = 0

    func runCommand(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            self.output = output
        }

        history.append(command)
        historyIndex = history.count
    }

    func previousCommand() -> String? {
        if historyIndex > 0 {
            historyIndex -= 1
            return history[historyIndex]
        } else {
            return nil
        }
    }

    func nextCommand() -> String? {
        if historyIndex < history.count - 1 {
            historyIndex += 1
            return history[historyIndex]
        } else {
            return nil
        }
    }
}

