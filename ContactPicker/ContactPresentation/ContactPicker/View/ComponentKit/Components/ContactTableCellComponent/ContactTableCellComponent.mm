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
#import "ContactAvatarComponent.h"
#import "ContactAvatarView.h"
#import "CheckBoxComponent.h"
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
    
//    NSLog(@"init component");
    // Text Component
    CKComponent * textComponent     = [CKCenterLayoutComponent newWithCenteringOptions:CKCenterLayoutComponentCenteringY
                                                                     sizingOptions:CKCenterLayoutComponentSizingOptionDefault
                                                                             child: [CKInsetComponent newWithInsets:InsetForText component:
                                                                                     [CKFlexboxComponent newWithView:{[UIView class]}
                                                                                                                size:{}
                                                                                                               style:{ .direction = CKFlexboxDirectionRow, .spacing = 5 }
                                                                                                            children:{
        
        {[CKLabelComponent newWithLabelAttributes:{ .string = contact.fullName, .font = CONTACT_NAME_FONT, .color = UIColor.blackColor }
                                   viewAttributes:{ {@selector(setBackgroundColor:), [UIColor clearColor]}, {@selector(setUserInteractionEnabled:), @NO} }
                                             size:{}]},
        
        {[CKLabelComponent newWithLabelAttributes:{ .string = contact.contactDescription, .font = CONTACT_NAME_FONT, .color = UIColor.blackColor }
                                   viewAttributes:{ {@selector(setBackgroundColor:), [UIColor clearColor]}, {@selector(setUserInteractionEnabled:), @NO} }
                                             size:{}]}
        
    }]] size:{}];
    
    // Avatar Component
    CKComponent * avatarComponent   = [CKInsetComponent newWithInsets:InsetForAvatar
                                                          component:[ContactAvatarComponent newWithContact: contact
                                                                                                      size: CGSizeMake(AVATAR_IMAGE_HEIGHT, AVATAR_IMAGE_HEIGHT)]];
    
    // Checkbox Component
    NSString * imageName = _state ? CHECK_IMAGE_NAME : UNCHECK_IMAGE_NAME;
    CKComponent * checkBoxComponent = [CKCenterLayoutComponent newWithCenteringOptions:CKCenterLayoutComponentCenteringY
                                                                          sizingOptions:CKCenterLayoutComponentSizingOptionDefault
                                                                                 child: [CKInsetComponent newWithInsets:InsetForCheckBox
                                                                                                              component:
                                                                                         [CKImageComponent newWithImage:[UIImage imageNamed:imageName]
                                                                                                             attributes:{}
                                                                                                                   size:{
        .width = CHECK_BOX_HEIGHT,
        .height = CHECK_BOX_HEIGHT
        
    }]
                                                                                         ]
                                       
                                                                                  size:{
        .width = CHECK_BOX_HEIGHT + LEFT_PADDING,
        .height = AVATAR_IMAGE_HEIGHT + 16
    }];
    
    // Combine
    ContactTableCellComponent * c =  [super newWithView:{[UIView class]} component: [CKFlexboxComponent newWithView:{}
                                                                                                               size:{}
                                                                                                              style:{
        .direction = CKFlexboxDirectionColumn,
        .alignItems = CKFlexboxAlignItemsStretch
    }
                                                                                                           children:{
        
        
        {[CKFlexboxComponent newWithView:{[UIView class]}
                                    size:{}
                                   style:{.direction = CKFlexboxDirectionRow, .spacing = SPACE_BETWEEN_ELEMENT}
                                children:{
            {checkBoxComponent},
            {avatarComponent},
            {textComponent}
        }]},
    }]];
    
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

- (void)configForModel:(ContactViewEntity *)entity {
}

- (void)setSelect {
    
}

+ (id)initialState {
    return @NO;
}

@end
#endif
