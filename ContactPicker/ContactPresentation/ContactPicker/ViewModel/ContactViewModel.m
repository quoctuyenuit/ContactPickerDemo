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

@interface ContactViewModel() {
    BOOL _contactIsLoaded;
    BOOL _loadContactIsDone;
    BOOL _isSearching;
    BOOL _isSearchDone;
    int _contactHadLoadedCount;
    int _contactHadShowFromSearch;
    
    dispatch_queue_t _updateViewQueue;
    dispatch_queue_t _searchResponseQueue;
    dispatch_queue_t _loadIntoBufferQueue;
    dispatch_queue_t _loadFromSearchBufferQueue;
    
    NSString * _waitingSearchResult;
    NSTimer * _loadContactTimer;
    NSMutableArray<ContactViewEntity *> * _contactsBufferFromBus;
//    For search
    NSMutableDictionary<NSString *, NSMutableArray<ContactViewEntity *> *> * _contactsBufferDic;
    NSMutableArray<ContactViewEntity *> * _contactSearchBuffer;
    NSTimer * _searchUpdateTimer;
    
    NSLock * _threadLock;
}

- (void) setupEvents;
- (ContactViewEntity *) parseContactEntity: (ContactBusEntity *) entity;
- (NSString *) makeKeyFromName: (NSString *) name;
- (void) refreshContactOnView;
- (void) addContactIntoBufferDic: (NSArray<ContactBusEntity *> *) listContacts;
- (void) loadContactFromSourceBuffer;
@end

@implementation ContactViewModel

@synthesize listSelectedContacts = _listSelectedContacts;

@synthesize contactBus = _contactBus;

@synthesize searchObservable;

@synthesize contactBookObservable;

@synthesize contactHadAddedObservable;

@synthesize cellNeedRemoveSelectedObservable;

@synthesize dataSourceNeedReloadObservable;

@synthesize selectedContactRemoveObservable;

@synthesize selectedContactAddedObservable;

- (id)initWithBus:(id<ContactBusProtocol>)bus {
    self->_contactBus = bus;
    self->_contactIsLoaded = NO;
    self->_loadContactIsDone = NO;
    self->_isSearching = NO;
    self->_isSearchDone = NO;
    self->_contactHadLoadedCount = 0;
    self->_contactHadShowFromSearch = 0;
    self->_loadContactTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                               target:self
                                                             selector:@selector(loadSourceContactByTimer)
                                                             userInfo:nil repeats:YES];
    
    self->_searchUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                   target:self
                                                                 selector:@selector(loadSearchContactByTimer)
                                                                 userInfo:nil repeats:YES];
    
    self->_updateViewQueue = dispatch_queue_create("update queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -2));
    self->_searchResponseQueue = dispatch_queue_create("search queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -2));
    self->_loadIntoBufferQueue = dispatch_queue_create("load contact into buffer queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -2));
    self->_loadFromSearchBufferQueue = dispatch_queue_create("load contact into buffer queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -2));
       
//    List source initialization
    self->_contactsBufferDic = [[NSMutableDictionary alloc] init];
    self.contactsOnView = [[NSMutableDictionary alloc] init];
    self.contactsBackup = self.contactsOnView;
    
    self.listSelectedContacts = [[NSMutableArray alloc] init];
    self->_listSectionKeys = [[NSMutableArray alloc] init];
    self->_contactsBufferFromBus = [[NSMutableArray alloc] init];
    self->_contactSearchBuffer = [[NSMutableArray alloc] init];
    
//    Data binding initialization
    self.searchObservable = [[DataBinding<NSString *> alloc] initWithValue:@""];
    self.contactBookObservable = [[DataBinding<NSNumber *> alloc] initWithValue:[NSNumber numberWithInt:0]];
    self.contactHadAddedObservable = [[DataBinding<NSArray<NSIndexPath *> *> alloc] initWithValue:nil];
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
    
    
    self->_threadLock = [[NSLock alloc] init];
    
    [self setupEvents];
    
    return self;
}

- (void)loadSearchContactByTimer {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"timer fired");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf loadContactFromSearchBuffer];
//            if (strongSelf->_isSearchDone) {
//                [strongSelf->_searchUpdateTimer invalidate];
//                strongSelf->_searchUpdateTimer = nil;
//                return;
//            }
        }
    });
}

- (void)loadSourceContactByTimer {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"timer fired");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            
            [strongSelf loadContactFromSourceBuffer];
            
            if (strongSelf->_loadContactIsDone && strongSelf->_contactHadLoadedCount == strongSelf->_contactsBufferFromBus.count) {
                [strongSelf->_loadContactTimer invalidate];
                strongSelf->_loadContactTimer = nil;
                [Logging info:@"Contact has loaded done, timer is stoped"];
                return;
            }
        }
    });
}

- (void)loadContactFromSearchBuffer {
    dispatch_async(self->_loadFromSearchBufferQueue, ^{
        __weak typeof(self) weakSelf = self;
        int index = self->_contactHadShowFromSearch;
        NSUInteger length = self->_contactSearchBuffer.count - index;
        if (length > 100)
            length = 100;
        self->_contactHadShowFromSearch += (int)length;
        NSArray<ContactViewEntity *> * batch = [self->_contactSearchBuffer subarrayWithRange:NSMakeRange(index, length)];
        NSLog(@"[Current Thread] %@", [NSThread currentThread]);
        [self addContacts:batch forDic:self->_contactsOnView completion:^(NSArray<NSIndexPath *> * updatedIndexPaths) {
            __strong typeof(weakSelf) strongBlockSelf = weakSelf;
            
            if (strongBlockSelf) {
                
                
                //            strongBlockSelf->_contactHadShowFromSearch += updatedIndexPaths.count;
                [Logging info:[NSString stringWithFormat: @"[Searching] Load more %lu contact(s)", updatedIndexPaths.count]];
                if (updatedIndexPaths.count > 0) {
                    NSLog(@"Searched %d contacts", (int)updatedIndexPaths.count);
                    strongBlockSelf.contactHadAddedObservable.value = updatedIndexPaths;
                    
                }
            }
        }];
    });
}

