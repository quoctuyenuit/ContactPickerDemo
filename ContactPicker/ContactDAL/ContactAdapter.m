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

- (ContactDAL *)_parseToContactDAL: (CNContact *) contact;
- (void)contactDidChangedEvent: (NSNotification *) notification;

#if DUMMY_DATA_ENABLE
- (NSArray<ContactDAL *> *) _createDummyDataWithSize:(NSUInteger) size;
#endif

@end

@implementation ContactAdapter

@synthesize contactChangedObservable;

- (NSArray *)fetchRequest {
    return @[CNContactIdentifierKey,
    CNContactGivenNameKey,
    CNContactFamilyNameKey,
    CNContactEmailAddressesKey,
    CNContactPhoneNumbersKey];
}

- (id) init {
    _loadContactQueue = dispatch_queue_create("[Adapter] background queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _responseLoadContactQueue = dispatch_queue_create("[Adapter] response queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _loadImageQueue = dispatch_queue_create("[Adapter] background queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _responseLoadImageQueue = dispatch_queue_create("[Adapter] response queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    
    _loadInProcessing       = NO;
    _loadImageInProcessing  = NO;
    _loadContactRequest         = [[NSMutableArray alloc] init];
    _loadContactImageRequest    = [[NSMutableArray alloc] init];
    
    contactChangedObservable   = [[DataBinding alloc] initWithValue: nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(contactDidChangedEvent:) name:CNContactStoreDidChangeNotification
                                             object:nil];
    
    return self;
}

#pragma mark - Listen ContactDidChanged method
- (void) contactDidChangedEvent: (NSNotification *) notification {
    contactChangedObservable.value = [NSNumber numberWithInt:[self->contactChangedObservable.value intValue] + 1];
}

#pragma mark - Protocols methods
- (void)requestPermission:(void (^)(BOOL, NSError * _Nullable)) block {
    NSAssert(block, @"block is nil");
#if DEBUG_PERMISSION_DENIED
    block(NO, nil);
    return;
#endif
    CNContactStore *addressBook = [[CNContactStore alloc] init];
    [addressBook requestAccessForEntityType:CNEntityTypeContacts
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        block(granted, error);
    }];
}

- (void)loadContactsWithBlock:(void (^)(NSArray<id<ContactDALProtocol>> *, NSError *))block {
    NSAssert(block, @"block is nil");
    LogAdapter(@"[%@]Requested", LOAD_HEADER);
    
#if DEBUG_EMPTY_CONTACT
    NSError * error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contacts"];
    block(nil, error);
    return;
#endif
    
#if DEBUG_FAILT_LOAD
    NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeFailt localizeString:@"Load failt"];
    block(nil, error);
    return;
#endif
    
    weak_self
    dispatch_sync(_responseLoadContactQueue, ^{
        strong_self
        if (strongSelf) {
            [strongSelf.loadContactRequest addObject:block];
            
            if (!strongSelf.loadInProcessing) {
                strongSelf->_loadInProcessing = YES;
                [strongSelf _excuteLoadContactsWithBlock: block];
            } else {
                LogAdapter(@"[%@]Wait from other", LOAD_HEADER);
                return;
            }
        } else {
            NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeFailt localizeString:@"Load failt"];
            block(nil, error);
        }
    });
}

- (void)loadContactById:(NSString *)identifier block:(AdapterResponseContactBlock)block {
    NSAssert(block, @"block is nil");
    NSAssert(identifier != nil && ![identifier isEqualToString:@""], @"invalid identifier");
    
    weak_self
    dispatch_async(_loadContactQueue, ^{
        strong_self
        if (strongSelf) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch        = strongSelf.fetchRequest;
            CNContact *contact          = [addressBook unifiedContactWithIdentifier: identifier
                                                                        keysToFetch:keysToFetch
                                                                              error:nil];
            if (!contact) {
                NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeNotFound localizeString:[NSString stringWithFormat: @"Dont have contact with identifier: %@", identifier]];
                block(nil, error);
            } else {
                ContactDAL * dalEntity = [strongSelf _parseToContactDAL:contact];
                block(dalEntity, nil);
            }
        }
    });
}

