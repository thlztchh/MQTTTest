//
//  MQTTClientModel.h
//  Rinnai
//
//  Created by 朱天聪 on 2018/5/10.
//  Copyright © 2018年 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"
#import "MQTTPackage.h"
#import <MQTTClient/MQTTClient.h>

#define MQTTClientModelStance [MQTTClientModel sharedInstance]

@protocol MQTTClientModelDelegate <NSObject>
@optional
- (void)MQTTClientModel_handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained;
@end

@interface MQTTClientModel : NSObject

@property (nonatomic, assign) BOOL isDiscontent;
@property (nonatomic, weak) id <MQTTClientModelDelegate> delegate;

@property (nonatomic,strong) MQTTSessionManager *mySessionManager;

+ (instancetype)sharedInstance;


- (void)bindWithUserName:(NSString *)username password:(NSString *)password cliendId:(NSString *)cliendId isSSL:(BOOL)isSSL;

- (void)disconnect;

- (void)reConnect;

/**
 订阅主题
 
 @param topic 主题
 */
typedef void (^SubscribeTopicHandler)(NSString *topic, BOOL success);

- (void)subscribeTopic:(NSString *)topic;

/**
 取消订阅
 
 @param topic 主题
 */
- (void)unsubscribeTopic:(NSString *)topic;

/**
 发布消息
 */
- (void)sendDataToTopic:(NSString *)topic dict:(NSDictionary *)dict;

@end
