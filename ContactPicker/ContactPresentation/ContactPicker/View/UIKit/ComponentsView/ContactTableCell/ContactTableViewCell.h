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
#import "ContactTableCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewCell : UITableViewCell<ContactTableCellProtocol>
@property (strong, nonatomic) IBOutlet ContactAvatarImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactDescriptionLabel;
@property (strong, nonatomic) IBOutlet CheckBoxButtonView *checkBox;

@end

NS_ASSUME_NONNULL_END
