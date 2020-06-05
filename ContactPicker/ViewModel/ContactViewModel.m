//
//  ContactViewModel.m
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactViewModel.h"
#import <UIKit/UIKit.h>

@interface ContactViewModel()

@end

@implementation ContactViewModel

- (id)initWithIdentifier:(NSString *)identifier
                    name:(NSString *)name
             description:(NSString *)description {
    
    return [self initWithIdentifier:identifier name:name description:description avatar:nil isChecked:NO];
}

- (id)initWithIdentifier:(NSString *)identifier
                    name:(NSString *)name
             description:(NSString *)description
                  avatar:(UIImage * _Nullable)image {
    
    return [self initWithIdentifier:identifier name:name description:description avatar:image isChecked:NO];
    
}

- (id)initWithIdentifier:(NSString *)identifier
                    name:(NSString *)name
             description:(NSString *)description
                  avatar:(UIImage * _Nullable)image
               isChecked:(BOOL)isChecked {
    
    self.identifier = identifier;
    self.name = name;
    self.contactDescription = description;
    self.avatar = image;
    self.isChecked = isChecked;
    return self;
}

- (BOOL)contactHasPrefix:(NSString *)key {
    if ([key isEqualToString:@""]) {
        return true;
    }
    return [[self.name lowercaseString] hasPrefix: [key lowercaseString]];
}

- (BOOL)isEqual:(ContactViewModel *)other
{
    if (other == self) {
        return YES;
    } else {
        return ([self.name isEqualToString:other.name] &&
                [self.contactDescription isEqualToString:other.contactDescription]);
    }
}

- (NSUInteger)hash
{
    return [self->_name hash];
}
@end
