//
//  ATHallViewController.m
//  RTCMeeting
//
//  Created by jh on 2017/10/13.
//  Copyright © 2017年 jh. All rights reserved.
//高级会议室

#import "ATHallViewController.h"

@interface ATHallViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation ATHallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    self.nameLabel.text = [ATCommon randomString:2];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidesKeyBords)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)doSomethingEvents:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 101:
        {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"敬请期待" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertVc animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)hidesKeyBords{
    [ATCommon hideKeyBoard];
}

@end
