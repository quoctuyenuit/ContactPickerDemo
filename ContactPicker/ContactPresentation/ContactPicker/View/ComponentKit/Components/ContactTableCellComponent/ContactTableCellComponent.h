//
//  ContactTableCellComponent.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/ComponentKit.h>
#import "ContactViewEntity.h"
#import "ContactTableCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableCellComponent : CKCompositeComponent <ContactTableCellProtocol>
+ (instancetype)newWithContact:(ContactViewEntity *) contact;
@end

NS_ASSUME_NONNULL_END
