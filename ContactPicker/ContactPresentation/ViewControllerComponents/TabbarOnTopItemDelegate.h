//
//  TabbarOnTopItemProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef TabbarOnTopItemProtocol_h
#define TabbarOnTopItemProtocol_h

@class TabbarOnTopItemView;
@protocol TabbarOnTopItemDelegate <NSObject>

- (void)didTapOnItem:(TabbarOnTopItemView *) item state:(BOOL) isHighLight;

@end

#endif /* TabbarOnTopItemProtocol_h */
