//
//  APIAdapter.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ImageGeneratorAPIAdapter.h"
#define GENERATE_IMAGE_API @"https://dummyimage.com/600x600/dbc418/fff&text="

@interface ImageGeneratorAPIAdapter()

@end

@implementation ImageGeneratorAPIAdapter
- (void)getRequestFrom:(NSString *)url completion:(void (^)(NSData *, BOOL))completion {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
        
        if (error == nil) {
            completion(data, YES);
        } else {
            completion(nil, NO);
            NSLog(@"[Error in get request] %@", error);
        }
        
    }] resume];
}

- (void)generateImageFromName:(NSString *)name completion:(void (^)(NSData *, BOOL))handle {
    NSString *targetUrl = [NSString stringWithFormat:@"%@%@", GENERATE_IMAGE_API, name];
    [self getRequestFrom:targetUrl completion:^(NSData * imageData, BOOL isSucess) {
        handle(imageData, isSucess);
    }];
}
@end
