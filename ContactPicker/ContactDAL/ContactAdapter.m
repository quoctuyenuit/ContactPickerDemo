//
//  ContactAdapter.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactAdapter.h"
#import <Contacts/Contacts.h>
#import "Utilities.h"
#import "ContactDefine.h"
#import "ContactDALProtocol.h"
#import "ImageManager.h"
#import "NSErrorExtension.h"

#define ADAPTER_ERROR_DOMAIN            @"AdapterError"
#define DEBUG_TIME_GET_IMAGE            0
#define TEST_STRESS                     0
#define LOG_ADAPTER                     0
#if LOG_ADAPTER
#define LogAdapter(...)                 NSLog(__VA_ARGS__)
#define LOAD_HEADER                     @"LoadContact"
#define LOAD_IMAGE_HEADER               @"LoadImages"
#else
#define LogAdapter(...)
#endif

#define CHECK_RETAINCYCLE               0
#if CHECK_RETAINCYCLE
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#endif



@interface ContactAdapter()
@property(nonatomic) dispatch_queue_t   internalSerialQueue;
@property(nonatomic) dispatch_queue_t   requestQueue;
@property(nonatomic) dispatch_queue_t   responseQueue;

@property(nonatomic) BOOL       loadInProcessing;
@property(nonatomic) NSArray*   fetchRequest;

@property(nonatomic) NSMutableArray<AdapterResponseListBlock> * loadContactRequest;

- (ContactDAL *)_parseToContactDAL: (CNContact *) contact;
- (void)_contactDidChangedEvent: (NSNotification *) notification;

#if DUMMY_DATA_ENABLE
- (NSArray<ContactDAL *> *) _createDummyDataWithSize:(NSUInteger) size;
#endif

@end

@implementation ContactAdapter

- (NSArray *)fetchRequest {
    return @[CNContactIdentifierKey,
    CNContactGivenNameKey,
    CNContactFamilyNameKey,
    CNContactEmailAddressesKey,
    CNContactPhoneNumbersKey];
}

- (id) init {
    _internalSerialQueue    = dispatch_queue_create("[Adapter] background queue",
                                                 dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                         QOS_CLASS_BACKGROUND, 0));
    _requestQueue           = dispatch_queue_create("[Adapter] response queue",
                                          dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                  QOS_CLASS_BACKGROUND, 0));
    _responseQueue          = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    _loadInProcessing           = NO;
    _loadContactRequest         = [[NSMutableArray alloc] init];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(_contactDidChangedEvent:) name:CNContactStoreDidChangeNotification
                                             object:nil];
    return self;
}

#pragma mark - Listen ContactDidChanged method
- (void)_contactDidChangedEvent: (NSNotification *) notification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contactDidChangeWithAdapter:)]) {
        [self.delegate contactDidChangeWithAdapter:self];
    }
}

#pragma mark - Protocols methods
- (void)requestPermission:(void (^)(BOOL, NSError * _Nullable)) block onQueue:(dispatch_queue_t)queue {
    NSAssert(block, @"block is nil");
    if (!block) {
        return;
    }
    if (!queue) {
        queue = _responseQueue;
    }
#if DEBUG_PERMISSION_DENIED
    block(NO, nil);
    return;
#endif
    CNContactStore *addressBook = [[CNContactStore alloc] init];
    [addressBook requestAccessForEntityType:CNEntityTypeContacts
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(queue, ^{
            block(granted, error);
        });
    }];
}

- (void)loadContactsWithBlock:(void (^)(NSArray<id<ContactDALProtocol>> *, NSError *))block onQueue:(dispatch_queue_t)queue {
    NSAssert(block, @"block is nil");
    if (!block) {
        return;
    }
    
    if (!queue) {
        queue = _responseQueue;
    }
//============================================================
//    Debug mode
//------------------------------------------------------------
#if DEBUG_EMPTY_CONTACT
    NSError * error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contacts"];
    dispatch_async(queue, ^{
        block(nil, error);
    });
    return;
#endif
    
#if DEBUG_FAILT_LOAD
    NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeFailt localizeString:@"Load failt"];
    dispatch_async(queue, ^{
        block(nil, error);
    });
    return;
#endif
//============================================================
    weak_self
    dispatch_async(_requestQueue, ^{
        if (weakSelf) {
            [weakSelf.loadContactRequest addObject:block];
            
            if (!weakSelf.loadInProcessing) {
                weakSelf.loadInProcessing = YES;
                [weakSelf _excuteLoadContactsWithBlock: block onQueue:queue];
                return;
            }
            LogAdapter(@"[%@]Wait from other", LOAD_HEADER);
        }
    });
}

- (void)loadContactsByBatch:(NSArray<NSString *> *)identifiers block:(AdapterResponseListBlock)block onQueue:(dispatch_queue_t)queue {
    NSAssert(block, @"block is nil");
    NSAssert(identifiers, @"identifiers is nil");
    if (!block || !identifiers) {
        return;
    }
    
    if (!queue) {
        queue = _responseQueue;
    }
    
    if (identifiers.count == 0) {
        NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contacts"];
        
        dispatch_async(queue, ^{
            block(nil, error);
        });
        return;
    }
    
    weak_self
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        strong_self
        if (strongSelf) {
            CNContactStore *addressBook     = [[CNContactStore alloc] init];
            NSArray *keysToFetch            = strongSelf.fetchRequest;
            
            NSPredicate* predicate          = [CNContact predicateForContactsWithIdentifiers:identifiers];
            NSArray<CNContact*> * contacts  = [addressBook unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:nil];
            NSError * error = nil;
            if (contacts.count == 0) {
                error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contacts"];
            }
            
            NSArray * result = [contacts map:^ContactDAL* _Nonnull(CNContact*  _Nonnull obj) {
                return [self _parseToContactDAL:obj];
            }];
            
            dispatch_async(queue, ^{
                block(result, error);
            });
        }
    });
}

