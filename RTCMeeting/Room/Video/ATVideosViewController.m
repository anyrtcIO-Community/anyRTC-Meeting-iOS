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
//本地显示窗口
@property (nonatomic, strong)UIView *localView;

@property (nonatomic, strong)NSMutableArray *videoArr;

@property (nonatomic, copy)NSString *anyRTCId;
//web是否开启屏幕共享
@property (nonatomic, assign)NSInteger isScreenIndex;
//web共享view
@property (nonatomic, strong)UIView *screenView;
//容器
@property (nonatomic, strong) UIView *containerView;

@end

@implementation ATVideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.videoArr = [NSMutableArray arrayWithCapacity:9];
    self.anyRTCId = [NSString stringWithFormat:@"anymeeting1000%ld",(long)self.typeMode];
    
    self.topicButton.userInteractionEnabled = NO;
    self.topicButton.layer.mask = [ATCommon getMaskLayer:self.topicButton.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:20];
    
    self.containerView = [[UIView alloc]initWithFrame:self.view.bounds];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.containerView atIndex:0];
    
    [self itializationMeetKit];
}

- (void)itializationMeetKit{
    //配置信息
    RTMeetOption *option = [RTMeetOption defaultOption];
    //设置显示模式
    option.videoLayOut = RTC_V_3X3_auto;
    //设置视频方向
    option.videoScreenOrientation = RTC_SCRN_Portrait;
    option.cameraType = RTMeetCameraTypeBeauty;
    //会议最大人数限制
    option.maxNum = 9;
    
    //实例化会议对象
    self.meetKit = [[RTMeetKit alloc] initWithDelegate:self andOption:option];
    self.meetKit.delegate = self;
    
    //本地视频采集窗口
    self.localView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.containerView addSubview:self.localView];
    [self.meetKit setLocalVideoCapturer:self.localView];
    [self.videoArr addObject:self.localView];
    
    NSDictionary *customDict = [NSDictionary dictionaryWithObjectsAndKeys:self.userName,@"nickName",nil];
    NSString *customStr = [ATCommon fromDicToJSONStr:customDict];
    
    //设置音频检测（默认）
    [self.meetKit setAudioActiveCheck:YES];
    
    //加入会议
    [self.meetKit joinRTC:self.anyRTCId andIsHoster:NO andUserId:[ATCommon randomString:6] andUserData:customStr];
}

#pragma mark - RTMeetKitDelegate
- (void)onRTCJoinMeetOK:(NSString*)strAnyRTCId{
    //加入会议成功的回调
    self.tipsLabel.text = @"RTC会议连接成功...";
}

- (void)onRTCJoinMeetFailed:(NSString*)strAnyRTCId withCode:(int)nCode{
    //加入会议室失败的回调
    (nCode == 701) ? ([XHToast showCenterWithText:@"会议人数已满"]) : ([XHToast showCenterWithText:@"加入会议失败"]);
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
    ATVideoView *videoView = [ATVideoView loadVideoViewWithRTCPubId:strRTCPubId andPeerId:strRTCPeerId withNickName:[dict objectForKey:@"nickName"]];
    [self.videoArr addObject:videoView];
    [self.meetKit setRTCVideoRender:strRTCPubId andRender:videoView];
    [self layoutVideoView];
}

-(void)onRTCCloseVideoRender:(NSString*)strRTCPeerId withRTCPubId:(NSString *)strRTCPubId withUserId:(NSString*)strUserId{
    //其他会议者离开的回调（音视频）
    [self.videoArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ATVideoView class]]) {
            ATVideoView *videoView = (ATVideoView *)obj;
            if ([videoView.pubId isEqualToString:strRTCPubId]) {
                
                [self.videoArr removeObjectAtIndex:idx];
                [videoView removeFromSuperview];
                //刷新位置
                [self layoutVideoView];
                *stop = YES;
            }
        }
    }];
}

-(void)onRTCOpenScreenRender:(NSString*)strRTCPeerId withRTCPubId:(NSString *)strRTCPubId withUserId:(NSString*)strUserId withUserData:(NSString*)strUserData{
    //用户开启屏幕共享
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    [self orientationRotating:UIInterfaceOrientationLandscapeRight];
    [self.view insertSubview:self.screenView atIndex:2];
    self.screenView.backgroundColor = [UIColor clearColor];
    [self.screenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.meetKit setRTCVideoRender:strRTCPubId andRender:self.screenView];

}

-(void)onRTCCloseScreenRender:(NSString*)strRTCPeerId withRTCPubId:(NSString *)strRTCPubId withUserId:(NSString*)strUserId{
    //用户关闭屏幕共享
}

- (void)onRTCAVStatus:(NSString*)strRTCPeerId withAudio:(BOOL)bAudio withVideo:(BOOL)bVideo{
    //其他与会者对音视频的操作的回调（比如对方关闭了音频，对方关闭了视频）
}

-(void)onRTCAudioActive:(NSString*)strRTCPeerId withUserId:(NSString *)strUserId withShowTime:(int)nTime{
    //RTC音频检测
}


