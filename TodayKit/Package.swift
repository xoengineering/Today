// swift-tools-version: 6.4

import PackageDescription

let package = Package(
  name: "TodayKit",
  platforms: [
    .iOS(.v27),
    .macOS(.v27),
  ],
  products: [
    .library(
      name: "TodayKit",
      targets: ["TodayKit"]
    )
  ],
  targets: [
    .target(
      name: "TodayKit"
    ),
    .testTarget(
      name: "TodayKitTests",
      dependencies: ["TodayKit"],
      resources: [
        .copy("Fixtures")
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
