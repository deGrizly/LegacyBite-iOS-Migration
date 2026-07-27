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
