//
//  HorizontalListNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "HorizontalListNode.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>

#define DEBUG_MODE      1
#define BUTTON_SIZE     CGSizeMake(50, 50)
//#define 


@implementation HorizontalListNode {
    ASButtonNode            * _actionButton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _actionButton       = [[ASButtonNode alloc] init];
        _collectionNode     = [[ASCollectionNode alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        self.automaticallyManagesSubnodes = YES;
#if DEBUG_MODE
        _actionButton.backgroundColor           = UIColor.greenColor;
        _collectionNode.backgroundColor         = UIColor.redColor;
#endif
    }
    return self;
}

//- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
//    
//}


@end
