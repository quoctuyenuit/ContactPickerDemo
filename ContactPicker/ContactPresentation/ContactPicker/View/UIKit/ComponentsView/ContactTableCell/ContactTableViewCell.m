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
    [self.avatar configWithContact:entity];
}

- (void)setSelect {
    self.checkBox.isChecked = !self.checkBox.isChecked;
}

- (NSString *)reuseIdentifier {
    return @"ContactViewCell";
}
@end
