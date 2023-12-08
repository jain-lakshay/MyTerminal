# MyTerminalApp
This is a simple terminal emulator application built using SwiftUI and Combine. It allows users to execute commands in a terminal-like interface and displays the output of these commands. The application also maintains a history of the commands that have been run.

## Features
Execute terminal commands: Users can type in commands in the terminal and the application will execute these commands and display the output.
Command history: The application maintains a history of the commands that have been run. Users can navigate through this history using the "previousCommand" and "nextCommand" methods.
Change directory: The application supports changing the current directory using the "cd" command.
Display command history: The application supports displaying the command history using the "history" command.
Clear command history: The application supports clearing the command history using the "clear" command.
Code Structure
The application is structured into three main Swift files:

### Terminal.swift: 
This file defines the Terminal class, which is responsible for executing commands and maintaining the command history. It uses the Process class from the Foundation framework to execute commands and a Pipe to capture the output of these commands.
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
### ContentView.swift:
 This file defines the ContentView struct, which is the main view of the application. It uses a TextField for inputting commands and a Text view for displaying the output of the commands. It also uses a List to display the command history.
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
### MyTerminalApp.swift:
 This file defines the MyTerminalApp struct, which is the main entry point of the application.
@main
struct MyTerminalApp: App {
   var body: some Scene {
       WindowGroup {
           ContentView()
       }
   }
}
### How to Run
To run this application, you need to have Xcode installed on your machine. Clone the repository, open the project in Xcode, and then click the "Run" button.

### Contributing
Contributions are welcome. Please feel free to submit a pull request or open an issue if you find a bug or have a feature request. 
