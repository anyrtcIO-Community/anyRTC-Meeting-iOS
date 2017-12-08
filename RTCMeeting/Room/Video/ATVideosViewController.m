//
//  ATVideosViewController.h
//  RTCMeeting
//
//  Created by jh on 2017/10/18.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATVideosViewController.h"

@interface ATVideosViewController ()<RTMeetKitDelegate,AnyRTCUserShareBlockDelegate>

//房间名
@property (weak, nonatomic) IBOutlet UIButton *topicButton;

//连接提示
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (nonatomic, strong)RTMeetKit *meetKit;
//配置信息
@property (nonatomic, strong)RTMeetOption *option;
//本地显示窗口
@property (nonatomic, strong)UIView *showView;

@property (nonatomic, strong)NSMutableArray *videoArr;

@property (nonatomic, copy)NSString *anyRTCId;
@end

@implementation ATVideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view insertSubview:self.showView atIndex:0];

    self.anyRTCId = [NSString stringWithFormat:@"anymeeting1000%ld",(long)self.typeMode];
    
    self.topicButton.userInteractionEnabled = NO;
    self.topicButton.layer.mask = [ATCommon getMaskLayer:self.topicButton.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:20];
    
    [self itializationMeetKit];
}

- (void)itializationMeetKit{
    //实例化会议对象
    self.meetKit = [[RTMeetKit alloc] initWithDelegate:self andOption:self.option];
    self.meetKit.delegate = self;
    
    //本地视频采集窗口
    [self.meetKit setLocalVideoCapturer:self.showView];
    
    NSDictionary *customDict = [NSDictionary dictionaryWithObjectsAndKeys:self.userName,@"nickName",nil];
    NSString *customStr = [ATCommon fromDicToJSONStr:customDict];
    
    //设置音频检测（默认）
    [self.meetKit setAudioActiveCheck:YES];
    
    //加入会议
    [self.meetKit joinRTC:self.anyRTCId andUserId:[ATCommon randomString:6] andUserData:customStr];
}

#pragma mark - RTMeetKitDelegate
- (void)onRTCJoinMeetOK:(NSString*)strAnyRTCId{
    //加入会议成功的回调
    self.tipsLabel.text = @"RTC会议连接成功...";
}

- (void)onRTCJoinMeetFailed:(NSString*)strAnyRTCId withCode:(int)nCode{
    //加入会议室失败的回调
    [XHToast showCenterWithText:@"加入会议失败"];
}

- (void)onRTCLeaveMeet:(int)nCode{
    //离开会议的回调
    self.tipsLabel.text = @"RTC会议连接失败...";
    if (nCode == 100) {
        [XHToast showCenterWithText:@"网络异常"];
    }
}

-(void)onRTCOpenVideoRender:(NSString*)strRTCPeerId withRTCPubId:(NSString *)strRTCPubId withUserId:(NSString*)strUserId withUserData:(NSString*)strUserData{
    //其他与会者视频接通回调(音视频)
    NSDictionary *dict = [ATCommon fromJsonStr:strUserData];
    UIView *videoView = [self getVideoViewWithRTCPeerId:strRTCPeerId withNickName:[dict objectForKey:@"nickName"]];
    [self.view insertSubview:videoView atIndex:99];
    [self.videoArr addObject:videoView];
    
    [self.meetKit setRTCVideoRender:strRTCPubId andRender:videoView];
}

-(void)onRTCCloseVideoRender:(NSString*)strRTCPeerId withRTCPubId:(NSString *)strRTCPubId withUserId:(NSString*)strUserId{
    //其他会议者离开的回调（音视频）
    @synchronized (self.videoArr){
        for (NSInteger i = 0; i < self.videoArr.count; i++) {
            ATVideoView *videoView = self.videoArr[i];
            if ([videoView.pubId isEqualToString:strRTCPubId]) {
                
                [self.videoArr removeObjectAtIndex:i];
                [videoView removeFromSuperview];
                //刷新位置
                [self layoutVideoView];
                break;
            }
        }
    }
}

- (void)onRTCAVStatus:(NSString*)strRTCPeerId withAudio:(BOOL)bAudio withVideo:(BOOL)bVideo{
    //其他与会者对音视频的操作的回调（比如对方关闭了音频，对方关闭了视频）
    for (ATVideoView *videoView in self.videoArr) {
        if ([videoView.pubId isEqualToString:strRTCPeerId]) {
            if (!bAudio && !bVideo) {
                [XHToast showCenterWithText:@"对方音视频关闭"];
                return;
            }
            //...操作
        }
    }
    
}

-(void)onRTCAudioActive:(NSString*)strRTCPeerId withUserId:(NSString *)strUserId withShowTime:(int)nTime{
    //RTC音频检测
}


