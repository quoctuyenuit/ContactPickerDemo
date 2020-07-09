//
//  ContactAvatarNode.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_TEXTURE
#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactAvatarNode : ASDisplayNode {
    ASDisplayNode   * _mainBoundNode;
    ASImageNode     * _imageNode;
    ASTextNode      * _label;
}

- (instancetype) init;
- (void) configWithImage: (UIImage * _Nullable) image withTitle: (NSString *) label;
@end

NS_ASSUME_NONNULL_END
#endif
