//
//  MTTGPUImageEmptyFilter.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/3.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTGPUImageEmptyFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kMTTGPUImageEmptyFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main(){
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4((textureColor.rgb), textureColor.w);
 }
 
 );
#else
NSString *const kGPUImageInvertFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main(){
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4((textureColor.rgb), textureColor.w);
 }
 
 );
#endif

@implementation MTTGPUImageEmptyFilter

- (instancetype)init{
    if ((self = [super initWithFragmentShaderFromString:kMTTGPUImageEmptyFragmentShaderString])) {
        return nil;
    }
    return self;
}

@end
