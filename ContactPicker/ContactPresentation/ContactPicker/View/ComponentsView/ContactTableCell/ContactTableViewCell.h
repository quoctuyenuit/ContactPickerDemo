//
//  ContactTableViewCell.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/4/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewEntity.h"
#import "CheckBoxButtonView.h"
#import "ContactAvatarImageView.h"
#import "CheckBoxButtonDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet ContactAvatarImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet CheckBoxButtonView *checkBox;

- (void) configForModel: (ContactViewEntity *) entity;
- (void) setSelect;
@end

NS_ASSUME_NONNULL_END
