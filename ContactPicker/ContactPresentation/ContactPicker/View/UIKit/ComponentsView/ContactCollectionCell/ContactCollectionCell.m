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
    [_avatar configWithContact:entity];
}

@end
