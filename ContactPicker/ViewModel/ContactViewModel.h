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

@interface ContactViewModel : NSObject
@property(nonatomic, readwrite) NSString * identifier;
@property(nonatomic, readwrite) NSString * name;
@property(nonatomic, readwrite) NSString * contactDescription;
@property(nonatomic, readwrite) UIImage * _Nullable avatar;
@property(nonatomic, readwrite) BOOL isChecked;
@property(nonatomic, readwrite) void (^waitImageToExcuteQueue)(UIImage *, NSString * );

- (id) initWithIdentifier: (NSString *) identifier
                     name: (NSString *) name
              description: (NSString *) description
                   avatar: (UIImage * _Nullable) image
                isChecked: (BOOL) isChecked;
                  

- (id) initWithIdentifier: (NSString *) identifier
                     name: (NSString *) name
              description: (NSString *) description
                   avatar: (UIImage * _Nullable) image;

- (id) initWithIdentifier: (NSString *) identifier
                     name: (NSString *) name
              description: (NSString *) description;

- (BOOL)contactHasPrefix: (NSString *) key;
@end

#endif /* ContactViewModel_h */
