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
@property (nonatomic, strong) NSMutableArray *thresholdList;

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

- (void)dealloc {
    
}

- (void)appendFrame:(MTTFrame *)frame {
    if (!frame) {
        return;
    }
    
    if (!_startTimer) {
        _startTimer = true;
        [self tick];
    }
}

// MARK: - 采样
- (void)tick {
    _currentInterval += self.updateInterval;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [self.thresholdList addObject:@(self.list.count)];
    dispatch_semaphore_signal(_lock);
    
    if (self.currentInterval >= self.callBackInterval) {
        MTTLiveBufferState state = [self currentBufferState];
        if (state == MTTLiveBufferIncrease) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(streamingBuffer:bufferState:)]) {
                [self.delegate streamingBuffer:self bufferState:MTTLiveBufferIncrease];
            } else if (state == MTTLiveBufferDeclines) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(streamingBuffer:bufferState:)]) {
                    [self.delegate streamingBuffer:self bufferState:MTTLiveBufferDeclines];
                }
            }
        }
        
        self.currentInterval = 0;
        [self.thresholdList removeAllObjects];
    }
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.updateInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        [self tick];
    });
}

- (MTTLiveBufferState)currentBufferState {
    NSInteger currentCount = 0;
    NSInteger increaseCount = 0;
    NSInteger decreaseCount = 0;
    
    for (NSNumber *number in self.thresholdList) {
        if (number.integerValue > currentCount) {
            increaseCount++;
        } else{
            decreaseCount++;
        }
        currentCount = [number integerValue];
    }
    
    if (increaseCount >= self.callBackInterval) {
        return MTTLiveBufferIncrease;
    }
    
    if (decreaseCount >= self.callBackInterval) {
        return MTTLiveBufferDeclines;
    }
    
    return MTTLiveBufferUnknown;
}

@end
