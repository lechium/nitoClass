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

        NSLog(@"Version: %@", hc.downloads.systemVersionCodename);
        NSLog(@"dl link: %@", hc.downloads.xcodeDownloadURL);
        NSLog(@"cli link: %@", hc.downloads.commandLineURL);
        NSLog(@"xcode installed: %d", hc.downloads.xcodeInstalled);
        NSLog(@"cli installed: %d", hc.downloads.cliInstalled);
        
        hc.hasAppleId = [HelperClass queryUserWithString:@"Do you have a Apple ID set up?"];
        if (!hc.hasAppleId){
            [hc openIDSignupPage];
            BOOL shouldContinue = [HelperClass queryUserWithString:@"You need an apple id before continuing!, opening the page in your default browser, press 'y when complete or n to cancel"];
            if (shouldContinue) {
                hc.hasDeveloperAccount = [HelperClass queryUserWithString:@"Do you have a Apple developer account? (Free acounts are sufficient)"];
                if (!hc.hasDeveloperAccount){
                    [hc openDeveloperAccountSite];
                    BOOL shouldContinue = [HelperClass queryUserWithString:@"You need a developer account to continue, opening the page in your default browser, press 'y when complete or n to cancel"];
                    if (shouldContinue){
                        NSLog(@"passed developer account signup");
                    }
                    
                }
            }
        } else { //we have an apple id
            hc.hasDeveloperAccount = [HelperClass queryUserWithString:@"Do you have a Apple developer account? (Free acounts are sufficient)"];
            if (!hc.hasDeveloperAccount){
                [hc openDeveloperAccountSite];
                BOOL shouldContinue = [HelperClass queryUserWithString:@"You need a developer account to continue, opening the page in your default browser, press 'y when complete or n to cancel"];
                if (shouldContinue){
                    NSLog(@"passed developer account signup");
                }
                
            }
        }
        
    }
    return 0;
}

