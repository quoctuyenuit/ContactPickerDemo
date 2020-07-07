//
//  ContactBusProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactBusProtocol_h
#define ContactBusProtocol_h
#import "ContactBusEntityProtocol.h"
#import "DataBinding.h"
#import <UIKit/UIKit.h>

typedef void(^BusinessResponseListBlock)(NSArray<id<ContactBusEntityProtocol>> * contacts, NSError * error);
typedef void(^BusinessResponseContactBlock)(id<ContactBusEntityProtocol> contact, NSError * error);
typedef void(^BusinessResponseListImageBlock)(NSDictionary<NSString *, UIImage *> * images, NSError * error);

@protocol ContactBusinessLayerProtocol <NSObject>
@property(nonatomic, readwrite) DataBinding< NSArray<id<ContactBusEntityProtocol>> *> *contactDidChangedObservable;

@required

- (void) requestPermission: (void (^)(BOOL granted, NSError * error)) completion;

- (void) loadContactsWithBlock: (BusinessResponseListBlock) block;

- (void) searchContactByName: (NSString *) name
                       block: (BusinessResponseListBlock) block;
@end

#endif /* ContactBusProtocol_h */
