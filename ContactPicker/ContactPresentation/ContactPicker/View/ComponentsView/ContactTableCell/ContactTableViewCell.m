//
//  ContactTableViewCell.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/4/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "ContactAvatarImageView.h"

@interface ContactTableViewCell() {
    ContactViewEntity * currentContact;
}
@end

@implementation ContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.checkBox.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configForModel:(ContactViewEntity *)entity {
    self->currentContact = entity;
    
    self.firstLabel.text = entity.name;
    self.secondLabel.text = entity.contactDescription;
    self.checkBox.checked = entity.isChecked;
    NSString* keyName = entity.name.length >= 2 ? [entity.name substringToIndex:2] : [entity.name substringToIndex:1];
    
    self.avatar.imageView.image = nil;
    if (entity.avatar) {
        [self.avatar configImage:entity.avatar forLabel:@""];
    } else {
        [self.avatar configImage:nil forLabel:keyName];
        __weak ContactTableViewCell* weakSelf = self;
        entity.waitImageToExcuteQueue = ^(UIImage* image, NSString* identifier){
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (identifier == entity.identifier) {
                    weakSelf.avatar.imageView.image = image;
                }
            });
        };
    }
}

- (void)setSelect {
    self.checkBox.checked = !self.checkBox.checked;
}

- (NSString *)reuseIdentifier {
    return @"ContactViewCell";
}

- (void)check:(BOOL)isChecked {
    [self.delegate didSelectContact:self->currentContact];
}
@end
