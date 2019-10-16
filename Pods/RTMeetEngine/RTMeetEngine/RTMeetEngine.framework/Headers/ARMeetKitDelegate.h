//
//  ARMeetKitDelegate.h
//  RTMeetEngine
//
//  Created by zjq on 2019/1/15.
//  Copyright © 2019 EricTao. All rights reserved.
//

#ifndef ARMeetKitDelegate_h
#define ARMeetKitDelegate_h
#import <AVFoundation/AVFoundation.h>

#import "ARMeetOption.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif

@protocol ARMeetKitDelegate <NSObject>
@required

#pragma mark - RTC状态回调
/**
 加入会议成功
 
 @param meetId 会议号(在开发者业务系统中保持唯一的Id)
 */
- (void)onRTCJoinMeetOK:(NSString *)meetId;

/**
 加入会议失败
 
 @param meetId 会议号(在开发者业务系统中保持唯一的Id)
 @param code 状态码
 @param reason 错误原因，RTC错误或者token错误(错误值自己平台定义)
 */
- (void)onRTCJoinMeetFailed:(NSString *)meetId code:(ARMeetCode)code reason:(NSString *)reason;

/**
 RTC服务已断开
 
 说明：收到该消息后，在网络恢复后，会有重连，重连成功，会有onRTCJoinMeetOK回调。
 */
- (void)onRTCConnectionLost;

/**
 离开会议
 
 @param code 状态码
 */
- (void)onRTCLeaveMeet:(ARMeetCode)code;

#pragma mark - RTC音视频流回调

/**
 其他与会者加入(音视频)
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 @param pubId RTC服务生成流的Id (用于标识与会者发布的流)
 @param userId 开发者自己平台的用户Id
 @param userData 开发者自己平台的相关信息（昵称，头像等)
 说明：其他与会者进入会议的回调，开发者需调用设置其他与会者视频窗口(setRemoteVideoRender)方法。
 */
- (void)onRTCOpenRemoteVideoRender:(NSString *)peerId pubId:(NSString *)pubId userId:(NSString *)userId userData:(NSString *)userData;

/**
 其他与会者离开(音视频)
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 @param pubId RTC服务生成流的Id (用于标识与会者发布的流)
 @param userId 开发者自己平台的用户Id
 说明：其他与会者离开将会回调此方法，需本地移除与会者视频视图。
 */
- (void)onRTCCloseRemoteVideoRender:(NSString *)peerId pubId:(NSString *)pubId userId:(NSString *)userId;

/**
 其他与会者加入(音频)
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 @param userId 开发者自己平台的Id
 @param userData 开发者自己平台的相关信息（昵称、头像等)
 */
- (void)onRTCOpenRemoteAudioTrack:(NSString *)peerId userId:(NSString *)userId userData:(NSString *)userData;

/**
 其他与会者离开(音频)
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 @param userId 开发者自己平台的用户Id
 */
- (void)onRTCCloseRemoteAudioTrack:(NSString *)peerId userId:(NSString *)userId;

/**
 用户开启桌面共享
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 @param pubId RTC服务生成流的Id (用于标识与会者发布的流)
 @param userId 开发者自己平台的Id
 @param userData 开发者自己平台的相关信息（昵称、头像等)
 说明：开发者需调用设置其他与会者视频窗口(setRemoteVideoRender)方法。
 */
- (void)onRTCOpenRemoteScreenRender:(NSString *)peerId pubId:(NSString *)pubId userId:(NSString *)userId userData:(NSString *)userData;

/**
 用户退出桌面共享
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 @param pubId RTC服务生成流的Id (用于标识与会者发布的流)
 @param userId 开发者自己平台的用户Id
 说明：其他与会者离开将会回调此方法，需本地移除屏幕共享窗口。
 */
- (void)onRTCCloseRemoteScreenRender:(NSString *)peerId pubId:(NSString *)pubId userId:(NSString *)userId;

#pragma mark - 音视频状态回调

/**
其他与会者对音视频的操作

@param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
@param audio YES为打开音频，NO为关闭音频
@param video YES为打开视频，NO为关闭视频
*/
- (void)onRTCRemoteAVStatus:(NSString *)peerId audio:(BOOL)audio video:(BOOL)video;

/**
 别人对自己音视频的操作
 
 @param audio YES为打开音频，NO为关闭音频
 @param video YES为打开视频，NO为关闭视频
 */
- (void)onRTCLocalAVStatus:(BOOL)audio video:(BOOL)video;

#pragma mark - 视频第一帧的回调、视频大小变化回调

/**
 本地视频第一帧
 
 @param size 视频窗口大小
 */
- (void)onRTCFirstLocalVideoFrame:(CGSize)size;

/**
 远程视频第一帧
 
 @param size 视频窗口大小
 @param pubId RTC服务生成流的Id (用于标识与会者发布的流)
 */
- (void)onRTCFirstRemoteVideoFrame:(CGSize)size pubId:(NSString *)pubId;

/**
 本地窗口大小的回调
 
 @param size 视频窗口大小
 */
- (void)onRTCLocalVideoViewChanged:(CGSize)size;

/**
 远程窗口大小的回调
 
 @param size 视频窗口大小
 @param pubId RTC服务生成流的Id (用于标识与会者发布的流)
 */
