
@interface NSData (dict)
- (NSDictionary *)safeDictionaryRepresentation;
@end

@interface NSObject (Additions)

-(NSArray *)ivars;
-(NSArray *)properties;
- (NSArray *)ivarsForClass:(Class)clazz;
- (NSArray *)propertiesForClass:(Class)clazz;
@end
