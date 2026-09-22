// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var targets: [Target] = []

#if os(anyAppleOS)
    targets.append(
        .target(
            name: "Lzma",
            dependencies: [
            ],
        ),
    )

#elseif os(Linux)

    targets.append(
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
    )
#endif

targets.append(
    .testTarget(
        name: "LzmaTests",
        dependencies: ["Lzma"],
    ),
)

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
