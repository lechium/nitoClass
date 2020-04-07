
#import "HelperClass.h"
#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>
#include <sys/stat.h>
#import "NSObject+Additions.h"
#include <sys/stat.h>
@import Darwin.POSIX.dirent;

@implementation HelperClass

#pragma mark version checking

- (id)init {
    self = [super init];
    if (self){
        _downloads = [XcodeDownloads new];
        _theosPath = [[HelperClass theosPath] stringByExpandingTildeInPath];
        NLog(@"theosPath: %@", _theosPath);
        _username = [HelperClass singleLineReturnForProcess:@"whoami"];
        _dpkgPath = [HelperClass singleLineReturnForProcess:@"which dpkg-deb"];
    }
    return self;
}

+ (NSString *)theosPath {
    
    NSString *alias = [HelperClass aliasPath];
    NSString *envRun = [NSString stringWithFormat:@"cat %@ | grep -m 1 THEOS= | cut -d \"=\" -f 2", alias];
    return [HelperClass singleLineReturnForProcess:envRun];
}


+ (NSString *)freeSpaceString {
    float space = [self freeSpaceAvailable];
    return [[NSString stringWithFormat:@"%f", space] suffixNumber];
}

+ (float)freeSpaceAvailable {
    float available = [[[FM attributesOfFileSystemForPath:@"/" error:nil] objectForKey:NSFileSystemFreeSize] floatValue];
    float avail2 = available / 1024;
    return avail2;
}

+ (BOOL)belowFreeSpaceThreshold {
    float avail2 = [self freeSpaceAvailable];
    DLog(@"avail: %f", avail2);
    return (avail2 < 60);
}

+ (NSString *)defaultShell {
    return [HelperClass singleLineReturnForProcess:@"printenv SHELL"];
}

+ (NSString *)aliasPath {
    NSString *shell = [self defaultShell];
    NLog(@"defaultShell: %@", shell);
    NSString *aliasFile = nil;
    if ([shell containsString:@"bash"]){
        aliasFile = [NSHomeDirectory() stringByAppendingPathComponent:@".bash_profile"];
    } else if ([shell containsString:@"zsh"]){
        aliasFile = [NSHomeDirectory() stringByAppendingPathComponent:@".config/aliasrc"];
        if (![FM fileExistsAtPath:aliasFile]){
            aliasFile = [NSHomeDirectory() stringByAppendingPathComponent:@".zshrc"];
        }
    }
    return aliasFile;
}

+ (long long) folderSizeAtPath: (const char*)folderPath {
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR
            && child->d_name[0] == '.'
            && (child->d_name[1] == 0 // ignore .
                ||
                (child->d_name[1] == '.' && child->d_name[2] == 0) // ignore dir ..
                ))
            continue;
        
        size_t folderPathLength = strlen(folderPath);
        char childPath[1024]; // child
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self folderSizeAtPath:childPath]; //
            // add folder size
            struct stat st;
            if (lstat(childPath, &st) == 0)
                folderSize += st.st_size;
        } else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if (lstat(childPath, &st) == 0)
                folderSize += st.st_size;
        }
    }
    return folderSize;
}

- (void)upgradeTextProgress:(NSString *)progress indeterminate:(BOOL)ind percent:(double)percentComplete {
    if (self.BasicProgressBlock){
        self.BasicProgressBlock(progress, ind, percentComplete);
    }
}
///Users/js/Library/Caches/com.apple.nsurlsessiond/Downloads
+ (NSString *)cacheFolder {
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [libraryPaths firstObject];
}

+ (long long)sessionCacheSize {
    return [self folderSizeAtPath:[[self sessionCache] UTF8String]];
}

+ (NSString *)sessionCache {
    return [[self cacheFolder] stringByAppendingPathComponent:@"com.apple.nsurlsessiond/Downloads"];
}

