import XCTest
@testable import GeoHashQuery

final class GeoHashTests: XCTestCase {
	
	func testInvalidArguments() {
		XCTAssertNil(GeoHash(location: CLLocationCoordinate2D(latitude: 0, longitude: 0), precision:0))
		XCTAssertNil(GeoHash(location: CLLocationCoordinate2D(latitude: 0, longitude: 0), precision:23))
		XCTAssertNotNil(GeoHash(location: CLLocationCoordinate2D(latitude: 0, longitude: 0), precision:22))
	}
	
	func testHashValues() {
		compare(latitude: 0, longitude: 0, hash: "7zzzzzzzzz")
		compare(latitude: 0, longitude: -180, hash: "2pbpbpbpbp")
		compare(latitude: 0, longitude: 180, hash: "rzzzzzzzzz")
		compare(latitude: -90, longitude: 0, hash: "5bpbpbpbpb")
		compare(latitude: -90, longitude: -180, hash: "0000000000")
		compare(latitude: -90, longitude: 180, hash: "pbpbpbpbpb")
		compare(latitude: 90, longitude: 0, hash: "gzzzzzzzzz")
		compare(latitude: 90, longitude: -180, hash: "bpbpbpbpbp")
		compare(latitude: 90, longitude: 180, hash: "zzzzzzzzzz")
		
		compare(latitude: 37.7853074, longitude: -122.4054274, hash: "9q8yywe56g")
		compare(latitude: 38.98719, longitude: -77.250783, hash: "dqcjf17sy6")
		compare(latitude: 29.3760648, longitude: 47.9818853, hash: "tj4p5gerfz")
		compare(latitude: 78.216667, longitude: 15.55, hash: "umghcygjj7")
		compare(latitude: -54.933333, longitude: -67.616667, hash: "4qpzmren1k")
		compare(latitude: -54, longitude: -67, hash: "4w2kg3s54y")
	}
	
	func testCustomprecision() {
		compare(latitude: -90, longitude: -180, precision: 6, hash: "000000")
		compare(latitude: 90, longitude: 180, precision: 20, hash: "zzzzzzzzzzzzzzzzzzzz")
		compare(latitude: -90, longitude: 180, precision: 1, hash: "p")
		compare(latitude: 90, longitude: -180, precision: 5, hash: "bpbpb")
		compare(latitude: 37.7853074, longitude: -122.4054274, precision: 8, hash: "9q8yywe5")
		compare(latitude: 38.98719, longitude: -77.250783, precision: 18, hash: "dqcjf17sy6cppp8vfn")
		compare(latitude: 29.3760648, longitude: 47.9818853, precision: 12, hash: "tj4p5gerfzqu")
		compare(latitude: 78.216667, longitude: 15.55, precision: 1, hash: "u")
		compare(latitude: -54.933333, longitude: -67.616667, precision: 7, hash: "4qpzmre")
		compare(latitude: -54, longitude: -67, precision: 9, hash: "4w2kg3s54")
	}
	
	private func compare(latitude: Double, longitude: Double, precision: UInt = 10, hash: String) {
		let location = CLLocationCoordinate2D(latitude: latitude,
											  longitude: longitude)
		let geoHash = GeoHash(location: location,
							  precision: precision)
		XCTAssertEqual(geoHash?.geoHashValue, hash)
	}
}
