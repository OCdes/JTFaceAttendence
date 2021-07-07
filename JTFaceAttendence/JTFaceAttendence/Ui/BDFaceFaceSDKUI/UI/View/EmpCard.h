//
//  EmpCard.h
//  JTFaceAttendence
//
//  Created by lj on 2021/7/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class EmpInfoModel;
@interface EmpCard : UIView

- (instancetype)initWithEmpModel:(EmpInfoModel *)mo;

- (void)animationToPoint:(CGPoint)targetPoint;

@end

NS_ASSUME_NONNULL_END
