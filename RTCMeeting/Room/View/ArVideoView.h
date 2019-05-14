//
//  ArVideoView.h
//  RTCMeeting
//
//  Created by 余生丶 on 2019/4/4.
//  Copyright © 2019 Ar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ArVideoDelegate <NSObject>
/** 切换大小屏 */
- (void)switchScreen:(UIView *)video;

@end

@interface ArVideoView : UIView
/** 流的唯一标识 */
@property (nonatomic, copy) NSString *pubId;
@property (nonatomic, copy) NSString *peerId;

@property (nonatomic, weak) id <ArVideoDelegate> delegate;

- (instancetype)initWithPubId:(NSString *)pubId peerId:(NSString *)peerId;

/** 添加手势，只能小屏切换大屏 */
- (void)addGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
