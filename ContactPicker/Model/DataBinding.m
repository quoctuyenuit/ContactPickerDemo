//
//  DataBinding.m
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBinding.h"

@interface DataBinding()


@end


@implementation DataBinding

- (id)initWithValue:(id)value {
    _handlers = [[NSMutableArray alloc] init];
    _value = value;
    return self;
}

-(id) value {
    return _value;
}

-(void) setValue:(id)value {
    _value = value;
    [self fire];
}

//=================================================================================

-(void) binding:(void (^)(id)) hdl {
    [_handlers addObject:hdl];
}

-(void) fire {
    typedef void (^Handler)(id);
    for (Handler hdl in _handlers) {
        hdl(_value);
    }
}

-(void) bindAndFire:(void (^)(id)) hdl {
    [self binding:hdl];
    [self fire];
}

@end
