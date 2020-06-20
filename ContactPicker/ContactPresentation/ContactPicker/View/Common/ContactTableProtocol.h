//
//  ContactTableProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/20/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactTableProtocol_h
#define ContactTableProtocol_h
#import <UIKit/UIKit.h>
#import "ContactViewModelProtocol.h"

@protocol ContactTableProtocol <NSObject>
- (void)resetAllData;
@end

#endif /* ContactTableProtocol_h */
