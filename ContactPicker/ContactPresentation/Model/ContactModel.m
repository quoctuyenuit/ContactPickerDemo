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

- (id)initWithIdentifier: (NSString *) identifier name: (NSString *) name {
    self->_name = name;
    self->_identifier = identifier;
    return self;
}

- (NSString*) name {
    return self->_name;
}

- (void) setName:(NSString *) name {
    self->_name = name;
}

- (NSString *) identifier {
    return self->_identifier;
}

- (void) setIdentifier: (NSString *) identifier{
    self->_identifier = identifier;
}
@end
