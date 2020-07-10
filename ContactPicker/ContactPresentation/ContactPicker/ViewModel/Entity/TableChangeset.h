//
//  UpdateInfo.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableChangeset : NSObject
@property(nonatomic, readonly) NSArray<NSIndexPath *> *  deletedIndexs;
@property(nonatomic, readonly) NSArray<NSIndexPath *> *  addedIndexes;

- (instancetype)initWithDeletedIndexes:(NSArray<NSIndexPath *> *) deletedIndexes addedIndexes:(NSArray<NSIndexPath *> *) addedIndexes;
@end

NS_ASSUME_NONNULL_END
