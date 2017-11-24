//
//  ATStartViewController.m
//  RTCMeeting
//
//  Created by jh on 2017/10/13.
//  Copyright © 2017年 jh. All rights reserved.
//普通会议室

#import "ATStartViewController.h"
#import "ATVideoViewController.h"
#import "ATAudioViewController.h"
#import "ATVideosViewController.h"

@interface ATStartViewController ()

//随机用户名
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *highY;

@end

@implementation ATStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    self.nameLabel.text = [ATCommon randomString:2];
}

- (IBAction)doSomethingEvents:(UIButton *)sender {
    switch (sender.tag) {
        case 99:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 100:
        case 101:
        case 102:
        case 103:
        case 104:
        case 105:
            self.type = sender.tag - 100;
            break;
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"videoName"]) {
        ATVideoViewController *videoVc = segue.destinationViewController;
        videoVc.userName = self.nameLabel.text;
        videoVc.typeMode = self.type;
    } else if ([segue.identifier isEqualToString:@"videosName"]){
        ATVideosViewController *videosVc = segue.destinationViewController;
        videosVc.typeMode = self.type;
        videosVc.userName = self.nameLabel.text;
    } else if([segue.identifier isEqualToString:@"audioName"]){
        ATAudioViewController *audioVc = segue.destinationViewController;
        audioVc.typeMode = self.type;
        audioVc.userName = self.nameLabel.text;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (SCREEN_HEIGHT <= 567) {
        self.highY.constant = 35;
    }
}

@end
