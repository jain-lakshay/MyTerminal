import Foundation
import SwiftUI
import Combine

class Terminal: ObservableObject {
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
        } else {
            self.output = "Error: Failed to convert output to string"
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

struct ContentView: View {
    @State private var command = ""
    @StateObject private var terminal = Terminal()
    @State private var previousCommands: [String] = []

    var body: some View {
        VStack {
            TextField("Enter command", text: $command, onCommit: {
                terminal.runCommand(command)
                previousCommands.append(command)
                command = ""
            })
            .padding()
            .border(Color.primary, width: 2)
            
            Text(terminal.output)
                .padding()
            
            List(previousCommands, id: \.self) { command in
                Text(command)
            }
        }
        .padding()
        .onReceive(Just(command)) { newValue in
            DispatchQueue.main.async {
                if newValue.hasPrefix("cd ") {
                    let directory = newValue.replacingOccurrences(of: "cd ", with: "")
                    FileManager.default.changeCurrentDirectoryPath(directory)
                } else if newValue == "history" {
                    terminal.output = "Command history: \(terminal.history)"
                } else if newValue == "clear" {
                    terminal.history.removeAll()
                    terminal.output = ""
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
