//
//  BDFaceAgreementViewController.m
//  FaceSDKSample_IOS
//
//  Created by 孙明喆 on 2020/3/12.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import "BDFaceAgreementViewController.h"
#import "BDFaceLogoView.h"
#import "LivenessVedioCheckVC.h"
#import "NoLivenessVedioCheckVC.h"
#import "BDFaceLivingConfigModel.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface BDFaceAgreementViewController ()

@end

@implementation BDFaceAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    // 顶部
    UILabel *titeLabel = [[UILabel alloc] init];
    titeLabel.frame = CGRectMake(0, 38, ScreenWidth, 20);
    titeLabel.text = @"人脸采集协议";
    titeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:20];
    titeLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:1 / 1.0];
    titeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titeLabel];
    
    UIButton *backButton = [[UIButton alloc] init];
    backButton.frame = CGRectMake(23.3, 43.3, 40, 20);
//    [backButton setImage:[UIImage imageNamed:@"icon_titlebar_back"] forState:UIControlStateNormal];
    [backButton setTitle:@"离开" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *agreeBtn = [[UIButton alloc] init];
    agreeBtn.frame = CGRectMake(kScreenWidth-63.3, 43.3, 40, 20);
//    [backButton setImage:[UIImage imageNamed:@"icon_titlebar_back"] forState:UIControlStateNormal];
    [agreeBtn setTitle:@"确认" forState:UIControlStateNormal];
    [agreeBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [agreeBtn addTarget:self action:@selector(enterHome) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreeBtn];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(0, 79.7, ScreenWidth, 0.3);
    lineView.backgroundColor = [UIColor colorWithRed:216 / 255.0 green:216 / 255.0 blue:216 / 255.0 alpha:1 / 1.0];
    [self.view addSubview:lineView];
    
    UIView *liveView = [[UIView alloc] init];
    liveView.frame = CGRectMake(0, 105, ScreenWidth-40, 400);
    
    // 间距
    int spacing = 0;
    
    for (int num = 0; num < 3; num++){
        UIImage *image = [UIImage imageNamed:@"image_agreement"];
        UIImageView *imageView1 = [[UIImageView alloc] init];
        imageView1.frame = CGRectMake(20, spacing, 3, 18);
        imageView1.image = image;
        UILabel *line1 = [[UILabel alloc] init];
        line1.frame = CGRectMake(29, spacing, self.view.frame.size.width-40, 18);
        line1.text = [self getTitle:num];
        line1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        line1.textColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:1 / 1.0];
       
        UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(20, spacing+CGRectGetHeight(line1.frame) + 15,  (self.view.frame.size.width-40), 0)];
        line2.numberOfLines = 0;
        line2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        line2.textColor = [UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1 / 1.0];
        line2.text = [self getMessage:num];
        line2.textAlignment = NSTextAlignmentLeft;
        CGSize size = [line2 sizeThatFits:CGSizeMake(line2.frame.size.width, MAXFLOAT)];
        line2.frame = CGRectMake(20, spacing +CGRectGetHeight(line1.frame)+ 15, (self.view.frame.size.width-40), size.height);
        
        spacing += CGRectGetHeight(line1.frame) + 15 + CGRectGetHeight(line2.frame) + 25;
        
        [liveView addSubview:imageView1];
        [liveView addSubview:line1];
        [liveView addSubview:line2];
    }
    
    [self.view addSubview:liveView];
    
    // 设置logo，底部的位置和大小，实例化显示
    BDFaceLogoView* logoView = [[BDFaceLogoView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-15-12), self.view.frame.size.width, 12)];
    [self.view addSubview:logoView];
}

- (void)enterHome {
    [AdminInfo shareInfo].hasAgree = YES;
    if ([[AdminInfo shareInfo].enableLiveness isEqualToString:@"1"]) {
        LivenessVedioCheckVC* lvc = [[LivenessVedioCheckVC alloc] init];
        BDFaceLivingConfigModel* model = [BDFaceLivingConfigModel sharedInstance];
        [lvc livenesswithList:model.liveActionArray order:model.isByOrder numberOfLiveness:model.numOfLiveness];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:lvc];
        navi.navigationBarHidden = true;
        navi.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navi animated:YES completion:nil];
    } else {
        APPWINDOW.rootViewController = [[BaseNavigationController alloc] initWithRootViewController:[[NoLivenessVedioCheckVC alloc] init]];
    }
    
}

- (IBAction)backAction:(UIButton *)sender{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                        //运行一个不存在的方法,退出界面更加圆滑
                        [self performSelector:@selector(notExistCall)];
#pragma clang diagnostic pop
}

- (NSString *)getTitle:(int)type{
    NSString* title;
    switch (type) {
        case 0:
            title = @"功能说明";
            break;
           case 1:
            title = @"授权与许可";
            break;
        case 2:
            title = @"信息安全声明";
            break;
        default:
            break;
    }
    return title;
}

- (NSString *)getMessage:(int)type{
    NSString* title;
    switch (type) {
        case 0:
            title = @"本应用为精特系统中员工人脸考勤模块，为您提供方便快捷的人脸考勤功能。通过人脸特征核验，对员工信息进行认证并考勤，该功能需要向您申请相机使用权限，使用时请确保环境光亮度正常，面容无遮挡。";
            break;
           case 1:
            title = @"如您点击“确认”或以其他方式选择接受本协议规则，则视为您在使用人脸识别服务时，同意并授权、获取、使用您在申请过程中所提供的员工信息。";
            break;
        case 2:
            title = @"承诺对您的员工信息严格保密，并基于国家监管部门认可的加密算法进行数据加密传输，数据加密存储，承诺尽到信息安全保护义务。";
            break;
        default:
            break;
    }
    return title;
}



@end
