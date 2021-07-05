//
//  VedioCheckViewController.m
//  JTFaceAttendence
//
//  Created by lj on 2021/6/29.
//

#import "VedioCheckViewController.h"
#import "BDFaceVideoCaptureDevice.h"
#import "BDFaceBaseViewController.h"
#import "ProfileView.h"
#import "BDFaceLivenessViewController.h"
#import "BDFaceDetectionViewController.h"
#import "BDFaceLivingConfigModel.h"
#import "BDFaceImageShow.h"
#import "AttendenceViewModel.h"
#import "EmpCard.h"
#import "AudioManager.h"

@interface VedioCheckViewController () <CaptureDataOutputProtocol> {
    CGRect rectFrame;
    BOOL isPaint;
    UIImageView * newImage;
    NSDateFormatter *formatter;
}

@property (nonatomic, readwrite, retain) UIImageView *displayImageView;

@property (nonatomic, readwrite, retain) BDFaceVideoCaptureDevice *videoCapture;

@property (nonatomic, readwrite, retain) UILabel * remindDetailLabel, *empNameLa, *departmenLa, *timeLa, *statusLa, *placeNameLa;

@property (nonatomic, strong) ProfileView *pv;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) AttendenceViewModel *viewModel;

@end

@implementation VedioCheckViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setHasFinished:(BOOL)hasFinished {
    _hasFinished = hasFinished;
    if (hasFinished) {
        [self.videoCapture stopSession];
        self.videoCapture.delegate = nil;
    } else {
        self.videoCapture.delegate = self;
    }
}

- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == PoseStatus) {
            [weakSelf.remindDetailLabel setHidden:false];
            weakSelf.remindDetailLabel.text = warning;
        }else if (status == occlusionStatus) {
            [weakSelf.remindDetailLabel setHidden:false];
            weakSelf.remindDetailLabel.text = warning;
        }else {
            [weakSelf.remindDetailLabel setHidden:true];
        }
    });
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 监听重新返回APP
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignAction) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    self.viewModel = [[AttendenceViewModel alloc] init];
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    @weakify(self);
    [self.viewModel.suceessSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        EmpInfoModel *model = [JTFaceImageAttendenceManager sharedInstance].lastEmpModel;
        self.empNameLa.text = [NSString stringWithFormat:@"姓名:%@",model.empName];
        self.departmenLa.text = [NSString stringWithFormat:@"部门:%@",model.empDepartmentName];
        
        self.timeLa.text = [NSString stringWithFormat:@"时间:%@",[self->formatter stringFromDate:[NSDate date]]];
        [self setStatusText:x status:YES];
        [[AudioManager shareInstance] attendenceSuccess];
    }];
    [self.viewModel.failureSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self setStatusText:x status:NO];
        [[AudioManager shareInstance] attendenceFailuer];
    }];
    [self setNav];
    [self initView];
}

