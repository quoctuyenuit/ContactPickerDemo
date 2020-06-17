//
//  ContactBus.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactBus.h"
#import "ContactDAL.h"
#import "Utilities.h"
#import "ContactBusEntity.h"
#import <UIKit/UIKit.h>
#import "Logging.h"

@interface ContactBus() {
    int _busBatchSize;
}
@end

@implementation ContactBus

@synthesize currentIndexBatch;

@synthesize contactChangedObservable;

- (id)initWithAdapter:(id<ContactAdapterProtocol>)adapter {
    self->_contactAdapter = adapter;
    self->_busBatchSize = 20;
    self->currentIndexBatch = 0;
    
     __weak ContactBus * weakSelf = self;
    [self->_contactAdapter.contactChangedObservable binding:^(NSNumber * changed) {
        [self loadContacts:^(NSArray<ContactBusEntity *> * listContacts, NSError *error, BOOL isDone) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && !error && strongSelf.contactChangedObservable) {
                strongSelf.contactChangedObservable(listContacts);
            }
        }];
    }];
    return self;
}

#pragma mask Protocol methods

- (void)requestPermission:(void (^)(BOOL, NSError *))handler {
    [self->_contactAdapter requestPermission:handler];
}

- (void)loadContacts:(void (^)(NSArray<ContactBusEntity *> *,  NSError *, BOOL))handler {
    
    [self->_contactAdapter loadContacts: self->_busBatchSize
                             completion:^(NSArray<ContactDAL *> * listContactRequestedInfor, NSError * error, BOOL isDone) {
        if (error) {
            handler(nil, error, YES);
            [Logging exeption:error.localizedDescription];
        }
        else
        {
            NSArray * listContactBusEntities = [listContactRequestedInfor map:^ContactBusEntity * _Nonnull(ContactDAL * _Nonnull obj) {
                return [[ContactBusEntity alloc] initWithData:obj];
            }];
            handler(listContactBusEntities, nil, isDone);
        }
    }];
}

- (void)loadContactById:(NSString *)identifier
               isReload:(BOOL) isReload
             completion:(void (^)(ContactBusEntity *, NSError *))handler {
    
    [self->_contactAdapter loadContactById:identifier isReload: isReload completion:^(ContactDAL * contactDAL, NSError * error) {
        handler([[ContactBusEntity alloc] initWithData:contactDAL], error);
    }];
}

- (void)loadBatchOfDetailedContacts:(NSArray<NSString *> *)identifiers
                           isReload:(BOOL) isReload
                         completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    [self->_contactAdapter loadBatchOfDetailedContacts:identifiers isReload: isReload completion:^(NSArray<ContactDAL*> * listContacts, NSError * error) {
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

- (void)getImageFromId:(NSString *)identifier isReload:(BOOL) isReload completion:(void (^)(NSData * imageData, NSError * error))handler {
    [self->_contactAdapter getImageById:identifier isReload:(BOOL) isReload completion:handler];
}

@end
