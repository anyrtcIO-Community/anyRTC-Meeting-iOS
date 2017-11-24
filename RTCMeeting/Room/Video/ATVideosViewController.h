//
//  ATVideosViewController.h
//  RTCMeeting
//
//  Created by jh on 2017/10/18.
//  Copyright © 2017年 jh. All rights reserved.
//九人会议模式

#import <UIKit/UIKit.h>

@interface ATVideosViewController : UIViewController

@property (nonatomic, copy)NSString *userName;

@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, assign)RTCMeetingMode typeMode;

@end
