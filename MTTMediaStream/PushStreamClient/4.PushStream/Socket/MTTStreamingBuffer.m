//
//  MTTStreamingBuffer.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTStreamingBuffer.h"
#import "NSMutableArray+MTTAdd.h"

static const NSUInteger defaultSortBufferMaxCount = 5;//排序10个内
static const NSUInteger defaultUpdateInterval = 1;//更新频率为1s
static const NSUInteger defaultCallBackInterval = 5;//5s计时一次
static const NSUInteger defaultSendBufferMaxCount = 600;//最大缓冲区

@interface MTTStreamingBuffer(){
    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong) NSMutableArray <MTTFrame *>*sortList;
@property (nonatomic, strong, readwrite) NSMutableArray <MTTFrame *>*list;
@property (nonatomic, strong) NSMutableArray *threadholdList;

@property (nonatomic, assign) NSInteger currentInterval;
@property (nonatomic, assign) NSInteger callBackInterval;
@property (nonatomic, assign) NSInteger updateInterval;
@property (nonatomic, assign) BOOL startTimer;

@end

@implementation MTTStreamingBuffer

- (instancetype)init {
    if (self = [super init]) {
        _lock = dispatch_semaphore_create(1);
        self.updateInterval = defaultUpdateInterval;
        self.callBackInterval = defaultCallBackInterval;
        self.maxCount = defaultSendBufferMaxCount;
        self.lastDropFrames = 0;
        self.startTimer = false;
    }
    return self;
}

@end
