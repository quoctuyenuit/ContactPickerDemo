//
//  ContactTableDataSource.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/8/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableModelSection.h"
#import "ContactViewEntity.h"

NS_ASSUME_NONNULL_BEGIN
typedef ContactViewEntity* Entity;

@interface ContactTableDataSource : NSObject
@property(atomic, readonly) NSMutableDictionary<NSString *, TableModelSection *>    *sections;
@property(nonatomic, readonly) NSMutableArray<NSString *>                           *sectionKeys;

+ (instancetype)dataSource;
- (NSInteger)numberOfSection;
- (NSInteger)numberOfRowsInSection:(NSInteger)sectionIdx;
- (Entity)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleForHeaderInSection:(NSInteger)sectionIndex;
- (NSArray *)sectionIndexTitles;

- (NSIndexPath *)addObject:(Entity)object;
- (NSIndexPath *)removeObject:(Entity)object;
- (NSIndexPath *)indexPathOfObject:(Entity)object;
- (NSArray *)removeAllObjects;
- (Entity)objectOfIdentifier:(NSString *)identifier;
- (BOOL)isContainsObject:(Entity)object;
@end

NS_ASSUME_NONNULL_END
