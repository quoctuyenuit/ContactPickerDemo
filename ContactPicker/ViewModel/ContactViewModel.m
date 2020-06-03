//
//  ContactViewModel.m
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactViewModel.h"
#import "ContactModel.h"
#import <UIKit/UIKit.h>

@interface ContactViewModel()

- (NSString*)formatTime: (float) timeInterval;
@end

@implementation ContactViewModel

- (id)initWithModel:(ContactModel*)model {
    self.avatar = model.avatar;
    self.name = model.name;
    self.activeTime = [self formatTime:model.activateTime];
    return self;
}

- (NSString*)formatTime:(float)timeInterval {
    NSDate *lastUpdate = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:lastUpdate];
}

- (BOOL)contactStartWith:(NSString *)key {
    if ([key isEqualToString:@""]) {
        return true;
    }
    return [[self.name lowercaseString] hasPrefix: [key lowercaseString]];
}
@end
