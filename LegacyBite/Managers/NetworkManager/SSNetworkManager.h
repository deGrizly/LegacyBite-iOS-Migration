//
//  SSNetworkManager.h
//  LegacyBite
//
//  Created by Grizly on 13.07.26.
//


#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef void (^responseBlock)(id _Nullable responseObject, NSError * _Nullable error);
typedef void (^imageBlock)(UIImage * _Nullable image, NSError * _Nullable error);
@interface SSNetworkManager : NSObject

+ (instancetype)shared;

-(void)getProductInfoWith:(NSString *)barCode withResponse:(responseBlock)completion;
-(NSURLSessionDataTask *)loadImageWithURL:(NSURL *)url completion:(imageBlock)completion;
@end

NS_ASSUME_NONNULL_END
