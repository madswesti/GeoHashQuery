#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "GeoHash.h"

@interface GeoHashQuery : NSObject<NSCopying>

@property (nonatomic, strong, readonly, nonnull) NSString * startValue;
@property (nonatomic, strong, readonly, nonnull) NSString * endValue;

+ (nonnull NSSet<GeoHashQuery *> *)queriesForLocation:(CLLocationCoordinate2D)location radius:(double)radius;
+ (nonnull NSSet<GeoHashQuery *> *)queriesForRegion:(MKCoordinateRegion)region;

- (BOOL)containsGeoHash:(nonnull GeoHash *)hash;

@end

@interface GeoHashQuery (Tests)

+ (CLLocationDegrees)wrapLongitude:(CLLocationDegrees)degrees;
+ (CLLocationDegrees)meters:(double)distance toLongitudeDegreesAtLatitude:(CLLocationDegrees)latitude;
+ (NSUInteger)bitsForBoundingBoxAtLocation:(CLLocationCoordinate2D)location withSize:(double)size;
+ (nonnull GeoHashQuery *)geoHashQueryWithGeoHash:(nullable GeoHash *)geohash bits:(NSUInteger)bits;
- (nonnull id)initWithStartValue:(nullable NSString *)startValue endValue:(nullable NSString *)endValue;
- (BOOL)canJoinWith:(nullable GeoHashQuery *)other;
- (nonnull GeoHashQuery *)joinWith:(nullable GeoHashQuery *)other;
@end
