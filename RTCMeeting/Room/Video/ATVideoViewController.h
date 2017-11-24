//
//  ATVideoViewController.h
//  RTCMeeting
//
//  Created by jh on 2017/10/13.
//  Copyright © 2017年 jh. All rights reserved.
//四人会议模式

#import <UIKit/UIKit.h>

@interface ATVideoViewController : UIViewController

@property (nonatomic, assign)RTCMeetingMode typeMode;
//昵称
@property (nonatomic, copy)NSString *userName;

@property (nonatomic, assign) CGFloat scale;

@end
