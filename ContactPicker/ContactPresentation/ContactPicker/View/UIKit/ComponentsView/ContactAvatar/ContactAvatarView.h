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
@property(nonatomic, readwrite) ContactViewEntity   * contact;

- (void)configWithImage:(UIImage * _Nullable) image withTitle:(NSString *) title withBackground:(NSArray * _Nullable) backgroundColor;

- (void)configWithContact:(ContactViewEntity *) contact;
@end

NS_ASSUME_NONNULL_END
