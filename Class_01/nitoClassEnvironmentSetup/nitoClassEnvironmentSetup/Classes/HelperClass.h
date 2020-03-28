#import "StatusPackageModel.h"
#import "XcodeDownloads.h"

@interface HelperClass: NSObject

@property XcodeDownloads *downloads;
@property BOOL hasAppleId;
@property BOOL hasDeveloperAccount;
@property NSString *theosPath;

- (void)waitForReturnWithMessage:(NSString *)message;
+ (BOOL)xcodeInstall;
+ (BOOL)commandLineToolsInstalled;
+ (BOOL)queryUserWithString:(NSString *)query;
+ (BOOL)shouldContinueWithError:(NSString *)errorMessage;
+ (NSArray *)returnForProcess:(NSString *)call;
+ (InputPackage *)packageForDeb:(NSString *)debFile;
+ (NSString *)octalFromSymbols:(NSString *)theSymbols;
+ (NSString *)singleLineReturnForProcess:(NSString *)call;
+ (NSArray *)arrayReturnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments;
+ (NCSystemVersionType)currentVersion;
- (void)openIDSignupPage;
- (void)openDeveloperAccountSite;
@end
