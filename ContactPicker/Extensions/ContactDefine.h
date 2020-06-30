//
//  ContactDefine.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/30/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactDefine_h
#define ContactDefine_h

//Error code define
#define NO_CONTENT_ERROR_CODE           204
#define TOO_MANY_REQUESTS_ERROR_CODE    429
#define RETAIN_CYCLE_GONE_ERROR_CODE    410
#define UNSUPPORTED_ERROR_CODE          415
#define NOT_FOUND_ERROR_CODE            404

#pragma mark - Debug define
#define DEBUG_APP_MODE                  0

#if DEBUG_APP_MODE == 1
#define DebugLog(...) NSLog(__VA_ARGS__)

//Dummy data define
#define DEBUG_EMPTY_CONTACT             0
#define DEBUG_FAILT_LOAD                0
#define DEBUG_PERMISSION_DENIED         0
#define DUMMY_DATA_ENABLE               1
#define NUMBER_OF_DUMMY                 10000

//Memory debug define
#define DEBUG_MEM_ENABLE                0

//Component debug define
//Just show UIKit View
#define DEBUG_JUST_UIKIT                0

#if !DEBUG_JUST_UIKIT
//Just show Texture View
#define DEBUG_JUST_TEXTURE              0

#if !DEBUG_JUST_TEXTURE
//Just show ComponentKit view
#define DEBUG_JUST_COMPONENTKIT         0
#endif

#endif

#elif DEBUG_APP_MODE == 0
#define DebugLog(...)
#endif


#endif /* ContactDefine_h */
