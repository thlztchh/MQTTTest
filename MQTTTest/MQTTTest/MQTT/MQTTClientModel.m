//
//  MQTTClientModel.m
//  Rinnai
//
//  Created by 朱天聪 on 2018/5/10.
//  Copyright © 2018年 Hadlinks. All rights reserved.
//

#import "MQTTClientModel.h"
#import "WifiManager.h"
@interface MQTTClientModel () <MQTTSessionManagerDelegate,WifiManagerDelegate>

@property (nonatomic,strong) MQTTCFSocketTransport *myTransport;

@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *cliendId;

//订阅的topic
@property (nonatomic,strong) NSMutableDictionary *subedDict;

@property (nonatomic,assign) BOOL isSSL;

@end
@implementation MQTTClientModel

+ (instancetype)sharedInstance {
    static MQTTClientModel *user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[MQTTClientModel alloc]init];
        [WifiManagerInstance addDelegate:user];
        
    });
    return user;
}

- (void)disconnect {
    
    self.isDiscontent = YES;
    //    self.isContented = NO;
    [self.mySessionManager disconnectWithDisconnectHandler:^(NSError *error) {
        NSLog(@"断开连接  error = %@",[error description]);
    }];
    [self.mySessionManager setDelegate:nil];
    self.mySessionManager = nil;
    
}


- (void)reConnect {
    
    if (self.mySessionManager && self.mySessionManager.port) {
        self.mySessionManager.delegate = self;
        self.isDiscontent = NO;
        [self.mySessionManager connectToLast:^(NSError *error) {
            NSLog(@"重新连接  error = %@",[error description]);
        }];
        self.mySessionManager.subscriptions = self.subedDict;
        
    }
    else {
        [self bindWithUserName:self.username password:self.password cliendId:self.cliendId isSSL:self.isSSL];
        
    }
    
}

#pragma mark - WifiManagerDelegate
- (void)manager:(WifiManager *)manager reachabilityChanged:(NetworkStatus)status {
    if (status == NotReachable) {
        [self disconnect];
#warning 网络改变所以设备离线
    }
    else if (self.mySessionManager.state != MQTTSessionManagerStateConnected) {
        [self reConnect];
    }
    
}

#pragma mark - 绑定
- (void)bindWithUserName:(NSString *)username password:(NSString *)password cliendId:(NSString *)cliendId isSSL:(BOOL)isSSL{
    
    self.username = username;
    self.password = password;
    self.cliendId = cliendId;
    self.isSSL = isSSL;

    [self.mySessionManager connectTo:AddressOfMQTTServer
                                port:self.isSSL?PortOfMQTTServerWithSSL:PortOfMQTTServer
                                 tls:self.isSSL
                           keepalive:60
                               clean:YES
                                auth:YES
                                user:self.username
                                pass:self.password
                                will:NO
                           willTopic:nil
                             willMsg:nil
                             willQos:MQTTQosLevelAtLeastOnce
                      willRetainFlag:NO
                        withClientId:self.cliendId
                      securityPolicy:[self customSecurityPolicy]
                        certificates:nil
                       protocolLevel:4
                      connectHandler:nil];
    
    
    self.isDiscontent = NO;
    self.mySessionManager.subscriptions = self.subedDict;
    
}

- (MQTTSSLSecurityPolicy *)customSecurityPolicy
{
    
    MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesCertificateChain = YES;
    securityPolicy.validatesDomainName = NO;
    return securityPolicy;
}


#pragma mark ---- 状态
- (void)sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MQTTSessionManagerState)newState {
    switch (newState) {
        case MQTTSessionManagerStateConnected:
            NSLog(@"eventCode -- 连接成功");
            break;
        case MQTTSessionManagerStateConnecting:
            NSLog(@"eventCode -- 连接中");
            
            break;
        case MQTTSessionManagerStateClosed:
            NSLog(@"eventCode -- 连接被关闭");
            break;
        case MQTTSessionManagerStateError:
            NSLog(@"eventCode -- 连接错误");
            break;
        case MQTTSessionManagerStateClosing:
            NSLog(@"eventCode -- 关闭中");
            
            break;
        case MQTTSessionManagerStateStarting:
            NSLog(@"eventCode -- 连接开始");
            
            break;
            
        default:
            break;
    }
}


#pragma mark MQTTSessionManagerDelegate
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(MQTTClientModel_handleMessage:onTopic:retained:)]) {
        [self.delegate MQTTClientModel_handleMessage:data onTopic:topic retained:retained];
    }
}


#pragma mark - 订阅
- (void)subscribeTopic:(NSString *)topic{
    
    NSLog(@"当前需要订阅-------- topic = %@",topic);
    
    if (![self.subedDict.allKeys containsObject:topic]) {
        [self.subedDict setObject:[NSNumber numberWithLong:MQTTQosLevelAtLeastOnce] forKey:topic];
        NSLog(@"订阅字典 ----------- = %@",self.subedDict);
        self.mySessionManager.subscriptions =  self.subedDict;
    }
    else {
        NSLog(@"已经存在，不用订阅");
    }
    
}

#pragma mark - 取消订阅
- (void)unsubscribeTopic:(NSString *)topic {
    
    NSLog(@"当前需要取消订阅-------- topic = %@",topic);
    
    if ([self.subedDict.allKeys containsObject:topic]) {
        [self.subedDict removeObjectForKey:topic];
        NSLog(@"更新之后的订阅字典 ----------- = %@",self.subedDict);
        self.mySessionManager.subscriptions =  self.subedDict;
    }
    else {
        NSLog(@"不存在，无需取消");
    }
    
}

#pragma mark - 发布消息
- (void)sendDataToTopic:(NSString *)topic dict:(NSDictionary *)dict {
    
    NSLog(@"发送命令 topic = %@  dict = %@",topic,dict);
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    [self.mySessionManager sendData:data topic:topic qos:MQTTQosLevelAtLeastOnce retain:NO];
}

#pragma mark - 懒加载
- (MQTTSessionManager *)mySessionManager {
    if (!_mySessionManager) {
        _mySessionManager = [[MQTTSessionManager alloc]init];
        _mySessionManager.delegate = self;
    }
    return _mySessionManager;
}

- (MQTTCFSocketTransport *)myTransport {
    if (!_myTransport) {
        _myTransport = [[MQTTCFSocketTransport alloc]init];
        _myTransport.host = AddressOfMQTTServer;
        NSLog(@"AddressOfMQTTServer = %@",AddressOfMQTTServer);
        _myTransport.port = self.isSSL?PortOfMQTTServerWithSSL:PortOfMQTTServer;
        _myTransport.tls = self.isSSL;
    }
    return _myTransport;
}

- (NSMutableDictionary *)subedDict {
    if (!_subedDict) {
        _subedDict = [NSMutableDictionary dictionary];
    }
    return _subedDict;
}
@end

