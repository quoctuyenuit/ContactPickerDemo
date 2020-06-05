//
//  ContactBusEntity.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactDAL.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactBusEntity : NSObject
@property (nonatomic, readwrite) NSString* contactID;
@property (nonatomic, readwrite) NSString* contactName;
@property (nonatomic, readwrite) NSData* contactImage;

- (id) initWith: (NSString *) contactID name: (NSString*) name image: (NSData *) imageData;
- (id) initWithData: (ContactDAL *) contactDAL;
- (BOOL) fitWithName: (NSString *) name;
@end

NS_ASSUME_NONNULL_END
