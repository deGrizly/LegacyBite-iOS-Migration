//
//  CameraViewController.m
//  LegacyBite
//
//  Created by Grizly on 16.07.26.
//

#import "CameraViewController.h"
#import "AVFoundation/AVFoundation.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CameraViewController () <AVCaptureMetadataOutputObjectsDelegate>

{
    BOOL didScanBarcode;
}


@property (weak, nonatomic) IBOutlet UIView * videoAreaView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem * torchItem;
@property (strong, nonatomic) UIButton * torchButton;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;

@property (nonatomic, strong) UIImageView *freezeImageView;
@property (nonatomic, strong) UIView *successOverlayView;


@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCamera];
    didScanBarcode = false;
    
    self.videoAreaView.layer.masksToBounds = true;
    self.videoAreaView.layer.cornerRadius = 20.f;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.videoPreviewLayer.frame = self.videoAreaView.bounds;
    
    //    CGRect metadataRect = [self.videoPreviewLayer metadataOutputRectOfInterestForRect:self.videoAreaView.bounds];
    //    self.captureMetadataOutput.rectOfInterest = metadataRect;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.captureSession stopRunning];
}

- (AVCaptureDevice *)bestBackCameraDevice {
    NSArray<AVCaptureDeviceType> *preferredTypes = @[
        AVCaptureDeviceTypeBuiltInTripleCamera,
        AVCaptureDeviceTypeBuiltInDualWideCamera,
        AVCaptureDeviceTypeBuiltInDualCamera,
        AVCaptureDeviceTypeBuiltInWideAngleCamera,
        AVCaptureDeviceTypeBuiltInUltraWideCamera
    ];
    
    for (AVCaptureDeviceType type in preferredTypes) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithDeviceType:type mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        
        if (device) {
            NSLog(@"Selected camera device type: %@", type);
            return device;
        }
    }
    
    return nil;
}

- (void)setupCamera {
    self.captureSession = [[AVCaptureSession alloc] init];
    
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    self.captureDevice = [self bestBackCameraDevice];
    
    if (!self.captureDevice) {
        NSLog(@"Back camera not available");
        return;
    }
    
    NSError *inputError = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&inputError];
    
    if (!input) {
        NSLog(@"Camera input error: %@", inputError.localizedDescription);
        return;
    }
    
    if ([self.captureSession canAddInput:input]) {
        [self.captureSession addInput:input];
    } else {
        NSLog(@"Cannot add camera input");
        return;
    }
    
    self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    if ([self.captureSession canAddOutput:self.captureMetadataOutput]) {
        [self.captureSession addOutput:self.captureMetadataOutput];
    } else {
        NSLog(@"Cannot add metadata output");
        return;
    }
    
    dispatch_queue_t metadataQueue = dispatch_queue_create("com.legacybite.barcode.metadata", DISPATCH_QUEUE_SERIAL);
    [self.captureMetadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    
    NSArray *requestedTypes = @[
        AVMetadataObjectTypeEAN13Code,
        AVMetadataObjectTypeEAN8Code,
        AVMetadataObjectTypeUPCECode,
        AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypeQRCode
    ];
    
    NSMutableArray *availableTypes = [NSMutableArray array];
    
    for (AVMetadataObjectType type in requestedTypes) {
        if ([self.captureMetadataOutput.availableMetadataObjectTypes containsObject:type]) {
            [availableTypes addObject:type];
        }
    }
    
    self.captureMetadataOutput.metadataObjectTypes = availableTypes;
    
    NSError *lockError = nil;
    
    if ([self.captureDevice lockForConfiguration:&lockError]) {
        
        CGPoint centerPoint = CGPointMake(0.5, 0.5);
        
        if ([self.captureDevice isFocusPointOfInterestSupported]) {
            self.captureDevice.focusPointOfInterest = centerPoint;
        }
        
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            self.captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        if ([self.captureDevice isExposurePointOfInterestSupported]) {
            self.captureDevice.exposurePointOfInterest = centerPoint;
        }
        
        if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            self.captureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        if ([self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            self.captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        }
        
        if ([self.captureDevice isAutoFocusRangeRestrictionSupported]) {
            self.captureDevice.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
        }
        
        CGFloat desiredZoom = 3.0;
        //        CGFloat maxZoom = MIN(self.captureDevice.activeFormat.videoMaxZoomFactor, 4.0);
        //        CGFloat zoom = MIN(desiredZoom, maxZoom);
        
        //        if (zoom > 1.0) {
        //            [self.captureDevice rampToVideoZoomFactor:zoom withRate:4.0];
        //        }
        
        self.captureDevice.videoZoomFactor = desiredZoom;
        NSLog(@"Current zoom: %f", self.captureDevice.videoZoomFactor);
        
        [self.captureDevice unlockForConfiguration];
    } else {
        NSLog(@"Camera configuration lock error: %@", lockError.localizedDescription);
    }
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoPreviewLayer.frame = self.videoAreaView.bounds;
    
    [self.videoAreaView.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
    });
}

