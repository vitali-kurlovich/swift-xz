// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-xz",
    products: [
        .library(
            name: "XzCompression",
            targets: ["XzCompression"]
        ),
    ],
    targets: [
        .systemLibrary(
            name: "liblzma",
            pkgConfig: "liblzma",
            providers: [
                .brew(["xz"]),
                .apt(["liblzma-dev"]),
            ]
        ),
        .target(name: "clzma",
                dependencies: [
                    .target(name: "liblzma"),
                ]),
        .target(
            name: "XzCompression",
            dependencies: [
                .target(name: "clzma"),
            ]
        ),
        .testTarget(
            name: "XzCompressionTests",
            dependencies: ["XzCompression"]
        ),
    ],

    swiftLanguageModes: [.v6]
)
