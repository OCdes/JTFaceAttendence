//
//  NSString+Tool.m
//  JTFaceAttendence
//
//  Created by lj on 2021/7/1.
//

#import "NSString+Tool.h"
#import <CommonCrypto/CommonCrypto.h>
@implementation NSString (Tool)

- (NSString *)HmacSHA256WithSecretKey:(NSString *)secret {
    const char *cin = [self cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cse = [secret cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cse, strlen(cse), cin, strlen(cin), cHMAC);
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    
    for (int i = 0; i < HMACData.length; ++i)
        HMAC = [HMAC stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];
    
    return HMAC;
}

@end