- (UIImage *)snapshotOfView:(UIView *)view {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:view.bounds.size];

    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    }];
}

- (void)playScanSuccessEffectWithCompletion:(void (^)(void))completion {
    UIImage * snapShot = [self snapshotOfView:self.videoAreaView];
    
    self.freezeImageView = [[UIImageView alloc] initWithFrame:self.videoAreaView.bounds];
    self.freezeImageView.image = snapShot;
    self.freezeImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.freezeImageView.clipsToBounds = YES;
    self.freezeImageView.layer.cornerRadius = self.videoAreaView.layer.cornerRadius;
    [self.videoAreaView addSubview:self.freezeImageView];
    
    AudioServicesPlaySystemSound(1108);
    UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
    [generator notificationOccurred:UINotificationFeedbackTypeSuccess];
    self.successOverlayView = [[UIView alloc] initWithFrame:self.videoAreaView.bounds];
    self.successOverlayView.backgroundColor = [[UIColor systemGreenColor] colorWithAlphaComponent:0.0];
    self.successOverlayView.layer.cornerRadius = self.videoAreaView.layer.cornerRadius;
    self.successOverlayView.clipsToBounds = YES;
    [self.videoAreaView addSubview:self.successOverlayView];
    
    UIImageView *checkmarkView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]];
    checkmarkView.tintColor = [UIColor whiteColor];
    checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
    checkmarkView.alpha = 0.0;
    checkmarkView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    [self.successOverlayView addSubview:checkmarkView];
    
    [NSLayoutConstraint activateConstraints:@[
        [checkmarkView.centerXAnchor constraintEqualToAnchor:self.successOverlayView.centerXAnchor],
        [checkmarkView.centerYAnchor constraintEqualToAnchor:self.successOverlayView.centerYAnchor],
        [checkmarkView.widthAnchor constraintEqualToConstant:72.0],
        [checkmarkView.heightAnchor constraintEqualToConstant:72.0]
    ]];
    
    [UIView animateWithDuration:0.18 animations:^{
        self.successOverlayView.backgroundColor = [[UIColor systemGreenColor] colorWithAlphaComponent:0.28];
        checkmarkView.alpha = 1.0;
        checkmarkView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (didScanBarcode) {
        return;
    }
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
        NSString *barcodeValue = metadataObj.stringValue;
        if (!barcodeValue || barcodeValue.length == 0) {
            return;
        }

        didScanBarcode = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.captureSession stopRunning];
            
            [self playScanSuccessEffectWithCompletion:^{
                if(self.delegate){
                    [self.delegate didScanBarCode:barcodeValue];
                }
                [self dismissViewControllerAnimated:false completion:nil];
            }];
            
            
        });
        
    }
}


- (void)updateTorchButtonForEnabled:(BOOL)enabled {
    UIImage *image = [UIImage systemImageNamed:(enabled ? @"flashlight.on.fill" : @"flashlight.slash")];
    [self.torchItem setImage:image];

}


#pragma mark - actions
-(IBAction)flashlightAction:(id)sender{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch] && [captureDevice isTorchModeSupported:AVCaptureTorchModeOn]) {
        NSError *error;
        if ([captureDevice lockForConfiguration:&error]) {
            
            if (captureDevice.torchMode == AVCaptureTorchModeOn) {
                captureDevice.torchMode = AVCaptureTorchModeOff;
                [self updateTorchButtonForEnabled:false];
            } else {
                [captureDevice setTorchModeOnWithLevel:AVCaptureMaxAvailableTorchLevel error:&error];
                [self updateTorchButtonForEnabled:true];
            }
            [captureDevice unlockForConfiguration];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    } else {
        NSLog(@"CaptureDevice Torch doesnt support");
    }
}

-(IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:false completion:nil];
}

@end
