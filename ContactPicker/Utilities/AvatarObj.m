//
//  AvatarObj.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "AvatarObj.h"

@implementation AvatarObj
- (instancetype)initWithImage:(UIImage *)image label:(NSString *)label isGenerated:(BOOL)isGenerated identififer:(nonnull NSString *)identifier {
    _image          = image;
    _label          = label;
    _isGenerated    = isGenerated;
    _identifier     = identifier;
    return self;
}
@end
