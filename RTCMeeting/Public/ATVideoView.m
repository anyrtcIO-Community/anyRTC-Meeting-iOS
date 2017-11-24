//
//  ATVideoView.m
//  RTCMeeting
//
//  Created by jh on 2017/10/16.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATVideoView.h"

@implementation ATVideoView

+ (instancetype)loadVideoView{
    return [[[NSBundle mainBundle]loadNibNamed:@"ATVideoView" owner:self options:nil] lastObject];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoTap)];
    [self addGestureRecognizer:tap];
}

- (void)videoTap{
    if (self.videoBlock) {
        self.videoBlock(self.peerId);
    }
}

@end
