//
//  SSNetworkManager.h
//  LegacyBite
//
//  Created by Grizly on 13.07.26.
//


#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


typedef void (^imageBlock)(UIImage * _Nullable image, NSError * _Nullable error);
@interface SSNetworkManager : NSObject

+ (instancetype)shared;

-(NSURLSessionDataTask *)loadImageWithURL:(NSURL *)url completion:(imageBlock)completion;
@end

NS_ASSUME_NONNULL_END
