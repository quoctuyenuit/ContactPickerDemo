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
#import "APIAdapterProtocol.h"
#import "NSArrayExtension.h"


@interface ContactAdapter() {
    NSCache *contactCache;
    NSMutableArray * listIdentifiersLoaded;
    id<ImageGeneratorProtocol> imageGeneratorAPI;
    NSMutableDictionary<NSString*, NSMutableArray<void (^)(NSData *)> *> * imageRequestQueue;
    NSMutableArray<NSString*> * contactWaitToImage;
}

- (ContactDAL*) parseToContactDAL: (CNContact *) contact forID: (NSString *) identifier;
- (void) contactDidChangedEvent: (NSNotification *) notification;

@end

@implementation ContactAdapter

@synthesize contactChangedObservable;

- (id) initWidthAPI: (id<ImageGeneratorProtocol>) imageAPI {
    self->contactCache = [[NSCache alloc] init];
    self->imageGeneratorAPI = imageAPI;
    self->imageRequestQueue = [[NSMutableDictionary alloc] init];
    self->contactWaitToImage = [[NSMutableArray alloc] init];
    self->listIdentifiersLoaded = [[NSMutableArray alloc] init];
    self->contactChangedObservable = [[DataBinding alloc] initWithValue: nil];
    
//    [CNContactStoreDidChangeNotification addObserver:self forKeyPath:@"test" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(contactDidChangedEvent:) name:CNContactStoreDidChangeNotification object:nil];
    return self;
}

- (void) contactDidChangedEvent: (NSNotification *) notification {
    [self loadContactByBatch:self->listIdentifiersLoaded completion:^(NSArray<ContactDAL *> * listUpdatedContact) {
        self->contactChangedObservable.value = listUpdatedContact;
    }];
}

- (void) loadContacts: (void (^)(NSArray<ContactDAL *> *, BOOL)) completion {
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
            
            
            completion([listContacts copy], YES);
        } else
            completion(nil, NO);
    });
}

- (void) loadContactById: (NSString *) identifier
             completion: (void (^)(ContactDAL *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ContactDAL *contactInCache = [self->contactCache objectForKey:identifier];
        if (contactInCache) {
            completion(contactInCache);
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
            
            completion([self parseToContactDAL:contact forID: identifier]);
        }
    });
}

- (void)requestPermission:(void (^)(BOOL))completion {
    if ([CNContactStore class]) {
        CNContactStore *addressBook = [[CNContactStore alloc] init];
        [addressBook requestAccessForEntityType:CNEntityTypeContacts
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error == nil) {
                completion(granted);
            } else {
                completion(granted);
                NSLog(@"%@", error);
            }
        }];
    }
}

- (void)loadContactByBatch:(NSArray<NSString *> *)listIdentifiers completion:(void (^)(NSArray *))completion {
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
            completion(results);
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
            
            completion(results);
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
    NSData * imageData = nil;
    if (contact.imageData) {
        imageData = contact.imageData;
    }
//    else {
//        [self->contactWaitToImage addObject:identifier];
//        NSString* name = givenName.length >= 2 ? [givenName substringToIndex:2] : [givenName substringToIndex:1];
//        [imageGeneratorAPI generateImageFromName:name completion:^(NSData * imageData, BOOL isSuccess) {
//            if (isSuccess == YES) {
//                [self->imageCache setObject:imageData forKey:identifier];
//
//                NSMutableArray* queue = [self->imageRequestQueue objectForKey:identifier];
//
//                for (void (^hdl)(NSData*)  in queue) {
//                    hdl(imageData);
//                }
//            }
//            [self->contactWaitToImage removeObject:identifier];
//        }];
//    }
    
    ContactDAL *contactDAL = [[ContactDAL alloc] init:contactId
                                              name:givenName
                                           familyName:familyName
                                                image: imageData
                                            phones:phoneNumbers
                                            emails:emails];
    
    [self->contactCache setObject:contactDAL forKey:contactDAL.contactID];
    
    return contactDAL;
    
}

@end
