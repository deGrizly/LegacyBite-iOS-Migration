//
//  SSProductObject.h
//  LegacyBite
//
//  Created by Grizly on 14.07.26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSProductObject : NSObject

@property NSString *code;
@property NSString *name;
@property NSString *brand;
@property NSString *quantity;
@property NSURL *imageURL;
@property NSString *nutriScore;
@property NSNumber *energyKcal;
@property NSNumber *proteins;
@property NSNumber *fat;
@property NSNumber *carbohydrates;

@property NSDate *savedDate;

@end



NS_ASSUME_NONNULL_END
