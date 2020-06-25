//
//  ContactWithSearchComponent.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/24/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactWithSearchBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactWithSearchComponent : ContactWithSearchBase <UICollectionViewDelegate, UICollectionViewDataSource>
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
