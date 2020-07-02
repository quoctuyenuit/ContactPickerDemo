//
//  TableIndexView.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "TableIndexView.h"
#import "Utilities.h"

#define DEBUG_MODE      0
#define TITLE_COLOR     UIColor.systemBlueColor
#define FONT_SIZE       11

@implementation TableIndexView {
    NSArray<NSString *>         *_titlesIndex;
    NSMutableArray<UIButton *>   *_titlesView;
    UIStackView                 *_mainStackView;
}

- (instancetype)initWithTitlesIndex:(NSArray<NSString *> *)titlesIndex {
    self = [super init];
    if (self) {
        _titlesIndex    = [[NSArray alloc] initWithArray:titlesIndex];
        _mainStackView  = [[UIStackView alloc] init];
        _mainStackView.axis = UILayoutConstraintAxisVertical;
        _mainStackView.distribution = UIStackViewDistributionFillEqually;
        _mainStackView.alignment = UIStackViewAlignmentCenter;
        _mainStackView.spacing = 0;
        [self setupViews];
        
#if DEBUG_MODE
        self.backgroundColor                = UIColor.greenColor;
        _mainStackView.backgroundColor      = UIColor.redColor;
#endif
    }
    return self;
}

- (void) setupViews {
    for (NSString *title in _titlesIndex) {
        UIButton * labelBtn = [[UIButton alloc] init];
        [labelBtn setAttributedTitle:[NSAttributedString attributedStringWithString:title font:[UIFont systemFontOfSize:FONT_SIZE weight:UIFontWeightSemibold] color:TITLE_COLOR firstWordColor:nil] forState:UIControlStateNormal];
        [_mainStackView addArrangedSubview:labelBtn];
        
        labelBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [labelBtn.heightAnchor constraintEqualToConstant:14].active = YES;
        [labelBtn.leftAnchor constraintEqualToAnchor:_mainStackView.leftAnchor].active = YES;
        [labelBtn.rightAnchor constraintEqualToAnchor:_mainStackView.rightAnchor].active = YES;
        
        [labelBtn addTarget:self action:@selector(selectTitleAction:event:) forControlEvents:UIControlEventTouchUpInside];

        
        
        [_titlesView addObject:labelBtn];
    }
    
    [self addSubview:_mainStackView];
    
    _mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_mainStackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active    = YES;
    [_mainStackView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active      = YES;
    [_mainStackView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active    = YES;
}

- (void) selectTitleAction:(UIButton *) sender event: (UIEvent *) event {
    NSInteger index = [_titlesIndex indexOfObject:sender.titleLabel.text];
    if (self.delegate && [self.delegate respondsToSelector: @selector(tableIndexView:didSelectAt:)])
        [self.delegate tableIndexView:self didSelectAt:index];
    NSLog(@"%@ - %ld", sender.titleLabel.text, index);
}

@end
