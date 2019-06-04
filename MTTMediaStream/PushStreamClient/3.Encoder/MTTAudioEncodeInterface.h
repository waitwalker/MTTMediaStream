//
//  MTTAudioEncodeInterface.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/4.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTLiveAudioConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MTTAudioEncodeInterface <NSObject>

@required
- (void)encodeAudioData:(nullable NSData*)audioData timeStamp:(uint64_t)timeStamp;
- (void)stopEncoder;

@optional
- (nullable instancetype)initWithAudioSteamConfiguration:(nullable MTTLiveAudioConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
