

#import "NSString+Additions.h"
#import "NSData+Flip.h"
#import "NSData+CommonCrypto.h"

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

- (NSString *)permissionsOctalRepresentation {
    if (self.length < 10) return nil;
    NSString *U = [self substringWithRange:NSMakeRange(1, 3)];
    NSString *G = [self substringWithRange:NSMakeRange(4, 3)];
    NSString *O = [self substringWithRange:NSMakeRange(7, 3)];
    
    //USER
    int sIdBit = 0;
    int uOctal = 0;
    const char *uArray = [U cStringUsingEncoding:NSASCIIStringEncoding];
    NSUInteger stringLength = [U length];
    
    int x;
    for( x=0; x<stringLength; x++ ) {
        unsigned int aCharacter = uArray[x];
        if (aCharacter == 'r') {
            uOctal += 4;
        } else if (aCharacter == 'w') {
            uOctal += 2;
        } else if (aCharacter == 'x') {
            uOctal += 1;
        } else if (aCharacter == 's') {
            sIdBit += 4;
        }
    }
    
    //GROUP
    int gOctal = 0;
    const char *gArray = [G cStringUsingEncoding:NSASCIIStringEncoding];
    stringLength = [G length];
    int y;
    for( y=0; y<stringLength; y++ ) {
        unsigned int aCharacter = gArray[y];
        if (aCharacter == 'r') {
            gOctal += 4;
        } else if (aCharacter == 'w') {
            gOctal += 2;
        } else if (aCharacter == 'x') {
            gOctal += 1;
        } else if (aCharacter == 's') {
            gOctal += 2;
        }
    }
    
    //OTHERS
    int z;
    int oOctal = 0;
    const char *oArray = [O cStringUsingEncoding:NSASCIIStringEncoding];
    stringLength = [O length];
    for( z=0; z<stringLength; z++ ) {
        unsigned int aCharacter = oArray[z];
        if (aCharacter == 'r') {
            oOctal += 4;
        } else if (aCharacter == 'w') {
            oOctal += 2;
        } else if (aCharacter == 'x') {
            oOctal += 1;
        }
    }
    return [NSString stringWithFormat:@"%i%i%i%i", sIdBit, uOctal, gOctal, oOctal];
}

- (NSString *)groupOctalWithDelimiter:(NSString *)delim {
    NSArray *groupArray = [self componentsSeparatedByString:delim];
    NSString *user = [groupArray objectAtIndex:0];
    NSString *group = [groupArray objectAtIndex:1];
    
    NSString *octalUser = nil;
    NSString *octalGroup = nil;
    //uid=0(root) gid=0(wheel) groups=0(wheel),1(daemon),2(kmem),3(sys),4(tty),5(operator),8(procview),9(procmod),20(staff),29(certusers),80(admin)
    if ([user isEqualToString:@"root"]) {
        octalUser = @"0";
    } else if ([user isEqualToString:@"mobile"]) {
        octalUser = @"501";
    }
    //obviously more cases!! FIXME:
    
    if ([group isEqualToString:@"staff"]) {
        octalGroup = @"20";
    } else if ([group isEqualToString:@"admin"]) {
        octalGroup = @"80";
    } else if ([group isEqualToString:@"wheel"]) {
        octalGroup = @"0";
    } else if ([group isEqualToString:@"daemon"]) {
        octalGroup = @"1";
    } else if ([group isEqualToString:@"kmem"]) {
        octalGroup = @"2";
    } else if ([group isEqualToString:@"sys"]) {
        octalGroup = @"3";
    } else if ([group isEqualToString:@"tty"]) {
        octalGroup = @"4";
    } else if ([group isEqualToString:@"operator"]) {
        octalGroup = @"5";
    } else if ([group isEqualToString:@"procview"]) {
        octalGroup = @"8";
    } else if ([group isEqualToString:@"procmod"]) {
        octalGroup = @"9";
    } else if ([group isEqualToString:@"certusers"]) {
        octalGroup = @"29";
    } else {
        octalGroup = @"501"; //default to mobile
    }
    //uid=0(root) gid=0(wheel) groups=0(wheel),1(daemon),2(kmem),3(sys),4(tty),5(operator),8(procview),9(procmod),20(staff),29(certusers),80(admin)
    return [NSString stringWithFormat:@"%@:%@", octalUser, octalGroup];
}

- (BOOL)validateFileSHA:(NSString *)sha {
    if ([FM fileExistsAtPath:self]){
        NSData *data = [NSData dataWithContentsOfFile:self];
        NSString *ourSHA = [[data SHA1Hash] stringFromHexData];
        return [ourSHA isEqualToString:sha];
    }
    return FALSE;
}

- (NSString *)TIMEFormat {
    
    NSInteger secondsLeft = [self integerValue];
    NSInteger _hours = (NSInteger)secondsLeft / 3600;
    NSInteger _minutes = (NSInteger)secondsLeft / 60 % 60;
    NSInteger _seconds = (NSInteger)secondsLeft % 60;
    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)_hours, (long)_minutes, (long)_seconds];
}

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

- (NSString *)plistSafeString
{
    NSUInteger startingLocation = [self rangeOfString:@"<?xml"].location;
    
    //find NSRange of the end of the plist (there is "junk" cert data after our plist info as well
    NSRange endingRange = [self rangeOfString:@"</plist>"];
    
    //adjust the location of endingRange to include </plist> into our newly trimmed string.
    NSUInteger endingLocation = endingRange.location + endingRange.length;
    
    //offset the ending location to trim out the "garbage" before <?xml
    NSUInteger endingLocationAdjusted = endingLocation - startingLocation;
    
    //create the final range of the string data from <?xml to </plist>
    
    NSRange plistRange = NSMakeRange(startingLocation, endingLocationAdjusted);
    
    //actually create our string!
    return [self substringWithRange:plistRange];
}



- (id)dictionaryRepresentation {
    NSString *error = nil;
    NSPropertyListFormat format;
    NSData *theData = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    id theDict = [NSPropertyListSerialization propertyListFromData:theData
                                                  mutabilityOption:NSPropertyListImmutable
                                                            format:&format
                                                  errorDescription:&error];
    return theDict;
}

@end
