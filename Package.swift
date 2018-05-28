// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ScheduleVapor",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.3"),
        
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc.2"),
        
        // 🖋🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc.2.3"),
        
        // ✅ Extensible data validation library (name, email, etc)
        .package(url: "https://github.com/vapor/validation.git", from: "2.0.0"),
        
        // A job system for Swift backends.
        .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.2")
    ],
    targets: [
        .target(name: "App",
                dependencies: [
                    "Vapor",
                    "Leaf",
                    "FluentPostgreSQL",
                    "Validation",
                    "Jobs"
            ],
                exclude: [
                    "Config",
                    "Database",
                    "Public",
                    "Resources"
                    ]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
