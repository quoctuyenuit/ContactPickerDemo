//
//  HorizontalListItemView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_UIKIT
#import <UIKit/UIKit.h>
#import "HorizontalListItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HorizontalListItemView : UIView < HorizontalListItemProtocol > 
@end

NS_ASSUME_NONNULL_END
#endif
