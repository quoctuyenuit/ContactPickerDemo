//
//  CheckBoxButtonView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckBoxButtonView : UIView {
    BOOL _checked;
}
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, readwrite) BOOL checked;
@end

NS_ASSUME_NONNULL_END
