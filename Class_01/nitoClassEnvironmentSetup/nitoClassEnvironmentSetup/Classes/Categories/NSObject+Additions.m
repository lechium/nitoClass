
#import "NSObject+Additions.h"
#import <objc/runtime.h>


@implementation NSData (dict)

- (NSDictionary *)safeDictionaryRepresentation {
    NSString *the_error;
    NSPropertyListFormat format;
    id plist;
    plist = [NSPropertyListSerialization propertyListFromData:self
                                             mutabilityOption:NSPropertyListImmutable
                                                       format:&format
                                             errorDescription:&the_error];
    
    if (the_error != nil) {
        NSString *rawString = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
        if (rawString == nil)
        {
            rawString = [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding];
        }
        rawString = [rawString plistSafeString];
        NSData *outData = [rawString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        plist = [NSPropertyListSerialization propertyListFromData:outData
                                                 mutabilityOption:NSPropertyListImmutable
                                                           format:&format
                                                 errorDescription:&the_error];
    }
    
    return plist;
}

@end

@implementation NSObject (Additions)


- (NSArray *)propertiesForClass:(Class)clazz {
    u_int count;
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        NSString *propName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        [propArray addObject:propName];
    }
    free(properties);
    return propArray;
}

- (NSArray *)properties {
    u_int count;
    objc_property_t* properties = class_copyPropertyList(self.class, &count);
    NSMutableArray* propArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        NSString *propName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        [propArray addObject:propName];
    }
    free(properties);
    Class sup = [self superclass];
    while (sup != nil){
        NSArray *a = [sup propertiesForClass:sup];
        [propArray addObjectsFromArray:a];
        sup = [sup superclass];
    }
    return propArray;
}

- (NSArray *)ivarsForClass:(Class)clazz {
    
    u_int count;
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    return ivarArray;
}

-(NSArray *)ivars
{
    Class clazz = [self class];
    u_int count;
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    Class sup = [self superclass];
    while (sup != nil){
        NSArray *a = [sup ivarsForClass:sup];
        [ivarArray addObjectsFromArray:a];
        sup = [sup superclass];
    }
    return ivarArray;
}

@end
