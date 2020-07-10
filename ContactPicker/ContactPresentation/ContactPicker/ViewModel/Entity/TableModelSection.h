//
//  TableModelSection.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactViewEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface TableModelSection : NSObject


@property(nonatomic, copy) NSString *           headerTitle;
@property(nonatomic, copy) NSString *           footerTitle;
@property(nonatomic, strong) NSMutableArray *   rows;

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;

- (NSInteger)addObject:(id)object;

- (NSInteger)removeObject:(id)object;

- (NSInteger)insertObject:(id)object atIndex:(NSInteger)index;

- (NSInteger)removeAllObject;

- (BOOL)containsObject:(id)object;

- (ContactViewEntity *)contactOfIdentifier:(NSString *)identifier;

- (id)objectAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
