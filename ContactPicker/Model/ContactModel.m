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

@interface ContactModel()
@end

@implementation ContactModel

- (id)initWithName:(NSString *)name
            avatar:(UIImage *)avatar
        activeTime:(float)activeTime {
    self->_name = name;
    self->_avatar = avatar;
    self->_activeTime = activeTime;
    return self;
}

- (NSString*) name {
    return _name;
}

- (void) setName:(NSString *)name {
    _name = name;
}

- (UIImage*) avatar {
    return _avatar;
}

- (void) setAvatar:(UIImage *)avatar {
    _avatar = avatar;
}

- (float) activateTime {
    return _activeTime;
}

- (void) setActivateTime:(float)activateTime {
    _activeTime = activateTime;
}

@end
