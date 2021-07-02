//
//  NSString+Tool.h
//  JTFaceAttendence
//
//  Created by lj on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Tool)

- (NSString *)HmacSHA256WithSecretKey:(NSString *)secret;

@end

NS_ASSUME_NONNULL_END
