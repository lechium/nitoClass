//
//  AppDelegate.m
//  nitoClassSetup
//
//  Created by Kevin Bradley on 3/28/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import "AppDelegate.h"
#import "WebCategories.h"
#import "WebFrame+Nito.h"
#include <sys/stat.h>
#import "NSData+CommonCrypto.h"
#import "NSData+Flip.h"
@import Darwin.POSIX.dirent;

#define kDebugFileMaxSize    200 * 1024
@interface AppDelegate () {
    WebView *webView;
}

@property (weak) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *webWindow;
@property NSCalendarDate *start;
@property NSDate *startDate;
@property (strong) FileMonitor *monitor;
@property (nonatomic, strong) NSString *ourDirectory;
@property (nonatomic, strong) HelperClass *helperInstance;
@end

@implementation AppDelegate

- (void)stopListening {
    [self.monitor stopMonitor];
}

- (void)startListening {
    
    self.monitor = [FileMonitor new];
    self.ourDirectory = @"/usr/bin/";
    NSLog(@"our dir: %@", self.ourDirectory);
    [self.monitor monitorDir:self.ourDirectory delegate:self];
    [self dirChanged:self.ourDirectory];
}


- (IBAction)installBrew:(id)sender {
    NSString *fileContents = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/Homebrew/install/master/install.sh"] encoding:NSUTF8StringEncoding error:nil];
    fileContents = [fileContents stringByAppendingString:@"\necho 'installing nitoClass extras'\n\nbrew install ldid xz dpkg\n"];
    NSString *outFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"brew.sh"];
    [fileContents writeToFile:outFile atomically:true encoding:NSUTF8StringEncoding error:nil];
    chmod([outFile UTF8String], 0755);
    [[NSWorkspace sharedWorkspace] openFile:outFile withApplication:@"Terminal" andDeactivate:false];
    [self updateProgressLabel:@""];
    [self updateProgressValue:1 indeterminate:true];
}

-(void) dirChanged:(NSString*) aDirName {
    
    NSString *git = [aDirName stringByAppendingPathComponent:@"git"];
    if ([FM fileExistsAtPath:git]){
        NLog(@"we done got git!, can check out theos etc now!");
        //[self stopListening];
        //[[self helperSharedInstance] checkoutTheosIfNecessary];
    } else {
        NLog(@"NO GIT FOR YOU");
    }
}


- (void)updateProgressLabel:(NSString *)text {
    if (![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressLabel.stringValue = text;
        });
    } else {
        self.progressLabel.stringValue = text;
    }
}


- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    //NLog(@"request: %@ headers: %@ body: %@", request, request.allHTTPHeaderFields, request.HTTPBody);
    NSString *ext = request.URL.pathExtension;
    
    if (ext.length > 0){
        _startDate = [NSDate date];
        _start = [NSCalendarDate calendarDate];
        HelperClass *hc = [self helperSharedInstance];
        XcodeDownloads *downloads = [hc downloads];
        __block XcodeDownload *dl = [downloads downloadFromURL:request.URL];
        double fullSize = (([dl expectedSize]/1024) + ([dl extractedSize])/1024);
        double availSize = [HelperClass freeSpaceAvailable];
        
        NLog(@"avail: %f vs full: %f", availSize, fullSize);
        if (availSize < fullSize){
            NLog(@"not enough space, this is probably bad!");
            [self showInsufficientSpaceAlert];
            return;
        }
        [hc.downloads downloadFileURL:request.URL];
        //URLDownloader *dl = hc.downloads.downloader;
        downloads.FancyProgressBlock = ^(double percentComplete, double writtenBytes, double expectedBytes) {
            // NSLog(@"pc: %f", percentComplete);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self download:dl durationDidIncreaseTo:writtenBytes totalDuration:expectedBytes];
                //self.progressLabel.stringValue = [NSString stringWithFormat:@"Downloading file %@", request.URL.lastPathComponent];
                self.progressBar.doubleValue = percentComplete;
            });
        };
        downloads.CompletedBlock = ^(NSString *downloadedFile) {
            NLog(@"downloaded file: %@", downloadedFile);
            
            NLog(@"xcd: %@", dl);
            /*
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                BOOL validated = [downloadedFile validateFileSHA:dl.SHA];
                if (validated){
                    NLog(@"VALID!");
                } else {
                    NSLog(@"INVALID!!!");
                }
            });*/
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.progressLabel.stringValue = @"";
                self.progressBar.doubleValue = 1;
                [self.progressBar stopAnimation:nil];
                //NSArray *bruh = [HelperClass arrayReturnForTask:@"/usr/bin/hdituil" withArguments:@[@"attach", downloadedFile]];
                if ([downloadedFile.pathExtension isEqualToString:@"xip"]){
                    self.progressLabel.stringValue = [NSString stringWithFormat:@"Extacting file %@", request.URL.lastPathComponent];
                    self.progressBar.indeterminate = true;
                    [self.progressBar startAnimation:nil];
                    
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    
                    NSString *heyo = [HelperClass processDownload:downloadedFile];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.progressBar.indeterminate = false;
                        [self.progressBar stopAnimation:nil];
                    });
                    NSLog(@"processed location: %@", heyo);
                    //[self startListening];
                    NSArray *files = [FM contentsOfDirectoryAtPath:heyo error:nil];
                    NSString *chosen = [[files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                        if ([[evaluatedObject pathExtension] isEqualToString:@"pkg"]){
                            return true;
                        }
                        return false;
                    }]] lastObject] ;
                    NSLog(@"chosen: %@", chosen);
                    [[NSWorkspace sharedWorkspace] openFile:[heyo stringByAppendingPathComponent:chosen]];
                });
                //[[NSWorkspace sharedWorkspace] openFile:downloadedFile];
            });
        };
        
        downloads.DownloadsFinishedBlock = ^{
            
            [self runPostXcodeProcess];
            
        };
        
    } else {
        [listener use];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame; {
    
    NSString *mfu = [sender mainFrameURL];
    if ([mfu containsString:@"/#/welcome"]){
        NSLog(@"we are signed in!");
        NSInteger resp = [self showDeveloperAccountAlert];
        switch (resp){
            case NSAlertDefaultReturn:
                //run through the general process
                [self runStandardProcess];
                break;
                
            case NSAlertAlternateReturn:
                NSLog(@"alt"); //No
                [self openDeveloperPage:nil];
                break;
        }
    }
    
    
    //NSLog(@"ff: %@", ff);
    NSLog(@"title: %@", [[frame DOMDocument] title]);
}

- (void)showInsufficientSpaceAlert {
    NSAlert *developerAccountAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"Insufficient Free Space",@"") defaultButton:NSLocalizedString(@"OK",@"") alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"There is insufficient free space to install the development environment.",@"")];
    [developerAccountAlert runModal];
}

- (NSInteger)showDeveloperAccountAlert
{
    NSAlert *developerAccountAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"Developer Account Required",@"") defaultButton:NSLocalizedString(@"Yes",@"") alternateButton:NSLocalizedString(@"No", @"") otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Development for deployment to any mobile apple device requires an Apple Developer account. Do you have one? (Free ones are sufficient). \n\nIf you have an Apple ID, signing in to the developer portal with this apple ID will enable you to sign up for the free account.",@"")];
    return [developerAccountAlert runModal];
    
}

- (void)download:(XcodeDownload *)download durationDidIncreaseTo:(long long)writtenDuration totalDuration:(long long)sourceDuration;
{
    float currentLevel = (float)((double)writtenDuration/(double)sourceDuration);
    float percent = currentLevel*100.0;
    NSInteger rSeconds = 0;
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:_startDate];
    [[NSCalendarDate calendarDate] years:nil months:nil days:nil hours:nil minutes:nil seconds:&rSeconds sinceDate:_start];
    NLog(@"r seconds: %lu interval: %.2f", rSeconds, interval);
    float speed = (float)writtenDuration/(float)rSeconds;
    float left = ((float)sourceDuration - (float)writtenDuration)/speed;
    NSString *leftString = nil;
    if(rSeconds < 15){
        leftString = NSLocalizedString(@"ETR", @"ETR");
    } else {
        leftString = [[NSString stringWithFormat:@"%f",left] TIMEFormat];
    }
    if(percent > 100.0) {
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_progressLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"About %.1f%% Complete <%@>", nil), percent, leftString]];
            
        });
    }
    
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self _createViews];
    [self openDeveloperPage:nil];
    [self scanEnvironment];
}


