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

// MARK: - 添加frame
- (void)appendFrame:(MTTFrame *)frame {
    if (!frame) {
        return;
    }
    
    if (!_startTimer) {
        _startTimer = true;
        [self tick];
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (self.sortList.count < defaultSortBufferMaxCount) {
        [self.sortList addObject:frame];
    } else {
        // 排序
        [self.sortList addObject:frame];
        [self.sortList sortUsingFunction:frameDataCompare context:nil];
        
        // 丢帧
        [self removeExpireFrame];
        
        // 添加到缓冲区
        MTTFrame *firstFrame = [self.sortList mPopFirstObject];
        
        if (firstFrame) {
            [self.list addObject:firstFrame];
        }
    }
    dispatch_semaphore_signal(_lock);
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

NSInteger frameDataCompare(id obj1, id obj2, void *context) {
    MTTFrame *frame1 = (MTTFrame *)obj1;
    MTTFrame *frame2 = (MTTFrame *)obj2;
    if (frame1.timeStamp == frame2.timeStamp) {
        return NSOrderedSame;
    } else if (frame1.timeStamp > frame2.timeStamp) {
        return NSOrderedDescending;
    }
    return NSOrderedAscending;
}

- (void)removeExpireFrame {
    if (self.list.count < self.maxCount) {
        return;
    }
    
    NSArray *pFrames = [self expirePFrames];
    self.lastDropFrames += pFrames.count;
    if (pFrames && pFrames.count > 0) {
        [self.list removeObjectsInArray:pFrames];
        return;
    }
    
    NSArray *iFrames = [self expireIFrames];
    self.lastDropFrames += iFrames.count;
    if (iFrames && iFrames.count > 0) {
        [self.list removeObjectsInArray:iFrames];
        return;
    }
    [self.list removeAllObjects];
}

- (NSArray *)expirePFrames {
    NSMutableArray *pFrames = [NSMutableArray new];
    for (NSInteger index = 0; index < self.list.count; index++) {
        MTTFrame *frame = [self.list objectAtIndex:index];
        if ([frame isKindOfClass:[MTTVideoFrame class]]) {
            MTTVideoFrame *videoFrame = (MTTVideoFrame *)frame;
            if (videoFrame.isKeyFrame && pFrames.count > 0) {
                break;
            } else if (!videoFrame.isKeyFrame) {
                [pFrames addObject:frame];
            }
        }
    }
    return pFrames;
}

- (NSArray *)expireIFrames {
    NSMutableArray *iframes = [NSMutableArray new];
    uint64_t timeStamp = 0;
    for (NSInteger index = 0; index < self.list.count; index ++) {
        MTTFrame *frame = [self.list objectAtIndex:index];
        if ([frame isKindOfClass:[MTTVideoFrame class]] && ((MTTVideoFrame *)frame).isKeyFrame) {
            if (timeStamp != 0 && timeStamp != frame.timeStamp) {
                break;
            }
            [iframes addObject:frame];
            timeStamp = frame.timeStamp;
        }
    }
    return iframes;
}

@end
