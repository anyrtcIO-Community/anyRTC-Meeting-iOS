//
//  ArVideoViewController.m
//  RTCMeeting
//
//  Created by 余生丶 on 2019/3/12.
//  Copyright © 2019 Ar. All rights reserved.
//

#import "ArVideoViewController.h"

static const CGFloat scrollHeight = 130;

@interface ArVideoViewController ()<ARMeetKitDelegate,ArVideoDelegate,ARShareDelegate>

@property (weak, nonatomic) IBOutlet UIView *localView;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
/** 会议对象 */
@property (nonatomic, strong) ARMeetKit *meetKit;
/** 底部滚动视图 */
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableArray *videoArr;
@property (nonatomic, copy) NSString *screenPubId;

@property (nonatomic, strong) NSMutableArray *logArr;

@end

@implementation ArVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.logArr = [NSMutableArray array];
    [self addObserver:self forKeyPath:@"logArr" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self initializeUI];
    [self initializeMeet];
}

- (void)initializeMeet {
    //配置信息
    ARMeetOption *option = [ARMeetOption defaultOption];
    ARVideoConfig *config = [[ARVideoConfig alloc] init];
    config.cameraOrientation = ARCameraPortrait;
    option.videoConfig = config;
    //实例化会议对象
    self.meetKit = [[ARMeetKit alloc] initWithDelegate:self option:option];
    //本地视频显示窗口
    [self.meetKit setLocalVideoCapturer:self.localView];
    self.meetKit.delegate = self;
    //加入会议
    [self.meetKit joinRTCByToken:nil meetId:self.meetId userId:[NSString stringWithFormat:@"%d",arc4random() % 100000] userData:@""];
    
    ArMethodText(@"initWithDelegate:");
    ArMethodText(@"setLocalVideoCapturer:");
    ArMethodText(@"joinRTCByToken:");
}

- (void)initializeUI {
    self.videoArr = [NSMutableArray arrayWithCapacity:4];
    self.roomIdLabel.text = [NSString stringWithFormat:@"  房间号：%@  ",self.meetId];
    
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width).multipliedBy(0.84);
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-20);
        make.height.equalTo(@(scrollHeight));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    self.stackView.alignment = UIStackViewAlignmentCenter;
    self.stackView.spacing = 1;
    [self.scrollView addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];
}

- (IBAction)handleSomethingEvent:(UIButton *)sender {
    switch (sender.tag) {
        case 50:
            //音频
            sender.selected = !sender.selected;
            [self.meetKit setLocalAudioEnable:!sender.selected];
            ArMethodText(@"setLocalAudioEnable:");
            break;
        case 51:
            //离开会议
            [self.meetKit leaveRTC];
            ArMethodText(@"leaveRTC");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 52:
            //视频
            sender.selected = !sender.selected;
            [self.meetKit setLocalVideoEnable:!sender.selected];
            ArMethodText(@"setLocalVideoEnable:");
            break;
        case 53:
            [self.meetKit switchCamera];
            ArMethodText(@"switchCamera");
            break;
        case 54:
            //日志
        {
            ArLogView *logView = [[ArLogView alloc] initWithFrame:self.view.bounds];
            [logView refreshLogText:self.logArr];
            UIWindow *window = UIApplication.sharedApplication.delegate.window;
            [window addSubview:logView];
        }
            break;
        default:
            break;
    }
}

// MARK: - ARMeetKitDelegate

- (void)onRTCJoinMeetOK:(NSString *)anyRTCId {
    //加入会议成功
    ArCallbackLog;
}

- (void)onRTCJoinMeetFailed:(NSString *)anyRTCId code:(ARMeetCode)code reason:(NSString *)reason {
    //加入会议失败
    NSString *errorText = @"加入会议失败";
    (code == ARMeet_IS_FULL) ? (errorText = @"会议人数已满") : nil;
    [SVProgressHUD showErrorWithStatus:errorText];
    [self leaveRoom];
    ArCallbackLog;
}

- (void)onRTCConnectionLost {
    //RTC服务已断开
    [SVProgressHUD showErrorWithStatus:@"请检查当前网络状况"];
    [SVProgressHUD dismissWithDelay:1.0];
    ArCallbackLog;
}

- (void)onRTCLeaveMeet:(ARMeetCode)code {
    //离开会议
    if (code == ARMeet_NET_ERR) {
        [SVProgressHUD showErrorWithStatus:@"请检查当前网络状况"];
        [self leaveRoom];
    }
    ArCallbackLog;
}

- (void)onRTCOpenRemoteVideoRender:(NSString *)peerId pubId:(NSString *)pubId userId:(NSString *)userId userData:(NSString *)userData {
    //其他与会者加入(音视频)
    [self openVideoRender:peerId pubId:pubId];
    ArCallbackLog;
}

- (void)onRTCCloseRemoteVideoRender:(NSString *)peerId pubId:(NSString *)pubId userId:(NSString *)userId {
    //其他与会者离开(音视频)
    [self closeVideoRender:peerId pubId:pubId];
    ArCallbackLog;
}

- (void)onRTCOpenRemoteScreenRender:(NSString *)peerId pubId:(NSString *)pubId userId:(NSString *)userId userData:(NSString *)userData {
    //用户开启桌面共享
    [self openVideoRender:peerId pubId:pubId];
    ArCallbackLog;
}

