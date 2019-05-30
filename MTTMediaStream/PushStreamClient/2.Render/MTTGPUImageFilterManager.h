//
//  MTTGPUImageFilterManager.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/5/30.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// MARK: - 滤镜类型
typedef enum : NSUInteger {
    // 像素化
    MTTGPUImagePixellateFilter = 0,
    // 指定位置像素化
    MTTGPUImagePixellatePositionFilter = 1,
    // 怀旧
    MTTGPUImageSepiaFilter = 2,
    // 反色
    MTTGPUImageColorInvertFilter = 3,
    // 饱和度
    MTTGPUImageSaturationFilter = 4,
    // 对比度
    MTTGPUImageContrastFilter = 5,
    // 曝光
    MTTGPUImageExposureFilter = 6,
    // 亮度
    MTTGPUImageBrightnessFilter = 7,
    // 色阶
    MTTGPUImageLevelsFilter = 8,
    // 锐化
    MTTGPUImageSharpenFilter = 9,
    // gamma
    MTTGPUImageGammaFilter = 10,
    // 漫画反色
    MTTGPUImageSobelEdgeDetectionFilter = 11,
    // 素描
    MTTGPUImageSketchFilter = 12,
    // 卡通
    MTTGPUImageToonFilter = 13,
    // 细腻卡通
    MTTGPUImageSmoothToonFilter = 14,
    // 阴影深度
    MTTGPUImageMultiplyBlendFilter = 15,
    // 溶解
    MTTGPUImageDissolveBlendFilter = 16,
    // 水粉画
    MTTGPUImageKuwaharaFilter = 17,
    // 
    MTTGPUImageKuwaharaRadius3Filter = 18,
    // 晕影
    MTTGPUImageVignetteFilter = 19,
    // 高斯模糊
    MTTGPUImageGaussianBlurFilter = 20,
    // 高斯模糊 指定模糊
    MTTGPUImageGaussianBlurPositionFilter = 21,
    // 高斯模糊 部分清晰
    MTTGPUImageGaussianSelectiveBlurFilter = 22,
    // 叠加
    MTTGPUImageOverlayBlendFilter = 23,
    // 加深混合
    MTTGPUImageDarkenBlendFilter = 24,
    // 减淡混合
    MTTGPUImageLightenBlendFilter = 25,
    // 旋涡
    MTTGPUImageSwirlFilter = 26,
    // 源混合
    MTTGPUImageSourceOverBlendFilter = 27,
    // 色彩加深混合
    MTTGPUImageColorBurnBlendFilter = 28,
    // 色彩减淡混合
    MTTGPUImageColorDodgeBlendFilter = 29,
    // 屏幕混合
    MTTGPUImageScreenBlendFilter = 30,
    // 排除混合
    MTTGPUImageExclusionBlendFilter = 31,
    // 差异混合
    MTTGPUImageDifferenceBlendFilter = 32,
    // 差值混合
    MTTGPUImageSubtractBlendFilter = 33,
    // 强光混合
    MTTGPUImageHardLightBlendFilter = 34,
    // 柔光混合
    MTTGPUImageSoftLightBlendFilter = 35,
    // 颜色混合
    MTTGPUImageColorBlendFilter = 36,
    // 色调混合
    MTTGPUImageHueBlendFilter = 37,
    // 饱和度混合
    MTTGPUImageSaturationBlendFilter = 38,
    // 亮度混合
    MTTGPUImageLuminosityBlendFilter = 39,
    // 裁剪
    MTTGPUImageCropFilter = 40,
    // 灰度
    MTTGPUImageGrayscaleFilter = 41,
    // 变换
    MTTGPUImageTransformFilter = 42,
    // 色度键混合
    MTTGPUImageChromaKeyBlendFilter = 43,
    // 朦胧加暗
    MTTGPUImageHazeFilter = 44,
    // 亮度阈
    MTTGPUImageLuminanceThresholdFilter = 45,
    // 色度分离
    MTTGPUImagePosterizeFilter = 46,
    // 盒状模糊
    MTTGPUImageBoxBlurFilter = 47,
    // 自适应阈值
    MTTGPUImageAdaptiveThresholdFilter = 48,
    // 钝
    MTTGPUImageUnsharpMaskFilter = 49,
    // 鱼眼
    MTTGPUImageBulgeDistortionFilter = 50,
    // 凹面镜
    MTTGPUImagePinchDistortionFilter = 51,
    // 黑白网状
    MTTGPUImageCrosshatchFilter = 52,
    // CGA色彩
    MTTGPUImageCGAColorspaceFilter = 53,
    // 同心圆像素
    MTTGPUImagePolarPixellateFilter = 54,
    // 哈哈镜
    MTTGPUImageStretchDistortionFilter = 55,
    // 花边噪点
    MTTGPUImagePerlinNoiseFilter = 56,
    // 
    MTTGPUImageJFAVoronoiFilter = 57,
    // 伏龙吸收器
    MTTGPUImageVoronoiConsumerFilter = 58,
    // 马赛克
    MTTGPUImageMosaicFilter = 59,
    // 条纹模糊 中间清晰
    MTTGPUImageTiltShiftFilter = 60,
    // 3x3卷积
    MTTGPUImage3x3ConvolutionFilter = 61,
    // 浮雕
    MTTGPUImageEmbossFilter = 62,
    // 边缘检测
    MTTGPUImageCannyEdgeDetectionFilter = 63,
    // 边缘检测
    MTTGPUImageThresholdEdgeDetectionFilter = 64,
    // 遮罩
    MTTGPUImageMaskFilter = 65,
    // 色彩直方图
    MTTGPUImageHistogramFilter = 66,
    // 色彩直方图
    MTTGPUImageHistogramGenerator = 67,
    // 直方图均衡化
    MTTGPUImageHistogramEqualizationFilter = 68,
    // 普瑞维特
    MTTGPUImagePrewittEdgeDetectionFilter = 69,
    // XYDerivative边缘检测
    MTTGPUImageXYDerivativeFilter = 70,
    // 角点检测
    MTTGPUImageHarrisCornerDetectionFilter = 71,
    // 透明混合
    MTTGPUImageAlphaBlendFilter = 72,
    // 正常混合
    MTTGPUImageNormalBlendFilter = 73,
    // 非最大抑制
    MTTGPUImageNonMaximumSuppressionFilter = 74,
    // RGB 
    MTTGPUImageRGBFilter = 75,
    // 中间值
    MTTGPUImageMedianFilter = 76,
    // 双边模糊
    MTTGPUImageBilateralFilter = 77,
    // 十字
    MTTGPUImageCrosshairGenerator = 78,
    // 色调曲线
    MTTGPUImageToneCurveFilter = 79,
    // Noble角点检测
    MTTGPUImageNobleCornerDetectionFilter = 80,
    // 角点检测
    MTTGPUImageShiTomasiFeatureDetectionFilter = 81,
    // 侵蚀边缘模糊
    MTTGPUImageErosionFilter = 82,
    // RGB侵蚀模糊
    MTTGPUImageRGBErosionFilter = 83,
    // 扩展边缘模糊
    MTTGPUImageDilationFilter = 84,
    // RGB扩展边缘模糊
    MTTGPUImageRGBDilationFilter = 85,
    // 黑白色调模糊
    MTTGPUImageOpeningFilter = 86,
    // RGB扩展边缘模糊，有色彩
    MTTGPUImageRGBOpeningFilter = 87,
    // 黑白色调模糊，暗色会被提亮
    MTTGPUImageClosingFilter = 88,
    // 彩色模糊，暗色会被提亮
    MTTGPUImageRGBClosingFilter = 89,
    // 色彩丢失，模糊（类似监控摄像效果）
    MTTGPUImageColorPackingFilter = 90,
    // 球形折射，图形倒立
    MTTGPUImageSphereRefractionFilter = 91,
    // 单色
    MTTGPUImageMonochromeFilter = 92,
    // 透明度
    MTTGPUImageOpacityFilter = 93,
    // 提亮阴影
    MTTGPUImageHighlightShadowFilter = 94,
    // 色彩替换（替换亮部和暗部色彩）
    MTTGPUImageFalseColorFilter = 95,
    // 
    MTTGPUImageHSBFilter = 96,
    // 色度
    MTTGPUImageHueFilter = 97,
    // 水晶球效果
    MTTGPUImageGlassSphereFilter = 98,
    // lookup 色彩调整
    MTTGPUImageLookupFilter = 99,
    // Amatorka lookup
    MTTGPUImageAmatorkaFilter = 100,
    // MissEtikate lookup
    MTTGPUImageMissEtikateFilter = 101,
    // SoftElegance lookup
    MTTGPUImageSoftEleganceFilter = 102,
    // 通常用于创建两个图像之间的动画变亮模糊效果
    MTTGPUImageAddBlendFilter = 103,
    // 通常用于创建两个图像之间的动画变暗模糊效果
    MTTGPUImageDivideBlendFilter = 104,
    // 像素圆点花样
    MTTGPUImagePolkaDotFilter = 105,
    // 图像黑白化，并有大量噪点
    MTTGPUImageLocalBinaryPatternFilter = 106,
    // Lanczos重取样，模糊效果
    MTTGPUImageLanczosResamplingFilter = 107,
    // 像素平均色值
    MTTGPUImageAverageColor = 108,
    // 纯色
    MTTGPUImageSolidColorGenerator = 109,
    // 亮度平均
    MTTGPUImageLuminosity = 110,
    // 像素色值亮度平均，图像黑白（有类似漫画效果）
    MTTGPUImageAverageLuminanceThresholdFilter = 111,
    // 白平衡
    MTTGPUImageWhiteBalanceFilter = 112,
    // 色度键
    MTTGPUImageChromaKeyFilter = 113,
    // 用于图像加亮
    MTTGPUImageLowPassFilter = 114,
    // 图像低于某值时显示为黑
    MTTGPUImageHighPassFilter = 115,
    // 动作检测
    MTTGPUImageMotionDetector = 116,
    // 点染,图像黑白化，由黑点构成原图的大致图形
    MTTGPUImageHalftoneFilter = 117,
    // 非最大抑制，只显示亮度最高的像素，其他为黑，像素丢失更多
    MTTGPUImageThresholdedNonMaximumSuppressionFilter = 118,
    // 线条检测
    MTTGPUImageHoughTransformLineDetector = 120,
    // 平行线检测
    MTTGPUImageParallelCoordinateLineTransformFilter = 121,
    // 阀值素描，形成有噪点的素描
    MTTGPUImageThresholdSketchFilter = 122,
    // 线条
    MTTGPUImageLineGenerator = 123,
    // 线性烧混合
    MTTGPUImageLinearBurnBlendFilter = 124,
    // 
    MTTGPUImageTwoInputCrossTextureSamplingFilter = 125,
    // 泊松混合
    MTTGPUImagePoissonBlendFilter = 126,
    // 动态模糊
    MTTGPUImageMotionBlurFilter = 127,
    // 缩放模糊
    MTTGPUImageZoomBlurFilter = 128,
    // 拉普拉斯算子
    MTTGPUImageLaplacianFilter = 129,
    // iOS模糊
    MTTGPUImageiOSBlurFilter = 130,
    // 亮度范围
    MTTGPUImageLuminanceRangeFilter = 131,
    // 方向最大抑制
    MTTGPUImageDirectionalNonMaximumSuppressionFilter = 132,
    // 定向观测
    MTTGPUImageDirectionalSobelEdgeDetectionFilter = 133,
    // 单分量高斯模糊
    MTTGPUImageSingleComponentGaussianBlurFilter = 134,
    // 三个输入文理
    MTTGPUImageThreeInputFilter = 135,
    // 弱像素包含
    MTTGPUImageWeakPixelInclusionFilter = 136,
} MTTGPUImageFilterType;

@interface MTTGPUImageFilterManager : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


/**
 根据滤镜类型渲染图片

 @param image 原始图片
 @param type 滤镜类型
 @return 渲染后的图片
 */
+ (UIImage *)renderImage:(UIImage *)image filterType:(MTTGPUImageFilterType)type;

@end

NS_ASSUME_NONNULL_END
