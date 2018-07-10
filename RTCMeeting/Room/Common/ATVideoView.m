//
//  ATVideoView.m
//  RTCMeeting
//
//  Created by jh on 2017/10/16.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATVideoView.h"

@implementation ATVideoView

+ (instancetype)loadVideoViewWithRTCPubId:(NSString*)pubId andPeerId:(NSString *)peerId withNickName:(NSString *)nameStr{
    ATVideoView *videoView = [[[NSBundle mainBundle]loadNibNamed:@"ATVideoView" owner:self options:nil] lastObject];
    videoView.backgroundColor = [UIColor clearColor];
    videoView.frame = CGRectZero;
    videoView.pubId = pubId;
    videoView.peerId = peerId;
    videoView.nameLabel.text = nameStr;
    return videoView;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoTap)];
    [self addGestureRecognizer:tap];
}

- (void)videoTap{
    if ([self.delegate respondsToSelector:@selector(switchScreen:)]) {
        [self.delegate switchScreen:self];
    }
}

@end