//base theos + our SDKs requires about 170 MB
- (void)checkoutTheosIfNecessary:(void(^)(BOOL success))block {
    BOOL theosNeeded = true;
    if ([FM fileExistsAtPath:_theosPath]){
        theosNeeded = false;
        NLog(@"theos detected! checking for tvOS SDK's\n");
        NSString *path = [_theosPath stringByAppendingPathComponent:@"sdks/AppleTVOS12.4.sdk"];
        if ([FM fileExistsAtPath:path]){
            NLog(@"AppleTV SDK's detected, no theos checkout is necessary\n");
            [self upgradeTextProgress:@"" indeterminate:true percent:0];
            if (block){
                block(true);
            }
            return;
        }
        
    }
    
    NSString *sdks = @"https://github.com/lechium/sdks.git";//@"git@github.com:lechium/sdks.git";
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [libraryPaths firstObject];
    NSString *fullCmd = nil;
    if (theosNeeded){
        [self upgradeTextProgress:@"checking out theos master..." indeterminate:true percent:0];
        [self upgradeTextProgress:@"checking out theos master..." indeterminate:true percent:0];
        NSString *theosCheckout = @"https://github.com/theos/theos.git";//@"git@github.com:theos/theos.git";
        fullCmd = [NSString stringWithFormat:@"/usr/bin/git clone --recursive %@", theosCheckout];
        [HelperClass runTask:fullCmd inFolder:libraryPath];
    }
    NSString *aliasFile = [HelperClass aliasPath];
    NSString *contents = [NSString stringWithContentsOfFile:aliasFile encoding:NSUTF8StringEncoding error:nil];
    if (aliasFile.length > 0 && ![contents containsString:@"export THEOS="]){
        fullCmd = [NSString stringWithFormat:@"echo \"export THEOS=%@/theos\" >> %@", libraryPath, aliasFile];
        [HelperClass singleLineReturnForProcess:fullCmd];
        fullCmd = [NSString stringWithFormat:@"echo \"export PATH=$PATH:$THEOS/bin\" >> %@", aliasFile];
        [HelperClass singleLineReturnForProcess:fullCmd];
    }
    //reuse fullCmd - waste not want not!
    
    [self upgradeTextProgress:@"checking out tvOS theos sdks..." indeterminate:true percent:0];
    fullCmd = [NSString stringWithFormat:@"/usr/bin/git clone %@", sdks];
    NSString *_tempPath = [libraryPath stringByAppendingPathComponent:@"theos/sdk"];
    NSString *_targetPath = [libraryPath stringByAppendingPathComponent:@"theos/sdks/"];
    [HelperClass runTask:fullCmd inFolder:_tempPath];
    fullCmd = [NSString stringWithFormat:@"/bin/mv %@/* %@", [_tempPath stringByAppendingPathComponent:@"sdks"], _targetPath];
    [self upgradeTextProgress:@"moving tvOS theos sdks..." indeterminate:true percent:0];
    [HelperClass singleLineReturnForProcess:fullCmd];
    
    //checkout templates
    [self upgradeTextProgress:@"checking out tvOS templates..." indeterminate:true percent:0];
    NSString *templates = @"https://github.com/lechium/tvOS-templates.git";
    fullCmd = [NSString stringWithFormat:@"/usr/bin/git clone %@", templates];
    _tempPath = [libraryPath stringByAppendingPathComponent:@"theos/template"];
    _targetPath = [libraryPath stringByAppendingPathComponent:@"theos/templates/"];
    [HelperClass runTask:fullCmd inFolder:_tempPath];
    fullCmd = [NSString stringWithFormat:@"/bin/mv %@/* %@", _tempPath, _targetPath];
    [self upgradeTextProgress:@"moving tvOS templates..." indeterminate:true percent:0];
    [HelperClass singleLineReturnForProcess:fullCmd];
    if (block){
        block(true);
    }
}

//post brew install: ldid, dpkg, other issues SDKs v make files. also some linking issues with my sdks

