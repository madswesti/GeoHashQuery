#import <Foundation/Foundation.h>

#define BITS_PER_BASE32_CHAR 5

@interface Base32Utils : NSObject

+ (char)valueToBase32Character:(NSUInteger)value;
+ (NSUInteger)base32CharacterToValue:(char)character;

+ (NSString *)base32Characters;

@end
