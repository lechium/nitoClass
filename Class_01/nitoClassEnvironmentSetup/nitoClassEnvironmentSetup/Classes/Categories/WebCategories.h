
#import <WebKit/WebKit.h>

#import "WebPrivate.h"

@interface DOMHTMLCollection (nito)
- (id)firstObject;
- (id)lastObject;
- (id)allObjects;
@end

@interface DOMNodeList (nito)
- (id)firstObject;
- (id)lastObject;
- (id)allObjects;
@end

@interface DOMHTMLInputElement (nito)
- (BOOL)isEmpty;
@end

@interface DOMNamedNodeMap (nito)
- (id)firstObject;
- (id)lastObject;
- (id)allObjects;
- (id)dictionaryRepresentation;
@end

@interface DOMHTMLFormElement (nito)
- (id)emailElement;
- (id)passwordElement;
- (id)focusedNode;
- (BOOL)hasEmptyInputs;
- (id)emptyInputs;
- (id)visibleElements;
- (id)invalidInputs;
- (id)elementNamed:(id)name;
- (id)elementNamed:(id)name fuzzy:(BOOL)fuzzy;
- (id)inputElementOfType:(NSString *)type;
- (void)clearInvalidInputs;
- (id)tabNextFocus;
- (int)currentTabIndex;
- (id)tabs;
- (BOOL)elementWithIdExists:(NSString *)elementID;
@end

@interface DOMDocument (nito)
- (id)inputElementOfType:(NSString *)type;
@end

@interface DOMHTMLElement (nito)
- (id)inputElementOfType:(NSString *)type;
@end

@interface DOMElement (nito)
- (id)elementWithDataId:(NSString *)dataID;
- (NSArray *)elementsWithName:(NSString *)name;
- (id)elementWithId:(NSString *)elementID;
- (NSString *)data_testid; //returns data-testid if applicable
- (id)rawValueForAttribute:(id)attribute;
- (BOOL)hasAttributeNamed:(NSString *)name;
- (NSString *)myStringWithFormat:(NSString *)fmt, ...;
- (id)querySelectorWithFormat:(const char*) fmt,...;
- (id)querySelectorAllWithFormat:(const char*)fmt, ...;
- (BOOL)elementWithIdExists:(NSString *)elementID;
- (DOMDocument *)ownerDocument;
- (DOMNodeList *)childNodes;
- (DOMNode *)lastChild;
- (DOMNode *)firstChild;
- (id)startPosition;
- (BOOL)isContentEditable;
- (DOMNode *)parentNode;
- (void)hidePlaceholder;
- (CGRect)boundingBoxUsingTransforms;
- (void)showPlaceholderIfNecessary;
- (DOMNode *)previousSibling;
- (id)removeChild:(id)arg1 ;
//- (WKQuad)innerFrameQuad;
- (CGRect)boundingBox;
- (id)endPosition;
- (void)getPreviewSnapshotImage:(id)arg1 andRects:(id*)arg2 ;
@end
