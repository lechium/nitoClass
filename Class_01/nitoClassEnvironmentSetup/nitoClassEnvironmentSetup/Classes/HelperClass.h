#import "XcodeDownloads.h"

@interface HelperClass: NSObject

@property XcodeDownloads *xcDownloadInfo;
@property BOOL hasAppleId;
@property BOOL hasDeveloperAccount;
@property NSString *theosPath;
@property NSString *dpkgPath;
@property NSString *username;
@property (strong, atomic) void (^BasicProgressBlock)(NSString *progressDetails, BOOL indeterminate, double percentComplete);
@property (strong, atomic) void (^HelperProgressBlock)(NSString *progressDetails, double percentComplete, double writtenBytes, double expectedBytes);

+ (NSString *)theosPath;
+ (NSString *)aliasPath;
+ (NSString *)defaultShell;
+ (NCSystemVersionType)currentVersion;

+ (float)freeSpaceAvailable;
+ (NSString *)freeSpaceString;

- (void)checkoutTheosIfNecessary:(void(^)(BOOL success))block;
- (NSString *)processDownload:(NSString *)download;

+ (NSURL *)moreDownloadsURL;
+ (NSURL *)appleIDPage;
+ (NSURL *)developerAccountSite;

+ (BOOL)xcodeInstalled;
+ (BOOL)brewInstalled;
+ (BOOL)commandLineToolsInstalled;

- (void)installHomebrewIfNecessary;
+ (void)openIDSignupPage;
+ (void)openDeveloperAccountSite;

+ (BOOL)queryUserWithString:(NSString *)query;
+ (NSInteger)runTask:(NSString *)fullCommand inFolder:(NSString *)targetFolder;
+ (NSArray *)returnForProcess:(NSString *)call;
+ (NSString *)singleLineReturnForProcess:(NSString *)call;
+ (NSArray *)arrayReturnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments;

+ (NSString *)mountImage:(NSString *)irString;
+ (NSArray *)scanForDrives;

+ (NSString *)cacheFolder ;
+ (NSString *)sessionCache;
+ (long long)sessionCacheSize;
+ (long long) folderSizeAtPath: (const char*)folderPath;
@end