- (void)onRTCRemoteVideoViewChanged:(CGSize)size pubId:(NSString *)pubId;

#pragma mark - 网络状态和音频检测

/**
 其他与会者音频检测回调
 
 @param peerId RTC服务生成的与会者标识Id（用于标识与会者用户，每次随机生成）
 @param userId 开发者自己平台的用户Id
 @param level 音频大小（0~100）
 @param time 音频检测在nTime毫秒内不会再回调该方法（单位：毫秒）
 说明：与会者关闭音频后（setLocalAudioEnable为NO）,该回调将不再回调。对方关闭音频检测后（setAudioActiveCheck为NO）,该回调也将不再回调。
 */
- (void)onRTCRemoteAudioActive:(NSString *)peerId userId:(NSString *)userId audioLevel:(int)level showTime:(int)time;

/**
 本地音频检测回调
 
 @param level 音频大小（0~100）
 @param time 音频检测在nTime毫秒内不会再回调该方法（单位：毫秒）
 说明：本地关闭音频后（setLocalAudioEnable为NO）,该回调将不再回调。对方关闭音频检测后（setAudioActiveCheck为NO）,该回调也将不再回调。
 */
- (void)onRTCLocalAudioActive:(int)level showTime:(int)time;

/**
 其他与会者网络质量回调

 @param peerId RTC服务生成的与会者标识Id（用于标识与会者用户，每次随机生成）
 @param userId 用户平台Id
 @param netSpeed 网络上行
 @param packetLost 丢包率
 @param netQuality 网络质量
 */
- (void)onRTCRemoteNetworkStatus:(NSString *)peerId userId:(NSString *)userId netSpeed:(int)netSpeed packetLost:(int)packetLost netQuality:(ARNetQuality)netQuality;

/**
 本地网络质量回调

 @param netSpeed 网络上行
 @param packetLost 丢包率
 @param netQuality 网络质量
 */
- (void)onRTCLocalNetworkStatus:(int)netSpeed packetLost:(int)packetLost netQuality:(ARNetQuality)netQuality;

/**
 收到消息回调
 
 @param userId 发送消息者在自己平台下的Id
 @param userName 发送消息者的昵称
 @param headerUrl 发送者的头像
 @param content 消息内容
 */
- (void)onRTCUserMessage:(NSString *)userId userName:(NSString *)userName userHeader:(NSString *)headerUrl content:(NSString *)content;

#pragma mark - 主持人模式相关回调 ARMeetTypeHoster

/**
 主持人上线
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 @param userId 开发者自己平台的Id
 @param userData 开发者自己平台的相关信息（昵称，头像等)
 说明：只有主持模式下的游客身份登录才有用。
 */
- (void)onRTCHosterOnLine:(NSString *)peerId userId:(NSString *)userId userData:(NSString *)userData;

/**
 主持人下线
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 说明：只有主持模式下的游客身份登录才有用。
 */
- (void)onRTCHosterOffLine:(NSString *)peerId;

/**
 1v1授课开启
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 @param userId 开发者自己平台的Id
 @param userData 开发者自己平台的相关信息（昵称，头像等)
 */
- (void)onRTCTalkOnlyOn:(NSString *)peerId userId:(NSString *)userId userData:(NSString *)userData;

/**
 1v1授课关闭
 
 @param peerId RTC服务生成的标识Id (用于标识与会者，每次加入会议随机生成)
 */
- (void)onRTCTalkOnlyOff:(NSString *)peerId;

#pragma mark - zoom 模式回调 ARMeetTypeZoom

/**
 zoom模式页码变化
 
 @param zoomType 当前模式
 @param allPage 总页码（一页显示4个）
 @param currentPage 当前页
 @param allRenderNum 当前服务上有多少个渲染，根据此数量来判断页码添加删除
 @param index 开始位置
 @param showNum 显示多少个
 */
- (void)onRTCZoomPageInfo:(ARZoomType)zoomType
                  allPage:(int)allPage
              currentPage:(int)currentPage
             allRenderNum:(int)allRenderNum
               beginIndex:(int)index
                  showNum:(int)showNum;

#pragma mark -  Video Audio data
/**
 获取视频的原始采集数据
 
 @param sampleBuffer 视频数据
 @return 视频对象（处理过或者没做处理）
 */
- (CVPixelBufferRef)onRTCCaptureVideoPixelBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 本地音频数据回调

 @param audioSamples pcm数据
 @param sampleRate 采样率
 @param channel 声道
 @param length 数据长度
 */
- (void)onRTCLocalAudioPcmBuffer:(const char * _Nullable)audioSamples sample:(int)sampleRate channel:(int)channel length:(int)length;

/**
 远程音频数据回调

 @param audioSamples pcm数据
 @param sampleRate 采样率
 @param channel 声道
 @param length 数据长度
 @param peerId RTC服务生成的与会者标识Id（用于标识与会者用户，每次随机生成）
 */
- (void)onRTCRemoteAudioPcmBuffer:(const char * _Nullable)audioSamples sample:(int)sampleRate channel:(int)channel length:(int)length peerId:(NSString *_Nullable)peerId;

@end

#endif /* ARMeetKitDelegate_h */

