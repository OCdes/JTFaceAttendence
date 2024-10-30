//
//  LivenessVedioCheckVC.h
//  JTFaceAttendence
//
//  Created by 袁炳生 on 2024/10/29.
//

#import "BDFaceBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LivenessVedioCheckVC : BDFaceBaseViewController

- (void)livenesswithList:(NSArray *)livenessArray order:(BOOL)order numberOfLiveness:(NSInteger)numberOfLiveness;

@end

NS_ASSUME_NONNULL_END
