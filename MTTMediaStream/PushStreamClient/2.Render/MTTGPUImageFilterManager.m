//
//  MTTGPUImageFilterManager.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/5/30.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTGPUImageFilterManager.h"
#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#elif __has_include("GPUImage/GPUImage.h")
#import "GPUImage/GPUImage.h"
#else
#import "GPUImage.h"
#endif


@implementation MTTGPUImageFilterManager

+ (UIImage *)renderImage:(UIImage *)image filterType:(MTTGPUImageFilterType)type {
    if (image == nil) {
        return nil;
    }
    GPUImageFilter *filter;
    
    switch (type) {
        default:
            break;
        case MTTGPUImagePixellatePositionFilter:
            filter = [GPUImagePixellatePositionFilter new];
            break;
        case MTTGPUImageSepiaFilter:
            filter = [GPUImageSepiaFilter new];
            break;
        case MTTGPUImageColorInvertFilter:
            filter = [GPUImageColorInvertFilter new];
            break;
        case MTTGPUImageSaturationFilter:
            filter = [GPUImageSaturationFilter new];
            break;
        case MTTGPUImageContrastFilter:
            filter = [GPUImageContrastFilter new];
            break;
        case MTTGPUImageExposureFilter:
            filter = [GPUImageExposureFilter new];
            break;
        case MTTGPUImageBrightnessFilter:
            filter = [GPUImageBrightnessFilter new];
            break;
        case MTTGPUImageLevelsFilter:
            filter = [GPUImageLevelsFilter new];
            break;
        case MTTGPUImageSharpenFilter:
            filter = [GPUImageSharpenFilter new];
            break;
        case MTTGPUImageGammaFilter:
            filter = [GPUImageGammaFilter new];
            break;
        case MTTGPUImageSobelEdgeDetectionFilter:
            filter = [GPUImageSobelEdgeDetectionFilter new];
            break;
        case MTTGPUImageSketchFilter:
            filter = [GPUImageSketchFilter new];
            break;
        case MTTGPUImageToonFilter:
            filter = [GPUImageToonFilter new];
            break;
        case MTTGPUImageSmoothToonFilter:
            //filter = [GPUImageSmoothToonFilter new];
            break;
        case MTTGPUImageMultiplyBlendFilter:
            filter = [GPUImageMultiplyBlendFilter new];
            break;
        case MTTGPUImageDissolveBlendFilter:
            filter = [GPUImageDissolveBlendFilter new];
            break;
        case MTTGPUImageKuwaharaFilter:
            filter = [GPUImageKuwaharaFilter new];
            break;
        case MTTGPUImageKuwaharaRadius3Filter:
            filter = [GPUImageKuwaharaRadius3Filter new];
            break;
        case MTTGPUImageVignetteFilter:
            filter = [GPUImageVignetteFilter new];
            break;
        case MTTGPUImageGaussianBlurFilter:
            filter = [GPUImageGaussianBlurFilter new];
            break;
        case MTTGPUImageGaussianBlurPositionFilter:
            filter = [GPUImageGaussianBlurPositionFilter new];
            break;
        case MTTGPUImageGaussianSelectiveBlurFilter:
            //filter = [GPUImageGaussianSelectiveBlurFilter new];
            break;
        case MTTGPUImageOverlayBlendFilter:
            filter = [GPUImageOverlayBlendFilter new];
            break;
        case MTTGPUImageDarkenBlendFilter:
            filter = [GPUImageDarkenBlendFilter new];
            break;
        case MTTGPUImageLightenBlendFilter:
            filter = [GPUImageLightenBlendFilter new];
            break;
        case MTTGPUImageSwirlFilter:
            filter = [GPUImageSwirlFilter new];
            break;
        case MTTGPUImageSourceOverBlendFilter:
            filter = [GPUImageSourceOverBlendFilter new];
            break;
        case MTTGPUImageColorBurnBlendFilter:
            filter = [GPUImageColorBurnBlendFilter new];
            break;
        case MTTGPUImageColorDodgeBlendFilter:
            filter = [GPUImageColorDodgeBlendFilter new];
            break;
        case MTTGPUImageScreenBlendFilter:
            filter = [GPUImageScreenBlendFilter new];
            break;
        case MTTGPUImageExclusionBlendFilter:
            filter = [GPUImageExclusionBlendFilter new];
            break;
        case MTTGPUImageDifferenceBlendFilter:
            filter = [GPUImageDifferenceBlendFilter new];
            break;
        case MTTGPUImageSubtractBlendFilter:
            filter = [GPUImageSubtractBlendFilter new];
            break;
        case MTTGPUImageHardLightBlendFilter:
            filter = [GPUImageHardLightBlendFilter new];
            break;
        case MTTGPUImageSoftLightBlendFilter:
            filter = [GPUImageSoftLightBlendFilter new];
            break;
        case MTTGPUImageColorBlendFilter:
            filter = [GPUImageColorBlendFilter new];
            break;
        case MTTGPUImageHueBlendFilter:
            filter = [GPUImageHueBlendFilter new];
            break;
        case MTTGPUImageSaturationBlendFilter:
            filter = [GPUImageSaturationFilter new];
            break;
        case MTTGPUImageLuminosityBlendFilter:
            filter = [GPUImageLuminosityBlendFilter new];
            break;
        case MTTGPUImageCropFilter:
            filter = [GPUImageCropFilter new];
            break;
        case MTTGPUImageGrayscaleFilter:
            filter = [GPUImageGrayscaleFilter new];
            break;
        case MTTGPUImageTransformFilter:
            filter = [GPUImageTransformFilter new];
            break;
        case MTTGPUImageChromaKeyBlendFilter:
            filter = [GPUImageChromaKeyBlendFilter new];
            break;
        case MTTGPUImageHazeFilter:
            filter = [GPUImageHazeFilter new];
            break;
        case MTTGPUImageLuminanceThresholdFilter:
            filter = [GPUImageLuminanceThresholdFilter new];
            break;
        case MTTGPUImagePosterizeFilter:
            filter = [GPUImagePosterizeFilter new];
            break;
        case MTTGPUImageBoxBlurFilter:
            filter = [GPUImageBoxBlurFilter new];
            break;
        case MTTGPUImageAdaptiveThresholdFilter:
            //filter = [GPUImageAdaptiveThresholdFilter new];
            break;
        case MTTGPUImageUnsharpMaskFilter:
            //filter = [GPUImageUnsharpMaskFilter new];
            break;
        case MTTGPUImageBulgeDistortionFilter:
            filter = [GPUImageBulgeDistortionFilter new];
            break;
        case MTTGPUImagePinchDistortionFilter:
            filter = [GPUImagePinchDistortionFilter new];
            break;
        case MTTGPUImageCrosshatchFilter:
            filter = [GPUImageCrosshatchFilter new];
            break;
        case MTTGPUImageCGAColorspaceFilter:
            filter = [GPUImageCGAColorspaceFilter new];
            break;
        case MTTGPUImagePolarPixellateFilter:
            filter = [GPUImagePolarPixellateFilter new];
            break;
        case MTTGPUImageStretchDistortionFilter:
            filter = [GPUImageStretchDistortionFilter new];
            break;
        case MTTGPUImagePerlinNoiseFilter:
            filter = [GPUImagePerlinNoiseFilter new];
            break;
        case MTTGPUImageJFAVoronoiFilter:
            filter = [GPUImageJFAVoronoiFilter new];
            break;
        case MTTGPUImageVoronoiConsumerFilter:
            filter = [GPUImageVoronoiConsumerFilter new];
            break;
        case MTTGPUImageMosaicFilter:
            filter = [GPUImageMosaicFilter new];
            break;
        case MTTGPUImageTiltShiftFilter:
            //filter = [GPUImageTiltShiftFilter new];
            break;
        case MTTGPUImage3x3ConvolutionFilter:
            filter = [GPUImage3x3ConvolutionFilter new];
            break;
        case MTTGPUImageEmbossFilter:
            filter = [GPUImageEmbossFilter new];
            break;
        case MTTGPUImageCannyEdgeDetectionFilter:
            //filter = [GPUImageCannyEdgeDetectionFilter new];
            break;
        case MTTGPUImageThresholdEdgeDetectionFilter:
            filter = [GPUImageThresholdEdgeDetectionFilter new];
            break;
        case MTTGPUImageMaskFilter:
            filter = [GPUImageMaskFilter new];
            break;
        case MTTGPUImageHistogramFilter:
            filter = [GPUImageHistogramFilter new];
            break;
        case MTTGPUImageHistogramGenerator:
            filter = [GPUImageHistogramGenerator new];
            break;
        case MTTGPUImageHistogramEqualizationFilter:
            //filter = [GPUImageHistogramEqualizationFilter new];
            break;
        case MTTGPUImagePrewittEdgeDetectionFilter:
            filter = [GPUImagePrewittEdgeDetectionFilter new];
            break;
        case MTTGPUImageXYDerivativeFilter:
            filter = [GPUImageXYDerivativeFilter new];
            break;
        case MTTGPUImageHarrisCornerDetectionFilter:
            //filter = [GPUImageHarrisCornerDetectionFilter new];
            break;
        case MTTGPUImageAlphaBlendFilter:
            filter = [GPUImageAlphaBlendFilter new];
            break;
        case MTTGPUImageNormalBlendFilter:
            filter = [GPUImageNormalBlendFilter new];
            break;
        case MTTGPUImageNonMaximumSuppressionFilter:
            filter = [GPUImageNonMaximumSuppressionFilter new];
            break;
        case MTTGPUImageRGBFilter:
            filter = [GPUImageRGBFilter new];
            break;
        case MTTGPUImageMedianFilter:
            filter = [GPUImageMedianFilter new];
            break;
        case MTTGPUImageBilateralFilter:
            filter = [GPUImageBilateralFilter new];
            break;
        case MTTGPUImageCrosshairGenerator:
            filter = [GPUImageCrosshatchFilter new];
            break;
        case MTTGPUImageToneCurveFilter:
            filter = [GPUImageToneCurveFilter new];
            break;
        case MTTGPUImageNobleCornerDetectionFilter:
            //filter = [GPUImageNobleCornerDetectionFilter new];
            break;
        case MTTGPUImageShiTomasiFeatureDetectionFilter:
            //filter = [GPUImageShiTomasiFeatureDetectionFilter new];
            break;
        case MTTGPUImageErosionFilter:
            filter = [GPUImageErosionFilter new];
            break;
        case MTTGPUImageRGBErosionFilter:
            filter = [GPUImageRGBErosionFilter new];
            break;
        case MTTGPUImageDilationFilter:
            filter = [GPUImageDilationFilter new];
            break;
        case MTTGPUImageRGBDilationFilter:
            filter = [GPUImageRGBDilationFilter new];
            break;
        case MTTGPUImageOpeningFilter:
            //filter = [GPUImageOpeningFilter new];
            break;
        case MTTGPUImageRGBOpeningFilter:
            //filter = [GPUImageRGBOpeningFilter new];
            break;
        case MTTGPUImageClosingFilter:
            //filter = [GPUImageClosingFilter new];
            break;
        case MTTGPUImageRGBClosingFilter:
            //filter = [GPUImageRGBClosingFilter new];
            break;
        case MTTGPUImageColorPackingFilter:
            filter = [GPUImageColorPackingFilter new];
            break;
        case MTTGPUImageSphereRefractionFilter:
            filter = [GPUImageSphereRefractionFilter new];
            break;
        case MTTGPUImageMonochromeFilter:
            filter = [GPUImageMonochromeFilter new];
            break;
        case MTTGPUImageOpacityFilter:
            filter = [GPUImageOpacityFilter new];
            break;
        case MTTGPUImageHighlightShadowFilter:
            filter = [GPUImageHighlightShadowFilter new];
            break;
        case MTTGPUImageFalseColorFilter:
            filter = [GPUImageFalseColorFilter new];
            break;
        case MTTGPUImageHSBFilter:
            filter = [GPUImageHSBFilter new];
            break;
        case MTTGPUImageHueFilter:
            filter = [GPUImageHueFilter new];
            break;
        case MTTGPUImageGlassSphereFilter:
            filter = [GPUImageGlassSphereFilter new];
            break;
        case MTTGPUImageLookupFilter:
            filter = [GPUImageLookupFilter new];
            break;
        case MTTGPUImageAmatorkaFilter:
            //filter = [GPUImageAmatorkaFilter new];
            break;
        case MTTGPUImageMissEtikateFilter:
            //filter = [GPUImageMissEtikateFilter new];
            break;
        case MTTGPUImageSoftEleganceFilter:
            //filter = [GPUImageSoftEleganceFilter new];
            break;
        case MTTGPUImageAddBlendFilter:
            filter = [GPUImageAddBlendFilter new];
            break;
        case MTTGPUImageDivideBlendFilter:
            filter = [GPUImageDivideBlendFilter new];
            break;
        case MTTGPUImagePolkaDotFilter:
            filter = [GPUImagePolkaDotFilter new];
            break;
        case MTTGPUImageLocalBinaryPatternFilter:
            filter = [GPUImageLocalBinaryPatternFilter new];
            break;
        case MTTGPUImageLanczosResamplingFilter:
            filter = [GPUImageLanczosResamplingFilter new];
            break;
        case MTTGPUImageAverageColor:
            filter = [GPUImageAverageColor new];
            break;
        case MTTGPUImageSolidColorGenerator:
            filter = [GPUImageSolidColorGenerator new];
            break;
        case MTTGPUImageLuminosity:
            filter = [GPUImageLuminosity new];
            break;
        case MTTGPUImageAverageLuminanceThresholdFilter:
            //filter = [GPUImageAverageLuminanceThresholdFilter new];
            break;
        case MTTGPUImageWhiteBalanceFilter:
            filter = [GPUImageWhiteBalanceFilter new];
            break;
        case MTTGPUImageChromaKeyFilter:
            filter = [GPUImageChromaKeyFilter new];
            break;
        case MTTGPUImageLowPassFilter:
            //filter = [GPUImageLowPassFilter new];
            break;
        case MTTGPUImageHighPassFilter:
            //filter = [GPUImageHighPassFilter new];
            break;
        case MTTGPUImageMotionDetector:
            //filter = [GPUImageMotionDetector new];
            break;
        case MTTGPUImageHalftoneFilter:
            filter = [GPUImageHalftoneFilter new];
            break;
        case MTTGPUImageThresholdedNonMaximumSuppressionFilter:
            filter = [GPUImageThresholdedNonMaximumSuppressionFilter new];
            break;
        case MTTGPUImageHoughTransformLineDetector:
            //filter = [GPUImageHoughTransformLineDetector new];
            break;
        case MTTGPUImageParallelCoordinateLineTransformFilter:
            filter = [GPUImageParallelCoordinateLineTransformFilter new];
            break;
        case MTTGPUImageThresholdSketchFilter:
            filter = [GPUImageThresholdSketchFilter new];
            break;
        case MTTGPUImageLineGenerator:
            filter = [GPUImageLineGenerator new];
            break;
        case MTTGPUImageLinearBurnBlendFilter:
            filter = [GPUImageLinearBurnBlendFilter new];
            break;
        case MTTGPUImageTwoInputCrossTextureSamplingFilter:
            filter = [GPUImageTwoInputFilter new];
            break;
        case MTTGPUImagePoissonBlendFilter:
            filter = [GPUImagePoissonBlendFilter new];
            break;
        case MTTGPUImageMotionBlurFilter:
            filter = [GPUImageMotionBlurFilter new];
            break;
        case MTTGPUImageZoomBlurFilter:
            filter = [GPUImageZoomBlurFilter new];
            break;
        case MTTGPUImageLaplacianFilter:
            filter = [GPUImageLaplacianFilter new];
            break;
        case MTTGPUImageiOSBlurFilter:
            //filter = [GPUImageiOSBlurFilter new];
            break;
        case MTTGPUImageLuminanceRangeFilter:
            //filter = [GPUImageLuminosityBlendFilter new];
            break;
        case MTTGPUImageDirectionalNonMaximumSuppressionFilter:
            filter = [GPUImageDirectionalNonMaximumSuppressionFilter new];
            break;
        case MTTGPUImageDirectionalSobelEdgeDetectionFilter:
            filter = [GPUImageDirectionalSobelEdgeDetectionFilter new];
            break;
        case MTTGPUImageSingleComponentGaussianBlurFilter:
            filter = [GPUImageSingleComponentGaussianBlurFilter new];
            break;
        case MTTGPUImageThreeInputFilter:
            filter = [GPUImageThreeInputFilter new];
            break;
        case MTTGPUImageWeakPixelInclusionFilter:
            filter = [GPUImageWeakPixelInclusionFilter new];
            break;
    }
    if (filter) {
        // 设置要渲染的区域
        [filter forceProcessingAtSize:image.size];
        [filter useNextFrameForImageCapture];
        
        // 获取数据源
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:image];
        // 添加滤镜
        [stillImageSource addTarget:filter];
        // 开始渲染
        [stillImageSource processImage];
        
        UIImage *renderedImage = [filter imageFromCurrentFramebuffer];
        if (renderedImage) {
            return renderedImage;
        } else {
            return nil;
        }
    }
    return nil;
}


@end
