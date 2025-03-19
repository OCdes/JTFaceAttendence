//
//  SettingLoadingVC.m
//  JTFaceAttendence
//
//  Created by lj on 2021/7/2.
//

#import "SettingLoadingVC.h"
#import "NSString+Tool.h"
#import "BDFaceAgreementViewController.h"

#import "ConfigManager.h"
#import "BDFaceDetectionViewController.h"
#import "BDFaceLivenessViewController.h"
#import "BDFaceLivingConfigModel.h"
#import "LivenessVedioCheckVC.h"
#import "NoLivenessVedioCheckVC.h"
@interface SettingLoadingVC ()

@property (nonatomic, strong) UIImageView *launchImgView;

@property (nonatomic, strong) UIButton *reRequestInfo;

@end

@implementation SettingLoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.launchImgView = [[UIImageView alloc] initWithFrame:APPWINDOW.bounds];
    self.launchImgView.image = [UIImage imageNamed:@"launchImage"];
    [self.view addSubview:self.launchImgView];
    
    self.reRequestInfo = [[UIButton alloc]  initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    [self.reRequestInfo setTitle:@"初始化网络连接失败,\n轻点重新尝试" forState:UIControlStateNormal];
    self.reRequestInfo.titleLabel.numberOfLines = 2;
    self.reRequestInfo.hidden = YES;
    self.reRequestInfo.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.reRequestInfo.center = CGPointMake(self.view.center.x, kScreenHeight*2/3+50);
    [self.reRequestInfo addTarget:self action:@selector(verifyPlacePad) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.reRequestInfo];
}

- (void)verifyPlacePad {
    [SVProgressHUD showWithStatus:@"请稍后，初始化加载中。。。"];
    //设备ID
    NSString *udid =[UUIDManager getUUID];
    //日期处理
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    NSString *intervalStr = [NSString stringWithFormat:@"%.0f",interval*10000];
    //32位随机数
    NSString *nonceStr = [NSString stringWithFormat:@"%ld",(long)(arc4random()*pow(10, 31))];
    NSString *placeKey = @"";
    //sign 签名
    NSString *secretKey = @"7dkc86acd1438f1";
    NSString *paramStr = [NSString stringWithFormat:@"%@%@%@",udid, intervalStr,nonceStr];
    NSString *signStr = [paramStr HmacSHA256WithSecretKey:secretKey];
    NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //参数处理+
    NSDictionary *dict = @{@"deviceId":udid,@"timestamp":intervalStr,@"nonceStr":nonceStr,@"placeKey":placeKey,@"sign":signStr,@"attendanceVersion":version};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@",Base_Url,POST_GETPLACEINFO] parameters:dict headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        DLog(@"%@",responseObject);
        self.reRequestInfo.hidden = YES;
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSNumber *code = (NSNumber *)[dict objectForKey:@"code"];
        NSString *msg = (NSString *)[dict objectForKey:@"msg"];
        NSDictionary *dataDict = (NSDictionary *)[dict objectForKey:@"data"];
        if (![code isEqualToNumber:@(0)]) {
            [SVProgressHUD showErrorWithStatus:msg];
            [AdminInfo shareInfo].placeKey = @"";
            [AdminInfo shareInfo].placeName = @"";
            [AdminInfo shareInfo].adapterAppID = @"";
            [AdminInfo shareInfo].enableLiveness = @"1";
        } else {
            [AdminInfo shareInfo].placeKey = [dataDict objectForKey:@"appKey"];
            [AdminInfo shareInfo].placeName = [dataDict objectForKey:@"placeName"];
            [AdminInfo shareInfo].adapterAppID = [dataDict objectForKey:@"adapterAppID"];
            [AdminInfo shareInfo].enableLiveness = NSStringFormate(@"%@",[dataDict objectForKey:@"livingBody"]);
        }
        [[ConfigManager manager] initConfig];
        if ([AdminInfo shareInfo].hasAgree) {
            [self enterHome];
        } else {
            [self agreenmentAlert];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == -1009) {
            self.reRequestInfo.hidden = NO;
        } else {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            [AdminInfo shareInfo].placeKey = @"";
            [AdminInfo shareInfo].placeName = @"";
            [AdminInfo shareInfo].adapterAppID = @"";
            [AdminInfo shareInfo].enableLiveness = @"1";
            NSLog(@"%@",error.localizedDescription);
        }
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self verifyPlacePad];
}

- (void)agreenmentAlert {
    BDFaceAgreementViewController *vc = [[BDFaceAgreementViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)enterHome {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
