#import "WebFrame+Nito.h"
#import <JavaScriptCore/JavaScriptCore.h>
#define PRINT_DEBUG_LOGS 1
@implementation WebFrame (nito)

- (NSString *)provisionalResourceString {
    
    WebResource * wr = [[self provisionalDataSource] mainResource];
    return [wr _stringValue];
}

- (NSString *)mainResourceString {
    
    WebResource * wr = [[self dataSource] mainResource];
    return [wr _stringValue];
}

- (BOOL)elementWithIDExists:(NSString *)elementID {
    NSString *jsString = [NSString stringWithFormat:@"document.getElementById(\"%@\").type;",elementID];
    NSString *returnString = [self _stringByEvaluatingJavaScriptFromString:jsString];
    //NSLog(@"elementWithIDExists: %@", returnString);
    if (returnString.length > 0)
    {
        return true;
    }
    return false;
}


#pragma mark transplants

- (id)valueForElementWithID:(NSString *)elementID {
    NSString *type = [self _stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById(\"%@\").type;",elementID]];
    NSString *jsString = [NSString stringWithFormat:@"document.getElementById(\"%@\").value;",elementID];
    if ([type isEqualToString:@"checkbox"]){
        jsString = [NSString stringWithFormat:@"document.getElementById(\"%@\").checked;",elementID];
    }
    return [self _stringByEvaluatingJavaScriptFromString:jsString];
}
- (id)valueForFirstElementNamed:(NSString *)elementName {
    NSString *type = [self _stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByName(\"%@\")[0].type;",elementName]];
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByName(\"%@\")[0].value;",elementName];
    if ([type isEqualToString:@"checkbox"]){
        jsString = [NSString stringWithFormat:@"document.getElementsByName(\"%@\")[0].checked;",elementName];
    }
    return [self _stringByEvaluatingJavaScriptFromString:jsString];
}

- (id)valueForElementWithClassName:(NSString *)elementName {
    NSString *type = [self _stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName(\"%@\")[0].type;",
                                                                   elementName]];
    NSString *javaScript = [NSString stringWithFormat:@"document.getElementsByClassName(\"%@\")[0].value;",
                            elementName];
    if ([type isEqualToString:@"checkbox"]){
        javaScript = [NSString stringWithFormat:@"document.getElementsByClassName(\"%@\")[0].checked;",elementName];
    }
    return [self _stringByEvaluatingJavaScriptFromString:javaScript];
}

- (void)executeJSOnMainThread:(NSString *)js {
    
    if (![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _stringByEvaluatingJavaScriptFromString:js];
        });
    } else {
        [self _stringByEvaluatingJavaScriptFromString:js];
    }
    
}


- (NSString *)valueForFirstTagName:(NSString *)tagName {
    
    NSString *javaScript = [NSString stringWithFormat:@"document.getElementsByTagName(\"%@\")[0].value;",
                            tagName];
    return [self _stringByEvaluatingJavaScriptFromString:javaScript];
}


- (NSString *)_innerHTML {
    return [self _stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML;"];
}

- (NSString *)valueForFuzzyElementID:(NSString *)elementID {
    return [self _stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var neededElements = [].filter.call(document.getElementsByTagName('input'), el => el.getAttribute(\"id\").indexOf('%@') >= 0); neededElements[0].value;", elementID]];
}

- (WebFrame *)findFirstFrameRunningItemCountJS:(NSString *)js {

    JSContext *jsc = [self javaScriptContext];
    JSValue *value = [jsc evaluateScript:js];
    if ([value toInt32] >= 1){
        return self;
    }
    for (WebFrame *v in self.childFrames) {
        WebFrame *theFrame = [v findFirstFrameRunningItemCountJS:js];
        if (theFrame != nil) {
            return theFrame;
        }
    }
    return nil;
}

- (void)waitForInputElementOfType:(NSString *)type completion:(void(^)(BOOL found))block {
    
    __block NSTimeInterval timeout = 10.0;
    __block BOOL expired = false;
    __block BOOL _found = false;
    __block NSDate *referenceDate = [NSDate date];
    __block BOOL _finished = false;
    __block NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:true block:^(NSTimer * _Nonnull timer) {
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:referenceDate];
        //NSLog(@"timer block: %f", interval);
        NSString *string = [self _stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var neededElements = [].filter.call(document.getElementsByTagName('input'), el => el.getAttribute(\"type\").indexOf('%@') >= 0); neededElements[0].getAttribute(\"id\");", type]];
        
        _found = (string.length > 0);
        if (_found){
            _finished = true;
        }
        if (interval > timeout){
            expired = true;
            _finished = true;
        }
        
        if (_finished == true){
            [timer invalidate];
            timer = nil;
            if (block){
                block(_found);
            }
        }
        
    }];
}

- (BOOL)elementWithSelectorExists:(NSString *)selector {
    
    NSString *fullSelector = [selector stringByAppendingPathExtension:@"nodeName;"];
    NSString *jsReturnValue = [self _stringByEvaluatingJavaScriptFromString:fullSelector];
    NSLog(@"elementWithSelectorExists: %@ returns: %@",selector, jsReturnValue);
    return (jsReturnValue > 0);
}

- (void)waitForElementWithSelector:(NSString *)selector timeout:(NSInteger)timeout completion:(void(^)(BOOL found))block {
    __block BOOL expired = false;
    __block BOOL _found = false;
    __block NSDate *referenceDate = [NSDate date];
    __block BOOL _finished = false;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:true block:^(NSTimer * _Nonnull timer) {
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:referenceDate];
        //NSLog(@"timer block: %f", interval);
        
        _found = [self elementWithSelectorExists:selector];
        if (_found){
            //NSLog(@"GOT IM!!!");
            _finished = true;
        }
        if ([referenceDate timeIntervalSinceNow ] > timeout){
            expired = true;
            //NSLog(@"EXPIRED!!!");
            _finished = true;
        }
        
        if (_finished == true){
            [timer invalidate];
            timer = nil;
            if (block){
                block(_found);
            }
        }
        
    }];
    
}

