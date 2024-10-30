//
//  ConfigManager.h
//  JTFaceAttendence
//
//  Created by lj on 2021/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigManager : NSObject

+ (instancetype)manager;

- (void)registerSDK;

- (void)initConfig;

@end

NS_ASSUME_NONNULL_END
