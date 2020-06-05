//
//  ContactViewEntity.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/4/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactViewEntity.h"

@implementation ContactViewEntity

- (id)initWithIdentifier:(NSString *)identifier name:(NSString *)name description:(NSString *)description {
    return [self initWithIdentifier:identifier name:name description:description avatar:nil isChecked:NO];
}

- (id)initWithIdentifier:(NSString *)identifier name:(NSString *)name description:(NSString *)description avatar:(UIImage * _Nullable)image {
    return [self initWithIdentifier:identifier name:name description:description avatar:image isChecked:NO];
    
}

- (id)initWithIdentifier:(NSString *)identifier name:(NSString *)name description:(NSString *)description avatar:(UIImage * _Nullable)image isChecked:(BOOL)isChecked {
    self.identifier = identifier;
    self.name = name;
    self.contactDescription = description;
    self.avatar = image;
    self.isChecked = isChecked;
    return self;
}

@end
