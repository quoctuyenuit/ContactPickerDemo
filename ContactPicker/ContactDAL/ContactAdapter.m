//
//  ContactAdapter.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactAdapter.h"
#import <Contacts/Contacts.h>
#import "NSArrayExtension.h"
#import "ContactDALProtocol.h"


@interface ContactAdapter() {
    NSCache *imageCache;
    NSCache *contactCache;
    NSMutableArray * listIdentifiersLoaded;
    NSMutableArray<NSString*> * contactWaitToImage;
}

- (ContactDAL *) parseToContactDAL: (CNContact *) contact forID: (NSString *) identifier;
- (void) contactDidChangedEvent: (NSNotification *) notification;

- (void) createDummyData: (int) number batchSize: (int) size delegate: (void (^)(NSArray<ContactDAL *> *)) handler;

@end

@implementation ContactAdapter

@synthesize contactChangedObservable;

- (id) init {
    self->imageCache = [[NSCache alloc] init];
    self->contactCache = [[NSCache alloc] init];
    self->contactWaitToImage = [[NSMutableArray alloc] init];
    self->listIdentifiersLoaded = [[NSMutableArray alloc] init];
    self->contactChangedObservable = [[DataBinding alloc] initWithValue: nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(contactDidChangedEvent:) name:CNContactStoreDidChangeNotification object:nil];
    return self;
}

- (void) contactDidChangedEvent: (NSNotification *) notification {
    self->contactChangedObservable.value = [NSNumber numberWithInt:[self->contactChangedObservable.value intValue] + 1];
}

- (void)requestPermission:(void (^)(BOOL, NSError * _Nullable)) handler {
    if ([CNContactStore class]) {
        CNContactStore *addressBook = [[CNContactStore alloc] init];
        [addressBook requestAccessForEntityType:CNEntityTypeContacts
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
            handler(granted, error);
        }];
    } else {
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
        handler(NO, error);
    }
}

- (void)loadContacts:(int) batchSize completion:(void (^)(NSArray<id<ContactDALProtocol>> *, NSError *, BOOL))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_queue_attr_t priorityAttribute = dispatch_queue_attr_make_with_qos_class(
            DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -1
        );
        dispatch_queue_t callBackQueue = dispatch_queue_create("response_batch", priorityAttribute);
        
        NSMutableArray *listContacts = [[NSMutableArray alloc] init];
        
        if ([CNContactStore class]) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch = @[CNContactIdentifierKey,
                                     CNContactGivenNameKey,
                                     CNContactFamilyNameKey,
                                     CNContactPhoneNumbersKey,
                                     CNContactEmailAddressesKey];
            
            CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
            
            [addressBook enumerateContactsWithFetchRequest:fetchRequest
                                                     error:nil
                                                usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                [listContacts addObject: [[ContactDAL alloc] initWithID:contact.identifier name:contact.givenName familyName:contact.familyName]];
                
                
                if (listContacts.count >= batchSize) {
                    NSArray * batch = [listContacts copy];
                    [listContacts removeAllObjects];
                    dispatch_sync(callBackQueue, ^{
                        handler(batch, nil, NO);
                    });
                }
                
                [self->listIdentifiersLoaded addObject:contact.identifier];
            }];
            
            //            Add dummy data
            [self createDummyData:1000 batchSize:100 delegate:^(NSArray<ContactDAL *> * listDummyData) {
                dispatch_async(callBackQueue, ^{
                   handler([listDummyData copy], nil, NO);
                });
            }];
            
            dispatch_async(callBackQueue, ^{
               handler([listContacts copy], nil, YES);
            });
        } else {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
            handler(nil, error, YES);
        }
        
    });
}


- (void)loadContactById:(NSString *)identifier isReload:(BOOL) isReload completion:(void (^)(id<ContactDALProtocol>, NSError *))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!isReload) {
            ContactDAL *contactInCache = [self->contactCache objectForKey:identifier];
            if (contactInCache) {
                handler(contactInCache, nil);
                return;
            }
        }
        
        if ([CNContactStore class]) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch = @[CNContactGivenNameKey,
                                     CNContactPhoneNumbersKey,
                                     CNContactFamilyNameKey,
                                     CNContactEmailAddressesKey];
            CNContact* contact = [addressBook unifiedContactWithIdentifier: identifier
                                                               keysToFetch:keysToFetch
                                                                     error:nil];
            
            if (!contact) {
                NSDictionary * userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"Dont have contact with identifier: %@", identifier]};
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
                handler(nil, error);
            } else {
                handler([self parseToContactDAL:contact forID: identifier], nil);
            }
            
        } else {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
            handler(nil, error);
        }
    });
}

