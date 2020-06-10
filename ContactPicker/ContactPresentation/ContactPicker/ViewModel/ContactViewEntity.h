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

@interface ContactViewEntity : NSObject
@property(nonatomic, readwrite) NSString *_Nonnull identifier;
@property(nonatomic, readwrite) NSString *_Nullable name;
@property(nonatomic, readwrite) NSString *_Nullable contactDescription;
@property(nonatomic, readwrite) UIImage *_Nullable avatar;
@property(nonatomic, readwrite) BOOL isChecked;
@property(nonatomic, readwrite) void (^ _Nullable waitImageToExcuteQueue)(UIImage *_Nonnull, NSString *_Nonnull );

- (id _Nullable ) initWithIdentifier: (NSString *_Nonnull) identifier
                     name: (NSString *_Nullable) name
              description: (NSString *_Nullable) description
                   avatar: (UIImage *_Nullable) image
                isChecked: (BOOL) isChecked;

- (id _Nullable) initWithIdentifier: (NSString *_Nonnull) identifier
                               name: (NSString *_Nullable) name
                        description: (NSString *_Nullable) description
                             avatar: (UIImage *_Nullable) image;

- (id _Nullable) initWithIdentifier: (NSString *_Nonnull) identifier
                               name: (NSString *_Nullable) name
                        description: (NSString *_Nullable) description;

- (BOOL)contactHasPrefix: (NSString *_Nonnull) key;
@end

#endif /* ContactViewModel_h */
