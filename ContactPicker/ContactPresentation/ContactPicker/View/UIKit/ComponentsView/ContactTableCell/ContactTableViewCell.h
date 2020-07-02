//
//  ContactTableViewCell.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/4/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_UIKIT
#import <UIKit/UIKit.h>
#import "ContactViewEntity.h"
#import "CheckBoxButtonView.h"
#import "ContactAvatarView.h"
#import "CheckBoxButtonDelegate.h"
#import "ContactTableCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewCell : UITableViewCell<ContactTableCellProtocol>
@end

NS_ASSUME_NONNULL_END
#endif
