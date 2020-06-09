//
//  ContactBus.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactBus.h"
#import "ContactDAL.h"
#import "NSArrayExtension.h"
#import "ContactBusEntity.h"
#import <UIKit/UIKit.h>
#import "Logging.h"

@interface ContactBus() {
    int busBatchSize;
    NSMutableArray<ContactBusEntity *> * listContactRequestedInfor;
    BOOL contactIsLoaded;
}

- (void) getContactBatchStartWith: (int) index
                        batchSize: (int) batchSize
                       completion: (void (^)(NSArray<ContactBusEntity *> *, NSError *)) handler;

- (void) getContactBatchWithIdentifiers: (NSArray *) identifiers completion: (void (^)(NSArray<ContactBusEntity *> *, NSError *)) handler;
- (void) getContactBatchWithContacts: (NSArray<ContactBusEntity *> *) contacts completion: (void (^)(NSArray<ContactBusEntity *> *, NSError *)) handler;

@end

@implementation ContactBus

@synthesize currentIndexBatch;

@synthesize contactChangedObservable;

- (id)initWithAdapter:(id<ContactAdapterProtocol>)adapter {
    self->_contactAdapter = adapter;
    self->busBatchSize = 20;
    self->currentIndexBatch = 0;
    self->contactIsLoaded = NO;
    
    self->listContactRequestedInfor = [[NSMutableArray alloc] init];
     __weak ContactBus * weakSelf = self;
    [self->_contactAdapter.contactChangedObservable binding:^(NSArray<ContactDAL *> * listContactDAL) {
        NSArray * listContactBusEntity = [listContactDAL map:^ContactBusEntity* _Nonnull(ContactDAL *  _Nonnull obj) {
            return [[ContactBusEntity alloc] initWithData: obj];
        }];
        if (weakSelf.contactChangedObservable) {
            weakSelf.contactChangedObservable(listContactBusEntity);
        }
    }];
    return self;
}

- (void)getContactBatchStartWith:(int)index
                       batchSize: (int) batchSize
                      completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    int batchSizeNeeded = (index + batchSize) >= self->listContactRequestedInfor.count ?  (int)self->listContactRequestedInfor.count - index : batchSize;
    
    NSArray* batch = [self->listContactRequestedInfor subarrayWithRange:NSMakeRange(index, batchSizeNeeded)];
    
    NSArray *batchIdentifiers = [batch map:^NSString* _Nonnull(ContactBusEntity*  _Nonnull obj) {
        return obj.identifier;
    }];
    
    [self getContactBatchWithIdentifiers:batchIdentifiers completion:handler];
}

- (void)getContactBatchWithIdentifiers:(NSArray *)identifiers completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    
    [self->_contactAdapter loadBatchOfDetailedContacts:identifiers completion:^(NSArray<ContactDAL*> * listContacts, NSError * error) {
        if (error) {
            handler(nil, error);
            [Logging exeption:error.localizedDescription];
        } else {
            NSArray* listContactBusEntitys = [listContacts map:^ContactBusEntity* _Nonnull(ContactDAL*  _Nonnull obj) {
                return [[ContactBusEntity alloc] initWithData:obj];
            }];
            
            handler([listContactBusEntitys copy], nil);
        }
    }];
}

- (void)getContactBatchWithContacts:(NSArray<ContactBusEntity *> *)contacts completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    NSArray *batchIdentifiers = [contacts map:^NSString* _Nonnull(ContactBusEntity*  _Nonnull obj) {
        return obj.identifier;
    }];
    [self getContactBatchWithIdentifiers:batchIdentifiers completion:handler];
}

#pragma mask Protocol methods

- (void)requestPermission:(void (^)(BOOL, NSError *))handler {
    [self->_contactAdapter requestPermission:handler];
}

- (void)loadContacts:(void (^)(NSError *))handler {
    [self->_contactAdapter loadContacts:^(NSArray<ContactDAL *> * listContactRequestedInfor, NSError * error) {
        if (error) {
            handler(error);
            [Logging exeption:error.localizedDescription];
        } else {
            NSArray * listContactBusEntities = [listContactRequestedInfor map:^ContactBusEntity * _Nonnull(ContactDAL * _Nonnull obj) {
                return [[ContactBusEntity alloc] initWithData:obj];
            }];
            [self->listContactRequestedInfor addObjectsFromArray: listContactBusEntities];
            self->contactIsLoaded = YES;
            handler(nil);
        }
    }];
}

- (void)loadContactById:(NSString *)identifier completion:(void (^)(ContactBusEntity *, NSError *))handler {
    [self->_contactAdapter loadContactById:identifier completion:^(ContactDAL * contactDAL, NSError * error) {
        handler([[ContactBusEntity alloc] initWithData:contactDAL], error);
    }];
}

- (void)loadBatchOfDetailedContacts:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    if (!self->contactIsLoaded) {
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"Contacts have not load yet"};
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:2 userInfo:userInfo];
        handler(nil, error);
        return;
    }
    
    if (self->currentIndexBatch >= self->listContactRequestedInfor.count)
        return;
    
    int gap = (int)self->listContactRequestedInfor.count - self->currentIndexBatch;
    int batchSize = gap >= self->busBatchSize ? self->busBatchSize : gap;
    
    [self getContactBatchStartWith:self->currentIndexBatch batchSize: batchSize completion:^(NSArray<ContactBusEntity *> * listContacts, NSError * error) {
        if (error) {
            handler(nil, error);
            [Logging exeption:error.localizedDescription];
        } else {
            self->currentIndexBatch += listContacts.count;
            handler(listContacts, nil);
        }
    }];
}

- (void)getImageFromId:(NSString *)identifier completion:(void (^)(NSData * imageData, NSError * error))handler {
    [self->_contactAdapter getImageById:identifier completion:handler];
}

- (void)searchContactByName:(NSString *)name completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        
        
        
        NSArray * listContactNeed = [self->listContactRequestedInfor filter:^BOOL(ContactBusEntity*  _Nonnull obj) {
            NSString * contactName = [NSString stringWithFormat:@"%@ %@", obj.givenName, obj.familyName];
            
            if ([name isEqualToString:@""])
                return YES;
            
            return [[contactName lowercaseString] hasPrefix:[name lowercaseString]];
        }];
        
        [self getContactBatchWithContacts:listContactNeed completion:handler];
    
    });
}

- (void)getAllContacts:(BOOL)isDetail completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    if (!self->contactIsLoaded) {
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"Contacts have not load yet"};
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:2 userInfo:userInfo];
        handler(nil, error);
        return;
    }
    
    if (isDetail) {
        [self getContactBatchWithContacts:self->listContactRequestedInfor completion:handler];
    } else {
        handler(self->listContactRequestedInfor, nil);
    }
}

@end
