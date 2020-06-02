//
//  ContactViewModel.h
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactViewModel_h
#define ContactViewModel_h
#import "DataBinding.h"
#import <UIKit/UIKit.h>
#import "ContactModel.h"

@interface ContactViewModel : NSObject
@property UIImage* avatar;
@property NSString* name;
@property NSString* activeTime;
-(id) initWithModel: (ContactModel*) model;
-(BOOL) contactStartWith: (NSString*) key;
@end

#endif /* ContactViewModel_h */
