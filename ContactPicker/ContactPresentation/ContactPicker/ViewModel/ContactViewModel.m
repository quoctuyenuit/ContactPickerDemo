//
//  ListContactViewModel.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactViewModel.h"
#import "ContactViewEntity.h"
#import <Contacts/Contacts.h>
#import "NSArrayExtension.h"
#import <UIKit/UIKit.h>
#import "Logging.h"

@interface ContactViewModel() {
    BOOL _contactIsLoaded;
    BOOL _loadContactIsDone;
    dispatch_queue_t _updateViewQueue;
    dispatch_queue_t _searchResponseQueue;
    NSString * _waitingSearchResult;
}

- (void) setupEvents;
- (ContactViewEntity *) parseContactEntity: (ContactBusEntity *) entity;
- (NSString *) makeKeyFromName: (NSString *) name;
- (void) refreshContactOnView;
@end

@implementation ContactViewModel

@synthesize listSelectedContacts = _listSelectedContacts;

@synthesize contactBus = _contactBus;

@synthesize searchObservable;

@synthesize contactBookObservable;

@synthesize contactAddedObservable;

@synthesize indexCellNeedUpdateObservable;

@synthesize selectedContactRemoveObservable;

@synthesize selectedContactAddedObservable;

- (id)initWithBus:(id<ContactBusProtocol>)bus {
    self->_contactBus = bus;
    self->_contactIsLoaded = NO;
    self->_loadContactIsDone = NO;
    
    self->_updateViewQueue = dispatch_queue_create("update queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -2));
    self->_searchResponseQueue = dispatch_queue_create("search queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -2));
//    List source initialization
    self.contactsOnView = [[NSMutableDictionary alloc] init];
    self.contactsBackup = self.contactsOnView;
    
    self.listSelectedContacts = [[NSMutableArray alloc] init];
    self->_listSectionKeys = [[NSMutableArray alloc] init];
    
//    Data binding initialization
    self.searchObservable = [[DataBinding<NSString *> alloc] initWithValue:@""];
    self.contactBookObservable = [[DataBinding<NSNumber *> alloc] initWithValue:[NSNumber numberWithInt:0]];
    self.contactAddedObservable = [[DataBinding<NSArray<NSIndexPath *> *> alloc] initWithValue:[[NSArray<NSIndexPath *> alloc] init]];
    self.indexCellNeedUpdateObservable = [[DataBinding<NSIndexPath *> alloc] initWithValue:nil];
    
    self.selectedContactAddedObservable = [[DataBinding<NSNumber *> alloc] initWithValue:[NSNumber numberWithInt:0]];
    self.selectedContactRemoveObservable = [[DataBinding<NSNumber *> alloc] initWithValue:[NSNumber numberWithInt:0]];
    
    for (char i = 'A'; i <= 'Z'; i++) {
        NSString * key = [NSString stringWithFormat:@"%c", i];
        [self.contactsOnView setValue:[[NSMutableArray alloc] init] forKey:key];
        [self->_listSectionKeys addObject:key];
    }
    NSString * key = @"#";
    [self.contactsOnView setValue:[[NSMutableArray alloc] init] forKey:key];
    [self->_listSectionKeys addObject:key];
    
    
    [self setupEvents];
    
    return self;
}

- (void)setupEvents {
    __weak ContactViewModel * weakSelf = self;
    
//    Listen Contact store changed
    self->_contactBus.contactChangedObservable = ^(NSArray * contactsUpdated) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (strongSelf) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    // Update avatar for current contacts
                    for (NSString * key in strongSelf->_listSectionKeys) {
                        [[strongSelf.contactsOnView objectForKey:key] enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [strongSelf.contactBus getImageFromId:obj.identifier isReload: YES completion:^(NSData *imageData, NSError *error) {
                                if (!error) {
                                    UIImage * image = [UIImage imageWithData:imageData];
                                    obj.avatar = image;
                                    if (obj.waitImageToExcuteQueue) {
                                        obj.waitImageToExcuteQueue(image, obj.identifier);
                                    }
                                }
                            }];
                        }];
                    }
                });
                
                [contactsUpdated enumerateObjectsUsingBlock:^(ContactBusEntity*  _Nonnull updatedEntity, NSUInteger idx, BOOL * _Nonnull stop) {
                    ContactViewEntity * oldContact = [strongSelf contactWithIdentifier:updatedEntity.identifier];
                    if (oldContact && ![oldContact isEqualWithBusEntity:updatedEntity]) {
                        [oldContact updateContactWithBus:updatedEntity];
                    }
                }];
                
                strongSelf.contactBookObservable.value = [NSNumber numberWithInt:[strongSelf.contactBookObservable.value intValue] + 1];
            }
        });
    };
}

