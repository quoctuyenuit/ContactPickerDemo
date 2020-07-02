//
//  CheckBoxNode.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_TEXTURE
#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "CheckBoxButtonDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface CheckBoxNode : ASButtonNode {
    BOOL            _isChecked;
}
@property (nonatomic, readwrite) BOOL         isChecked;

@property (weak, nonatomic) id<CheckBoxButtonDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
#endif
