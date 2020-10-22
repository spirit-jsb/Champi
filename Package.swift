// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "Champi",
  platforms: [
    .iOS(.v10)
  ],
  products: [
    .library(name: "Champi", targets: ["Champi"]),
  ],
  targets: [
    .target(name: "Champi", path: "Sources"),
  ],
  swiftLanguageVersions: [
    .v5
  ]
)
