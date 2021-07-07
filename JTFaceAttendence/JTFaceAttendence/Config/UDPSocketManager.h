//
//  UDPSocketManager.h
//  JingTeYuHui
//
//  Created by 袁炳生 on 2021/4/13.
//  Copyright © 2021 WanCai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UDPSocketManager : NSObject

- (instancetype)initUDPSocketBindID:(uint16_t )port;

- (void)sendContentStr:(NSString *)str toHost:(NSString *)host;

@end

NS_ASSUME_NONNULL_END
