//
//  ContactAdapter.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactAdapter.h"
#import <Contacts/Contacts.h>
#import "ContactDAL.h"
#import "NSArrayExtension.h"


@interface ContactAdapter() {
    NSCache *imageCache;
    NSCache *contactCache;
    NSMutableArray * listIdentifiersLoaded;
    NSMutableDictionary<NSString*, NSMutableArray<void (^)(NSData *)> *> * imageRequestQueue;
    NSMutableArray<NSString*> * contactWaitToImage;
}

- (ContactDAL*) parseToContactDAL: (CNContact *) contact forID: (NSString *) identifier;
- (void) contactDidChangedEvent: (NSNotification *) notification;

@end

@implementation ContactAdapter

@synthesize contactChangedObservable;

- (id) init {
    self->imageCache = [[NSCache alloc] init];
    self->contactCache = [[NSCache alloc] init];
    self->imageRequestQueue = [[NSMutableDictionary alloc] init];
    self->contactWaitToImage = [[NSMutableArray alloc] init];
    self->listIdentifiersLoaded = [[NSMutableArray alloc] init];
    self->contactChangedObservable = [[DataBinding alloc] initWithValue: nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(contactDidChangedEvent:) name:CNContactStoreDidChangeNotification object:nil];
    return self;
}

- (void) contactDidChangedEvent: (NSNotification *) notification {
    [self loadBatchOfContacts:self->listIdentifiersLoaded completion:^(NSArray<ContactDAL *> * listUpdatedContact, NSError * error) {
        if (!error) {
            self->contactChangedObservable.value = listUpdatedContact;
        }
    }];
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

- (void) loadContacts: (void (^)(NSArray<ContactDAL *> *, NSError * _Nullable)) handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *listContacts = [[NSMutableArray alloc] init];
        
        if ([CNContactStore class]) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch = @[CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey];
            
            CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
            
            [addressBook enumerateContactsWithFetchRequest:fetchRequest
                                                     error:nil
                                                usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                [listContacts addObject: [[ContactDAL alloc] initWithID:contact.identifier name:contact.givenName familyName:contact.familyName]];
                [self->listIdentifiersLoaded addObject:contact.identifier];
            }];
            
            handler([listContacts copy], nil);
        } else {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"CNContactStore not supported"};
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
            handler(nil, error);
        }
        
    });
}

- (void) loadContactById: (NSString *) identifier
             completion: (void (^)(ContactDAL *, NSError * _Nullable))handler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ContactDAL *contactInCache = [self->contactCache objectForKey:identifier];
        if (contactInCache) {
            handler(contactInCache, nil);
            return;
        }
        
        if ([CNContactStore class]) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch = @[CNContactGivenNameKey,
                                     CNContactPhoneNumbersKey,
                                     CNContactFamilyNameKey,
                                     CNContactEmailAddressesKey,
                                     CNContactImageDataAvailableKey,
                                     CNContactThumbnailImageDataKey];
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

- (void)loadBatchOfContacts:(NSArray<NSString *> *)listIdentifiers
                completion:(void (^)(NSArray *, NSError * _Nullable))handler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        
        NSMutableArray * identifiersNeedLoad = [[NSMutableArray alloc] init];
        NSMutableArray * results = [[NSMutableArray alloc] init];
        
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
        
//        Load contact from CNContactStore
        if ([CNContactStore class]) {
            CNContactStore *addressBook = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch = @[CNContactGivenNameKey,
                                     CNContactIdentifierKey,
                                     CNContactPhoneNumbersKey,
                                     CNContactFamilyNameKey,
                                     CNContactEmailAddressesKey,
                                     CNContactImageDataAvailableKey,
                                     CNContactImageDataKey,
                                     CNContactThumbnailImageDataKey];
            
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

#pragma mark PARSE ContactDAL

- (ContactDAL *)parseToContactDAL:(CNContact *)contact
                            forID: (NSString *) identifier {
    NSString* contactId = contact.identifier;
    NSString* givenName = contact.givenName;
    NSString* familyName = contact.familyName;
    NSMutableArray<NSString*> *phoneNumbers = [[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"];
    NSMutableArray<NSString*> *emails = [contact.emailAddresses valueForKey:@"value"];
    
    if (contact.imageDataAvailable) {
        [self->imageCache setObject:contact.imageData forKey:contactId];
        
        NSArray * blocksQueue = [self->waitImageBlockQueue objectForKey:contactId];
        if (blocksQueue) {
            for (void (^block)(NSData *) in blocksQueue) {
                block(contact.imageData);
            }
        }
    }
    
    ContactDAL *contactDAL = [[ContactDAL alloc] init:contactId
                                              name:givenName
                                           familyName:familyName
                                            phones:phoneNumbers
                                            emails:emails];
    
    [self->contactCache setObject:contactDAL forKey:contactDAL.contactID];
    
    return contactDAL;
    
}

- (void)getImageFromId:(NSString *)identifier completion:(void (^)(NSData *))handler {
    NSData * imageData = [self->imageCache objectForKey:identifier];
    if (imageData) {
        handler(imageData);
    } else {
        NSMutableArray * queue = [self->waitImageBlockQueue objectForKey:identifier];
        if (queue) {
            [queue addObject:[handler copy]];
        } else {
            [self->waitImageBlockQueue setObject:[[NSMutableArray alloc] initWithObjects:[handler copy], nil] forKey:identifier];
        }
    }
}

@end
