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
