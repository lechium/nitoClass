#import "XcodeDownloads.h"

@interface HelperClass: NSObject

@property XcodeDownloads *downloads;
@property BOOL hasAppleId;
@property BOOL hasDeveloperAccount;
@property NSString *theosPath;
@property NSString *dpkgPath;
@property NSString *username;
@property (strong, atomic) void (^BasicProgressBlock)(NSString *progressDetails, BOOL indeterminate, double percentComplete);
@property (strong, atomic) void (^HelperProgressBlock)(NSString *progressDetails, double percentComplete, double writtenBytes, double expectedBytes);
+ (long long) folderSizeAtPath: (const char*)folderPath;
+ (NSString *)theosPath;
+ (NSString *)freeSpaceString;
+ (NSString *)aliasPath;
+ (NSString *)defaultShell;
+ (float)freeSpaceAvailable;
+ (BOOL)belowFreeSpaceThreshold;
+ (NSURL *)moreDownloadsURL;
+ (NSString *)tempFolder;
- (void)installHomebrewIfNecessary;
- (void)checkoutTheosIfNecessary:(void(^)(BOOL success))block;
+ (NSInteger)runTask:(NSString *)fullCommand inFolder:(NSString *)targetFolder;
- (void)waitForReturnWithMessage:(NSString *)message;
+ (BOOL)xcodeInstalled;
- (void)installXcode;
+ (BOOL)brewInstalled;
+ (BOOL)commandLineToolsInstalled;
+ (BOOL)queryUserWithString:(NSString *)query;
+ (NSArray *)returnForProcess:(NSString *)call;
+ (NSString *)octalFromSymbols:(NSString *)theSymbols;
+ (NSString *)singleLineReturnForProcess:(NSString *)call;
+ (NSArray *)arrayReturnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments;
+ (NCSystemVersionType)currentVersion;
+ (void)openIDSignupPage;
+ (NSURL *)appleIDPage;
+ (NSURL*)developerAccountSite;
+ (void)openDeveloperAccountSite;
+ (NSArray *)scanForDrives;
+ (NSString *)mountImage:(NSString *)irString;
+ (NSString *)processDownload:(NSString *)download;
@end
