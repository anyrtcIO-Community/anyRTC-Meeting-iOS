//
//  ATAudioViewController.m
//  RTCMeeting
//
//  Created by jh on 2017/10/13.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATAudioViewController.h"

//间距
#define Padding 40

@interface ATAudioViewController ()<RTMeetAudioKitDelegate>

@property (nonatomic, strong)RTMeetAudioKit *meetKit;

@property (nonatomic, strong)NSMutableArray *audioArr;

@property (nonatomic, strong)NSMutableArray *tempArr;

@property (nonatomic, copy)NSString *anyRTCId;

@property (nonatomic, copy)NSString *userId;

//承载其他与会者视图
@property (weak, nonatomic) IBOutlet UIView *audioView;
//房间名
@property (weak, nonatomic) IBOutlet UIButton *topicButton;
//连接提示
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *animImageView;

//昵称
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ATAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.topicButton.userInteractionEnabled = NO;
    if (self.typeMode == RTCMeeting_Audio) {
        [self.topicButton setTitle:@"语音会议室01" forState:UIControlStateNormal];
    } else {
        [self.topicButton setTitle:@"语音会议室02" forState:UIControlStateNormal];
    }
    self.topicButton.layer.mask = [ATCommon getMaskLayer:self.topicButton.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:20];
    self.anyRTCId = [NSString stringWithFormat:@"anymeeting1000%ld",(long)self.typeMode];
    self.nameLabel.text = self.userName;
    
    [self itializationMeetKit];
}

- (void)itializationMeetKit{
    //实例化会议对象
    self.meetKit = [[RTMeetAudioKit alloc]initWithDelegate:self withMeetingType:AnyMeetingTypeNomal];

    NSDictionary *customDict = [NSDictionary dictionaryWithObjectsAndKeys:self.userName,@"nickName",nil];
    NSString *customStr = [ATCommon fromDicToJSONStr:customDict];
    self.userId = [ATCommon randomString:6];
    //加入会议
    [self.meetKit joinRTC:self.anyRTCId andIsHoster:NO andUserId:self.userId andUserData:customStr];
}

#pragma mark - RTMeetKitDelegate
- (void)onRTCJoinMeetOK:(NSString*)strAnyRTCId{
    //加入会议成功的回调
    self.tipsLabel.text = @"RTC会议连接成功...";
    [self startAnimation];
}

- (void)onRTCJoinMeetFailed:(NSString*)strAnyRTCId withCode:(int)nCode{
    //加入会议室失败的回调
    [XHToast showCenterWithText:@"加入会议失败"];
}

- (void)onRTCLeaveMeet:(int)nCode{
    //离开会议的回调
    if (nCode == 100) {
        [XHToast showCenterWithText:@"网络异常"];
        self.tipsLabel.text = @"RTC会议连接失败...";
    }
}

- (void)onRTCOpenAudioTrack:(NSString*)strRTCPeerId withUserId:(NSString *)strUserId withUserData:(NSString*)strUserData{
    //其他与会者加入（音频）
    NSDictionary *dict = [ATCommon fromJsonStr:strUserData];
    ATVoiceView *voiceView = [ATVoiceView loadVoiceView];
    voiceView.nameLabel.text = [dict objectForKey:@"nickName"];
    voiceView.peerId = strRTCPeerId;
    [self.audioArr addObject:voiceView];
    [self.audioView addSubview:voiceView];
    [self layoutAudioView];
}

- (void)onRTCCloseAudioTrack:(NSString*)strRTCPeerId withUserId:(NSString *)strUserId{
    //其他与会者离开（音频）
    @synchronized (self.audioArr){
        for (NSInteger i = 0; i < self.audioArr.count; i++) {
            ATVoiceView *voiceView = self.audioArr[i];
            if ([voiceView.peerId isEqualToString:strRTCPeerId]) {
                [self.audioArr removeObjectAtIndex:i];
                [voiceView removeFromSuperview];
                [self layoutAudioView];
                break;
            }
        }
    }
}

