/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "CameraHelper.h"
#import "ImageOrientation.h"
#import "EXIFGeometry.h"
#import "UIImage+CoreImage.h"

// Camera Helper - General Camera Information

@implementation CameraHelper
#pragma mark - Instance

- (instancetype) init
{
    if (!(self = [super init])) return self;
    _session = [[AVCaptureSession alloc] init];
    return self;
}

+ (instancetype) newSession
{
    return [[self alloc] init];
}

#pragma mark - Info

+ (int) numberOfCameras
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}

+ (BOOL) backCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionBack) return YES;
    return NO;
}

+ (BOOL) frontCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionFront) return YES;
    return NO;
}

+ (AVCaptureDevice *)backCamera
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionBack) return device;
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

+ (AVCaptureDevice *)frontCamera
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionFront) return device;
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

+ (BOOL) supportsTorchMode
{
    if (![self backCameraAvailable]) return NO;
    
    AVCaptureDevice *backCamera = [self backCamera];
    if (!backCamera.hasTorch) return NO;
    
    return [backCamera isTorchModeSupported:AVCaptureTorchModeOn];
}

+ (BOOL) isTorchModeOn
{
    if (![self supportsTorchMode]) return NO;
    
    AVCaptureDevice *backCamera = [self backCamera];
    return (backCamera.torchMode == AVCaptureTorchModeOn);
}

+ (void) toggleTorchMode
{
    if (![self supportsTorchMode]) return;
    
    AVCaptureDevice *backCamera = [self backCamera];
    NSError *error;
    if ([backCamera lockForConfiguration:&error])
    {
        backCamera.torchMode = [self isTorchModeOn] ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
        [backCamera unlockForConfiguration];
    }
    else
        NSLog(@"Could not configure back camera: %@", error.localizedDescription);

}

#pragma mark - Capture Inputs

- (void) useDevice: (AVCaptureDevice *) newDevice
{
    [_session beginConfiguration];
    
    // Remove existing inputs
    NSArray *inputs = _session.inputs;
    for (AVCaptureInput *input in inputs)
        [_session removeInput:input];
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
    [_session addInput:captureInput];
    
    [_session commitConfiguration];
}

- (void) useFrontCamera
{
    [self useDevice:[CameraHelper frontCamera]];
}

- (void) useBackCamera
{
    [self useDevice:[CameraHelper backCamera]];
}

- (BOOL) isUsingFrontCamera
{
    NSArray *inputs = _session.inputs;
    if (!inputs.count) return NO;
    
    for (AVCaptureDeviceInput *input in inputs)
    {
        if ([input.device.uniqueID isEqual:[CameraHelper frontCamera].uniqueID])
            return YES;
    }
    return NO;
}

- (BOOL) isUsingBackCamera
{
    NSArray *inputs = _session.inputs;
    if (!inputs.count) return NO;
    
    for (AVCaptureDeviceInput *input in inputs)
    {
        if ([input.device.uniqueID isEqual:[CameraHelper backCamera].uniqueID])
            return YES;
    }
    return NO;
    
}

- (void) switchCameras
{
    // Only switch if more than one camera available
    if (![CameraHelper numberOfCameras] > 1) return;
    
    // Only switch if a camera is in use
    if (!_session.inputs.count) return;
    
    // Perform switch
    AVCaptureDevice *newDevice = [self isUsingFrontCamera] ? [CameraHelper backCamera] : [CameraHelper frontCamera];
    [self useDevice:newDevice];
}

#pragma mark - Previews

- (void) embedPreviewInView: (UIView *) aView
{
    if (!_session) return;
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession: _session];
    preview.frame = aView.bounds;
    // preview.videoGravity = AVLayerVideoGravityResizeAspect; // hmmm.
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [aView.layer addSublayer: preview];
}

- (UIView *) previewWithFrame: (CGRect) aFrame
{
    if (!_session) return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:aFrame];
    [self embedPreviewInView:view];
    
    return view;
}

+ (AVCaptureVideoPreviewLayer *) previewInView: (UIView *) view
{
    for (CALayer *layer in view.layer.sublayers)
        if ([layer isKindOfClass:[AVCaptureVideoPreviewLayer class]])
            return (AVCaptureVideoPreviewLayer *)layer;
    
    return nil;
}

