//
//  SearchNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "SearchNode.h"

@implementation SearchNode
- (UISearchBar *)bar {
    return (UISearchBar *)self.view;
}

- (instancetype)initWithHeight:(CGFloat)height {
    self = [super init];
    if (self) {
        [self setViewBlock:^UIView * _Nonnull{
            UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
            searchBar.backgroundImage = nil;
            searchBar.backgroundColor = UIColor.clearColor;
            searchBar.searchBarStyle = UISearchBarStyleMinimal;
            return searchBar;
        }];
        
        self.style.height       = ASDimensionMake(ASDimensionUnitPoints, height);
        self.backgroundColor    = UIColor.whiteColor;
    }
    return self;
}
@end
