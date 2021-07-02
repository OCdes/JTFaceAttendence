//
//  AppKeyChain.h
//  JingTeYuHui
//
//  Created by LJ on 2018/8/6.
//  Copyright © 2018年 WanCai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppKeyChain : NSObject

+ (void)saveData:(id)data toKeyChainWithKey:(NSString *)key;

+ (id)getDataWithKey:(NSString *)key;

+ (void)deletDataWithKey:(NSString *)key;

@end
