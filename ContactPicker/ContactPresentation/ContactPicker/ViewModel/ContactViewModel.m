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
#import "Utilities.h"
#import <UIKit/UIKit.h>
#import "Logging.h"

#define CONTACT_BATCH_SIZE              200
#define STRONG_SELF_DEALLOCATED_MSG     @"strongSelf had deallocated"

@interface ContactViewModel() {
    BOOL                _loadBatchInProcessing;
    dispatch_queue_t    _backgroundQueue;
    dispatch_queue_t    _searchingQueue;
}

- (void) setupEvents;
- (ContactViewEntity *) parseContactEntity: (ContactBusEntity *) entity;
- (NSString *) makeKeyFromName: (NSString *) name;
- (void) refreshContactOnView;
@end

@implementation ContactViewModel

@synthesize contactsOnView;

@synthesize contactBus = _contactBus;

@synthesize searchObservable;

@synthesize contactBookObservable;

@synthesize cellNeedRemoveSelectedObservable;

@synthesize dataSourceNeedReloadObservable;

@synthesize selectedContactRemoveObservable;

@synthesize selectedContactAddedObservable;

- (id)initWithBus:(id<ContactBusProtocol>)bus {
    _contactBus                 = bus;
    
    _searchingQueue             = dispatch_queue_create("[ViewModel] searching queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    
    _backgroundQueue            = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    _loadBatchInProcessing      = NO;
    
//    List source initialization
    self.contactsOnView         = [[NSMutableDictionary alloc] init];
    
    _listSelectedContacts           = [[NSMutableArray alloc] init];
   _listSectionKeys          = [[NSMutableArray alloc] init];
    
//    Data binding initialization
    self.searchObservable = [[DataBinding<NSString *> alloc] initWithValue:@""];
    self.contactBookObservable = [[DataBinding<NSNumber *> alloc] initWithValue:[NSNumber numberWithInt:0]];
    self.cellNeedRemoveSelectedObservable = [[DataBinding<NSIndexPath *> alloc] initWithValue:nil];
    self.dataSourceNeedReloadObservable = [[DataBinding<NSNumber *> alloc] initWithValue:[NSNumber numberWithInt:0]];
    
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
   _contactBus.contactChangedObservable = ^(NSArray * contactsUpdated) {
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

#pragma mark Protocol methods
- (void)requestPermission:(void (^)(BOOL, NSError *))completion {
    [self->_contactBus requestPermission:completion];
}

- (void)loadContacts:(void (^)(BOOL isSuccess, NSError * error, NSUInteger numberOfContacts))completion {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_backgroundQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            
            [strongSelf->_contactBus loadContacts:^(NSError *error, BOOL isDone, NSUInteger numberOfContacts) {
                if (error) {
                    completion(NO, error, 0);
                } else {
                    completion(YES, nil, numberOfContacts);
                }
                
               
            }];
        }
    });
}

- (void)loadBatchOfContacts:(void (^)(NSError * error, NSArray<NSIndexPath *> * updatedIndexPaths))handler {
    if (_loadBatchInProcessing) {
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"Load batch in processing"};
        NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(error, nil);
        });
        return;
    } else {
        @synchronized (self) {
        NSLog(@"[ViewModel] loadBatch");
        _loadBatchInProcessing = YES;
        
            __weak typeof(self) weakSelf = self;
            dispatch_async(_backgroundQueue, ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf->_contactBus loadContactByBatch:CONTACT_BATCH_SIZE completion:^(NSArray<ContactBusEntity *> * listContacts, NSError *error) {
                        if (error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                handler(error, nil);
                            });
                            strongSelf->_loadBatchInProcessing = NO;
                        } else {
                            NSArray<ContactViewEntity *> * contactsAdded = [listContacts map:^ContactViewEntity * _Nonnull(ContactBusEntity * _Nonnull obj) {
                                return [[ContactViewEntity alloc] initWithBusEntity:obj];
                            }];
                            [strongSelf addContacts:contactsAdded completion:^(NSArray<NSIndexPath *> *updatedIndexPaths) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    handler(nil, updatedIndexPaths);
                                });
                                strongSelf->_loadBatchInProcessing = NO;
                            }];
                        }
                    }];
                } else {
                    NSDictionary * userInfo = @{NSLocalizedDescriptionKey: STRONG_SELF_DEALLOCATED_MSG};
                    NSError *error          = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:userInfo];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(error, nil);
                    });
                    strongSelf->_loadBatchInProcessing = NO;
                }
            });
        }
    }
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
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(_searchingQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf) {
            [strongSelf refreshContactOnView];
            strongSelf.dataSourceNeedReloadObservable.value = [NSNumber numberWithUnsignedInteger:0];
            [strongSelf->_contactBus searchContactByName:key block:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSLog(@"[SearchBusRespone]");
                [strongSelf loadBatchOfContacts:^(NSError *error, NSArray<NSIndexPath *> *updatedIndexPaths) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf && !error) {
                        NSLog(@"[LoadBatchResponse]");
                        strongSelf.dataSourceNeedReloadObservable.value = [NSNumber numberWithUnsignedInteger:0];
                    }
                }];
            }];
        }
    });
}

