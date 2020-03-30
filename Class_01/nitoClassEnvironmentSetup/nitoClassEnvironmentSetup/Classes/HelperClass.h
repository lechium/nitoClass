#import "XcodeDownloads.h"

@interface HelperClass: NSObject
+ (NSString *)freeSpaceString;
+ (float)freeSpaceAvailable;
@property XcodeDownloads *downloads;
@property BOOL hasAppleId;
@property BOOL hasDeveloperAccount;
@property NSString *theosPath;
@property NSString *dpkgPath;
@property NSString *username;
+ (BOOL)belowFreeSpaceThreshold;
+ (NSURL *)moreDownloadsURL;
+ (NSString *)tempFolder;
- (void)installHomebrewIfNecessary;
- (void)checkoutTheosIfNecessary;
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
@end