- (ContactViewEntity *)parseContactEntity:(ContactBusEntity *)entity {
    ContactViewEntity *viewEntity =  [[ContactViewEntity alloc] initWithBusEntity:entity];
    
    [self->_contactBus getImageFromId:entity.identifier isReload: NO completion:^(NSData * imageData, NSError * error) {
        if (!error) {
            UIImage * image = [UIImage imageWithData:imageData];
            viewEntity.avatar = image;
            if (viewEntity.waitImageToExcuteQueue) {
                viewEntity.waitImageToExcuteQueue(image, entity.identifier);
            }
        }
    }];
    return viewEntity;
}

- (void)storeContacts:(NSArray *)batchOfContact {
    __weak typeof(self) weakSelf = self;
    
    dispatch_sync(self->_updateViewQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableArray * insertedIndexPaths = [[NSMutableArray alloc] init];
            
            [batchOfContact enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull newContact, NSUInteger idx, BOOL * _Nonnull stop) {
                [strongSelf.listSelectedContacts enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull selectedContact, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([selectedContact.identifier isEqualToString:newContact.identifier]) {
                        [newContact updateContact:selectedContact];
                    }
                }];
                
                NSString * key = [strongSelf makeKeyFromName:newContact.fullName];
                
                NSMutableArray * contactsInSection = [strongSelf.contactsBackup objectForKey:key];
                
                [contactsInSection addObject:newContact];
                [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:contactsInSection.count - 1
                                                                 inSection:[self->_listSectionKeys indexOfObject:key]]];
            }];
            
            [Logging info:[NSString stringWithFormat: @"Load more %lu contact(s)", (unsigned long)batchOfContact.count]];
            strongSelf.contactAddedObservable.value = insertedIndexPaths;
            [NSThread sleepForTimeInterval:0.3];
        }
    });
}

#pragma mark Public function
- (void)requestPermission:(void (^)(BOOL, NSError *))completion {
    [self->_contactBus requestPermission:completion];
}

- (void)loadContacts:(void (^)(BOOL isSuccess, NSError * error, int numberOfContacts))completion {
    __weak typeof(self) weakSelf = self;
    [self->_contactBus loadContacts:^(NSArray<ContactBusEntity *> * listContactFromBus, NSError *error, BOOL isDone) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error) {
                completion(NO, error, 0);
                [Logging error:[NSString stringWithFormat:@"Load contact failt, error: %@", error.localizedDescription]];
            } else {
                NSArray * batchOfContact = [listContactFromBus map:^ContactViewEntity* _Nonnull(ContactBusEntity*  _Nonnull obj) {
                    return [self parseContactEntity:obj];
                }];
                [self storeContacts:batchOfContact];
                
                if (!self->_contactIsLoaded) {
                    completion(YES, nil, (int)batchOfContact.count);
                    self->_contactIsLoaded = YES;
                }
                self->_loadContactIsDone = isDone;
            }
        }
    }];
}

- (NSInteger)numberOfSection {
    return [self.contactsOnView allKeys].count;
}

- (int)numberOfContactInSection: (NSInteger) section {
    NSString * key = [self parseSectionToKey:(int)section];
    return  (int)[self.contactsOnView objectForKey:key].count;
}

- (NSString *) parseSectionToKey: (int) section {
    return [self->_listSectionKeys objectAtIndex:section];
}

- (ContactViewEntity *)contactAtIndex:(NSIndexPath *)indexPath {
    NSString * key = [self parseSectionToKey:(int)indexPath.section];
    return [[self.contactsOnView objectForKey:key] objectAtIndex:indexPath.row];
}

- (ContactViewEntity *)contactWithIdentifier:(NSString *)identifier name:(NSString *)name {
    NSString * key = [self makeKeyFromName:name];
    NSArray * listContact = [self.contactsOnView objectForKey:key];
    return [listContact firstObjectWith:^BOOL(ContactViewEntity * _Nonnull obj) {
        return [obj.identifier isEqualToString:identifier];
    }];
}

