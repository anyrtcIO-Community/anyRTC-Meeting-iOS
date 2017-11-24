//
//  ATMainViewController.m
//  RTCMeeting
//
//  Created by jh on 2017/10/13.
//  Copyright © 2017年 jh. All rights reserved.
//主页

#import "ATMainViewController.h"

@interface ATMainViewController ()

//高级会议
@property (weak, nonatomic) IBOutlet UIButton *seniorButton;

@end

@implementation ATMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.seniorButton.layer.borderColor = ATBordColor.CGColor;
}

- (IBAction)doSomethingEvents:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
        {
            //普通会议
            [self performSegueWithIdentifier:@"start" sender:nil];
        }
            break;
        case 101:
        {
            //高级会议
            [self performSegueWithIdentifier:@"hall" sender:nil];
        }
            break;
        case 102:
            //技术支持

            [ATCommon callPhone:@"021-65650071" control:sender];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

@end
