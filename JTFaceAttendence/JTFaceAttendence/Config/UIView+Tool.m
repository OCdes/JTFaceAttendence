//
//  UIView+Tool.m
//  JTFaceAttendence
//
//  Created by lj on 2021/7/2.
//

#import "UIView+Tool.h"

@implementation UIView (Tool)

- (void)gradualChangeColorViewWithColors:(NSArray *)arr {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    NSMutableArray *newColors = [NSMutableArray array];
    for (UIColor *color in arr) {
        [newColors addObject:(__bridge id)color.CGColor];
    }
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.colors = newColors;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    [self.layer addSublayer:gradientLayer];
}


@end