-(void)onRTCViewChanged:(UIView*)videoView didChangeVideoSize:(CGSize)size{
    //视频窗口大小改变
    @synchronized (self.videoArr) {
        if (videoView == self.showView){
            self.scale = size.width/size.height;
        }
        
        for (ATVideoView *atVideoView in self.videoArr) {
            if (videoView == atVideoView) {
                atVideoView.videoSize = size;
                [self layoutVideoView];
                break;
            }
        }
        [self layoutVideoView];
    }
}

- (void)onRTCUserMessage:(NSString*)strUserId withUserName:(NSString*)strUserName withUserHeader:(NSString*)strUserHeaderUrl withContent:(NSString*)strContent{
    //收到消息回调
    
}

#pragma mark - AnyRTCWriteBlockDelegate
- (void)onRTCCanUseShareEnableResult:(BOOL)scuess{
    //判断是否可以开启共享
}

- (void)onRTCUserShareOpen:(NSString*)strUserShareInfo withUserId:(NSString *)strUserId withUserData:(NSString*)strUserData{
    //共享开启
}

- (void)OnRTCUserShareClose{
    //共享关闭
}

#pragma mark - 刷新显示视图
- (UIView *)getVideoViewWithRTCPeerId:(NSString*)peerId withNickName:(NSString *)nameStr{
    ATVideoView *videoView = [ATVideoView loadVideoView];
    videoView.frame = CGRectZero;
    videoView.nameLabel.text = nameStr;
    videoView.pubId = peerId;
    return videoView;
}

- (void)layoutVideoView{
    //九人会议模式
    if (self.videoArr.count == 0) {
        self.showView.frame = CGRectMake(0, 0, SCREEN_HEIGHT * self.scale, SCREEN_HEIGHT);
    } else if (self.videoArr.count == 1 ){
        CGFloat width = self.view.frame.size.width/2.0;
        CGFloat height = width;
        self.showView.frame = CGRectMake(0, CGRectGetMidY(self.view.frame) - height/2, width, height);
        ATVideoView *videoView = (ATVideoView *)self.videoArr[0];
        
        videoView.frame = CGRectMake(width, CGRectGetMidY(self.view.frame) - height/2, width, height);
        
        
    } else if (self.videoArr.count <= 3) {
        CGFloat width = self.view.frame.size.width/2.0;
        CGFloat height = width;
        self.showView.frame = CGRectMake(0, 0, width, height);
        
        CGFloat allWidth = width;
        CGFloat allHeight = 0;
        
        for (int i= 0;i < self.videoArr.count;i++) {
            ATVideoView *videoView = self.videoArr[i];
            if (allWidth+10>self.view.frame.size.width) {
                allHeight +=width;
                allWidth = 0;
                videoView.frame = CGRectMake(0, allHeight, width, height);
                allWidth = width;
            }else{
                videoView.frame = CGRectMake(allWidth, allHeight, width, height);
                allWidth+=width;
            }
        }
    }else {
        CGFloat width = self.view.frame.size.width/3.0;
        CGFloat height = width;
        
        self.showView.frame = CGRectMake(0, 0, width, height);
        CGFloat allWidth = width;
        CGFloat allHeight = 0;
        
        for (int i= 0;i<self.videoArr.count;i++) {
            ATVideoView *videoView = self.videoArr[i];
            if (allWidth+10>self.view.frame.size.width) {
                allHeight +=width;
                allWidth = 0;
                videoView.frame = CGRectMake(0, allHeight, width, height);
                allWidth = width;
            }else{
                videoView.frame = CGRectMake(allWidth, allHeight, width, height);
                allWidth+=width;
            }
        }
    }
}

#pragma mark - event
- (IBAction)doSomethingEvents:(UIButton *)sender {
    sender.selected = !sender.selected;
    switch (sender.tag) {
        case 100:
            //翻转摄像头
            [self.meetKit switchCamera];
            break;
        case 101:
            //音频
            [self.meetKit setLocalAudioEnable:!sender.selected];
            break;
        case 102:
            //挂断
            [self.meetKit leaveRTC];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 103:
            //视频
            [self.meetKit setLocalVideoEnable:!sender.selected];
            break;
        default:
            break;
    }
}

#pragma mark - other
- (BOOL)shouldAutorotate{
    [super shouldAutorotate];
    return NO;
}

- (UIView *)showView{
    if (!_showView) {
        _showView = [[UIView alloc]init];
        _showView.frame = self.view.frame;
    }
    return _showView;
}

- (NSMutableArray *)videoArr{
    if (!_videoArr) {
        _videoArr = [NSMutableArray array];
    }
    return _videoArr;
}

- (RTMeetOption *)option{
    if(!_option){
        _option = [RTMeetOption defaultOption];
        //设置显示模式
        _option.videoLayOut = RTC_V_3X3_auto;
        //设置视频方向
        _option.videoScreenOrientation = RTMPC_SCRN_Portrait;
    }
    return _option;
}

@end

