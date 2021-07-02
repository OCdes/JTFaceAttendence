//
//  ProfileView.m
//  JTFaceAttendence
//
//  Created by lj on 2021/6/29.
//

#import "ProfileView.h"
#import "BDFaceLivingConfigViewController.h"
@interface ProfileView () <UITableViewDelegate, UITableViewDataSource> {
    BOOL _hasShow;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *rowTitles;

@property (nonatomic, strong) UIView *bgView, *loginHeader, *profileHader;

@end

@implementation ProfileView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(-kScreenWidth*0.25, 0, kScreenWidth*0.25, kScreenHeight);
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth*0.25, kScreenHeight) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.bgView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animation)]];
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
            self.tableView.contentOffset = CGPointZero;
        }
        [self addSubview:self.tableView];
        self.alpha = 0.01;
    }
    return self;
}

- (void)animation {
    if (_hasShow) {
        if (self.didHideBlock) {
            self.didHideBlock();
        }
        CGRect frame = self.frame;
        frame.origin.x = -kScreenWidth*0.25;
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
            self.alpha = 0.01;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.bgView removeFromSuperview];
        }];
    } else {
        [APPWINDOW addSubview:self.bgView];
        [APPWINDOW addSubview:self];
        CGRect frame = self.frame;
        frame.origin.x = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
            self.alpha = 1.0;
        }];
    }
    _hasShow = !_hasShow;
}

- (void)loginBtnClicked {
    
}

#pragma mark --UITableViewDelegate&DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifer = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 2;
        cell.selectionStyle = 0;
    }
    cell.textLabel.text = self.rowTitles[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 236;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [AdminInfo shareInfo].token.length ? self.profileHader : self.loginHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *rowTitle = self.rowTitles[indexPath.row];
    if ([rowTitle isEqualToString:@"设置"]) {
        BDFaceLivingConfigViewController *vc = [[BDFaceLivingConfigViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [(BaseNavigationController *)APPWINDOW.rootViewController presentViewController:vc animated:YES completion:nil];
    }
    [self animation];
}

#pragma mark --Lazyload

- (NSArray *)rowTitles {
    if ([AdminInfo shareInfo].token.length) {
        return @[@"设备重新激活",@"已录入员工管理",@"设置",@"关于我们"];
    } else {
        return @[];
    }
}

- (UIView *)loginHeader {
    if (!_loginHeader) {
        _loginHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth*0.25, 236)];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth*0.25, 236)];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:@"登录/注册" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginHeader;
}

- (UIView *)profileHader {
    if (!_profileHader) {
        _profileHader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth*0.25, 236)];
        _profileHader.backgroundColor = [UIColor orangeColor];
        UIImageView *portraitV = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth*0.25-60)/2, 30, 60, 60)];
        portraitV.contentMode = UIViewContentModeScaleAspectFill;
        portraitV.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[AdminInfo shareInfo].avatarUrl]]];
        portraitV.layer.cornerRadius = 30;
        portraitV.layer.masksToBounds = YES;
        [_profileHader addSubview:portraitV];
        
        CGFloat width = (kScreenWidth-34)/2;
        
        UILabel *nameLa = [[UILabel alloc] initWithFrame:CGRectMake(14, CGRectGetMaxY(portraitV.frame)+30, width, 30)];
        nameLa.font = [UIFont boldSystemFontOfSize:16];
        nameLa.textColor = [UIColor lightGrayColor];
        nameLa.text = [NSString stringWithFormat:@"姓名：%@",[AdminInfo shareInfo].emp_name];
        [_profileHader addSubview:nameLa];
        
        UILabel *departmentLa = [[UILabel alloc] initWithFrame:CGRectMake(14, CGRectGetMaxY(nameLa.frame)+10, width, 30)];
        departmentLa.font = [UIFont boldSystemFontOfSize:16];
        departmentLa.textColor = [UIColor lightGrayColor];
        departmentLa.text = [NSString stringWithFormat:@"部门：%@",[AdminInfo shareInfo].emp_department];
        [_profileHader addSubview:departmentLa];
        
        UILabel *positionLa = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(departmentLa.frame)+10, width*2, 30)];
        positionLa.font = [UIFont boldSystemFontOfSize:16];
        positionLa.textColor = [UIColor lightGrayColor];
        positionLa.text = [NSString stringWithFormat:@"职位：%@",[AdminInfo shareInfo].emp_position];
        [_profileHader addSubview:positionLa];
    }
    return _profileHader;
}

@end
