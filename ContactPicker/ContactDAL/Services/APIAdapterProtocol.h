//
//  APIAdapterProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef APIAdapterProtocol_h
#define APIAdapterProtocol_h

@protocol APIAdapterProtocol <NSObject>

- (void) getRequestFrom: (NSString *) url
             completion: (void (^)(NSData *, BOOL)) completion;

@end

@protocol ImageGeneratorProtocol <NSObject>

- (void) generateImageFromName: (NSString*) name completion: (void (^)(NSData*, BOOL)) handle;

@end

#endif /* APIAdapterProtocol_h */
