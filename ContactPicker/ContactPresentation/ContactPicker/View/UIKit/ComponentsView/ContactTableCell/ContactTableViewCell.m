//
//  ContactTableViewCell.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/4/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableViewCell.h"
//#import "ContactAvatarImageView.h"

@interface ContactTableViewCell() {

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
    self.contactNameLabel.text = entity.fullName;
    self.contactDescriptionLabel.text = entity.contactDescription;
    self.checkBox.isChecked = entity.isChecked;
    
    NSString * firstString = entity.givenName.length > 0 ? [entity.givenName substringToIndex:1] : @"";
    NSString * secondString = entity.familyName.length > 0 ? [entity.familyName substringToIndex:1] : @"";
    NSString * keyName = [NSString stringWithFormat:@"%@%@", firstString, secondString];
    
    if (entity.avatar) {
        [_avatar configWithImage:entity.avatar withTitle:@"" withBackground:nil];
    } else {
        [_avatar configWithImage:nil withTitle:keyName withBackground:entity.backgroundColor];
    }
    
    __weak typeof(self) weakSelf = self;
    entity.waitImageToExcuteQueue = ^(UIImage* image, NSString* identifier){
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && identifier == entity.identifier) {
                [strongSelf->_avatar configWithImage:image withTitle:@"" withBackground:nil];
            }
        });
    };
}

- (void)setSelect {
    self.checkBox.isChecked = !self.checkBox.isChecked;
}

- (NSString *)reuseIdentifier {
    return @"ContactViewCell";
}
@end
