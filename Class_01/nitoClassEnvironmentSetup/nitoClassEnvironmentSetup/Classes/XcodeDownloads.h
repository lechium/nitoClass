//
//  XcodeDownloads.h
//  nitoClassEnvironmentSetup
//
//  Created by Kevin Bradley on 3/28/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLDownloader.h"

typedef enum {
    FileDownloadTypeXcode,
    FileDownloadTypeCLI,
}
FileDownloadType;
//11.4 SHASUM = 7c1151670760be55c5c8b09be1aa2a17291dc468, xip size 8111919274, extracted size: 16.83 GB
//11.3.1 SHASUM = d5773e61189595cbb639c3e1c460b38d8c1e19ae, xip size 7843352719, extracted size: 16.15 GB
//10.1 SHASUM - 6a6667303750ce9c238da8a4ea76d54eefe2bbc4, xip size 6047730870, extracted size: 12.47 GB

@interface XcodeDownloads : NSObject

@property (nonatomic, strong) URLDownloader *downloader;
@property BOOL xcodeInstalled;
@property BOOL cliInstalled;
@property NCSystemVersionType sytemVersion;
@property NSString *systemVersionCodename;
@property NSString *xcodeDownloadURL;
@property NSString *commandLineURL;
- (void)downloadFileType:(FileDownloadType)type;
- (void)downloadFileURL:(NSURL *)url;

@end
