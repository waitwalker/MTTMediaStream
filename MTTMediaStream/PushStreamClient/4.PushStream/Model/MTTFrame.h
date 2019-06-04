//
//  MTTFrame.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/4.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTTFrame : NSObject
@property (nonatomic, assign) uint64_t timeStamp;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSData *header;

@end

NS_ASSUME_NONNULL_END
