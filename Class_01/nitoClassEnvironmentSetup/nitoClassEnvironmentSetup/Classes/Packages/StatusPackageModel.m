
#import "StatusPackageModel.h"

@implementation StatusPackageModel

- (NSString *)description {
    
    NSString *orig = [super description];
    return [NSString stringWithFormat:@"%@ = %@ (%@)", orig, self.package, self.version];
}

- (NSString*) fullDescription {
    
    NSString *orig = [super description];
    NSMutableDictionary *details = [NSMutableDictionary new];
    NSArray *props = [self properties];
    [props enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *cv = [self valueForKey:obj];
        if (cv){
            details[obj] = cv;
        }
        
    }];
    return [NSString stringWithFormat:@"%@ = %@", orig, details];
    
}

+ (NSDictionary *)dependencyDictionaryFromString:(NSString *)depend
{
    NSMutableCharacterSet *whitespaceAndPunctuationSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"()"];
    [whitespaceAndPunctuationSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSScanner *stringScanner = [[NSScanner alloc] initWithString:depend];
    stringScanner.charactersToBeSkipped = whitespaceAndPunctuationSet;
    
    NSString *name = nil;
    NSInteger i = 0;
    NSMutableDictionary *predicate = [NSMutableDictionary new];
    while ([stringScanner scanUpToCharactersFromSet:whitespaceAndPunctuationSet intoString:&name]) {
        // NSLog(@"%@ pass %li", name, (long)i);
        switch (i) {
            case 0 :
                predicate[@"package"] = name;
                break;
            case 1:
                predicate[@"predicate"] = name;
                break;
            case 2:
                predicate[@"requirement"] = name;
                break;
            default:
                break;
        }
        i++;
    }
    return predicate;
}


+ (NSArray *)dependencyArrayFromString:(NSString *)depends
{
    NSMutableArray *cleanArray = [[NSMutableArray alloc] init];
    NSArray *dependsArray = [depends componentsSeparatedByString:@","];
    for (id depend in dependsArray)
    {
        NSArray *spaceDelimitedArray = [depend componentsSeparatedByString:@" "];
        if (spaceDelimitedArray.count > 1){
            NSString *isolatedDependency = [[spaceDelimitedArray objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([isolatedDependency length] == 0)
                isolatedDependency = [[spaceDelimitedArray objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSDictionary *dependDict = [self dependencyDictionaryFromString:depend];
            //DLog(@"depend dict: %@", dependDict);
            [cleanArray addObject:dependDict];
        }
       
    }
    
    return cleanArray;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"Name",
             @"package": @"Package",
             @"source": @"Source",
             @"version": @"Version",
             @"priority": @"Priority",
             @"essential": @"Essential",
             @"depends": @"Depends",
             @"maintainer": @"Maintainer",
             @"packageDescription": @"Description",
             @"homepage": @"Homepage",
             @"icon": @"Icon",
             @"author": @"Author",
             @"preDepends": @"Pre-Depends",
             @"breaks": @"Breaks",
             @"depiction": @"Depiction",
             @"tag": @"Tag",
             @"architecture": @"Architecture",
             @"section": @"Section",
             @"osMax": @"osMax",
             @"osMin": @"osMin",
             @"banner": @"Banner",
             @"topShelfImage": @"TopShelfImage"
             };
}

- (instancetype)initWithRawControlString:(NSString *)controlString
{
    NSArray *packageArray = [controlString componentsSeparatedByString:@"\n"];
    NSMutableDictionary *currentPackage = [[NSMutableDictionary alloc] init];
    for (id currentLine in packageArray)
    {
        NSArray *itemArray = [currentLine componentsSeparatedByString:@": "];
        if ([itemArray count] >= 2)
        {
            NSString *key = [itemArray objectAtIndex:0];
            NSString *object = [itemArray objectAtIndex:1];
            
            if ([key isEqualToString:@"Depends"]) //process the array
            {
                NSArray *dependsObject = [StatusPackageModel dependencyArrayFromString:object];
                
                [currentPackage setObject:dependsObject forKey:key];
                
            } else { //every other key, even if it has an array is treated as a string
                
                [currentPackage setObject:object forKey:key];
            }
        }
    }
    
    if ([[currentPackage allKeys] count] > 4)
    {
        self = [super init];
        self.rawString = controlString;
        [self mapDictionaryToProperties:currentPackage];
        return self;
    }
    return nil;
    
    
}

- (void)mapDictionaryToProperties:(NSDictionary *)theProps {
    
    NSArray *ourProps = [self properties];
    NSArray *allKeys = [theProps allKeys];
    NSDictionary *mappedKeys = [StatusPackageModel JSONKeyPathsByPropertyKey];
    [ourProps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *mappedProp = mappedKeys[obj];
        
        //DLog(@"allkeys: %@", allKeys);
        
        if ([allKeys containsObject:mappedProp]){
            if ([self respondsToSelector:NSSelectorFromString(obj)]){ //redudant
                
                id value = theProps[mappedProp];
                //DLog(@"setting value: %@ for key: %@ from mapped key: %@", value, obj, mappedProp);
                [self setValue:value forKey:obj];
                
            }
        } else {
            
            //DLog(@"%@ doesnt respond to %@", self, mappedProp);
            
        }
        
        
    }];
    
}


@end
