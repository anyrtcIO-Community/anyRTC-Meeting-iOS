//
//  ATAudioViewController.h
//  RTCMeeting
//
//  Created by jh on 2017/10/13.
//  Copyright © 2017年 jh. All rights reserved.
//音频会议室

#import <UIKit/UIKit.h>

@interface ATAudioViewController : UIViewController

@property (nonatomic, copy)NSString *userName;

@property (nonatomic, assign)RTCMeetingMode typeMode;

@end
