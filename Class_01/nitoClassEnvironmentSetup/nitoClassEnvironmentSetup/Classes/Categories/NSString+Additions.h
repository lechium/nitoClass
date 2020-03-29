
@interface NSNumber (NumberFormatting)
-(NSString*) suffixNumber;
@end;

@interface NSString (Additions)

- (void)writeToFileWithoutAttributes:(NSString *)theFile;
- (NSString *)nextVersionNumber;
-(NSString*) suffixNumber;
@end
