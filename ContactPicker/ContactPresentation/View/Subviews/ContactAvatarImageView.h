//
//  ContactAvatarImageView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/5/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactAvatarImageView : UIView
@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

- (void) showImage;
- (void) showLabel;
- (void) configImage: (UIImage * _Nullable) image forLabel: (NSString *) label;
@end

NS_ASSUME_NONNULL_END
