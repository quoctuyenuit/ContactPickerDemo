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
    NSArray<ContactViewModel*> *_listContact;
    NSMutableArray<ContactViewModel*> *_listContactOnView;
}

@property DataBinding<NSString*>* search;

-(id) init;

-(int) getNumberOfContact;

-(ContactViewModel*) getContactAt: (int) index;

-(BOOL) updateListContactWithKey: (NSString*) key;

@end

NS_ASSUME_NONNULL_END
