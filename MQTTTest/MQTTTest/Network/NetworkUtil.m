//
//  NetworkUtil.m
//  LifeShanghai
//
//  Created by wenjun on 12-12-1.
//
//

#import "NetworkUtil.h"


#define HostOfApple @"www.apple.com"

@interface NetworkUtilDelegateObject : NSObject

@property (weak, nonatomic) id<NetworkUtilDelegate> delegate;
- (instancetype)initWithDelegate:(id<NetworkUtilDelegate>)delegate;

@end

@implementation NetworkUtilDelegateObject

- (instancetype)initWithDelegate:(id<NetworkUtilDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

@end

@interface NetworkUtil ()
{
    NSMutableArray *delegateQueue;
    Reachability * reachability;
}

@end


@implementation NetworkUtil

/**
 * 单例
 */
+ (instancetype)sharedInstance {
    static NetworkUtil *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [NetworkUtil new];
    });
    return singleton;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [delegateQueue removeAllObjects];
}

/**
 * 初始化
 */
- (instancetype)init {
    if (self = [super init]) {
        delegateQueue = [NSMutableArray array];
        reachability = [Reachability reachabilityWithHostName:HostOfApple];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification object:reachability];
        [reachability startNotifier];
    }
    return self;
}

/**
 * 网络代理
 */
/**
 * 添加代理
 * 移除代理
 */
- (void)addDelegate:(id<NetworkUtilDelegate>)delegate {
    if (!delegate) return;     // 非法值
    
    for (NetworkUtilDelegateObject *delegateObject in delegateQueue)
        if (delegate == delegateObject.delegate) return;    // 已经添加过了
    
    NetworkUtilDelegateObject *delegateObject = [[NetworkUtilDelegateObject alloc] initWithDelegate:delegate];
    [delegateQueue addObject:delegateObject];
}
- (void)removeDelegate:(id<NetworkUtilDelegate>)delegate {
    if (!delegate) return;     // 非法值
    
    for (int i = (int)delegateQueue.count - 1; i >= 0; -- i) {
        NetworkUtilDelegateObject *delegateObject = [delegateQueue objectAtIndex:i];
        
        if (delegateObject.delegate == nil) [delegateQueue removeObject:delegateObject];
        
        if (!(delegate == delegateObject.delegate)) continue;  // 找到删除
        
        [delegateQueue removeObject:delegateObject]; break;
    }
}

/**
 * 网络切换通知
 */
- (void)reachabilityChanged:(NSNotification *)note {
    for (int i = (int)delegateQueue.count - 1; i >= 0; -- i) {
        NetworkUtilDelegateObject *delegateObject = [delegateQueue objectAtIndex:i];
        
        if (delegateObject.delegate == nil) {
            [delegateQueue removeObject:delegateObject];
        } else if ([delegateObject.delegate respondsToSelector:@selector(networkUtil:networkStatusChanged:)]) {
            [delegateObject.delegate networkUtil:self networkStatusChanged:[self networkStatus]];
        }
    }
}

/**
 * 网络状态
 */
- (BOOL)isNetworkEnable {
    return !(reachability.currentReachabilityStatus == NotReachable);
}

- (NetworkStatus)networkStatus {
    return reachability.currentReachabilityStatus;
}

@end
