//
//  TableModelSection.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "TableModelSection.h"
#import "Utilities.h"

@implementation TableModelSection

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle {
    _headerTitle = headerTitle;
    _footerTitle = footerTitle;
    _rows = [NSMutableArray array];
    return self;
}

- (NSInteger)addObject:(id)object {
    [_rows addObject:object];
    return _rows.count - 1;
}

- (NSInteger)removeObject:(id)object {
    NSAssert([_rows containsObject:object], @"object is not exists in rows");
    NSInteger index = [_rows indexOfObject:object];
    [_rows removeObject:object];
    return index;
}

- (NSInteger)insertObject:(id)object atIndex:(NSInteger)index {
    NSAssert(index >= 0 && index <= _rows.count, @"Invalid index");
    [_rows insertObject:object atIndex:index];
    return index;
}

- (NSInteger)removeAllObject {
    NSInteger count = _rows.count;
    [_rows removeAllObjects];
    return count;
}

- (BOOL)containsObject:(id)object {
    return [_rows containsObject:object];
}

- (ContactViewEntity *)contactOfIdentifier:(NSString *)identifier {
    return [_rows firstObjectWith:^BOOL(id  _Nonnull obj) {
        if ([obj isKindOfClass:[ContactViewEntity class]]) {
            return [((ContactViewEntity *)obj).identifier isEqualToString:identifier];
        }
        return NO;
    }];
}

- (id)objectAtIndex:(NSInteger)index {
    NSAssert(index >= 0 && index < _rows.count, @"Invalid index");
    return [_rows objectAtIndex:index];
}

@end
