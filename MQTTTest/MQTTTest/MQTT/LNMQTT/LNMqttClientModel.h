//
//  LNBaseMqttClientModel.h
//  Rinnai
//
//  Created by 朱天聪 on 2018/10/19.
//  Copyright © 2018年 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTClientModel.h"

#define LNMqttClientModelStance [LNMqttClientModel sharedInstance]

@interface LNMqttClientModel : NSObject
+ (instancetype)sharedInstance;


#pragma mark - 登录 解绑
- (void)bindWithUserName:(NSString *)username password:(NSString *)password epoch:(long long)epoch;

- (void)disconnect;

- (void)reConnect;

#pragma mark - 订阅命令
/**
 订阅设备inf、res、sys三种topic
 */
- (void)subscribeTopic:(NSString *)topic;

#pragma mark - 取消订阅
/**
 取消订阅设备inf、res、sys三种topic
 */
- (void)unsubscribeTopic:(NSString *)topic;

#pragma mark - set命令 采暖炉
/**
 开关
 */
- (void)switchWithDevice;

@end
