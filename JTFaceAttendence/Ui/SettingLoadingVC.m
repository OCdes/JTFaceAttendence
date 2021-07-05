//
//  SettingLoadingVC.m
//  JTFaceAttendence
//
//  Created by lj on 2021/7/2.
//

#import "SettingLoadingVC.h"
#import "NSString+Tool.h"
#import "VedioCheckViewController.h"
@interface SettingLoadingVC ()

@property (nonatomic, strong) UIImageView *launchImgView;

@end

@implementation SettingLoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.launchImgView = [[UIImageView alloc] initWithFrame:APPWINDOW.bounds];
    self.launchImgView.image = [UIImage imageNamed:@"launchImage"];
    [self.view addSubview:self.launchImgView];
    [self verifyPlacePad];
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
    //参数处理+
    NSDictionary *dict = @{@"deviceId":udid,@"timestamp":intervalStr,@"nonceStr":nonceStr,@"placeKey":placeKey,@"sign":signStr};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@",Base_Url,POST_GETPLACEINFO] parameters:dict headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSNumber *code = (NSNumber *)[dict objectForKey:@"code"];
        NSString *msg = (NSString *)[dict objectForKey:@"msg"];
        NSDictionary *dataDict = (NSDictionary *)[dict objectForKey:@"data"];
        if (![code isEqualToNumber:@(0)]) {
            [SVProgressHUD showErrorWithStatus:msg];
        } else {
            [AdminInfo shareInfo].placeKey = dataDict[@"appKey"];
            [AdminInfo shareInfo].placeName = dataDict[@"placeName"];
        }
        APPWINDOW.rootViewController = [[BaseNavigationController alloc] initWithRootViewController:[[VedioCheckViewController alloc] init]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error.localizedDescription);
    }];
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
