//
//  SettingLoadingVC.m
//  JTFaceAttendence
//
//  Created by lj on 2021/7/2.
//

#import "SettingLoadingVC.h"

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
    
}

- (void)verifyPlacePad {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@",@""] parameters:@{@"deviceID":[UUIDManager getUUID]} headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
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
