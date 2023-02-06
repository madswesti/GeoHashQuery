// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "GeoHashQuery",
	platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "GeoHashQuery", targets: ["GeoHashQuery"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "GeoHashQuery"),
		.testTarget(name: "GeoHashQueryTests", dependencies: ["GeoHashQuery"]),
    ]
)
