#import "UIView-KIFAdditions.h" //use some classes from the KIF framework to simulate touching/tapping the screen
#import "UIView+RecursiveFind.h" //use a handy recursive function i wrote to find subviews of a certain class type
#import "UIColor+Additions.h" //color additions to create colors from hex values
#import <UIKit/UIKit.h>
//silence warnings from the compiler
@interface T1TweetComposeViewController: UIViewController
- (void)_t1_didTapSendButton:(id)sender;
- (void)_t1_appendDroppedText:(id)arg1;
@end

@interface TFNModalSheetViewController: UIViewController
- (id)modalContentViewController;
@end

@interface TFNViewController : UIViewController
@end

@interface T1TweetComposeContainerViewController : TFNViewController
@property(retain, nonatomic) T1TweetComposeViewController *tweetComposeViewController;
@end

//ditto
@interface T1AppDelegate: NSObject
- (void)doH4x;
- (void)addH4xButton;
- (UIViewController *)rootViewController;
@end

/*
 
 using logos for hooking & swizzling, (preprocessing language that is part of theos build environment)

 FYI: AppDelegate class for the Twitter Apps lives inside the embedded framework T1Twitter.framework  

*/

%hook T1AppDelegate

//%new keyword adds a new function to T1AppDelegate, this is a conveience method to get at the rootViewController

%new - (UIViewController *)rootViewController {
    UIWindow *key = [[UIApplication sharedApplication] keyWindow];
    return [key rootViewController];
}

//add the 'h4x' button to the rootViewController (TFNPortraitScreenBoundsLockedContainerViewController)

%new - (void)addH4xButton {
    
    UIViewController *rvc = [self rootViewController]; 
    UIView *rootView = [rvc view];
    //create the button we are adding to the UI
    UIButton *button = [[UIButton alloc] init];
    button.translatesAutoresizingMaskIntoConstraints = false; //always necessary when doing autolayout
    [button setTitle:@"h4x" forState:0];
    //sizing constraints
    [button.widthAnchor constraintEqualToConstant: 60].active = true;
    [button.heightAnchor constraintEqualToConstant: 40].active = true;
    
    //add to the view before using anchors for autolayout
    [rootView addSubview:button];
    //pin to the left and the bottom of the view
    [button.leftAnchor constraintEqualToAnchor:rootView.leftAnchor constant:10].active = true;
    [button.bottomAnchor constraintEqualToAnchor:rootView.bottomAnchor constant:-70].active = true;
    //background is clear otherwise and just a floating word
    button.backgroundColor = [UIColor twitterBlue];
    //add our target
    [button addTarget:self action:@selector(doH4x) forControlEvents:UIControlEventTouchUpInside];
}

%new - (void)doH4x {
    //if this isnt in the main thread it acts weird, UI events should always be in the main thread anyways!
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rvc = [self rootViewController];
        UIView *view = [rvc.view findFirstSubviewWithClass:NSClassFromString(@"TFNFloatingActionButton")]; //this is the the compose tweet button 
        [view tap];
    });
    //wait for a few seconds for the presented view to appear before we continue.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TFNModalSheetViewController *presented = (TFNModalSheetViewController*)[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController]; //Class: TFNModalSheetViewController
        if (presented) {
            
            T1TweetComposeContainerViewController *containerViewController = [presented modalContentViewController];
            T1TweetComposeViewController *composeViewController = [containerViewController tweetComposeViewController];
            [composeViewController _t1_appendDroppedText:@"#nitoClass automated tweet testing, testing 123"];
            [composeViewController _t1_didTapSendButton:nil];
            
        }
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BOOL _orig = %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ //wait 5 seconds for the UI to show up before we add our button. kindy hacky, but gets the job done.
        [self addH4xButton];
    });
    return _orig; //return their original value.
}

%end
