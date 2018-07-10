//
//  ATVideoViewController.m
//  RTCMeeting
//
//  Created by jh on 2017/10/13.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATVideoViewController.h"

@interface ATVideoViewController ()<RTMeetKitDelegate,AnyRTCUserShareBlockDelegate,SwitchDelegate>

//房间名
@property (weak, nonatomic) IBOutlet UIButton *topicButton;
//连接提示
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
//屏幕共享按钮
@property (weak, nonatomic) IBOutlet UIButton *screenButton;

@property (weak, nonatomic) IBOutlet UIButton *videoButton;

@property (nonatomic, strong)RTMeetKit *meetKit;
//配置信息
@property (nonatomic, strong)RTMeetOption *option;
//本地显示窗口
@property (nonatomic, strong)UIView *localView;
//容器
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong)NSMutableArray *videoArr;

@property (nonatomic, copy)NSString *anyRTCId;
//web是否开启屏幕共享
@property (nonatomic, assign)NSInteger isScreenIndex;
//web共享view
@property (nonatomic, strong)UIView *screenView;
//共享PubId
@property (nonatomic, copy)NSString *pubId;
//是否旋转
@property (nonatomic, assign)BOOL isRotation;
@end

@implementation ATVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.videoArr = [NSMutableArray arrayWithCapacity:4];
    
    self.isRotation = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidesKeyControl)];
    [self.view addGestureRecognizer:tap];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    
    self.anyRTCId = [NSString stringWithFormat:@"anymeeting1000%ld",(long)self.typeMode];
    
    self.topicButton.userInteractionEnabled = NO;
    self.topicButton.layer.mask = [ATCommon getMaskLayer:self.topicButton.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:20];
    
    [self itializationMeetKit];
}

- (void)itializationMeetKit{
    self.localView = [[UIView alloc]init];
    self.localView.tag = 1000;
    [self.view insertSubview:self.localView atIndex:0];
    [self.localView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    //实例化会议对象
    self.meetKit = [[RTMeetKit alloc] initWithDelegate:self andOption:self.option];
    //白板
    self.meetKit.delegate = self;
    //本地视频采集窗口
    [self.meetKit setLocalVideoCapturer:self.localView];
    
    NSDictionary *customDict = [NSDictionary dictionaryWithObjectsAndKeys:self.userName,@"nickName",nil];
    NSString *customStr = [ATCommon fromDicToJSONStr:customDict];
    
    //加入会议
    [self.meetKit joinRTC:self.anyRTCId andIsHoster:NO andUserId:[ATCommon randomString:6] andUserData:customStr];
    
    [self.meetKit updateLocalVideoRenderModel:AnyRTCVideoRenderScaleAspectFill];
}

//MARK: - SwitchDelegate
- (void)switchScreen:(UIView *)video{
    if (video.tag == 1000) {
        video.tag = 0;
        [self.videoArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj == self.localView) {
                self.localView.tag = 1000;
                [self.view addSubview:self.localView];
                [self.videoArr removeObjectAtIndex:idx];
                *stop = true;
            }
        }];
        [self.videoArr addObject:video];
    } else {
        UIView *view = [self.view viewWithTag:1000];
        view.tag = 0;
        [self.videoArr addObject:view];
        [self.videoArr removeObject:video];
        video.tag = 1000;
        [self.view insertSubview:video atIndex:0];
    }
    [self layoutVideoView];
}

//MARK: - RTMeetKitDelegate
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
    if (![self.pubId isEqualToString:strRTCPubId]) {
        NSDictionary *dict = [ATCommon fromJsonStr:strUserData];
        ATVideoView *videoView = [ATVideoView loadVideoViewWithRTCPubId:strRTCPubId andPeerId:strRTCPeerId withNickName:[dict objectForKey:@"nickName"]];
        videoView.delegate = self;
        [self.videoArr addObject:videoView];
        
        [self.meetKit setRTCVideoRender:strRTCPubId andRender:videoView];
        [self layoutVideoView];
    }
}

-(void)onRTCCloseVideoRender:(NSString*)strRTCPeerId withRTCPubId:(NSString *)strRTCPubId withUserId:(NSString*)strUserId{
    if (![self.pubId isEqualToString:strRTCPubId]) {
        @synchronized (self.videoArr){
            //其他会议者离开的回调（音视频）
            UIView *largeView = [self.view viewWithTag:1000];
            if ([largeView isKindOfClass:[ATVideoView class]]) {
                ATVideoView *video = (ATVideoView *)largeView;
                if ([video.pubId isEqualToString:strRTCPubId]) {
                    [video removeFromSuperview];
                    [self.videoArr removeObject:self.localView];
                    self.localView.tag = 1000;
                    [self.view insertSubview:self.localView atIndex:0];
                    [self layoutVideoView];
                    return;
                }
            }
            
            [self.videoArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[ATVideoView class]]) {
                    ATVideoView *video = (ATVideoView *)obj;
                    if ([video.pubId isEqualToString:strRTCPubId]) {
                        [video removeFromSuperview];
                        [self.videoArr removeObjectAtIndex:idx];
                        [self layoutVideoView];
                        *stop = YES;
                    }
                }
            }];
        }
    }
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
    if (scuess) {
        [self.meetKit openUserShareInfo:@"123"];
    }
}

