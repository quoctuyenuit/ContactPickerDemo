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

NS_ASSUME_NONNULL_BEGIN

@protocol HorizontalListNodeDelegate <NSObject>

- (void)listDidClickButton:(NSArray<ContactViewEntity *> *) listContacts;

@end

@interface HorizontalListNode : ASDisplayNode
@property(nonatomic, strong) ASCollectionNode               * collectionNode;
@property(weak, readwrite) id<HorizontalListNodeDelegate>     delegate;

- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
