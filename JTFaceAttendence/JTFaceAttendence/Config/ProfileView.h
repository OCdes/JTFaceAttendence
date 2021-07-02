//
//  ProfileView.h
//  JTFaceAttendence
//
//  Created by lj on 2021/6/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileView : UIView

@property (nonatomic, copy) void(^didHideBlock)(void);

- (void)animation;

@end

NS_ASSUME_NONNULL_END
