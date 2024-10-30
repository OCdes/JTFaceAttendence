//
//  JTFaceImageAttendenceManager.m
//  JTFaceAttendence
//
//  Created by lj on 2021/7/1.
//

#import "JTFaceImageAttendenceManager.h"

@implementation JTFaceImageAttendenceManager

+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static JTFaceImageAttendenceManager *manager;
    dispatch_once(&once, ^{
        manager = [[JTFaceImageAttendenceManager alloc] init];
        manager.lastEmpModel = [EmpInfoModel new];
        manager.suceessImages = [NSMutableArray array];
    });
    return manager;
}

- (void)setLastEmpModel:(EmpInfoModel *)lastEmpModel {
    _lastEmpModel = lastEmpModel;
}

- (UIImage *)lastSuccessImage {
    return _lastEmpModel.img;
}

- (void)reset{
    _lastEmpModel = [EmpInfoModel new];
    _suceessImages = [NSMutableArray array];
}

@end

@implementation EmpInfoModel



@end
