//
//  ContactViewCell.h
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *activeTime;
-(void) config: (ContactViewModel*) model;

@end

NS_ASSUME_NONNULL_END
