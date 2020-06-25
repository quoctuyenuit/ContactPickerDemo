//
//  ContactAvatarView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/23/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactAvatarView : UIView

- (void)configWithImage:(UIImage * _Nullable) image withTitle:(NSString *) title withBackground:(NSArray * _Nullable) backgroundColor;
@end

NS_ASSUME_NONNULL_END
