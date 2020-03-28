//
//  main.m
//  nitoClassEnvironmentSetup
//
//  Created by Kevin Bradley on 3/28/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"
#import "HelperClass.h"
#import "XcodeDownloads.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        HelperClass *hc = [HelperClass new];

        NSLog(@"Version: %lu", hc.downloads.sytemVersion);
        NSLog(@"dl link: %@", hc.downloads.xcodeDownloadURL);
        NSLog(@"cli link: %@", hc.downloads.commandLineURL);
        NSLog(@"xcode installed: %d", hc.downloads.xcodeInstalled);
        NSLog(@"cli installed: %d", hc.downloads.cliInstalled);
    }
    return 0;
}

