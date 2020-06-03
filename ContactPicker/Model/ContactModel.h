//
//  Contact.h
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactModel_h
#define ContactModel_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ContactModel: NSObject {
    NSString *_name;
    UIImage *_avatar;
    float _activeTime;
}

@property (nonatomic, readwrite) NSString* name;
@property (nonatomic, readwrite) UIImage* avatar;
@property (nonatomic, readwrite) float activateTime;
- (id)initWithName: (NSString*) name
                 avatar: (UIImage*) avatar
             activeTime: (float) activeTime;

@end

#endif /* Contact_h */
