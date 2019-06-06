//
//  NSMutableArray+LFAdd.m
//  YYKit
//
//  Created by waitwalker on 19/5/20.
//  Copyright © 2019年 waitwalker All rights reserved.
//

#import "NSMutableArray+MTTAdd.h"

@implementation NSMutableArray (MTTAdd)

- (void)mRemoveFirstObject {
    if (self.count) {
        [self removeObjectAtIndex:0];
    }
}

- (id)mPopFirstObject {
    id obj = nil;
    if (self.count) {
        obj = self.firstObject;
        [self mRemoveFirstObject];
    }
    return obj;
}

@end
