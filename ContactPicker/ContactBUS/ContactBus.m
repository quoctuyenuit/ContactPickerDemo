//
//  ContactBus.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactBus.h"
#import "ContactDAL.h"
#import "NSArrayExtension.h"
#import "ContactBusEntity.h"
#import <UIKit/UIKit.h>


@interface ContactBus() {
    int busBatchSize;
    NSMutableArray<ContactDAL *> * listContactRequestedInfor;
}
- (void) getContactBatchStartWith: (int) index
                        batchSize: (int) batchSize
                       completion: (void (^)(NSArray<ContactBusEntity *> *)) handler;

- (void) getContactBatchWithIdentifiers: (NSArray *) identifiers completion: (void (^)(NSArray<ContactBusEntity *> *)) handler;
@end

@implementation ContactBus
@synthesize currentIndexBatch;


- (id)initWithAdapter:(id<ContactAdapterProtocol>)adapter {
    self->contactAdapter = adapter;
    self->busBatchSize = 20;
    self->currentIndexBatch = 0;
    self->listContactRequestedInfor = [[NSMutableArray alloc] init];
    return self;
}

- (void)getContactBatchStartWith:(int)index
                       batchSize: (int) batchSize
                      completion:(void (^)(NSArray<ContactBusEntity *> *))handler {
    int batchSizeNeeded = (index + batchSize) >= self->listContactRequestedInfor.count ?  (int)self->listContactRequestedInfor.count - index : batchSize;
    
    NSArray* batch = [self->listContactRequestedInfor subarrayWithRange:NSMakeRange(index, batchSizeNeeded)];
    
    NSArray *batchIdentifiers = [batch map:^NSString* _Nonnull(ContactDAL*  _Nonnull obj) {
        return obj.contactID;
    }];
    
    [self getContactBatchWithIdentifiers:batchIdentifiers completion:handler];
}

- (void)getContactBatchWithIdentifiers:(NSArray *)identifiers completion:(void (^)(NSArray<ContactBusEntity *> *))handler {
    [self->contactAdapter loadContactByBatch:identifiers completion:^(NSArray<ContactDAL*> * listContacts) {
        
        NSArray* listContactBusEntitys = [listContacts map:^ContactBusEntity* _Nonnull(ContactDAL*  _Nonnull obj) {
            return [[ContactBusEntity alloc] initWithData:obj];
        }];
        
        //        NSMutableArray* dummyData = [NSMutableArray new];
        //
        //        for (int i =0; i < 3 * batchSize / 80; i++)
        //        {
        //            [dummyData addObjectsFromArray:[listContactBusEntitys copy]];
        //        }
        
        handler([listContactBusEntitys copy]);
    }];
}

- (void)requestPermission:(void (^)(BOOL))completion {
    [self->contactAdapter requestPermission:completion];
}

- (void)loadContacts:(void (^)(BOOL))completion {
    [self->contactAdapter loadContacts:^(NSArray<ContactDAL *> * listContactRequestedInfor, BOOL isSuccess) {
//        self->listContactIdentifiers = listContactIdentifiers;
//        NSMutableArray* dummyData = [NSMutableArray new];
        
//        for (int i =0; i < 50; i++)
//        {
//            [dummyData addObjectsFromArray:[listContactIdentifiers copy]];
//        }
        
        [self->listContactRequestedInfor addObjectsFromArray: listContactRequestedInfor];
        completion(isSuccess);
    }];
}

- (void)getImageFor:(NSString *)identifier completion:(void (^)(UIImage *))handler {
    [self->contactAdapter loadImageFromId:identifier completion:^(NSData *imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        handler(image);
    }];
}

- (void)searchContactByName:(NSString *)name completion:(void (^)(NSArray *))handler {
    NSArray * listContactNeed = [self->listContactRequestedInfor filter:^BOOL(ContactDAL*  _Nonnull obj) {
        NSString * contactName = [NSString stringWithFormat:@"%@ %@", obj.contactName, obj.contactFamilyName];
        
        if ([name isEqualToString:@""])
            return YES;
        
        return [[contactName lowercaseString] hasPrefix:[name lowercaseString]];
    }];
    
    NSArray *batchIdentifiers = [listContactNeed map:^NSString* _Nonnull(ContactDAL*  _Nonnull obj) {
        return obj.contactID;
    }];
    
    [self getContactBatchWithIdentifiers:batchIdentifiers completion:handler];
}

- (void)loadBatch:(void (^)(NSArray<ContactBusEntity *> *))handler {
    if (self->currentIndexBatch >= self->listContactRequestedInfor.count)
        return;
    
    int gap = (int)self->listContactRequestedInfor.count - self->currentIndexBatch;
    int batchSize = gap >= self->busBatchSize ? self->busBatchSize : gap;
    
    [self getContactBatchStartWith:self->currentIndexBatch batchSize: batchSize completion:^(NSArray<ContactBusEntity *> * listContacts) {
        self->currentIndexBatch += listContacts.count;
        handler(listContacts);
    }];
}

@end