+ (BOOL)brewInstalled {
    return ([FM fileExistsAtPath:@"/usr/local/bin/brew"]);
}

+ (NSString *)mountImage:(NSString *)irString {
    NSTask *irTask = [[NSTask alloc] init];
    NSPipe *hdip = [[NSPipe alloc] init];
    NSFileHandle *hdih = [hdip fileHandleForReading];
    NSMutableArray *irArgs = [[NSMutableArray alloc] init];
    [irArgs addObject:@"attach"];
    [irArgs addObject:@"-plist"];
    
    [irArgs addObject:irString];
    
    [irArgs addObject:@"-owners"];
    [irArgs addObject:@"off"];
    
    [irTask setLaunchPath:@"/usr/bin/hdiutil"];
    
    [irTask setArguments:irArgs];
    
    
    [irTask setStandardError:hdip];
    [irTask setStandardOutput:hdip];
    //NLog(@"hdiutil %@", [[irTask arguments] componentsJoinedByString:@" "]);
    [irTask launch];
    [irTask waitUntilExit];
    
    NSData *outData = nil;
    outData = [hdih readDataToEndOfFile];
    NSDictionary *plist = [outData safeDictionaryRepresentation];
    //NLog(@"plist: %@", plist);
    NSArray *plistArray = [plist objectForKey:@"system-entities"];
    //int theItem = ([plistArray count] - 1);
    int i = 0;
    NSString *mountPath = nil;
    for (i = 0; i < [plistArray count]; i++) {
        NSDictionary *mountDict = [plistArray objectAtIndex:i];
        mountPath = [mountDict objectForKey:@"mount-point"];
        if (mountPath != nil)
        {
            //NLog(@"Mount Point: %@", mountPath);
            int rValue = [irTask terminationStatus];
            if (rValue == 0)
            {
                irTask = nil;
                hdip = nil;
                return mountPath;
            }
        }
    }
    irTask = nil;
    hdip = nil;
    return nil;
}

