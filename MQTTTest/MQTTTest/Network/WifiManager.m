//
//  WifiManager.m
//  AirCleaner
//
//  Created by Shaojun Han on 10/14/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import <systemconfiguration/captivenetwork.h>
#import <corefoundation/corefoundation.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <ifaddrs.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <sys/socket.h>

#import "WifiManager.h"

@interface WifiManagerDelegateObject : NSObject

@property (weak, nonatomic) id<WifiManagerDelegate> delegate;
- (instancetype)initWithDelegate:(id<WifiManagerDelegate>)delegate;

@end

@implementation WifiManagerDelegateObject

- (instancetype)initWithDelegate:(id<WifiManagerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

@end

@interface WifiManager ()
{
    Reachability    *reachability;  // 可达性
    NSMutableArray  *delegateQueue;
}

@end

@implementation WifiManager

/**
 * 单例方法
 */
+ (instancetype)sharedInstance {
    static WifiManager *wifiManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wifiManager = [[WifiManager alloc] init];
    });
    return wifiManager;
}

- (void)dealloc {
    [reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [delegateQueue removeAllObjects];
}

- (instancetype)init {
    if (self = [super init]) {
        delegateQueue = [NSMutableArray array];
        reachability = [Reachability reachabilityForLocalWiFi];
        // 注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification object:reachability];
        [reachability startNotifier];
    }
    return self;
}

/**
 * 添加代理
 * 移除代理
 */
- (void)addDelegate:(id<WifiManagerDelegate>)delegate {
    if (!delegate) return;     // 非法值
    
    for (WifiManagerDelegateObject *delegateObject in delegateQueue)
        if (delegate == delegateObject.delegate) return;    // 已经添加过了
    
    WifiManagerDelegateObject *delegateObject = [[WifiManagerDelegateObject alloc] initWithDelegate:delegate];
    [delegateQueue addObject:delegateObject];
}
- (void)removeDelegate:(id<WifiManagerDelegate>)delegate {
    if (!delegate) return;     // 非法值
    
    for (int i = (int)delegateQueue.count - 1; i >= 0; -- i) {
        WifiManagerDelegateObject *delegateObject = [delegateQueue objectAtIndex:i];
        
        if (delegateObject.delegate == nil) [delegateQueue removeObject:delegateObject];
        
        if (!(delegate == delegateObject.delegate)) continue;  // 找到删除
        
        [delegateQueue removeObject:delegateObject]; break;
    }
}

/**
 * 网络切换通知
 */
- (void)reachabilityChanged:(NSNotification *)note {
    NSLog(@">>>>>>>>wifi manager wifi changed.");
    for (int i = (int)delegateQueue.count - 1; i >= 0; -- i) {
        WifiManagerDelegateObject *delegateObject = [delegateQueue objectAtIndex:i];
        
        if (delegateObject.delegate == nil) {
            [delegateQueue removeObject:delegateObject];
        } else if ([delegateObject.delegate respondsToSelector:@selector(manager:reachabilityChanged:)]) {
            NSLog(@">>>>>>>>wifi manager delegate = %@.", delegateObject.delegate);
            [delegateObject.delegate manager:self reachabilityChanged:[self networkStatus]];
        }
    }
}

/**
 * 网络可达性测试
 */
- (NetworkStatus)networkStatus {
    return reachability.currentReachabilityStatus;
}
-(BOOL)isWifiEnable {
    return reachability.currentReachabilityStatus == ReachableViaWiFi;
}


/**
 * 获取当前wifi名
 */
- (NSString *)wifiName {
    NSString *wifiName = nil;
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray == nil) return wifiName;
    
    CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
    if (myDict != nil) {
        NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
        wifiName = [dict valueForKey:@"SSID"];
    }
    
    CFRelease(myArray);
    return wifiName;
}

/**
 * 获取路由器的广播地址
 */
- (NSString *)broadAddress {
    
    NSString *routerBroadCastAddress = @"255.255.255.255";
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    if (getifaddrs(&interfaces) == 0 && (temp_addr = interfaces) != NULL) {
        //Loop through linked list of interfaces
        do {
            if(temp_addr->ifa_addr->sa_family == AF_INET &&
               [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                // Get NSString from C String //ifa_addr
                //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                //routerBroadCastAddress
                routerBroadCastAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                break;  // 找到广播地址，结束

                /**
                // localIPAddress
                localIPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                //netmask
                netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                //en0Port
                en0Port = [NSString stringWithUTF8String:temp_addr->ifa_name];
                //address
                address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];   **/
            }
            
        } while ((temp_addr = temp_addr->ifa_next) != NULL);
    }
    //Free memory
    freeifaddrs(interfaces);
    return routerBroadCastAddress;
}

@end
