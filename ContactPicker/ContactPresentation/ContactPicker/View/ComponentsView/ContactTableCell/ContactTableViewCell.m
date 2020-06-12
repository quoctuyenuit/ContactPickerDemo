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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configForModel:(ContactViewEntity *)entity {
    self->currentContact = entity;
    
    self.firstLabel.text = entity.fullName;
    self.secondLabel.text = entity.contactDescription;
    self.checkBox.checked = entity.isChecked;
    NSString * firstString = entity.givenName.length > 0 ? [entity.givenName substringToIndex:1] : @"";
    NSString * secondString = entity.familyName.length > 0 ? [entity.familyName substringToIndex:1] : @"";
    NSString * keyName = [NSString stringWithFormat:@"%@%@", firstString, secondString];
    
    self.avatar.imageView.image = nil;
    if (entity.avatar) {
        [self.avatar configImage:entity.avatar forLabel:@"" withColor:entity.backgroundColor];
    } else {
        [self.avatar configImage:nil forLabel:keyName withColor:entity.backgroundColor];
        __weak ContactTableViewCell* weakSelf = self;
        entity.waitImageToExcuteQueue = ^(UIImage* image, NSString* identifier){
            dispatch_async(dispatch_get_main_queue(), ^{
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
@end
