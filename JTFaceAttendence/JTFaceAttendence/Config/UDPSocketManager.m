//
//  UDPSocketManager.m
//  JingTeYuHui
//
//  Created by 袁炳生 on 2021/4/13.
//  Copyright © 2021 WanCai. All rights reserved.
//

#import "UDPSocketManager.h"
#import "GCDAsyncUdpSocket.h"
@interface UDPSocketManager ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *sendSocket;

@property (nonatomic, assign) uint16_t sendPort;

@end

@implementation UDPSocketManager

- (instancetype)initUDPSocket {
    if (self = [super init]) {
        _sendSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (void)bindPort:(uint16_t)port {
    self.sendPort = port;
    NSError *error = nil;
    [self.sendSocket bindToPort:port error:&error];
    if (error) {
        DLog(@"%@",error.localizedDescription);
    }
}

- (void)sendContentStr:(NSString *)str toHost:(NSString *)host {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);//kCFStringEncodingGB_2312_80
    [self.sendSocket sendData:[str dataUsingEncoding:enc] toHost:host port:self.sendPort withTimeout:-1 tag:0];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    DLog(@"%@",error.localizedDescription);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    if (self.udpResultBlock) {
        self.udpResultBlock(@"UDP服务连接失败");
    }
    DLog(@"%@",error.localizedDescription);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    DLog(@"发送成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    if (self.udpResultBlock) {
        self.udpResultBlock(@"UDP数据发送失败");
    }
    DLog(@"%@",error);
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    if (_delegate && [_delegate respondsToSelector:@selector(udpManagerDidReceiveData:)]) {
        [_delegate udpManagerDidReceiveData:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }
    DLog(@"%@",filterContext);
}

- (void)dealloc {
    [self.sendSocket close];
    _sendSocket = nil;
}

@end
