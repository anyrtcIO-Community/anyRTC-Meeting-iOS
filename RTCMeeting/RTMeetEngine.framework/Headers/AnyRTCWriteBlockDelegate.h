//
//  AnyRTCWriteBlockDelegate.h
//  RTMeetEngine
//
//  Created by derek on 2017/10/19.
//  Copyright © 2017年 EricTao. All rights reserved.
//

#ifndef AnyRTCWriteBlockDelegate_h
#define AnyRTCWriteBlockDelegate_h
#import <UIKit/UIKit.h>

@protocol AnyRTCWriteBlockDelegate <NSObject>

/**
 自己打开白板结果
 @return 成功与失败
 */

- (void)onRTCSetWhiteBoardEnableResult:(BOOL)scuess;

/**
 白板开启

 @param strWBInfo 白板信息
 @param strUserId 与开发者自己平台的Id
 @param strUserData 开发者自己平台的相关信息（昵称，头像等)；
 说明：别人打开的白板
 */
- (void)onRTCWhiteBoardOpen:(NSString*)strWBInfo withUserId:(NSString *)strUserId withUserData:(NSString*)strUserData;

/**
 白板关闭
 说明：打开该白板的人关闭了白板
 */
- (void)OnRTCWhiteBoardClose;
@end
#endif /* AnyRTCWriteBlockDelegate_h */