- (void)runPostXcodeProcess {
    [self updateProgressLabel:@"Post Xcode Processing, checkinging out theos & sdks..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[self helperSharedInstance] checkoutTheosIfNecessary:^(BOOL success) {
            NLog(@"theos is done with status %d", success);
            if (![HelperClass brewInstalled]){
                [self updateProgressLabel:@"Attempting to run brew install script..."];
                [self updateProgressValue:0 indeterminate:true];
                [self installBrew:nil];
                
            } else {
                [self updateProgressLabel:@""];
                [self updateProgressValue:1 indeterminate:true];
            }
        }];
    });
    
}

- (void)runAuthBasedProcess {
    [self.window makeKeyAndOrderFront:nil];
}


- (void)scanEnvironment {
  
    NSInteger freeSpace = [HelperClass freeSpaceAvailable];
    NLog(@"free space: %lu", freeSpace);
    if (![HelperClass xcodeInstalled] || ![HelperClass commandLineToolsInstalled]){
        NLog(@"either Xcode or the command line tools are missing, need to authenticate!");
        [self runAuthBasedProcess];
    } else {
        [self runPostXcodeProcess];
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"ivars: %@", [webView ivars]);
    NSLog(@"props: %@", [webView properties]);
}

- (void)updateProgressValue:(double)value indeterminate:(BOOL)indy {
    if (![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (value == 0 && indy == true){
                [self.progressBar startAnimation:nil];
                self.progressBar.indeterminate = indy;
                
            } else if (indy == true && value == 1){
                [self.progressBar stopAnimation:nil];
            } else {
                [self.progressBar startAnimation:nil];
                self.progressBar.doubleValue = value;
            }
            
        });
    } else {
        if (value == 0 && indy == true){
            [self.progressBar startAnimation:nil];
            self.progressBar.indeterminate = indy;
            
        } else if (indy == true && value == 1){
            [self.progressBar stopAnimation:nil];
        } else {
            [self.progressBar startAnimation:nil];
            self.progressBar.doubleValue = value;
        }
    }
}

- (HelperClass *)helperSharedInstance {
    if (!self.helperInstance){
        self.helperInstance = [HelperClass new];
        @weakify(self);
        self.helperInstance.BasicProgressBlock = ^(NSString *progressDetails, BOOL indeterminate, double percentComplete) {
            [self_weak_ updateProgressLabel:progressDetails];
            [self_weak_ updateProgressValue:percentComplete indeterminate:indeterminate];
            NLog(@"%@", progressDetails);
        };
    }
    return self.helperInstance;
}

- (void)runStandardProcess {
    
    HelperClass *hc = [self helperSharedInstance];
    XcodeDownloads *xcdl = [hc downloads];
    NSArray <XcodeDownload *> *dl = [xcdl downloads];
    
    [dl enumerateObjectsUsingBlock:^(XcodeDownload * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:obj.downloadURL]];
        [[self->webView mainFrame] loadRequest:req];
    }];
}

- (IBAction)openDownloadsPage:(id)sender {
    NSURL *url = [HelperClass moreDownloadsURL];
    HelperClass *hc = [self helperSharedInstance];
    XcodeDownloads *dl = [hc downloads];
    if (![HelperClass xcodeInstalled]){
        url = [NSURL URLWithString:[dl xcodeDownloadURL]];
    }
    if ([HelperClass commandLineToolsInstalled]){
        //    url = [NSURL URLWithString:[dl commandLineURL]];
    }
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
