
#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (UIColor *)twitterBlue {
    return [UIColor colorFromHex:@"1A97F1"];
}

+ (UIColor *)colorFromHex:(NSString *)s {
    NSScanner *scan = [NSScanner scannerWithString:[s substringToIndex:2]];
    unsigned int r = 0, g = 0, b = 0;
    [scan scanHexInt:&r];
    scan = [NSScanner scannerWithString:[[s substringFromIndex:2] substringToIndex:2]];
    [scan scanHexInt:&g];
    scan = [NSScanner scannerWithString:[s substringFromIndex:4]];
    [scan scanHexInt:&b];
    return [UIColor colorWithRed:(float)r/255 green:(float)g/255 blue:(float)b/255 alpha:1.0];
}

- (NSString *)hexValue {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}


@end
