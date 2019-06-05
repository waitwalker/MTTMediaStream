//
//  MTTHardwareAudioEncoder.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/5.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTHardwareAudioEncoder.h"

@interface MTTHardwareAudioEncoder(){
    AudioConverterRef m_converter;
    char *leftBuf;
    char *accBuf;
    NSInteger leftLength;
    FILE *fp;
    BOOL enabledWirteAudioFile;
}
@property (nonatomic, strong) MTTLiveAudioConfiguration *configuration;
@property (nonatomic, weak) id<MTTAudioEncodeDelegate>accDelegate;


@end

@implementation MTTHardwareAudioEncoder

@end
