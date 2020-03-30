//
//  AppDelegate.m
//  nitoClassSetup
//
//  Created by Kevin Bradley on 3/28/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import "AppDelegate.h"
#import "URLDownloader.h"

@interface AppDelegate () {
    WKWebView *_WKWebView;
}

@property (weak) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *webWindow;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self _createViews];
    [self openDeveloperPage:nil];
    NSArray *drives = [HelperClass scanForDrives];
    NSLog(@"drives: %@", drives);
}

- (IBAction)openDownloadsPage:(id)sender {
    
    HelperClass *hc = [HelperClass new];
    [[hc downloads] downloadFileType:FileDownloadTypeCLI];
    hc.downloads.downloader.ProgressBlock = ^(double percentComplete) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.progressLabel.stringValue = [NSString stringWithFormat:@"Downloading file %@", hc.downloads.commandLineURL.lastPathComponent];
            self.progressBar.doubleValue = percentComplete;
        });
    };
    hc.downloads.downloader.CompletedBlock = ^(NSString *downloadedFile) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DLog(@"file downloaded: %@", downloadedFile);
            self.progressLabel.stringValue = @"";
            [self.progressBar stopAnimation:nil];
        });
    };
    return;
    NSURL *url = [HelperClass moreDownloadsURL];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    [_WKWebView loadRequest:req];
}

- (IBAction)openDeveloperPage:(id)sender {
    
    NSURL *url = [HelperClass developerAccountSite];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    [_WKWebView loadRequest:req];
    _WKWebView.alphaValue = 1.0;
    _WKWebView.hidden = false;
    NSLog(@"web view: %@ frame: %@", _WKWebView, NSStringFromRect(_WKWebView.frame));
}

- (IBAction)openAppleIDPage:(id)sender {
    NSURL *url = [HelperClass appleIDPage];
    [_WKWebView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://developer.apple.com/account"]]];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    [_WKWebView loadRequest:req];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)_createViews {
    NSView* contentView = _window.contentView;
    // WKWebView
    _WKWebView = [[WKWebView alloc] initWithFrame:contentView.frame];
    [_WKWebView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    
    [contentView addSubview:_WKWebView];
}

@end
