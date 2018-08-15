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
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.8"),
        
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.1"),
        
        // 🖋🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        
        // ✅ Extensible data validation library (name, email, etc)
        .package(url: "https://github.com/vapor/validation.git", from: "2.1.0")
    ],
    targets: [
        .target(name: "App",
                dependencies: [
                    "Vapor",
                    "Leaf",
                    "FluentPostgreSQL",
                    "Validation"
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
