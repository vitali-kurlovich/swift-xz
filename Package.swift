// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let targets: [Target]

#if os(anyAppleOS)

    targets = [
        .target(
            name: "Lzma",
            dependencies: [
            ],
        ),

        .testTarget(
            name: "LzmaTests",
            dependencies: ["Lzma"],
        ),
    ]

#elseif os(Linux)

    targets = [
        .systemLibrary(
            name: "liblzma",
            pkgConfig: "liblzma",
            providers: [
                .apt(["liblzma-dev"]),
            ],
        ),

        .target(name: "clzma",
                dependencies: [
                    .target(name: "liblzma"),
                ]),

        .target(
            name: "Lzma",
            dependencies: [
                .target(name: "clzma"),
            ],
        ),

        .testTarget(
            name: "LzmaTests",
            dependencies: ["Lzma"],
        ),
    ]
#endif

let package = Package(
    name: "swift-xz",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .watchOS(.v9),
        .tvOS(.v15),
    ],
    products: [
        .library(
            name: "Lzma",
            targets: ["Lzma"],
        ),
    ],
    targets: targets,

    swiftLanguageModes: [.v6],
)
