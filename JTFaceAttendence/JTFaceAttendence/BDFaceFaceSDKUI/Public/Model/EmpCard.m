//
//  EmpCard.m
//  JTFaceAttendence
//
//  Created by lj on 2021/7/1.
//

#import "EmpCard.h"
#import "JTFaceImageAttendenceManager.h"
#import <EventKit/EventKit.h>

@interface EmpCard () <CAAnimationDelegate> {
    CGPoint _targetPoint;
}

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UILabel *nameLa, *departmentLa, *statusLa;

@property (nonatomic, strong) UIView *bgView;

@end

@implementation EmpCard

- (instancetype)initWithEmpModel:(EmpInfoModel *)mo {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kScreenWidth/3, kScreenWidth/2);
        self.layer.cornerRadius = 23;
        self.layer.masksToBounds = YES;
        self.backgroundColor = HEX_ThemeColor;
        self.center = APPWINDOW.center;
        self.bgView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
        
        self.statusLa = [UILabel new];
        self.statusLa.textColor = HEX_COLOR(@"#ffffff");
        self.statusLa.font = [UIFont systemFontOfSize:20];
        self.statusLa.text = @"考勤成功✅";
        self.statusLa.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.statusLa];
        [self.statusLa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(40);
        }];
        
        self.avatar = [UIImageView new];
        self.avatar.layer.cornerRadius = 15;
        self.avatar.layer.masksToBounds = YES;
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:mo.empAvatar] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mo.empPhoto]]]];
        
        [self addSubview:self.avatar];
        [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth/3-35, (kScreenWidth/3-35)*3/2));
        }];
        
        self.nameLa = [UILabel new];
        self.nameLa.textColor = HEX_COLOR(@"#999999");
        self.nameLa.font = [UIFont systemFontOfSize:18];
        self.nameLa.text = [NSString stringWithFormat:@"姓名：%@",mo.empName];
        [self addSubview:self.nameLa];
        [self.nameLa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatar.mas_bottom).offset(20);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth/6, 30));
        }];
        
        self.departmentLa = [UILabel new];
        self.departmentLa.textColor = HEX_COLOR(@"#999999");
        self.departmentLa.font = [UIFont systemFontOfSize:18];
        self.departmentLa.text = [NSString stringWithFormat:@"部门：%@",mo.empDepartmentName];
        [self addSubview:self.departmentLa];
        [self.departmentLa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLa.mas_bottom).offset(20);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth/6, 30));
        }];
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }
    return self;
}

- (void)animationToPoint:(CGPoint)targetPoint {
    _targetPoint = targetPoint;
    [APPWINDOW addSubview:self.bgView];
    [APPWINDOW addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {

    }];
    
    
    
    
    
    
    
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    group.animations = @[[self scaleToFull]];//, scale2, move
//    group.duration = 0.8;
//    group.delegate = self;
//    [self.layer addAnimation:group forKey:nil];
    
    
    
}

- (CABasicAnimation *)scaleToFull {
    CABasicAnimation *scale1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale1.toValue = [NSNumber numberWithFloat:1.0];
    scale1.fromValue = [NSNumber numberWithFloat:0.01];
    scale1.duration = 0.8;
    scale1.beginTime = CACurrentMediaTime();
    scale1.repeatCount = HUGE_VAL;
    scale1.removedOnCompletion = NO;
    scale1.fillMode = kCAFillModeForwards;
    return scale1;
}

- (CABasicAnimation *)scaleToHalf {
    CABasicAnimation *scale2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale2.toValue = @(0.5);
    scale2.fromValue = @(1.0);
    scale2.beginTime = CACurrentMediaTime()+2;
    scale2.duration = 0.3;
    scale2.repeatCount = 0;
    return scale2;
}

- (CAKeyframeAnimation *)moveToPoint {
    CGPoint fromPoint = self.center;
    CGPoint toPoint = _targetPoint;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:fromPoint];
    [path addLineToPoint:toPoint];
    
    CAKeyframeAnimation *move = [CAKeyframeAnimation animation];
    move.keyPath = @"position";
    move.path = path.CGPath;
    move.duration = 0.3;
    move.repeatCount = 1;
    move.beginTime = CACurrentMediaTime()+2;
    move.removedOnCompletion = NO;
    move.fillMode = kCAFillModeForwards;
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return move;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    [self.layer removeAllAnimations];
//    self.transform = CGAffineTransformMakeScale(0.5, 0.5);
//    self.center = _targetPoint;
//    self.layer.position = _targetPoint;
//    self.layer.affineTransform = CGAffineTransformMakeScale(0.5, 0.5);;
    [self hide];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.bgView removeFromSuperview];
    }];
}

@end
