// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EmbeddableVoiceAssistant",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EmbeddableVoiceAssistant",
            targets: ["EmbeddableVoiceAssistant"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "0.1.2"),
        .package(name: "AdaptiveCardUI", url: "https://github.com/Master-Of-Code-Global/AdaptiveCardUI", from: "0.1.0"),
        .package(name: "DirectLine", url: "https://github.com/Master-Of-Code-Global/DirectLine", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EmbeddableVoiceAssistant",
            dependencies: ["Introspect", "AdaptiveCardUI", "DirectLine"],
            resources: [
                  .copy("Roboto-Regular.ttf")
              ]),
    ]
)
