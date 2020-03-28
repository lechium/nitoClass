

@interface InputPackageFile: NSObject

@property (nonatomic, strong) NSString *fileType;
@property (nonatomic, strong) NSString *permissions;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *linkDestination;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *basename;
@property (readwrite, assign) NSInteger type;

- (void)_setFileTypeFromRaw:(NSString *)rawType;

@end
