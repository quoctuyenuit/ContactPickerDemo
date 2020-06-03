//
//  ListContactViewModel.h
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBinding.h"
#import "ContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListContactViewModel : NSObject {
    NSMutableArray<ContactViewModel*> *_listContactOnView;
    NSMutableArray<ContactViewModel*> *_listContact;
}

@property DataBinding<NSString*>* search;
@property DataBinding<NSNumber*>* numberOfContact;

- (id)init;

- (int)getNumberOfContact;

- (ContactViewModel*)getContactAt: (int) index;

- (BOOL)updateListContactWithKey: (NSString*) key;

- (void)getAllContact;
@end

NS_ASSUME_NONNULL_END
