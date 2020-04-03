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
    NSView *infoView;
    NSTextView *infoText;
}

@property (weak) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *progressWindow;
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
    if (text.length == 0){
        [self.progressWindow close];
        [self.window makeKeyWindow];
    } else {
        [self.progressWindow makeKeyAndOrderFront:nil];
    }
    if (![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressLabel.stringValue = text;
        });
    } else {
        self.progressLabel.stringValue = text;
    }
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request
   newFrameName:(NSString *)frameName
decisionListener:(id<WebPolicyDecisionListener>)listener {
     NLog(@"decidePolicyForNewWindowAction: %@ request: %@", actionInformation, request);
    [listener use];
    [[webView mainFrame] loadRequest:request];
}


- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    NLog(@"request: %@ headers: %@ body: %@", request, request.allHTTPHeaderFields, request.HTTPBody);
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

- (void)showAccountAlert {
    
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame; {
    
    NSString *mfu = [sender mainFrameURL];
    if ([mfu containsString:@"/#/welcome"]){
        NSLog(@"we are signed in!");
        [self runStandardProcess];
    }
    
    
    //NSLog(@"ff: %@", ff);
    NSLog(@"title: %@", [[frame DOMDocument] title]);
}

- (void)showInsufficientSpaceAlert {
    NSAlert *developerAccountAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"Insufficient Free Space",@"") defaultButton:NSLocalizedString(@"OK",@"") alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"There is insufficient free space to install the development environment.",@"")];
    [developerAccountAlert runModal];
}

- (NSInteger)_showDeveloperAccountAlert
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
            [self->_progressLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Downloading %@...\nAbout %.1f%% Complete <%@>", nil), download.downloadURL.lastPathComponent, percent, leftString]];
            
        });
    }
    
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self _createViews];
    //[self openDeveloperPage:nil];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.progressWindow makeKeyAndOrderFront:nil];
    });
    HelperClass *hc = [self helperSharedInstance];
    XcodeDownloads *xcdl = [hc downloads];
    NSArray <XcodeDownload *> *dl = [xcdl downloads];
    
    [dl enumerateObjectsUsingBlock:^(XcodeDownload * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:obj.downloadURL]];
        [[self->webView mainFrame] loadRequest:req];
    }];
}

- (IBAction)openDownloadsPage:(id)sender {
    [self.window makeKeyAndOrderFront:nil];
    NSURL *url = [HelperClass moreDownloadsURL];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    [[webView mainFrame] loadRequest:req];
}

- (IBAction)openDeveloperPage:(id)sender {
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window makeKeyAndOrderFront:nil];
        NSURL *url = [HelperClass developerAccountSite];
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
        [[webView mainFrame] loadRequest:req];
    });
   
}

- (IBAction)openAppleIDPage:(id)sender {
    [self.window makeKeyAndOrderFront:nil];
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
    webView.translatesAutoresizingMaskIntoConstraints = false;
    [contentView addSubview:webView];
    [webView.widthAnchor constraintEqualToAnchor:contentView.widthAnchor multiplier:1.0].active = true;
    [webView.heightAnchor constraintEqualToAnchor:contentView.heightAnchor multiplier:1.0].active = true;
    [webView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor].active = true;
    [webView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor].active = true;
    [webView.topAnchor constraintEqualToAnchor:contentView.topAnchor].active = true;
    [webView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor].active = true;
    webView.alphaValue = 0;
    infoText = [[NSTextView alloc] init];
    infoText.editable = false;
    infoText.alignment = NSTextAlignmentCenter;
    infoText.translatesAutoresizingMaskIntoConstraints = false;
    infoText.font = [NSFont systemFontOfSize:24];
    infoText.backgroundColor = [NSColor clearColor];
    infoText.string = @"Welcome to nito class session 1\n\nThank you for joining us.\n\nThis application will step you through the process of setting up your environment to be able to create and deploy all the applications, tweaks and assorted projects throughout the course of this class.\n\nIf you don't already have an apple ID select the 'Create yours now.' link on the next page.\n\nYour Apple ID must be signed up as a developer account (free or otherwise) to continue.\n\nYou will be presented with the developer portal to login upon pressing continue.\n\nYou will need to fill out whatever forms presented upon login if you aren't already signed up as a developer.\n The application will take it from there, Enjoy!";
    infoView = [[NSView alloc] initWithFrame:contentView.frame];
    infoView.translatesAutoresizingMaskIntoConstraints = false;
    [infoView addSubview:infoText];
    [contentView addSubview:infoView];
    
    [infoView.widthAnchor constraintEqualToAnchor:contentView.widthAnchor multiplier:1.0].active = true;
    [infoView.heightAnchor constraintEqualToAnchor:contentView.heightAnchor multiplier:1.0].active = true;
    [infoText.widthAnchor constraintEqualToAnchor:infoView.widthAnchor multiplier:0.8].active = true;
    [infoText.heightAnchor constraintEqualToAnchor:infoView.heightAnchor multiplier:0.8].active = true;
    [infoText.centerXAnchor constraintEqualToAnchor:infoView.centerXAnchor].active = true;
    [infoText.centerYAnchor constraintEqualToAnchor:infoView.centerYAnchor].active = true;
    
    NSButton *continueButton = [[NSButton alloc] init];
    continueButton.translatesAutoresizingMaskIntoConstraints = false;
    [continueButton.widthAnchor constraintEqualToConstant:100].active = true;
    [continueButton.heightAnchor constraintEqualToConstant:40].active = true;
    [continueButton setTitle:@"Continue"];
    [continueButton setTarget:self];
    [continueButton setAction:@selector(continueProcess:)];
    [infoView addSubview:continueButton];
    [continueButton.centerXAnchor constraintEqualToAnchor:infoView.centerXAnchor].active = true;
    [continueButton.topAnchor constraintEqualToAnchor:infoText.bottomAnchor constant:15].active = true;
    continueButton.bezelStyle = NSBezelStyleTexturedRounded;
    continueButton.keyEquivalent = @"\r";
    self.progressLabel.alignment = NSTextAlignmentCenter;
    self.progressLabel.textColor = [NSColor whiteColor];
}

- (void)continueProcess:(id)sender {
    
    [self openDeveloperPage:nil];
    [infoView removeFromSuperview];
    [webView setAlphaValue:1.0];
    
}


@end
