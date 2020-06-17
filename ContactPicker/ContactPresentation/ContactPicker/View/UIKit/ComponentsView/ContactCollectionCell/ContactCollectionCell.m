//
//  ContactCollectionCell.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactCollectionCell.h"
#import "ContactViewEntity.h"

@interface ContactCollectionCell() {
    ContactViewEntity * _currentContact;
}
@end

@implementation ContactCollectionCell

@synthesize delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)closeAction:(id)sender {
    [self.delegate removeCell:self->_currentContact];
}

- (void)configWithEntity:(ContactViewEntity *)entity {
    self->_currentContact = entity;
    
    NSString * firstString = entity.givenName.length > 0 ? [entity.givenName substringToIndex:1] : @"";
    NSString * secondString = entity.familyName.length > 0 ? [entity.familyName substringToIndex:1] : @"";
    NSString * keyName = [NSString stringWithFormat:@"%@%@", firstString, secondString];
    
    if (entity.avatar) {
        [self.avatar configImage:entity.avatar forLabel:@"" withColor:entity.backgroundColor];
    } else {
        [self.avatar configImage:nil forLabel:keyName withColor:entity.backgroundColor];
        __weak ContactCollectionCell* weakSelf = self;
        entity.waitImageToExcuteQueue = ^(UIImage* image, NSString* identifier){
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (identifier == entity.identifier) {
                    weakSelf.avatar.imageView.image = image;
                }
            });
        };
    }
}

@end
