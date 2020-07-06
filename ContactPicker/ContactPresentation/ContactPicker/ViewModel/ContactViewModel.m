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
#import "ContactDefine.h"
#import "NSErrorExtension.h"
#import "ImageManager.h"


#define VIEWMODEL_ERROR_DOMAIN          @"ViewModel Error"

#define CHECK_RETAINCYCLE               0
#if CHECK_RETAINCYCLE
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#endif

#define CONTACT_BATCH_SIZE              200
#define STRONG_SELF_DEALLOCATED_MSG     @"strongSelf had deallocated"

@interface ContactViewModel()
- (void) _setupEvents;
- (void) _initContactOnView;
- (void) _refreshContactOnView;
- (NSArray<NSIndexPath *> *) _getAllIndexPaths;
- (NSString *) _makeKeyFromName: (NSString *) name;
@end

@implementation ContactViewModel

@synthesize searchObservable;

@synthesize contactBookObservable;

@synthesize cellNeedRemoveSelectedObservable;

@synthesize dataSourceNeedReloadObservable;

@synthesize selectedContactRemoveObservable;

@synthesize selectedContactAddedObservable;

- (id)initWithBus:(id<BusinessLayerProtocol>)bus {
    _contactBus                 = bus;
    _backgroundSerialQueue      = dispatch_queue_create("[ViewModel] searching queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _backgroundConcurrentQueue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    //    List source initialization
    _contactsOnView         = [[NSMutableDictionary alloc] init];
    _listSelectedContacts   = [[NSMutableArray alloc] init];
    _listSectionKeys        = [[NSMutableArray alloc] init];
    
    //    Data binding initialization
    self.searchObservable                   = [[DataBinding alloc] initWithValue:@""];
    self.contactBookObservable              = [[DataBinding alloc] initWithValue:nil];
    self.cellNeedRemoveSelectedObservable   = [[DataBinding alloc] initWithValue:nil];
    self.dataSourceNeedReloadObservable     = [[DataBinding alloc] initWithValue:nil];
    self.selectedContactAddedObservable     = [[DataBinding alloc] initWithValue:nil];
    self.selectedContactRemoveObservable    = [[DataBinding alloc] initWithValue:nil];
    
    [self _initContactOnView];
    [self _setupEvents];
    
    return self;
}

#pragma mark - Helper methods
- (void)_initContactOnView {
    for (char i = 'A'; i <= 'Z'; i++) {
        NSString * key = [NSString stringWithFormat:@"%c", i];
        [_contactsOnView setValue:[[NSMutableArray alloc] init] forKey:key];
        [_listSectionKeys addObject:key];
    }
    NSString * key = @"#";
    [_contactsOnView setValue:[[NSMutableArray alloc] init] forKey:key];
    [_listSectionKeys addObject:key];
}

- (void)_setupEvents {
    weak_self
    [_contactBus.contactDidChangedObservable binding:^(NSArray<id<ContactBusEntityProtocol>> * updatedContacts) {
        dispatch_async(weakSelf.backgroundSerialQueue, ^{
            strong_self
            if (strongSelf) {
                [[ImageManager instance] updateCache];
                NSMutableDictionary<NSIndexPath *, ContactViewEntity *> * indexsNeedUpdate = [[NSMutableDictionary alloc] init];
                
                for (id<ContactBusEntityProtocol> newContact in updatedContacts) {
                    
                    for (int section = 0; section < strongSelf.listSectionKeys.count; section++) {
                        NSString * key = [strongSelf.listSectionKeys objectAtIndex:section];
                        NSArray * rowsInSection = [strongSelf.contactsOnView objectForKey:key];
                        for (int row = 0; row < rowsInSection.count; row++) {
                            ContactViewEntity * oldContact = [rowsInSection objectAtIndex:row];
                            
                            if (oldContact &&
                                [oldContact.identifier isEqualToString:newContact.identifier] &&
                                ![oldContact isEqualWithBusEntity:newContact]) {
                                
                                [oldContact updateContactWithBus:newContact];
                                [indexsNeedUpdate setObject:oldContact forKey:[NSIndexPath indexPathForRow:row inSection:section]];
                            }
                            
                        }
                    }
                }
                strongSelf.contactBookObservable.value = indexsNeedUpdate;
            }
        });
    }];
}

- (void)_addContacts:(NSArray<ContactViewEntity *> *) contacts block: (void (^)(NSArray<NSIndexPath *> * updatedIndexPaths)) block {
    NSAssert(block, @"block is nil");
    
    weak_self
    dispatch_async(_backgroundSerialQueue, ^{
        strong_self
        if (strongSelf) {
            
            NSMutableArray<NSIndexPath *> * updatedIndexPaths = [[NSMutableArray alloc] init];
            [contacts enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull newContact, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [strongSelf->_listSelectedContacts enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull selectedContact, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([selectedContact.identifier isEqualToString:newContact.identifier]) {
                        [newContact updateContact:selectedContact];
                    }
                }];
                
                NSString * key                      = [strongSelf _makeKeyFromName:newContact.fullName.string];
                NSMutableArray * contactsInSection  = [strongSelf->_contactsOnView objectForKey:key];
                
                NSUInteger row          = contactsInSection.count;
                NSUInteger section      = [strongSelf->_listSectionKeys indexOfObject:key];
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                
                [contactsInSection addObject:newContact];
                [updatedIndexPaths addObject:indexPath];
            }];
            
            block(updatedIndexPaths);
        }
    });
}

