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
#import "ContactTableDataSource.h"


#define VIEWMODEL_ERROR_DOMAIN          @"ViewModel Error"

#define CHECK_RETAINCYCLE               0
#if CHECK_RETAINCYCLE
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#endif

#define CONTACT_BATCH_SIZE              200
#define STRONG_SELF_DEALLOCATED_MSG     @"strongSelf had deallocated"

@interface ContactViewModel() {
}
- (void) _setupEvents;
@end

@implementation ContactViewModel

@synthesize searchObservable;

@synthesize contactBookObservable;

@synthesize cellNeedRemoveSelectedObservable;

@synthesize removeContactObservable;

@synthesize selectedContactRemoveObservable;

@synthesize selectedContactAddedObservable;

- (id)initWithBus:(id<ContactBusinessLayerProtocol>)bus {
    _contactBus                 = bus;
    _backgroundSerialQueue      = dispatch_queue_create("[ViewModel] searching queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    _backgroundConcurrentQueue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    // List source initialization
    _dataSource = [ContactTableDataSource dataSource];
    _listSelectedContacts   = [[NSMutableArray alloc] init];

    // Data binding initialization
    self.searchObservable                   = [[DataBinding alloc] initWithValue:@""];
    self.contactBookObservable              = [[DataBinding alloc] initWithValue:nil];
    self.cellNeedRemoveSelectedObservable   = [[DataBinding alloc] initWithValue:nil];
    self.removeContactObservable            = [[DataBinding alloc] initWithValue:nil];
    self.selectedContactAddedObservable     = [[DataBinding alloc] initWithValue:nil];
    self.selectedContactRemoveObservable    = [[DataBinding alloc] initWithValue:nil];
    [self _setupEvents];
    
    return self;
}

#pragma mark - Helper methods

- (void)_setupEvents {
    weak_self
    [_contactBus.contactDidChangedObservable binding:^(NSArray<id<ContactBusEntityProtocol>> * updatedContacts) {
        dispatch_async(weakSelf.backgroundSerialQueue, ^{
            [[ImageManager instance] updateCacheWithComplete:^{
                strong_self
                if (strongSelf) {
                    NSMutableDictionary<NSIndexPath *, ContactViewEntity *> * indexsNeedUpdate = [[NSMutableDictionary alloc] init];
                    
                    for (id<ContactBusEntityProtocol> newContact in updatedContacts) {
                        
                        ContactViewEntity * oldContact = [strongSelf.dataSource objectOfIdentifier:newContact.identifier];
                        if (![oldContact isEqualWithBusEntity:newContact]) {
                            [oldContact updateContactWithBus:newContact];
                            [indexsNeedUpdate setObject:oldContact forKey: [NSIndexPath indexPathForRow:0 inSection:0]];
                        }
                    }
                    strongSelf.contactBookObservable.value = [NSNumber numberWithInt:0];
                }
            }];
            
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
                
                NSIndexPath * indexPath = [strongSelf.dataSource addObject:newContact];
                
                [updatedIndexPaths addObject:indexPath];
            }];
            
            block(updatedIndexPaths);
        }
    });
}

#pragma mark - ContactTableDataSource methods
- (NSInteger)numberOfSection {
    return [_dataSource numberOfSection];
}

- (NSInteger)numberOfContactInSection: (NSInteger) section {
    return [_dataSource numberOfRowsInSection:section];
}

- (ContactViewEntity *)contactAtIndex:(NSIndexPath *)indexPath {
    return [_dataSource objectAtIndexPath:indexPath];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return [_dataSource titleForHeaderInSection:section];
}

- (NSArray *)sectionIndexTitles {
    return [_dataSource sectionIndexTitles];
}

#pragma mark - Selected Contact CollectionDataSource methods
- (NSInteger)numberOfSelectedContacts {
    return _listSelectedContacts.count;
}

- (ContactViewEntity *)selectedContactAtIndex:(NSInteger)index {
    NSAssert(index >= 0 && index < _listSelectedContacts.count, @"Invalid index");
    return [_listSelectedContacts objectAtIndex:index];
}

#pragma mark Public methods
- (void)requestPermissionWithBlock:(void (^)(BOOL, NSError *))block {
    NSAssert(block, @"completion is nil");
    [self->_contactBus requestPermission:block];
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
                            block(updatedIndexPaths, nil);
                        });
                    }];
                    
                } else {
                    if (!strongSelf) {
                        DebugLog(@"[%@] %@", LOG_MSG_HEADER, error.localizedDescription);
                        error = [[NSError alloc] initWithDomain:VIEWMODEL_ERROR_DOMAIN type:ErrorTypeRetainCycleGone localizeString:@"StrongSelf is released"];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, error);
                    });
                }
            }];
        }
    });
}

- (void)refreshTableWithNewData:(NSArray *)contacts
                     completion:(nonnull UpdateTableResponseBlock)block {
    weak_self
    ASPerformBlockOnMainThread(^{
        NSMutableArray * deletedIndexPaths = [NSMutableArray arrayWithArray:[weakSelf.dataSource removeAllObjects]];
        [self _addContacts:contacts block:^(NSArray<NSIndexPath *> *updatedIndexPaths) {
            ASPerformBlockOnMainThread(^{
                block(deletedIndexPaths, updatedIndexPaths);
            });
        }];
    });
}

- (void)searchContactWithKeyName:(NSString *)key block:(SearchResponseBlock)block {
    NSAssert(block, @"block is nil");
    NSAssert(key, @"key is nil");
    weak_self
    dispatch_async(_backgroundSerialQueue, ^{
        strong_self
        if (strongSelf) {
            [strongSelf.contactBus searchContactByName:key block:^(NSArray<id<ContactBusEntityProtocol>> *contacts, NSError *error) {
                if (!error) {
                    NSArray<ContactViewEntity *> *contactsModel = [contacts map:^ContactViewEntity * _Nonnull(id<ContactBusEntityProtocol> _Nonnull obj) {
                        return [[ContactViewEntity alloc] initWithBusEntity:obj];
                    }];
                    block(contactsModel, nil);
                } else {
                    block(nil, error);
                }
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
    
    if (![self.dataSource isContainsObject:contact]) {
        contact = [self.dataSource objectOfIdentifier:contact.identifier];
    }
    
    contact.isChecked = NO;
    NSIndexPath * index = [self.dataSource indexPathOfObject:contact];
    
    self.cellNeedRemoveSelectedObservable.value = index;
}

@end
