//
//  DataBinding.h
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef DataBinding_h
#define DataBinding_h

@interface DataBinding<DataType> : NSObject {
    DataType _value;
    NSMutableArray<void (^)(DataType)> *_handlers;
}

@property(atomic, readwrite) DataType value;
- (id)initWithValue: (DataType) value;
- (void)binding: (void (^)(DataType)) hdl;
- (void)fire;
- (void)bindAndFire: (void (^)(DataType)) hdl;

@end

#endif /* DataBinding_h */
