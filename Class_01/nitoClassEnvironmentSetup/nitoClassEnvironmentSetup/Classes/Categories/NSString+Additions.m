

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (NSString *)nextVersionNumber {
    
    NSArray *comp = [self componentsSeparatedByString:@"-"];
    if (comp.count > 1){
        
        NSString *first = comp[0];
        NSInteger bumpVersion = [[comp lastObject] integerValue]+1;
        
        return [NSString stringWithFormat:@"%@-%lu", first, bumpVersion];
        
    } else {
        return nil;
    }
    return nil;
}

- (void)writeToFileWithoutAttributes:(NSString *)theFile {
    
    if ([FM fileExistsAtPath:theFile]){
        
        DLog(@"overwriting file: %@", theFile);
    }
    FILE *fd = fopen([theFile UTF8String], "w+");
    const char *text = self.UTF8String;
    fwrite(text, strlen(text) + 1, 1, fd);
    fclose(fd);
    
}

@end
