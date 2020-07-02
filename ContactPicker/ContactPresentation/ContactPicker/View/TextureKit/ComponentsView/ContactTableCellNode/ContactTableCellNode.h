//
//  ContactCellNode.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_TEXTURE
#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewEntity.h"
#import "ContactTableCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableCellNode : ASCellNode <ContactTableCellProtocol>
- (instancetype)initWithContact:(ContactViewEntity *) contact;
@end

NS_ASSUME_NONNULL_END
#endif
