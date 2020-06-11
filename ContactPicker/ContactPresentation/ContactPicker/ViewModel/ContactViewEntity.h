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
#import "ContactBusEntity.h"

@interface ContactViewEntity : NSObject
@property(nonatomic, readwrite) NSString * _Nonnull identifier;
@property(nonatomic, readwrite) NSString * _Nullable fullName;
@property(nonatomic, readwrite) NSString * _Nullable givenName;
@property(nonatomic, readwrite) NSString * _Nullable familyName;
@property(nonatomic, readwrite) NSString * _Nullable contactDescription;
@property(nonatomic, readwrite) UIImage * _Nullable avatar;
@property(nonatomic, readwrite) UIColor * _Nullable backgroundColor;
@property(nonatomic, readwrite) BOOL isChecked;
@property(nonatomic, readwrite) void (^ _Nullable waitImageToExcuteQueue)(UIImage *_Nonnull, NSString *_Nonnull );

- (id _Nonnull ) initWithIdentifier: (NSString *_Nonnull) identifier
                          givenName: (NSString *_Nullable) givenName
                         familyName: (NSString *_Nullable) familyName
              description: (NSString *_Nullable) description
                   avatar: (UIImage *_Nullable) image
                isChecked: (BOOL) isChecked;

- (id _Nonnull ) initWithBusEntity: (ContactBusEntity *) entity;

- (void) updateContactWith: (ContactBusEntity *) entity;

- (BOOL)contactHasPrefix: (NSString *_Nonnull) key;

- (BOOL) isEqualWithBusEntity: (ContactBusEntity *) entity;
@end

#endif /* ContactViewModel_h */
