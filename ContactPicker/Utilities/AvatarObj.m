//
//  AvatarObj.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "AvatarObj.h"

@implementation AvatarObj
- (instancetype)initWithImage:(UIImage *)image isGenerated:(BOOL)isGenerated {
    _image          = image;
    _isGenerated    = isGenerated;
    _isLoaded       = NO;
    return self;
}
@end
