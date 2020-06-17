//
//  ContactCollectionCellNode.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactCollectionCellProtocol.h"
#import "ContactViewEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactCollectionCellNode : ASCellNode <ContactCollectionCellProtocol>
- (instancetype) initWithEntity: (ContactViewEntity *) entity;
@end

NS_ASSUME_NONNULL_END
