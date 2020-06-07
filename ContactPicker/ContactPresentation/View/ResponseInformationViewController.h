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
} ResponseViewType;

@interface ResponseInformationViewController : UIViewController<KeyboardAppearanceProtocol> {
    ResponseViewType viewType;
}

@property (weak, nonatomic) IBOutlet UIImageView *responseIconView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *openSettingBtn;

extern NSString * const _Nonnull PermissionDeniedMsg;
extern NSString * const _Nonnull EmptyContactMsg;
extern NSString * const _Nonnull FailLoadingContactMsg;

+ (ResponseInformationViewController *) instantiateWith: (ResponseViewType) viewType;

@end

NS_ASSUME_NONNULL_END
