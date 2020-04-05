//
//  XcodeDownloads.h
//  nitoClassEnvironmentSetup
//
//  Created by Kevin Bradley on 3/28/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadOperation.h"
typedef enum {
    FileDownloadTypeXcode,
    FileDownloadTypeCLI,
    FileDownloadTypeStandard, //any other file, when processing these we don't care about the download block.
}
FileDownloadType;
//11.4 SHASUM = 7c1151670760be55c5c8b09be1aa2a17291dc468, xip size 8111919274, extracted size: 16.83 GB
//11.3.1 SHASUM = d5773e61189595cbb639c3e1c460b38d8c1e19ae, xip size 7843352719, extracted size: 16.15 GB
//10.1 SHASUM - 6a6667303750ce9c238da8a4ea76d54eefe2bbc4, xip size 6047730870, extracted size: 12.47 GB : 12460255151

@interface XcodeDownload: NSObject

@property (nonatomic, strong) NSString *downloadURL;
@property (readwrite, assign) NSInteger expectedSize; //6047806709
@property (readwrite, assign) NSInteger extractedSize; //6047806709
@property (nonatomic, strong) NSString *SHA;
@property FileDownloadType downloadType;

@end

@interface XcodeDownloads : NSObject

@property (nonatomic, strong) NSArray <XcodeDownload *>* downloads;
@property (strong, atomic) void (^ProgressBlock)(double percentComplete);
@property (strong, atomic) void (^FancyProgressBlock)(NSString *fileName, double percentComplete, double writtenBytes, double expectedBytes);
@property (strong, atomic) void (^CompletedBlock)(NSString *downloadedFile, id downloadObject);
@property (strong, atomic) void (^DownloadsFinishedBlock)(void);
@property (strong, nonatomic) NSOperationQueue      *operationQueue;
@property BOOL xcodeInstalled;
@property BOOL cliInstalled;
@property NCSystemVersionType sytemVersion;
@property NSString *systemVersionCodename;
@property NSString *xcodeDownloadURL;
@property NSString *commandLineURL;
- (void)downloadFileURL:(NSURL *)url;
- (BOOL)hasDownloads;
- (XcodeDownload *)downloadFromURL:(NSURL *)url;
- (void)cancelAllDownloads;
- (void)downloadFile:(XcodeDownload *)download;
@end
