//
//  ContactTableViewCell.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/4/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableViewCell.h"

@interface ContactTableViewCell()
- (void) setupView;
- (void) updateView;
@end

@implementation ContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self updateView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self updateView];
}

- (void)setupView {
    self.avatar.layer.borderWidth = 1;
    self.avatar.layer.borderColor = UIColor.grayColor.CGColor;
}

- (void)updateView {
    self.avatar.layer.cornerRadius = self.avatar.bounds.size.width / 2;
}

- (void)configForModel:(ContactViewModel *)entity {
    self.firstLabel.text = entity.name;
    self.secondLabel.text = entity.contactDescription;
    self.checkBox.checked = entity.isChecked;
    self.avatar.image = nil;
    if (entity.avatar) {
        self.avatar.image = entity.avatar;
    } else {
        __weak ContactTableViewCell* weakSelf = self;
        entity.waitImageToExcuteQueue = ^(UIImage* image, NSString* identifier){
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (identifier == entity.identifier) {
                    weakSelf.avatar.image = image;
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
