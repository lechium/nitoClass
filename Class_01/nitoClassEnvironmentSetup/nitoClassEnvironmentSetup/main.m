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
#include <unistd.h>

/**
 
 This tool will likely be constantly changing as i find better ways to handle the different tasks involved. It is the introduction to my free #nitoClass on tvOS development
 from start to finish. The goal of this class is to teach everything from normal application development and how it differs from iOS and macOS all the way until the most complex
 tweak development imaginable. There will be a companion slack or discord set up for this in addition to an old school forum. the awkwardtv wiki will be instrumental as well
 there MAY be a new more modernized wiki set up as well to be catered specifically to this class.
 

 Class 1

 This tool aims to analyze your system and automatically set up anything possible to make the initial process easier for you to get moving!
 will make exhaustive comments, any opportunity to get some objective-c lessons in at the same time.
 
 1. Do some system analysis
    a. find out OS version
    b. see if Xcode / CLI tools are installed
    c. check the default shell (might be frivolous)
    d. check if theos is installed
    e. see if brew is installed
 
 2. Ask the user some questions
    a. Do you have an Apple ID
    b. Do you have a developer account
 
 3. If Xcode or CLI tools are missing
    a. use analysis to see which xcode / cli tools to install
    b. download both of those as necessary.
 
 4. Once verified they have Xcode / CLI tools installed, make sure THEOS and related pieces are installed.
    a. If theos is missing create a folder (ie ~/Develop/) and check out the latest version
    b. Check for the SDK folder and checkout our branch
    c. Maybe add another repo that has some added tvOS templates
 

 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        HelperClass *hc = [HelperClass new];
        NSString *shell = [HelperClass singleLineReturnForProcess:@"printenv SHELL"];
        //home brew install for when needed
        ///bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        DLog(@"\n\nWelcome to the nitoClass environment setup tool!\n\n");
        DLog(@"System Info\n-----------\n\n")
        DLog(@"Version: %@", hc.downloads.systemVersionCodename);
        DLog(@"Username: %@", hc.username);
        DLog(@"Default Shell: %@\n\n", shell);
        DLog(@"Checking system environment...\n\n");
        [hc installHomebrewIfNecessary];
        if ([HelperClass brewInstalled]){
            DLog(@"Homebrew is installed!\n");
        } else {
            DLog(@"Homebrew is missing!\n");
        }
        if (hc.dpkgPath.length > 0){
            DLog(@"dpkg-deb path found: %@\n", hc.dpkgPath);
        } else {
            DLog(@"dpkg-deb is not installed!\n");
        }
        if (hc.theosPath.length > 0){
            DLog(@"THEOS path found: %@\n", hc.theosPath);
        } else {
            DLog(@"THEOS is not installed!\n");
            [hc checkoutTheosIfNecessary];
        }
        if (!hc.downloads.xcodeInstalled){
            DLog(@"Xcode missing, download link: %@\n", hc.downloads.xcodeDownloadURL);
        }
        if (!hc.downloads.cliInstalled){
            DLog(@"cli tools missing, download link: %@\n", hc.downloads.commandLineURL);
        }
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

