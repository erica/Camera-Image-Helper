/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import Foundation;
@import UIKit;
@import AVFoundation;
@import CoreImage;
@import CoreVideo;
@import CoreMedia;
@import QuartzCore;

enum {
	kCameraNone = -1,
    kCameraBack,
	kCameraFront,
} availableCameras;

typedef enum {
    kAspect = 0, // AVLayerVideoGravityResizeAspect
    kResize,     // AVLayerVideoGravityResize
    kFill        // AVLayerVideoGravityResizeAspectFill
} previewAspect;

@protocol CameraHelperBarcodeDelegate <NSObject>
- (void) processBarcode: (NSString *) barcode withType: (NSString *) codeType withMetadata: (AVMetadataObject *) metadata;
@end

// General Camera Assistance
@interface CameraHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, readonly) AVCaptureSession *session;
+ (instancetype) newSession;
- (void) startSession;
- (void) stopSession;

+ (int) numberOfCameras;
+ (BOOL) backCameraAvailable;
+ (BOOL) frontCameraAvailable;

// Get the names of these by sending .localizedName, e.g.
// [CameraHelper frontCamera].localizedName
+ (AVCaptureDevice *)backCamera;
+ (AVCaptureDevice *)frontCamera;

- (BOOL) isUsingFrontCamera;
- (BOOL) isUsingBackCamera;
- (void) useFrontCamera;
- (void) useBackCamera;
- (void) switchCameras;

+ (BOOL) supportsTorchMode;
+ (BOOL) isTorchModeOn;
+ (void) toggleTorchMode;

+ (AVCaptureVideoPreviewLayer *) previewInView: (UIView *) view;
- (void) embedPreviewInView: (UIView *) aView;
- (UIView *) previewWithFrame: (CGRect) aFrame;
- (void) layoutPreviewInView: (UIView *) aView;

- (void) removeOutputs;

@property (nonatomic, readonly) CIImage *ciImage;
@property (nonatomic, readonly) UIImage *currentImage;
- (void) addImageGrabbingOutput;

@property (nonatomic) id <CameraHelperBarcodeDelegate> barcodeDelegate;
- (void) addMetaDataOutput;


@end
