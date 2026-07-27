//
//  CoreDataManager.h
//  LegacyBite
//
//  Created by Grizly on 19.07.26.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSProductObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataManager : NSObject

+(instancetype)shared;

- (BOOL)saveProduct:(SSProductObject *)product error:(NSError **)error;
- (SSProductObject *)getProductBy:(NSString *)barCode error:(NSError **)error;
- (NSArray<SSProductObject *> *)getAllProducts:(NSError **)error;



@end

NS_ASSUME_NONNULL_END
