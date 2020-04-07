
#import "HelperClass.h"
#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>
#include <sys/stat.h>
#import "NSObject+Additions.h"
#include <sys/stat.h>
@import Darwin.POSIX.dirent;

/**
 
 NOTE: This class is definitely a 'ball of mud' anti-pattern, or one could reasonably defend the claim to it being one.
 
 That being said, its not here a demonstration of how you should organize your code,
 it's a quick and dirty implementation to get this process moving in a timely fashion.
 
 Overview:
 
 This is a multi purpose "helper" class that tracks / discerns important file locations, installation status of packages
 convenience tasks for task operations (NSTask or popen) and will also track the XcodeDownload(s) classes
 based on which OS you are currently running, and what components you already have installed.
 
 I've tried to reorganize & make use of pragma marks throughout to make this code better organized and easier to trace.
 
 
 */

@implementation HelperClass

#pragma mark version checking

- (id)init {
    self = [super init];
    if (self){
        _xcDownloadInfo = [XcodeDownloads new];
        _theosPath = [[HelperClass theosPath] stringByExpandingTildeInPath];
        NLog(@"theosPath: %@", _theosPath);
        _username = [HelperClass singleLineReturnForProcess:@"whoami"];
        _dpkgPath = [HelperClass singleLineReturnForProcess:@"which dpkg-deb"];
    }
    return self;
}

#pragma mark UI / progress management

//currently the basic progress block is currently only implemented on the GUI app, but it enables core functions in here to relay data back to the AppDelegate.

- (void)upgradeTextProgress:(NSString *)progress indeterminate:(BOOL)ind percent:(double)percentComplete {
    if (self.BasicProgressBlock){ //since objective-c is a dynamic and 'loose' language, it is good practice to do nil checks.
        self.BasicProgressBlock(progress, ind, percentComplete);
    }
}

#pragma mark Important paths

//determine if a THEOS environment variable already exists depending on the default shell

+ (NSString *)theosPath {
    
    NSString *alias = [HelperClass aliasPath]; //gets a default alias path based on the current shell (ie ~/.bash_profile, or ~/.zshrc etc)
    NSString *envRun = [NSString stringWithFormat:@"cat %@ | grep -m 1 THEOS= | cut -d \"=\" -f 2", alias]; //use cat to read the file, and grep to match 'THEOS=' in the file, and use 'cut to return the important data
    return [HelperClass singleLineReturnForProcess:envRun]; //this will run a line like the one above as if you were running it in a regular Terminal session.
}

//use printenv to determine default shell

+ (NSString *)defaultShell {
    return [HelperClass singleLineReturnForProcess:@"printenv SHELL"];
}

//take default shell and return the default alias path, only works with bash or zsh as defaults right now.

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
//environment var, fits close enough with important paths

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

#pragma mark Free space determination

//returns a user readable value for the amount of hard drive space available on your main drive.

+ (NSString *)freeSpaceString {
    float space = [self freeSpaceAvailable];
    return [[NSString stringWithFormat:@"%f", space] suffixNumber];
}

+ (float)freeSpaceAvailable {
    float available = [[[FM attributesOfFileSystemForPath:@"/" error:nil] objectForKey:NSFileSystemFreeSize] floatValue];
    float avail2 = available / 1024;
    return avail2;
}

#pragma mark Core Functions

/**
 
 This function will handle checking out theos + our fork of the SDK repo + our nic repo from github
 
 */

