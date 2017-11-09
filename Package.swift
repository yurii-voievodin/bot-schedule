// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SumDUBot",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/leaf-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/postgresql-provider.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/BrettRToomey/Jobs.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/validation-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/auth-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/debugging.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentProvider", "LeafProvider", "PostgreSQLProvider", "Jobs", "ValidationProvider", "AuthProvider", "Debugging"],
                exclude: [
                    "Config",
                    "Database",
                    "Public",
                    "Resources",
                    ]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
