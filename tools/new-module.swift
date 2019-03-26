import Files // marathon:https://github.com/JohnSundell/Files.git
import Foundation
import Yams // marathon:https://github.com/jpsim/Yams.git

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

Console.writeMessage("What is the name of you new module?")
guard let moduleName = Console.getInput(), moduleName.isEmpty == false else {
    Console.writeMessage("There must be a module name entered")
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
    guard let decoded = try? Yams.load(yaml: projectContents) as? [String: Any], var projectYaml = decoded else {
        Console.writeMessage("Module created but not added to the project yet. Do that manually.", to: .error)
        exit(0)
    }

    var includes = [String]()
    if let projectIncludes = projectYaml["include"] as? [String] {
        includes = projectIncludes
    }

    includes.append("Modules/\(depName)/\(depName).yml")
    projectYaml["include"] = includes

    let encodedProject = try Yams.dump(object: projectYaml)
    try projectFile.write(string: encodedProject)
}

func addTargetDependency(_ depName: String) throws {
    let appYamlFile = try Folder.current.subfolder(atPath: "Modules/App").file(named: "app.yml")
    let yamlContents = try appYamlFile.readAsString()
    guard let decoded = try? Yams.load(yaml: yamlContents) as? [String: Any], var appYaml = decoded else {
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
let templateFolder = try Folder.current.subfolder(atPath: "tools/!Module-Template")
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
try addTargetDependency(moduleName)