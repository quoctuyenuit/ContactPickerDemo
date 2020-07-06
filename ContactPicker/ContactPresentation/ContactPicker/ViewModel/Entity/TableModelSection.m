//
//  TableModelSection.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "TableModelSection.h"

@implementation TableModelSection

+ (instancetype)section {
    return [[TableModelSection alloc] init];
}

- (NSMutableArray *)rows {
    if (!_rows) {
        _rows = [NSMutableArray array];
    }
    return _rows;
}

@end