- (void)_refreshContactOnView {
    DebugLog(@"Refresh contactOnView");
    _contactsOnView = [[NSMutableDictionary alloc] init];
    for (char i = 'A'; i <= 'Z'; i++) {
        NSString * key = [NSString stringWithFormat:@"%c", i];
        [_contactsOnView setValue:[[NSMutableArray alloc] init] forKey:key];
    }
    NSString * key = @"#";
    [_contactsOnView setValue:[[NSMutableArray alloc] init] forKey:key];
}

- (NSArray<NSIndexPath *> *)_getAllIndexPaths {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i < _listSectionKeys.count; i++) {
        NSString * key = [_listSectionKeys objectAtIndex:i];
        NSArray * sectionData = [_contactsOnView objectForKey:key];
        for (int j = 0; j < sectionData.count; j++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:j inSection:i]];
        }
    }
    return indexPaths;
}

- (NSString *)_makeKeyFromName:(NSString *)name {
    if (name.length == 0)
        return @"#";
    
    NSString * firstLetter = [[name substringToIndex:1] uppercaseString];
    int letterNumber = [firstLetter characterAtIndex:0];
    return (letterNumber >= 65 && letterNumber <= 90) ? firstLetter : @"#";
}

- (ContactViewEntity *)contactOfIdentifier:(NSString *)identifier name:(NSString *)name {
    NSAssert([identifier isEqualToString:@""], @"identifier is empty");
    
    NSString * key = [self _makeKeyFromName:name];
    NSArray * listContact = [_contactsOnView objectForKey:key];
    return [listContact firstObjectWith:^BOOL(ContactViewEntity * _Nonnull obj) {
        return [obj.identifier isEqualToString:identifier];
    }];
}

- (BOOL)isContainContact:(ContactViewEntity *)contact {
    NSAssert(contact, @"Contact is nil");
    
    NSString * key = [self _makeKeyFromName:contact.fullName.string];
    NSArray * listContacts = [_contactsOnView objectForKey:key];
    return listContacts ? [listContacts containsObject:contact] : NO;
}

