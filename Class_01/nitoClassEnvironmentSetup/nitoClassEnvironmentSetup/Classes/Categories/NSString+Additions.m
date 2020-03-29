

#import "NSString+Additions.h"

@implementation NSNumber (NumberFormatting)

-(NSString*) suffixNumber {
    
    long long num = [self longLongValue];
    int s = ( (num < 0) ? -1 : (num > 0) ? 1 : 0 );
    NSString* sign = (s == -1 ? @"-" : @"" );
    num = llabs(num);
    if (num < 1000)
        return [NSString stringWithFormat:@"%@%lld",sign,num];
    
    int exp = (int) (log10l(num) / 3.f); //log10l(1000));
    NSArray* units = @[@"MB",@"GB",@"TB",@"PB",@"EB",@"YB"];
    return [NSString stringWithFormat:@"%@%.1f%@",sign, (num / pow(1000, exp)), [units objectAtIndex:(exp-1)]];
}

@end

@implementation NSString (Additions)

-(NSString*) suffixNumber {
    
    long long num = [self longLongValue];
    int s = ( (num < 0) ? -1 : (num > 0) ? 1 : 0 );
    NSString* sign = (s == -1 ? @"-" : @"" );
    num = llabs(num);
    if (num < 1000)
        return [NSString stringWithFormat:@"%@%lld",sign,num];
    
    int exp = (int) (log10l(num) / 3.f); //log10l(1000));
    NSArray* units = @[@"MB",@"GB",@"TB",@"PB",@"EB",@"YB"];
    return [NSString stringWithFormat:@"%@%.1f%@",sign, (num / pow(1000, exp)), [units objectAtIndex:(exp-1)]];
}


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
