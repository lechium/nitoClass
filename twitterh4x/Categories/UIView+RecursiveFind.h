
#import <UIKit/UIKit.h>

@interface NSObject (convenience)

- (NSString *)appSupportFolder;
- (NSString *)downloadFolder;
@end

@interface UIView (RecursiveFind)

- (id) clone;
- (UIImage *)snapshotViewWithSize:(CGSize)size;
- (UIImage *) snapshotView;
- (UIView *)findFirstSubviewWithClass:(Class)theClass;
- (void)printRecursiveDescription;
- (void)removeAllSubviews;
- (void)printAutolayoutTrace;

@end
