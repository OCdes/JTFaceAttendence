//
//  UDPSocketManager.h
//  JingTeYuHui
//
//  Created by 袁炳生 on 2021/4/13.
//  Copyright © 2021 WanCai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UDPManagerDelegate <NSObject>

- (void)udpManagerDidReceiveData:(NSString *)contentStr;

@end

@interface UDPSocketManager : NSObject

@property (nonatomic, weak) id<UDPManagerDelegate> delegate;

- (instancetype)initUDPSocket;

- (void)bindPort:(uint16_t)port;

- (void)sendContentStr:(NSString *)str toHost:(NSString *)host;

@property (nonatomic, strong) void(^udpResultBlock)(NSString *contentStr);

@end

NS_ASSUME_NONNULL_END
