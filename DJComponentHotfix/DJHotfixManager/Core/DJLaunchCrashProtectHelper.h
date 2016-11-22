//
//  DJLaunchCrashProtectHelper.h
//  DJComponentHotfix
//
//  Created by Dokay on 16/11/23.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJHotfixHelper.h"

typedef BOOL(^DJLaunchCompleteBlock)();
typedef BOOL(^DJLaunchMaybeFailBlock)();

typedef NS_ENUM(NSInteger,DJLaunchStatus){
    DJLaunchStatusDefault,
    DJLaunchStatusSuccess,
    DJLaunchStatusCrash,
};

@interface DJLaunchCrashProtectHelper : NSObject

@property (nonatomic, copy) DJLaunchMaybeFailBlock fail;
@property (nonatomic, copy) DJLaunchCompleteBlock success;
@property (nonatomic, assign) BOOL launchProtectEnbale;
@property (nonatomic, assign, readonly) DJLaunchStatus launchState;

@property (nonatomic, strong) NSObject<DJHotfixHelperProtocol> *hotFixHelper;//默认是DJHotfixHelper，这里使用者可以自己实现DJHotfixHelperProtocol

- (void)launchWithOptions:(NSDictionary *)launchOptions;
- (void)clearCrashCount;

@end
