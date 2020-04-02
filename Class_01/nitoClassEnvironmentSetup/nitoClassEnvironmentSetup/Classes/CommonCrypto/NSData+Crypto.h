//
//  NSData+Crypto.h
//  YTDecryptDeviceKey
//
//  Created by Max Weisel on 10/2/12.
//  Copyright (c) 2012 Max Weisel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Crypto)

- (NSData *)decryptDeviceKey:(NSString *)deviceKeyBase64;
- (NSData *)AES128DecryptWithKey:(NSData *)key;
- (NSData *)SHA1HmacWithKey:(NSData *)key;

@end
