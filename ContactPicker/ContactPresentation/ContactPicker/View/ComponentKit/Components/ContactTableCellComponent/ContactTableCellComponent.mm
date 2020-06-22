//
//  ContactTableCellComponent.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableCellComponent.h"
#import "Utilities.h"

#define CONTACT_NAME_FONT [UIFont systemFontOfSize: CONTACT_FONT_SIZE]

@implementation ContactTableCellComponent

+ (instancetype)newWithContact:(ContactViewEntity *) contact {
    CKComponentScope scope(self);
    
    return [super newWithView:{[UIView class]} component:[CKFlexboxComponent newWithView:{[UIView class]}
                                                                                    size:{}
                                                                                   style:{ .direction = CKFlexboxDirectionRow, .spacing = 5 }
                                                                                children:{
        
        {[CKLabelComponent newWithLabelAttributes:{ .string = contact.fullName, .font = CONTACT_NAME_FONT, .color = UIColor.blackColor }
                                   viewAttributes:{ {@selector(setBackgroundColor:), [UIColor clearColor]}, {@selector(setUserInteractionEnabled:), @NO} }
                                             size:{}]},
        
        {[CKLabelComponent newWithLabelAttributes:{ .string = contact.contactDescription, .font = CONTACT_NAME_FONT, .color = UIColor.blackColor }
                                   viewAttributes:{ {@selector(setBackgroundColor:), [UIColor clearColor]}, {@selector(setUserInteractionEnabled:), @NO} }
                                             size:{}]}
            
        }]];
}

- (void)configForModel:(ContactViewEntity *)entity {
    
}

- (void)setSelect {
    
}

+ (id)initialState {
    return @NO;
}

@end
