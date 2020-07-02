//
//  CheckBoxButtonView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_UIKIT
#import <UIKit/UIKit.h>
#import "CheckBoxButtonDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface CheckBoxButtonView : UIButton {
    BOOL        _isChecked;
}

@property (nonatomic, readwrite) BOOL isChecked;
@property (weak, nonatomic) id<CheckBoxButtonDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
#endif
