//
//  NSData+Crypto.m
//  YTDecryptDeviceKey
//
//  Created by Max Weisel on 10/2/12.
//  Copyright (c) 2012 Max Weisel. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSData+Base64.h"

#ifndef __COMMONCRYPTO_PUBLIC__
#define __COMMONCRYPTO_PUBLIC__

#include "CommonCrypto/CommonCryptor.h"
#include "CommonCrypto/CommonDigest.h"
#include "CommonCrypto/CommonHMAC.h"
//#include <CommonCrypto/CommonKeyDerivation.h>
//#include <CommonCrypto/CommonSymmetricKeywrap.h>

#endif


@implementation NSData (Crypto)

+ (NSData *)decryptDeviceKey:(NSString *)deviceKeyBase64 {
    NSData *deviceKey = [NSData dataFromBase64String:deviceKeyBase64];
    NSData *secret = [NSData dataFromBase64String:@"ngLJVgMq08XSkJIfMwrilw=="];
    return [deviceKey AES128DecryptWithKey:secret];
}

- (NSData *)AES128DecryptWithKey:(NSData *)key {
    // 'key' should be 16 bytes for AES128, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    unsigned long keyLength = [key length];
    if (keyLength > kCCKeySizeAES128) {
        NSLog(@"Key is too long: %i", keyLength);
        return nil;
    }
    memcpy(keyPtr, [key bytes], keyLength);
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = keyLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
        
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(1,
                                          0,
                                          3,
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], [self length], /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    NSLog(@"Decrypt failed with error code %d", cryptStatus);
    free(buffer); // free the buffer;
    return nil;
}

- (NSData *)SHA1HmacWithKey:(NSData *)key {
    unsigned char Hmac[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, [key bytes], [key length], [self bytes], [self length], Hmac);
    return [NSData dataWithBytes:Hmac length:CC_SHA1_DIGEST_LENGTH];
}

@end