- (void)loadContactFromSourceBuffer {
    __weak typeof(self) weakSelf = self;
    NSUInteger length = self->_contactsBufferFromBus.count - self->_contactHadLoadedCount;
    if (length > 100)
        length = 100;
    NSArray<ContactViewEntity *> * batch = [self->_contactsBufferFromBus subarrayWithRange:NSMakeRange(self->_contactHadLoadedCount, length)];
    
    [self addContacts:batch forDic:self->_contactsBackup completion:^(NSArray<NSIndexPath *> * updatedIndexPaths) {
        __strong typeof(weakSelf) strongBlockSelf = weakSelf;
        
        if (strongBlockSelf) {
            strongBlockSelf->_contactHadLoadedCount += updatedIndexPaths.count;
            if (!strongBlockSelf->_isSearching) {
                [Logging info:[NSString stringWithFormat: @"[Loading] Load more %lu contact(s)", updatedIndexPaths.count]];
                strongBlockSelf.contactHadAddedObservable.value = updatedIndexPaths;
            }
        }
    }];
}

- (void) addContactIntoBufferDic:(NSArray<ContactBusEntity *> *) listContacts {
    __weak typeof(self) weakSelf = self;
    [listContacts enumerateObjectsUsingBlock:^(ContactBusEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSString * key = [strongSelf makeKeyFromName:obj.givenName];
            
            NSMutableArray * contactsInSection = [strongSelf->_contactsBufferDic objectForKey:key];
            if (contactsInSection)
                [contactsInSection addObject:obj];
            else {
                [strongSelf->_contactsBufferDic setValue:[[NSMutableArray alloc] initWithObjects:obj, nil] forKey:key];
            }
        }
    }];
}

- (void)addContacts:(NSArray *)batchOfContact forDic: (NSMutableDictionary *) dic completion: (void(^)(NSArray<NSIndexPath *> *)) handler {
    __weak typeof(self) weakSelf = self;
    
    dispatch_sync(self->_updateViewQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableArray<NSIndexPath *> * updatedIndexPaths = [[NSMutableArray alloc] init];
            [batchOfContact enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull newContact, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [strongSelf.listSelectedContacts enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull selectedContact, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([selectedContact.identifier isEqualToString:newContact.identifier]) {
                        [newContact updateContact:selectedContact];
                    }
                }];
                
                NSString * key = [strongSelf makeKeyFromName:newContact.fullName];
                
                NSUInteger section = [self->_listSectionKeys indexOfObject:key];
                
                NSMutableArray * contactsInSection = [dic objectForKey:key];
                
                NSUInteger row = contactsInSection.count;
                
                [contactsInSection addObject:newContact];
                
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                
                [updatedIndexPaths addObject:indexPath];
            }];
            
            handler(updatedIndexPaths);
            
        }
    });
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
                
                dispatch_async(strongSelf->_loadIntoBufferQueue, ^{
                    NSArray * contacts = [listContactFromBus map:^ContactViewEntity * _Nonnull(ContactBusEntity * _Nonnull obj) {
                        return [strongSelf parseContactEntity:obj];
                    }];
                    [strongSelf->_contactsBufferFromBus addObjectsFromArray:contacts];
                    [strongSelf addContactIntoBufferDic:contacts];
                    
                    if (!strongSelf->_contactIsLoaded) {
                        
//                        load contact onto view immediately in the first batch loaded
                        [strongSelf loadContactFromSourceBuffer];
                        
                        completion(YES, nil, self->_contactHadLoadedCount);
                        strongSelf->_contactIsLoaded = YES;
                    }
                    strongSelf->_loadContactIsDone = isDone;
                });
            
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
    self->_isSearching = NO;
    self->_isSearchDone = NO;
    self->_contactHadShowFromSearch = 0;
    self->_contactSearchBuffer = [[NSMutableArray alloc] init];

    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self->_searchResponseQueue, ^{
        self->_isSearching = YES;
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            if ([key isEqualToString:@""]) {
                strongSelf.contactsOnView = strongSelf.contactsBackup;
                strongSelf.dataSourceNeedReloadObservable.value = [NSNumber numberWithUnsignedInteger:0];
                self->_isSearching = NO;
                return;
            }
            int i = 0;
            
            NSString * firstLetter = [key substringToIndex:1];
            NSString * contactKey = [strongSelf->_listSectionKeys containsObject:firstLetter] ? firstLetter : @"#";
            NSMutableArray * section = [strongSelf->_contactsBufferDic objectForKey:contactKey];
            
            [strongSelf refreshContactOnView];
            
            strongSelf.dataSourceNeedReloadObservable.value = [NSNumber numberWithUnsignedInteger:0];
            BOOL haveResult = NO;
            
            while (i < section.count && self->_isSearching) {
                ContactViewEntity * contact = [section objectAtIndex:i];
                
                if ([contact contactHasPrefix:key]) {
                    [strongSelf->_contactSearchBuffer addObject:contact];
//                    if (!haveResult) {
//                        haveResult = YES;
//                        [strongSelf loadContactFromSearchBuffer];
//                    }
                }
                
                if (strongSelf->_loadContactIsDone || i < section.count)
                    i++;
            }
            self->_isSearchDone = YES;
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
    
    self.cellNeedRemoveSelectedObservable.value = index;
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
