//
//  LNBaseMqttClientModel.m
//  Rinnai
//
//  Created by 朱天聪 on 2018/10/19.
//  Copyright © 2018年 Hadlinks. All rights reserved.
//

#import "LNMqttClientModel.h"
@interface LNMqttClientModel () <MQTTClientModelDelegate>

@end


@implementation LNMqttClientModel
+ (instancetype)sharedInstance {
    static LNMqttClientModel *user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[LNMqttClientModel alloc]init];
        MQTTClientModelStance.delegate = user;
       
    });
    return user;
}

#pragma mark - 绑定
- (void)bindWithUserName:(NSString *)username password:(NSString *)password epoch:(long long)epoch {
    
    NSString *usernameMQTT = [NSString stringWithFormat:@"a:rinnai:SR:01:SR:%@",username];
    NSString *cliendId = [NSString stringWithFormat:@"a:rinnai:SR:01:SR:%@:%lld",username,epoch];

    [MQTTClientModelStance bindWithUserName:usernameMQTT password:password cliendId:cliendId isSSL:YES];
    
}

- (void)disconnect {
    [MQTTClientModelStance disconnect];
}

- (void)reConnect {
    if (MQTTClientModelStance.mySessionManager.state != MQTTSessionManagerStateConnected && MQTTClientModelStance.mySessionManager.state != MQTTSessionManagerStateConnecting) {
        [MQTTClientModelStance reConnect];
    }
    else {
        NSLog(@"已经连接，不需要重连");
    }
}


#pragma mark - 订阅topic
- (void)subscribeTopic:(NSString *)topic {
    
    [MQTTClientModelStance subscribeTopic:topic];
}


#pragma mark - 取消订阅
- (void)unsubscribeTopic:(NSString *)topic {
    [MQTTClientModelStance unsubscribeTopic:topic];

}

#pragma mark - set命令
//开关
- (void)switchWithDevice {
    
    NSDictionary *dict = @{@"ptn":@"J00",
                           @"code":@"1234",
                           @"id": @"1234",
                           @"sum":@"1",
                           @"enl":@[@{@"id":@"power",
                                      @"data":@"31"
                                      }]
                           };
    
    [MQTTClientModelStance sendDataToTopic:[HeadTopic stringByAppendingString:@"/set/"] dict:dict];
    
}



#pragma mark - MQTTClientModelDelegate
- (void)MQTTClientModel_handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    
    NSArray *array = [topic componentsSeparatedByString:@"/"];
    NSString *str = [[NSString alloc]initWithBytes:&(((UInt8 *)[data bytes])[0]) length:data.length encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [self dictionaryWithJsonString:str];
    NSLog(@"str = %@ \n -------- dict:%@ --------- \n",str,dict);
    
    __weak typeof(self) weakSelf = self;
    //解析
    
}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
