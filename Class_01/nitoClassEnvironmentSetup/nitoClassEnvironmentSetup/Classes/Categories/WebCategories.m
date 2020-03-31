
#import "WebCategories.h"

@implementation DOMDocument (nito)
- (id)inputElementOfType:(NSString *)type {
    return [self querySelector:[NSString stringWithFormat:@"[type=%@]",type]];
}
@end

@implementation DOMNodeList (nito)

- (id)firstObject {
    if ([self length] > 0){
        return [self item:0];
    }
    return nil;
}
- (id)lastObject {
    int length = [self length];
    if (length > 0){
        return [self item:length-1];
    }
    return nil;
}
- (id)allObjects {
    NSMutableArray *_new = [NSMutableArray new];
    int length = [self length];
    for (int i =0; i < length; i++){
        id item = [self item:i];
        [_new addObject:item];
    }
    return _new;
}

@end

@implementation DOMHTMLInputElement (nito)
- (BOOL)isEmpty {
    if ([[self value] respondsToSelector:@selector(length)]){
        return ([[self value] length] > 0);
    }
    return true;
}
@end

@implementation DOMHTMLCollection (nito)
- (id)firstObject {
    if ([self length] > 0){
        return [self item:0];
    }
    return nil;
}
- (id)lastObject {
    int length = [self length];
    if (length > 0){
        return [self item:length-1];
    }
    return nil;
}
- (id)allObjects {
    NSMutableArray *_new = [NSMutableArray new];
    int length = [self length];
    for (int i =0; i < length; i++){
        id item = [self item:i];
        [_new addObject:item];
    }
    return _new;
}
@end

@implementation DOMHTMLElement (nito)

- (id)inputElementOfType:(NSString *)type {
    return [self querySelector:[NSString stringWithFormat:@"[type=%@]",type]];
}

@end

@implementation DOMHTMLFormElement (nito)

-(NSArray *)tabs {
    return [[self querySelectorAll:@"[tabIndex]"] allObjects];
}


- (id)startFocusChain {
    id focused = [self focusedNode];
    if (focused != nil) return focused;
    NSArray * tabs = [self tabs];
    if (tabs.count > 0){
        [[tabs firstObject] focus];
        return [self focusedNode];
    }
    return nil;
}

- (id)tabNextFocus {
    id focused = [self focusedNode];
    if (focused == nil) return [self startFocusChain];
    NSArray * tabs = [self tabs];
    if (tabs.count > 0){
        NSInteger foundIndex = [tabs indexOfObject:focused];
        if (foundIndex != NSNotFound){
            //NSLog(@"found current index: %lu", foundIndex);
            if (foundIndex == [tabs count]){
              //  NSLog(@"at the end! starting over");
                [[tabs firstObject] focus]; //start over
                return [tabs firstObject];
            } else {
                NSInteger nextIndex = foundIndex  + 1;
                //NSLog(@"next index: %lu", nextIndex);
                id next = [tabs objectAtIndex:nextIndex];
                //NSLog(@"found next element: %@", next);
                [next focus];
                return next;
            }
        } else {
            NSLog(@"index out of bounds!");
        }
    }
    return nil;
}

- (id)inputElementOfType:(NSString *)type {
    return [self querySelector:[NSString stringWithFormat:@"[type=%@]",type]];
}

- (id)emailElement {
    return [self inputElementOfType:@"email"];
}

- (id)passwordElement {
    return [self inputElementOfType:@"password"];
}

- (id)elementNamed:(id)name {
    return [self elementNamed:name fuzzy:false];
}

- (id)elementNamed:(id)name fuzzy:(BOOL)fuzzy {
    
    NSString *query = [NSString stringWithFormat:@"[name=%@]",name];
    if (fuzzy){
        query = [NSString stringWithFormat:@"[name*=%@]",name];
    }
    return query;
}



- (void)clearInvalidInputs {
    NSArray <DOMHTMLInputElement *> *invalids = [self invalidInputs];
    [invalids enumerateObjectsUsingBlock:^(DOMHTMLInputElement *obj, NSUInteger idx, BOOL * stop) {
        [obj setValue:@""];
    }];
}