- (void)onRTCUserShareOpen:(int)nType withShareInfo:(NSString*)strUserShareInfo withUserId:(NSString *)strUserId withUserData:(NSString*)strUserData{
    /*数据格式
     strUserShareInfo -->  X1005tsRdSXgqDX0YAxK
     strUserId --> 7305968871
     strUserData --> {"userId":"7305968871","nickName":" Sutton","headUrl":""}
      */
    //共享开启
    NSDictionary *userInfo = (NSDictionary *)[ATCommon fromJsonStr:strUserData];
    [XHToast showCenterWithText:[NSString stringWithFormat:@"%@开启了屏幕共享",[userInfo objectForKey:@"nickName"]]];
    self.pubId = strUserShareInfo;
    self.isScreenIndex ++;
}

- (void)OnRTCUserShareClose{
    //共享关闭
    [XHToast showCenterWithText:[NSString stringWithFormat:@"关闭了屏幕共享"]];
    [self.screenView removeFromSuperview];
    self.isRotation = YES;
    self.screenButton.selected = NO;
    self.isScreenIndex = 0;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
}

#pragma mark - 刷新显示视图
- (void)layoutVideoView{
    
    UIView *largeView = [self.view viewWithTag:1000];
    [largeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.view sendSubviewToBack:largeView];
    [self.view insertSubview:self.containerView aboveSubview:largeView];
    
    //4:3
    CGFloat itemW = self.view.frame.size.width/4;
    CGFloat itemH = itemW * 3/4;
    [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(itemH));
        make.width.equalTo(@(itemW * self.videoArr.count));
        make.bottom.equalTo(self.videoButton.mas_top).offset(-10);
        make.centerX.equalTo(self.view.mas_centerX);
    }];

    //四人会议模式
    [self makeVideoEqualWidthViews:self.videoArr containerView:self.containerView spacing:0 padding:5];
}

#pragma mark - event
- (IBAction)doSomethingEvents:(UIButton *)sender {
    if (sender.selected && (sender.tag == 104)) {
        self.screenView.hidden = YES;
        sender.selected = NO;
        self.isRotation = YES;
        return;
    }
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
        {
            [self orientationRotating:UIInterfaceOrientationPortrait];
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
                [self orientationRotating:UIInterfaceOrientationLandscapeRight];
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.allowRotation = NO;
                
                if (self.screenView.hidden) {
                    self.screenView.hidden = NO;
                    return;
                }
                [self.view insertSubview:self.screenView atIndex:2];
                self.screenView.backgroundColor = [UIColor clearColor];
                [self.screenView mas_makeConstraints:^(MASConstraintMaker *make) {
                   make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
                }];
                [self.meetKit setRTCVideoRender:self.pubId andRender:self.screenView];
            } else {
                [XHToast showCenterWithText:@"当前无人发起屏幕共享"];
                sender.selected = NO;
            }
            break;
        default:
            break;
    }
}

- (void)hidesKeyControl{
    //切换大屏
    if (self.localView.tag != 1000) {
        UIView *view = [self.view viewWithTag:1000];
        view.tag = 0;
        [self.videoArr addObject:view];
        [self.videoArr removeObject:self.localView];
        self.localView.tag = 1000;
        [self.view insertSubview:self.localView atIndex:0];
        [self layoutVideoView];
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

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (RTMeetOption *)option{
    if(!_option){
        _option = [RTMeetOption defaultOption];
        //设置显示模式
        _option.videoLayOut = RTC_V_1X3;
        //设置视频方向
        _option.videoScreenOrientation = RTC_SCRN_Auto;
        //美颜相机
        _option.cameraType = RTMeetCameraTypeBeauty;
        
        //视频质量
        switch (self.typeMode) {
                case RTCMeeting_360P:
                [self.topicButton setTitle:@"四人会议室 - 360P" forState:UIControlStateNormal];
                _option.videoMode = AnyRTCVideoQuality_Low2;
                break;
                case RTCMeeting_720P:
                [self.topicButton setTitle:@"四人会议室 - 720P" forState:UIControlStateNormal];
                _option.videoMode = AnyRTCVideoQuality_Height1;
                break;
                case RTCMeeting_1080P:
                [self.topicButton setTitle:@"四人会议室 - 1080P" forState:UIControlStateNormal];
                _option.videoMode = AnyRTCVideoQuality_Height2;
                break;
            default:
                break;
        }
    }
    return _option;
}

@end
