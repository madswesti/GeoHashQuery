import XCTest
import MapKit

@testable import GeoHashQuery

final class GeoHashQueryTests: XCTestCase {
	
	func testWrapLongitude() {
		let values: [(input: CLLocationDegrees, output: CLLocationDegrees)] = [
			(1, 1),
			(0, 0),
			(180, 180),
			(-180, -180),
			(182, -178),
			(270, -90),
			(360, 0),
			(540, -180),
			(630, -90),
			(720, 0),
			(810, 90),
			(-360, 0),
			(-182, 178),
			(-270, 90),
			(-360, 0),
			(-450, -90),
			(-540, 180),
			(-630, 90),
			(1080, 0),
			(-1080, 0)
		]
		
		values.forEach {
			XCTAssertEqual(GeoHashQuery.wrapLongitude($0.input), $0.output, accuracy: 1e-6)
		}
	}
	
	func testMetersToLongitudeDegrees() {
		let values: [(meters: Double, latitude: CLLocationDegrees, longitude: CLLocationDegrees)] = [
			(1000, 0, 0.008983),
			(111320, 0, 1),
			(107550, 15, 1),
			(96486, 30, 1),
			(78847, 45, 1),
			(55800, 60, 1),
			(28902, 75, 1),
			(0, 90, 0),
			(1000, 90, 360),
			(1000, 89.9999, 360),
			(1000, 89.995, 102.594208)
		]
		
		values.forEach {
			XCTAssertEqual(GeoHashQuery.meters($0.meters, toLongitudeDegreesAtLatitude:$0.latitude), $0.longitude, accuracy: 1e-5)
		}
	}
	
	func testBoundingBoxBits() {
		let values: [(coordinate: CLLocationCoordinate2D, size: Double, meters: UInt) ] = [
			(CLLocationCoordinate2D(latitude: 35, longitude: 0), 1000, 28),
			(CLLocationCoordinate2D(latitude: 35.645, longitude: 0), 1000, 27),
			(CLLocationCoordinate2D(latitude: 36, longitude: 0), 1000, 27),
			(CLLocationCoordinate2D(latitude: 0, longitude: 0), 1000, 28),
			(CLLocationCoordinate2D(latitude: 0, longitude: -180), 1000, 28),
			(CLLocationCoordinate2D(latitude: 0, longitude: 180), 1000, 28),
			(CLLocationCoordinate2D(latitude: 0, longitude: 0), 8000, 22),
			(CLLocationCoordinate2D(latitude: 45, longitude: 0), 1000, 27),
			(CLLocationCoordinate2D(latitude: 75, longitude: 0), 1000, 25),
			(CLLocationCoordinate2D(latitude: 75, longitude: 0), 2000, 23),
			(CLLocationCoordinate2D(latitude: 90, longitude: 0), 100, 1),
			(CLLocationCoordinate2D(latitude: 90, longitude: 0), 200, 1)
		]
		
		values.forEach {
			XCTAssertEqual(GeoHashQuery.bitsForBoundingBox(atLocation: $0.coordinate, withSize: $0.size), $0.meters)
		}
	}
	
	func testInitializers() {
		let values: [(lhs: GeoHashQuery, rhs: GeoHashQuery)] = [
			(GeoHashQuery(geoHash: GeoHash(string: "64m9yn96mx"), bits: 6), GeoHashQuery(startValue: "60", endValue: "6h")),
			(GeoHashQuery(geoHash: GeoHash(string: "64m9yn96mx"), bits: 1), GeoHashQuery(startValue: "0", endValue: "h")),
			(GeoHashQuery(geoHash: GeoHash(string: "64m9yn96mx"), bits: 10), GeoHashQuery(startValue: "64", endValue: "65")),
			(GeoHashQuery(geoHash: GeoHash(string: "6409yn96mx"), bits: 11), GeoHashQuery(startValue: "640", endValue: "64h")),
			(GeoHashQuery(geoHash: GeoHash(string: "64m9yn96mx"), bits: 11), GeoHashQuery(startValue: "64h", endValue: "64~")),
			(GeoHashQuery(geoHash: GeoHash(string: "6"), bits: 10), GeoHashQuery(startValue: "6", endValue: "6~")),
			(GeoHashQuery(geoHash: GeoHash(string: "64z178"), bits: 12), GeoHashQuery(startValue: "64s", endValue: "64~")),
			(GeoHashQuery(geoHash: GeoHash(string: "64z178"), bits: 15), GeoHashQuery(startValue: "64z", endValue: "64~"))
		]
		
		values.forEach {
			XCTAssertEqual($0.lhs, $0.rhs)
		}
	}
	
