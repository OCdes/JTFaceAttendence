//
//  AttendenceViewModel.h
//  JTFaceAttendence
//
//  Created by lj on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AttendenceViewModel : NSObject

@property (nonatomic, strong) RACSubject *suceessSubject, *failureSubject, *udpSubject;

- (void)requestAttendence;

@end

NS_ASSUME_NONNULL_END
