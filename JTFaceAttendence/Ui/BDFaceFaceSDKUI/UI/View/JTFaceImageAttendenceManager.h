//
//  JTFaceImageAttendenceManager.h
//  JTFaceAttendence
//
//  Created by lj on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class EmpInfoModel;
@interface JTFaceImageAttendenceManager : NSObject

@property (nonatomic, readonly) UIImage *lastSuccessImage;

@property (nonatomic, strong) EmpInfoModel *lastEmpModel;

@property (nonatomic, strong) NSMutableArray *suceessImages;

+ (instancetype)sharedInstance;

- (UIImage *)getSuccessImage;


- (void) reset;

@end

@interface EmpInfoModel : NSObject

@property (nonatomic, strong) NSString *empPhoto, *empAvatar, *dutyName, *empDepartmentName, *empName, *empPosition;

@property (nonatomic, strong) UIImage *img;

@end

NS_ASSUME_NONNULL_END
