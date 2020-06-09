//
//  ContactDALProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/9/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactDALProtocol_h
#define ContactDALProtocol_h
@protocol ContactDALProtocol <NSObject>

@property (nonatomic, readwrite) NSString * contactID;
@property (nonatomic, readwrite) NSString * contactName;
@property (nonatomic, readwrite) NSString * contactFamilyName;
@property (nonatomic, readwrite) NSArray<NSString *> * contactPhones;
@property (nonatomic, readwrite) NSArray<NSString *> * contactEmails;

@end

#endif /* ContactDALProtocol_h */