	func testCanJoin() {
		let joinableQueries: [(lhs: GeoHashQuery, rhs: GeoHashQuery)] = [
			(GeoHashQuery(startValue: "abcd", endValue: "abce"), GeoHashQuery(startValue: "abce", endValue: "abcf")),
			(GeoHashQuery(startValue: "abce", endValue: "abcf"), GeoHashQuery(startValue: "abcd", endValue: "abce")),
			(GeoHashQuery(startValue: "abcd", endValue: "abcf"), GeoHashQuery(startValue: "abcd", endValue: "abce")),
			(GeoHashQuery(startValue: "abcd", endValue: "abcf"), GeoHashQuery(startValue: "abce", endValue: "abcf")),
			(GeoHashQuery(startValue: "abc", endValue: "abd"), GeoHashQuery(startValue: "abce", endValue: "abcf")),
			(GeoHashQuery(startValue: "abce", endValue: "abcf"), GeoHashQuery(startValue: "abc", endValue: "abd")),
			(GeoHashQuery(startValue: "abcd", endValue: "abce~"), GeoHashQuery(startValue: "abc", endValue: "abd")),
			(GeoHashQuery(startValue: "abcd", endValue: "abce~"), GeoHashQuery(startValue: "abce", endValue: "abcf")),
			(GeoHashQuery(startValue: "abcd", endValue: "abcf"), GeoHashQuery(startValue: "abce", endValue: "abcg"))
		]
		
		let nonJoinableQueries: [(lhs: GeoHashQuery, rhs: GeoHashQuery)] = [
			(GeoHashQuery(startValue: "abcd", endValue: "abce"), GeoHashQuery(startValue: "abcg", endValue: "abch")),
			(GeoHashQuery(startValue: "abcd", endValue: "abce"), GeoHashQuery(startValue: "dce", endValue: "dcf")),
			(GeoHashQuery(startValue: "abc", endValue: "abd"), GeoHashQuery(startValue: "dce", endValue: "dcf"))
		]
		
		joinableQueries.forEach {
			XCTAssertTrue($0.lhs.canJoin(with: $0.rhs))
		}
		
		nonJoinableQueries.forEach {
			XCTAssertFalse($0.lhs.canJoin(with: $0.rhs))
		}
	}
	
	func testJoinQueries() {
		let joinableQueries: [(lhs: GeoHashQuery, rhs: GeoHashQuery, result: GeoHashQuery)] = [
			(GeoHashQuery(startValue: "abcd", endValue: "abce"), GeoHashQuery(startValue: "abce", endValue: "abcf"), GeoHashQuery(startValue: "abcd", endValue: "abcf")),
			(GeoHashQuery(startValue: "abce", endValue: "abcf"), GeoHashQuery(startValue: "abcd", endValue: "abce"), GeoHashQuery(startValue: "abcd", endValue: "abcf")),
			(GeoHashQuery(startValue: "abcd", endValue: "abcf"), GeoHashQuery(startValue: "abcd", endValue: "abce"), GeoHashQuery(startValue: "abcd", endValue: "abcf")),
			(GeoHashQuery(startValue: "abcd", endValue: "abcf"), GeoHashQuery(startValue: "abce", endValue: "abcf"), GeoHashQuery(startValue: "abcd", endValue: "abcf")),
			(GeoHashQuery(startValue: "abc", endValue: "abd"), GeoHashQuery(startValue: "abce", endValue: "abcf"), GeoHashQuery(startValue: "abc", endValue: "abd")),
			(GeoHashQuery(startValue: "abce", endValue: "abcf"), GeoHashQuery(startValue: "abc", endValue: "abd"), GeoHashQuery(startValue: "abc", endValue: "abd")),
			(GeoHashQuery(startValue: "abcd", endValue: "abce~"), GeoHashQuery(startValue: "abc", endValue: "abd"), GeoHashQuery(startValue: "abc", endValue: "abd")),
			(GeoHashQuery(startValue: "abcd", endValue: "abce~"), GeoHashQuery(startValue: "abce", endValue: "abcf"), GeoHashQuery(startValue: "abcd", endValue: "abcf")),
			(GeoHashQuery(startValue: "abcd", endValue: "abcf"), GeoHashQuery(startValue: "abce", endValue: "abcg"), GeoHashQuery(startValue: "abcd", endValue: "abcg")),
		]
		
		// TODO: Fix non joinable test
		let _: [(lhs: GeoHashQuery, rhs: GeoHashQuery)] = [
			(GeoHashQuery(startValue: "abcd", endValue: "abce"), GeoHashQuery(startValue: "abcg", endValue: "abch")),
			(GeoHashQuery(startValue: "abcd", endValue: "abce"), GeoHashQuery(startValue: "dce", endValue: "dcf")),
			(GeoHashQuery(startValue: "abc", endValue: "abd"), GeoHashQuery(startValue: "dce", endValue: "dcf"))
		]
		
		joinableQueries.forEach {
			XCTAssertEqual($0.lhs.join(with: $0.rhs), $0.result)
		}
	}
	
