//
//  ContactBusProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactBusProtocol_h
#define ContactBusProtocol_h
#import "ContactBusEntityProtocol.h"
#import "DataBinding.h"
#import <UIKit/UIKit.h>

@protocol ContactBusinessLayerDelegate;

typedef void(^BusinessResponseListBlock)(NSArray<id<ContactBusEntityProtocol>> * contacts, NSError * error);
typedef void(^BusinessResponseContactBlock)(id<ContactBusEntityProtocol> contact, NSError * error);
typedef void(^BusinessResponseListImageBlock)(NSDictionary<NSString *, UIImage *> * images, NSError * error);

@protocol ContactBusinessLayerProtocol <NSObject>

@property(nonatomic, weak) id<ContactBusinessLayerDelegate> delegate;

@required
/**
 * Request contact permission and return result asynchronus through block
 * @param block call back block to return result
 * @param queue the queue that result will dispatch result on it
 */
- (void) requestPermissionWithBlock:(void (^)(BOOL granted, NSError * error))block
                            onQueue:(dispatch_queue_t)queue;
/**
 * Load all of contact and return result asynchronus through block
 * @param block call back block to return result
 * @param queue the queue that result will dispatch result on it
 */
- (void) loadContactsWithBlock: (BusinessResponseListBlock) block
                       onQueue:(dispatch_queue_t)queue;
/**
 * Search contact by name
 * @param name name of contact that want to search
 * @param block call back block to return result
 * @param queue the queue that result will dispatch result on it
 */
- (void) searchContactByName: (NSString *) name
                       block: (BusinessResponseListBlock) block
                     onQueue:(dispatch_queue_t)queue;
@end

@protocol ContactBusinessLayerDelegate <NSObject>

- (void)contactDidChangedWithBusiness:(id<ContactBusinessLayerProtocol>)business
                        contactsAdded:(NSArray *)contactsAdded
                      contactsRemoved:(NSArray *)contactsRemoved
                      contactsUpdated:(NSArray *)contactsUpdated;

@end

#endif /* ContactBusProtocol_h */
