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
    NSString *_identifier;
    NSString *_name;
}

@property (nonatomic, readwrite) NSString* identifier;
@property (nonatomic, readwrite) NSString* name;

- (id)initWithIdentifier: (NSString *) identifier name: (NSString *) name;

@end

#endif /* Contact_h */
