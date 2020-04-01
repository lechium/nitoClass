//
//  NSData+Flip.h
//  tetherKit
//
//  Created by Kevin Bradley on 1/26/12.
//  Copyright 2012 FireCore, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (myAdditions)
- (NSString *)stringFromHexData;
- (NSData *)byteFlipped;
+ (NSData *)dataFromStringHex:(NSString *)command;
- (NSData *)reverse;
- (NSString *)decimalString;
+ (NSData *)littleEndianHexFromInt:(NSUInteger)inputNumber;
@end


