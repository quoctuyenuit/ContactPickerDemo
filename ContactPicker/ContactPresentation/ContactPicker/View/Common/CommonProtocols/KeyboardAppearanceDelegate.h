//
//  KeyboardAppearanceProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef KeyboardAppearanceProtocol_h
#define KeyboardAppearanceProtocol_h

@protocol KeyboardAppearanceDelegate <NSObject>

- (void) hideKeyboard;

@end

@protocol KeyboardAppearanceProtocol <NSObject>

@property (weak, readwrite) id<KeyboardAppearanceDelegate> keyboardAppearanceDelegate;

@end


#endif /* KeyboardAppearanceProtocol_h */
