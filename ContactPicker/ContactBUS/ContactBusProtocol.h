//
//  ContactBusProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactBusProtocol_h
#define ContactBusProtocol_h
#import "ContactBusEntity.h"
#import <UIKit/UIKit.h>

@protocol ContactBusProtocol <NSObject>

@property void (^contactChangedObservable)(NSArray *);

@required

- (void) requestPermission: (void (^)(BOOL granted, NSError * error)) completion;

- (void) loadContacts: (void (^)(NSError * error, BOOL isDone, NSUInteger numberOfContacts)) handler;

- (void) loadBatchOfDetailedContacts: (NSArray<NSString *> *) identifiers isReload:(BOOL) isReload completion: (void (^)(NSArray<ContactBusEntity *> *, NSError *)) handler;

- (void) loadContactByBatch:(int) numberOfContact completion:(void (^)(NSArray<ContactBusEntity *> *, NSError * error)) handler;

- (void) loadContactById: (NSString *) identifier isReload:(BOOL) isReload completion: (void (^) (ContactBusEntity *, NSError * )) handler;

- (void) getImageFromId: (NSString *) identifier isReload:(BOOL) isReload completion: (void (^)(NSData * imageData, NSError * error)) handler;

- (void) searchContactByName: (NSString *) name block: (void (^)(void)) handler;

@end

#endif /* ContactBusProtocol_h */
