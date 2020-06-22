//
//  CheckBoxComponent.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "CheckBoxComponent.h"
#import <ComponentKit/ComponentKit.h>

@implementation CheckBoxComponent

+ (instancetype)newWithState:(BOOL)state {
    CKComponentScope scope(self);
    return [super newWithComponent:[CKButtonComponent newWithAction:{scope, @selector(checkAction:event:)} options:{
        .backgroundImages = {{UIControlStateNormal, [UIImage imageNamed:@"unchecked_img"]}}
    }]];
    return nil;
}

- (void)checkAction:(CKButtonComponent *) sender event:(UIEvent *) event {
    
}

@end
