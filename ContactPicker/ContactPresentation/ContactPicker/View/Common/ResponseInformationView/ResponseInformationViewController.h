//
//  PermissionDeniedViewController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardAppearanceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ResponseViewTypePermissionDenied,
    ResponseViewTypeEmptyContact,
    ResponseViewTypeFailLoadingContact,
    ResponseViewTypeSomethingWrong
} ResponseViewType;

@interface ResponseInformationViewController : UIView<KeyboardAppearanceProtocol>
- (instancetype)initWithType:(ResponseViewType) viewType;

@end

NS_ASSUME_NONNULL_END
