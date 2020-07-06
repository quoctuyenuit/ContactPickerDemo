//
//  ContactDefine.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/30/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactDefine_h
#define ContactDefine_h

#define weak_self __weak typeof(self) weakSelf = self;
#define strong_self __strong typeof(weakSelf) strongSelf = weakSelf;

#define LOG_MSG_HEADER                  [NSString stringWithFormat: @"%@", [self class]]

#pragma mark - Debug define
#define DEBUG_APP_MODE                  1

#if DEBUG_APP_MODE == 1
#define DebugLog(...) NSLog(__VA_ARGS__)

//Dummy data define
#define DEBUG_EMPTY_CONTACT             0
#define DEBUG_FAILT_LOAD                0
#define DEBUG_PERMISSION_DENIED         0
#define DUMMY_DATA_ENABLE               1
#define NUMBER_OF_DUMMY                 1000


#define BUILD_UIKIT                     1
#define BUILD_TEXTURE                   1
#define BUILD_COMPONENTKIT              1


#elif DEBUG_APP_MODE == 0
#define DebugLog(...)
#endif


#endif /* ContactDefine_h */