- (void)selectectContactAtIndex:(NSIndexPath *)indexPath {
    ContactViewEntity * contact = [self contactAtIndex:indexPath];
    contact.isChecked = !contact.isChecked;
    
    if (contact.isChecked) {
        [_listSelectedContacts addObject:contact];
        self.selectedContactAddedObservable.value = [NSNumber numberWithUnsignedInteger:_listSelectedContacts.count - 1];
    } else if ([_listSelectedContacts containsObject:contact]) {
        NSUInteger index = [_listSelectedContacts indexOfObject:contact];
        [_listSelectedContacts removeObjectAtIndex:index];
        self.selectedContactRemoveObservable.value = [NSNumber numberWithUnsignedInteger:index];
    }
}

- (void)removeSelectedContact:(NSString *)identifier {
    
    ContactViewEntity * contact = [_listSelectedContacts firstObjectWith:^BOOL(ContactViewEntity*  _Nonnull obj) {
        return [obj.identifier isEqualToString:identifier];
    }];
    
    if ([_listSelectedContacts containsObject:contact]) {
        NSUInteger index = [_listSelectedContacts indexOfObject:contact];
        [_listSelectedContacts removeObjectAtIndex:index];
        self.selectedContactRemoveObservable.value = [NSNumber numberWithUnsignedInteger:index];
    }
    
    if (![self isContainContact:contact]) {
        contact = [self contactWithIdentifier:contact.identifier name:contact.fullName];
    }
    
    contact.isChecked = NO;
    NSIndexPath * index = [self indexOfContact:contact];
    
    self.cellNeedRemoveSelectedObservable.value = index;
}

- (NSArray *)getAllSectionNames {
    return _listSectionKeys;
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
    for (NSString * key in _listSectionKeys) {
        ContactViewEntity * result = [[self.contactsOnView objectForKey:key] firstObjectWith:^BOOL(ContactViewEntity * _Nonnull obj) {
            return [obj.identifier isEqualToString:identifier];
        }];
        if (result)
            return result;
    }

    return nil;
}

- (NSIndexPath * _Nullable)firstContactOnView {
    for(int i = 0; i < _listSectionKeys.count; i++) {
        NSString * key = _listSectionKeys[i];
        if ([contactsOnView objectForKey:key].count > 0) {
            NSLog(@"[firstContactOnView] %ld", [contactsOnView objectForKey:key].count);
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    return nil;
}

#pragma mark - Selected contact implement
- (NSInteger)numberOfSelectedContacts {
    return _listSelectedContacts.count;
}

- (ContactViewEntity *)selectedContactAtIndex:(NSInteger)index {
    return [_listSelectedContacts objectAtIndex:index];
}

#pragma mark - Helper methods

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

- (void)addContacts:(NSArray<ContactViewEntity *> *) contacts completion: (void (^)(NSArray<NSIndexPath *> * updatedIndexPaths)) handler {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(_backgroundQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            
            NSMutableArray<NSIndexPath *> * updatedIndexPaths = [[NSMutableArray alloc] init];
            [contacts enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull newContact, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [strongSelf->_listSelectedContacts enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull selectedContact, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([selectedContact.identifier isEqualToString:newContact.identifier]) {
                        [newContact updateContact:selectedContact];
                    }
                }];
                
                NSString * key                      = [strongSelf makeKeyFromName:newContact.fullName];
                NSMutableArray * contactsInSection  = [strongSelf.contactsOnView objectForKey:key];
                
                NSUInteger row          = contactsInSection.count;
                NSUInteger section      = [strongSelf->_listSectionKeys indexOfObject:key];
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                
                [contactsInSection addObject:newContact];
                [updatedIndexPaths addObject:indexPath];
            }];
            
            handler(updatedIndexPaths);
        }
    });
}

@end