//
//  Logging.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/8/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#if DEBUG == 0
#define DebugLog(...)
#elif DEBUG == 1
#define DebugLog(...) NSLog(__VA_ARGS__)
#endif

#import "Logging.h"

@interface Logging()
+ (NSString *)findCallerMethod;
@end

@implementation Logging
+ (NSString *)findCallerMethod
{
    NSString *callerStackSymbol = nil;

    NSArray<NSString *> *callStackSymbols = [NSThread callStackSymbols];

    if (callStackSymbols.count >= 2)
    {
        callerStackSymbol = [callStackSymbols objectAtIndex:2];
        if (callerStackSymbol)
        {
            // Stack: 2   TerribleApp 0x000000010e450b1e -[TALocalDataManager startUp] + 46
            NSInteger idxDash = [callerStackSymbol rangeOfString:@"-" options:kNilOptions].location;
            NSInteger idxPlus = [callerStackSymbol rangeOfString:@"+" options:NSBackwardsSearch].location;

            if (idxDash != NSNotFound && idxPlus != NSNotFound)
            {
                NSRange range = NSMakeRange(idxDash, (idxPlus - idxDash - 1)); // -1 to remove the trailing space.
                callerStackSymbol = [callerStackSymbol substringWithRange:range];

                return callerStackSymbol;
            }
        }
    }

    return (callerStackSymbol) ?: @"Caller not found! :(";
}

+ (void)info:(NSString *)msg {
//    DebugLog(@"%@ \n[Information] %@", [self findCallerMethod], msg);
}

+ (void)exeption:(NSString *)msg {
//    DebugLog(@"%@ \n[Exeption] %@", [self findCallerMethod], msg);
}

+ (void)error:(NSString *)msg {
//    DebugLog(@"%@ \n[Error] %@", [self findCallerMethod], msg);
}
@end