- (NSString *)processDownload:(NSString *)download {
    
    NSString *fileExt = [[download pathExtension] lowercaseString];
    if ([fileExt isEqualToString:@"dmg"]){
        return [HelperClass mountImage:download];
    } else if ([fileExt isEqualToString:@"xip"]){
        [self upgradeTextProgress:[NSString stringWithFormat:@"Extacting file %@", download.lastPathComponent] indeterminate:true percent:0];
        NSInteger bro = [HelperClass runTask:[NSString stringWithFormat:@"/usr/bin/xip -x %@", download] inFolder:NSHomeDirectory()];
        if (bro == 0){
            [FM removeItemAtPath:download error:nil];
            NSString *outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Xcode.app"];
            [self upgradeTextProgress:[NSString stringWithFormat:@"Extacting finished to %@", outputPath] indeterminate:true percent:0];
            return outputPath;
            
        } else {
            return [NSString stringWithFormat:@"returned with status %lu", bro];
        }
    }
    return nil;
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

+ (void)openIDSignupPage {
    [[NSWorkspace sharedWorkspace] openURL:self.appleIDPage];
}

+ (NSURL *)appleIDPage {
    return [NSURL URLWithString:@"https://appleid.apple.com/account#!&page=create"];
}
+ (NSURL*)developerAccountSite {
    return [NSURL URLWithString:@"https://developer.apple.com/account"];
    //https://developer.apple.com/account
}

+ (NSURL *)moreDownloadsURL {
    return [NSURL URLWithString:@"https://developer.apple.com/download/more/"];
}


+ (void)openDeveloperAccountSite {
    [[NSWorkspace sharedWorkspace] openURL:self.developerAccountSite];
}
/*
 -f = fail silently
 -s = silent / quiet mode
 -S = error when failing
 -L = location, handles redirects
 
 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
 
 */

- (void)installHomebrewIfNecessary {
    if (![HelperClass brewInstalled]){
        NSString *temp = [HelperClass tempFolder];
        NSString *runCmd = [NSString stringWithFormat:@"curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh -o %@install.sh ; chmod +x %@install.sh", temp, temp];
        //DLog(@"runCmd: %@", runCmd);
        [HelperClass singleLineReturnForProcess:runCmd];
        NSString *runScript = [NSString stringWithFormat:@"/bin/bash %@", [NSTemporaryDirectory() stringByAppendingString:@"install.sh"]];
        //DLog(@"%@", runScript);
        [HelperClass runInteractiveProcess:runScript];
    }
}

+ (NSString *)tempFolder {
    NSString *ourTempFolder = NSTemporaryDirectory();
    //mkdir([ourTempFolder UTF8String], 755);
    if ([FM fileExistsAtPath:ourTempFolder]){
        return ourTempFolder;
    }
    return NSTemporaryDirectory();
}


+ (BOOL)xcodeInstalled {
    NSString *path = [[NSWorkspace sharedWorkspace] fullPathForApplication:@"Xcode.app"];
    NLog(@"xcode path: %@", path);
    if (path.length > 0 && [FM fileExistsAtPath:path]){
        return true;
    }
    return false;
}

- (void)waitForReturnWithMessage:(NSString *)message { //doesnt work properly... might prune.
    
    char c;
    printf("%s", [message UTF8String]);
    c=getchar();
    while(c!='\n'){
        c=getchar();
    }
    NLog(@"return presssed, continuing...");
}

+ (BOOL)queryUserWithString:(NSString *)query {
    
    NSString *errorString = [NSString stringWithFormat:@"\n%@ [y/n]? ", query];
    char c;
    printf("%s", [errorString UTF8String] );
    c=getchar();
    while(c!='y' && c!='n') {
        if (c!='\n'){
            printf("[y/n]");
        }
        c=getchar();
    }
    if (c == 'n') {
        return FALSE;
    } else if (c == 'y') {
        return TRUE;
    }
    return FALSE;
}


+ (NSInteger)runTask:(NSString *)fullCommand inFolder:(NSString *)targetFolder {
    
    if (![FM fileExistsAtPath:targetFolder]){
        NLog(@"folder missing: %@", targetFolder);
        [FM createDirectoryAtPath:targetFolder withIntermediateDirectories:true attributes:nil error:nil];
        //return -1;
    }
    NSArray *args = [fullCommand componentsSeparatedByString:@" "];
    NSString *taskBinary = args[0];
    NSArray *taskArguments = [args subarrayWithRange:NSMakeRange(1, args.count-1)];
    NLog(@"%@ %@", taskBinary, [taskArguments componentsJoinedByString:@" "]);
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:taskBinary];
    [task setArguments:taskArguments];
    [task setCurrentDirectoryPath:targetFolder];
    [task launch];
    [task waitUntilExit];
    NSInteger retStatus = [task terminationStatus];
    return retStatus;
}

