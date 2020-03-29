
#import <Foundation/Foundation.h>
#import "NSObject+Additions.h"
#import "NSString+Additions.h"

typedef NS_ENUM(NSInteger, BSPackageFileType)
{
    
    BSPackageFileTypeFile,
    BSPackageFileTypeDirectory,
    BSPackageFileTypeBlock,
    BSPackageFileTypeCharacter,
    BSPackageFileTypeLink,
    BSPackageFileTypePipe,
    BSPackageFileTypeSocket,
    BSPackageFileTypeUnknown
    
};

typedef NS_ENUM(NSInteger, NCSystemVersionType) {
    
    NCSystemVersionTypeUnsupported,
    NCSystemVersionTypeHighSierra,
    NCSystemVersionTypeMojave,
    NCSystemVersionTypeCatalina
};
#import "HelperClass.h"
#define LOG_SELF        NSLog(@"%@ %@", self, NSStringFromSelector(_cmd))
#define DLOG_SELF DLog(@"%@ %@", self, NSStringFromSelector(_cmd))
#define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#define FM [NSFileManager defaultManager]
