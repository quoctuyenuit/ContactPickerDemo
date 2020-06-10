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
    ContactViewEntity * currentContact;
}

@end

@implementation ContactCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)closeAction:(id)sender {
    [self.delegate removeCell:self->currentContact];
}

- (void)config:(ContactViewEntity *)entity {
    self->currentContact = entity;
    NSString* keyName = entity.name.length >= 2 ? [entity.name substringToIndex:2] : [entity.name substringToIndex:1];
    if (entity.avatar) {
        [self.avatar configImage:entity.avatar forLabel:@""];
    } else {
        [self.avatar configImage:nil forLabel:keyName];
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
