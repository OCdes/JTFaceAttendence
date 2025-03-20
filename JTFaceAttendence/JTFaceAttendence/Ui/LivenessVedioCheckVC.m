//
//  LivenessVedioCheckVC.m
//  JTFaceAttendence
//
//  Created by 袁炳生 on 2024/10/29.
//

#import "LivenessVedioCheckVC.h"
#import "BDFaceSuccessViewController.h"
#import "BDFaceLivingConfigModel.h"
#import "BDFaceImageShow.h"
#import <IDLFaceSDK/IDLFaceSDK.h>
#import "BDFaceLog.h"
#import "AttendenceViewModel.h"
#import "EmpCard.h"
#import "AudioManager.h"
#import "GCDAsyncUdpSocket.h"
@interface LivenessVedioCheckVC ()<GCDAsyncUdpSocketDelegate>

{
    CGRect rectFrame;
    BOOL isPaint, isBindUDP;
    UIImageView * newImage;
    NSDateFormatter *formatter;
}

@property (nonatomic) dispatch_source_t timer;

@property (nonatomic, readwrite, retain) UILabel * remindDetailLabel, *empNameLa, *departmenLa, *timeLa, *statusLa, *placeNameLa;

@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) AttendenceViewModel *viewModel;

@property (nonatomic, strong) GCDAsyncUdpSocket *sendSocket;
@property (nonatomic, strong) NSArray *livenessArray;
@property (nonatomic, assign) BOOL order;
@property (nonatomic, assign) NSInteger numberOfLiveness;
@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation LivenessVedioCheckVC

- (void)viewDidLoad {
    CGFloat rectWidth = kScreenWidth*0.625;//
    CGFloat rectHeight = rectWidth * 596/480;
    rectFrame = CGRectMake((kScreenWidth-rectWidth)/2, 40, rectWidth, rectHeight);
    self.previewRect = rectFrame;
    self.detectRect = rectFrame;//CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [super viewDidLoad];
    [self setNav];
    [self initView];
}

- (void)setNav {
    UILabel *titleLa = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-240, 40)];
    titleLa.font = [UIFont boldSystemFontOfSize:32];
    titleLa.textColor = [UIColor whiteColor];
    titleLa.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    titleLa.layer.shadowOffset = CGSizeZero;
    titleLa.layer.shadowOpacity = 1;
    titleLa.layer.shadowRadius = 5;
    self.statusLa = titleLa;
}
- (void)initView {
    
    // 用于展示视频流的imageview
    self.displayImageView.frame = rectFrame;
    [self.view addSubview:self.displayImageView];

    // 提示label（遮挡等问题）
    self.remindDetailLabel = [[UILabel alloc] init];
    self.remindDetailLabel.frame = CGRectMake(0, 139.3, kScreenWidth, 40);
    self.remindDetailLabel.font = [UIFont systemFontOfSize:25];
    self.remindDetailLabel.textColor = [UIColor cyanColor];
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
    
    UIImageView *infoV = [[UIImageView alloc] initWithFrame:CGRectMake(borderRect.origin.x, CGRectGetMaxY(borderRect)+37, borderRect.size.width, 216)];//empInfobg
    infoV.image = [UIImage imageNamed:@"empInfobg"];
    infoV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:infoV];
    
    self.empNameLa = [[UILabel alloc] initWithFrame:CGRectMake(66, 61, borderRect.size.width/2, 25)];
    self.empNameLa.textColor = HEX_COLOR(@"#ffffff");
    self.empNameLa.text = @"姓名：";
    self.empNameLa.font = [UIFont boldSystemFontOfSize:16];
    [infoV addSubview:self.empNameLa];
    self.departmenLa = [[UILabel alloc] initWithFrame:CGRectMake(66, CGRectGetMaxY(self.empNameLa.frame)+10, borderRect.size.width/2, 25)];
    self.departmenLa.textColor = HEX_COLOR(@"#ffffff");
    self.departmenLa.text = @"部门：";
    self.departmenLa.font = [UIFont boldSystemFontOfSize:16];
    [infoV addSubview:self.departmenLa];
    self.timeLa = [[UILabel alloc] initWithFrame:CGRectMake(66, CGRectGetMaxY(self.departmenLa.frame)+10, borderRect.size.width/2, 25)];
    self.timeLa.textColor = HEX_COLOR(@"#ffffff");
    self.timeLa.font = [UIFont boldSystemFontOfSize:16];
    self.timeLa.text = @"考勤时间：";
    [infoV addSubview:self.timeLa];
    
    self.statusLa.frame = CGRectMake(66, CGRectGetMaxY(self.timeLa.frame)+5, borderRect.size.width*2/3, 50);
    self.statusLa.numberOfLines = 2;
    self.statusLa.font = [UIFont boldSystemFontOfSize:16];
    self.statusLa.adjustsFontSizeToFitWidth = YES;
    [infoV addSubview:self.statusLa];
    
    UILabel *deviceID = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight-56, kScreenWidth, 56)];
    deviceID.textColor = HEX_COLOR(@"#ffffff");
    deviceID.font = [UIFont boldSystemFontOfSize:14];
    deviceID.textAlignment = NSTextAlignmentCenter;
    deviceID.text = [NSString stringWithFormat:@"设备号：%@",[UUIDManager getUUID]];
    deviceID.userInteractionEnabled = YES;
    [deviceID addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyUDID)]];
    [self.view addSubview:deviceID];
    
    self.viewModel = [[AttendenceViewModel alloc] init];
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    @weakify(self);
    [self.viewModel.suceessSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.isFinished = NO;
        EmpInfoModel *model = [JTFaceImageAttendenceManager sharedInstance].lastEmpModel;
        self.empNameLa.text = [NSString stringWithFormat:@"姓名:%@",model.empName];
        self.departmenLa.text = [NSString stringWithFormat:@"部门:%@",model.empDepartmentName];
        
        self.timeLa.text = [NSString stringWithFormat:@"时间:%@",[self->formatter stringFromDate:[NSDate date]]];
        [self setStatusText:x status:YES];
        [[AudioManager shareInstance] attendenceSuccess];
        [self selfReplayFunction];
    }];
    [self.viewModel.failureSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.isFinished = NO;
        [self setStatusText:x status:NO];
        self.empNameLa.text = [NSString stringWithFormat:@"姓名:%@",@""];
        self.departmenLa.text = [NSString stringWithFormat:@"部门:%@",@""];
        self.timeLa.text = [NSString stringWithFormat:@"时间:%@",@""];
        [[AudioManager shareInstance] attendenceFailuer];
        [self selfReplayFunction];
    }];
    
    [self.viewModel.udpSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self udpRequestWithDict:x];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isFinished = NO;
    [[IDLFaceLivenessManager sharedInstance] startInitial];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [IDLFaceLivenessManager.sharedInstance reset];
}

