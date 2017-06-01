import PackageDescription

let package = Package(
    name: "SumDUBot",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/postgresql-provider.git", majorVersion: 2, minor: 0)
    ],
    exclude: [
        "Config",
        "Database",
        "Public",
        "Resources"
    ]
)
