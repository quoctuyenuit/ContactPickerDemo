//
//  CheckBoxComponent.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
//#import <compo>
#import "CheckBoxButtonDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface CheckBoxComponent : CKCompositeComponent {
    BOOL            _isChecked;
}

@property (nonatomic, readwrite) BOOL                   isChecked;
@property (weak, nonatomic) id<CheckBoxButtonDelegate>  delegate;

+ (instancetype)newWithState:(BOOL) state;
@end

NS_ASSUME_NONNULL_END