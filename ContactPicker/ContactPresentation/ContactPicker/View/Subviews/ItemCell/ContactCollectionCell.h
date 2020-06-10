//
//  ContactCollectionCell.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactAvatarImageView.h"
#import "ContactViewEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet ContactAvatarImageView *avatar;

- (void) config: (ContactViewEntity *) entity;
@end

NS_ASSUME_NONNULL_END
