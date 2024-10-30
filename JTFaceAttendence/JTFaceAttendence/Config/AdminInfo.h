//
//  AdminInfo.h
//  JTFaceAttendence
//
//  Created by lj on 2021/6/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdminInfo : NSObject

@property (nonatomic, strong) NSString *token;

@property (nonatomic, strong) NSString *avatarUrl;

@property (nonatomic, strong) NSString *emp_name, *emp_position, *emp_department;

@property (nonatomic, assign) BOOL hasAgree;

@property (nonatomic, strong) NSString *placeKey, *placeName;

@property (nonatomic, strong) NSString *adapterAppID, *enableLiveness;//adapterAppID 1->娱汇  3->娱通



+ (AdminInfo *)shareInfo;

@end

NS_ASSUME_NONNULL_END