- (void)setStatusText:(NSString *)msg status:(BOOL)sucess {
    self.hasFinished = NO;
    [self.videoCapture startSession];
    if (sucess) {
        self.statusLa.text = [NSString stringWithFormat:@"%@",msg];
        self.statusLa.textColor = HEX_COLOR(@"#bef467");
    } else {
        self.statusLa.text = [NSString stringWithFormat:@"%@",msg];
        self.statusLa.textColor = HEX_COLOR(@"#e4240c");
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLa.text = @"精特考勤";
            self.statusLa.textColor = HEX_COLOR(@"#ffffff");
        });
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.hasFinished = YES;
    self.videoCapture.runningStatus = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hasFinished = NO;
    self.videoCapture.runningStatus = YES;
    [self.videoCapture startSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)faceProcesss:(UIImage *)image {
    if (self.hasFinished) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[IDLFaceLivenessManager sharedInstance] livenessNormalWithImage:image previewRect:rectFrame detectRect:rectFrame completionHandler:^(NSDictionary *images, FaceInfo *faceInfo, LivenessRemindCode remindCode) {
        switch (remindCode) {
            case LivenessRemindCodeOK: {
                weakSelf.hasFinished = YES;
                [self warningStatus:CommonStatus warning:@"识别成功"];
                if (images[@"image"] != nil && [images[@"image"] count] != 0) {
                    
                    NSArray *imageArr = images[@"image"];
                    for (FaceCropImageInfo * image in imageArr) {
                        NSLog(@"cropImageWithBlack %f %f", image.cropImageWithBlack.size.height, image.cropImageWithBlack.size.width);
                        NSLog(@"originalImage %f %f", image.originalImage.size.height, image.originalImage.size.width);
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGRect faceRect = [BDFaceQualityUtil getFaceRect:faceInfo.landMarks withCount:faceInfo.landMarks.count];
                        CGRect faceRectFit = [BDFaceUtil convertRectFrom:faceRect image:image previewRect:self->rectFrame];
                        if (!self->isPaint) {
                            self->newImage= [[UIImageView alloc]init];
                            [self.view addSubview:self->newImage];
                            self->isPaint = !self->isPaint;
                        }
                        self->newImage = [self creatRectangle:self->newImage withRect:faceRectFit  withcolor:[UIColor blackColor]];
                    });
                    
                    FaceCropImageInfo * bestImage = imageArr[0];
                    [[BDFaceImageShow sharedInstance] setSuccessImage:bestImage.originalImage];
                    [[BDFaceImageShow sharedInstance] setSilentliveScore:bestImage.silentliveScore];
                    [self.viewModel requestAttendence];
                    
                }
                break;
            }
            case LivenessRemindCodePoorIllumination:
                [self warningStatus:CommonStatus warning:@"请使环境光线再亮些" conditionMeet:false];
                break;
            case LivenessRemindCodeNoFaceDetected:
                [self warningStatus:CommonStatus warning:@"把脸移入框内" conditionMeet:false];
                break;
            case LivenessRemindCodeImageBlured:
                [self warningStatus:PoseStatus warning:@"请不要晃动" conditionMeet:false];
                break;
            case LivenessRemindCodeOcclusionLeftEye:
                [self warningStatus:occlusionStatus warning:@"左眼有遮挡" conditionMeet:false];
                break;
            case LivenessRemindCodeOcclusionRightEye:
                [self warningStatus:occlusionStatus warning:@"右眼有遮挡" conditionMeet:false];
                break;
            case LivenessRemindCodeOcclusionNose:
                [self warningStatus:occlusionStatus warning:@"鼻子有遮挡" conditionMeet:false];
                break;
            case LivenessRemindCodeOcclusionMouth:
                [self warningStatus:occlusionStatus warning:@"嘴巴有遮挡" conditionMeet:false];
                break;
            case LivenessRemindCodeOcclusionLeftContour:
                [self warningStatus:occlusionStatus warning:@"左脸颊有遮挡" conditionMeet:false];
                break;
            case LivenessRemindCodeOcclusionRightContour:
                [self warningStatus:occlusionStatus warning:@"右脸颊有遮挡" conditionMeet:false];
                break;
            case LivenessRemindCodeOcclusionChinCoutour:
                [self warningStatus:occlusionStatus warning:@"下颚有遮挡" conditionMeet:false];
                break;
            case LivenessRemindCodeLeftEyeClosed:
                [self warningStatus:occlusionStatus warning:@"左眼未睁开" conditionMeet:false];
                break;
            case LivenessRemindCodeRightEyeClosed:
                [self warningStatus:occlusionStatus warning:@"右眼未睁开" conditionMeet:false];
                break;
            case LivenessRemindCodeTooClose:
                [self warningStatus:CommonStatus warning:@"请将脸部离远一点" conditionMeet:false];
                break;
            case LivenessRemindCodeTooFar:
                [self warningStatus:CommonStatus warning:@"请将脸部靠近一点" conditionMeet:false];
                break;
            case LivenessRemindCodeBeyondPreviewFrame:
                [self warningStatus:CommonStatus warning:@"把脸移入框内" conditionMeet:false];
                break;
            case LivenessRemindCodeVerifyInitError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeConditionMeet: {
            }
                break;
            default:
                break;
        }
    }];
}

