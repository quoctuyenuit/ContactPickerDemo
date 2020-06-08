//
//  ContactAdapterProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactAdapterProtocol_h
#define ContactAdapterProtocol_h
#import <UIKit/UIKit.h>
#import "ContactDAL.h"
#import "DataBinding.h"

@protocol ContactAdapterProtocol <NSObject>
@property DataBinding<NSArray<ContactDAL *> *> *contactChangedObservable;
@required
- (void) requestPermission: (void (^)(BOOL)) completion;

- (void) loadContacts: (void (^)(NSArray<ContactDAL *> * , BOOL)) completion;

- (void) loadContactById: (NSString *) identifier
              completion: (void (^) (ContactDAL *)) completion;

- (void) loadContactByBatch: (NSArray<NSString *> *) listIdentifiers
                 completion: (void (^)(NSArray *)) completion;

- (void) getImageFromId: (NSString *) identifier completion: (void (^)(NSData *)) handler;

@end

#endif /* ContactAdapterProtocol_h */
