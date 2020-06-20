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
@property (nonatomic, readwrite) NSString   * identifier;
@property (nonatomic, readwrite) NSString   * givenName;
@property (nonatomic, readwrite) NSString   * familyName;
@property (nonatomic, readwrite) NSData     * imageData;

- (id) initWithIdentifier: (NSString *) identifier givenName: (NSString*) givenName familyName: (NSString *) familyName imageData:(NSData * _Nullable) imageData;
- (id) initWithData: (ContactDAL *) contactDAL;
@end

NS_ASSUME_NONNULL_END