#pragma mark-绘框方法
- (UIImageView *)creatRectangle:(UIImageView *)imageView withRect:(CGRect) rect withcolor:(UIColor *)color{
    
//    CAShapeLayer *lineLayer = [CAShapeLayer layer];
//    //创建需要画线的视图
//    UIBezierPath *linePath = [UIBezierPath bezierPath];
//    //起点
//    float x = rect.origin.x;
//    float y = rect.origin.y;
//    float W = rect.size.width;
//    float H = rect.size.height;
//    [linePath moveToPoint:CGPointMake(x, y)];
//    //其他点
//    [linePath addLineToPoint:CGPointMake(x + W, y)];
//    [linePath addLineToPoint:CGPointMake(x + W, y + H)];
//    [linePath addLineToPoint:CGPointMake(x, y + H)];
//    [linePath addLineToPoint:CGPointMake(x, y)];
//    lineLayer.lineWidth = 2;
//    lineLayer.strokeColor = color.CGColor;
//    lineLayer.path = linePath.CGPath;
//    lineLayer.fillColor = nil; // 默认为blackColor
//    imageView.layer.sublayers = nil;
//    [imageView.layer addSublayer:lineLayer];
    imageView.image = [UIImage imageNamed:@"faceFollow"];
    imageView.frame = rect;
    
    return imageView;
}

- (void)initView {
    
    CGFloat rectWidth = 480;//kScreenWidth*0.625
    CGFloat rectHeight = 596;
    rectFrame = CGRectMake((kScreenWidth-480)/2, 98, rectWidth, rectHeight);
    // 初始化相机处理类
    self.videoCapture = [[BDFaceVideoCaptureDevice alloc] init];
    self.videoCapture.delegate = self;
    
    // 用于展示视频流的imageview
    self.displayImageView = [[UIImageView alloc] initWithFrame:rectFrame];
    self.displayImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.displayImageView];

    // 提示label（遮挡等问题）
    self.remindDetailLabel = [[UILabel alloc] init];
    self.remindDetailLabel.frame = CGRectMake(0, 139.3, kScreenWidth, 16);
    self.remindDetailLabel.font = [UIFont systemFontOfSize:16];
    self.remindDetailLabel.textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1 / 1.0];
    self.remindDetailLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.remindDetailLabel];
    [self.remindDetailLabel setHidden:true];
    
    self.maskView = [[UIView alloc] initWithFrame:APPWINDOW.bounds];
    [self.maskView gradualChangeColorViewWithColors:@[HEX_COLOR(@"#15151D"),HEX_COLOR(@"#262634")]];
    [self.view addSubview:self.maskView];
    UIBezierPath *bp = [UIBezierPath bezierPathWithRoundedRect:APPWINDOW.bounds cornerRadius:0];
    [bp appendPath:[UIBezierPath bezierPathWithRect:rectFrame]];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = bp.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    self.maskView.layer.mask = layer;
    
    CGFloat pluginValue = 20;
    CGRect borderRect = CGRectMake(rectFrame.origin.x-pluginValue, rectFrame.origin.y-pluginValue, rectFrame.size.width+pluginValue*2, rectFrame.size.height+pluginValue*2);
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:borderRect];
    imgv.backgroundColor = [UIColor clearColor];
    imgv.image = [UIImage imageNamed:@"scanRect"];
    imgv.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgv];
    
    UIImageView *bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, kScreenHeight-43-56, kScreenWidth, 43)];
    bottomLine.image = [UIImage imageNamed:@"bottomLine"];
    bottomLine.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:bottomLine];
    
    self.placeNameLa = [[UILabel alloc] initWithFrame:bottomLine.frame];
    self.placeNameLa.textColor = HEX_COLOR(@"#ffffff");
    self.placeNameLa.font = [UIFont systemFontOfSize:20];
    self.placeNameLa.textAlignment = NSTextAlignmentCenter;
    self.placeNameLa.text = [AdminInfo shareInfo].placeName;
    [self.view addSubview:self.placeNameLa];
    
    UIImageView *infoV = [[UIImageView alloc] initWithFrame:CGRectMake(borderRect.origin.x, CGRectGetMaxY(borderRect)+37, borderRect.size.width, 136)];//empInfobg
    infoV.image = [UIImage imageNamed:@"empInfobg"];
    infoV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:infoV];
    
    self.empNameLa = [[UILabel alloc] initWithFrame:CGRectMake(66, 51, borderRect.size.width/2, 25)];
    self.empNameLa.textColor = HEX_COLOR(@"#ffffff");
    self.empNameLa.text = @"姓名：";
    self.empNameLa.font = [UIFont boldSystemFontOfSize:16];
    [infoV addSubview:self.empNameLa];
    self.departmenLa = [[UILabel alloc] initWithFrame:CGRectMake(66, CGRectGetMaxY(self.empNameLa.frame), borderRect.size.width/2, 25)];
    self.departmenLa.textColor = HEX_COLOR(@"#ffffff");
    self.departmenLa.text = @"部门：";
    self.departmenLa.font = [UIFont boldSystemFontOfSize:16];
    [infoV addSubview:self.departmenLa];
    self.timeLa = [[UILabel alloc] initWithFrame:CGRectMake(66, CGRectGetMaxY(self.departmenLa.frame), borderRect.size.width/2, 25)];
    self.timeLa.textColor = HEX_COLOR(@"#ffffff");
    self.timeLa.font = [UIFont boldSystemFontOfSize:16];
    self.timeLa.text = @"考勤时间：";
    [infoV addSubview:self.timeLa];
    
    UILabel *deviceID = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight-56, kScreenWidth, 56)];
    deviceID.textColor = HEX_COLOR(@"#ffffff");
    deviceID.font = [UIFont boldSystemFontOfSize:14];
    deviceID.textAlignment = NSTextAlignmentCenter;
    deviceID.text = [NSString stringWithFormat:@"设备号：%@",[UUIDManager getUUID]];
    deviceID.userInteractionEnabled = YES;
    [deviceID addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyUDID)]];
    [self.view addSubview:deviceID];
}

