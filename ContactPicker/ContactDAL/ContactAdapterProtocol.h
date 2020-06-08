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
@property DataBinding<NSArray<ContactDAL *> *> * contactChangedObservable;
@required
- (void) requestPermission: (void (^)(BOOL, NSError * )) handler;

- (void) loadContacts: (void (^)(NSArray<ContactDAL *> *, NSError * )) handler;

- (void) loadContactById: (NSString *) identifier completion: (void (^) (ContactDAL *, NSError * )) handler;

- (void) loadBatchOfContacts: (NSArray<NSString *> *) listIdentifiers completion: (void (^)(NSArray *, NSError *)) handler;

- (void) getImageFromId: (NSString *) identifier completion: (void (^)(NSData *)) handler;

@end

#endif /* ContactAdapterProtocol_h */
