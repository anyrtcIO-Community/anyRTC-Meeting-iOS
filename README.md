# 重要提醒
anyRTC 对该版本已经不再维护，如需音视频呼叫，请前往:https://github.com/anyRTC-UseCase/ARCall

**功能如下：**
- 一对一音视频呼叫
- 一对多音视频呼叫
- 视频通话转音频通话
- 静音开关/视频开关
- AI降噪，极致降噪，不留噪声
- 大小屏切换
- 悬浮窗功能

新版本一行代码，30分钟即可使应用有音视频能力。

更多示列请前往**公司网址： [www.anyrtc.io](https://www.anyrtc.io)**

# anyRTC-Meeting-iOS

## 简介
anyRTC-Meeting-iOS视频会议，基于RTMeetEngine SDK，支持视频、语音多人会议，适用于会议、培训、互动等多人移动会议。</br>

## 安装
### 1、编译环境
Xcode 8以上</br>

### 2、运行环境
真机运行、iOS 8.0以上（建议最新）

## 导入SDK

### Cocoapods导入
```
pod 'RTMeetEngine', '~> 3.0.1'
```
### 手动导入

1. 下载Demo，或者前往[anyRTC官网](https://www.anyrtc.io)下载SDK
![list_directory](/image/list_directory.png)


2. 在Xcode中选择“Add files to 'Your project name'...”，将RTMeetEngine.framework添加到你的工程目录中</br>

3.  打开General->Embedded Binaries中添加RTMeetEngine.framework</br>

## 如何使用？

### 注册账号
登陆[AnyRTC官网](https://www.anyrtc.io/)

### 填写信息
创建应用，在管理中心获取开发者ID，AppID，AppKey，AppToken，替换AppDelegate.h中的相关信息

### 操作步骤：
1、一台iphone启动app，选择进入会议房间；</br>

2、另一台手机进入相同会议房间，实时会议开始。</br>

### 资源中心
[更多详细方法使用，请查看API文档](https://docs.anyrtc.io/v1/MEET/)


## 扫描二维码下载demo
![RTCMeeting](/image/xoTQ.png)


## 支持的系统平台
**iOS** 8.0及以上

## 支持的CPU架构
**iOS** armv7 、arm64。  支持bitcode

## ipv6
苹果2016年6月新政策规定新上架app必须支持ipv6-only。该库已经适配

## Android版anyRTC-Meeting
[anyRTC-Meeting-Android](https://github.com/AnyRTC/anyRTC-Meeting-Android)

## 网页版anyRTC-Meeting
[anyRTC-Meeting-Web](https://www.anyrtc.io/demo/meeting)

## 更新日志

* 2019年10月15日：Version 3.0.1 </br>

（1）新增塞流接口（setExternalCameraCapturer）；

（2）新增流量信息监测以及音频数据信息；

（3）新增录制相关方法（startRecording:recordVideo:）。

* 2019年05月14日：</br>

SDK更新3.0.0版本</br>

* 2018年11月06日：</br>

修复iOS 9系统时，退出会议崩溃的问题</br>

* 2018年10月31日：</br>

（1）修复美颜相机情况下，本地视频添加子视图镜像的问题。</br>

（2）RTMeetKitDelegate添加开启屏幕共享、关闭屏幕共享的回调；</br>

```
//用户开启桌面共享
-(void)onRTCOpenScreenRender:(NSString*)strRTCPeerId withRTCPubId:(NSString *)strRTCPubId withUserId:(NSString*)strUserId withUserData:(NSString*)strUserData;

//用户退出桌面共享
-(void)onRTCCloseScreenRender:(NSString*)strRTCPeerId withRTCPubId:(NSString *)strRTCPubId withUserId:(NSString*)strUserId;
```
（3）修复Demo中的已知问题。

## 技术支持
* anyRTC官方网址：https://www.anyrtc.io </br>

* QQ技术交流群：554714720 </br>

* 联系电话:021-65650071-816 </br>

* Email:hi@dync.cc </br>

## 关于直播
本公司有一整套直播解决方案，特别针对移动端。本公司开发者平台[www.anyrtc.io](http://www.anyrtc.io)。除了基于RTMP协议的直播系统外，我公司还有基于WebRTC的时时交互直播系统、P2P呼叫系统、会议系统等。快捷集成SDK，便可让你的应用拥有时时通话功能。欢迎您的来电~

## License

RTMeetEngine is available under the MIT license. See the LICENSE file for more info.