- (void)copyUDID {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:[UUIDManager getUUID]];
    [SVProgressHUD showSuccessWithStatus:@"已复制"];
}

- (void)setNav {
    UIButton *menu = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    menu.hidden = YES;
    [menu setImage:[UIImage imageNamed:@"icon_guide2"] forState:UIControlStateNormal];
    menu.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [menu addTarget:self action:@selector(profileShow) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menu];
    
    UIButton *addFace = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [addFace setImage:[UIImage imageNamed:@"icon_guide3"] forState:UIControlStateNormal];
    addFace.hidden = YES;
    addFace.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [addFace addTarget:self action:@selector(registFaceID) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addFace];
    
    UILabel *titleLa = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-240, 40)];
    titleLa.font = [UIFont boldSystemFontOfSize:25];
    titleLa.textColor = [UIColor whiteColor];
    titleLa.text = @"精特考勤";
    titleLa.textAlignment = NSTextAlignmentCenter;
    titleLa.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    titleLa.layer.shadowOffset = CGSizeZero;
    titleLa.layer.shadowOpacity = 1;
    titleLa.layer.shadowRadius = 5;
    self.statusLa = titleLa;
    self.navigationItem.titleView = self.statusLa;
}

- (void)profileShow {
    [self.pv animation];
}

- (void)registFaceID {
    if ([AdminInfo shareInfo].token.length) {
        NSNumber *LiveMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"LiveMode"];
        if (LiveMode.boolValue){
            [self faceLiveness];
        } else {
            [self faceDetect];
        }
    } else {
        
    }
    
    
}

- (void)faceLiveness {
    BDFaceLivenessViewController* lvc = [[BDFaceLivenessViewController alloc] init];
    BDFaceLivingConfigModel* model = [BDFaceLivingConfigModel sharedInstance];
    [lvc livenesswithList:model.liveActionArray order:model.isByOrder numberOfLiveness:model.numOfLiveness];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:lvc];
    navi.navigationBarHidden = true;
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)faceDetect {
    BDFaceDetectionViewController* dvc = [[BDFaceDetectionViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:dvc];
    navi.navigationBarHidden = true;
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark - Notification

- (void)onAppWillResignAction {
    _hasFinished = YES;
}

- (void)onAppBecomeActive {
    _hasFinished = NO;
}

#pragma mark - CaptureDataOutputProtocol

- (void)captureOutputSampleBuffer:(UIImage *)image {
    if (_hasFinished) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.displayImageView.image = image;
    });
    [self faceProcesss:image];
}

- (void)captureError {
    NSString *errorStr = @"出现未知错误，请检查相机设置";
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        errorStr = @"相机权限受限,请在设置中启用";
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:errorStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"知道啦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"知道啦");
        }];
        [alert addAction:action];
        UIViewController* fatherViewController = weakSelf.presentingViewController;
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [fatherViewController presentViewController:alert animated:YES completion:nil];
        }];
    });
}

- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning conditionMeet:(BOOL)meet{
    [self warningStatus:status warning:warning];
}

@end
