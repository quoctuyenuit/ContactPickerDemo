//
//  ContactTableHeaderComponentView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/25/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_COMPONENTKIT
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableHeaderComponentView : UICollectionReusableView
@property(nonatomic, readwrite) UILabel             *title;
@end

NS_ASSUME_NONNULL_END
#endif
