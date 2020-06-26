//
//  HorizontalListNode.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewEntity.h"
#import "HorizontalListItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HorizontalListNode : ASDisplayNode <HorizontalListItemProtocol>
@property(nonatomic, strong) ASCollectionNode               * collectionNode;

- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
