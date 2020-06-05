//
//  ContactViewEntity.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/4/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewEntity : NSObject
@property(nonatomic, readwrite) NSString* identifier;
@property(nonatomic, readwrite) NSString * name;
@property(nonatomic, readwrite) NSString * contactDescription;
@property(nonatomic, readwrite) UIImage * avatar;
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

@end

NS_ASSUME_NONNULL_END
