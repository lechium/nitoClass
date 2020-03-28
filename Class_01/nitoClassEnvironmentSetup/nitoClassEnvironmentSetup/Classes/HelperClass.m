
#import "HelperClass.h"
#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>

@implementation HelperClass

#pragma mark version checking

- (id)init {
    self = [super init];
    if (self){
        _downloads = [XcodeDownloads new];
        _theosPath = [HelperClass singleLineReturnForProcess:@"printenv THEOS"];
    }
    return self;
}

+ (NCSystemVersionType)currentVersion {
    SInt32 major = 0;
    SInt32 minor = 0;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    if ((major == 10 && minor >= 15) || major >= 11) {
        return NCSystemVersionTypeCatalina;
    } else if (major == 10 && minor >= 14) {
        return NCSystemVersionTypeMojave;
    } else if(major == 10 && minor >= 13) {
        return NCSystemVersionTypeHighSierra;
    }
    return NCSystemVersionTypeUnsupported;
}
+ (BOOL)commandLineToolsInstalled {
    return ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/SDKSettings.plist"]);
}

- (void)openIDSignupPage {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://appleid.apple.com/account#!&page=create"]];
}

- (void)openDeveloperAccountSite {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://developer.apple.com/download/more/"]];
}

+ (BOOL)xcodeInstall {
    NSString *returnVals = [self singleLineReturnForProcess:@"/usr/bin/which xcode-select"];
    if (returnVals.length > 0){
        return true;
    }
    return false;
}

- (void)waitForReturnWithMessage:(NSString *)message {

    char c;
    printf("%s", [message UTF8String]);
    c=getchar();
    while(c!='\n'){
        c=getchar();
    }
    NSLog(@"return presssed, continuing...");
}

+ (BOOL)queryUserWithString:(NSString *)query {
    
    NSString *errorString = [NSString stringWithFormat:@"\n%@ [y/n]? ", query];
    char c;
    printf("%s", [errorString UTF8String] );
    c=getchar();
    while(c!='y' && c!='n')
    {
        if (c!='\n'){
            printf("[y/n]");
        }
        c=getchar();
    }
    if (c == 'n')
    {
        return FALSE;
    } else if (c == 'y') {
        return TRUE;
    }
    return FALSE;
    
}

+ (BOOL)shouldContinueWithError:(NSString *)errorMessage {
    
    NSString *errorString = [NSString stringWithFormat:@"\n%@ Are you sure you want to continue? [y/n]?", errorMessage];
    
    char c;
    printf("%s", [errorString UTF8String] );
    c=getchar();
    while(c!='y' && c!='n')
    {
        if (c!='\n'){
            printf("[y/n]");
        }
        c=getchar();
    }
    
    if (c == 'n')
    {
        DLog(@"\nSmart move... exiting\n\n");
        return FALSE;
    } else if (c == 'y') {
        DLog(@"\nDon't say we didn't warn ya!....\n");
    }
    
    return TRUE;
    
}

