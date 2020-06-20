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
#import "ContactDALProtocol.h"


#define DEBUG_EMPTY_CONTACT 0
#define DEBUG_FAILT_LOAD    0
#define DUMMY_DATA_ENABLE   1
#define NUMBER_OF_DUMMY     10000


@interface ContactAdapter() {
    NSCache                     * _imageCache;
    NSCache                     * _contactCache;
    dispatch_queue_t              _background_queue;
}

- (ContactDAL *)parseToContactDAL: (CNContact *) contact forID: (NSString *) identifier;
- (void)contactDidChangedEvent: (NSNotification *) notification;

#if DUMMY_DATA_ENABLE
- (void)createDummyDataByBatch: (int) number batchSize: (int) size delegate: (void (^)(NSArray<ContactDAL *> *)) handler;
#endif

@end

@implementation ContactAdapter

@synthesize contactChangedObservable;

- (id) init {
    _imageCache                     = [[NSCache alloc] init];
    _contactCache                   = [[NSCache alloc] init];
    _background_queue               = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    self.contactChangedObservable   = [[DataBinding alloc] initWithValue: nil];
    
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
- (void)requestPermission:(void (^)(BOOL, NSError * _Nullable)) handler {
    if ([CNContactStore class]) {
        CNContactStore *addressBook = [[CNContactStore alloc] init];
        [addressBook requestAccessForEntityType:CNEntityTypeContacts
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
            handler(granted, error);
        }];
    } else {
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
        NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
        handler(NO, error);
    }
}

- (void)loadContactsWithBatchSize:(int) batchSize
                       completion:(void (^)(NSArray<id<ContactDALProtocol>> *, NSError *, BOOL))handler {
    
    dispatch_async(_background_queue, ^{
#if DEBUG_EMPTY_CONTACT
        handler(@[], nil, YES);
        return;
#endif
        
#if DEBUG_FAILT_LOAD
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
        NSError * error         = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
        handler(nil, error, YES);
        return;
#endif
        
        dispatch_queue_attr_t priorityAttribute = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -1);
        dispatch_queue_t callBackQueue          = dispatch_queue_create("response_batch", priorityAttribute);
        NSMutableArray *listContacts            = [[NSMutableArray alloc] init];
        
        if ([CNContactStore class]) {
            
            CNContactStore *addressBook         = [[CNContactStore alloc] init];
            NSArray *keysToFetch                = @[CNContactIdentifierKey,
                                                    CNContactGivenNameKey,
                                                    CNContactFamilyNameKey];
            
            CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
            fetchRequest.sortOrder              = CNContactSortOrderGivenName;
            
            
            [addressBook enumerateContactsWithFetchRequest:fetchRequest
                                                     error:nil
                                                usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                
                [listContacts addObject: [[ContactDAL alloc] initWithID:contact.identifier name:contact.givenName familyName:contact.familyName]];
                
                
                if (listContacts.count >= batchSize) {
                    NSArray * batch = [listContacts copy];
                    [listContacts removeAllObjects];
                    
                    dispatch_async(callBackQueue, ^{
                        handler(batch, nil, NO);
                    });
                }
            }];
            
#if !DUMMY_DATA_ENABLE
            dispatch_async(callBackQueue, ^{
                handler([listContacts copy], nil, YES);
            });
#else
            dispatch_async(callBackQueue, ^{
                handler([listContacts copy], nil, NO);
            });
#endif
            
            
#if DUMMY_DATA_ENABLE

            // Add dummy data
            [self createDummyDataByBatch:NUMBER_OF_DUMMY batchSize:batchSize delegate:^(NSArray<ContactDAL *> * listDummyData) {
                dispatch_async(callBackQueue, ^{
                    handler([listDummyData copy], nil, NO);
                });
            }];
            
            dispatch_async(callBackQueue, ^{
                handler(@[], nil, YES);
            });
#endif
            
        } else {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
            NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
            handler(nil, error, YES);
        }
    });
}


- (void)loadContactById:(NSString *)identifier isReload:(BOOL) isReload completion:(void (^)(id<ContactDALProtocol>, NSError *))handler {
    dispatch_async(_background_queue, ^{
        
        if (!isReload) {
            ContactDAL *contactInCache = [self->_contactCache objectForKey:identifier];
            if (contactInCache) {
                handler(contactInCache, nil);
                return;
            }
        }
        
        if ([CNContactStore class]) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch        = @[CNContactGivenNameKey,
                                            CNContactPhoneNumbersKey,
                                            CNContactFamilyNameKey,
                                            CNContactEmailAddressesKey];
            
            CNContact* contact          = [addressBook unifiedContactWithIdentifier: identifier
                                                                        keysToFetch:keysToFetch
                                                                              error:nil];
            
            if (!contact) {
                NSDictionary * userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"Dont have contact with identifier: %@", identifier]};
                NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
                handler(nil, error);
            } else {
                handler([self parseToContactDAL:contact forID: identifier], nil);
            }
            
        } else {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
            NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
            handler(nil, error);
        }
    });
}

