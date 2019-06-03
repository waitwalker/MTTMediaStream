
//
//  MTTAudioCapture.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/3.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTAudioCapture.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

NSString *const kAudioComponentFailedToCreateNotification = @"kAudioComponentFailedToCreateNotification";

@interface MTTAudioCapture()

@property (nonatomic, assign) AudioComponentInstance componentInstance;
@property (nonatomic, assign) AudioComponent component;
@property (nonatomic, strong) dispatch_queue_t taskQueue;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong, nullable) MTTLiveAudioConfiguration *configuration;


@end

@implementation MTTAudioCapture

- (instancetype)initWithAudioConfiguration:(MTTLiveAudioConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;
        self.isRunning = false;
        self.taskQueue = dispatch_queue_create("cn.waitwalker.audiocapture.queue", NULL);
        
        // 音频会话
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:session];
        [[NSNotificationCenter defaultCenter]addObserver:session selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:session];
        
        // 采集相关参数设置
        AudioComponentDescription acd;
        acd.componentType = kAudioUnitType_Output;
        acd.componentSubType = kAudioUnitSubType_RemoteIO;
        acd.componentFlags = 0;
        acd.componentFlagsMask = 0;
        
        self.component = AudioComponentFindNext(NULL, &acd);
        
        OSStatus status = noErr;
        status = AudioComponentInstanceNew(self.component, &_componentInstance);
        
        if (status != noErr) {
            [self handleAudioComponentCreationFailure];
        }
        
        UInt32 flagOne = 1;
        AudioUnitSetProperty(self.componentInstance, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &flagOne, sizeof(flagOne));
        AudioStreamBasicDescription desc = {0};
        desc.mSampleRate = _configuration.audioSampleRate;
        desc.mFormatID = kAudioFormatLinearPCM;
        desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
        desc.mChannelsPerFrame = (UInt32)_configuration.numberOfChannels;
        desc.mFramesPerPacket = 1;
        desc.mBitsPerChannel = 16;
        desc.mBytesPerFrame = desc.mBitsPerChannel / 8 * desc.mChannelsPerFrame;
        desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
        
        AURenderCallbackStruct cb;
        cb.inputProcRefCon = (__bridge void *)(self);
        cb.inputProc = handleInputBuffer;
        AudioUnitSetProperty(self.componentInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &desc, sizeof(desc));
        AudioUnitSetProperty(self.componentInstance, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &cb, sizeof(cb));
        
        status = AudioUnitInitialize(self.componentInstance);
        if (status != noErr) {
            [self handleAudioComponentCreationFailure];
        }
        
        [session setPreferredSampleRate:_configuration.audioSampleRate error:nil];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:nil];
        [session setActive:true withOptions:kAudioSessionSetActiveFlag_NotifyOthersOnDeactivation error:nil];
        [session setActive:true error:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    dispatch_sync(self.taskQueue, ^{
        if (self.componentInstance) {
            self.isRunning = false;
            AudioOutputUnitStop(self.componentInstance);
            AudioComponentInstanceDispose(self.componentInstance);
            self.componentInstance = nil;
            self.component = nil;
        } 
    });
}

- (void)setRunning:(BOOL)running {
    if (_running == running) {
        return;
    }
    _running = running;
    if (_running) {
        dispatch_async(self.taskQueue, ^{
           self.isRunning = true;
            NSLog(@"音频采集正在运行");
        });
        [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:nil];
        AudioOutputUnitStart(self.componentInstance);
    } else {
        dispatch_sync(self.taskQueue, ^{
           self.isRunning = false;
            NSLog(@"音频采集停止运行");
            AudioOutputUnitStop(self.componentInstance);
        });
    }
}

- (void)handleRouteChange:(NSNotification *)notification {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSString *seccReason = @"";
    AVAudioSessionRouteChangeReason reason = [[[notification userInfo]objectForKey:AVAudioSessionRouteChangeReasonKey]integerValue];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            seccReason = @"The route changed because no suitable route is now available for the specified category.";
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            seccReason = @"The route changed when the device woke up from sleep.";
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            seccReason = @"The output route was overridden by the app.";
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            seccReason = @"The category of the session object changed.";
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            seccReason = @"The previous audio output path is no longer available.";
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            seccReason = @"A preferred new audio output path is now available.";
            break;
        case AVAudioSessionRouteChangeReasonUnknown:
        default:
            seccReason = @"The reason for the change is unknown.";
            break;
    }
    NSLog(@"handleRouteChange reason is %@", seccReason);
    
    AVAudioSessionPortDescription *inputDesc = [[session.currentRoute.inputs count] ? session.currentRoute.inputs:nil objectAtIndex:0];
    if (inputDesc.portType == AVAudioSessionPortHeadsetMic) {
        
    }
}

- (void)handleInterruption:(NSNotification *)notification {
    AVAudioSessionInterruptionType reason = 0;
    NSString *reasonStr = @"";
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        reason = [[[notification userInfo]objectForKey:AVAudioSessionInterruptionTypeKey]integerValue];
        
        if (reason == AVAudioSessionInterruptionTypeBegan) {
            if (self.isRunning) {
                dispatch_sync(self.taskQueue, ^{
                   NSLog(@"音频采集被打断:stop running"); 
                    AudioOutputUnitStop(self.componentInstance);
                });
            }
        }
        
        if (reason == AVAudioSessionInterruptionTypeEnded) {
            reasonStr = @"AVAudioSessionInterruptionTypeEnded";
            NSNumber *secondReason = [[notification userInfo]objectForKey:AVAudioSessionInterruptionOptionKey];
            switch ([secondReason integerValue]) {
                case AVAudioSessionInterruptionOptionShouldResume:
                    if (self.isRunning) {
                        dispatch_async(self.taskQueue, ^{
                           NSLog(@"音频采集被打断后重启启动:start running");
                            AudioOutputUnitStart(self.componentInstance);
                        });
                    }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    NSLog(@"handleInterruption: %@ reason: %@",[notification name],reasonStr);
}

- (void)handleAudioComponentCreationFailure {
    dispatch_async(dispatch_get_main_queue(), ^{
       [[NSNotificationCenter defaultCenter]postNotificationName:kAudioComponentFailedToCreateNotification object:nil]; 
    });
}

static OSStatus handleInputBuffer(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    @autoreleasepool {
        MTTAudioCapture *source = (__bridge MTTAudioCapture *)inRefCon;
        if (!source) {
            return -1;
        }
        
        AudioBuffer buffer;
        buffer.mData = NULL;
        buffer.mDataByteSize = 0;
        buffer.mNumberChannels = 1;
        
        AudioBufferList buffers;
        buffers.mNumberBuffers = 1;
        buffers.mBuffers[0] = buffer;
        
        OSStatus status = AudioUnitRender(source.componentInstance, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &buffers);
        
        if (source.muted) {
            for (int i = 0; i < buffers.mNumberBuffers; i++) {
                AudioBuffer ab = buffers.mBuffers[i];
                memset(ab.mData, 0, ab.mDataByteSize);
            }
        }
        
        if (status == noErr) {
            if (source.delegate && [source.delegate respondsToSelector:@selector(captureOutput:audioData:)]) {
                [source.delegate captureOutput:source audioData:[NSData dataWithBytes:buffers.mBuffers[0].mData length:buffers.mBuffers[0].mDataByteSize]];
            }
        }
        return status;
    }
}

@end
