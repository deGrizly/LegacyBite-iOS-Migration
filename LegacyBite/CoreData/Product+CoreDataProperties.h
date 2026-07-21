//
//  Product+CoreDataProperties.h
//  LegacyBite
//
//  Created by Grizly on 19.07.26.
//
//

#import "Product+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Product (CoreDataProperties)

+ (NSFetchRequest<Product *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *code;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *brand;
@property (nullable, nonatomic, copy) NSString *quantity;
@property (nonatomic) double fat;
@property (nonatomic) double proteins;
@property (nonatomic) double energyKcal;
@property (nullable, nonatomic, copy) NSString *nutriScore;
@property (nullable, nonatomic, copy) NSString *imageURL;
@property (nullable, nonatomic, copy) NSDate *createdAt;
@property (nonatomic) double carbohydrates;

@end

NS_ASSUME_NONNULL_END
