/*
 
 Erica Sadun, http://ericasadun.com
 
 Convert CG points, sizes, and rects based on EXIF orientation
 
 */

#import <Foundation/Foundation.h>
#import "ImageOrientation.h"

CGPoint PointInEXIF(ExifOrientation exifOrientation, CGPoint aPoint, CGRect rect);
CGSize SizeInEXIF(ExifOrientation exifOrientation, CGSize aSize);
CGRect RectInEXIF(ExifOrientation exifOrientation, CGRect inner, CGRect outer);