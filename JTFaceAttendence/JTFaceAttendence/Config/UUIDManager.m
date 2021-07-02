
//
//  UUIDManager.m
//  JingTeYuHui
//
//  Created by LJ on 2018/8/6.
//  Copyright © 2018年 WanCai. All rights reserved.
//

#import "UUIDManager.h"
#import "AppKeyChain.h"
@implementation UUIDManager

+ (NSString *)getUUID {
    NSString *strUUID = [AppKeyChain getDataWithKey:@"jtuuid"];
    if ([strUUID isEqualToString:@""] || !strUUID) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
        [AppKeyChain saveData:strUUID toKeyChainWithKey:@"jtuuid"];
    }
    return strUUID;
}

@end
