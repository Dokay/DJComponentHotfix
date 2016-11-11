//
//  AppDelegate+DJLaunchProtect.h
//  DJComponentHotfix
//
//  Created by Dokay on 16/11/11.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "AppDelegate.h"

typedef BOOL(^DJLaunchCompleteBlock)();
typedef BOOL(^DJLaunchFailBlock)();

@interface AppDelegate (DJLaunchProtect)

- (void)dj_setLaunchFail:(DJLaunchFailBlock)fail;
- (void)dj_setDJLaunchProtectEnable:(BOOL)enable;

- (DJLaunchCompleteBlock)dj_normalLaunchBlock;

@end
