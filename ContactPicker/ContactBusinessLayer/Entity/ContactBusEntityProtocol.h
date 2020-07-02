//
//  ContactBusEntityProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactBusEntityProtocol_h
#define ContactBusEntityProtocol_h

@protocol ContactBusEntityProtocol <NSObject>
@property (nonatomic, readwrite) NSString               *identifier;
@property (nonatomic, readwrite) NSString               *givenName;
@property (nonatomic, readwrite) NSString               *familyName;
@property (nonatomic, readwrite) NSArray<NSString *>    *phones;
@end

#endif /* ContactBusEntityProtocol_h */
