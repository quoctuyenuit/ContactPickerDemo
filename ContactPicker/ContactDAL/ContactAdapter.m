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

#define CHECK_RETAINCYCLE               0
#if CHECK_RETAINCYCLE
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#endif

@interface ContactAdapter()

- (ContactDAL *)parseToContactDAL: (CNContact *) contact;
- (void)contactDidChangedEvent: (NSNotification *) notification;

#if DUMMY_DATA_ENABLE
- (NSArray<ContactDAL *> *) createDummyDataWithSize:(NSUInteger) size;
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
    _background_queue   = dispatch_queue_create("[Adapter] background queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _response_queue     = dispatch_queue_create("[Adapter] response queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _loadInProcessing   = NO;
    _loadContactRequest = [[NSMutableArray alloc] init];
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
- (void)requestPermission:(void (^)(BOOL, NSError * _Nullable)) handler {
#if DEBUG_PERMISSION_DENIED
    handler(NO, nil);
    return;
#endif
    CNContactStore *addressBook = [[CNContactStore alloc] init];
    [addressBook requestAccessForEntityType:CNEntityTypeContacts
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (handler)
            handler(granted, error);
    }];
}

- (void)loadContactsWithBlock:(void (^)(NSArray<id<ContactDALProtocol>> *, NSError *))block {
    if (!block) {
        return;
    }
    
#if DEBUG_EMPTY_CONTACT
    NSError * error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contacts"];
    block(nil, error);
    return;
#endif
    
#if DEBUG_FAILT_LOAD
    NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeRetainCycleGone localizeString:@"Load failt"];
    block(nil, error);
    return;
#endif
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_response_queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.loadContactRequest addObject:block];
            
            if (strongSelf.loadInProcessing) {
                return;
            }
            strongSelf->_loadInProcessing = YES;
        }
    });
    
    dispatch_async(_background_queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableArray *listContacts        = [[NSMutableArray alloc] init];
            CNContactStore *addressBook         = [[CNContactStore alloc] init];
            
            NSArray *keysToFetch                = strongSelf.fetchRequest;
            CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
            //        fetchRequest.sortOrder              = CNContactSortOrderGivenName;
            
            [addressBook enumerateContactsWithFetchRequest:fetchRequest
                                                     error:nil
                                                usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                
                [listContacts addObject: [strongSelf parseToContactDAL:contact]];
            }];
            
#if DUMMY_DATA_ENABLE
            [listContacts addObjectsFromArray: [strongSelf createDummyDataWithSize:NUMBER_OF_DUMMY]];
#endif
            
            NSError * error = nil;
            if (listContacts.count == 0) {
                error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contacts"];
            }
            
            dispatch_sync(strongSelf->_response_queue, ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    for (AdapterResponseListBlock block in strongSelf.loadContactRequest) {
                        block(listContacts, error);
                    }
                    [strongSelf.loadContactRequest removeAllObjects];
                    strongSelf->_loadInProcessing = NO; //Load done
                }
            });
        } else {
            NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeRetainCycleGone localizeString:@"Load failt"];
            block(nil, error);
        }
    });
}

- (void)loadContactById:(NSString *)identifier block:(AdapterResponseContactBlock)block {
    if (!block) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(_background_queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
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
                ContactDAL * dalEntity = [strongSelf parseToContactDAL:contact];
                block(dalEntity, nil);
            }
        }
    });
}

- (void)loadContactsByBatch:(NSArray<NSString *> *)identifiers block:(AdapterResponseListBlock)block {
    if (!block) {
        return;
    }
    
    if (identifiers.count == 0) {
        NSError *error = [[NSError alloc] initWithDomain:ADAPTER_ERROR_DOMAIN type:ErrorTypeEmpty localizeString:@"Empty contacts"];
        
        block(nil, error);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_background_queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
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
                return [self parseToContactDAL:obj];
            }];
            
            block(result, error);
        }
    });
}

- (void)getImageById:(NSString *)identifier block:(void (^)(UIImage *image, NSError * error))block {
    if (!block) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(_background_queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
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
//                Resize image to smaller
                UIImage * image = [UIImage imageWithImage: [UIImage imageWithData:contact.thumbnailImageData]
                                         scaledToFillSize:CGSizeMake(AVATAR_IMAGE_HEIGHT, AVATAR_IMAGE_HEIGHT)];
                block(image, nil);
            }
        }
    });
}

#pragma mark Helper methods
- (ContactDAL *)parseToContactDAL:(CNContact *)contact {
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

#pragma mark - Create Dummy Data methods
#if DUMMY_DATA_ENABLE
- (NSArray<ContactDAL *> *) createDummyDataWithSize:(NSUInteger) size {
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