- (void)searchContactWithKeyName:(NSString *)key {
    self->_waitingSearchResult = key;
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            //        [NSThread sleepForTimeInterval:0.1];
            if ([key isEqualToString:@""]) {
                strongSelf.contactsOnView = strongSelf.contactsBackup;
                strongSelf->contactAddedObservable.value = @[[NSIndexPath indexPathForRow:0 inSection:0]];
                return;
            }
            int i = 0;
            
            NSString * firstLetter = [key substringToIndex:1];
            NSString * contactKey = [strongSelf->_listSectionKeys containsObject:firstLetter] ? firstLetter : @"#";
            NSMutableArray * section = [strongSelf.contactsBackup objectForKey:contactKey];
            
            [strongSelf refreshContactOnView];
            BOOL haveResult = NO;
            
            while (i < section.count && [strongSelf->_waitingSearchResult isEqualToString:key]) {
                ContactViewEntity * contact = [[strongSelf.contactsBackup objectForKey:contactKey] objectAtIndex:i];
                
                if ([contact contactHasPrefix:key]) {
                    haveResult = YES;
                    NSString * k = [strongSelf makeKeyFromName:contact.fullName];
                    
                    NSMutableArray * newSection = [strongSelf.contactsOnView objectForKey:k];
                    
                    [newSection addObject:contact];
                    
                    dispatch_sync(strongSelf->_searchResponseQueue, ^{
                        strongSelf->contactAddedObservable.value = @[[NSIndexPath indexPathForRow:0 inSection:0]];
                        [NSThread sleepForTimeInterval:0.1];
                    });
                }
                
                if (strongSelf->_loadContactIsDone || i < section.count)
                    i++;
            }
            
            if (!haveResult) {
                strongSelf->contactAddedObservable.value = @[[NSIndexPath indexPathForRow:0 inSection:0]];
                return;
            }
        }
    });
}

- (void)selectectContactAtIndex:(NSIndexPath *)indexPath {
    ContactViewEntity * contact = [self contactAtIndex:indexPath];
    contact.isChecked = !contact.isChecked;
    
    if (contact.isChecked) {
        [self.listSelectedContacts addObject:contact];
        self.selectedContactAddedObservable.value = [NSNumber numberWithUnsignedInteger:self.listSelectedContacts.count - 1];
    } else if ([self.listSelectedContacts containsObject:contact]) {
        NSUInteger index = [self.listSelectedContacts indexOfObject:contact];
        [self.listSelectedContacts removeObjectAtIndex:index];
        self.selectedContactRemoveObservable.value = [NSNumber numberWithUnsignedInteger:index];
    }
}

- (void)removeSelectedContact:(NSString *)identifier {
    
    ContactViewEntity * contact = [self.listSelectedContacts firstObjectWith:^BOOL(ContactViewEntity*  _Nonnull obj) {
        return [obj.identifier isEqualToString:identifier];
    }];
    
    if ([self.listSelectedContacts containsObject:contact]) {
        NSUInteger index = [self.listSelectedContacts indexOfObject:contact];
        [self.listSelectedContacts removeObjectAtIndex:index];
        self.selectedContactRemoveObservable.value = [NSNumber numberWithUnsignedInteger:index];
    }
    
    if (![self isContainContact:contact]) {
        contact = [self contactWithIdentifier:contact.identifier name:contact.fullName];
    }
    
    contact.isChecked = NO;
    NSIndexPath * index = [self indexOfContact:contact];
    
    self.indexCellNeedUpdateObservable.value = index;
}

- (NSArray *)getAllSectionNames {
    return self->_listSectionKeys;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return [self->_listSectionKeys objectAtIndex:section];
}

- (NSString *)makeKeyFromName:(NSString *)name {
    if (name.length == 0)
        return @"#";
    
    NSString * firstLetter = [[name substringToIndex:1] uppercaseString];
    int letterNumber = [firstLetter characterAtIndex:0];
    return (letterNumber >= 65 && letterNumber <= 90) ? firstLetter : @"#";
}

- (BOOL)isContainContact:(ContactViewEntity *)contact {
    NSString * key = [self makeKeyFromName:contact.fullName];
    NSArray * listContacts = [self.contactsOnView objectForKey:key];
    return listContacts ? [listContacts containsObject:contact] : NO;
}

- (NSIndexPath *)indexOfContact:(ContactViewEntity *)contact {
    NSString * key = [self makeKeyFromName:contact.fullName];
    NSInteger section = [self->_listSectionKeys indexOfObject:key];
    NSArray * listContacts = [self.contactsOnView objectForKey:key];
    NSInteger row = [listContacts indexOfObject:contact];
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (ContactViewEntity * _Nullable)contactWithIdentifier:(NSString *)identifier {
    for (NSString * key in self->_listSectionKeys) {
        ContactViewEntity * result = [[self.contactsOnView objectForKey:key] firstObjectWith:^BOOL(ContactViewEntity * _Nonnull obj) {
            return [obj.identifier isEqualToString:identifier];
        }];
        if (result)
            return result;
    }

    return nil;
}

- (void)refreshContactOnView {
    [Logging info:@"Refresh contactOnView"];
    self.contactsOnView = [[NSMutableDictionary alloc] init];
    for (char i = 'A'; i <= 'Z'; i++) {
        NSString * key = [NSString stringWithFormat:@"%c", i];
        [self.contactsOnView setValue:[[NSMutableArray alloc] init] forKey:key];
    }
    NSString * key = @"#";
    [self.contactsOnView setValue:[[NSMutableArray alloc] init] forKey:key];
}

@end
