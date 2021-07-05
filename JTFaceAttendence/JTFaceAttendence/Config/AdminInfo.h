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

@property (nonatomic, strong) NSString *placeKey, *placeName;

+ (AdminInfo *)shareInfo;

@end

NS_ASSUME_NONNULL_END
