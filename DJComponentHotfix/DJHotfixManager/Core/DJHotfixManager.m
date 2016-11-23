//
//  DJHotfixManager.m
//  DJLibComponentHotfix
//
//  Created by Dokay on 16/7/26.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "DJHotfixManager.h"
#import "JPEngine.h"
#import <QuartzCore/QuartzCore.h>
#import "DJZipHelper.h"

#define KTestJSAlert @"\
var alertView = require('UIAlertView').alloc().init();\
alertView.setTitle('Alert');\
alertView.setMessage('AlertView from js'); \
alertView.addButtonWithTitle('OK');\
alertView.show(); \
"

#define DJ_HOT_MD5_FROM_SERVER_CACHE_KEY @"DJ_HOT_MD5_FROM_SERVER_CACHE_KEY"
#define DJ_HOT_VERSION_CACHE_KEY @"DJ_HOT_VERSION_CACHE_KEY"
#define DJ_HOTFIX_CRASH_COUNT_KEY @"DJ_HOTFIX_CRASH_COUNT_KEY"
#define DJ_HOTFIX_IS_ZIP_SUPPORT_KEY @"DJ_HOTFIX_IS_ZIP_SUPPORT_KEY"
#define DJ_HOTFIX_ZIP_PASSWORD_KEY @"DJ_HOTFIX_ZIP_PASSWORD_KEY"

static NSInteger const kContinuousCrashNeedToStop = 3;
static CFTimeInterval const kCrashAfterExcutingHotFixTimeInterval = 3.0;

@interface DJHotfixManager()

@property (nonatomic, assign) BOOL bLoadingFromServer;
@property (nonatomic, strong) NSString *tmpMd5FromServer;
@property (nonatomic, strong) NSObject<DJHotfixHelperProtocol> *hotFixHelper;

@end

@implementation DJHotfixManager

#pragma mark - life cycle
- (instancetype)init
{
    self = [self initWithHelper:nil];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithHelper:(NSObject<DJHotfixHelperProtocol> *)helper
{
    self = [super init];
    if (self) {
        _bLoadingFromServer = NO;
        if (helper) {
            self.hotFixHelper = helper;
        }
    }
    return self;
}

#pragma mark - public methods
- (void)excuteJSFromServerWithUrl:(NSString *)url
{
    NSAssert(url != nil, @"url can not be nil");
    
    [self loadNewJSContentWithUrl:url];
}

- (void)excuteJSFromLocal
{
    NSInteger crashCount = [self readCrashCount];
    
    if (crashCount > kContinuousCrashNeedToStop) {
        //连续执行hot fix 后，应用没活超过kCrashAfterExcutingHotFixTimeInterval
        [self.hotFixHelper removeLocalJSContent];
        [self setCrashCount:0];
        
        return;
    }
    
    crashCount ++;
    [self setCrashCount:crashCount];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kCrashAfterExcutingHotFixTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [self setCrashCount:0];
    });
    
    @try {
        NSString *appVsersion = [self appVersion];
        NSString *appVersionCached = (NSString *)[self.hotFixHelper valueForCacheKey:DJ_HOT_VERSION_CACHE_KEY];
        if (![appVsersion isEqualToString:appVersionCached]) {
            //updated Version
            return;
        }
        NSString *jsContent;
        BOOL isZipSupport = [(NSNumber *)[self.hotFixHelper valueForCacheKey:DJ_HOTFIX_IS_ZIP_SUPPORT_KEY] boolValue];
        NSData *jsData = [self.hotFixHelper jsContentCached];
        if (isZipSupport) {
            //解压缩
            NSString *zipPassword = (NSString *)[self.hotFixHelper valueForCacheKey:DJ_HOTFIX_ZIP_PASSWORD_KEY];
            jsContent = [DJZipHelper unzipJSWithData:jsData password:zipPassword];
            
        }else{
            jsContent =[[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
        }
        
        NSString *encryptionMd5 = [self readLastestMd5];
        
        if ([self checkJSAvaliable:jsContent withEncryptionMd5:encryptionMd5]) {
            [self excuteJS:jsContent];
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(applyPatchSuccess:)]) {
                [self.delegate applyPatchSuccess:self.bLoadingFromServer];
            }
        }
    } @catch (NSException *exception) {
        //to avoid excute js crash ,a really big bug
        [self.hotFixHelper saveCacheValue:@"" forKey:DJ_HOT_VERSION_CACHE_KEY];
    } @finally {
        
    }
}

