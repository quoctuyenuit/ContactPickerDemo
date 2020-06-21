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
#import "Utilities.h"

#define DEFAULT_BATCH_SIZE      100

@interface ContactBus()
- (void)setupEvents;
- (NSArray *)getIdentifiersFrom:(int) indexStart count:(int) count;
@end

@implementation ContactBus {
    int                                     _busBatchSize;
    int                                     _numberContactHadLoaded;
    BOOL                                    _loadingState;
    BOOL                                    _contactLoadDone;
    BOOL                                    _searchingReady;
    NSMutableArray<ContactDAL *>           *_listContactsBuffer;
    NSMutableArray<ContactDAL *>           *_listContacts;
    dispatch_once_t                         _dispatchOnceToken;
    dispatch_queue_t                        _backgroundQueue;
    dispatch_queue_t                        _searchQueue;
    dispatch_queue_t                        _searchResponseQueue;
}

@synthesize contactChangedObservable;

- (instancetype)initWithAdapter:(id<ContactAdapterProtocol>)adapter {
    return [self initWithAdapter:adapter batchSize:DEFAULT_BATCH_SIZE];
}

- (id)initWithAdapter:(id<ContactAdapterProtocol>)adapter batchSize:(int)batchSize {
    _contactAdapter             = adapter;
    _busBatchSize               = batchSize;
    _numberContactHadLoaded     = 0;
    _loadingState               = NO;
    _contactLoadDone            = NO;
    _searchingReady             = YES;
    _listContacts               = [[NSMutableArray alloc] init];
    _listContactsBuffer         = _listContacts;
    _backgroundQueue            = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    _searchQueue                = dispatch_queue_create("ContactBus search queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _searchResponseQueue        = dispatch_queue_create("ContactBus search queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    
    [self setupEvents];
    return self;
}

#pragma mark - Protocol methods
- (void)requestPermission:(void (^)(BOOL, NSError *))handler {
    [self->_contactAdapter requestPermission:handler];
}

- (void)loadContacts:(void (^)(NSError *, BOOL, NSUInteger))handler {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(_backgroundQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            
            [strongSelf->_contactAdapter loadContactsWithBatchSize:strongSelf->_busBatchSize
                                                        completion:^(NSArray<ContactDAL *> * listContactRequestedInfor, NSError * error, BOOL isDone) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(error, YES, 0);
                    });
                    [Logging exeption:error.localizedDescription];
                } else {
                    [strongSelf->_listContacts addObjectsFromArray:listContactRequestedInfor];
                    strongSelf->_contactLoadDone = isDone;
                    dispatch_once(&strongSelf->_dispatchOnceToken, ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handler(nil, isDone, listContactRequestedInfor.count);
                        });
                    });
                }
            }];
        }
    });
}

- (void)loadContactById:(NSString *)identifier
               isReload:(BOOL) isReload
             completion:(void (^)(ContactBusEntity *, NSError *))handler {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(_backgroundQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf->_contactAdapter loadContactById:identifier isReload: isReload completion:^(ContactDAL * contactDAL, NSError * error) {
                handler([[ContactBusEntity alloc] initWithData:contactDAL], error);
            }];
        }
    });
}

- (void)loadBatchOfDetailedContacts:(NSArray<NSString *> *)identifiers
                           isReload:(BOOL) isReload
                         completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_backgroundQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            
            [strongSelf->_contactAdapter loadDetailContactByBatch:identifiers isReload: isReload completion:^(NSArray<ContactDAL*> * listContacts, NSError * error) {
                if (error) {
                    handler(nil, error);
                } else {
                    NSArray* listContactBusEntitys = [listContacts map:^ContactBusEntity* _Nonnull(ContactDAL*  _Nonnull obj) {
                        return [[ContactBusEntity alloc] initWithData:obj];
                    }];
                    
                    handler([listContactBusEntitys copy], nil);
                }
            }];
        }
    });
}

- (void)loadContactByBatch:(int)numberOfContact completion:(void (^)(NSArray<ContactBusEntity *> *, NSError *))handler {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_backgroundQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {

            if (strongSelf->_loadingState || strongSelf->_numberContactHadLoaded >= strongSelf->_listContactsBuffer.count) {
                [Logging info:@"[LoadContact] _listContacts have 0 elements"];
                NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"contact didnt have loaded yet"};
                NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
                handler(nil, error);
                return;
            }
            strongSelf->_loadingState = YES;
            NSArray * identifiers = [self getIdentifiersFrom:strongSelf->_numberContactHadLoaded count:numberOfContact];
            
            [self loadBatchOfDetailedContacts:identifiers isReload:NO completion:^(NSArray<ContactBusEntity *> * contacts, NSError * error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    if (error) {
                        handler(nil, error);
                    } else {
                        strongSelf->_numberContactHadLoaded += contacts.count;
                        handler(contacts, nil);
                    }
                    strongSelf->_loadingState = NO;
                }
            }];
        }
    });
}

- (void)getImageFromId:(NSString *)identifier isReload:(BOOL) isReload completion:(void (^)(NSData * imageData, NSError * error))handler {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_backgroundQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf->_contactAdapter getImageById:identifier isReload:(BOOL) isReload completion:handler];
        }
    });
}

- (void)searchContactByName:(NSString *)name block:(void (^)(void))handler {
    _searchingReady = NO;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_searchQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->_searchingReady = YES;
            strongSelf->_numberContactHadLoaded = 0;
            
            if ([name isEqualToString:@""]) {
                strongSelf->_listContactsBuffer = strongSelf->_listContacts;
                handler();
                return;
            }
            
            strongSelf->_listContactsBuffer = [[NSMutableArray alloc] init];
            
            int i = 0;
            while (strongSelf->_searchingReady  && i < strongSelf->_listContacts.count) {
                ContactDAL * contact = [strongSelf->_listContacts objectAtIndex:i];
                if ([contact.fullName hasPrefixLower:name]) {
//                    handler();
                    [strongSelf->_listContactsBuffer addObject:contact];
                }
                i++;
            }
            handler();
        }
    });
}

#pragma mark - Helper methods
- (void)setupEvents {
    __weak ContactBus * weakSelf   = self;
    [self->_contactAdapter.contactChangedObservable binding:^(NSNumber * changed) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSArray * identifiers = [strongSelf getIdentifiersFrom:0 count: strongSelf->_numberContactHadLoaded];
            [strongSelf loadBatchOfDetailedContacts:identifiers isReload:YES completion:^(NSArray<ContactBusEntity *> * updatedContacts, NSError * error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (error || !strongSelf) {
                    [Logging error:@"Cannot load contacts after contact changed events"];
                } else {
                    strongSelf.contactChangedObservable(updatedContacts);
                }
            }];
        }
    }];
}

- (NSArray *)getIdentifiersFrom:(int)indexStart count:(int)count {
    count = indexStart + count > _listContactsBuffer.count ? (int)_listContactsBuffer.count - indexStart : count;
    NSArray * contactNeed = [_listContactsBuffer subarrayWithRange:NSMakeRange(indexStart, count)];
    return [contactNeed map:^NSString * _Nonnull(ContactDAL * _Nonnull obj) {
        return obj.identifier;
    }];
}

@end
