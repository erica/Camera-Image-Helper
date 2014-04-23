/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import "ImageOrientation.h"

uint EXIFOrientationFromUIOrientation(UIImageOrientation uiorientation)
{
    if (uiorientation > 7) return 1;
    int orientations[8] = {1, 3, 8, 6, 2, 4, 5, 7};
    return orientations[uiorientation];
}

UIImageOrientation ImageOrientationFromEXIFOrientation(uint exiforientation)
{
    if ((exiforientation < 1) || (exiforientation > 8)) return UIImageOrientationUp;    
    int orientations[8] = {0, 4, 1, 5, 6, 3, 7, 2};
    return orientations[exiforientation];
}

NSString *DeviceOrientationName(UIDeviceOrientation orientation)
{
    NSArray *names = [NSArray 
                      arrayWithObjects:
                      @"Unknown",
                      @"Portrait",
                      @"Portrait Upside Down",
                      @"Landscape Left",
                      @"Landscape Right",
                      @"Face Up",
                      @"Face Down",
                      nil];
    return [names objectAtIndex:orientation];
}

NSString *CurrentDeviceOrientationName()
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return DeviceOrientationName(orientation);
}

NSString *ImageOrientationNameFromOrientation(UIImageOrientation orientation)
{
    NSArray *names = [NSArray 
                      arrayWithObjects:
                      @"Up",
                      @"Down",
                      @"Left",
                      @"Right",
                      @"Up-Mirrored",
                      @"Down-Mirrored",
                      @"Left-Mirrored",
                      @"Right-Mirrored",
                      nil];
    return [names objectAtIndex:orientation];
}

NSString *EXIFOrientationNameFromOrientation(uint orientation)
{
    NSArray *names = [NSArray 
                      arrayWithObjects:
                      @"Undefined",
                      @"Top Left",
                      @"Top Right",
                      @"Bottom Right",
                      @"Bottom Left",
                      @"Left Top",
                      @"Left Bottom",
                      @"Right Bottom",
                      @"Right Top",
                      nil];
    return [names objectAtIndex:orientation];
}


NSString *ImageOrientationName(UIImage *anImage)
{
    return ImageOrientationNameFromOrientation(anImage.imageOrientation);
}

BOOL DeviceIsLandscape()
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation);
}

BOOL DeviceIsPortrait()
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsPortrait(orientation);
}

UIImageOrientation CurrentImageOrientationWithMirroring(BOOL isUsingFrontCamera)
{
    switch ([UIDevice currentDevice].orientation) 
    {
        case UIDeviceOrientationPortrait:
            return isUsingFrontCamera ? UIImageOrientationRight : UIImageOrientationLeftMirrored;
        case UIDeviceOrientationPortraitUpsideDown:
            return isUsingFrontCamera ? UIImageOrientationLeft :UIImageOrientationRightMirrored;
        case UIDeviceOrientationLandscapeLeft:
            return isUsingFrontCamera ? UIImageOrientationDown :  UIImageOrientationUpMirrored;
        case UIDeviceOrientationLandscapeRight:
            return isUsingFrontCamera ? UIImageOrientationUp : UIImageOrientationDownMirrored;
        default:
            return  UIImageOrientationUp;
    }
}

// Expected Image orientation from current orientation and camera in use
UIImageOrientation CurrentImageOrientation(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip)
{
    if (shouldMirrorFlip) 
        return CurrentImageOrientationWithMirroring(isUsingFrontCamera);
    
    switch ([UIDevice currentDevice].orientation) 
    {
        case UIDeviceOrientationPortrait:
            return isUsingFrontCamera ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
        case UIDeviceOrientationPortraitUpsideDown:
            return isUsingFrontCamera ? UIImageOrientationRightMirrored :UIImageOrientationLeft;
        case UIDeviceOrientationLandscapeLeft:
            return isUsingFrontCamera ? UIImageOrientationDownMirrored :  UIImageOrientationUp;
        case UIDeviceOrientationLandscapeRight:
            return isUsingFrontCamera ? UIImageOrientationUpMirrored :UIImageOrientationDown;
        default:
            return  UIImageOrientationUp;
    }
}

uint CurrentEXIFOrientation(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip)
{
    return EXIFOrientationFromUIOrientation(CurrentImageOrientation(isUsingFrontCamera, shouldMirrorFlip));
}

// Does not take camera into account for both portrait orientations
// This is likely due to an ongoing bug
uint DetectorEXIF(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip)
{
    if (isUsingFrontCamera || DeviceIsLandscape())
        return CurrentEXIFOrientation(isUsingFrontCamera, shouldMirrorFlip);
    
    // Only back camera portrait  or upside down here. This bugs me a lot.
    // Detection happens but the geometry is messed.
    int orientation = CurrentEXIFOrientation(!isUsingFrontCamera, shouldMirrorFlip);
    return orientation;
}
