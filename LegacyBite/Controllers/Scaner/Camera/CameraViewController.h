//
//  CameraViewController.h
//  LegacyBite
//
//  Created by Grizly on 16.07.26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraViewControllerDelegate <NSObject>

-(void)didScanBarCode:(NSString *)barCode;

@end

@interface CameraViewController : UIViewController

@property (weak, nonatomic) id <CameraViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
