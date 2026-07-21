//
//  AboutDetailsViewController.h
//  LegacyBite
//
//  Created by Grizly on 20.07.26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AboutDetailsTypeProject,
    AboutDetailsTypeApi
} AboutDetailsType;

@interface AboutDetailsViewController : UIViewController

@property (assign ,nonatomic) AboutDetailsType type;

@end

NS_ASSUME_NONNULL_END
