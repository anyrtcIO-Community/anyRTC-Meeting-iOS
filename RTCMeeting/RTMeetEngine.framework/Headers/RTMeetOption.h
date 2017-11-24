//
//  RTMeetOption.h
//  RTMeetEngine
//
//  Created by derek on 2017/11/20.
//  Copyright © 2017年 EricTao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCCommon.h"

@interface RTMeetOption : NSObject
/**
 使用默认配置生成一个 RTMeetOption 对象
 
 @return 生成的 RTMeetOption 对象
 */
+ (nonnull RTMeetOption *)defaultOption;


/**
 是否是前置摄像头
 说明：默认前置摄像头
 */
@property (nonatomic, assign) BOOL isFont;

/**
 设置视频分辨率
 说明：默认为：RTCMeet_Videos_SD
 */
@property (nonatomic, assign) RTCMeetVideosMode videoMode;

/**
 视频方向：默认：RTC_SCRN_Portrait竖屏
 */
@property (nonatomic, assign) RTCScreenOrientation videoScreenOrientation;

/**
 设置显示模板
 说明：默认：RTC_V_1X3
 　　　RTC_V_1X3为4人小型会议模式，视频窗口比例为３：４；
 　　　RTC_V_3X3_auto为９人小型会议模式，窗口比例为１：１
 */
@property (nonatomic, assign) RTCVideoLayout videoLayOut;
@end
