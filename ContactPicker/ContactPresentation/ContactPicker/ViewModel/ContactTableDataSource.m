//
//  ContactTableDataSource.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/8/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableDataSource.h"

@implementation ContactTableDataSource

+ (instancetype)dataSource {
    return [[ContactTableDataSource alloc] _init];
}

- (instancetype)_init {
    _sections = [NSMutableDictionary dictionary];
    _sectionKeys = [NSMutableArray array];
    for (char i = 'A'; i <= 'Z'; i++) {
        NSString * key = [NSString stringWithFormat:@"%c", i];
        [_sectionKeys addObject:key];
    }
    [_sectionKeys addObject:@"#"];
    return self;
}

#pragma mark - Helper methods
- (TableModelSection *)_sectionAtIndex:(NSInteger)index {
    NSAssert(index >= 0 && index < _sectionKeys.count, @"Invalid section");
    NSString *key = [_sectionKeys objectAtIndex:index];
    return [_sections objectForKey:key];
}

- (NSString *)_makeKeyFromName:(NSString *)name {
    if (name.length == 0)
        return @"#";
    
    NSString * firstLetter = [[name substringToIndex:1] uppercaseString];
    int letterNumber = [firstLetter characterAtIndex:0];
    return (letterNumber >= 65 && letterNumber <= 90) ? firstLetter : @"#";
}

#pragma mark - Public methods
- (NSInteger)numberOfSection {
    return _sectionKeys.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)sectionIdx {
    return [self _sectionAtIndex:sectionIdx].rows.count;
}

- (Entity)objectAtIndexPath:(NSIndexPath *)indexPath {
    TableModelSection *section = [self _sectionAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

- (NSString *)titleForHeaderInSection:(NSInteger)sectionIndex {
    return [self _sectionAtIndex:sectionIndex].headerTitle;
}

- (NSArray *)sectionIndexTitles {
    return _sectionKeys;
}

- (NSIndexPath *)addObject:(Entity)object {
    NSString * key = [self _makeKeyFromName:object.fullName.string];
    TableModelSection *section = [_sections objectForKey:key];
    if (!section) {
        section = [[TableModelSection alloc] initWithHeaderTitle:key footerTitle:@""];
        [_sections setObject:section forKey:key];
    }
    
    NSInteger rowIndex = [section addObject:object];
    NSInteger sectionindex = [_sectionKeys indexOfObject:key];
    
    return [NSIndexPath indexPathForRow:rowIndex inSection:sectionindex];
}

- (NSIndexPath *)removeObject:(Entity)object {
    NSString * key = [self _makeKeyFromName:object.fullName.string];
    TableModelSection *section = [_sections objectForKey:key];
    if (!section) {
        return nil;
    }
    
    NSInteger rowIndex = [section removeObject:object];
    NSInteger sectionindex = [_sectionKeys indexOfObject:key];
    
    return [NSIndexPath indexPathForRow:rowIndex inSection:sectionindex];
}

- (NSIndexPath *)indexPathOfObject:(Entity)object {
    NSString * key = [self _makeKeyFromName:object.fullName.string];
    NSInteger sectionIdx = [_sectionKeys indexOfObject:key];
    TableModelSection *section = [_sections objectForKey:key];
    if (section) {
        NSInteger rowIdx = [section.rows indexOfObject:object];
        return [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
    }
    return nil;
}

- (NSArray *)removeAllObjects {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSString * key in _sections.allKeys) {
        NSInteger sectionIdx = [_sectionKeys indexOfObject:key];
        TableModelSection *section = [_sections objectForKey:key];
        for (NSInteger rowIdx = 0; rowIdx < section.rows.count; rowIdx++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
            [indexPaths addObject:indexPath];
        }
        [section removeAllObject];
    }
    [_sections removeAllObjects];
    return indexPaths;
}

- (Entity)objectOfIdentifier:(NSString *)identifier {
    for (NSString * key in _sections.allKeys) {
        TableModelSection *section = [_sections objectForKey:key];
        Entity object = [section.rows firstObjectWith:^BOOL(Entity _Nonnull obj) {
            return [obj.identifier isEqualToString:identifier];
        }];
        if (object) {
            return object;
        }
    }
    return nil;
}

- (BOOL)isContainsObject:(Entity)object {
    for (NSString * key in _sections.allKeys) {
        TableModelSection *section = [_sections objectForKey:key];
        if ([section containsObject:object])
            return YES;
    }
    return NO;
}

@end
