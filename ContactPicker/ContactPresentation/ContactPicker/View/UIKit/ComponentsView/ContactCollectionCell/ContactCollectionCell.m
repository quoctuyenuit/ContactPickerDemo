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
        [_avatar configWithImage:entity.avatar withTitle:@"" withBackground:nil];
    } else {
        [_avatar configWithImage:nil withTitle:keyName withBackground:entity.backgroundColor];
    }
    
    __weak typeof(self) weakSelf = self;
    entity.waitImageSelectedToExcuteQueue = ^(UIImage* image, NSString* identifier){
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && identifier == entity.identifier) {
                [strongSelf->_avatar configWithImage:image withTitle:@"" withBackground:nil];
            }
        });
    };
}

@end
