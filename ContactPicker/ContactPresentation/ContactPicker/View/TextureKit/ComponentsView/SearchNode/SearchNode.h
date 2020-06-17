//
//  SearchNode.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchNode : ASDisplayNode
@property (nonatomic, readwrite) UISearchBar * bar;

- (instancetype)initWithHeight: (CGFloat) height;
@end

NS_ASSUME_NONNULL_END