- (void) layoutPreviewInView: (UIView *) aView
{
    AVCaptureVideoPreviewLayer *layer = [CameraHelper previewInView:aView];
    if (!layer) return;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CATransform3D transform = CATransform3DIdentity;
    if (orientation == UIDeviceOrientationPortrait) ;
    else if (orientation == UIDeviceOrientationLandscapeLeft)
        transform = CATransform3DMakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
    else if (orientation == UIDeviceOrientationLandscapeRight)
        transform = CATransform3DMakeRotation(M_PI_2, 0.0f, 0.0f, 1.0f);
    else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    
    layer.transform = transform;
    layer.frame = aView.bounds;
}

#pragma mark - Output Cleanup

- (void) setVideoOutputScale: (CGFloat) scaleFactor
{
    [_session beginConfiguration];
    
    NSArray *outputs = _session.outputs;
    for (AVCaptureOutput *output in outputs)
        for (AVCaptureConnection *connection in output.connections)
            connection.videoScaleAndCropFactor = scaleFactor;
    
    [_session commitConfiguration];

}

- (void) removeOutputs
{
    [_session beginConfiguration];
    
    // Remove existing outputs
    NSArray *outputs = _session.outputs;
    for (AVCaptureOutput *output in outputs)
        [_session removeOutput:output];
    
    [_session commitConfiguration];
}

#pragma mark - Image Grabbing

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool
    {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        _ciImage = [[CIImage alloc] initWithCVPixelBuffer:imageBuffer options:(__bridge_transfer NSDictionary *)attachments];
    }
}

- (void) addImageGrabbingOutput
{
    [_session beginConfiguration];
    
    // Remove existing outputs
    NSArray *outputs = _session.outputs;
    for (AVCaptureOutput *output in outputs)
        [_session removeOutput:output];
    
    // Create capture output
    // Update thanks to Jake Marsh who points out not to use the main queue
    char *queueName = "com.sadun.tasks.grabFrames";
    dispatch_queue_t queue = dispatch_queue_create(queueName, NULL);
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    [captureOutput setSampleBufferDelegate:self queue:queue];
    [captureOutput setVideoSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
    
    [_session addOutput:captureOutput];
    [_session commitConfiguration];
}

- (UIImage *) currentImage
{
    UIImageOrientation orientation = CurrentImageOrientation([self isUsingFrontCamera], NO);
    CIImage *ciimage = self.ciImage;
    UIImage *uiimage = [UIImage imageWithCIImage:ciimage orientation:orientation];
    return uiimage;
}

#pragma mark - Metadata
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // NSLog(@"%@", [(AVCaptureMetadataOutput *) captureOutput availableMetadataObjectTypes]);

    // These are arbitrary. Pick and choose whichever types you like
    NSArray *codeTypes = @[AVMetadataObjectTypeUPCECode,
                           AVMetadataObjectTypeCode39Code,
                           AVMetadataObjectTypeCode39Mod43Code,
                           AVMetadataObjectTypeEAN13Code,
                           AVMetadataObjectTypeEAN8Code,
                           AVMetadataObjectTypeCode93Code,
                           AVMetadataObjectTypeCode128Code,
                           AVMetadataObjectTypePDF417Code,
                           AVMetadataObjectTypeQRCode,
                           AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([codeTypes containsObject:metadata.type])
        {
            // Match
            NSString *stringValue = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            [_barcodeDelegate processBarcode:stringValue withType:metadata.type withMetadata:metadata];
        }
        else
            NSLog(@"Captured unknown metadata object: %@", metadata.type);

    }
}

- (void) addMetaDataOutput
{
    [_session beginConfiguration];
    
    // Remove existing outputs
    NSArray *outputs = _session.outputs;
    for (AVCaptureOutput *output in outputs)
        [_session removeOutput:output];
    
    // Create capture output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    [_session addOutput:output];
    output.metadataObjectTypes = output.availableMetadataObjectTypes;
    [_session commitConfiguration];
}

#pragma mark - Start/Stop

- (void) startSession
{
    if (_session.running) return;
    [_session startRunning];
}

- (void) stopSession
{
    [_session stopRunning];
}
@end