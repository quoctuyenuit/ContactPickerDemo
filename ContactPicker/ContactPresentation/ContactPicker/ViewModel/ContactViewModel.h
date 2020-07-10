//
//  ListContactViewModel.h
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBinding.h"
#import "ContactViewEntity.h"
#import "ContactBusinessLayerProtocol.h"
#import "ContactViewModelProtocol.h"
#import "ContactTableDataSource.h"

NS_ASSUME_NONNULL_BEGIN



@interface ContactViewModel : NSObject<ContactViewModelProtocol>

- (id)initWithBus: (id<ContactBusinessLayerProtocol>) bus;
@end

NS_ASSUME_NONNULL_END
