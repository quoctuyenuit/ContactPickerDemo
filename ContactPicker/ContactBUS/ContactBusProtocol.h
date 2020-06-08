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

- (void) requestPermission: (void (^)(BOOL, NSError *)) completion;

- (void) loadContacts: (void (^)(NSError *)) completion;

- (void) loadBatchOfContacts: (void (^)(NSArray<ContactBusEntity *> *, NSError *)) handler;

- (void) loadContactById: (NSString *) identifier completion: (void (^) (ContactBusEntity *, NSError * )) handler;

- (void) getImageFromId: (NSString *) identifier completion: (void (^)(NSData *)) handler;

- (void) searchContactByName: (NSString *) name completion: (void (^)(NSArray<ContactBusEntity *> *, NSError *)) handler;

- (void) getAllContacts: (BOOL) isDetail completion: (void (^)(NSArray<ContactBusEntity *> *, NSError *)) handler;
@end

#endif /* ContactBusProtocol_h */
