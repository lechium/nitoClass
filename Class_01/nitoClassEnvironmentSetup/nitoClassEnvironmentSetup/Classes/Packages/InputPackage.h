
//the input deb file that is processing

#import "InputPackageFile.h"

@interface InputPackage: NSObject

@property (nonatomic, strong) NSArray <InputPackageFile *> *files;
@property (nonatomic, strong) NSArray  *controlFiles;
@property (nonatomic, strong) NSString *packageName;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *path;

- (void)bumpVersionInCurrentDirectory;
- (void)repackageInCurrentDirectoryWithArch:(NSString *)newArch;
- (ErrorReturn *)errorReturnForBootstrap:(NSString *)bootstrapPath;
- (NSString *)listfile;
@end
