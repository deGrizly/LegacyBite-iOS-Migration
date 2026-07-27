//
//  SSProductObject.h
//  LegacyBite
//
//  Created by Grizly on 14.07.26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSProductObject : NSObject

@property (strong, nonatomic, nullable) NSString *code;
@property (strong, nonatomic, nullable) NSString *name;
@property (strong, nonatomic, nullable) NSString *brand;
@property (strong, nonatomic, nullable) NSString *quantity;
@property (strong, nonatomic, nullable) NSURL *imageURL;
@property (strong, nonatomic, nullable) NSString *nutriScore;
@property (strong, nonatomic, nullable) NSNumber *energyKcal;
@property (strong, nonatomic, nullable) NSNumber *proteins;
@property (strong, nonatomic, nullable) NSNumber *fat;
@property (strong, nonatomic, nullable) NSNumber *carbohydrates;

@property (strong, nonatomic, nullable) NSDate *savedDate;

@end



NS_ASSUME_NONNULL_END
