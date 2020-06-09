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
#import "ContactDALProtocol.h"

@protocol ContactAdapterProtocol <NSObject>

@property DataBinding<NSArray<id<ContactDALProtocol>> *> * contactChangedObservable;

@required

- (void) requestPermission: (void (^)(BOOL isSuccess, NSError * error)) handler;

//Load identifier and name of contacts from CNContactStore. The result will callback by bactch
- (void) loadContacts: (void (^)(NSArray<id<ContactDALProtocol>> * listContacts, NSError * error)) handler;

//Load detail of a contact by identifier, if contact already in cache take it otherwise load it from CNContactStore
- (void) loadContactById: (NSString *) identifier completion: (void (^) (id<ContactDALProtocol> contactDAL, NSError * error)) handler;

//Load batch of detailed contacts by list of identifiers, get contacts already in cache and load others from CNContactStore.
//Set new contact into cache
- (void) loadBatchOfDetailedContacts: (NSArray<NSString *> *) listIdentifiers completion: (void (^)(NSArray<id<ContactDALProtocol>> * listContacts, NSError * error)) handler;

//Get image by id, if image already in cache take it otherwise load it from CNContactStore
- (void) getImageById: (NSString *) identifier completion: (void (^)(NSData * imageData, NSError * error)) handler;

@end

#endif /* ContactAdapterProtocol_h */
