// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "{{App-Name}}",
    dependencies: [
      .package(url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.2.0"),
    ],
    targets: [
        // This is just an arbitrary Swift file in the app, that has
        // no dependencies outside of Foundation, the dependencies section
        .target(name: "{{App-Name}}", dependencies: ["xcodegen"], path: "Modules", sources: ["tools.swift"]),
    ]
)