-(void)onRTCAVStatus:(NSString*) strRTCPeerId withAudio:(BOOL)bAudio{
    //其他与会者对音视频的操作的回调（比如对方关闭了音频）
    for (NSInteger i = 0; i < self.audioArr.count; i++) {
        ATVoiceView *voiceView = self.audioArr[i];
        if ([strRTCPeerId isEqualToString:voiceView.peerId]) {
            if (bAudio) {
                voiceView.animImageView.image = [UIImage imageNamed:@""];
            } else {
                //关
                voiceView.animImageView.image = [UIImage imageNamed:@"Button_Voice_02"];
            }
            break;
        }
    }
}

-(void)onRTCAudioActive:(NSString*)strRTCPeerId withUserId:(NSString *)strUserId withShowTime:(int)nTime{
    //RTC音频检测
    if ([strUserId isEqualToString:self.userId]) {
        [self.animImageView startAnimating];
        return;
    }
    
    for (NSInteger i = 0; i < self.audioArr.count; i++) {
        ATVoiceView *voiceView = self.audioArr[i];
        if ([strRTCPeerId isEqualToString:voiceView.peerId]) {
            [voiceView startAnimation];
            break;
        }
    }
}

- (void)onRTCUserMessage:(NSString*)strUserId withUserName:(NSString*)strUserName withUserHeader:(NSString*)strUserHeaderUrl withContent:(NSString*)strContent{
    //收到消息回调
}

#pragma mark - event
- (IBAction)doSomethingEvents:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    switch (sender.tag) {
        case 100:
            [self.meetKit leaveRTC];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 101:
            [self.meetKit setLocalAudioEnable:!sender.selected];
            break;
        default:
            break;
    }
}

#pragma mark - other
- (void)layoutAudioView{
    CGFloat voiceSize = CGRectGetWidth(self.audioView.frame)/3;
    
    CGFloat audioX = CGRectGetMidX(self.audioView.frame) - voiceSize;
    
    for (NSInteger i = 0; i < self.audioArr.count; i++) {
        ATVoiceView *audioView = self.audioArr[i];
        
        if (self.audioArr.count == 1) {
            audioView.frame = CGRectMake(CGRectGetMidX(self.audioView.frame) - voiceSize/2 - Padding, 0, voiceSize, voiceSize);
        } else if (self.audioArr.count == 2) {
            audioView.frame = CGRectMake(audioX + i * voiceSize - Padding, 0, voiceSize, voiceSize);
        } else {
            
            audioView.frame = CGRectMake((i%3) * voiceSize, i/3 * voiceSize, voiceSize, voiceSize);
        }
    }
}

- (void)startAnimation{
    
    self.animImageView.animationImages = self.tempArr;
    
    self.animImageView.animationDuration = 0.5f;
    
    self.animImageView.animationRepeatCount = 10;
    
    [self.animImageView startAnimating];
    
    [self performSelector:@selector(deleteGif:) withObject:nil afterDelay:3];
}

- (void)deleteGif:(id)object{
    [self.animImageView stopAnimating];
    self.animImageView.animationImages = nil;
    self.tempArr = nil;
}

- (NSMutableArray *)tempArr{
    if (!_tempArr) {
        _tempArr = [NSMutableArray arrayWithCapacity:2];
        for (int i = 0; i < 2; i ++) {
            UIImage *image =  [UIImage imageNamed:[NSString stringWithFormat:@"icon_volume_%d",i]];
            [_tempArr addObject:image];
        }
    }
    return _tempArr;
}


- (BOOL)shouldAutorotate{
    [super shouldAutorotate];
    return NO;
}

- (NSMutableArray *)audioArr{
    if (!_audioArr) {
        _audioArr = [[NSMutableArray alloc]init];
    }
    return _audioArr;
}

@end
