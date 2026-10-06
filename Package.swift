// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Prompty",
    platforms: [.macOS("27.0")],
    targets: [
        .executableTarget(
            name: "Prompty",
            path: "Sources/Prompty"
        )
    ]
)
