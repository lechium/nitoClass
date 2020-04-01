
@interface NSNumber (NumberFormatting)

- (NSString*) suffixNumber;

@end;

@interface NSString (Additions)
- (id)dictionaryRepresentation;
- (void)writeToFileWithoutAttributes:(NSString *)theFile;
- (NSString *)nextVersionNumber;
- (NSString*) suffixNumber;
- (NSString *)plistSafeString;
- (NSString *)TIMEFormat ;
@end
