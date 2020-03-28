
#import "InputPackageFile.h"

@implementation InputPackageFile

- (void)_setFileTypeFromRaw:(NSString *)rawType {
    
    _fileType = [InputPackageFile readableFileTypeForRawMode:rawType];
    _type = [InputPackageFile fileTypeForRawMode:rawType];
    
    
}

/*
 - denotes a regular file
 d denotes a directory
 b denotes a block special file
 c denotes a character special file
 l denotes a symbolic link
 p denotes a named pipe
 s denotes a domain socket
 */

+ (NSString* )readableFileTypeForRawMode:(NSString *)fileTypeChar {
    
    NSString *fileType = nil;
    
    if ([fileTypeChar isEqualToString:@"-"])
    { fileType = @"file"; }
    else if ([fileTypeChar isEqualToString:@"d"])
    { fileType = @"directory"; }
    else if ([fileTypeChar isEqualToString:@"b"])
    { fileType = @"block"; }
    else if ([fileTypeChar isEqualToString:@"c"])
    { fileType = @"character"; }
    else if ([fileTypeChar isEqualToString:@"l"])
    { fileType = @"link"; }
    else if ([fileTypeChar isEqualToString:@"p"])
    { fileType = @"pipe"; }
    else if ([fileTypeChar isEqualToString:@"s"])
    { fileType = @"socket"; }
    
    return fileType;
    
}

+ (BSPackageFileType)fileTypeForRawMode:(NSString *)fileTypeChar {
    
    BSPackageFileType type = BSPackageFileTypeUnknown;
    
    if ([fileTypeChar isEqualToString:@"-"])
    { type = BSPackageFileTypeFile; }
    else if ([fileTypeChar isEqualToString:@"d"])
    { type = BSPackageFileTypeDirectory; }
    else if ([fileTypeChar isEqualToString:@"b"])
    { type = BSPackageFileTypeBlock; }
    else if ([fileTypeChar isEqualToString:@"c"])
    { type = BSPackageFileTypeCharacter; }
    else if ([fileTypeChar isEqualToString:@"l"])
    { type = BSPackageFileTypeLink; }
    else if ([fileTypeChar isEqualToString:@"p"])
    { type = BSPackageFileTypePipe; }
    else if ([fileTypeChar isEqualToString:@"s"])
    { type = BSPackageFileTypeSocket; }
    
    return type;
    
}

- (NSString*) description {
    
    NSString *orig = [super description];
    NSMutableDictionary *details = [NSMutableDictionary new];
    NSArray *props = [self properties];
    [props enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *cv = [self valueForKey:obj];
        if (cv){
            details[obj] = cv;
        }
        
    }];
    return [NSString stringWithFormat:@"%@ = %@", orig, details];
    
}

@end
