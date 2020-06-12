//
//  NSArrayExtension.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/4/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "NSArrayExtension.h"

@implementation NSArray(extension)
- (NSArray *)map:(id  _Nonnull (^)(id _Nonnull))block {
    NSMutableArray* results = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [results addObject:block(obj)];
    }];
    return [results copy];
}

- (NSArray *)filter:(BOOL (^)(id obj))block {
    NSMutableArray *mutableArray = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (block(obj) == YES) {
            [mutableArray addObject:obj];
        }
    }];
    return [mutableArray copy];
}

- (id)reduce:(id)initial
       block:(id (^)(id obj1, id obj2))block {
    __block id obj = initial;
    [self enumerateObjectsUsingBlock:^(id _obj, NSUInteger idx, BOOL *stop) {
        obj = block(obj, _obj);
    }];
    return obj;
}

- (NSArray *)flatMap:(id (^)(id obj))block {
    NSMutableArray *mutableArray = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id _obj = block(obj);
        if ([_obj isKindOfClass:[NSArray class]]) {
            NSArray *_array = [_obj flatMap:block];
            [mutableArray addObjectsFromArray:_array];
            return;
        }
        [mutableArray addObject:_obj];
    }];
    return [mutableArray copy];
}

- (id _Nullable)firstObjectWith:(BOOL (^)(id _Nonnull))block {
    for (id obj in self) {
        if (block(obj))
            return obj;
    }
    
    return nil;
}

- (BOOL)containsObjectWith:(BOOL (^)(id _Nonnull))block {
    for (id obj in self) {
        if (block(obj))
            return YES;
    }
    return NO;
}
@end
