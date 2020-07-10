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
#define SEARCH_HEADER                     @"search"

#define LOG_ADAPTER                     0
#if LOG_ADAPTER
#define LogBusiness(...)                 NSLog(__VA_ARGS__)
#else
#define LogAdapter(...)
#endif


#define CHECK_RETAINCYCLE       0
#if CHECK_RETAINCYCLE
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#endif

@interface ContactBusinessLayer() <ContactAdapterDelegate>

@property(nonatomic) id<ContactAdapterProtocol>             contactAdapter;
@property(nonatomic) NSMutableArray<ContactBusEntity *> *   contacts;
@property(nonatomic) BOOL                                   searchReady;

@property(nonatomic) dispatch_queue_t  internalSerialQueue;
@property(nonatomic) dispatch_queue_t  responseQueue;
@property(nonatomic) dispatch_queue_t  searchQueue;

@end

@implementation ContactBusinessLayer

- (instancetype)initWithAdapter:(id<ContactAdapterProtocol>)adapter {
    _contactAdapter             = adapter;
    _contactAdapter.delegate    = self;
    _contacts                   = [[NSMutableArray alloc] init];
    _searchReady                = YES;
    
    _internalSerialQueue        = dispatch_queue_create("ContactBus search queue",
                                                        dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _searchQueue                = dispatch_queue_create("ContactBus search queue",
                                                        dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _responseQueue              = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    return self;
}

#pragma mark - Protocol methods
- (void)requestPermissionWithBlock:(void (^)(BOOL, NSError *))block onQueue:(dispatch_queue_t)queue {
    NSAssert(block, @"handler is nil");
    [self->_contactAdapter requestPermission:block onQueue:queue];
}

- (void)loadContactsWithBlock:(BusinessResponseListBlock)block onQueue:(dispatch_queue_t)queue {
    NSAssert(block, @"block is nil");
    if (!block) {
        return;
    }
    if (!queue) {
        queue = _responseQueue;
    }
    weak_self
    dispatch_async(_internalSerialQueue, ^{
        [weakSelf.contactAdapter loadContactsWithBlock:^(NSArray<id<ContactDALProtocol>> *contacts, NSError *error) {
            strong_self
            if (strongSelf) {
                if (!error) {
                    NSArray<id<ContactBusEntityProtocol>> *businessContacts = [contacts map:^ContactBusEntity * _Nonnull(id<ContactDALProtocol>  _Nonnull contactDAL) {
                        return [[ContactBusEntity alloc] initWithData:contactDAL];
                    }];
                    [strongSelf->_contacts removeAllObjects];
                    [strongSelf->_contacts addObjectsFromArray:businessContacts];
                }
                dispatch_async(queue, ^{
                    block(strongSelf->_contacts, error);
                });
            } else {
                NSError * error = [[NSError alloc] initWithDomain:BUSINESS_ERROR_DOMAIN type:ErrorTypeRetainCycleGone localizeString:@"strongSelf released"];
                dispatch_async(queue, ^{
                    block(nil, error);
                });
            }
        } onQueue:weakSelf.internalSerialQueue];
    });
}

- (void)searchContactByName:(NSString *)name block:(BusinessResponseListBlock)block onQueue:(dispatch_queue_t)queue {
    NSAssert(block, @"block is nil");
    
    if (!block) {
        return;
    }
    if (!queue) {
        queue = _responseQueue;
    }
    if (!name) {
        NSError * error = [[NSError alloc] initWithDomain:BUSINESS_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"name is nil"];
        dispatch_async(queue, ^{
            block(nil, error);
        });
        return;
    }
    
    _searchReady = NO;
    weak_self
    dispatch_async(_searchQueue, ^{
        strong_self
        if (strongSelf) {
            strongSelf->_searchReady = YES;
            if ([name isEqualToString:@""]) {
                dispatch_async(queue, ^{
                    block(strongSelf.contacts, nil);
                });
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
            if (i >= strongSelf.contacts.count && strongSelf.searchReady) {
                dispatch_async(queue, ^{
                    block(result, nil);
                });
            }
        }
    });
}

#pragma mark - ContactAdapterDelegate methods
- (void)contactDidChangeWithAdapter:(id<ContactAdapterProtocol>)adapter {
    weak_self
    dispatch_async(_internalSerialQueue, ^{
        [weakSelf.contactAdapter loadContactsWithBlock:^(NSArray<id<ContactDALProtocol>> *contacts, NSError *error) {
            strong_self
            if (strongSelf) {
                if (!error) {
                    NSArray<ContactBusEntity *> *newContacts = [contacts map:^ContactBusEntity * _Nonnull(id<ContactDALProtocol>  _Nonnull contactDAL) {
                        return [[ContactBusEntity alloc] initWithData:contactDAL];
                    }];
                    
                    NSMutableArray * contactsAdded = [NSMutableArray array];
                    NSMutableArray * contactsRemoved = [NSMutableArray array];
                    NSMutableArray * contactsUpdated = [NSMutableArray array];
                    //------------------------------------------------------------
                    // Check contacts has added and removed
                    //------------------------------------------------------------
                    for (ContactBusEntity * newContact in newContacts) {
                        ContactBusEntity * oldContact = [strongSelf.contacts firstObjectWith:^BOOL(ContactBusEntity * _Nonnull obj) {
                            return [obj.identifier isEqualToString:newContact.identifier];
                        }];
                        
                        if (!oldContact) {
                            [contactsAdded addObject:newContact];
                            [strongSelf.contacts addObject:newContact];
                        } else if (![oldContact isEqualToOther:newContact]) {
                            [oldContact update:newContact];
                            [contactsUpdated addObject:oldContact];
                        }
                    }
                    //------------------------------------------------------------
                    // Check contacts has removed
                    //------------------------------------------------------------
                    for (ContactBusEntity * oldContact in strongSelf.contacts) {
                        if (![newContacts containsObject:oldContact]) {
                            [contactsRemoved addObject:oldContact];
                            [strongSelf.contacts removeObject:oldContact];
                        }
                    }
                    
                    if (strongSelf.delegate &&
                        [strongSelf.delegate respondsToSelector:@selector(contactDidChangedWithBusiness:contactsAdded:contactsRemoved:contactsUpdated:)]) {
                        [strongSelf.delegate contactDidChangedWithBusiness:self
                                                             contactsAdded:contactsAdded
                                                           contactsRemoved:contactsRemoved
                                                           contactsUpdated:contactsUpdated];
                    }
                } else {
                    DebugLog(@"[%@] %@", LOG_MSG_HEADER,error.localizedDescription);
                }
                
                
            } else {
                DebugLog(@"[%@] strongSelf is released from contactChangedObservable", LOG_MSG_HEADER);
            }
        } onQueue:weakSelf.internalSerialQueue];
    });
}

@synthesize delegate;

@end
