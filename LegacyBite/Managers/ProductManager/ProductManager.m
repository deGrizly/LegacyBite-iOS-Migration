//
//  ProductManager.m
//  LegacyBite
//
//  Created by Grizly on 17.07.26.
//

#import "ProductManager.h"
#import "SSNetworkManager.h"
#import "CoreDataManager.h"

@implementation ProductManager

+ (instancetype)shared {
    static ProductManager *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[ProductManager alloc] init];
    });
    
    return instance;
}

-(void)getProductForBarCode:(NSString *)barCode with:(ProductResponseBlock)response{
    
    NSError * coreDataError = nil;
    SSProductObject * obj = [[CoreDataManager shared]getProductBy:barCode error:&coreDataError];
    if (coreDataError) {
        NSLog(@"Core Data fetch error: %@", coreDataError.localizedDescription);
    }
    if(obj){
        if(response){
            response(obj, nil);
        }
        return;
    }
    
    
    [[SSNetworkManager shared]getProductInfoWith:barCode withResponse:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        if([responseObject isKindOfClass:[SSProductObject class]] && !error){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError * saveError;
                BOOL saved = [[CoreDataManager shared] saveProduct:responseObject error:&saveError];
                if (!saved) {
                    NSLog(@"Core Data save error: %@",  saveError.localizedDescription);
                }
            });
        }
        
        if (response){
            response(responseObject, error);
        }
    }];
}

-(NSArray<SSProductObject *> *)historyListOfProducts{
    NSError * error = nil;
    NSArray * list = [[CoreDataManager shared]getAllProducts:&error];
    if([list count]){
        return list;
    } else {
        return @[];
    }
}

@end
