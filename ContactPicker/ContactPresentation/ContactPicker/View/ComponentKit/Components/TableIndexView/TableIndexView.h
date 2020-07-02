//
//  TableIndexView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TableViewIndexDelegate;

@interface TableIndexView : UIView
@property(nonatomic, readwrite, weak) id<TableViewIndexDelegate, NSObject> delegate;

- (instancetype) initWithTitlesIndex:(NSArray<NSString *> *) titlesIndex;
@end

@protocol TableViewIndexDelegate

- (void) tableIndexView: (TableIndexView *) indexView didSelectAt:(NSInteger) index;

@end

NS_ASSUME_NONNULL_END
