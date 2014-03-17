/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import Foundation;
@import UIKit;

@interface UIImage (CoreImageUtility)
+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation;
@property (nonatomic, readonly) CIImage *coreImageRepresentation;
@end
