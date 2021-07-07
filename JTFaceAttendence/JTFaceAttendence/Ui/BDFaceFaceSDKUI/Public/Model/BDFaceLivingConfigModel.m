//
//  BDFaceLivingConfigModel.m
//  FaceSDKSample_IOS
//
//  Created by 阿凡树 on 2017/5/23.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BDFaceLivingConfigModel.h"
@interface BDFaceLivingConfigModel ()

@end
@implementation BDFaceLivingConfigModel

- (instancetype)init {
    if (self = [super init]) {
        _liveActionArray = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static BDFaceLivingConfigModel *_model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _model=[[BDFaceLivingConfigModel alloc] init];
        NSArray *arr = [USER_DEFAULTS arrayForKey:@"_liveActionArray"] ? [USER_DEFAULTS arrayForKey:@"_liveActionArray"] : @[];
        BOOL b = [[USER_DEFAULTS objectForKey:@"isByOrder"] boolValue];
        NSInteger num = [[USER_DEFAULTS objectForKey:@"_numOfLiveness"] integerValue];
        _model.liveActionArray = [NSMutableArray arrayWithArray:arr];
        _model.isByOrder = b;
        _model.numOfLiveness = num;
    });
    return _model;
}


- (void)persistanceState {
    [USER_DEFAULTS setObject:_liveActionArray forKey:@"_liveActionArray"];
    [USER_DEFAULTS setObject:@(_isByOrder) forKey:@"isByOrder"];
    [USER_DEFAULTS setObject:@(_numOfLiveness) forKey:@"_numOfLiveness"];
}

- (void)resetState {
    [_liveActionArray removeAllObjects];
    _isByOrder = false;
    _numOfLiveness = 0;
}

@end
