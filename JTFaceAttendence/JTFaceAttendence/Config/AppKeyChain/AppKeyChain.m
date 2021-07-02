//
//  AppKeyChain.m
//  JingTeYuHui
//
//  Created by LJ on 2018/8/6.
//  Copyright © 2018年 WanCai. All rights reserved.
//

#import "AppKeyChain.h"

@implementation AppKeyChain

+ (NSMutableDictionary *)getKeyChainWithKey:(NSString *)key {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword,(id)kSecClass,key, (id)kSecAttrService,key, (id)kSecAttrAccount,(id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible, nil];
}

+ (void)saveData:(id)data toKeyChainWithKey:(NSString *)key {
    NSMutableDictionary *dict = [self getKeyChainWithKey:key];
    SecItemDelete((CFDictionaryRef)dict);
    [dict setValue:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)dict, NULL);
}

+ (id)getDataWithKey:(NSString *)key {
    id ret = nil;
    NSMutableDictionary *dict = [self getKeyChainWithKey:key];
    [dict setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [dict setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)dict, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"存储失败");
        } @finally {
            
        }
    }
    if (keyData) {
        CFRelease(keyData);
    }
    return ret;
}

+ (void)deletDataWithKey:(NSString *)key {
    NSMutableDictionary *dict = [self getKeyChainWithKey:key];
    SecItemDelete((CFDictionaryRef)dict);
}

@end
