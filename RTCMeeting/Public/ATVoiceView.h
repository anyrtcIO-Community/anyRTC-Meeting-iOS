//
//  ATVoiceView.h
//  RTCMeeting
//
//  Created by jh on 2017/10/17.
//  Copyright © 2017年 jh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATVoiceView : UIView

//昵称
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

//动画
@property (weak, nonatomic) IBOutlet UIImageView *animImageView;

@property (nonatomic, copy)NSString *peerId;

@property (nonatomic, strong)NSMutableArray *tempArr;

+ (instancetype)loadVoiceView;

- (void)startAnimation;

@end
