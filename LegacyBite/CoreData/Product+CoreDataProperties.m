//
//  Product+CoreDataProperties.m
//  LegacyBite
//
//  Created by Grizly on 19.07.26.
//
//

#import "Product+CoreDataProperties.h"

@implementation Product (CoreDataProperties)

+ (NSFetchRequest<Product *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Product"];
}

@dynamic code;
@dynamic name;
@dynamic brand;
@dynamic quantity;
@dynamic fat;
@dynamic proteins;
@dynamic energyKcal;
@dynamic nutriScore;
@dynamic imageURL;
@dynamic createdAt;
@dynamic carbohydrates;

@end
