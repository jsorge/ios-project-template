#!/usr/bin/swift sh

import Files // @JohnSundell ~> 3.1.0
import Foundation
import Yams // @jpsim ~> 2.0.0

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

enum ModuleType: Int, CaseIterable {
	case framework = 1
	case iosApp = 2
	case macApp = 3

	init?(text: String) {
		guard let num = Int(text), let moduleType = ModuleType(rawValue: num) else { return nil }
		self = moduleType
	}

	var templateFolder: String {
		switch self {
		case .framework: return "!Module-Template"
		case .iosApp: return "!iOS-App-Template"
		case .macApp: return "!Mac-App-Template"
		}
	}
}

Console.writeMessage("What is the name of you new module?")
guard let moduleName = Console.getInput(), moduleName.isEmpty == false else {
    Console.writeMessage("There must be a module name entered")
    exit(EXIT_FAILURE)
}

Console.writeMessage("What kind of module is it?\n1. Framework\n2. iOS app\n3. Mac app")
guard let moduleTypeInput = Console.getInput(), let moduleType = ModuleType(text: moduleTypeInput) else {
	Console.writeMessage("There needs to be a valid module type selected")
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

func addProjectDependency(_ depName: String) throws {
    let projectFile = try Folder.current.file(named: "project.yml")
    let projectContents = try projectFile.readAsString()
    guard var projectYaml = try? Yams.load(yaml: projectContents) as? [String: Any] else {
        Console.writeMessage("Module created but not added to the project yet. Do that manually.", to: .error)
        exit(0)
    }

    var includes = [String]()
    if let projectIncludes = projectYaml["include"] as? [String] {
        includes = projectIncludes
    }

    includes.append("Modules/\(depName)/\(depName).yml")
    projectYaml["include"] = includes

    var fileGroups = [String]()
    if let projectGroups = projectYaml["fileGroups"] as? [String] {
    	fileGroups = projectGroups
    }

    fileGroups.append("Modules/\(depName)/")
    projectYaml["fileGroups"] = fileGroups

    let encodedProject = try Yams.dump(object: projectYaml)
    try projectFile.write(string: encodedProject)
}

func addTargetDependency(_ depName: String) throws {
    let appYamlFile = try Folder.current.subfolder(atPath: "Modules/App").file(named: "app.yml")
    let yamlContents = try appYamlFile.readAsString()
    guard var appYaml = try? Yams.load(yaml: yamlContents) as? [String: Any] else {
        Console.writeMessage("Module created but not added as an app dependency yet. Do that manually.", to: .error)
        exit(0)
    }

    guard var targets = appYaml["targets"] as? [String: Any],
        let appName = targets.keys.first,
        var appTarget = targets[appName] as? [String: Any]
        else { return }

    var deps = [[String: Any]]()
    if let appDeps = appTarget["depdendencies"] as? [[String: Any]] {
        deps = appDeps
    }

    deps.append(["target": depName])
    appTarget["dependencies"] = deps
    targets[appName] = appTarget
    appYaml["targets"] = targets


    let encodedAppFile = try Yams.dump(object: appYaml)
    try appYamlFile.write(string: encodedAppFile)
}

let moduleToken = "{{Module}}"

// copy template folder over
let templateFolder = try Folder.current.subfolder(atPath: "tools/\(moduleType.templateFolder)")
let targetFolder = try Folder.current.subfolder(atPath: "Modules").createSubfolderIfNeeded(withName: moduleName)

for file in templateFolder.files {
    let newFile = try file.copy(to: targetFolder)
    try replaceToken(moduleToken, in: newFile, with: moduleName)
}

for folder in templateFolder.subfolders {
    let newFolder = try folder.copy(to: targetFolder)

    for file in newFolder.files {
        try replaceToken(moduleToken, in: file, with: moduleName)
    }
}

try addProjectDependency(moduleName)

if moduleType == .framework {
	try addTargetDependency(moduleName)
}