#pragma mark - private methods
- (void)excuteJS:(NSString *)jsContent
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [JPEngine startEngine];
        [JPEngine evaluateScript:jsContent];
    });
}

- (void)loadNewJSContentWithUrl:(NSString *)url
{
    if (!self.bLoadingFromServer) {
        self.bLoadingFromServer = YES;
        __weak typeof(self) weakSelf = self;
        
        NSURL *requestUrl = [NSURL URLWithString:url];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:requestUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"JS download Error: %@", error);
                if ([weakSelf.delegate respondsToSelector:@selector(downloadFail)]) {
                    [weakSelf.delegate downloadFail];
                }
            } else {
                if (data.length > 0) {
                    NSString *jsContentNew;
                    if (weakSelf.serverZipEnable) {
                        //解压缩
                        jsContentNew = [DJZipHelper unzipJSWithData:data password:self.tmpZipPassword];
                    }else{
                        jsContentNew =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    }

                    if ([weakSelf checkJSAvaliable:jsContentNew withEncryptionMd5:weakSelf.tmpMd5FromServer]) {
                        [self.hotFixHelper saveCacheValue:weakSelf.tmpMd5FromServer forKey:DJ_HOT_MD5_FROM_SERVER_CACHE_KEY];
                        [weakSelf.hotFixHelper saveJSContent:data];
                        NSString *appVersion = [weakSelf appVersion];
                        [self.hotFixHelper saveCacheValue:appVersion forKey:DJ_HOT_VERSION_CACHE_KEY];
                        [self.hotFixHelper saveCacheValue:@(self.serverZipEnable) forKey:DJ_HOTFIX_IS_ZIP_SUPPORT_KEY];
                        if (self.serverZipEnable && self.tmpZipPassword.length > 0) {
                            [self.hotFixHelper saveCacheValue:self.tmpZipPassword forKey:DJ_HOTFIX_ZIP_PASSWORD_KEY];
                            self.tmpZipPassword = @"";//内存里清空密码
                        }
                        [self excuteJSFromLocal];
                    }
                }
            }
            weakSelf.bLoadingFromServer = NO;
        }];
        
        [task resume];
    }
}

- (BOOL)checkJSAvaliable:(NSString *)jsContent withEncryptionMd5:(NSString *)encryptionMd5
{
    NSString *realMd5 = [self.hotFixHelper md5ForContent:jsContent];
    NSString *decryptionMd5 = [self.hotFixHelper decryptionMd5:encryptionMd5];
    
    if ([[realMd5 uppercaseString] isEqualToString:[decryptionMd5 uppercaseString]]) {
        return jsContent.length > 0 && ([jsContent rangeOfString:@"require"].location != NSNotFound);
    }else{
        return NO;
    }
    //    return jsContent.length > 0 && ([jsContent rangeOfString:@"require"].location != NSNotFound);
}

- (NSString *)readLastestMd5
{
    NSString *md5 = (NSString *)[self.hotFixHelper valueForCacheKey:DJ_HOT_MD5_FROM_SERVER_CACHE_KEY];
    return md5 ? md5 : @"";
}

- (void)setServerMd5:(NSString *)md5
{
    self.tmpMd5FromServer = md5;
}

- (NSInteger)readCrashCount
{
    NSNumber *crashCount = (NSNumber *)[self.hotFixHelper valueForCacheKey:DJ_HOTFIX_CRASH_COUNT_KEY];
    return [crashCount integerValue];
}

- (void)setCrashCount:(NSInteger)crashCount
{
    [self.hotFixHelper saveCacheValue:@(crashCount) forKey:DJ_HOTFIX_CRASH_COUNT_KEY];
}

- (NSString *)appVersion
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

#pragma mark - getter
- (NSObject<DJHotfixHelperProtocol> *)hotFixHelper
{
    if (_hotFixHelper == nil) {
        _hotFixHelper = [DJHotfixHelper new];
    }
    return _hotFixHelper;
}

@end
