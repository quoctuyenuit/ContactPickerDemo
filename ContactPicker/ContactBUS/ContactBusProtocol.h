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

@property (nonatomic, readwrite) int currentIndexBatch;

@property void (^contactChangedObservable)(NSArray *);

@required

- (void) requestPermission: (void (^)(BOOL granted, NSError * error)) completion;

- (void) loadContacts: (void (^)(NSError * error, BOOL isDone)) completion;

- (void) loadBatchOfDetailedContacts: (void (^)(NSArray<ContactBusEntity *> *, NSError *)) handler;

- (void) loadContactById: (NSString *) identifier completion: (void (^) (ContactBusEntity *, NSError * )) handler;

- (void) getImageFromId: (NSString *) identifier completion: (void (^)(NSData * imageData, NSError * error)) handler;

- (void) searchContactByName: (NSString *) name completion: (void (^)(void)) handler;

- (void) getAllContacts: (BOOL) isDetail completion: (void (^)(NSArray<ContactBusEntity *> *, NSError *)) handler;
@end

#endif /* ContactBusProtocol_h */
