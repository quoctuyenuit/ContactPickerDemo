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

@required
- (void) requestPermission: (void (^)(BOOL)) completion;
- (void) loadContacts: (void (^)(BOOL)) completion;
- (void) loadBatch: (void (^)(NSArray<ContactBusEntity *> *)) handler;
- (void) getImageFor: (NSString*) identifier completion: (void (^)(UIImage*)) handler;
- (void) searchContactByName: (NSString *) name completion: (void (^)(NSArray *)) handler;
@end

#endif /* ContactBusProtocol_h */
