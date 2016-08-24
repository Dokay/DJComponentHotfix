//
//  DJHotfixManager.m
//  DJLibComponentHotfix
//
//  Created by Dokay on 16/7/26.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "DJHotfixManager.h"
#import "JPEngine.h"

#define KTestJSAlert @"\
var alertView = require('UIAlertView').alloc().init();\
alertView.setTitle('Alert');\
alertView.setMessage('AlertView from js'); \
alertView.addButtonWithTitle('OK');\
alertView.show(); \
"

#define DJ_HOT_MD5_FROM_SERVER_CACHE_KEY @"DJ_HOT_MD5_FROM_SERVER_CACHE_KEY"
#define DJ_HOT_VERSION_CACHE_KEY @"DJ_HOT_VERSION_CACHE_KEY"

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
    @try {
        NSString *appVsersion = [self appVersion];
        NSString *appVersionCached = [self.hotFixHelper valueForCacheKey:DJ_HOT_VERSION_CACHE_KEY];
        if (![appVsersion isEqualToString:appVersionCached]) {
            //updated Version
            return;
        }
        
        NSString *jsContentOld = [self.hotFixHelper jsContentCached];
        NSString *encryptionMd5 = [self readLastestMd5FromServer];
        
        if ([self checkJSAvaliable:jsContentOld withEncryptionMd5:encryptionMd5]) {
            [self excuteJS:jsContentOld];
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(hotfixSuccessFormServer:)]) {
                [self.delegate hotfixSuccessFormServer:self.bLoadingFromServer];
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
            } else {
                if (data.length > 0) {
                    
                    NSString *jsContentNew =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if ([weakSelf checkJSAvaliable:jsContentNew withEncryptionMd5:weakSelf.tmpMd5FromServer]) {
                        [self.hotFixHelper saveCacheValue:weakSelf.tmpMd5FromServer forKey:DJ_HOT_MD5_FROM_SERVER_CACHE_KEY];
                        [weakSelf.hotFixHelper saveJSContent:data];
                        NSString *appVersion = [weakSelf appVersion];
                        [self.hotFixHelper saveCacheValue:appVersion forKey:DJ_HOT_VERSION_CACHE_KEY];
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
    //    NSString *realMd5 = [self.hotFixHelper jsRealMd5];
    //    NSString *decryptionMd5 = [self.hotFixHelper decryptionMd5:encryptionMd5];
    //    if ([[realMd5 uppercaseString] isEqualToString:[decryptionMd5 uppercaseString]]) {
    //        return jsContent.length > 0 && ([jsContent rangeOfString:@"require"].location != NSNotFound);
    //    }else{
    //        return NO;
    //    }
    return jsContent.length > 0 && ([jsContent rangeOfString:@"require"].location != NSNotFound);
}

- (NSString *)readLastestMd5FromServer
{
    NSString *md5 = [self.hotFixHelper valueForCacheKey:DJ_HOT_MD5_FROM_SERVER_CACHE_KEY];
    return md5 ? md5 : @"";
}

- (void)setServerMd5:(NSString *)md5
{
    self.tmpMd5FromServer = md5;
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