- (void)checkoutTheosIfNecessary:(void(^)(BOOL success))block {
    BOOL theosNeeded = true; //track if theos is needed separetly from whether our SDK fork is needed
    if ([FM fileExistsAtPath:_theosPath]){
        theosNeeded = false;
        NLog(@"theos detected! checking for tvOS SDK's\n");
        NSString *path = [_theosPath stringByAppendingPathComponent:@"sdks/AppleTVOS12.4.sdk"]; //check for a known path in our SDKs github fork
        if ([FM fileExistsAtPath:path]){
            NLog(@"AppleTV SDK's detected, no theos checkout is necessary\n");
            [self upgradeTextProgress:@"" indeterminate:true percent:0]; //clear progress
            if (block){
                block(true); //call the completion block
            }
            return;
        }
    }
    
    /*
     
     checking out things via git is tricky if the target folders already exist.
     when you checkout THEOS it has an empty 'sdks' folder (which the user may have added folders to - so we cant delete it)
     git will not allow you to 'clone' a repository if the target folder it will be creating already exists
     for example: if "~/Library/theos/sdks" exists running 'git clone xxx ~/Library/theos/sdks' will yield an error
     
     to handle this all of the clones below go to a temporary folder first and THEN move their contents to the target directory.
    
     */
    
    NSString *sdks = @"https://github.com/lechium/sdks.git";//@"git@github.com:lechium/sdks.git";
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [libraryPaths firstObject];
    NSString *fullCmd = nil;
    if (theosNeeded){
        //if its not called twice sometimes the UI doesnt update properly - likely a race condition on changing the progress details
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

//post processing for downloaded files, manages Xcode.xip and Command Line Utils.dmg
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

#pragma mark installation checks

+ (BOOL)brewInstalled {
    return ([FM fileExistsAtPath:@"/usr/local/bin/brew"]);
}

+ (BOOL)commandLineToolsInstalled {
    return ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/SDKSettings.plist"]);
}

+ (BOOL)xcodeInstalled {
    NSString *path = [[NSWorkspace sharedWorkspace] fullPathForApplication:@"Xcode.app"];
    if (path.length > 0 && [FM fileExistsAtPath:path]){
        return true;
    }
    return false;
}

#pragma mark website URL's

+ (NSURL *)appleIDPage {
    return [NSURL URLWithString:@"https://appleid.apple.com/account#!&page=create"];
}
+ (NSURL*)developerAccountSite {
    return [NSURL URLWithString:@"https://developer.apple.com/account"];
}

+ (NSURL *)moreDownloadsURL {
    return [NSURL URLWithString:@"https://developer.apple.com/download/more/"];
}

#pragma mark CLI only

+ (void)openIDSignupPage {
    [[NSWorkspace sharedWorkspace] openURL:self.appleIDPage];
}

+ (void)openDeveloperAccountSite {
    [[NSWorkspace sharedWorkspace] openURL:self.developerAccountSite];
}

//this is different because it will run through our current command line session rather than spawning a new terminal window.
- (void)installHomebrewIfNecessary {
    if (![HelperClass brewInstalled]){
        NSString *temp = NSTemporaryDirectory();
        NSString *runCmd = [NSString stringWithFormat:@"curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh -o %@install.sh ; chmod +x %@install.sh", temp, temp];
        //DLog(@"runCmd: %@", runCmd);
        [HelperClass singleLineReturnForProcess:runCmd];
        NSString *runScript = [NSString stringWithFormat:@"/bin/bash %@", [temp stringByAppendingString:@"install.sh"]];
        //DLog(@"%@", runScript);
        [HelperClass runInteractiveProcess:runScript];
    }
}

#pragma mark task execution

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

//run a task where we dont care about the console output but we do care about the target folder & return status.
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

//used when we care about the actual console output of the task being run
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

//only used in the command line tool, for running scripts that require user interaction, ie the brew installl script.
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

//similar to arrayFromTask but uses popen instead of NSTask
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

//same as above but it returns everything as one single line
+ (NSString *)singleLineReturnForProcess:(NSString *)call {
    return [[self returnForProcess:call] componentsJoinedByString:@"\n"];
}

#pragma mark diskimage / mount manipulation

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

//this is specifically if we need to find an external drive to extract / download some of the files to, currently unused

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

#pragma mark Unused cache code

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


@end