+ (NSArray *)arrayReturnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments {
    NLog(@"%@ %@", taskBinary, [taskArguments componentsJoinedByString:@" "]);
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
    while((outData = [handle readDataToEndOfFile]) && [outData length]) {
        temp = [[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
    }
    [handle closeFile];
    task = nil;
    return [temp componentsSeparatedByString:@"\n"];
}

+ (NSString *)singleLineReturnForProcess:(NSString *)call {
    return [[self returnForProcess:call] componentsJoinedByString:@"\n"];
}

+ (void)runInteractiveProcess:(NSString *)call {
    if (call==nil)
        return;
    char line[200];
    //DLog(@"\nRunning process: %@\n", call);
    FILE* fp = popen([call UTF8String], "r");
    if (fp) {
        while (fgets(line, sizeof line, fp)){
            NSString *s = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
            s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            DLog(@"%@", s);
        }
    }
    pclose(fp);
}

+ (NSArray *)returnForProcess:(NSString *)call {
    if (call==nil)
        return 0;
    char line[200];
    //DLog(@"\nRunning process: %@\n", call);
    FILE* fp = popen([call UTF8String], "r");
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    if (fp) {
        while (fgets(line, sizeof line, fp)){
            NSString *s = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
            s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [lines addObject:s];
        }
    }
    pclose(fp);
    return lines;
}

+ (NSString *)octalFromGroupSymbols:(NSString *)theSymbols {
    NSArray *groupArray = [theSymbols componentsSeparatedByString:@"/"];
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

+ (NSString *)octalFromSymbols:(NSString *)theSymbols {
    NSString *U = [theSymbols substringWithRange:NSMakeRange(1, 3)];
    NSString *G = [theSymbols substringWithRange:NSMakeRange(4, 3)];
    NSString *O = [theSymbols substringWithRange:NSMakeRange(7, 3)];
    
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

//this is specifically if we need to find an external drive to extract / download some of the files to.

+ (NSArray *)scanForDrives {
    //NLog(@"%@ %s", self, _cmd);
    NSMutableArray *deviceList = [[NSMutableArray alloc] init];
    NSTask *scanTask = [[NSTask alloc] init];
    NSPipe *pipe = [[NSPipe alloc] init];
    NSFileHandle *handle = [pipe fileHandleForReading];
    NSData *outData = nil;
    [scanTask setLaunchPath:@"/usr/sbin/diskutil"];
    [scanTask setStandardOutput:pipe];
    [scanTask setStandardError:pipe];
    [scanTask setArguments:[NSArray arrayWithObjects:@"list", @"-plist", nil]];
    //Variables needed for reading output
    NSString *temp = @"";
    [scanTask launch];
    while((outData = [handle readDataToEndOfFile]) && [outData length]) {
        temp = [[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
    }
    
    NSDictionary *dictReturn = [temp dictionaryRepresentation];
    //DLog(@"dictR: %@", dictReturn);
    NSArray *allDisks = dictReturn[@"AllDisksAndPartitions"];
    for (NSDictionary *device in allDisks) {
        NSString *deviceContent = device[@"Content"];
        NSString *devicePath = [NSString stringWithFormat:@"/dev/%@", device[@"DeviceIdentifier"]];
        NSArray *partitions = device[@"Partitions"];
        for (NSDictionary *partition in partitions) {
            NSString *content = partition[@"Content"];
            NSNumber *byteSize = partition[@"Size"];
            NSInteger mb = byteSize.integerValue / 1000000;
            NSString *sizeLabel = nil;
            NSInteger theSize = byteSize.integerValue / 1000000000;
            BOOL shouldDisplay = true;
            if (theSize > 0) {
                sizeLabel = @"GB";
            } else {
                sizeLabel = @"MB";
                theSize = mb;
            }
            
            NSArray *acceptableTypes = @[@"Apple_HFS", @"APFS"];
            
            if ([acceptableTypes containsObject:content]) {
                NSString *volumeName = partition[@"VolumeName"];
                if (volumeName == nil) volumeName = partition[@"Content"];
                if (shouldDisplay == true) {
                    float avail = [[[FM attributesOfFileSystemForPath:[@"/Volumes" stringByAppendingPathComponent:volumeName] error:nil] objectForKey:NSFileSystemFreeSize] floatValue]/1024/1024/1024;
                    NSString *freeSpace = [NSString stringWithFormat:@"%.2f", avail];
                    NSString *displayName = [NSString stringWithFormat:@"%@ : %li %@", volumeName, (long)theSize, sizeLabel];
                    NSDictionary *volumeInfo = @{@"PartitionScheme": deviceContent, @"VolumeName": volumeName, @"Path": devicePath, @"Size": [NSString stringWithFormat:@"%li %@", (long)theSize, sizeLabel], @"DisplayName": displayName, @"FreeSpace": freeSpace, @"Content": content};
                    [deviceList addObject:volumeInfo];
                }
            }
        }
    }
    scanTask = nil;
    pipe = nil;
    return deviceList;
}

@end
