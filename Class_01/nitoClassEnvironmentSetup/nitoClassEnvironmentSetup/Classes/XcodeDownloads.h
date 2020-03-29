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

@interface XcodeDownloads : NSObject
@property (nonatomic, strong) URLDownloader *downloader;
@property BOOL xcodeInstalled;
@property BOOL cliInstalled;
@property NCSystemVersionType sytemVersion;
@property NSString *systemVersionCodename;
@property NSString *xcodeDownloadURL;
@property NSString *commandLineURL;
- (void)downloadFileType:(FileDownloadType)type;
@end
