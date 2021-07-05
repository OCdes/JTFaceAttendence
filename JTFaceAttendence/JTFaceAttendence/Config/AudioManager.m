//
//  AudioManager.m
//  JTFaceAttendence
//
//  Created by lj on 2021/7/5.
//

#import "AudioManager.h"
#import "NSString+Tool.h"
#import <AVFoundation/AVFoundation.h>
static AudioManager *_instance = nil;

@interface AudioManager ()

@property (nonatomic, strong) AVPlayer *aplayer;

@end

@implementation AudioManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[AudioManager alloc] init];
        }
    });
    return _instance;
}

- (void)playWord:(NSString *)content {
    [self.aplayer pause];
    [self playerRemoveObserver];
    if (content.length > 0) {
//        //日期处理
//        NSDate *date = [NSDate date];
//        NSTimeInterval interval = [date timeIntervalSince1970];
//        NSString *intervalStr = [NSString stringWithFormat:@"%.0f",interval*10000];
//        //32位随机数
//        NSString *nonceStr = [NSString stringWithFormat:@"%ld",(long)(arc4random()*pow(10, 31))];
//        NSString *placeKey = [AdminInfo shareInfo].placeKey;
//        //sign 签名
//        NSString *secretKey = @"7dkc86acd1438f1";
//        NSString *paramStr = [NSString stringWithFormat:@"%@%@%@",content, intervalStr,nonceStr];
//        NSString *signStr = [paramStr HmacSHA256WithSecretKey:secretKey];
//        //参数处理+
//        NSDictionary *dict = @{@"word":content,@"timestamp":intervalStr,@"nonceStr":nonceStr,@"placeKey":placeKey,@"sign":signStr};
//        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
//        [manager POST:[NSString stringWithFormat:@"%@%@",Base_Url,POST_EXCHANGEWORDTOAUDIO] parameters:dict headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
//
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"%@",responseObject);
//            NSDictionary *dict = (NSDictionary *)responseObject;
//            NSNumber *code = (NSNumber *)[dict objectForKey:@"code"];
//            NSDictionary *dataDict = (NSDictionary *)[dict objectForKey:@"data"];
//            if ([code  isEqual: @(0)]) {
//                NSString *audioUrl = (NSString *)[dataDict objectForKey:@"audioUrl"];
//                AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:audioUrl]];
//                if (self.aplayer.currentItem) {
//                    [self.aplayer replaceCurrentItemWithPlayerItem:item];
//                } else {
//                    self.aplayer = [AVPlayer playerWithPlayerItem:item];
//                }
//
//                [self playerAddObsever];
//            }
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"%@",error.localizedDescription);
//        }];
        NSURL *audioPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bugscaner-tts-auido" ofType:@"mp3"]];
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:audioPath];
        if (self.aplayer.currentItem) {
            [self.aplayer replaceCurrentItemWithPlayerItem:item];
        } else {
            self.aplayer = [AVPlayer playerWithPlayerItem:item];
        }
        
        [self playerAddObsever];
    } else {
        
    }
}

- (void)attendenceFailuer {
    NSURL *audioPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"attendenceFailure" ofType:@"mp3"]];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:audioPath];
    if (self.aplayer.currentItem) {
        [self.aplayer replaceCurrentItemWithPlayerItem:item];
    } else {
        self.aplayer = [AVPlayer playerWithPlayerItem:item];
    }
    
    [self playerAddObsever];
}

- (void)attendenceSuccess {
    NSURL *audioPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"attendenceSuccess" ofType:@"mp3"]];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:audioPath];
    if (self.aplayer.currentItem) {
        [self.aplayer replaceCurrentItemWithPlayerItem:item];
    } else {
        self.aplayer = [AVPlayer playerWithPlayerItem:item];
    }
    
    [self playerAddObsever];
}

- (void)playerAddObsever {
    [self.aplayer.currentItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [change[@"new"] integerValue];
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                // 开始播放
                [self.aplayer play];
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"加载失败");
                NSLog(@"播放错误");
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"未知资源");
                NSLog(@"播放错误");
            }
                break;
            default:
                break;
        }
    }
}

- (void)playerRemoveObserver {
    [self.aplayer.currentItem removeObserver:self  forKeyPath:@"status"];
}

#pragma mark -lazyload

- (AVPlayer *)aplayer {
    if (!_aplayer) {
        _aplayer = [[AVPlayer alloc] init];
        _aplayer.volume = 1.0;
    }
    return _aplayer;
}

@end
