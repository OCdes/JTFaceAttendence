//
//  AdminInfo.m
//  JTFaceAttendence
//
//  Created by lj on 2021/6/29.
//

#import "AdminInfo.h"
static AdminInfo *_instance = nil;
@implementation AdminInfo

- (NSString *)token {
    return [USER_DEFAULTS objectForKey:@"adminToken"];
}

- (void)setToken:(NSString *)token {
    [USER_DEFAULTS setObject:token forKey:@"adminToken"];
}

- (NSString *)emp_name {
    return [USER_DEFAULTS objectForKey:@"emp_name"];
}

- (void)setEmp_name:(NSString *)emp_name {
    [USER_DEFAULTS setObject:emp_name forKey:@"emp_name"];
}

- (NSString *)emp_position {
    return  [USER_DEFAULTS objectForKey:@"emp_position"];
}

- (void)setEmp_position:(NSString *)emp_position {
    [USER_DEFAULTS setObject:emp_position forKey:@"emp_position"];
}

- (NSString *)emp_department {
    return [USER_DEFAULTS objectForKey:@"emp_department"];
}

- (void)setEmp_department:(NSString *)emp_department {
    [USER_DEFAULTS setObject:emp_department forKey:@"emp_department"];
}

- (NSString *)avatarUrl {
    return [USER_DEFAULTS objectForKey:@"avatarUrl"];
}

- (void)setAvatarUrl:(NSString *)avatarUrl {
    [USER_DEFAULTS setObject:avatarUrl forKey:@"avatarUrl"];
}

- (void)setPlaceKey:(NSString *)placeKey {
    [USER_DEFAULTS setObject:placeKey ? placeKey : @"" forKey:@"placeKey"];
}

- (NSString *)placeKey {
    return [USER_DEFAULTS objectForKey:@"placeKey"];
}

- (void)setPlaceName:(NSString *)placeName {
    [USER_DEFAULTS setObject:placeName ? placeName : @"" forKey:@"placeName"];
}

- (NSString *)placeName {
    return [USER_DEFAULTS objectForKey:@"placeName"];
}

+ (AdminInfo *)shareInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[AdminInfo alloc] init];
        }
    });
    return _instance;
}

@end
