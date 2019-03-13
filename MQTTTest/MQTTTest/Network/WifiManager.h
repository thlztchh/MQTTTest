//
//  WifiManager.h
//  AirCleaner
//
//  Created by Shaojun Han on 10/14/15.
//  Copyright © 2015 HadLinks. All rights reserved.

#import <Foundation/Foundation.h>
#import "Reachability.h"

#define WifiManagerInstance [WifiManager sharedInstance]

/**
 * 本地wifi变化时代理
 */
@class WifiManager;
@protocol WifiManagerDelegate <NSObject>
@optional
- (void)manager:(WifiManager *)manager reachabilityChanged:(NetworkStatus)status;

@end

/**
 * wifi管理类
 */
@interface WifiManager : NSObject

/**
 * wifi管理只保留一个wifi名和密码
 */
@property (strong, nonatomic) NSString *wifiName;       // wifi名
@property (strong, nonatomic) NSString *broadAddress;   // 广播地址

/**
 * 单例方法
 */
+ (instancetype)sharedInstance;

/**
 * 添加代理
 * 移除代理
 */
- (void)addDelegate:(id<WifiManagerDelegate>)delegate;
- (void)removeDelegate:(id<WifiManagerDelegate>)delegate;

/**
 * 网络可达性测试
 */
- (NetworkStatus)networkStatus;
-(BOOL)isWifiEnable;

/**
 * 获取路由器的广播地址
 */
- (NSString *)broadAddress;

/**
 * 获取当前wifi名
 */
- (NSString *)wifiName;

@end