- (void)onAppBecomeActive {
    [super onAppBecomeActive];
    self.isFinished = NO;
    [[IDLFaceLivenessManager sharedInstance] livenesswithList:_livenessArray order:_order numberOfLiveness:_numberOfLiveness];
}

- (void)onAppWillResignAction {
    [super onAppWillResignAction];
    self.isFinished = YES;
    [IDLFaceLivenessManager.sharedInstance reset];
}
static int countDown = 3;
- (void)setIsFinished:(BOOL)isFinished {
    if (!isFinished) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_queue_create("com.jt.attendance", DISPATCH_QUEUE_CONCURRENT));
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(self.timer, ^{
            countDown --;
            if (countDown < 0) {
                dispatch_cancel(self.timer);
                self.timer = nil;
                countDown = 3;
                self->_isFinished = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.empNameLa.text = @"姓名:";
                    self.departmenLa.text = @"部门:";
                    self.timeLa.text = @"时间:";
                    self.statusLa.text = @"";
                    [self setStatusText:@"" status:YES];
                });
            }
            
        });
        dispatch_activate(self.timer);
    } else {
        _isFinished = isFinished;
    }
}

- (void)udpRequestWithDict:(NSDictionary *)data {
    uint16_t port = [[data objectForKey:@"port"] intValue];
    NSString *post = [data objectForKey:@"host"];
    NSString *content = [data objectForKey:@"content"];
    DLog(@"%@--%hu--%@",post, port, content);
    if (!isBindUDP) {
        NSError *error = nil;
        self.sendSocket.delegate = self;
        [self.sendSocket bindToPort:port error:&error];
        if (error == nil) {
            [self.sendSocket beginReceiving:nil];
            [self.sendSocket sendData:[content dataUsingEncoding:NSUTF8StringEncoding] toHost:post port:port withTimeout:5 tag:0];
            isBindUDP = YES;
        } else {
            [self setStatusText:error.localizedDescription status:NO];
            isBindUDP = NO;
        }
    } else {
        [self.sendSocket sendData:[content dataUsingEncoding:NSUTF8StringEncoding] toHost:post port:port withTimeout:5 tag:0];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *contentStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[contentStr componentsSeparatedByString:@"#"]];
    [arr removeObject:@""];
    if (arr.count) {
        NSString *code = [NSString stringWithFormat:@"%@",arr[0]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isFinished = NO;
            if ([code isEqualToString:@"00000"]) {
                EmpInfoModel *mo = [EmpInfoModel new];
                mo.empName = arr[1];
                mo.empDepartmentName = arr[2];
                [JTFaceImageAttendenceManager sharedInstance].lastEmpModel = mo;
                self.empNameLa.text = [NSString stringWithFormat:@"姓名:%@",mo.empName];
                self.departmenLa.text = [NSString stringWithFormat:@"部门:%@",mo.empDepartmentName];
                
                self.timeLa.text = [NSString stringWithFormat:@"时间:%@",[self->formatter stringFromDate:[NSDate date]]];
                [self setStatusText:arr.lastObject status:YES];
                [[AudioManager shareInstance] attendenceSuccess];
                [self selfReplayFunction];
            } else {
                if (arr.count > 2 ) {
                    EmpInfoModel *mo = [EmpInfoModel new];
                    mo.empName = arr[1];
                    mo.empDepartmentName = arr[2];
                    [JTFaceImageAttendenceManager sharedInstance].lastEmpModel = mo;
                    self.empNameLa.text = [NSString stringWithFormat:@"姓名:%@",mo.empName];
                    self.departmenLa.text = [NSString stringWithFormat:@"部门:%@",mo.empDepartmentName];
                    self.timeLa.text = [NSString stringWithFormat:@"时间:%@",[self->formatter stringFromDate:[NSDate date]]];
                    [self selfReplayFunction];
                } else {
                    self.empNameLa.text = [NSString stringWithFormat:@"姓名:%@",@""];
                    self.departmenLa.text = [NSString stringWithFormat:@"部门:%@",@""];
                    self.timeLa.text = [NSString stringWithFormat:@"时间:%@",@""];
                }
                [self setStatusText:arr.lastObject status:NO];
                [[AudioManager shareInstance] attendenceFailuer];
                [self selfReplayFunction];
            }
        });
    } else {
        self.isFinished = NO;
        [self setStatusText:@"已识别人脸，但未能返回考勤信息" status:NO];
        [[AudioManager shareInstance] attendenceFailuer];
        [self selfReplayFunction];
        
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isFinished = NO;
        [self setStatusText:@"打卡信息已发送，请等待结果" status:NO];
        [self selfReplayFunction];
    });
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isFinished = NO;
        [self setStatusText:@"UDP连接已关闭，请联系管理员" status:NO];
        [self selfReplayFunction];
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error {
    [self setStatusText:error.localizedDescription status:NO];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setStatusText:@"UDP服务器已连接" status:YES];
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setStatusText:error.localizedDescription status:YES];
        DLog(@"%@",error.localizedDescription)
    });
}