- (void)loadDetailContactByBatch:(NSArray<NSString *> *)listIdentifiers
                        isReload: (BOOL) isReload
                      completion:(void (^)(NSArray<id<ContactDALProtocol>> *, NSError *))handler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableArray * identifiersNeedLoad    = [[NSMutableArray alloc] init];
        NSMutableArray * results                = [[NSMutableArray alloc] init];
        
        if (!isReload) {
            //        Check if cache have this contact then just take it.
            for (NSString * identifier in listIdentifiers) {
                ContactDAL *contactInCache = [self->_contactCache objectForKey:identifier];
                if (contactInCache) {
                    [results addObject:contactInCache];
                } else {
                    [identifiersNeedLoad addObject:identifier];
                }
            }
            
            if (identifiersNeedLoad.count == 0) {
                handler(results, nil);
                return;
            }
            
        } else
            identifiersNeedLoad = [[NSMutableArray alloc] initWithArray: listIdentifiers];
        
        // Load contact from CNContactStore
        if ([CNContactStore class]) {
            CNContactStore *addressBook     = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch            = @[CNContactGivenNameKey,
                                                CNContactFamilyNameKey,
                                                CNContactPhoneNumbersKey,
                                                CNContactEmailAddressesKey,
                                                CNContactImageDataAvailableKey,
                                                CNContactImageDataKey,
                                                CNContactThumbnailImageDataKey];
            
            NSPredicate* predicate          = [CNContact predicateForContactsWithIdentifiers:identifiersNeedLoad];
            NSArray<CNContact*> * contacts  = [addressBook unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:nil];
            
            NSArray * listContactLoaded     = [contacts map:^ContactDAL* _Nonnull(CNContact*  _Nonnull obj) {
                return [self parseToContactDAL:obj forID:obj.identifier];
            }];
            
            [results addObjectsFromArray:listContactLoaded];
            handler(results, nil);
        } else {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
            NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
            handler(nil, error);
        }
        
    });
}

- (void)getImageById:(NSString *)identifier isReload: (BOOL) isReload completion:(void (^)(NSData *, NSError * error))handler {
    
    dispatch_async(_background_queue, ^{
        if (!isReload) {
            NSData * imageData = [self->_imageCache objectForKey:identifier];
            if (imageData) {
                handler(imageData, nil);
                return;
            }
        }
        
        if ([CNContactStore class]) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            
            NSArray *keysToFetch        = @[CNContactImageDataKey,
                                            CNContactImageDataAvailableKey,
                                            CNContactThumbnailImageDataKey];
            
            CNContact* contact = [addressBook unifiedContactWithIdentifier: identifier
                                                               keysToFetch:keysToFetch
                                                                     error:nil];
            if (!contact) {
                NSDictionary * userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"Dont have contact with identifier: %@", identifier]};
                NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
                handler(nil, error);
            } else {
                if (contact.imageDataAvailable) {
                    [self->_imageCache setObject:contact.imageData forKey:identifier];
                    handler(contact.imageData, nil);
                }
            }
            
        } else {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
            NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
            handler(nil, error);
        }
    });
}

#pragma mark Helper methods
- (ContactDAL *)parseToContactDAL:(CNContact *)contact
                            forID: (NSString *) identifier {
    NSString * contactId                        = contact.identifier;
    NSString * givenName                        = contact.givenName;
    NSString * familyName                       = contact.familyName;
    NSMutableArray<NSString*> *phoneNumbers     = [[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"];
    NSMutableArray<NSString*> *emails           = [contact.emailAddresses valueForKey:@"value"];
    
    NSData * imageData                          = nil;
    if (contact.imageDataAvailable) {
        imageData                               = contact.imageData;
    }
    
    ContactDAL *contactDAL = [[ContactDAL alloc] initWithIdentifier:contactId
                                                               name:givenName
                                                         familyName:familyName
                                                             phones:phoneNumbers
                                                             emails:emails
                                                          imageData:imageData];
    
    [self->_contactCache setObject:contactDAL forKey:contactDAL.identifier];
    
    return contactDAL;
    
}

#pragma mark - Create Dummy Data methods

#if DUMMY_DATA_ENABLE
- (void)createDummyDataByBatch:(int)number batchSize:(int) size delegate:(void (^)(NSArray<ContactDAL *> *))handler {
    int i = 0;
    while (i < number) {
        int batchSize = i + size > number ? number - i : size;
        i += batchSize;
        NSArray * batch = [self createDummyDataWithSize:batchSize];
        handler(batch);
    }
}

- (NSArray<ContactDAL *> *) createDummyDataWithSize:(NSUInteger) size {
    NSMutableArray * dummyData = [[NSMutableArray alloc] init];
    static int nameIndex = 0;
    for (int i = 0; i < size; i++ ) {
        NSString * identifier = [[NSProcessInfo processInfo] globallyUniqueString];
        ContactDAL * dummyContact = [[ContactDAL alloc] initWithID:identifier name:[NSString stringWithFormat:@"%d dummy data", nameIndex++] familyName:@""];
        
        [self->_contactCache setObject:dummyContact forKey: identifier];
        [dummyData addObject:dummyContact];
    }
    
    return dummyData;
}
#endif

@end
