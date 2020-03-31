#import "WebPrivate.h"

#import <WebKit/WebKit.h>

@interface WebFrame (nito)
- (void)waitForElementWithSelector:(NSString *)selector timeout:(NSInteger)timeout completion:(void(^)(BOOL found))block;
- (BOOL)elementWithSelectorExists:(NSString *)selector;
- (WebFrame *)findFirstFrameRunningItemCountJS:(NSString *)js;
- (NSString *)provisionalResourceString;
- (NSString *)mainResourceString;
- (void)executeJSOnMainThread:(NSString *)js;
- (void)clickSubmit;
- (void)clickButtonWithClassName:(NSString *)className;
- (void)submitOnElementWithName:(NSString *)name;
- (void)clickElementWithName:(NSString *)elementName;
- (void)clickElementWithID:(NSString *)elementID;
- (BOOL)elementWithNameExists:(NSString *)elementID;
- (BOOL)elementWithIDExists:(NSString *)elementID;
- (void)enterText:(NSString *)text infoFieldWithID:(NSString *)fieldID;
- (void)enterText:(NSString *)text infoFieldWithName:(NSString *)fieldID;
- (void)enterText:(NSString *)text infoFieldContainingClassNameString:(NSString *)string;
- (id)valueForElementWithID:(NSString *)elementID;
- (id)valueForFirstElementNamed:(NSString *)elementName;
- (id)valueForElementWithClassName:(NSString *)elementName;
- (void)waitForElementWithID:(NSString *)elementID completion:(void(^)(BOOL found))block;
- (void)waitForInputElementOfType:(NSString *)type completion:(void(^)(BOOL found))block;
- (NSString *)valueForFirstTagName:(NSString *)tagName;
- (NSString *)valueForFuzzyElementID:(NSString *)elementID;
- (NSString *)_innerHTML;
@end