- (void)copyUDID {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:[UUIDManager getUUID]];
    [SVProgressHUD showSuccessWithStatus:@"已复制"];
}

- (void)livenesswithList:(NSArray *)livenessArray order:(BOOL)order numberOfLiveness:(NSInteger)numberOfLiveness {
    _livenessArray = [NSArray arrayWithArray:livenessArray];
    _order = order;
    _numberOfLiveness = numberOfLiveness;
    [[IDLFaceLivenessManager sharedInstance] livenesswithList:livenessArray order:order numberOfLiveness:numberOfLiveness];
}

- (void)faceProcesss:(UIImage *)image {
    if (self.isFinished) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[IDLFaceLivenessManager sharedInstance] livenessNormalWithImage:image previewRect:self.previewRect detectRect:self.detectRect completionHandler:^(NSDictionary *images, FaceInfo *faceInfo, LivenessRemindCode remindCode) {
        switch (remindCode) {
            case LivenessRemindCodeOK: {
                DLog(@"识别成功")
                weakSelf.isFinished = YES;
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
            case LivenessRemindCodeLiveEye:
                [self warningStatus:CommonStatus warning:@"眨眨眼" conditionMeet:true];
               
                break;
           
            
            
            case LivenessRemindCodeFaceIdChanged:
            {
                [self warningStatus:CommonStatus warning:@"把脸移入框内" conditionMeet:true];
            }
                break;
            case LivenessRemindCodeVerifyInitError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                [[IDLFaceLivenessManager sharedInstance] reset];
                break;
            case LivenessRemindCodeTimeout: {
                // 时间超时，重置之前采集数据
                [[IDLFaceLivenessManager sharedInstance] reset];
                break;
            }
            case LivenessRemindActionCodeTimeout:{
                [[IDLFaceLivenessManager sharedInstance] reset];
                break;
            }
            case LivenessRemindCodeConditionMeet: {
                break;
            }
            default:
//                DLog(@"%lu",(unsigned long)remindCode);
                break;
        }
    }];
}

- (void)selfReplayFunction{
     [[IDLFaceLivenessManager sharedInstance] reset];
     BDFaceLivingConfigModel* model = [BDFaceLivingConfigModel sharedInstance];
     [[IDLFaceLivenessManager sharedInstance] livenesswithList:model.liveActionArray order:model.isByOrder numberOfLiveness:model.numOfLiveness];
}

- (void)setStatusText:(NSString *)msg status:(BOOL)sucess {
    if (sucess) {
        self.statusLa.text = [NSString stringWithFormat:@"%@",msg];
        self.statusLa.textColor = HEX_COLOR(@"#bef467");
    } else {
        self.statusLa.text = [NSString stringWithFormat:@"%@",msg];
        self.statusLa.textColor = HEX_COLOR(@"#e4240c");
    }
}


- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning conditionMeet:(BOOL)meet{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.remindDetailLabel.hidden = NO;
        weakSelf.remindDetailLabel.text = warning;
    });
}

- (GCDAsyncUdpSocket *)sendSocket {
    if (!_sendSocket) {
        _sendSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    }
    return _sendSocket;
}

@end