- (void)loadImageWithIdentifier:(NSString *)identifier block:(void (^)(NSData *imageData, NSError * error))block onQueue:(dispatch_queue_t)queue {
    NSAssert(block, @"block is nil");
    if (!block) {
        return;
    }
    
    if (!queue) {
        queue = _responseQueue;
    }
    
    weak_self
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        strong_self
        if (strongSelf) {
#if DEBUG_TIME_GET_IMAGE
            NSDate *start = [NSDate date];
#endif
            
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch        = @[CNContactImageDataAvailableKey,
                                            CNContactThumbnailImageDataKey];
            
            CNContact* contact = [addressBook unifiedContactWithIdentifier: identifier
                                                               keysToFetch:keysToFetch
                                                                     error:nil];
            if (!contact) {
                NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeNotFound localizeString:[NSString stringWithFormat: @"Dont have contact with identifier: %@", identifier]];
                dispatch_async(queue, ^{
                    block(nil, error);
                });
            } else if (contact.imageDataAvailable) {
                dispatch_async(queue, ^{
                    block(contact.thumbnailImageData, nil);
                });
            }
#if DEBUG_TIME_GET_IMAGE
            NSDate *end = [NSDate date];
            DebugLog(@"Get image time: (id, time) = (%@, %f)", identifier, [end timeIntervalSinceDate:start]);
#endif
        }
    });
}

#pragma mark Helper methods
- (ContactDAL *)_parseToContactDAL:(CNContact *)contact {
    NSAssert(contact, @"Contact is nil");
    
    NSString * contactId                        = contact.identifier;
    NSString * givenName                        = contact.givenName;
    NSString * familyName                       = contact.familyName;
    NSMutableArray<NSString*> *phoneNumbers     = [[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"];
    NSMutableArray<NSString*> *emails           = [contact.emailAddresses valueForKey:@"value"];
    
    ContactDAL *contactDAL = [[ContactDAL alloc] initWithIdentifier:contactId
                                                               name:givenName
                                                         familyName:familyName
                                                             phones:phoneNumbers
                                                             emails:emails];
    return contactDAL;
}

- (void)_excuteLoadContactsWithBlock:(void (^)(NSArray<id<ContactDALProtocol>> *, NSError *))block onQueue:(dispatch_queue_t)queue {
    weak_self
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        LogAdapter(@"[%@]Begin excute", LOAD_HEADER);
#if TEST_STRESS
        [NSThread sleepForTimeInterval:3];
#endif
        strong_self
        if (strongSelf) {
            NSMutableArray *listContacts        = [[NSMutableArray alloc] init];
            CNContactStore *addressBook         = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch                = strongSelf.fetchRequest;
            CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
            //        fetchRequest.sortOrder              = CNContactSortOrderGivenName;
            
            [addressBook enumerateContactsWithFetchRequest:fetchRequest
                                                     error:nil
                                                usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                
                [listContacts addObject: [strongSelf _parseToContactDAL:contact]];
            }];
            
#if DUMMY_DATA_ENABLE
            [listContacts addObjectsFromArray: [strongSelf _createDummyDataWithSize:NUMBER_OF_DUMMY]];
#endif
            
            NSError * error = nil;
            if (listContacts.count == 0) {
                error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contacts"];
            }
            
            dispatch_async(strongSelf->_requestQueue, ^{
                strong_self
                NSError * inError = error;
                if (strongSelf) {
                    for (AdapterResponseListBlock block in strongSelf.loadContactRequest) {
                        dispatch_async(queue, ^{
                            block(listContacts, inError);
                        });
                    }
                    [strongSelf.loadContactRequest removeAllObjects];
                    strongSelf->_loadInProcessing = NO; //Load done
                    LogAdapter(@"[%@]Dispatched result", LOAD_HEADER);
                } else {
                    NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeFailt localizeString:@"Load failt"];
                    block(nil, error);
                }
            });
        } else {
            NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeFailt localizeString:@"Load failt"];
            block(nil, error);
        }
    });
}

#pragma mark - Create Dummy Data methods
#if DUMMY_DATA_ENABLE
- (NSArray<ContactDAL *> *)_createDummyDataWithSize:(NSUInteger) size {
    NSAssert(size > 0, @"Size is negative");
    
    NSMutableArray * dummyData = [[NSMutableArray alloc] init];
    for (int i = 0; i < size; i++ ) {
        NSString * identifier = [[NSProcessInfo processInfo] globallyUniqueString];
        NSString * name = [NSString stringWithFormat:@"%d ", i];
        ContactDAL * dummyContact = [[ContactDAL alloc] initWithIdentifier:identifier
                                                                      name:name
                                                                familyName:@"Dummy"
                                                                    phones:nil
                                                                    emails:nil];
        [dummyData addObject:dummyContact];
    }
    
    return dummyData;
}
#endif

@synthesize delegate;

@end
