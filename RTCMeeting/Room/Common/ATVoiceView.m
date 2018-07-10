//
//  ATVoiceView.m
//  RTCMeeting
//
//  Created by jh on 2017/10/17.
//  Copyright © 2017年 jh. All rights reserved.
//

#import "ATVoiceView.h"



@implementation ATVoiceView

+ (instancetype)loadVoiceView{
    return [[[NSBundle mainBundle]loadNibNamed:@"ATVoiceView" owner:self options:nil] lastObject];
}

- (void)startAnimation{
    
    self.animImageView.animationImages = self.tempArr;
    
    self.animImageView.animationDuration = 0.5f;
    
    self.animImageView.animationRepeatCount = 10;
    
    [self.animImageView startAnimating];
    
    [self performSelector:@selector(deleteGif:) withObject:nil afterDelay:3];
}

- (void)deleteGif:(id)object{
    [self.animImageView stopAnimating];
    self.animImageView.animationImages = nil;
    self.tempArr = nil;
}

- (NSMutableArray *)tempArr{
    if (!_tempArr) {
        _tempArr = [NSMutableArray arrayWithCapacity:2];
        for (int i = 0; i < 2; i ++) {
            UIImage *image =  [UIImage imageNamed:[NSString stringWithFormat:@"icon_volume_%d",i]];
            [_tempArr addObject:image];
        }
    }
    return _tempArr;
}

@end
