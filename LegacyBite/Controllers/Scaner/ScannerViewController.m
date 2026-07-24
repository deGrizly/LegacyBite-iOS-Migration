//
//  ScannerViewController.m
//  LegacyBite
//
//  Created by Grizly on 15.07.26.
//

#import "ScannerViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "CameraViewController.h"
#import "ProductManager.h"
#import "ProductCardViewController.h"
#import "LegacyBite-Swift.h"

@interface ScannerViewController () <CameraViewControllerDelegate>

@property (strong, nonatomic) ScannerViewModel * viewModel;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewModel];
}

-(void)initViewModel{
    self.viewModel = [[ScannerViewModel alloc] init];
    __weak typeof(self) weakSelf = self;
    
    self.viewModel.onLoadingChanged = ^(BOOL isLoading){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isLoading) {
                [weakSelf showLoaderWithBlocksInteraction:NO];
            } else {
                [weakSelf hideLoader];
            }
        });
    };
    
    self.viewModel.onProductLoaded = ^(SSProductObject * product){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showProduct:product];
        });
        
    };
    
    self.viewModel.onError = ^(NSError * error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAlertWith:error.localizedDescription];
        });
    };
}

-(IBAction)scanBarcodeAction:(id)sender{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized){
        [self presentCameraViewController];
    } else if (status == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self presentCameraViewController];
                } else {
                    [self showAccessDeniedAlert];
                }
            });
        }];
    } else {
        [self showAccessDeniedAlert];
    }
}

-(void)presentCameraViewController{
    UINavigationController * nc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CameraNavController"];
    CameraViewController * vc = (CameraViewController *)nc.viewControllers.firstObject;
    vc.delegate = self;
    nc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nc animated:false completion:nil];
}

-(void)showAccessDeniedAlert{
    
    NSString * title = @"";
    NSString * message = @"Enable camera access in Settings to scan product barcodes.";
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * toSettingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]){
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

        
    [alert addAction:toSettingsAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

-(void)showAlertWith:(NSString *)alertMessage{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}

-(void)showProduct:(SSProductObject *)product{
    ProductCardViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProductCardViewController"];
    vc.product = product;
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark: CameraViewControllerDelegate
-(void)didScanBarCode:(NSString *)barCode{
    [self.viewModel loadProductWithBarCode:barCode];
}

@end
