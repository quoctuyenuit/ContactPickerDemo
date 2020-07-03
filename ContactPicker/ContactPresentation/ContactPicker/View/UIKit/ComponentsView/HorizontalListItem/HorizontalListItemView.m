//
//  HorizontalListItemView.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "HorizontalListItemView.h"
#import "ContactCollectionCell.h"
#import "ImageManager.h"

#define DEBUG_MODE                  0
#define DEFAULT_CONTENT_HEIGHT      80
#define DEFAULT_COLLECTION_HEIGHT   60
#define BUTTON_WIDTH                50
#define REUSE_IDENTIIER             @"HorizontalReuseIdentifier"


@interface HorizontalListItemView() <UICollectionViewDelegate, UICollectionViewDataSource, ContactCollectionCellDelegate>
- (void)customInit;

@end

@implementation HorizontalListItemView {
    UIView            *_mainContentView;
    UIButton          *_button;
    UICollectionView  *_collectionView;
}

@synthesize delegate;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:10];
    flowLayout.itemSize = ITEM_SIZE;
    flowLayout.estimatedItemSize = CGSizeZero;
    
    _mainContentView    = [[UIView alloc] init];
    _button             = [[UIButton alloc] init];
    _collectionView     = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:flowLayout];
    [_button setBackgroundImage:[UIImage imageNamed:@"arrow_ico"] forState:UIControlStateNormal];

    self.backgroundColor                = UIColor.whiteColor;
    _mainContentView.backgroundColor    = UIColor.whiteColor;
    _collectionView.backgroundColor     = UIColor.whiteColor;
    
    _collectionView.delegate            = self;
    _collectionView.dataSource          = self;
    
    [_collectionView registerClass:[ContactCollectionCell class] forCellWithReuseIdentifier:REUSE_IDENTIIER];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addSubview:_mainContentView];
    [_mainContentView addSubview:_button];
    [_mainContentView addSubview:_collectionView];
    
    _mainContentView.translatesAutoresizingMaskIntoConstraints  = NO;
    _button.translatesAutoresizingMaskIntoConstraints           = NO;
    _collectionView.translatesAutoresizingMaskIntoConstraints   = NO;
    
    
    [_mainContentView.topAnchor constraintEqualToAnchor:self.topAnchor].active      = YES;
    [_mainContentView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active    = YES;
    [_mainContentView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active  = YES;
    NSLayoutConstraint * mainHeightConstraint = [_mainContentView.heightAnchor constraintEqualToConstant:DEFAULT_CONTENT_HEIGHT];
    NSLayoutConstraint * mainBtmConstraint = [_mainContentView.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor];
    
    [_collectionView.leftAnchor constraintEqualToAnchor:_mainContentView.leftAnchor constant:16].active = YES;
    [_collectionView.rightAnchor constraintEqualToAnchor:_button.leftAnchor constant:-8].active         = YES;
    [_collectionView.centerYAnchor constraintEqualToAnchor:_mainContentView.centerYAnchor].active       = YES;
    
    NSLayoutConstraint * collectionHeightConstraint = [_collectionView.heightAnchor constraintEqualToConstant:DEFAULT_COLLECTION_HEIGHT];
    NSLayoutConstraint * collectionTopConstraint = [_collectionView.topAnchor constraintGreaterThanOrEqualToAnchor:_mainContentView.topAnchor];
    NSLayoutConstraint * collectionBottomConstraint = [_collectionView.bottomAnchor constraintLessThanOrEqualToAnchor:_mainContentView.bottomAnchor];
    
    
    [_button.heightAnchor constraintEqualToAnchor:_button.widthAnchor].active                       = YES;
    [_button.centerYAnchor constraintEqualToAnchor:_mainContentView.centerYAnchor].active           = YES;
    [_button.rightAnchor constraintEqualToAnchor:_mainContentView.rightAnchor constant:-16].active   = YES;
    
    NSLayoutConstraint * buttonTopConstraint = [_button.topAnchor constraintGreaterThanOrEqualToAnchor:_mainContentView.topAnchor];
    NSLayoutConstraint * buttonWidthContraint = [_button.widthAnchor constraintEqualToConstant:BUTTON_WIDTH];
    
    buttonWidthContraint.priority   = UILayoutPriorityDefaultHigh;
    buttonTopConstraint.priority    = UILayoutPriorityRequired;
    mainBtmConstraint.priority      = UILayoutPriorityRequired;
    mainHeightConstraint.priority   = UILayoutPriorityDefaultHigh;
    collectionHeightConstraint.priority = UILayoutPriorityDefaultHigh;
    collectionTopConstraint.priority    = UILayoutPriorityRequired;
    collectionBottomConstraint.priority = UILayoutPriorityRequired;
    
    
    buttonWidthContraint.active = YES;
    buttonTopConstraint.active  = YES;
    mainBtmConstraint.active    = YES;
    mainHeightConstraint.active = YES;
    collectionHeightConstraint.active = YES;
    collectionTopConstraint.active    = YES;
    collectionBottomConstraint.active = YES;
    
#if DEBUG_MODE
    self.backgroundColor                    = UIColor.blackColor;
    _mainContentView.backgroundColor        = UIColor.greenColor;
    _collectionView.backgroundColor         = UIColor.redColor;
    _button.backgroundColor                 = UIColor.yellowColor;
#endif
}

#pragma mark - HorizontalListItemProtocol methods
- (void)insertItemAtIndex:(NSInteger)index {
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView insertItemsAtIndexPaths:@[indexPath]];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

- (void)removeItemAtIndex:(NSInteger)index {
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [delegate horizontalListItem:self numberOfItemAtSection:section];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ContactCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIIER forIndexPath:indexPath];
    
    ContactViewEntity * entity = [delegate horizontalListItem:self entityForIndexPath:indexPath];
    
    [cell binding:entity];
    
    if (cell.delegate == nil) {
        cell.delegate = self;
    }
    
    return cell;
}

#pragma mark - ContactCollectionDelegate methods
- (void)removeCell:(NSString *)identifier {
    [delegate removeCellWithContact:identifier];
}

@end