- (void)loadContactsByBatch:(NSArray<NSString *> *)identifiers block:(AdapterResponseListBlock)block {
    NSAssert(block, @"block is nil");
    NSAssert(identifiers, @"identifiers is nil");
    
    if (identifiers.count == 0) {
        NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contacts"];
        
        block(nil, error);
        return;
    }
    
    weak_self
    dispatch_async(_loadContactQueue, ^{
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
            
            block(result, error);
        }
    });
}

- (void)loadContactImagesWithBlock:(AdapterResponseListImageBlock)block {
    NSAssert(block, @"block is nil");
    LogAdapter(@"[%@]Requested", LOAD_IMAGE_HEADER);
    weak_self
    dispatch_sync(_responseLoadImageQueue, ^{
        strong_self
        if (strongSelf) {
            [strongSelf.loadContactImageRequest addObject:block];
            
            if (!strongSelf.loadImageInProcessing) {
                strongSelf->_loadImageInProcessing = YES;
                [strongSelf _excuteLoadContactImagesWithBlock:block];
            } else {
                LogAdapter(@"[%@]Wait from other", LOAD_IMAGE_HEADER);
                return;
            }
        } else {
            NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeFailt localizeString:@"Load failt"];
            block(nil, error);
        }
    });
}

- (void)getImageById:(NSString *)identifier block:(void (^)(NSData *imageData, NSError * error))block {
    NSAssert(block, @"block is nil");
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
                block(nil, error);
            } else if (contact.imageDataAvailable) {
                block(contact.thumbnailImageData, nil);
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

- (void)_excuteLoadContactImagesWithBlock:(AdapterResponseListImageBlock)block {
    NSAssert(block != nil, @"block is nil");
    weak_self
    dispatch_async(_loadImageQueue, ^{
        LogAdapter(@"[%@]Begin excute", LOAD_IMAGE_HEADER);
#if TEST_STRESS
        [NSThread sleepForTimeInterval:3];
#endif
        strong_self
        if (strongSelf) {
            NSMutableDictionary *result   = [[NSMutableDictionary alloc] init];
            CNContactStore *addressBook         = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch                = @[CNContactIdentifierKey,
                                                    CNContactImageDataAvailableKey,
                                                    CNContactThumbnailImageDataKey];
            
            CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
            [addressBook enumerateContactsWithFetchRequest:fetchRequest
                                                     error:nil
                                                usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                if (contact.imageDataAvailable) {
                    [result setObject:contact.thumbnailImageData forKey:contact.identifier];
                }
            }];
            
            NSError * error = nil;
            if (result.count == 0) {
                error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contact images"];
            }
            
            dispatch_sync(strongSelf->_responseLoadImageQueue, ^{
                strong_self
                if (strongSelf) {
                    for (AdapterResponseListImageBlock block in strongSelf.loadContactImageRequest) {
                        block(result, error);
                    }
                    [strongSelf.loadContactImageRequest removeAllObjects];
                    strongSelf->_loadImageInProcessing = NO; //Load done
                    LogAdapter(@"[%@]Dispatched result", LOAD_IMAGE_HEADER);
                }
            });
        } else {
            NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeFailt localizeString:@"Load failt"];
            block(nil, error);
        }
    });
}

- (void)_excuteLoadContactsWithBlock:(void (^)(NSArray<id<ContactDALProtocol>> *, NSError *))block {
    weak_self
    dispatch_async(_loadContactQueue, ^{
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
            
            dispatch_sync(strongSelf->_responseLoadContactQueue, ^{
                strong_self
                NSError * inError = error;
                if (strongSelf) {
                    for (AdapterResponseListBlock block in strongSelf.loadContactRequest) {
                        block(listContacts, inError);
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

@end
