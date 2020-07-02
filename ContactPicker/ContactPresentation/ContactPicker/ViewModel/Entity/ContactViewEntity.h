//
//  ContactViewModel.h
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactViewModel_h
#define ContactViewModel_h
#import "DataBinding.h"
#import <UIKit/UIKit.h>
#import "ContactBusEntityProtocol.h"
#import "DataBinding.h"
#import "Utilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewEntity : NSObject
@property(nonatomic, readwrite) NSString                *identifier;
@property(nonatomic, readwrite) NSAttributedString      *fullName;
@property(nonatomic, readwrite) NSAttributedString      *phone;
@property(nonatomic, readwrite) BOOL                    isChecked;
@property(nonatomic, readonly) NSString                 *keyName;
@property(nonatomic, readwrite) DataBinding<NSNumber *> *isCheckObservable;

- (id) initWithIdentifier: (NSString *) identifier
                givenName: (NSString *) givenName
               familyName: (NSString *) familyName
                    phone: (NSString * _Nullable) phone
                isChecked: (BOOL) isChecked;

- (id) initWithBusEntity:(id<ContactBusEntityProtocol>) entity;

- (void) updateContactWithBus:(id<ContactBusEntityProtocol>) entity;

- (void) updateContact: (ContactViewEntity *) entity;

- (BOOL) isEqualWithBusEntity: (id<ContactBusEntityProtocol>) entity;
@end

NS_ASSUME_NONNULL_END
#endif /* ContactViewModel_h */
