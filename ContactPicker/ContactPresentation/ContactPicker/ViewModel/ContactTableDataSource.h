//
//  ContactTableDataSource.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableModelSection.h"
#import "ContactViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableDataSource : NSObject
@property(nonatomic, readonly) NSMutableArray<TableModelSection *>  *sections;
@property(nonatomic, readonly) NSArray<NSString *>                  *prefixTitleSections;

- (instancetype) initWithSectionHeaderTitle:(NSArray<NSString *> *) titles;

- (NSIndexPath *)addObject:(id)object
               headerTitle:(NSString *) headerTitle
               footerTitle:(NSString *)footerTitle;
- (NSIndexPath *)addObject:(id)object toSection:(NSInteger)section;
- (NSArray *)addObjectFromArray:(NSArray *)array
                    headerTitle:(nonnull NSString *)headerTitle
                    footerTitle:(nonnull NSString *)footerTitle;
- (NSArray *)addObjectFromArray:(NSArray *)array toSection:(NSInteger)section;
- (NSIndexPath *)insertObject:(id)object indexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)removeObjectAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)removeAllObjects;

- (NSInteger)numberOfSection;
- (NSInteger)numberOfRowInSection:(NSInteger)section;
- (id)rowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSArray *)sectionIndexTitles;
@end

NS_ASSUME_NONNULL_END
