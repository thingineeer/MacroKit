// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "macroKit",
    // Macro targets execute on the host Mac. Use macOS 13+ to match swift-syntax 602 prebuilts.
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "macroKit",
            targets: ["macroKit"]
        ),
        .executable(
            name: "macroKitClient",
            targets: ["macroKitClient"]
        ),
    ],
    dependencies: [
        // Pin to a toolchain-matching swift-syntax. Adjust if your Xcode requires a different 602 patch.
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "602.0.0"),
    ],
    targets: [
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "macroKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "macroKit", dependencies: ["macroKitMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "macroKitClient", dependencies: ["macroKit"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "macroKitTests",
            dependencies: [
                "macroKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