	func testPointsInCircleGeoQuery() {
		for _ in 0..<1000 {
			let centerLatitude: CLLocationDegrees = Double.random(in: 0...1) * 160 - 80
			let centerLongitude: CLLocationDegrees = Double.random(in: 0...1) * 360 - 180
			let centerLocation = CLLocation(latitude: centerLatitude, longitude: centerLongitude)
			let radius = max(5, pow(Double.random(in: 0...1), 5) * 100000)
			
			let degreeRadius = GeoHashQuery.meters(radius, toLongitudeDegreesAtLatitude: centerLatitude) * 2
			let queries = GeoHashQuery.queries(forLocation: centerLocation.coordinate, radius: radius)
			
			for _ in 0..<1000 {
				let pointLatitude: CLLocationDegrees = max(-89.9, min(89.9, centerLatitude + Double.random(in: 0...1) * degreeRadius))
				let pointLongitude: CLLocationDegrees = GeoHashQuery.wrapLongitude(centerLongitude + Double.random(in: 0...1) * degreeRadius)
				let pointLocation = CLLocation(latitude: pointLatitude, longitude: pointLongitude)
				
				guard (pointLocation.distance(from: centerLocation) < radius) else { return }
				XCTAssertTrue(queries.contains(location: pointLocation))
			}
		}
	}
	
	func testPointsInRegionGeoQueries() {
		for _ in 0..<1000 {
			let centerLatitude: CLLocationDegrees = Double.random(in: 0...1) * 160 - 80
			let centerLongitude: CLLocationDegrees = Double.random(in: 0...1) * 360 - 180
			let centerLocation = CLLocation(latitude: centerLatitude, longitude: centerLongitude)
			let latitudeDelta = max(0.00001, pow(Double.random(in: 0...1), 5) * (90 - abs(centerLatitude)))
			let longitudeDelta = max(0.00001, pow(Double.random(in: 0...1), 5) * 360);
			let region = MKCoordinateRegion(center: centerLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
			
			let queries = GeoHashQuery.queries(for: region)
			for _ in 0..<1000 {
				let pointLatitude: CLLocationDegrees = max(-89.9, min(89.9, centerLatitude + Double.random(in: 0...1) * latitudeDelta - latitudeDelta/2))
				let pointLongitude: CLLocationDegrees = GeoHashQuery.wrapLongitude(centerLongitude + (Double.random(in: 0...1) * longitudeDelta - longitudeDelta / 2))
				let pointLocation = CLLocation(latitude: pointLatitude, longitude: pointLongitude)
				
				XCTAssertTrue(queries.contains(location: pointLocation))
			}
		}
	}
	
}

extension Set where Element == GeoHashQuery {
	func contains(location: CLLocation) -> Bool {
		guard let geoHash = GeoHash(location: location.coordinate) else { return false }
		return self.first { $0.contains(geoHash) } != nil
	}
}
