

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <WebKit/WebKit.h>

@interface  WebResource  (bro)

-(id)_stringValue;
-(id)_suggestedFilename;
-(id)_response;

@end

@interface WebFrame (private)

@property(readonly, nonatomic) DOMHTMLElement *frameElement;
@property (nonatomic,readonly) DOMDocument * DOMDocument;
@property(readonly, nonatomic) WebDataSource *dataSource;
@property (nonatomic,readonly) WebDataSource * provisionalDataSource;
@property(readonly, nonatomic) NSString *name;
- (NSArray *)childFrames;
-(id)_stringByEvaluatingJavaScriptFromString:(id)arg1 ;
- (NSString *)_stringByEvaluatingJavaScriptFromString:(NSString *)string forceUserGesture:(BOOL)forceUserGesture;
-(void)loadRequest:(id)arg1 ;
-(void)reload;
-(void)loadHTMLString:(id)arg1 baseURL:(id)arg2 ;
-(void)loadData:(id)arg1 MIMEType:(id)arg2 textEncodingName:(id)arg3 baseURL:(id)arg4 ;
-(id)elementAtPoint:(CGPoint)arg1;
-(JSContext *)javaScriptContext;
-(DOMHTMLElement *)frameElement;
-(void)loadArchive:(id)arg1 ;
-(id)findFrameNamed:(id)arg1 ;
-(WebFrame *)parentFrame;
-(WebScriptObject *)windowObject;
-(id)globalContext;//OpaqueJSContextRef
-(BOOL)focusedNodeHasContent;
@end

@interface WebView (private)

-(id)_focusedFrame;

@end

