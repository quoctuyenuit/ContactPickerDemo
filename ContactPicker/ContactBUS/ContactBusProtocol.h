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
@required - (void) requestPermission: (void (^)(BOOL)) completion;
@required - (void) loadContacts: (void (^)(BOOL)) completion;
@required - (void) loadBatch: (void (^)(NSArray<ContactBusEntity *> *)) handler;
@required - (void) searchContactByName: (NSString *) name completion: (void (^)(NSArray *)) handler;
@end

#endif /* ContactBusProtocol_h */
