//
//  ContactTableDataSource.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableDataSource.h"

@implementation ContactTableDataSource

- (instancetype)initWithSectionHeaderTitle:(NSArray<NSString *> *)titles {
    NSAssert(titles, @"titles is nil");
    for (NSString * title in titles) {
        [self _appendSectionWithHeaderTitle:title footerTitle:@""];
    }
    return self;
}

#pragma mark - Private methods
- (TableModelSection *)_appendSectionWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle {
    if (_sections == nil) {
        _sections = [NSMutableArray array];
    }
    
    TableModelSection *section = [TableModelSection section];
    section.headerTitle = headerTitle;
    section.footerTitle = footerTitle;
    section.rows        = [NSMutableArray array];
    [_sections addObject:section];
    return section;
}

#pragma mark - Adjust datasource methods
- (NSIndexPath *)addObject:(id)object
               headerTitle:(nonnull NSString *)headerTitle
               footerTitle:(nonnull NSString *)footerTitle {
    TableModelSection *section = _sections.count > 0 ? _sections.lastObject :
    [self _appendSectionWithHeaderTitle:headerTitle footerTitle:footerTitle];
    
    [section.rows addObject:object];
    
    return [NSIndexPath indexPathForRow:section.rows.count - 1 inSection:_sections.count - 1];
}

- (NSIndexPath *)addObject:(id)object toSection:(NSInteger)section {
    NSAssert(section >= 0 && section < _sections.count, @"Invalid section");
    TableModelSection *tableSection = [_sections objectAtIndex:section];
    [tableSection.rows addObject:object];
    return [NSIndexPath indexPathForRow:tableSection.rows.count - 1 inSection:section];
}

- (NSArray *)addObjectFromArray:(NSArray *)array
                    headerTitle:(nonnull NSString *)headerTitle
                    footerTitle:(nonnull NSString *)footerTitle {
    NSMutableArray * indices = [NSMutableArray array];
    for (id object in array) {
        [indices addObject:[self addObject:object headerTitle:headerTitle footerTitle:footerTitle]];
    }
    return indices;
}

- (NSArray *)addObjectFromArray:(NSArray *)array toSection:(NSInteger)section {
    NSMutableArray * indices = [NSMutableArray array];
    for (id object in array) {
        [indices addObject:[self addObject:object toSection:section]];
    }
    return indices;
}

- (NSIndexPath *)insertObject:(id)object indexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.section >= 0 && indexPath.section < _sections.count, @"Invalid section");
    TableModelSection *section = [_sections objectAtIndex:indexPath.section];
    NSAssert(indexPath.row >= 0 && indexPath.row <= section.rows.count, @"Invalid section");
    [section.rows insertObject:object atIndex:indexPath.row];
    return indexPath;
}

- (NSIndexPath *)removeObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.section >= 0 && indexPath.section < _sections.count, @"Invalid section");
    TableModelSection *section = [_sections objectAtIndex:indexPath.section];
    NSAssert(indexPath.row >= 0 && indexPath.row < section.rows.count, @"Invalid section");
    [section.rows removeObjectAtIndex:indexPath.row];
    return indexPath;
}

- (NSArray *)removeAllObjects {
    NSMutableArray *indices = [[NSMutableArray alloc] init];
    for (NSInteger sectionIdx = 0; sectionIdx < _sections.count; sectionIdx++) {
        TableModelSection *section = [_sections objectAtIndex:sectionIdx];
        for (NSInteger row = 0; row < section.rows.count; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectionIdx];
            [indices addObject:[self removeObjectAtIndexPath:indexPath]];
        }
    }
    return indices;
}

#pragma mark - Building table methods
- (NSInteger)numberOfSection {
    return _sections.count;
}

- (NSInteger)numberOfRowInSection:(NSInteger)section {
    NSAssert(section >= 0 && section < _sections.count, @"Invalid section");
    return [_sections objectAtIndex:section].rows.count;
}

- (id)rowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.section >= 0 && indexPath.section < _sections.count, @"Invalid section");
    NSArray * rowsInSection = [_sections objectAtIndex:indexPath.section].rows;
    NSAssert(indexPath.row >= 0 && indexPath.row < rowsInSection.count, @"Invalid row");
    
    return [rowsInSection objectAtIndex:indexPath.row];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSAssert(section >= 0 && section < _sections.count, @"Invalid section");
    return [_sections objectAtIndex:section].headerTitle;
}

- (NSArray *)sectionIndexTitles {
    return _prefixTitleSections;
}

@end
