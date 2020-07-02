//
//  ErrorFactory.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NO_CONTENT_ERROR_CODE           204
#define TOO_MANY_REQUESTS_ERROR_CODE    429
#define RETAIN_CYCLE_GONE_ERROR_CODE    410
#define UNSUPPORTED_ERROR_CODE          415
#define NOT_FOUND_ERROR_CODE            404
#define FAILT_ERROR_CODE                505
#define DEFAULT_ERROR_CODE              1

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ErrorTypeEmpty,
    ErrorTypeFailt,
    ErrorTypeTooManyRequest,
    ErrorTypeRetainCycleGone,
    ErrorTypeNotFound
} ErrorType;

@interface NSError(Addition)
- (instancetype)initWithDomain:(NSString *) domain type:(ErrorType) type localizeString:(NSString *) msg;
@end

NS_ASSUME_NONNULL_END
