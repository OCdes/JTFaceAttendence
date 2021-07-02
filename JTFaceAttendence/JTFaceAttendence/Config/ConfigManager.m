//
//  ConfigManager.m
//  JTFaceAttendence
//
//  Created by lj on 2021/6/17.
//

#import "ConfigManager.h"
#import "BDFaceAdjustParamsTool.h"

static ConfigManager *_cm = nil;
@implementation ConfigManager

+ (instancetype)manager {
    if (_cm == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _cm = [[ConfigManager alloc] init];
        });
    }
    return _cm;
}

- (void)registerSDK {
    NSString* licensePath = [NSString stringWithFormat:@"%@.%@", FACE_LICENSE_NAME, FACE_LICENSE_SUFFIX ];
    [[FaceSDKManager sharedInstance] setLicenseID:FACE_LICENSE_ID andLocalLicenceFile:licensePath andRemoteAuthorize:true];
    NSLog(@"canWork = %d",[[FaceSDKManager sharedInstance] canWork]);
    NSLog(@"version = %@",[[FaceSDKManager sharedInstance] getVersion]);
    if (![[FaceSDKManager sharedInstance] canWork]) {
        NSLog(@"当前鉴权失败");
    } else {
        [[FaceSDKManager sharedInstance] initCollect];
        [self initConfig];
    }
    [AdminInfo shareInfo].token = @"123456778";
    [AdminInfo shareInfo].emp_name = @"张坤";
    [AdminInfo shareInfo].emp_department = @"人事部";
    [AdminInfo shareInfo].emp_position = @"认识经理";
    [AdminInfo shareInfo].avatarUrl = @"https://img2.baidu.com/it/u=3947572783,1476163811&fm=26&fmt=auto&gp=0.jpg";
}

- (void)initConfig {
    // 初始化SDK配置参数，可使用默认配置
    [USER_DEFAULTS setObject:@(YES) forKey:@"SoundMode"];
    [USER_DEFAULTS setObject:@(YES) forKey:@"LiveMode"];
    [USER_DEFAULTS setObject:@(NO) forKey:@"ByOrder"];
    // 设置最小检测人脸阈值
    [[FaceSDKManager sharedInstance] setMinFaceSize:200];
    // 设置截取人脸图片高
    [[FaceSDKManager sharedInstance] setCropFaceSizeWidth:480];
    // 设置截取人脸图片宽
    [[FaceSDKManager sharedInstance] setCropFaceSizeHeight:640];
    // 设置人脸遮挡阀值
    [[FaceSDKManager sharedInstance] setOccluThreshold:0.5];
    // 设置亮度阀值
    [[FaceSDKManager sharedInstance] setMinIllumThreshold:40];
    [[FaceSDKManager sharedInstance] setMaxIllumThreshold:240];
    // 设置图像模糊阀值
    [[FaceSDKManager sharedInstance] setBlurThreshold:0.3];
    // 设置头部姿态角度
    [[FaceSDKManager sharedInstance] setEulurAngleThrPitch:10 yaw:10 roll:10];
    // 设置人脸检测精度阀值
    [[FaceSDKManager sharedInstance] setNotFaceThreshold:0.6];
    // 设置抠图的缩放倍数
    [[FaceSDKManager sharedInstance] setCropEnlargeRatio:2.5];
    // 设置照片采集张数
    [[FaceSDKManager sharedInstance] setMaxCropImageNum:3];
    // 设置超时时间
    [[FaceSDKManager sharedInstance] setConditionTimeout:15];
    // 设置开启口罩检测，非动作活体检测可以采集戴口罩图片
    [[FaceSDKManager sharedInstance] setIsCheckMouthMask:true];
    // 设置开启口罩检测情况下，非动作活体检测口罩过滤阈值，默认0.8 不需要修改
    [[FaceSDKManager sharedInstance] setMouthMaskThreshold:0.8f];
    // 设置原始图缩放比例
    [[FaceSDKManager sharedInstance] setImageWithScale:0.8f];
    // 设置图片加密类型，type=0 基于base64 加密；type=1 基于百度安全算法加密
    [[FaceSDKManager sharedInstance] setImageEncrypteType:0];
    // 初始化SDK功能函数
    [[FaceSDKManager sharedInstance] initCollect];
    // 设置人脸过远框比例
    [[FaceSDKManager sharedInstance] setMinRect:0.4];
    
//    /// 设置用户设置的配置参数
    [BDFaceAdjustParamsTool setDefaultConfig];
}

@end
