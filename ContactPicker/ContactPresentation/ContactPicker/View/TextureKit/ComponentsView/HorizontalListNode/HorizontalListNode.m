//
//  HorizontalListNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_TEXTURE
#import "HorizontalListNode.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactCollectionCellNode.h"

#define DEBUG_MODE          0
#define BUTTON_SIZE         CGSizeMake(50, 50)
#define COLLECTION_HEIGHT   60
#define BOUND_HEIGHT        80
#define LEFT_PADDING        16
#define RIGHT_PADDING       16
#define InsetForCollection  UIEdgeInsetsMake(0, LEFT_PADDING, 0, 0)
#define InsetForButton      UIEdgeInsetsMake(0, 0, 0, RIGHT_PADDING)

@interface HorizontalListNode () <ASCollectionDelegate, ASCollectionDataSource, ContactCollectionCellDelegate>

@end

@implementation HorizontalListNode  {
    ASButtonNode            * _actionButton;
    ASDisplayNode           * _boundNode;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [flowLayout setMinimumInteritemSpacing:0];
        [flowLayout setMinimumLineSpacing:10];
        flowLayout.itemSize = ITEM_SIZE;
        flowLayout.estimatedItemSize = CGSizeZero;
        
        
        _actionButton           = [[ASButtonNode alloc] init];
        _collectionNode         = [[ASCollectionNode alloc] initWithCollectionViewLayout: flowLayout];
        _boundNode              = [[ASDisplayNode alloc] init];
        self.backgroundColor    = UIColor.whiteColor;
        
        _collectionNode.showsHorizontalScrollIndicator  = NO;
        _collectionNode.dataSource                      = self;
        _collectionNode.delegate                        = self;
        
        [_actionButton setBackgroundImage:[UIImage imageNamed:@"arrow_ico"] forState:UIControlStateNormal];
        
        [_boundNode addSubnode:_collectionNode];
        [_boundNode addSubnode:_actionButton];
        [self addSubnode:_boundNode];
        [self layoutInBound];
        
#if DEBUG_MODE
        _actionButton.backgroundColor           = UIColor.greenColor;
        _collectionNode.backgroundColor         = UIColor.redColor;
        _boundNode.backgroundColor              = UIColor.blueColor;
#endif
    }
    return self;
}

- (void)layoutInBound {
    __weak typeof(self) weakSelf = self;
    
    _boundNode.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            ASLayoutSpec * collectionViewLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:InsetForCollection
                                                                                         child:
                                                   [strongSelf->_collectionNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                style.preferredSize = CGSizeMake(strongSelf.calculatedSize.width, COLLECTION_HEIGHT);
            }]];
            
            ASLayoutSpec * buttonLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:InsetForButton
                                                                                 child:
                                           [strongSelf->_actionButton styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                style.preferredSize = BUTTON_SIZE;
            }]];
            
            return [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                           spacing:8
                                                    justifyContent:ASStackLayoutJustifyContentCenter
                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                          children:@[[collectionViewLayout styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                style.flexGrow = 10;
            }], buttonLayout]];
        }
        return nil;
    };
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    __weak typeof(self) weakSelf = self;
    
    return [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                   spacing:0
                                            justifyContent:ASStackLayoutJustifyContentStart
                                                alignItems:ASStackLayoutAlignItemsStart
                                                  children: @[[_boundNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = CGSizeMake(weakSelf.calculatedSize.width, BOUND_HEIGHT);
        style.flexGrow = 10;
    }]]];
}

#pragma mark - ASCollectionDataSource methods

- (NSInteger)numberOfSectionsInCollectionNode:(ASCollectionNode *)collectionNode {
    return 1;
}

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section {
    return [self.delegate horizontalListItem:self numberOfItemAtSection:section];
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    ContactViewEntity * contact = [self.delegate horizontalListItem:self entityForIndexPath:indexPath];
    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode * {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        ContactCollectionCellNode *  cellNode = [[ContactCollectionCellNode alloc] initWithContact:contact];
        cellNode.delegate = strongSelf;
        return cellNode;
    };
    return ASCellNodeBlock;
}

- (void)removeCell:(ContactViewEntity *)entity {
    [self.delegate removeCellWithContact:entity];
}

#pragma - mark HorizontalListItemProtocol methods
- (void)insertItemAtIndex:(NSInteger)index {
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionNode insertItemsAtIndexPaths:@[indexPath]];
    [_collectionNode scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

- (void)removeItemAtIndex:(NSInteger)index {
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionNode deleteItemsAtIndexPaths:@[indexPath]];
}

@synthesize delegate;
@end
#endif
