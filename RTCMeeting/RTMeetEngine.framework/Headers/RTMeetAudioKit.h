//
//  RTMeetAudioKit.h
//  RTMeetEngine
//
//  Created by derek on 2017/10/19.
//  Copyright © 2017年 EricTao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTMeetAudioKitDelegate.h"
#import "AnyRTCWriteBlockDelegate.h"

@interface RTMeetAudioKit : NSObject

/**
 实例化会议对象
 
 @param delegate RTC相关回调代理
 @return 会议对象
 */
- (instancetype)initWithDelegate:(id<RTMeetAudioKitDelegate>)delegate;

/**
 设置本地音频是否传输
 
 @param bEnable 打开或关闭本地音频
 说明：yes为传输音频,no为不传输音频，默认传输
 */
- (void)setLocalAudioEnable:(bool)bEnable;
/**
 设置扬声器开关
 
 @param bOn YES:打开扬声器，NO:关闭扬声器
 说明：扬声器默认打开
 */
- (void)setSpeakerOn:(bool)bOn;

/**
 设置音频检测

 @param bOn 是否开启音频检测
 说明：默认打开
 */
- (void)setAudioActiveCheck:(bool)bOn;
#pragma mark RTC function for line

/**
 加入会议
 
 @param strAnyRTCId strAnyRTCId 会议号（可以在AnyRTC 平台获得，也可以根据自己平台，分配唯一的一个ID号）
 @param strUserId 播在开发者自己平台的id，可选
 @param strUserData 播在开发者自己平台的相关信息（昵称，头像等），可选。(限制512字节)
 @return 加入会议成功或者失败
 */
- (BOOL)joinRTC:(NSString*)strAnyRTCId andUserId:(NSString*)strUserId andUserData:(NSString*)strUserData;

/**
 离开会议室
 说明：相当于析构函数
 */
- (void)leaveRTC;

#pragma mark - 消息
/**
 发送消息
 
 @param strUserName 用户昵称(最大256字节)，不能为空，否则发送失败；
 @param strUserHeaderUrl 用户头像(最大512字节)，可选
 @param strContent 消息内容(最大1024字节)不能为空，否则发送失败；
 @return YES/NO 发送成功/发送失败
 说明：默认普通消息。以上参数均会出现在参会者的消息回调方法中，如果加入RTC（joinRTC）没有设置strUserid，发送失败。
 */

- (int)sendUserMessage:(NSString*)strUserName andUserHeader:(NSString*)strUserHeaderUrl andContent:(NSString*)strContent;

#pragma mark - 白板功能模块
/**
 设置白板相关回调
 */
@property (nonatomic, weak)id<AnyRTCWriteBlockDelegate>delegate;
/**
 打开白板
 
 @param strWBInfo 白板相关信息。(限制512字节)
 说明：打开白板成功与失败，参考onRTCSetWhiteBoardEnableResult 回调方法
 */
- (void)openWhiteBoard:(NSString *)strWBInfo;

/**
 关闭白板
 */
- (void)closeWhiteBoard;
@end
