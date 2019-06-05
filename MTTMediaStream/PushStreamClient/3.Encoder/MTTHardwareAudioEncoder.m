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

- (instancetype)initWithAudioSteamConfiguration:(MTTLiveAudioConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;
        if (!leftBuf) {
            leftBuf = malloc(_configuration.bufferLength);
        }
        if (!accBuf) {
            accBuf = malloc(_configuration.bufferLength);
        }
        
#if DEBUG
        enabledWirteAudioFile = false;
        [self initForFilePath];
#endif
        
        
    }
    return self;
}

- (void)initForFilePath {
    NSString *path = [self getFilePathWithFileName:@"iOSAudioDemo.acc"];
    NSLog(@"%@",path);
    self->fp = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "wb");
}

- (NSString *)getFilePathWithFileName:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *writeabelPath = [documentDirectory stringByAppendingPathComponent:filename];
    return writeabelPath;
}

@end
