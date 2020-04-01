
#import <Foundation/Foundation.h>

@interface DownloadOperation: NSOperation <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

typedef void(^DownloadCompletedBlock)(NSString *downloadedFile);
typedef void(^DownloadProgressBlock)(double percentComplete, double writtenBytes, double expectedBytes);

@property (nonatomic, strong) NSURL *downloadURL;
@property (nonatomic, strong) NSString *downloadLocation;
@property (strong, atomic) void (^ProgressBlock)(double percentComplete);
@property (strong, atomic) void (^FancyProgressBlock)(double percentComplete, double writtenBytes, double expectedBytes);
@property (strong, atomic) void (^CompletedBlock)(NSString *downloadedFile);

- (id)initWithURL:(NSURL *)fileURL progresss:(DownloadProgressBlock)progressBlock completed:(DownloadCompletedBlock)completedBlock;

@end
