//
//  ContactTableProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactTableProtocol_h
#define ContactTableProtocol_h

#import "ContactViewEntity.h"

@protocol ContactTableDelegate
@required
- (void) didSelectContact: (ContactViewEntity *) contact;
@end

#endif /* ContactTableProtocol_h */
