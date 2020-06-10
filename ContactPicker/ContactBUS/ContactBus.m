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
    NSMutableArray<ContactBusEntity *> * listContactsBuffer;
    NSMutableArray<ContactBusEntity *> * listContactsOrigin;
    BOOL contactIsLoaded;
    BOOL contactIsLoadDone;
    BOOL searchIsWaiting;
    NSOperationQueue * search_queue;
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
    self->contactIsLoadDone = NO;
    self->searchIsWaiting = NO;
    
    self->listContactsOrigin = [[NSMutableArray alloc] init];
    self->listContactsBuffer = self->listContactsOrigin;
//    dispatch_queue_attr_t priorityAttribute = dispatch_queue_attr_make_with_qos_class(
//        DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -1
//    );
//    self.contactChangedObservable = [[DataBinding alloc] initWithValue:^(NSArray *){}];
    self->search_queue = [NSOperationQueue new];
    self->search_queue.maxConcurrentOperationCount = 1;
    
     __weak ContactBus * weakSelf = self;
    [self->_contactAdapter.contactChangedObservable binding:^(NSNumber * changed) {
        
        [self getContactBatchStartWith:0 batchSize:self->currentIndexBatch completion:^(NSArray<ContactBusEntity *> * listUpdatedContact, NSError * error) {
            if (!error) {
                if (weakSelf.contactChangedObservable) {
                    weakSelf.contactChangedObservable(listUpdatedContact);
                }
            }
        }];
    }];
    return self;
}

- (void)getContactBatchStartWith:(int)index
                       batchSize: (int) batchSize
                      completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    int batchSizeNeeded = (index + batchSize) >= self->listContactsBuffer.count ?  (int)self->listContactsBuffer.count - index : batchSize;
    
    NSMutableArray * batch = [[NSMutableArray alloc] init];
    
    for (int i = index; i < index + batchSizeNeeded; i++) {
        [batch addObject:self->listContactsBuffer[i]];
    }
    
//    NSArray* batch = [self->listContactsBuffer subarrayWithRange:NSMakeRange(index, batchSizeNeeded)];
    
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

- (void)loadContacts:(void (^)(NSError *, BOOL isDone))handler {
    [self->_contactAdapter loadContacts: self->busBatchSize
                             completion:^(NSArray<ContactDAL *> * listContactRequestedInfor, NSError * error, BOOL isDone) {
        if (error) {
            handler(error, YES);
            [Logging exeption:error.localizedDescription];
        } else {
            NSArray * listContactBusEntities = [listContactRequestedInfor map:^ContactBusEntity * _Nonnull(ContactDAL * _Nonnull obj) {
                return [[ContactBusEntity alloc] initWithData:obj];
            }];
            [self->listContactsOrigin addObjectsFromArray: listContactBusEntities];
            self->contactIsLoaded = YES;
            handler(nil, isDone);
            self->contactIsLoadDone = isDone;
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
    
    if (self->currentIndexBatch >= self->listContactsBuffer.count)
        return;
    
    int gap = (int)self->listContactsBuffer.count - self->currentIndexBatch;
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

- (void)searchContactByName:(NSString *)name completion:(void (^)(void))handler {
    
//    Clean queue
    self->searchIsWaiting = NO;
    self->search_queue.suspended = YES;
    [self->search_queue cancelAllOperations];
    self->search_queue.suspended = NO;
    
    self->searchIsWaiting = NO;
    
    [self->search_queue addOperationWithBlock: ^{
        self->currentIndexBatch = 0;
        
        if ([name isEqualToString:@""]) {
            self->listContactsBuffer = self->listContactsOrigin;
            handler();
            return;
        }
        
        self->searchIsWaiting = YES;
        int i = 0;
        self->listContactsBuffer = [[NSMutableArray alloc] init];
        
        while ((i < self->listContactsOrigin.count || !self->contactIsLoadDone) && self->searchIsWaiting) {
            NSLog(@"%@", name);
            if (i < self->listContactsOrigin.count) {
                ContactBusEntity * contact = self->listContactsOrigin[i];
                NSString * contactName = [NSString stringWithFormat:@"%@ %@", contact.givenName, contact.familyName];
                
                if ([name isEqualToString:@""] || [[contactName lowercaseString] hasPrefix:[name lowercaseString]]) {    
                    [self->listContactsBuffer addObject:contact];
                }
                
                if ((self->listContactsBuffer.count == self->busBatchSize || i == self->listContactsOrigin.count - 1) && self->searchIsWaiting) {
                    handler();
                }
                i++;
            }
        }
    }];
}

- (void)getAllContacts:(BOOL)isDetail completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    if (!self->contactIsLoaded) {
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"Contacts have not load yet"};
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:2 userInfo:userInfo];
        handler(nil, error);
        return;
    }
    
    if (isDetail) {
        [self getContactBatchWithContacts:self->listContactsBuffer completion:handler];
    } else {
        handler(self->listContactsBuffer, nil);
    }
}

@end
