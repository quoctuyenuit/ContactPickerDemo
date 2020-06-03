//
//  ContactViewCell.h
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewModel.h"
#import "CheckBoxButtonView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITableViewCell *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *activeTime;
@property (weak, nonatomic) IBOutlet CheckBoxButtonView *checkButton;
-(void) config: (ContactViewModel*) model;
-(void) select;
@end

NS_ASSUME_NONNULL_END
