//
//  AudioManager.h
//  JTFaceAttendence
//
//  Created by lj on 2021/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioManager : NSObject

+ (instancetype)shareInstance;

- (void)playWord:(NSString *)content;

- (void)attendenceFailuer;

- (void)attendenceSuccess;

@end

NS_ASSUME_NONNULL_END
