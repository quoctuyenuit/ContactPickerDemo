//
//  ContactTableComponentController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableComponentController.h"
#import "ContactViewEntity.h"
#import "ContactTableCellComponent.h"
#import <ComponentKit/ComponentKit.h>

@interface ContactTableComponentController () <CKComponentProvider, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate> {
    id<ContactViewModelProtocol>                      _viewModel;
    UICollectionView                                * _collectionView;
    CKCollectionViewDataSource                      * _dataSource;
    CKComponentFlexibleSizeRangeProvider            * _sizeRangeProvider;
}

@end

@implementation ContactTableComponentController

- (instancetype)initWithViewModel:(id<ContactViewModelProtocol>)viewModel {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel                  = viewModel;
        _sizeRangeProvider          = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    }
    return self;
}
                                       
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    
    _collectionView                 = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout: flowLayout];
    _collectionView.backgroundColor = UIColor.whiteColor;
    _collectionView.delegate        = self;
    
    const CKSizeRange sizeRange = [_sizeRangeProvider sizeRangeForBoundingSize:_collectionView.bounds.size];
    CKDataSourceConfiguration *configuration = [[CKDataSourceConfiguration<ContactViewEntity *, id<NSObject>> alloc]
                                                initWithComponentProviderFunc:ContactComponentProvider
                                                context:nil
                                                sizeRange:sizeRange];
    
    _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:_collectionView
                                                 supplementaryViewDataSource:nil configuration:configuration];
    
    
    
}
+ (CKComponent *)componentForModel:(ContactViewEntity *)contact context:(id<NSObject>)context {
    return [ContactTableCellComponent newWithContact: contact];
}

static CKComponent * ContactComponentProvider(ContactViewEntity * contact,id<NSObject> context) {
    return [ContactTableCellComponent newWithContact: contact];
}

@end
