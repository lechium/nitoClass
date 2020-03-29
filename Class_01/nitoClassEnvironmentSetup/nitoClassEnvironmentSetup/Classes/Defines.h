
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

#define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#define FM [NSFileManager defaultManager]
