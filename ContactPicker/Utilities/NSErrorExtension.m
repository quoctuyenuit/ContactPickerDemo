//
//  ErrorFactory.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "NSErrorExtension.h"

@implementation NSError(Addition)
@dynamic errorType;

- (instancetype)initWithDomain:(NSString *)domain type:(ErrorType)type localizeString:(NSString *)msg {
    
    NSInteger code;
    switch (type) {
        case ErrorTypeEmpty:
            code = NO_CONTENT_ERROR_CODE;
            break;
        case ErrorTypeTooManyRequest:
            code = TOO_MANY_REQUESTS_ERROR_CODE;
            break;
        case ErrorTypeRetainCycleGone:
            code = RETAIN_CYCLE_GONE_ERROR_CODE;
            break;
        case ErrorTypeNotFound:
            code = NOT_FOUND_ERROR_CODE;
            break;
        default:
            code = DEFAULT_ERROR_CODE;
            break;
    }
    NSDictionary * userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat: msg]};
    
    self = [[super init] initWithDomain:domain code:code userInfo:userInfo];
    return self;
}

@end