- (NSIndexPath *)indexOfContact:(ContactViewEntity *)contact {
    NSAssert(contact, @"Contact is nil");
    
    NSString * key = [self _makeKeyFromName:contact.fullName.string];
    NSInteger section = [self->_listSectionKeys indexOfObject:key];
    NSArray * listContacts = [_contactsOnView objectForKey:key];
    NSInteger row = [listContacts indexOfObject:contact];
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (ContactViewEntity * _Nullable)contactOfIdentifier:(NSString *)identifier {
    NSAssert([identifier isEqualToString:@""], @"identifier is empty");
    
    for (NSString * key in _listSectionKeys) {
        ContactViewEntity * result = [[_contactsOnView objectForKey:key] firstObjectWith:^BOOL(ContactViewEntity * _Nonnull obj) {
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
        if ([_contactsOnView objectForKey:key].count > 0) {
            DebugLog(@"[firstContactOnView] %ld", [_contactsOnView objectForKey:key].count);
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    return nil;
}

#pragma mark - ContactTableDataSource methods
- (NSInteger)numberOfSection {
    return [_contactsOnView allKeys].count;
}

- (NSInteger)numberOfContactInSection: (NSInteger) section {
    NSString * key = [self parseSectionToKey:(int)section];
    return [_contactsOnView objectForKey:key].count;
}

- (ContactViewEntity *)contactAtIndex:(NSIndexPath *)indexPath {
    NSString * key = [self parseSectionToKey:(int)indexPath.section];
    NSArray * rows = [_contactsOnView objectForKey:key];
    
    NSAssert(indexPath.row >= 0 && indexPath.row < rows.count, @"Invalid row in IndexPath");
    
    return [[_contactsOnView objectForKey:key] objectAtIndex:indexPath.row];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSAssert(section >= 0 && section < self.listSectionKeys.count, @"invalid section");
    return [self->_listSectionKeys objectAtIndex:section];
}

- (NSArray *)sectionIndexTitles {
    return _listSectionKeys;
}

#pragma mark - Selected Contact CollectionDataSource methods
- (NSInteger)numberOfSelectedContacts {
    return _listSelectedContacts.count;
}

- (ContactViewEntity *)selectedContactAtIndex:(NSInteger)index {
    NSAssert(index >= 0 && index < _listSelectedContacts.count, @"Invalid index");
    return [_listSelectedContacts objectAtIndex:index];
}


- (NSString *) parseSectionToKey: (int) section {
    NSAssert(section >= 0 && section < self.listSectionKeys.count, @"invalid section");
    return [self->_listSectionKeys objectAtIndex:section];
}

#pragma mark Public methods
- (void)requestPermission:(void (^)(BOOL, NSError *))completion {
    NSAssert(completion, @"completion is nil");
    [self->_contactBus requestPermission:completion];
}

- (void)loadContactsWithBlock:(ViewModelResponseListBlock)block {
    NSAssert(block, @"block is nil");
    
    weak_self
    dispatch_async(_backgroundSerialQueue, ^{
        strong_self
        if (strongSelf) {
            [strongSelf->_contactBus loadContactsWithBlock:^(NSArray<id<ContactBusEntityProtocol>> *contacts, NSError *error) {
                strong_self
                if (strongSelf && !error) {
                    NSArray<ContactViewEntity *> *contactEntity = [contacts map:^ContactViewEntity * _Nonnull(id<ContactBusEntityProtocol> _Nonnull obj) {
                        return [[ContactViewEntity alloc] initWithBusEntity:obj];
                    }];
                    
                    [strongSelf _addContacts:contactEntity block:^(NSArray<NSIndexPath *> *updatedIndexPaths) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(contactEntity, updatedIndexPaths, nil);
                        });
                    }];
                    
                } else {
                    if (!strongSelf) {
                        DebugLog(@"[%@] %@", LOG_MSG_HEADER, error.localizedDescription);
                        error = [[NSError alloc] initWithDomain:VIEWMODEL_ERROR_DOMAIN type:ErrorTypeRetainCycleGone localizeString:@"StrongSelf is released"];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, nil, error);
                    });
                }
            }];
        }
    });
}

- (void)searchContactWithKeyName:(NSString *)key block:(ViewModelResponseListBlock) block {
    NSAssert(block, @"block is nil");
    NSAssert(key, @"key is nil");
    weak_self
    dispatch_async(_backgroundSerialQueue, ^{
        strong_self
        if (strongSelf) {
            NSArray * allIndexes = [strongSelf _getAllIndexPaths];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [strongSelf _refreshContactOnView];
                strongSelf.dataSourceNeedReloadObservable.value = allIndexes;
            });
            [strongSelf.contactBus searchContactByName:key block:^(NSArray<id<ContactBusEntityProtocol>> *contacts, NSError *error) {
                
                NSArray<ContactViewEntity *> *contactEntity = [contacts map:^ContactViewEntity * _Nonnull(id<ContactBusEntityProtocol> _Nonnull obj) {
                    return [[ContactViewEntity alloc] initWithBusEntity:obj];
                }];
                
                [strongSelf _addContacts:contactEntity block:^(NSArray<NSIndexPath *> *updatedIndexPaths) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(contactEntity, updatedIndexPaths, nil);
                    });
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
        self.selectedContactAddedObservable.value = [NSIndexPath indexPathForRow:_listSelectedContacts.count - 1 inSection:0];
    } else {
        for (int i = 0; i < _listSelectedContacts.count; i++) {
            if ([contact.identifier isEqualToString:_listSelectedContacts[i].identifier]) {
                [_listSelectedContacts removeObjectAtIndex:i];
                self.selectedContactRemoveObservable.value = [NSIndexPath indexPathForRow:i inSection:0];
                return;
            }
        }
    }
}

- (void)removeSelectedContact:(NSString *)identifier {
    NSAssert(identifier, @"identifier is nil");
    ContactViewEntity * contact = [_listSelectedContacts firstObjectWith:^BOOL(ContactViewEntity*  _Nonnull obj) {
        return [obj.identifier isEqualToString:identifier];
    }];
    
    if ([_listSelectedContacts containsObject:contact]) {
        NSUInteger index = [_listSelectedContacts indexOfObject:contact];
        [_listSelectedContacts removeObjectAtIndex:index];
        self.selectedContactRemoveObservable.value = [NSIndexPath indexPathForRow:index inSection:0];
    }
    
    if (![self isContainContact:contact]) {
        contact = [self contactOfIdentifier:contact.identifier name:contact.fullName.string];
    }
    
    contact.isChecked = NO;
    NSIndexPath * index = [self indexOfContact:contact];
    
    self.cellNeedRemoveSelectedObservable.value = index;
}
@end
