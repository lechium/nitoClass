//
//  AppDelegate.m
//  nitoClassSetup
//
//  Created by Kevin Bradley on 3/28/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import "AppDelegate.h"
#import "URLDownloader.h"
#import "WebCategories.h"
#import "WebFrame+Nito.h"
#include <sys/stat.h>
@interface AppDelegate () {
    WebView *webView;
}

@property (weak) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *webWindow;

@end

@implementation AppDelegate

- (IBAction)testRun:(id)sender {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    NSString *fileContents = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/Homebrew/install/master/install.sh"] encoding:NSUTF8StringEncoding error:nil];
    NSString *outFile = [NSHomeDirectory() stringByAppendingPathComponent:@"brew.sh"];
    [fileContents writeToFile:outFile atomically:true encoding:NSUTF8StringEncoding error:nil];
    chmod([outFile UTF8String], 0755);
    [ws openFile:outFile withApplication:@"Terminal" andDeactivate:false];
    

}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    NLog(@"request: %@", request.URL);
    NSString *ext = request.URL.pathExtension;

    if (ext.length > 0){
        HelperClass *hc = [HelperClass new];
        [hc.downloads downloadFileURL:request.URL];
        URLDownloader *dl = hc.downloads.downloader;
        dl.ProgressBlock = ^(double percentComplete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.progressLabel.stringValue = [NSString stringWithFormat:@"Downloading file %@", request.URL.lastPathComponent];
                self.progressBar.doubleValue = percentComplete;
            });
        };
        dl.CompletedBlock = ^(NSString *downloadedFile) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.progressLabel.stringValue = @"";
                self.progressBar.doubleValue = 1;
                [self.progressBar stopAnimation:nil];
                //NSArray *bruh = [HelperClass arrayReturnForTask:@"/usr/bin/hdituil" withArguments:@[@"attach", downloadedFile]];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSString *heyo = [HelperClass mountImage:downloadedFile];
                    NSLog(@"mounted location: %@", heyo);
                    
                });
                //[[NSWorkspace sharedWorkspace] openFile:downloadedFile];
            });
        };
    } else {
        [listener use];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame; {
    

    //id ff = [frame findFrameNamed:@"aid-auth-widget"];
    DOMHTMLDivElement *div = [[frame DOMDocument] getElementById:@"auth-container"];
    NSLog(@"div : %@", [(DOMHTMLIFrameElement *)[div querySelector:@"iframe"] src]);
    NSLog(@"url: %@", [sender mainFrameURL]);
    
    NSString *mfu = [sender mainFrameURL];
    if ([mfu containsString:@"/#/welcome"]){
        NSLog(@"we are signed in!");
        
    }
    
    //NSLog(@"ff: %@", ff);
    NSLog(@"title: %@", [[frame DOMDocument] title]);
   // NSLog(@"form: %@", [[[[frame DOMDocument] forms] firstObject] innerHTML]);
   // WebFrame *wf = [[frame childFrames] lastObject];
    //NSLog(@"email: %@", [[wf DOMDocument] inputElementOfType:@"email"] );
    //NSLog(@"password: %@", [[wf DOMDocument] inputElementOfType:@"password"] );
    /*
    NSLog(@"links: %@",[[[frame DOMDocument] links] allObjects] );
    NSArray <DOMHTMLAnchorElement *>*links = [[[frame DOMDocument] links] allObjects];
    [links enumerateObjectsUsingBlock:^(DOMHTMLAnchorElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"link %@ at index %lu",[obj innerText], idx);
    }];
     */
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSString *ext = response.URL.pathExtension;
    NLog(@"ext: %@", response.URL.pathExtension);
    //LOG_SELF;
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    
    for (NSHTTPCookie *cookie in cookies) {
        // NLog(@"cookie: %@", cookie);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    if (ext.length > 0){
        HelperClass *hc = [HelperClass new];
        [hc.downloads downloadFileURL:response.URL];
        hc.downloads.downloader.ProgressBlock = ^(double percentComplete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.progressLabel.stringValue = [NSString stringWithFormat:@"Downloading file %@", response.URL.lastPathComponent];
                self.progressBar.doubleValue = percentComplete;
            });
        };
        decisionHandler(WKNavigationResponsePolicyCancel);
        return;
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (NSInteger)showDeveloperAccountAlert
{
    NSAlert *developerAccountAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"Developer Account Required",@"") defaultButton:NSLocalizedString(@"Yes",@"") alternateButton:NSLocalizedString(@"No", @"") otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Development for deployment to any mobile apple device requires an Apple Developer account. Do you have one? (Free ones are sufficient). \n\nIf you have an Apple ID, signing in to the developer portal with this apple ID will enable you to sign up for the free account.",@"")];
    return [developerAccountAlert runModal];
    
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self _createViews];
    [self openDeveloperPage:nil];
    [HelperClass xcodeInstalled];
 
    NSInteger resp = [self showDeveloperAccountAlert];
    switch (resp){
        case NSAlertDefaultReturn:
            //run through the general process
            break;
            
        case NSAlertAlternateReturn:
            NSLog(@"alt"); //No
            [self openDeveloperPage:nil];
            break;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"ivars: %@", [webView ivars]);
    NSLog(@"props: %@", [webView properties]);
}

- (IBAction)openDownloadsPage:(id)sender {

    NSURL *url = [HelperClass moreDownloadsURL];
    HelperClass *hc = [HelperClass new];
    url = [NSURL URLWithString:[[hc downloads] commandLineURL]];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    [[webView mainFrame] loadRequest:req];
}

- (IBAction)openDeveloperPage:(id)sender {
    
    NSURL *url = [HelperClass developerAccountSite];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    [[webView mainFrame] loadRequest:req];
}

- (IBAction)openAppleIDPage:(id)sender {
    NSURL *url = [HelperClass appleIDPage];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    [[webView mainFrame] loadRequest:req];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)_createViews {
    NSView* contentView = _window.contentView;
    
    //WebView
    webView = [[WebView alloc] initWithFrame:contentView.frame];
    webView.policyDelegate = self;
    webView.frameLoadDelegate = self;
    [webView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    [contentView addSubview:webView];
}

@end
