//
//  ARMeetKit.h
//  RTMeetEngine
//
//  Created by zjq on 2019/1/15.
//  Copyright © 2019 EricTao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARMeetOption.h"
#import "ARMeetKitDelegate.h"
#import "ARShareDelegate.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIView VIEW_CLASS;
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView VIEW_CLASS;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ARMeetKit : NSObject

/**
 实例化会议对象
 
 @param delegate RTC相关回调代理
 @param option 配置信息
 @return 会议对象
 */
- (instancetype)initWithDelegate:(id <ARMeetKitDelegate>)delegate option:(ARMeetOption *)option;

#pragma mark Common function

/**
 设置本地音频是否传输
 
 @param enable YES传输音频，NO不传输音频，默认传输
 */
- (void)setLocalAudioEnable:(BOOL)enable;

/**
 设置本地视频是否传输
 
 @param enable YES为传输视频，NO为不传输视频，默认视频传输
 */
- (void)setLocalVideoEnable:(BOOL)enable;

/**
 获取本地音频传输是否打开
 
 @return 音频是否传输
 */
- (BOOL)localAudioEnabled;

/**
 获取本地视频传输是否打开
 
 @return 视频是否传输
 */
- (BOOL)localVideoEnabled;

/**
 切换前后摄像头
 */
- (void)switchCamera;

/**
 设置扬声器开关
 
 @param on YES打开扬声器，NO关闭扬声器，默认打开
 */
- (void)setSpeakerOn:(BOOL)on;

/**
 设置音频检测

 @param on 是否开启音频检测，默认打开
 @return 操作是否成功
 */
- (BOOL)setAudioActiveCheck:(BOOL)on;

/**
 设置本地视频采集窗口
 
 @param render 视频显示对象
 */

- (void)setLocalVideoCapturer:(VIEW_CLASS * _Nullable)render;

/**
 设置本地显示模式
 
 @param videoRenderMode 显示模式，默认ARVideoRenderScaleAspectFill，等比例填充视图模式
 */
- (void)updateLocalVideoRenderModel:(ARVideoRenderMode)videoRenderMode;

/**
 重置音频录音和播放
 
 说明：使用AVplayer播放后调用该方法。
 */
- (void)doRestartAudioRecord;

/**
 设置本地前置摄像头镜像是否打开
 
 @param enable YES打开，NO关闭
 @return 镜像成功与否
 */
- (BOOL)setFontCameraMirrorEnable:(BOOL)enable;

/**
 设置滤镜（默认开启美颜）
 
 @param filter 滤镜模式
 说明：只有使用美颜相机模式才有用。
 */
- (void)setCameraFilter:(ARCameraFilterMode)filter;

/**
 设置远端音视频是否传输
 
 @param peerId RTC服务生成的标识Id
 @param audio YES传输音频，NO不传输音频
 @param video YES传输视频，NO不传输视频
 @return 操作是否成功
 */
- (BOOL)setRemoteAVEnable:(NSString *)peerId audio:(BOOL)audio video:(BOOL)video;

/**
 本地是否接收远程的视频
 
 @param mute 视频是否接收 YES:不接收，NO:接收
 @param pubId RTC服务生成流的ID (用于标识与会者发布的流)
 说明:当本地下行质量不行的时候，用该方法来禁止接收该路流的视频
 @return 成功与否
 */
- (BOOL)muteRemoteVideoStream:(BOOL)mute pubId:(NSString *)pubId;

/**
 本地是否接收远程的音频
 
 @param mute YES不接收，NO接收
 @param pubId RTC服务生成流的Id (用于标识与会者发布的流)
 @return 操作是否成功
 */
- (BOOL)muteRemoteAudioStream:(BOOL)mute pubId:(NSString *)pubId;

#pragma mark RTC function for line

/**
 加入会议

 @param token 令牌:客户端向自己服务申请获得，参考企业级安全指南
 @param meetId 会议Id，系统业务自己管理
 @param userId 用户id
 @param userData 用户其他相关信息（昵称，头像等）(限制512字节)
 @return 加入会议成功或者失败
 */
