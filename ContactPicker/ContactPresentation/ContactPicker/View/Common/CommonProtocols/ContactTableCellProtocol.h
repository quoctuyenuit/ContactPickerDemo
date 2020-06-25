//
//  ContactTableCellProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactTableCellProtocol_h
#define ContactTableCellProtocol_h
#import "ContactViewEntity.h"

@protocol ContactTableCellProtocol <NSObject>
- (void)setSelect;
- (void)configForModel: (ContactViewEntity *) entity;
@end

#endif /* ContactTableCellProtocol_h */
