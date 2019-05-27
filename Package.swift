// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "{{App-Name}}",
    dependencies: [
		.package(url: "https://github.com/mxcl/swift-sh.git", from: "1.12.0"),
		.package(url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.5.0"),
    ],
    targets: [
        // This is just an arbitrary Swift file in the app, that has
        // no dependencies outside of Foundation, the dependencies section
        .target(name: "{{App-Name}}", dependencies: [
						       "swift-sh",
        						"xcodegen",
        					    ],
        		path: "Modules", sources: ["tools.swift"]),
    ]
)
