//
//  DJLaunchCrashProtectHelper.m
//  DJComponentHotfix
//
//  Created by Dokay on 16/11/23.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "DJLaunchCrashProtectHelper.h"

static long crashCount = 0;

static const long DJMaxCrashCount = 4;
static const long DJSafeLaunchDuration = 4;
static NSString *kDJCrashCountKey = @"kDJCrashCountKey";

@interface DJLaunchCrashProtectHelper()

@property (nonatomic, assign) DJLaunchStatus launchState;

@end

@implementation DJLaunchCrashProtectHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _launchState = DJLaunchStatusDefault;
    }
    return self;
}

- (void)launchWithOptions:(NSDictionary *)launchOptions
{
    NSAssert(self.hotFixHelper != nil, @"hotFixHelper can not be nil");
    
    if (!self.launchProtectEnbale) {
        self.launchState = DJLaunchStatusSuccess;
        if (self.success) {
            self.success();
        }
        return;
    }
    //只检测冷启动
    if (launchOptions != nil) {
        self.launchState = DJLaunchStatusSuccess;
        if (self.success) {
            self.success();
        }
        return;
    }
    
    NSNumber *crashCountNumber = (NSNumber *)[self.hotFixHelper valueForCacheKey:kDJCrashCountKey];
    crashCount = [crashCountNumber integerValue];
    crashCount ++;
    [self.hotFixHelper saveCacheValue:@(crashCount) forKey:kDJCrashCountKey];
    
    if (crashCount > DJMaxCrashCount) {
        self.launchState = DJLaunchStatusCrash;
        if (self.fail) {
            self.fail();
        }
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DJSafeLaunchDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.launchState = DJLaunchStatusSuccess;
            [self.hotFixHelper saveCacheValue:@(0) forKey:kDJCrashCountKey];
        });
        if (self.success) {
            self.success();
        }
    }
}

- (void)clearCrashCount
{
    [self.hotFixHelper saveCacheValue:@(0) forKey:kDJCrashCountKey];
}

@end
