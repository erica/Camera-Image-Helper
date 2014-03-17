/*
 
 Erica Sadun, http://ericasadun.com
  
 */

#import "UIImage+CoreImage.h"

@implementation UIImage (CoreImageUtility)
- (CIImage *) coreImageRepresentation
{
    if (self.CIImage)
        return self.CIImage;
    return [CIImage imageWithCGImage:self.CGImage];
}

+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation
{
    if (!aCIImage) return nil;
    
    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:aCIImage fromRect:aCIImage.extent];
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:anOrientation];
    CFRelease(imageRef);
    
    return image;
}
@end
