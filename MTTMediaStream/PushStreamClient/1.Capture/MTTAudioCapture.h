//
//  LFAudioCapture.h
//   
//
//  Created by waitwalker on 19/5/20.
//  Copyright © 2019年 waitwalker All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MTTLiveAudioConfiguration.h"

#pragma mark -- AudioCaptureNotification
/** compoentFialed will post the notification */
extern NSString *_Nullable const kAudioComponentFailedToCreateNotification;

@class MTTAudioCapture;
/** LFAudioCapture callback audioData */
@protocol MTTAudioCaptureDelegate <NSObject>
- (void)captureOutput:(nullable MTTAudioCapture *)capture audioData:(nullable NSData*)audioData;
@end


@interface MTTAudioCapture : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================

/** The delegate of the capture. captureData callback */
@property (nullable, nonatomic, weak) id<MTTAudioCaptureDelegate> delegate;

/** The muted control callbackAudioData,muted will memset 0.*/
@property (nonatomic, assign) BOOL muted;

/** The running control start capture or stop capture*/
@property (nonatomic, assign) BOOL running;

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
   The designated initializer. Multiple instances with the same configuration will make the
   capture unstable.
 */
- (nullable instancetype)initWithAudioConfiguration:(nullable MTTLiveAudioConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

@end
