//
//  ARMeetOption.h
//  RTMeetEngine
//
//  Created by zjq on 2019/1/15.
//  Copyright © 2019 EricTao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARObjects.h"
#import "ARMeetEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARMeetOption : NSObject

/**
 使用默认配置生成一个 ARMeetOption 对象
 
 @return 生成的 ARMeetOption 对象
 */
+ (nonnull ARMeetOption *)defaultOption;


/**
 媒体类型
 
 说明：选择是音频还是音视频，默认：ARMediaTypeVideo 音视频。设置为音频时，视频功能都不能用。
 */
@property (nonatomic, assign) ARMediaType meidaType;

/**
 设置会议模式，默认ARMeetTypeNomal
 */
@property (nonatomic, assign) ARMeetType meetType;

/**
 设置相机类型
 
 说明：根据自己的需求，选择相应的相机类型;默认ARCameraTypeNomal
 */
@property (nonatomic, assign) ARCameraType cameraType;

/**
 视频配置项
 */
@property (nonatomic, strong) ARVideoConfig *videoConfig;

/**
 是否是主持人
 
 说明：只有ARMeetType设置为ARMeetTypeHoster才有用，设置YES其他人都能看得到，NO只能看到Hoster的视频，一个会议只能有一个人设置为YES。
 */
@property (nonatomic, assign) BOOL isHost;

@end

NS_ASSUME_NONNULL_END
