//
//  MTTH264VideoEncoder.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/5.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTH264VideoEncoder.h"
#import "MTTVideoFrame.h"
#import <CoreMedia/CoreMedia.h>
#import <mach/mach_time.h>
#import "MTTNALUnit.h"
#import "MTTAVEncoder.h"



@interface MTTH264VideoEncoder(){
    FILE *fp;
    NSInteger frameCount;
    BOOL enabledWirteVideoFile;
}

@property (nonatomic, strong) MTTLiveVideoConfiguration *configuration;
@property (nonatomic, weak) id<MTTVideoEncodeDelegate>h264Delegate;
@property (nonatomic, assign) BOOL isBackground;
@property (nonatomic, assign) NSInteger currentVideoBitRate;
@property (nonatomic, strong) dispatch_queue_t sendQueue;
@property (nonatomic, strong) MTTAVEncoder *encoder;

@property (nonatomic, strong) NSData *naluStartCode;
@property (nonatomic, strong) NSMutableData *videoSPSAndPPS;
@property (nonatomic, strong) NSMutableData *spsData;
@property (nonatomic, strong) NSMutableData *ppsData;
@property (nonatomic, strong) NSMutableData *sei;
@property (nonatomic, assign) CMTimeScale timeSacle;
@property (nonatomic, strong) NSMutableArray *orphanedFrames;
@property (nonatomic, strong) NSMutableArray *orphanedSEIFrames;
@property (nonatomic, assign) CMTime lastPTS;


@end


@implementation MTTH264VideoEncoder

@end
