#!/usr/bin/swift sh

import Files // @JohnSundell ~> 3.1.0
import Foundation

/// Used to interact with the console in a CLI context
struct Console {
    /// The type of output to print messages to the console
    enum OutputType {
        /// Standard Output
        case standard
        /// Standard Error
        case error
    }

    /// Reads the input from Standard Input
    static func getInput() -> String? {
        return String(data: FileHandle.standardInput.availableData, encoding: .utf8)?
            .trimmingCharacters(in: .newlines)
    }

    /// Prints the message to the specified output
    ///
    /// - parameter message: The message to print
    /// - parameter output:  The output type to send the message to. It gets prepended with "Error: "
    static func writeMessage(_ message: String, to output: OutputType = .standard) {
        switch output {
        case .standard:
            print(message)
        case .error:
            fputs("Error: \(message)\n", stderr)
        }
    }
}

Console.writeMessage("What is the name of your app?")
guard let appName = Console.getInput(), appName.isEmpty == false else {
    Console.writeMessage("There must be an app name entered")
    exit(EXIT_FAILURE)
}

func replaceToken(_ token: String, in file: File, with name: String) throws {
    if let fileContents = try? file.readAsString(), fileContents.contains(token) {
        let replacedContents = fileContents.replacingOccurrences(of: token, with: name)
        try file.write(string: replacedContents)
    }

    if file.name.contains(token) {
        let newName = file.name.replacingOccurrences(of: token, with: name)
        try file.rename(to: newName)
    }
}

let appToken = "{{App-Name}}"

var files = [File]()
files.append(contentsOf: Folder.current.files)

let appFolder = try Folder.current.subfolder(atPath: "Modules/App")
files.append(contentsOf: appFolder.files)

for folder in appFolder.subfolders {
    files.append(contentsOf: folder.files)
}

for file in files {
    try replaceToken(appToken, in: file, with: appName)
}