+ (NSArray *)arrayReturnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments
{
    NSLog(@"%@ %@", taskBinary, [taskArguments componentsJoinedByString:@" "]);
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [[NSPipe alloc] init];
    NSFileHandle *handle = [pipe fileHandleForReading];
    
    [task setLaunchPath:taskBinary];
    [task setArguments:taskArguments];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    
    [task launch];
    
    NSData *outData = nil;
    NSString *temp = nil;
    while((outData = [handle readDataToEndOfFile]) && [outData length])
    {
        temp = [[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
        
    }
    [handle closeFile];
    task = nil;
    
    return [temp componentsSeparatedByString:@"\n"];
    
}

+ (NSString *)singleLineReturnForProcess:(NSString *)call
{
    return [[self returnForProcess:call] componentsJoinedByString:@"\n"];
}

+ (NSArray *)returnForProcess:(NSString *)call
{
    if (call==nil)
    return 0;
    char line[200];
    //DLog(@"\nRunning process: %@\n", call);
    FILE* fp = popen([call UTF8String], "r");
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    if (fp)
    {
        while (fgets(line, sizeof line, fp))
        {
            NSString *s = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
            s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [lines addObject:s];
        }
    }
    pclose(fp);
    return lines;
}

+ (InputPackageFile *)packageFileFromLine:(NSString *)inputLine {
    //    "-rwxr-xr-x  0 root   wheel   69424 Oct 22 03:56 ./Library/MobileSubstrate/DynamicLibraries/beigelist7.dylib\n",
    
    //-rwxr-xr-x root/staff    10860 2011-02-02 03:55 ./Library/Frameworks/CydiaSubstrate.framework/Commands/cycc
    
    inputLine = [inputLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    inputLine = [inputLine stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t"]];
    NSMutableString *newString = [[NSMutableString alloc] initWithString:inputLine];
    [newString replaceOccurrencesOfString:@"      " withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@"     " withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@"    " withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@"   " withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@"  " withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    
    NSArray *lineObjects = [newString componentsSeparatedByString:@" "];
    
    //NSLog(@"lineObjects: %@", lineObjects);
    
    
    /*
     
     "drwxr-xr-x",
     "root/wheel",
     0,
     "2018-06-27",
     "01:21",
     "./"
     */
    
    
    NSString *permissionsAndType = [lineObjects objectAtIndex:0];
    NSString *userGroup = [lineObjects objectAtIndex:1];
    NSString *size = [lineObjects objectAtIndex:2];
    NSString *date = [lineObjects objectAtIndex:3];
    NSString *time = [lineObjects objectAtIndex:4];
    NSString *path = [lineObjects objectAtIndex:5];
    
    //@"drwxr-xr-x"
    NSString *fileTypeChar = [permissionsAndType substringWithRange:NSMakeRange(0, 1)];
    
    NSString *octalPermissions = [self octalFromSymbols:permissionsAndType];
    NSString *octalUG = [self octalFromGroupSymbols:userGroup];
    NSString *fileName = [path lastPathComponent];
    NSString *fullPath = [path substringFromIndex:0];
    //NSString *fullPath = [NSString stringWithFormat:@"/%@", path];
    if (path.length > 1){
        if ([[path substringToIndex:1] isEqualToString:@"./"]){
            fullPath = [path substringFromIndex:1];
        }
    }
    
    //NSString *fullPath = [path substringFromIndex:1];
    //NSString *fullPath = [path substringFromIndex:0];
    NSLog(@"fullPath: %@", fullPath);
    InputPackageFile *pf = [InputPackageFile new];
    [pf _setFileTypeFromRaw:fileTypeChar];
    
    switch (pf.type) {
        case BSPackageFileTypeLink:
        {
            
            fullPath = [lineObjects objectAtIndex:7];
            NSString *linkDest = [NSString stringWithFormat:@"/%@", path];
            pf.permissions = octalPermissions;
            pf.owner = octalUG;
            pf.size = size;
            pf.time = time;
            pf.date = date;
            pf.path = fullPath;
            pf.basename = fileName;
            pf.linkDestination = linkDest;
            
            return pf;
        }
            break;
            
        case BSPackageFileTypeDirectory: //return for now
            
            //DLog(@"we dont want directory entries do we %@", lineObjects);
            pf.permissions = octalPermissions;
            pf.owner = octalUG;
            pf.size = size;
            pf.time = time;
            pf.date = date;
            pf.path = fullPath;
            pf.basename = fileName;
            return pf;
            break;
            
        default:
            break;
    }
    
    
    pf.permissions = octalPermissions;
    pf.owner = octalUG;
    pf.size = size;
    pf.time = time;
    pf.date = date;
    pf.path = fullPath;
    pf.basename = fileName;
    return pf;
    // return [NSDictionary dictionaryWithObjectsAndKeys:fileType, @"fileType",octalPermissions, @"octalPermissions", octalUG, @"octalUG", size, @"size", date, @"date", time, @"time", fileName, @"fileName", fullPath, @"fullPath",  nil];
    
}


+ (NSString *)octalFromGroupSymbols:(NSString *)theSymbols
{
    NSArray *groupArray = [theSymbols componentsSeparatedByString:@"/"];
    NSString *user = [groupArray objectAtIndex:0];
    NSString *group = [groupArray objectAtIndex:1];
    
    NSString *octalUser = nil;
    NSString *octalGroup = nil;
    //uid=0(root) gid=0(wheel) groups=0(wheel),1(daemon),2(kmem),3(sys),4(tty),5(operator),8(procview),9(procmod),20(staff),29(certusers),80(admin)
    if ([user isEqualToString:@"root"])
    {
        octalUser = @"0";
    } else if ([user isEqualToString:@"mobile"])
    {
        octalUser = @"501";
    }
    //obviously more cases!! FIXME:
    
    if ([group isEqualToString:@"staff"])
    {
        octalGroup = @"20";
    } else if ([group isEqualToString:@"admin"])
    {
        octalGroup = @"80";
    } else if ([group isEqualToString:@"wheel"])
    {
        octalGroup = @"0";
    } else if ([group isEqualToString:@"daemon"])
    {
        octalGroup = @"1";
    } else if ([group isEqualToString:@"kmem"])
    {
        octalGroup = @"2";
    } else if ([group isEqualToString:@"sys"])
    {
        octalGroup = @"3";
    } else if ([group isEqualToString:@"tty"])
    {
        octalGroup = @"4";
    } else if ([group isEqualToString:@"operator"])
    {
        octalGroup = @"5";
    } else if ([group isEqualToString:@"procview"])
    {
        octalGroup = @"8";
    } else if ([group isEqualToString:@"procmod"])
    {
        octalGroup = @"9";
    } else if ([group isEqualToString:@"certusers"])
    {
        octalGroup = @"29";
    } else
    {
        octalGroup = @"501"; //default to mobile
    }
    //uid=0(root) gid=0(wheel) groups=0(wheel),1(daemon),2(kmem),3(sys),4(tty),5(operator),8(procview),9(procmod),20(staff),29(certusers),80(admin)
    return [NSString stringWithFormat:@"%@:%@", octalUser, octalGroup];
    
}


+ (InputPackage *)packageForDeb:(NSString *)debFile {
    
    NSString *packageName = [self singleLineReturnForProcess:[NSString stringWithFormat:@"/usr/local/bin/dpkg -f %@ Package", debFile]];
    NSString *packageVersion = [self singleLineReturnForProcess:[NSString stringWithFormat:@"/usr/local/bin/dpkg -f %@ Version", debFile]];
    NSArray <InputPackageFile *> *fileList = [self returnForProcess:[NSString stringWithFormat:@"/usr/local/bin/dpkg -c %@", debFile]];
    
    __block NSMutableArray *finalArray = [NSMutableArray new];
    
    [fileList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        InputPackageFile *file = [self packageFileFromLine:obj];
        if (file) {
            //DLog(@"%@", file);
            [finalArray addObject:file];
        }
        
    }];
    
    InputPackage *pkg = [InputPackage new];
    pkg.files = finalArray;
    pkg.path = debFile;
    pkg.packageName = packageName;
    pkg.version = packageVersion;
    return pkg;
    
}

+ (NSString *)octalFromSymbols:(NSString *)theSymbols
{
    //NSLog(@"%@ %s", self, _cmd);
    NSString *U = [theSymbols substringWithRange:NSMakeRange(1, 3)];
    NSString *G = [theSymbols substringWithRange:NSMakeRange(4, 3)];
    NSString *O = [theSymbols substringWithRange:NSMakeRange(7, 3)];
    //NSLog(@"fileTypeChar: %@", fileTypeChar);
    //NSLog(@"U; %@", U);
    //NSLog(@"G; %@", G);
    //NSLog(@"O; %@", O);
    
    //USER
    
    int sIdBit = 0;
    
    int uOctal = 0;
    
    const char *uArray = [U cStringUsingEncoding:NSASCIIStringEncoding];
    NSUInteger stringLength = [U length];
    
    int x;
    for( x=0; x<stringLength; x++ )
    {
        unsigned int aCharacter = uArray[x];
        if (aCharacter == 'r')
        {
            uOctal += 4;
        } else     if (aCharacter == 'w')
        {
            uOctal += 2;
        } else     if (aCharacter == 'x')
        {
            uOctal += 1;
        } else     if (aCharacter == 's')
        {
            sIdBit += 4;
        }
    }
    
    //GROUP
    
    int gOctal = 0;
    const char *gArray = [G cStringUsingEncoding:NSASCIIStringEncoding];
    stringLength = [G length];
    
    int y;
    for( y=0; y<stringLength; y++ )
    {
        unsigned int aCharacter = gArray[y];
        if (aCharacter == 'r')
        {
            gOctal += 4;
        } else     if (aCharacter == 'w')
        {
            gOctal += 2;
        } else     if (aCharacter == 'x')
        {
            gOctal += 1;
        } else     if (aCharacter == 's')
        {
            gOctal += 2;
        }
    }
    
    //OTHERS
    int z;
    int oOctal = 0;
    const char *oArray = [O cStringUsingEncoding:NSASCIIStringEncoding];
    stringLength = [O length];
    
    
    for( z=0; z<stringLength; z++ )
    {
        unsigned int aCharacter = oArray[z];
        if (aCharacter == 'r')
        {
            oOctal += 4;
        } else     if (aCharacter == 'w')
        {
            oOctal += 2;
        } else     if (aCharacter == 'x')
        {
            oOctal += 1;
        }
    }
    
    
    return [NSString stringWithFormat:@"%i%i%i%i", sIdBit, uOctal, gOctal, oOctal];
    
}

@end
