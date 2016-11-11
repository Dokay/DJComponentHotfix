//
//  AppDelegate+DJLaunchProtect.m
//  DJComponentHotfix
//
//  Created by Dokay on 16/11/11.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "AppDelegate+DJLaunchProtect.h"
#import <objc/runtime.h>

static inline void dj_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static long crashCount = 0;
static BOOL launchSuccess = NO;

static const long DJMaxCrashCount = 4;
static const long DJSafeLaunchDuration = 4;
static NSString *kDJCrashCountKey = @"kDJCrashCountKey";

@implementation AppDelegate (DJLaunchProtect)

#pragma mark - Method Swizzling
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL originalSelector = @selector(application:didFinishLaunchingWithOptions:);
        SEL swizzledSelector = @selector(dj_application:didFinishLaunchingWithOptions:);
        
        dj_swizzleSelector([self class],originalSelector,swizzledSelector);
        
    });
}

- (BOOL)dj_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL enable = [self dj_launchProtectEnbale];
    if (!enable) {
        launchSuccess = YES;
        return [self dj_application:application didFinishLaunchingWithOptions:launchOptions];
    }
    //只检测冷启动
    if (launchOptions != nil) {
        launchSuccess = YES;
        return [self dj_application:application didFinishLaunchingWithOptions:launchOptions];
    }
    
    crashCount = [[[NSUserDefaults standardUserDefaults] valueForKey:kDJCrashCountKey] integerValue];
    crashCount ++;
    [[NSUserDefaults standardUserDefaults] setObject:@(crashCount) forKey:kDJCrashCountKey];
    
    DJLaunchCompleteBlock normalLaunchBlcok = ^BOOL{
        //async process finish
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kDJCrashCountKey];
        if (!launchSuccess) {
            launchSuccess = YES;
            return [self dj_application:application didFinishLaunchingWithOptions:launchOptions];
        }
        return launchSuccess;
    };
    [self dj_setLaunchComplete:normalLaunchBlcok];
    
    if (crashCount > DJMaxCrashCount) {
        
        DJLaunchFailBlock failBlock = [self dj_launchFail];
        if (failBlock) {
            //sync process finish
            BOOL canLaunchNormal = failBlock();
            if (canLaunchNormal) {
                [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kDJCrashCountKey];
                launchSuccess = YES;
                return [self dj_application:application didFinishLaunchingWithOptions:launchOptions];
            }
        }
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DJSafeLaunchDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kDJCrashCountKey];
        });
        launchSuccess = YES;
        return [self dj_application:application didFinishLaunchingWithOptions:launchOptions];
    }
    
    return YES;
}

- (DJLaunchCompleteBlock)dj_normalLaunchBlock
{
    return [self dj_launchComplete];
}

#pragma mark - getter & setter
- (void)dj_setLaunchComplete:(DJLaunchCompleteBlock)complete
{
    objc_setAssociatedObject(self, @selector(dj_setLaunchComplete:), complete, OBJC_ASSOCIATION_COPY);
}

- (DJLaunchCompleteBlock)dj_launchComplete
{
    return objc_getAssociatedObject(self, @selector(dj_setLaunchComplete:));
}

- (void)dj_setLaunchFail:(DJLaunchFailBlock)fail
{
    objc_setAssociatedObject(self, @selector(dj_setLaunchFail:), fail, OBJC_ASSOCIATION_COPY);
}

- (DJLaunchFailBlock)dj_launchFail
{
    return objc_getAssociatedObject(self, @selector(dj_setLaunchFail:));
}

- (void)dj_setDJLaunchProtectEnable:(BOOL)enable
{
    objc_setAssociatedObject(self, @selector(dj_setDJLaunchProtectEnable:), @(enable), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)dj_launchProtectEnbale
{
    return [objc_getAssociatedObject(self, @selector(dj_setDJLaunchProtectEnable:)) boolValue];
}

@end
