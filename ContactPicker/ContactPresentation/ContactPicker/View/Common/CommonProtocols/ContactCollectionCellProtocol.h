//
//  ContactCollectionCellProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactCollectionCellProtocol_h
#define ContactCollectionCellProtocol_h
#import "ContactViewEntity.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ContactCollectionCellDelegate <NSObject>

- (void) removeCell: (NSString *) identifier;

@end

@protocol ContactCollectionCellProtocol <NSObject>

@property (weak, nonatomic) id<ContactCollectionCellDelegate> delegate;

- (void)binding: (ContactViewEntity *) entity;

@end

NS_ASSUME_NONNULL_END

#endif /* ContactCollectionCellProtocol_h */
