//
//  UpdateInfo.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "TableChangeset.h"

@implementation TableChangeset
- (instancetype)initWithDeletedIndexes:(NSArray<NSIndexPath *> *)deletedIndexes addedIndexes:(NSArray<NSIndexPath *> *)addedIndexes {
    _deletedIndexs  = [NSArray arrayWithArray:deletedIndexes];
    _addedIndexes   = [NSArray arrayWithArray:addedIndexes];
    return self;
}
@end
