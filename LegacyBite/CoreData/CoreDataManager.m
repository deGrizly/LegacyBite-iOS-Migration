//
//  CoreDataManager.m
//  LegacyBite
//
//  Created by Grizly on 19.07.26.
//

#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "Product+CoreDataProperties.h"
#import "Product+CoreDataClass.h"

@implementation CoreDataManager

+(instancetype)shared{
    static CoreDataManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CoreDataManager alloc] init];
    });
    return manager;
}


-(NSManagedObjectContext *)context{
    AppDelegate * appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    return appDelegate.persistentContainer.viewContext;
}

-(void)manageError:(NSString *)errorStr error:(NSError **)error{
    NSString * errStr = @"Something went wrong";
    if (errorStr && errorStr.length > 0){
        errStr = errorStr;
    }
    if(error){
        * error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:-1 userInfo:@{NSLocalizedDescriptionKey:errStr}];
    }
}

-(Product *)getProductWith:(NSString *)barCode error:(NSError **)error{
    
    if (!barCode || barCode.length == 0) {
        return nil;
    }
    
    NSManagedObjectContext * context = [self context];
    if (!context) {
        return nil;
    }
    NSFetchRequest * request = [Product fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"code==%@",barCode];
    request.fetchLimit = 1;
    
    NSArray<Product *> * result = [context executeFetchRequest:request error:error];
    
    if(result == nil || result.count == 0){
        return nil;
    }
    
    return result.firstObject;
}

- (SSProductObject *)productObjectFromEntity:(Product *)product{
    if(!product){
        return nil;
    }
    SSProductObject * productObj = [[SSProductObject alloc] init];

    productObj.code = product.code;
    productObj.name = product.name;
    productObj.brand = product.brand;
    productObj.quantity = product.quantity;

    if (product.imageURL.length > 0) {
        productObj.imageURL = [NSURL URLWithString:product.imageURL];
    }

    productObj.nutriScore = product.nutriScore;

    productObj.energyKcal = @(product.energyKcal);
    productObj.proteins = @(product.proteins);
    productObj.fat = @(product.fat);
    productObj.carbohydrates = @(product.carbohydrates);

    productObj.savedDate = product.createdAt;

    return productObj;
    
}

#pragma mark - interface

-(BOOL)saveProduct:(SSProductObject *)productObj error:(NSError *__autoreleasing  _Nullable *)error{
    
    if (!productObj) {
        [self manageError:@"Product is nil" error:error];
        return NO;
    }
    NSString * barCode = productObj.code;
    if (barCode.length == 0) {
        [self manageError:@"Barcode is empty" error:error];
        return NO;
    }
    NSError *fetchError = nil;
    Product *existingProduct = [self getProductWith:barCode error:&fetchError];
    if (fetchError) {
        if (error != NULL) {
            *error = fetchError;
        }
        return NO;
    }
    
    if (existingProduct) {
        [self manageError:@"Product already exists" error:error];
        return NO;
    }
    
    NSManagedObjectContext * context = [self context];
    if(!context){
        [self manageError:@"Context is nil" error:error];
        return NO;
    }
    
    Product * entity = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:context];
    
    entity.code = productObj.code;
    entity.name = productObj.name;
    entity.brand = productObj.brand;
    entity.quantity = productObj.quantity;

    entity.imageURL = productObj.imageURL.absoluteString;

    entity.nutriScore = productObj.nutriScore;

    entity.energyKcal = productObj.energyKcal.doubleValue;
    entity.proteins = productObj.proteins.doubleValue;
    entity.fat = productObj.fat.doubleValue;
    entity.carbohydrates = productObj.carbohydrates.doubleValue;

    entity.createdAt = [NSDate date];
    
    return [context save:error];
}

- (SSProductObject *)getProductBy:(NSString *)barCode
                            error:(NSError **)error
{
    if (barCode.length == 0) {
        [self manageError:@"Barcode is empty" error:error];
        return nil;
    }

    Product *product = [self getProductWith:barCode error:error];

    return [self productObjectFromEntity:product];
}

- (NSArray<SSProductObject *> *)getAllProducts:(NSError **)error
{
    NSManagedObjectContext * context = [self context];
    if (!context) {
        [self manageError:@"Context is nil" error:error];
        return nil;
    }

    NSFetchRequest<Product *> * request = [Product fetchRequest];
    request.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"createdAt"
                                      ascending:NO]
    ];

    NSError * fetchError = nil;
    NSArray<Product *> * products =
        [context executeFetchRequest:request error:&fetchError];

    if (fetchError) {
        if (error) {
            * error = fetchError;
        }
        return nil;
    }

    NSMutableArray<SSProductObject *> * result =
        [NSMutableArray arrayWithCapacity:products.count];

    for (Product * product in products) {

        SSProductObject *obj = [self productObjectFromEntity:product];
        if(obj){
            [result addObject:obj];
        }
    }

    return result;
}

@end
