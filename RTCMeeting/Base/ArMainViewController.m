//
//  ArMainViewController.m
//  RTCMeeting
//
//  Created by 余生丶 on 2019/3/12.
//  Copyright © 2019 Ar. All rights reserved.
//

#import "ArMainViewController.h"
#import "ArVideoViewController.h"

@interface ArMainViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;

@end

@implementation ArMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)joinRoom:(id)sender {
    if (self.roomIdTextField.text.length != 0) {
        ArVideoViewController *videoVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ArMeet_room"];
        videoVc.meetId = self.roomIdTextField.text;
        [self presentViewController:videoVc animated:YES completion:nil];
    } else {
        [SVProgressHUD showWithStatus:@"请输入房间号"];
        [SVProgressHUD dismissWithDelay:1.0];
    }
}

- (void)hideKeyBoard {
    [self.roomIdTextField resignFirstResponder];
}

@end
