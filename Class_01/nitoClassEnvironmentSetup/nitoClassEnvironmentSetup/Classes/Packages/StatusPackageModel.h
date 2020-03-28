
//that packages inside the status folder

@interface StatusPackageModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *package;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *priority;
@property (nonatomic, copy) NSString *essential;
@property (nonatomic, copy) NSArray *depends;
@property (nonatomic, copy) NSString *maintainer;
@property (nonatomic, copy) NSString *packageDescription; //cant be description, that is reservered
@property (nonatomic, copy) NSString *homepage;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *depiction;
@property (nonatomic, copy) NSString *preDepends;
@property (nonatomic, copy) NSString *breaks;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *architecture;
@property (nonatomic, copy) NSString *section;
@property (nonatomic, copy) NSString *rawString;


- (instancetype)initWithRawControlString:(NSString *)controlString;


@end
