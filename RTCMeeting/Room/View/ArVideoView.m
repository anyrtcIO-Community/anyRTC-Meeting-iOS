//
//  ArVideoView.m
//  RTCMeeting
//
//  Created by 余生丶 on 2019/4/4.
//  Copyright © 2019 Ar. All rights reserved.
//

#import "ArVideoView.h"

@implementation ArVideoView

- (instancetype)initWithPubId:(NSString *)pubId peerId:(NSString *)peerId {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        self.pubId = pubId;
        self.peerId = peerId;
        [self addGestureRecognizer];
    }
    return self;
}

- (void)addGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoTap)];
    [self addGestureRecognizer:tap];
}

- (void)videoTap{
    if ([self.delegate respondsToSelector:@selector(switchScreen:)]) {
        [self.delegate switchScreen:self];
    }
}

@end
