//
//  ContactCollectionCell.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactAvatarView.h"
#import "ContactViewEntity.h"
#import "ContactCollectionCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactCollectionCell : UICollectionViewCell<ContactCollectionCellProtocol>
@property (weak, nonatomic) IBOutlet ContactAvatarView *avatar;

@end



NS_ASSUME_NONNULL_END
