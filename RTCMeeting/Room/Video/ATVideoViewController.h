//
//  ATVideoViewController.h
//  RTCMeeting
//
//  Created by jh on 2018/7/6.
//  Copyright © 2018年 jh. All rights reserved.
//四人会议模式

#import <UIKit/UIKit.h>

@interface ATVideoViewController : UIViewController

@property (nonatomic, assign)RTCMeetingMode typeMode;
//昵称
@property (nonatomic, copy)NSString *userName;

@property (nonatomic, assign) CGFloat scale;

@end
