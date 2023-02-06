#import "GeoHash.h"

#import "Base32Utils.h"

@interface GeoHash ()

@property (nonatomic, strong, readwrite) NSString *geoHashValue;

@end

@implementation GeoHash

- (id)initWithLocation:(CLLocationCoordinate2D)location
{
	return [self initWithLocation:location precision:GF_DEFAULT_PRECISION];
}

- (id)initWithLocation:(CLLocationCoordinate2D)location precision:(NSUInteger)precision
{
	self = [super init];
	if (self != nil) {
		if (precision < 1) {
			return nil;
		}
		if (precision > GF_MAX_PRECISION) {
			return nil;
		}
		if (!CLLocationCoordinate2DIsValid(location)) {
			return nil;
		}
		
		double longitudeRange[] = { -180 , 180 };
		double latitudeRange[] = { -90 , 90 };
		
		char buffer[precision+1];
		buffer[precision] = 0;
		
		for (NSUInteger i = 0; i < precision; i++) {
			NSUInteger hashVal = 0;
			for (NSUInteger j = 0; j < BITS_PER_BASE32_CHAR; j++) {
				BOOL even = ((i*BITS_PER_BASE32_CHAR)+j) % 2 == 0;
				double val = (even) ? location.longitude : location.latitude;
				double* range = (even) ? longitudeRange : latitudeRange;
				double mid = (range[0] + range[1])/2;
				if (val > mid) {
					hashVal = (hashVal << 1) + 1;
					range[0] = mid;
				} else {
					hashVal = (hashVal << 1) + 0;
					range[1] = mid;
				}
			}
			buffer[i] = [Base32Utils valueToBase32Character:hashVal];
		}
		self->_geoHashValue = [NSString stringWithUTF8String:buffer];
	}
	return self;
}

- (id)initWithString:(NSString *)hashValue
{
	if ([GeoHash isValidGeoHash:hashValue]) {
		return [self initWithCheckedHash:hashValue];
	} else {
		return nil;
	}
}

- (id)initWithCheckedHash:(NSString *)hashValue
{
	self = [super init];
	if (self != nil) {
		self->_geoHashValue = hashValue;
	}
	return self;
}

+ (BOOL)isValidGeoHash:(NSString *)hash
{
	static NSCharacterSet *base32Set;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		base32Set = [NSCharacterSet characterSetWithCharactersInString:[Base32Utils base32Characters]];
	});
	if (hash.length == 0) {
		return NO;
	}
	NSCharacterSet *hashCharSet = [NSCharacterSet characterSetWithCharactersInString:hash];
	if (![base32Set isSupersetOfSet:hashCharSet]) {
		return NO;
	}
	
	return YES;
}

- (BOOL)isEqual:(id)other
{
	if (other == self) {
		return YES;
	}
	if (!other || ![other isKindOfClass:[self class]]) {
		return NO;
	}
	return [self.geoHashValue isEqualToString:[other geoHashValue]];
}

- (NSUInteger)hash
{
	return [self.geoHashValue hash];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"GeoHash: %@", self.geoHashValue];
}

@end
