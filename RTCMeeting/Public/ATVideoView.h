//
//  ATVideoView.h
//  RTCMeeting
//
//  Created by jh on 2017/10/16.
//  Copyright © 2017年 jh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VideoTapBlock)(NSString *peerId);

@interface ATVideoView : UIView

//唯一标识
@property (nonatomic, copy)NSString *pubId;

// 视图的分辨率大小
@property (nonatomic, assign) CGSize videoSize;

@property (nonatomic, copy)VideoTapBlock videoBlock;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

+ (instancetype)loadVideoView;

@end
