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

@protocol ContactAdapterDelegate;

typedef void(^AdapterResponseListBlock)(NSArray<id<ContactDALProtocol>> * contacts, NSError * error);
typedef void(^AdapterResponseContactBlock)(id<ContactDALProtocol> contact, NSError * error);
typedef void(^AdapterResponseListImageBlock)(NSDictionary<NSString *, NSData *> * images, NSError * error);

@protocol ContactAdapterProtocol <NSObject>

@property(nonatomic, weak) id<ContactAdapterDelegate> delegate;

@required

/**
 * Request contact permission and return result asynchronus through block
 * @param block call back block to return result
 * @param queue the queue that result will dispatch result on it
 */
- (void) requestPermission:(void (^)(BOOL isSuccess, NSError * error)) block
                   onQueue:(dispatch_queue_t)queue;

/**
 * Load all of contact and return result asynchronus through block
 * @param block call back block to return result
 * @param queue the queue that result will dispatch result on it
 */
- (void) loadContactsWithBlock:(AdapterResponseListBlock) block
                       onQueue:(dispatch_queue_t)queue;

/**
 * Load contact by batch, take a list of identifiers and return result asynchronus through block
 * @param identifiers list of identifiers that need to load detail contact
 * @param block call back block to return result
 * @param queue the queue that result will dispatch result on it
 */
- (void) loadContactsByBatch:(NSArray<NSString *> *) identifiers
                       block:(AdapterResponseListBlock) block
                     onQueue:(dispatch_queue_t)queue;
/**
 * Load contact by batch, take a list of identifiers and return result asynchronus through block
 * @param identifier identifier of image that need to load
 * @param block call back block to return result
 * @param queue the queue that result will dispatch result on it
 */
- (void) loadImageWithIdentifier:(NSString *) identifier
                           block:(void (^)(NSData * imageData, NSError * error)) block
                         onQueue:(dispatch_queue_t)queue;
@end

@protocol ContactAdapterDelegate <NSObject>

- (void)contactDidChangeWithAdapter:(id<ContactAdapterProtocol>)adapter;

@end
#endif /* ContactAdapterProtocol_h */
