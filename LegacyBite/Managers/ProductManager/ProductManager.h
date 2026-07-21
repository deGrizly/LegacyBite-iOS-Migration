//
//  ProductManager.h
//  LegacyBite
//
//  Created by Grizly on 17.07.26.
//

#import <Foundation/Foundation.h>

#import "SSProductObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^responseBlock)(id _Nullable product, NSError * _Nullable error);

@interface ProductManager : NSObject

+ (instancetype)shared;

-(void)getProductForBarCode:(NSString *)barCode with:(responseBlock)response;

-(NSArray <SSProductObject *> *)historyListOfProducts;

@end

NS_ASSUME_NONNULL_END
