//
//  ListContactViewModel.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ListContactViewModel.h"
#import "ContactViewModel.h"
#import "ContactModel.h"

@interface ListContactViewModel() {
}

-(NSArray<ContactViewModel*>*) dummyListContact;

@end

@implementation ListContactViewModel
-(id) init {
    self.search = [[DataBinding<NSString*> alloc] initWithValue:@""];
    _listContact = [self dummyListContact];
    _listContactOnView = [NSMutableArray arrayWithArray:_listContact];
    return self;
}

- (NSArray<ContactViewModel *> *)dummyListContact {
    ContactViewModel* model = [[ContactViewModel alloc] initWithModel:[[ContactModel alloc] initWithName:@"Nguyen Quoc Tuyen" avatar:nil activeTime:200]];
    
    ContactViewModel* model2 = [[ContactViewModel alloc] initWithModel:[[ContactModel alloc] initWithName:@"Nguyen Van Thi" avatar: [UIImage imageNamed: @"default_avatar"] activeTime:200]];
    
    return [NSArray arrayWithObjects:model, model2, nil];
}

-(int) getNumberOfContact {
    return (int)_listContactOnView.count;
}

- (ContactViewModel *)getContactAt:(int)index {
    if (index < _listContactOnView.count) {
        return _listContactOnView[index];
    }
    return nil;
}

- (BOOL)updateListContactWithKey:(NSString *)key {
    NSUInteger beforeLength = _listContactOnView.count;
    [_listContactOnView removeAllObjects];
    for (ContactViewModel* contact in _listContact) {
        if ([contact contactStartWith: key])
            [_listContactOnView addObject:contact];
    }
    
    return (beforeLength != _listContactOnView.count);
}
@end
