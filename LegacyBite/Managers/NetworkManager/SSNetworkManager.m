//
//  SSNetworkManager.m
//  LegacyBite
//
//  Created by Grizly on 13.07.26.
//

#import "SSNetworkManager.h"
#import "SSProductObject.h"

@interface SSNetworkManager()

@property (strong, nonatomic) NSCache <NSURL *, UIImage *> * imageCache;

@end


@implementation SSNetworkManager

+ (instancetype)shared {
    static SSNetworkManager *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[SSNetworkManager alloc] init];
        instance.imageCache = [[NSCache alloc] init];
        instance.imageCache.countLimit = 100;
    });
    
    return instance;
}

-(void)handleError:(NSString *)errorStr completion:(responseBlock)completion{
    NSString * errStr = @"Something went wrong";
    if (errorStr && errorStr.length > 0){
        errStr = errorStr;
    }
    
    NSError * error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:-1 userInfo:@{NSLocalizedDescriptionKey:errStr}];
    if(completion){
        completion(nil, error);
    }
}

- (SSProductObject *)serializeProduct:(NSDictionary *)product
{
    if (![product isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    SSProductObject *productObject = [[SSProductObject alloc] init];
    
    if ([product[@"code"] isKindOfClass:[NSString class]]) {
        productObject.code = product[@"code"];
    }
    
    if ([product[@"product_name"] isKindOfClass:[NSString class]]) {
        productObject.name = product[@"product_name"];
    }
    
    if ([product[@"brands"] isKindOfClass:[NSString class]]) {
        productObject.brand = product[@"brands"];
    }
    
    if ([product[@"quantity"] isKindOfClass:[NSString class]]) {
        productObject.quantity = product[@"quantity"];
    }
    
    if ([product[@"image_front_url"] isKindOfClass:[NSString class]]) {
        productObject.imageURL = [NSURL URLWithString:product[@"image_front_url"]];
    }
    
    if ([product[@"nutrition_grades"] isKindOfClass:[NSString class]]) {
        productObject.nutriScore = [product[@"nutrition_grades"] uppercaseString];
    }
    
    NSDictionary *nutriments = product[@"nutriments"];
    if ([nutriments isKindOfClass:[NSDictionary class]]) {
        
        if ([nutriments[@"energy-kcal_100g"] isKindOfClass:[NSNumber class]]) {
            productObject.energyKcal = nutriments[@"energy-kcal_100g"];
        }
        
        if ([nutriments[@"proteins_100g"] isKindOfClass:[NSNumber class]]) {
            productObject.proteins = nutriments[@"proteins_100g"];
        }
        
        if ([nutriments[@"fat_100g"] isKindOfClass:[NSNumber class]]) {
            productObject.fat = nutriments[@"fat_100g"];
        }
        
        if ([nutriments[@"carbohydrates_100g"] isKindOfClass:[NSNumber class]]) {
            productObject.carbohydrates = nutriments[@"carbohydrates_100g"];
        }
    }
    
    return productObject;
}

-(void)getProductInfoWith:(NSString *)barCode withResponse:(responseBlock)completion{
    if (!barCode || [barCode length] == 0){
        [self handleError:@"Bar code is empty" completion:completion];
        return;
    }
    NSString *urlString = [NSString stringWithFormat: @"https://world.openfoodfacts.org/api/v3/product/%@", barCode];
    
    
    NSURLComponents * components = [NSURLComponents componentsWithString:urlString];
    components.queryItems = @[[NSURLQueryItem queryItemWithName:@"fields" value:@"code,product_name,brands,quantity,image_front_url,nutrition_grades,nutriments"]];
    
    NSURL *url = components.URL;
    
    if (!url) {
        [self handleError:@"Couldn't create URL" completion:completion];
        return;
    }
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 20.0;
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error){
            if (completion){
                completion(nil, error);
            }
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            [self handleError:@"Invalid server response" completion:completion];
            return;
        }

        if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            [self handleError:[NSString stringWithFormat:@"HTTP error: %ld", (long)httpResponse.statusCode] completion:completion];
            return;
        }
        
        
        if ([data length] != 0){
            
            NSError * jsonError = nil;
            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError || ![json isKindOfClass:[NSDictionary class]]){
                [self handleError:@"Invalid JSON data" completion:completion];
                return;
            }
            
            NSDictionary *product = json[@"product"];
            
            if (![product isKindOfClass:[NSDictionary class]]){
                [self handleError:@"Product was not found" completion:completion];
                return;
            }
            
            SSProductObject * productObj = [self serializeProduct:product];
            if (productObj){
                if (completion){
                    completion(productObj, nil);
                }
                return;
            } else {
                [self handleError:@"Serialization to SSProductObject error" completion:completion];
                return;
            }
            
            
        } else {
            [self handleError:@"Server returned empty data" completion:completion];
            return;
        }
        
        
    }];
    [task resume];
    
}

- (NSURLSessionDataTask *)loadImageWithURL:(NSURL *)url
                                completion:(imageBlock)completion {

    if(!url){
        NSError * urlError = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Image URL is nil"}];
        [self callImageCompletion:completion image:nil error:urlError];
        return nil;
    }
    UIImage * cachedImage = [self.imageCache objectForKey:url];
    if (cachedImage){
        [self callImageCompletion:completion image:cachedImage error:nil];
        return nil;
    }
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error) {
            [self callImageCompletion:completion image:nil error:error];
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]] || httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {

            NSError *statusError = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:httpResponse.statusCode userInfo:@{ NSLocalizedDescriptionKey: @"Image request returned an invalid HTTP status."}];

            [self callImageCompletion:completion image:nil error:statusError];
            return;
        }

        if (data.length == 0) {
            NSError *emptyDataError = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Image response contains no data."}];

            [self callImageCompletion:completion image:nil error:emptyDataError];
            return;
        }

        UIImage *image = [UIImage imageWithData:data];

        if (!image) {
            NSError *decodingError = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unable to decode image data."}];

            [self callImageCompletion:completion image:nil error:decodingError];
            return;
        }
        [self.imageCache setObject:image forKey:url];
        [self callImageCompletion:completion image:image error:nil];
        
    }];

    [task resume];

    return task;
}

- (void)callImageCompletion:(imageBlock)completion image:(UIImage *)image error:(NSError *)error {

    if (!completion) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        completion(image, error);
    });
}



@end
