//
//  ContactTableCellComponent.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_COMPONENTKIT
#import "ContactTableCellComponent.h"
#import "Utilities.h"
#import "ContactAvatarView.h"
#import "ContactTableViewCell.h"
#import <ComponentKit/CKComponentSubclass.h>

#define DEBUG_MODE              0

#define SPACE_BETWEEN_ELEMENT   0
#define TOP_PADDING             8
#define BOTTOM_PADDING          8
#define LEFT_PADDING            16
#define RIGHT_PADDING           8
#define InsetForAvatar          UIEdgeInsetsMake(TOP_PADDING, LEFT_PADDING, BOTTOM_PADDING, 0)
#define InsetForCheckBox        UIEdgeInsetsMake(0, LEFT_PADDING, 0, 0)
#define InsetForText            UIEdgeInsetsMake(0, LEFT_PADDING, 0, 0)
#define CHECK_BOX_HEIGHT        25
#define CONTACT_NAME_FONT [UIFont systemFontOfSize: CONTACT_FONT_SIZE]
#define CHECK_IMAGE_NAME    @"checked_img"
#define UNCHECK_IMAGE_NAME  @"unchecked_img"

@implementation ContactTableCellComponent {
    ContactViewEntity   * _contact;
//    CKComponent         * _overlay;
}

+ (instancetype)newWithContact:(ContactViewEntity *) contact {
    CKComponentScope scope(self, contact.identifier);
    const BOOL _state = contact.isChecked;
    
    ContactTableCellComponent * c = [super newWithComponent:[CKComponent newWithView:{[ContactTableViewCell class], {
        {@selector(setUserInteractionEnabled:), @NO},
        {@selector(updateCellWithContact:), contact},
        {@selector(configCheckBox:), _state},
    }} size:{.height = TABLE_CELL_HEIGHT}]];
    
    if (c) {
        c->_contact = contact;
        [c->_contact.isCheckObservable bindOne:^(NSNumber * isChecked) {
            [c updateState:^(NSNumber *oldState) {
                return isChecked;
            } mode:CKUpdateModeSynchronous];
        }];
    }
    
    return c;
}

- (void)updateCellWithContact:(ContactViewEntity *)entity {
}

- (void)setSelect {
    
}

+ (id)initialState {
    return @NO;
}

@end
#endif