- (void)waitForElementWithID:(NSString *)elementID completion:(void(^)(BOOL found))block {
    __block NSInteger timeout = 10;
    __block BOOL expired = false;
    __block BOOL _found = false;
    __block NSDate *referenceDate = [NSDate date];
    __block BOOL _finished = false;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:true block:^(NSTimer * _Nonnull timer) {
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:referenceDate];
        //NSLog(@"timer block: %f", interval);
        
        _found = [self elementWithIDExists:elementID];
        if (_found){
            //NSLog(@"GOT IM!!!");
            _finished = true;
        }
        if ([referenceDate timeIntervalSinceNow ] > timeout){
            expired = true;
            //NSLog(@"EXPIRED!!!");
            _finished = true;
        }
        
        if (_finished == true){
            [timer invalidate];
            timer = nil;
            if (block){
                block(_found);
            }
        }
        
    }];
    
}

- (BOOL)elementWithNameExists:(NSString *)elementID {
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByName(\"%@\").type;",elementID];
    NSString *returnString = [self _stringByEvaluatingJavaScriptFromString:jsString];
    if (returnString.length > 0) {
        return true;
    }
    return false;
}



- (void)clickElementWithID:(NSString *)elementID {
    NSString *jsString = [NSString stringWithFormat:@"document.getElementById(\"%@\").click();",elementID];
    if(PRINT_DEBUG_LOGS) {
        NSLog(@"[DEBUG] clickElementWithID: %@", elementID);
    }
    [self executeJSOnMainThread:jsString];
}

- (void)clickElementWithName:(NSString *)elementName {
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByName(\"%@\").click();",elementName];
    if(PRINT_DEBUG_LOGS) {
        NSLog(@"[DEBUG] clickElementWithName: %@", elementName);
    }
    [self executeJSOnMainThread:jsString];
    
}

- (void)submitOnElementWithName:(NSString *)name {
    
    NSString *jsString = [NSString stringWithFormat:@"var button = document.getElementsByName(\"%@\")[0]; button.form.submit(); ",name];
    if(PRINT_DEBUG_LOGS) {
        NSLog(@"[DEBUG] submitOnElementWithName: %@", name);
    }
    [self executeJSOnMainThread:jsString];
}


- (void)clickButtonWithClassName:(NSString *)className {
    if(PRINT_DEBUG_LOGS) {
        NSLog(@"[DEBUG] clickButtonWithClassName: %@", className);
    }
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByClassName(\"%@\")[0].click();",className];
    [self executeJSOnMainThread:jsString];
}


- (void)clickSubmit { //amazon?
    NSString *javaScript = [NSString stringWithFormat:@"document.getElementsByClassName(\"%@\")[0].click();",@"button-text signin-button-text"];
    [self executeJSOnMainThread:javaScript];
}

#pragma mark Enter text

- (void)enterText:(NSString *)text infoFieldContainingClassNameString:(NSString *)string {
    NSString *javaScript = [NSString stringWithFormat:@"var textField = document.getElementsByClassName(\"%@\")[0];"
                            "textField.value = '%@';",
                            string, text];
    [self executeJSOnMainThread:javaScript];
}

- (void)enterText:(NSString *)text infoFieldWithName:(NSString *)fieldName {
    
    if (text.length == 0){
        NSLog(@"[WARNING] Attempting to enter empty text into fieldName: %@", fieldName);
        return;
    }
    NSString *javaScript = [NSString stringWithFormat:@"var textField = document.getElementsByName(\"%@\")[0];"
                            "textField.value = '%@';",
                            fieldName, text];
    [self executeJSOnMainThread:javaScript];
}

- (void)enterText:(NSString *)text infoFieldWithID:(NSString *)fieldID {
    
    if (text.length == 0){
        NSLog(@"[WARNING] Attempting to enter empty text into fieldID: %@", fieldID);
        return;
    }
    
    NSString *javaScript = [NSString stringWithFormat:@"var textField = document.getElementById(\"%@\");"
                            "textField.value = '%@';",
                            fieldID, text];
    [self executeJSOnMainThread:javaScript];
    
}

@end

