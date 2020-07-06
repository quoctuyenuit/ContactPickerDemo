//
//  ContactBus.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactBusinessLayer.h"
#import "ContactDAL.h"
#import "Utilities.h"
#import "ContactBusEntity.h"
#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "ContactDefine.h"
#import "NSErrorExtension.h"

#define BUSINESS_ERROR_DOMAIN   @"BusinessError"

#define CHECK_RETAINCYCLE       0
#if CHECK_RETAINCYCLE
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#endif

@interface ContactBusinessLayer()
- (void)setupEvents;
@end

@implementation ContactBusinessLayer

- (instancetype)initWithAdapter:(id<ContactAdapterProtocol>)adapter {
    _contactAdapter     = adapter;
    _contacts           = [[NSMutableArray alloc] init];
    _loadContactRequest = [[NSMutableArray alloc] init];
    _searchReady        = YES;
    
    _backgroundQueue    = dispatch_queue_create("ContactBus search queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _loadResponseQueue  = dispatch_queue_create("ContactBus search queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _searchQueue        = dispatch_queue_create("ContactBus search queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    
    self.contactDidChangedObservable = [[DataBinding alloc] initWithValue:nil];
    [self setupEvents];
    return self;
}

#pragma mark - Helper methods
- (void)setupEvents {
    __weak ContactBusinessLayer * weakSelf   = self;
    [self->_contactAdapter.contactChangedObservable binding:^(NSNumber * changed) {
        dispatch_async(weakSelf.backgroundQueue, ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                NSArray * identifiers = [strongSelf.contacts map:^NSString * _Nonnull(ContactBusEntity * _Nonnull obj) {
                    return obj.identifier;
                }];
                
                [strongSelf.contactAdapter loadContactsByBatch:identifiers block:^(NSArray<id<ContactDALProtocol>> *contacts, NSError *error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        if (!error) {
                            
                            NSArray<id<ContactBusEntityProtocol>> *businessContacts = [contacts map:^ContactBusEntity * _Nonnull(id<ContactDALProtocol>  _Nonnull contactDAL) {
                                return [[ContactBusEntity alloc] initWithData:contactDAL];
                            }];
                            
                            NSMutableArray * contactNeedUpdate = [[NSMutableArray alloc] init];
                            
                            for (ContactBusEntity * newContact in businessContacts) {
                                ContactBusEntity * oldContact = [strongSelf.contacts firstObjectWith:^BOOL(ContactBusEntity * _Nonnull obj) {
                                    return [obj.identifier isEqualToString:newContact.identifier];
                                }];
                                
                                if (oldContact && ![oldContact isEqualToOther:newContact]) {
                                    [oldContact update:newContact];
                                    [contactNeedUpdate addObject:oldContact];
                                }
                            }
                            
                            strongSelf.contactDidChangedObservable.value = contactNeedUpdate;
                        } else {
                            DebugLog(@"[%@] %@", LOG_MSG_HEADER,error.localizedDescription);
                        }
                    } else {
                        DebugLog(@"[%@] strongSelf is released from contactChangedObservable", LOG_MSG_HEADER);
                    }
                }];
            }
        });
    }];
}

#pragma mark - Protocol methods
- (void)requestPermission:(void (^)(BOOL, NSError *))handler {
    NSAssert(handler, @"handler is nil");
    [self->_contactAdapter requestPermission:handler];
}

- (void)loadContactsWithBlock:(BusinessResponseListBlock)block {
    NSAssert(block, @"block is nil");
    
    weak_self
    dispatch_sync(_loadResponseQueue, ^{
        strong_self
        if (strongSelf) {
            [strongSelf.loadContactRequest addObject:block];
            
            if (strongSelf.loadInProcessing) {
                return;
            }
            strongSelf->_loadInProcessing = YES;
            [strongSelf.contacts removeAllObjects];
        }
    });
    dispatch_async(weakSelf.backgroundQueue, ^{
        [weakSelf.contactAdapter loadContactsWithBlock:^(NSArray<id<ContactDALProtocol>> *contacts, NSError *error) {
            strong_self
            if (strongSelf) {
                if (!error) {
                    NSArray<id<ContactBusEntityProtocol>> *businessContacts = [contacts map:^ContactBusEntity * _Nonnull(id<ContactDALProtocol>  _Nonnull contactDAL) {
                        return [[ContactBusEntity alloc] initWithData:contactDAL];
                    }];
                    
                    [strongSelf->_contacts addObjectsFromArray:businessContacts];
                }
                
                dispatch_async(strongSelf.loadResponseQueue, ^{
                    strong_self
                    if (strongSelf) {
                        for (BusinessResponseListBlock block in strongSelf.loadContactRequest) {
                            //add excute queue
                            block(strongSelf->_contacts, error);
                        }
                        [strongSelf.loadContactRequest removeAllObjects];
                        strongSelf->_loadInProcessing = NO;
                    }
                });
            } else {
                NSError * error = [[NSError alloc] initWithDomain:BUSINESS_ERROR_DOMAIN type:ErrorTypeRetainCycleGone localizeString:@"strongSelf released"];
                block(nil, error);
            }
        }];
    });
   
}

- (void)searchContactByName:(NSString *)name block:(BusinessResponseListBlock)block {
    NSAssert(block, @"block is nil");
    
    if (!name) {
        NSError * error = [[NSError alloc] initWithDomain:BUSINESS_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"name is nil"];
        block(nil, error);
        return;
    }
    
    _searchReady = NO;
    weak_self
    dispatch_sync(_searchQueue, ^{
        strong_self
        if (strongSelf) {
            strongSelf->_searchReady = YES;
            if ([name isEqualToString:@""]) {
                block(strongSelf.contacts, nil);
                return;
            }
            
            NSMutableArray<id<ContactBusEntityProtocol>> *result = [[NSMutableArray alloc] init];
            NSInteger i = 0;
            while (strongSelf.searchReady && i < strongSelf.contacts.count) {
                ContactBusEntity * contact = strongSelf.contacts[i];
                if ([contact compareWithNameQuery:name]) {
                    [result addObject:contact];
                }
                i++;
            }
//            if while statement stop by searching all of contact --> call block
//            if while statement stop by searchReady --> not call block
            if (i >= strongSelf.contacts.count) {
                block(result, nil);
            }
        }
    });
}
@synthesize contactDidChangedObservable;

@end
