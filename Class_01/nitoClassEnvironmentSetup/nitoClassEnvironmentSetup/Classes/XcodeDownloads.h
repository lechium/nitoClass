//
//  XcodeDownloads.h
//  nitoClassEnvironmentSetup
//
//  Created by Kevin Bradley on 3/28/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XcodeDownloads : NSObject
@property BOOL xcodeInstalled;
@property BOOL cliInstalled;
@property NCSystemVersionType sytemVersion;
@property NSString *xcodeDownloadURL;
@property NSString *commandLineURL;

@end

NS_ASSUME_NONNULL_END
