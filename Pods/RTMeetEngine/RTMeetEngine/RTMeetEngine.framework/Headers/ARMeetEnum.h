//
//  ARMeetEnum.h
//  ARMeetEngine
//
//  Created by zjq on 2019/1/15.
//  Copyright © 2019 EricTao. All rights reserved.
//

#ifndef ARMeetEnum_h
#define ARMeetEnum_h

typedef NS_ENUM(NSInteger,ARMeetCode) {
    
    ARMeet_OK = 0,                     // 正常
    ARMeet_UNKNOW,                     // 未知错误
    ARMeet_EXCEPTION,                  // SDK调用异常
    ARMeet_EXP_UNINIT,                 // SDK未初始化
    ARMeet_EXP_PARAMS_INVALIDE,        // 参数非法
    ARMeet_EXP_NO_NETWORK,             // 没有网络
    ARMeet_EXP_NOT_FOUND_CAMERA,       // 没有找到摄像头设备
    ARMeet_EXP_NO_CAMERA_PERMISSION,   // 没有打开摄像头权限:
    ARMeet_EXP_NO_AUDIO_PERMISSION,    // 没有音频录音权限
    ARMeet_EXP_NOT_SUPPOAR_WEBARC,     // 浏览器不支持原生的webARc
    
    ARMeet_NET_ERR = 100,              // 网络错误
    ARMeet_NET_DISSCONNECT = 101,      // 网络断开
    ARMeet_LIVE_ERR = 102,             // 直播出错
    ARMeet_EXP_ERR = 103,              // 异常错误
    ARMeet_EXP_UNAUTHORIZED = 104,     // 服务未授权
    
    ARMeet_BAD_REQ  = 201,             // 服务不支持的错误请求
    ARMeet_AUTH_FAIL = 202,            // 认证失败
    ARMeet_NO_USER= 203,               // 此开发者信息不存在
    ARMeet_SVR_ERR = 204,              // 服务器内部错误
    ARMeet_SQL_ERR = 205,              // 服务器内部数据库错误
    ARMeet_ARREARS = 206,              // 账号欠费
    ARMeet_LOCKED = 207,               // 账号被锁定
    ARMeet_SERVER_NOT_OPEN = 208,      // 服务未开通
    ARMeet_ALLOC_NO_RES = 209,         // 没有服务资源
    ARMeet_SERVER_NO_SURPPOAR = 210,   // 不支持的服务
    ARMeet_FORCE_EXIT = 211,           // 强制离开
    ARMeet_AUTH_TIMEOUT = 212,         // 验证超时
    ARMeet_NEED_VERTIFY_TOKEN = 213,   // 需要验证userToken
    ARMeet_WEB_DOMIAN_ERROR = 214,     // Web应用的域名验证失败
    ARMeet_IOS_BUNDLE_ID_ERROR = 215,  // iOS应用的BundleId验证失败
    ARMeet_ANDROID_PKG_NAME_ERROR = 216,// Android应用的包名验证失败
    
    ARMeet_NOT_STAAR = 700,            // 房间未开始
    ARMeet_IS_FULL = 701,              // 房间人员已满
    ARMeet_NOT_COMPARE =702            // 房间类型不匹配
};
// 媒体类型：视频会议/音频会议
typedef NS_ENUM(NSInteger, ARMediaType){
    ARMediaTypeVideo = 0,
    ARMediaTypeAudio,
};

// 会议类型
typedef NS_ENUM(NSInteger,ARMeetType) {
    ARMeetTypeNomal = 0,  // 一般模式：大家进入会议互相观看
    ARMeetTypeHoster = 1, // 主持模式：主持人进入，可以看到所有人，其他人员只看到主持人
    ARMeetTypeLive = 2,   // live模式：大班课模式
    ARMeetTypeZoom = 3,   // zoom模式
};

//zoom模式
typedef NS_ENUM(NSInteger,ARZoomType){
    ARZoomTypeNomal = 0,  // 一般模式:分屏显示模式
    ARZoomTypeSingle = 1, // 单显示模式:语音激励模式
    ARZoomTypeDriver = 2, // 驾驶模式:只接受音频:此时自己设置音视频是否传输
};

#endif /* ARMeetEnum_h */
