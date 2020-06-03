//
//  ContactViewCell.m
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactViewCell.h"
#import <SnapKit-Swift.h>
#import <UIKit/UIKit.h>
#import "ContactViewModel.h"
#define GENERATE_IMAGE_API @"https://dummyimage.com/600x600/dbc418/fff&text="

@interface ContactViewCell()

-(void) setup;
-(void) getImageFrom: (NSString*) url forName: (NSString*) name completion: (void (^)(UIImage*)) handle;
-(void) customInit;
@end

@implementation ContactViewCell

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

#pragma mark Override methods

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    [self setup];
    [super drawRect: rect];
}

#pragma mark Addition methods

- (void) customInit {
    [[NSBundle mainBundle] loadNibNamed:@"ContactViewCell" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

- (void)setup {
    _avatar.layer.cornerRadius = _avatar.bounds.size.width/2;
    _avatar.layer.borderWidth = 1;
    _avatar.layer.borderColor = UIColor.grayColor.CGColor;
}

- (void) getImageFrom:(NSString *)url
              forName: (NSString*) name
           completion: (void (^)(UIImage*)) handle
{
    NSString *targetUrl = [NSString stringWithFormat:@"%@%@", url, name];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {

        UIImage* image = [UIImage imageWithData:data];
        handle(image);
    }] resume];
}

-(void) config:(ContactViewModel*) model {
//    If contact dont have avatar --> generate avatar from name
    if (!model.avatar) {
        [self getImageFrom:GENERATE_IMAGE_API forName:[model.name substringToIndex:1] completion:^(UIImage * image) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                __weak ContactViewCell *weakSelf = self;
                weakSelf.avatar.image = image;
            });
        }];
    }
    self.avatar.image = model.avatar;
    self.name.text = model.name;
    self.activeTime.text = model.activeTime;
}

- (void) select {
    self.checkButton.checked = !self.checkButton.checked;
}

@end