- (void)loadBatchOfDetailedContacts:(NSArray<NSString *> *)listIdentifiers
                           isReload: (BOOL) isReload
                 completion:(void (^)(NSArray<id<ContactDALProtocol>> *, NSError *))handler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * identifiersNeedLoad = [[NSMutableArray alloc] init];
        NSMutableArray * results = [[NSMutableArray alloc] init];
        
        if (!isReload) {
            //        Check if cache have this contact then just take it.
            for (NSString * identifier in listIdentifiers) {
                ContactDAL *contactInCache = [self->contactCache objectForKey:identifier];
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
        } else {
            identifiersNeedLoad = [[NSMutableArray alloc] initWithArray: listIdentifiers];
        }
        
//        Load contact from CNContactStore
        if ([CNContactStore class]) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch = @[CNContactGivenNameKey,
                                     CNContactPhoneNumbersKey,
                                     CNContactFamilyNameKey,
                                     CNContactEmailAddressesKey];
            
            NSPredicate* predicate = [CNContact predicateForContactsWithIdentifiers:identifiersNeedLoad];
            NSArray<CNContact*> * contacts = [addressBook unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:nil];
            
            NSArray * listContactLoaded = [contacts map:^ContactDAL* _Nonnull(CNContact*  _Nonnull obj) {
                return [self parseToContactDAL:obj forID:obj.identifier];
            }];
            
            [results addObjectsFromArray:listContactLoaded];
            handler(results, nil);
        } else {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
            handler(nil, error);
        }
        
    });
}

- (void)getImageById:(NSString *)identifier isReload: (BOOL) isReload completion:(void (^)(NSData *, NSError * error))handler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!isReload) {
            NSData * imageData = [self->imageCache objectForKey:identifier];
            if (imageData) {
                handler(imageData, nil);
                return;
            }
        }
        
        if ([CNContactStore class]) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch = @[CNContactImageDataAvailableKey,
                                     CNContactImageDataKey,
                                     CNContactThumbnailImageDataKey];
            CNContact* contact = [addressBook unifiedContactWithIdentifier: identifier
                                                               keysToFetch:keysToFetch
                                                                     error:nil];
            
            if (!contact) {
                NSDictionary * userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"Dont have contact with identifier: %@", identifier]};
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
                handler(nil, error);
            } else {
                if (contact.imageDataAvailable) {
                    [self->imageCache setObject:contact.imageData forKey:identifier];
                    
                    handler(contact.imageData, nil);
                }
            }
            
        } else {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
            handler(nil, error);
        }
    });
}

#pragma mark parse ContactDAL

- (ContactDAL *)parseToContactDAL:(CNContact *)contact
                            forID: (NSString *) identifier {
    NSString* contactId = contact.identifier;
    NSString* givenName = contact.givenName;
    NSString* familyName = contact.familyName;
    NSMutableArray<NSString*> *phoneNumbers = [[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"];
    NSMutableArray<NSString*> *emails = [contact.emailAddresses valueForKey:@"value"];
    
    
    ContactDAL *contactDAL = [[ContactDAL alloc] init:contactId
                                              name:givenName
                                           familyName:familyName
                                            phones:phoneNumbers
                                            emails:emails];
    
    [self->contactCache setObject:contactDAL forKey:contactDAL.contactID];
    
    return contactDAL;
    
}

#pragma mark Create Dummy Data

- (void)createDummyData:(int)number batchSize:(int) size delegate:(void (^)(NSArray<ContactDAL *> *))handler {
    NSMutableArray * dummyData = [[NSMutableArray alloc] init];
    
    int i = 0;
    while (i < number) {
        NSString * identifier = [[NSProcessInfo processInfo] globallyUniqueString];
        ContactDAL * dummyContact = [[ContactDAL alloc] initWithID:identifier name:[NSString stringWithFormat:@"%d dummy %d", i, i] familyName:@""];
        
        [self->contactCache setObject:dummyContact forKey: identifier];
        [dummyData addObject:dummyContact];
        
        if (dummyData.count >= size || i == number) {
            NSArray * batch = [dummyData copy];
            [dummyData removeAllObjects];
            dispatch_sync(dispatch_queue_create("response_batch", DISPATCH_QUEUE_CONCURRENT), ^{
                handler(batch);
            });
        }
        i++;
    }
}

@end