- (void)onRTCCloseRemoteScreenRender:(NSString *)peerId pubId:(NSString *)pubId userId:(NSString *)userId {
    //用户退出桌面共享
    [self closeVideoRender:peerId pubId:pubId];
    ArCallbackLog;
}

- (void)onRTCRemoteAVStatus:(NSString *)peerId audio:(BOOL)audio video:(BOOL)video {
    //其他与会者对音视频的操作
    ArCallbackLog;
}

- (void)onRTCLocalAVStatus:(BOOL)audio video:(BOOL)video {
    //别人对自己音视频的操作
    ArCallbackLog;
}

- (void)onRTCFirstLocalVideoFrame:(CGSize)size {
    //本地视频第一帧
    ArCallbackLog;
}

- (void)onRTCFirstRemoteVideoFrame:(CGSize)size pubId:(NSString *)pubId {
    //远程视频第一帧
    ArCallbackLog;
}

- (void)onRTCLocalVideoViewChanged:(CGSize)size {
    //本地窗口大小的回调
    ArCallbackLog;
}

- (void)onRTCRemoteVideoViewChanged:(CGSize)size pubId:(NSString *)pubId {
    //远程窗口大小的回调
    ArCallbackLog;
}

- (void)onRTCRemoteAudioActive:(NSString *)peerId userId:(NSString *)userId audioLevel:(int)level showTime:(int)time {
    //其他与会者音频检测回调
    ArCallbackLog;
}

- (void)onRTCLocalAudioActive:(int)level showTime:(int)time {
    //本地音频检测回调
    ArCallbackLog;
}

- (void)onRTCRemoteNetworkStatus:(NSString *)peerId userId:(NSString *)userId netSpeed:(int)netSpeed packetLost:(int)packetLost netQuality:(ARNetQuality)netQuality {
    //其他与会者网络质量回调
    ArCallbackLog;
}

- (void)onRTCLocalNetworkStatus:(int)netSpeed packetLost:(int)packetLost netQuality:(ARNetQuality)netQuality {
    //本地网络质量回调
    ArCallbackLog;
}

- (void)onRTCUserMessage:(NSString *)userId userName:(NSString *)userName userHeader:(NSString *)headerUrl content:(NSString *)content {
    //收到消息回调
    ArCallbackLog;
}

// MARK: - ArVideoDelegate

- (void)switchScreen:(UIView *)video {
    //移除点击手势
    [self.stackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (UITapGestureRecognizer *tap in obj.gestureRecognizers) {
            [obj removeGestureRecognizer:tap];
        }
    }];
    
    UIView *largeView = [self.view viewWithTag:1000];
    largeView.tag = 0;
    [self.stackView addArrangedSubview:largeView];
    [largeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(scrollHeight * 3/4));
        make.height.equalTo(@(scrollHeight));
    }];
    
    video.tag = 1000;
    [self.view insertSubview:video belowSubview:self.roomIdLabel];
    [video mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.stackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ArVideoView class]]) {
            ArVideoView *videoView = (ArVideoView *)obj;
            [videoView addGestureRecognizer];
        } else {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoTap)];
            [self.localView addGestureRecognizer:tap];
        }
    }];
}

// MARK: - other

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"logArr"]) {
        for (UIView *subView in UIApplication.sharedApplication.keyWindow.subviews) {
            if ([subView isKindOfClass:[ArLogView class]]) {
                ArLogView *logView = (ArLogView *)subView;
                [logView refreshLogText:self.logArr];
                break;
            }
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(self.stackView.frame.size.width, self.stackView.frame.size.height);
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (scrollHeight * 3/4 * self.videoArr.count > self.scrollView.frame.size.width) {
            make.edges.equalTo(self.scrollView);
        } else {
            make.centerX.equalTo(self.scrollView.mas_centerX);
            make.top.bottom.equalTo(self.scrollView);
        }
    }];
    [self.scrollView layoutIfNeeded];
}

- (void)leaveRoom {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self.meetKit leaveRTC];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)openVideoRender:(NSString *)peerId pubId:(NSString *)pubId {

    ArVideoView *videoView = [[ArVideoView alloc] initWithPubId:pubId peerId:peerId];
    [self.stackView addArrangedSubview:videoView];
    [videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(scrollHeight * 3/4));
        make.height.equalTo(@(scrollHeight));
    }];
    videoView.delegate = self;
    [self.meetKit setRemoteVideoRender:videoView pubId:pubId];
 
    [self.meetKit updateRTCVideoRenderModel:ARVideoRenderScaleAspectFit pubId:pubId];
    [self.videoArr addObject:videoView];  
}

- (void)closeVideoRender:(NSString *)peerId pubId:(NSString *)pubId {
    [self.videoArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ArVideoView class]]) {
            ArVideoView *videoView = (ArVideoView *)obj;
            if ([videoView.pubId isEqualToString:pubId]) {
                [self.videoArr removeObject:videoView];
                [videoView removeFromSuperview];
                if (videoView.tag == 1000) {
                    self.localView.tag = 1000;
                    [self.view insertSubview:self.localView belowSubview:self.roomIdLabel];
                    [self.localView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(self.view);
                    }];
                }
                *stop = YES;
            }
        }
    }];
}

- (void)videoTap {
    [self switchScreen:self.localView];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"logArr"];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
