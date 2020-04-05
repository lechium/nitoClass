
#import <Foundation/Foundation.h>

@class XcodeDownload;

@interface DownloadOperation: NSOperation <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

typedef void(^DownloadCompletedBlock)(NSString *downloadedFile, id downloadObject);
typedef void(^DownloadProgressBlock)(NSString *fileName, double percentComplete, double writtenBytes, double expectedBytes);

@property (nonatomic, strong) NSURL *downloadURL;
@property (nonatomic, strong) NSString *downloadLocation;
@property (nonatomic, strong) XcodeDownload *xcodeDownload;
@property (strong, atomic) void (^ProgressBlock)(double percentComplete);
@property (strong, atomic) void (^FancyProgressBlock)(NSString *fileName, double percentComplete, double writtenBytes, double expectedBytes);
@property (strong, atomic) void (^CompletedBlock)(NSString *downloadedFile, id downloadObject);

- (id)initWithURL:(NSURL *)fileURL progresss:(DownloadProgressBlock)progressBlock completed:(DownloadCompletedBlock)completedBlock;

@end
