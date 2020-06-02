#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define GF_DEFAULT_PRECISION 10
#define GF_MAX_PRECISION 22

@interface GeoHash : NSObject

@property (nonatomic, strong, readonly, nonnull) NSString *geoHashValue;

- (nonnull id)initWithLocation:(CLLocationCoordinate2D)location;
- (nonnull id)initWithLocation:(CLLocationCoordinate2D)location precision:(NSUInteger)precision;
- (nonnull id)initWithString:(nonnull NSString *)string;

+ (BOOL)isValidGeoHash:(nonnull NSString *)hash;

@end
