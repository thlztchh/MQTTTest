//
//  NetworkUtil.h
//  LifeShanghai
//
//  Created by wenjun on 12-12-1.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

#define NetworkUtilInstance [NetworkUtil sharedInstance]

/**
 * 网络发生变化时回调
 */
@class NetworkUtil;
@protocol NetworkUtilDelegate <NSObject>
@required
- (void)networkUtil:(NetworkUtil *)util networkStatusChanged:(NetworkStatus)status;
@end

@interface NetworkUtil : NSObject

+ (instancetype)sharedInstance;

/**
 * 网络代理
 */
- (void)addDelegate:(id<NetworkUtilDelegate>)delegate;
- (void)removeDelegate:(id<NetworkUtilDelegate>)delegate;

/**
 * 网络状态
 */
- (BOOL)isNetworkEnable;
- (NetworkStatus)networkStatus;

@end