- (BOOL)joinRTCByToken:(NSString* _Nullable)token
                meetId:(NSString *)meetId
                userId:(NSString *)userId
              userData:(NSString *)userData;
/**
 离开会议室
 
 说明：相当于析构函数。
 */
- (void)leaveRTC;

/**
 设置其他人视频显示窗口
 
 @param render 对方视频的视图窗口
 @param pubId RTC服务生成流的Id (用于标识与会者发布的流)
 说明：该方法用于与会者接通后，与会者视频接通回调中(onRTCOpenRemoteVideoRender)使用。
 */
- (void)setRemoteVideoRender:(VIEW_CLASS *)render pubId:(NSString *)pubId;

/**
 设置某个人的显示模式
 
 @param videoRenderMode 显示模式，默认ARVideoRenderScaleToFill，等比例填充视图模式
 @param pubId RTC服务生成流的Id (用于标识与会者发布的流)
 */
- (void)updateRTCVideoRenderModel:(ARVideoRenderMode)videoRenderMode pubId:(NSString *)pubId;

/**
 设置驾驶模式（只听音频）
 
 @param open 是否打开，默认关闭
 */
- (void)setDriveModel:(BOOL)open;

/**
 设置某路视频广播
 
 @param enable 广播与取消广播
 @param peerId 视频流Id
 */
- (void)setRTCBroadCast:(BOOL)enable peerId:(NSString *)peerId;

/**
 1v1授课模式
 
 @param enable YES授课，NO取消授课
 @param peerId 视频流Id
 */
- (void)setRTCTalkOnly:(BOOL)enable peerId:(NSString *)peerId;

#pragma mark - 消息

/**
 发送消息
 
 @param userName 用户昵称，不能为空，否则发送失败(最大256字节)
 @param headerUrl 用户头像，可选(最大512字节)
 @param content 消息内容不能为空，否则发送失败(最大1024字节)
 @return YES发送成功，NO发送失败
 说明：默认普通消息，以上参数均会出现在参会者的消息回调方法中，如果加入RTC（joinRTC）没有设置userid，发送失败。
 */
- (BOOL)sendUserMessage:(NSString *)userName userHeader:(NSString *)headerUrl content:(NSString *)content;

#pragma mark - 流量信息监测

/**
 设置网络质量是否打开
 
 @param enable YES打开，NO关闭，默认关闭
 */
- (void)setNetworkStatus:(BOOL)enable;

/**
 获取当前网络状态是否打开
 
 @return 获取网络状态
 */
- (BOOL)networkStatusEnabled;

/**
 获取人员列表
 
 @return 人员列表
 */
- (NSArray<ARUserItem *> *)getUserList;


#pragma mark - 白板功能模块

/**
 设置共享回调
 */
@property (nonatomic, weak) id<ARShareDelegate>delegate;

/**
 打开共享
 
 @param type 共享类型，类型自己平台设定，例如1为白板，２为文档
 */
- (void)openShare:(int)type;
/**
 发送共享信息
 
 @param shearInfo 共享相关信息(限制512字节)
 说明：打开白板成功与失败，参考onRTCShareEnable回调方法
 */
- (void)setShareInfo:(NSString *)shearInfo;

/**
 关闭共享
 */
- (void)closeShare;

#pragma mark - ZOOM模式
/**
 设置Zoom显示模式
 
 @param type 模式，默认为ARZoomTypeSingle模式
 @return 操作是否成功
 说明：必须先设置会议模式为zoom模式才有效。
 */
- (BOOL)setZoomModel:(ARZoomType)type;

/**
 设置显示页码（分屏显示ARZoomTypeNomal）
 
 @param page 页码（从0开始，每页加上自己的视频流为4路）
 @return 操作是否成功
 */
- (BOOL)setZoomPage:(int)page;

/**
 设置显示区域从nIndex 到第几个
 
 @param index 开始标记
 @param showNum 数量，默认为4，onRTCZoomPageInfo回调里的showNum
 @return 操作是否成功
 */
- (BOOL)setZoomPageIndex:(int)index showNum:(int)showNum;

@end

NS_ASSUME_NONNULL_END

