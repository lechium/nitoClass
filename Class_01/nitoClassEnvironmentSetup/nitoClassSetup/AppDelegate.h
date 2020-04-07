//
//  AppDelegate.h
//  nitoClassSetup
//
//  Created by Kevin Bradley on 3/28/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "FileMonitor.h"
@interface AppDelegate : NSObject <NSApplicationDelegate, WebResourceLoadDelegate, WebFrameLoadDelegate, WebPolicyDelegate, FileMonitorDelegate>
@property IBOutlet NSProgressIndicator *progressBar;
@property IBOutlet NSTextField *progressLabel;
@property IBOutlet NSTextField *commandField;
- (IBAction)openDeveloperPage:(id)sender;
- (IBAction)openAppleIDPage:(id)sender;
- (IBAction)openDownloadsPage:(id)sender;
- (IBAction)installBrew:(id)sender;
- (IBAction)openTutorialVideo:(id)sender;
- (void)startListening;
- (void)stopListening;
@end

