//
//  HorizontalListItemProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/26/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef HorizontalListItemProtocol_h
#define HorizontalListItemProtocol_h

#import "ContactViewEntity.h"

#define ITEM_SIZE   CGSizeMake(55, 55)

@protocol HorizontalListItemProtocol;

@protocol HorizontalListItemDelegate <NSObject>

- (NSInteger) horizontalListItem:(id<HorizontalListItemProtocol>) listItemView numberOfItemAtSection:(NSInteger) section;
- (ContactViewEntity *) horizontalListItem:(id<HorizontalListItemProtocol>) listItemView entityForIndexPath:(NSIndexPath *) indexPath;
- (void) removeCellWithContact:(NSString *) identifier;

@end

@protocol HorizontalListItemProtocol <NSObject>

@property(weak, nonatomic) id<HorizontalListItemDelegate> delegate;
- (void)insertItemAtIndex:(NSInteger) index;
- (void)removeItemAtIndex:(NSInteger) index;

@end

#endif /* HorizontalListItemProtocol_h */
