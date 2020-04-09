#import "UIView-KIFAdditions.h"
#import "UIView+RecursiveFind.h"
#import "UIColor+Additions.h"

@interface T1TweetComposeViewController: UIViewController
- (void)_t1_didTapSendButton:(id)sender;
@end

@interface T1AppDelegate: NSObject
- (void)doH4x;
- (void)addH4xButton;
- (UIViewController *)rootViewController;
@end

%hook T1AppDelegate

%new - (UIViewController *)rootViewController {
    UIWindow *key = [[UIApplication sharedApplication] keyWindow];
    return [key rootViewController];
}

%new - (void)addH4xButton {
    
    UIViewController *rvc = [self rootViewController];
    UIView *rootView = [rvc view];
    UIButton *button = [[UIButton alloc] init];
    button.translatesAutoresizingMaskIntoConstraints = false;
    [button setTitle:@"h4x" forState:0];
    [button.widthAnchor constraintEqualToConstant: 60].active = true;
    [button.heightAnchor constraintEqualToConstant: 40].active = true;
    [rootView addSubview:button];
    [button.leftAnchor constraintEqualToAnchor:rootView.leftAnchor constant:10].active = true;
    [button.bottomAnchor constraintEqualToAnchor:rootView.bottomAnchor constant:-70].active = true;
    button.backgroundColor = [UIColor twitterBlue];
    [button addTarget:self action:@selector(doH4x) forControlEvents:UIControlEventTouchUpInside];
}


%new - (void)doH4x {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rvc = [self rootViewController];
        UIView *view = [rvc.view findFirstSubviewWithClass:NSClassFromString(@"TFNFloatingActionButton")];
        [view tap];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *presented = [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController]; //TFNModalSheetViewController
        if (presented) {
            UINavigationController *navController = [[[[presented childViewControllers] lastObject] childViewControllers] lastObject]; //TFNNavigationController
            T1TweetComposeViewController *visible = (T1TweetComposeViewController *)[navController visibleViewController]; //T1TweetComposeViewController
            UITextView *compose  = (UITextView*)[visible.view findFirstSubviewWithClass: NSClassFromString(@"T1ComposeTextView")];
            id <UITextViewDelegate> delegate = [compose delegate]; //T1TweetComposeSingleTweetViewController
            [compose setText:@"testing testing 123"];
            [delegate textViewDidChange:compose];
            id sendButton = [visible valueForKey:@"sendButton"];
            [visible _t1_didTapSendButton:sendButton];
            
        }
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    %log;
    BOOL _orig = %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addH4xButton];
    });
    return _orig;
}

%end
