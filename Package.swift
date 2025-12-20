// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MeshingKit",
  platforms: [
    .iOS(.v18),
    .macOS(.v15),
    .macCatalyst(.v18),
    .tvOS(.v18),
    .watchOS(.v11),
    .visionOS(.v2)
  ],
  products: [
    .library(
      name: "MeshingKit",
      type: .static,
      targets: ["MeshingKit"])
  ],
  targets: [
    .target(
      name: "MeshingKit",
      resources: [
        .process("ParameterizedNoise.metal")
      ]
    ),
    .testTarget(
      name: "MeshingKitTests",
      dependencies: ["MeshingKit"]
    )
  ]
)
