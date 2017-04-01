import PackageDescription

let package = Package(
    name: "SumDUBot",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),

        // TODO: Turn on when issue with Kanna will be fixed https://github.com/tid-kijyun/Kanna/issues/142
//        .Package(url: "https://github.com/tid-kijyun/Kanna.git", majorVersion: 2),

        .Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/onevcat/Rainbow", majorVersion: 2)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)
