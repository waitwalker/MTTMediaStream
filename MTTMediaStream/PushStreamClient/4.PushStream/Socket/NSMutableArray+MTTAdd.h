//
//  NSMutableArray+LFAdd.h
//  YYKit
//
//  Created by waitwalker on 19/5/20.
//  Copyright © 2019年 waitwalker All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MTTAdd)

/**
   Removes and returns the object with the lowest-valued index in the array.
   If the array is empty, it just returns nil.

   @return The first object, or nil.
 */
- (nullable id)mPopFirstObject;

@end