-(void)onRTCViewChanged:(UIView*)videoView didChangeVideoSize:(CGSize)size{
    //视频窗口大小改变
    NSLog(@"%f-----%f",size.width,size.height);
}

- (void)onRtcNetworkStatus:(NSString*)strRTCPeerId withUserId:(NSString *)strUserId withNetSpeed:(int)nNetSpeed withPacketLost:(int)nPacketLost{
    //网络状态
}

- (void)onRTCUserMessage:(NSString*)strUserId withUserName:(NSString*)strUserName withUserHeader:(NSString*)strUserHeaderUrl withContent:(NSString*)strContent{
    //收到消息回调
}

- (void)onRTCHosterOnLine:(NSString*)strRTCPeerId withUserId:(NSString*)strUserId withUserData:(NSString*)strUserData{
    //主持人上线
}

- (void)onRTCHosterOffLine:(NSString*)strRTCPeerId{
    //主持人下线
}

- (void)onRTCTalkOnlyOn:(NSString*)strRTCPeerId withUserId:(NSString*)strUserId withUserData:(NSString*)strUserData{
    //1v1开启
}

- (void)onRtcTalkOnlyOff:(NSString*)strRTCPeerId{
    //1v1关闭
}

#pragma mark - AnyRTCWriteBlockDelegate
- (void)onRTCCanUseShareEnableResult:(BOOL)scuess{
    //判断是否可以开启共享
}

- (void)onRTCUserShareOpen:(int)nType withShareInfo:(NSString*)strUserShareInfo withUserId:(NSString *)strUserId withUserData:(NSString*)strUserData{
    //共享开启
    self.isScreenIndex ++;
    NSDictionary *userInfo = (NSDictionary *)[ATCommon fromJsonStr:strUserData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [XHToast showCenterWithText:[NSString stringWithFormat:@"%@开启了屏幕共享",[userInfo objectForKey:@"nickName"]]];
    });
}

- (void)OnRTCUserShareClose{
    //共享关闭
    [self.screenView removeFromSuperview];
    self.screenView = nil;
    self.isScreenIndex = 0;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self orientationRotating:UIInterfaceOrientationPortrait];
    appDelegate.allowRotation = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [XHToast showCenterWithText:@"屏幕共享已关闭"];
    });
}

#pragma mark - 刷新显示视图
- (void)layoutVideoView{
    //九人会议模式
    CGFloat itemWidth,itemHeight;
    
    switch (self.videoArr.count) {
        case 1:
        {
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            [self.localView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.containerView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
        }
            break;
        case 2:
        {
            itemWidth = SCREEN_WIDTH/2;
            itemHeight = itemWidth * 3/4;
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.left.width.equalTo(self.view);
                make.height.equalTo(@(itemHeight));
                make.centerY.equalTo(self.view.mas_centerY);
            }];
            [self makeVideoEqualWidthViews:self.videoArr containerView:self.containerView spacing:0 padding:0];
        }
            break;
        case 3:
        case 4:
        {
            itemWidth = SCREEN_WIDTH/2;
            itemHeight = itemWidth;
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.left.width.equalTo(self.view);
                make.height.equalTo(@(itemHeight * 2));
                make.centerY.equalTo(self.view.mas_centerY);
            }];
            [self makeEqualViews:self.videoArr inView:self.containerView ItemWidth:itemWidth itemHeight:itemHeight warpCount:2];
        }
            break;
        default:
            itemWidth = SCREEN_WIDTH/3;
            itemHeight = itemWidth;
            
            NSInteger count = self.videoArr.count/3;
            if (self.videoArr.count%3 != 0) {
                count ++;
            }
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.left.width.equalTo(self.view);
                make.height.equalTo(@(itemHeight * count));
                make.centerY.equalTo(self.view.mas_centerY);
            }];
            [self makeEqualViews:self.videoArr inView:self.containerView ItemWidth:itemWidth itemHeight:itemHeight warpCount:3];
            break;
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
        {
            [self.meetKit leaveRTC];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.allowRotation = NO;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case 103:
            //视频
            [self.meetKit setLocalVideoEnable:!sender.selected];
            break;
        case 104:
            //共享
            if (self.isScreenIndex != 0) {
                //显示共享屏幕（横屏）
                if (self.screenView.hidden) {
                    self.screenView.hidden = NO;
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.allowRotation = YES;
                    [self orientationRotating:UIInterfaceOrientationLandscapeRight];
                } else {
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [self orientationRotating:UIInterfaceOrientationPortrait];
                    
                    appDelegate.allowRotation = NO;
                    self.screenView.hidden = YES;
                }
            } else {
                [XHToast showCenterWithText:@"当前无人发起屏幕共享"];
                sender.selected = NO;
            }
        default:
            break;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self layoutVideoView];
    }];
}

#pragma mark - other
- (UIView *)screenView{
    if (!_screenView) {
        _screenView = [[UIView alloc]init];
    }
    return _screenView;
}

@end

