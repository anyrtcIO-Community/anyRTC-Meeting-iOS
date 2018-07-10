//
//  ATVideoView.h
//  RTCMeeting
//
//  Created by jh on 2017/10/16.
//  Copyright © 2017年 jh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchDelegate <NSObject>

@optional

- (void)switchScreen:(UIView *)video;

@end


@interface ATVideoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//流的唯一标识
@property (nonatomic, copy)NSString *pubId;

@property (nonatomic, copy)NSString *peerId;

@property (nonatomic, weak) id <SwitchDelegate> delegate;
// 视图的分辨率大小
@property (nonatomic, assign) CGSize videoSize;

+ (instancetype)loadVideoViewWithRTCPubId:(NSString*)pubId andPeerId:(NSString *)peerId withNickName:(NSString *)nameStr;

@end