- (id)focusFirstEmptyInput {
    id object = [[self emptyInputs] firstObject];
    if (object != nil){
        [object focus];
        return object;
    }
    return nil;
}

- (NSArray <DOMHTMLInputElement *>*)invalidInputs {
    return [[self querySelectorAll:@"input:invalid"] allObjects];
}
- (id)focusedNode {
    return [self querySelector:@"input:focus"];
}
- (id)emptyInputs {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.value.length == 0 && self._isTextField == true"];
    return [[[self visibleElements] allObjects] filteredArrayUsingPredicate:pred];
}
- (BOOL)hasEmptyInputs {
    return ( [[self emptyInputs] count] > 0);
}
- (id)visibleElements {
    return [self querySelectorAll:@"input:not([type=hidden])"];
}
- (int)currentTabIndex {
    return [[self focusedNode] tabIndex];
}

- (BOOL)elementWithIdExists:(NSString *)elementID {
    if ([self querySelectorWithFormat:"#%s", [elementID UTF8String]]){
        return true;
    }
    return false;
}

@end

@implementation DOMNamedNodeMap (nito)

- (id)dictionaryRepresentation {
    NSArray <DOMAttr*>*all = [self allObjects];
    __block NSMutableDictionary *_dict = [NSMutableDictionary new];
    [all enumerateObjectsUsingBlock:^(DOMAttr *obj, NSUInteger idx, BOOL * stop) {
        
        NSString *name = [obj name];
        id value = [obj value];
        if (name.length > 0 && value){
            
            [_dict setObject:value forKey:name];
        }
        
    }];
    return _dict;
}

- (id)firstObject {
    if ([self length] > 0){
        return [self item:0];
    }
    return nil;
}
- (id)lastObject {
    int length = [self length];
    if (length > 0){
        return [self item:length-1];
    }
    return nil;
}
- (id)allObjects {
    NSMutableArray *_new = [NSMutableArray new];
    int length = [self length];
    for (int i =0; i < length; i++){
        id item = [self item:i];
        [_new addObject:item];
    }
    return _new;
}
@end

@implementation DOMElement (nito)

- (id)elementWithDataId:(NSString *)dataID {
    return [self querySelectorWithFormat:"*[data-testid=%s]", [dataID UTF8String]];
}

- (NSArray *)elementsWithName:(NSString *)name {
    return [[self querySelectorAllWithFormat:"#%s", [name UTF8String]] allObjects];
}

- (id)elementWithId:(NSString *)elementID {
    return [self querySelectorWithFormat:"#%s", [elementID UTF8String]];
}

- (id)data_testid {
    return [(DOMAttr*)[[self attributes] getNamedItem:@"data-testid"] value];
}

- (id)rawValueForAttribute:(id)attribute {
    return [(DOMAttr*)[[self attributes] getNamedItem:attribute] value];
}
- (BOOL)hasAttributeNamed:(NSString *)name {
    id item = [[self attributes] getNamedItem:name];
    if (item) return true;
    return false;
}

+ (NSString *)myStringWithFormat:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    va_end(args);
    return [[NSString alloc] initWithFormat:fmt arguments:args];
}

- (id) querySelectorWithFormat:(const char*) fmt,... {
    va_list args;
    char temp[2048];
    va_start(args, fmt);
    vsprintf(temp, fmt, args);
    va_end(args);
    return [self querySelector:[[NSString alloc] initWithUTF8String:temp]];
}


- (id)querySelectorAllWithFormat:(const char*)fmt, ... {
    va_list args;
    char temp[2048];
    va_start(args, fmt);
    vsprintf(temp, fmt, args);
    va_end(args);
    return [self querySelectorAll:[[NSString alloc] initWithUTF8String:temp]];
}


- (BOOL)elementWithIdExists:(NSString *)elementID {
    if ([self querySelectorWithFormat:"#%s", [elementID UTF8String]]){
        return true;
    }
    return false;
}


@end
