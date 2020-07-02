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

typedef void(^AdapterResponseListBlock)(NSArray<id<ContactDALProtocol>> * contacts, NSError * error);
typedef void(^AdapterResponseContactBlock)(id<ContactDALProtocol> contact, NSError * error);
typedef void(^AdapterResponseListImageBlock)(NSDictionary<NSString *, NSData *> * images, NSError * error);

@protocol ContactAdapterProtocol <NSObject>

@property DataBinding<NSNumber *> * contactChangedObservable;

@required

- (void) requestPermission: (void (^)(BOOL isSuccess, NSError * error)) handler;

//Load all of contacts
- (void) loadContactsWithBlock: (AdapterResponseListBlock) block;

//Load one contact by identifier
- (void) loadContactById: (NSString *) identifier
                   block: (AdapterResponseContactBlock) block;

//Load batch of contacts by list of identifiers
- (void) loadContactsByBatch: (NSArray<NSString *> *) identifiers
                      block: (AdapterResponseListBlock) block;

- (void) loadContactImagesWithBlock:(AdapterResponseListImageBlock) block;

//Get image by id, if image already in cache take it otherwise load it from CNContactStore
- (void) getImageById: (NSString *) identifier
                block: (void (^)(NSData * image, NSError * error)) block;
@end

#endif /* ContactAdapterProtocol_h */
