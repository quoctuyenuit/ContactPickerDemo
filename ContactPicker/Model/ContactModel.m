//
//  Contact.m
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactModel.h"
#define GENERATE_IMAGE_API @"https://dummyimage.com/600x400/dbc418/fff&text="

@interface ContactModel()
//-(void) getImageFrom: (NSString*) url forName: (NSString*) name completion: (void (^)(UIImage*)) handle;
@end

@implementation ContactModel

//- (void) getImageFrom:(NSString *)url
//              forName: (NSString*) name
//           completion: (void (^)(UIImage*)) handle
//{
//    NSString *targetUrl = [NSString stringWithFormat:@"%@%@", url, name];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setHTTPMethod:@"GET"];
//    [request setURL:[NSURL URLWithString:targetUrl]];
//
//    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
//      ^(NSData * _Nullable data,
//        NSURLResponse * _Nullable response,
//        NSError * _Nullable error) {
//
//        UIImage* image = [UIImage imageWithData:data];
//        handle(image);
//    }] resume];
//}

-(id) initWithName:(NSString *)name
            avatar:(UIImage *)avatar
        activeTime:(float)activeTime {
    _name = name;
    _avatar = avatar;
    _activeTime = activeTime;
    
//    if (!_avatar) {
//        [self getImageFrom: GENERATE_IMAGE_API forName: [name substringToIndex:1] completion:^(UIImage * image) {
//            self->_avatar = image;
//        }];
//    }
    return self;
}

-(NSString*) name {
    return _name;
}

-(void) setName:(NSString *)name {
    _name = name;
}

-(UIImage*) avatar {
    return _avatar;
}

-(void) setAvatar:(UIImage *)avatar {
    _avatar = avatar;
}

-(float) activateTime {
    return _activeTime;
}

-(void) setActivateTime:(float)activateTime {
    _activeTime = activateTime;
}

@end
