//
//  AttendenceViewModel.m
//  JTFaceAttendence
//
//  Created by lj on 2021/7/1.
//

#import "AttendenceViewModel.h"
#import "BDFaceImageShow.h"
#import "NSString+Tool.h"
#import "JTFaceImageAttendenceManager.h"
@implementation AttendenceViewModel

- (instancetype)init {
    if (self = [super init]) {
        self.suceessSubject = [RACSubject subject];
        self.failureSubject = [RACSubject subject];
    }
    return self;
}

- (void)requestAttendence {
    BDFaceImageShow *imgshow = [BDFaceImageShow sharedInstance];
    if (imgshow.successImage) {
        //图像处理
        UIImage *simg = imgshow.successImage;
        NSString *imgDataStr = [UIImageJPEGRepresentation(simg, 1) base64EncodedStringWithOptions:0];
        //日期处理
        NSDate *date = [NSDate date];
        NSTimeInterval interval = [date timeIntervalSince1970];
        NSString *intervalStr = [NSString stringWithFormat:@"%.0f",interval*10000];
        //32位随机数
        NSString *nonceStr = [NSString stringWithFormat:@"%ld",(long)(arc4random()*pow(10, 31))];
        NSString *placeKey = [AdminInfo shareInfo].placeKey;
        //sign 签名
        NSString *secretKey = @"7dkc86acd1438f1";
        NSString *paramStr = [NSString stringWithFormat:@"%@%@%@",imgDataStr, intervalStr,nonceStr];
        NSString *signStr = [paramStr HmacSHA256WithSecretKey:secretKey];
        //参数处理+
        NSDictionary *dict = @{@"base64Image":imgDataStr,@"timestamp":intervalStr,@"nonceStr":nonceStr,@"placeKey":placeKey,@"sign":signStr};
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSLog(@"%@",[NSString stringWithFormat:@"%@%@",Base_Url,POST_FACEATTENDENCE]);
        [manager POST:[NSString stringWithFormat:@"%@%@",Base_Url,POST_FACEATTENDENCE] parameters:dict headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            NSString *msg = responseDict[@"msg"];
            NSNumber *num = responseDict[@"code"];
            NSDictionary *data = responseDict[@"data"];
            if ([num isEqualToNumber:@(0)]) {
                EmpInfoModel *mo = [EmpInfoModel mj_objectWithKeyValues:data];
                mo.img = imgshow.successImage;
                [JTFaceImageAttendenceManager sharedInstance].lastEmpModel = mo;
                [self.suceessSubject sendNext:msg];
            } else {
                [self.failureSubject sendNext:msg];
            }
            [imgshow reset];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [imgshow reset];
            [self.failureSubject sendNext:nil];
        }];
    }
}



@end
