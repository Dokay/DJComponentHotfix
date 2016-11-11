//
//  AppDelegate.m
//  DJLibComponentHotfix
//
//  Created by Dokay on 16/7/26.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "AppDelegate.h"
#import "JPViewController.h"
#import "JPEngine.h"
#import "DJHotfixManager.h"
#import "AppDelegate+DJLaunchProtect.h"

#define KPrivateRSAKey @"-----BEGIN PRIVATE KEY-----\nMIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAN4N32iNuFV9MwnC\nSXSm1bzGjNDhdQO3WyWh5y9myGWDkCHUtBsavNgpUFNR6yXn8jSHehUZlIxEae3D\nnYpkjhyt750xusV2dmDYdV2F5BZlMmmvbHB+IDO+N7NV0ACIsv5Ual5RZrqvlVfp\nl09j2t4EZqoogZ8Y1AfD0JOZXJ8NAgMBAAECgYEA0JYDeHk34MY8vTwOOE/Hkw6H\nlGdUvers6crOGc7ZC9Kr/7uIe7WAEyWr2LioxPC+qe1hFpTy31gckUYhpLCUdEdV\n9DEsgiWe2CUcQcpsdER6XJog84uDEVgatAzLt7Tz5nKwD7MY+yGFiTvmyukVMNhD\n66ntqN3q4KtfWedRQhkCQQD+/Ba3pThv26/wv8GjcTilZoMM/Zy558LV+sTMfg21\nFGpprH72QoxRdudC5Tvo4DzHfG9iUx+56xAIzCukNXvbAkEA3vA3mHIreA7lBLvC\ndqUjdPeq97UFw+kDCYFNv9q90h2gxbaNVKsDL0R6YDgBu5msM6e4ZFqMZYojCyIO\n/WX5NwJADGRR8lDcQktp7IhVL81D1H375ni40iwaQu3x/IIvxlocpdAVR4CKczcV\nHCIp3DJxobxBaYTiqNVsrRDHGi7jOwJAGNpauEnyAp5WdaKg2S0ruLxreNXbYK23\nQvYBPuQZyTS4WZIyS0ANSNWvds6HkuxcwB1wdu+JO0CdC36ugR0/HQJADa8mszbC\nvMa00H52JYedk7ehU+l/YmPWdnjCui1Ix/X29lIdgEolbiUECZT08KCxYu+sCnIs\nWwHAzqOdKK1oxQ==\n-----END PRIVATE KEY-----"

#define kPublicESAKey @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDeDd9ojbhVfTMJwkl0ptW8xozQ\n4XUDt1sloecvZshlg5Ah1LQbGrzYKVBTUesl5/I0h3oVGZSMRGntw52KZI4cre+d\nMbrFdnZg2HVdheQWZTJpr2xwfiAzvjezVdAAiLL+VGpeUWa6r5VX6ZdPY9reBGaq\nKIGfGNQHw9CTmVyfDQIDAQAB\n-----END PUBLIC KEY-----"

@import Foundation;

//加密逻辑
//服务端:
//1.developer上传 hotfix文件A；
//2.计算A的Md5值 B,
//3.使用私钥加密B 得到 C,
//4.将js的下载地址和C传给客户端；
//
//客户端：
//5.下载js文件到本地并计算Md5 得到D;
//6.版本号判断，如果js版本和当前APP版本不一致则认为是之前版本的hotfix,则不执行；
//7.将从服务端得到的C使用本地公钥进行解密得到E;
//8.将E和D进行比对，一致的话执行本地js;

//考虑的场景：
//1.A版本需要hotfix,直接下载
//2.A版本继续叠加hotfix,直接下载
//3.A版本后的B版本需要hotfix,

//可以考虑本地先执行本地缓存的，根据服务端的信息判断有没有最新的补丁

@interface AppDelegate ()<DJHotfixManagerDeleagte>

@property (nonatomic, strong) DJHotfixManager *aDJHotfixManager;

@end

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self dj_setDJLaunchProtectEnable:YES];
        
        __weak AppDelegate *weakSelf = self;
        [self dj_setLaunchFail:^BOOL{
           //处理crash，此处可以做一些保守的保护，比如删除本地无用数据库，展示友好的崩溃通知界面
            [weakSelf requestHotFixAPIFromServer];//由于applicationDidBecomeActive中放了执行打补丁的代码，这里可以不再执行
            return YES;
        }];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [JPEngine startEngine];
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demoSimple" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    [JPEngine evaluateScript:script];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    JPViewController *rootViewController = [JPViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    [self.aDJHotfixManager excuteJSFromLocal];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self requestHotFixAPIFromServer];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)requestHotFixAPIFromServer
{
    __weak AppDelegate *weakSelf = self;
    
    NSString *oldMd5 = [self.aDJHotfixManager readLastestMd5];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *url = [NSString stringWithFormat:@"http://www.douzhongxu.com/jspatch/hot_fix_config?old_md5=%@&version=%@",oldMd5,appVersion];
    NSURL *requestUrl = [NSURL URLWithString:url];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:requestUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"JS download Error: %@", error);
        } else {
            if (data.length > 0) {
                NSError *jsonError;
                NSDictionary *hotFixDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                NSLog(@"hot fix api from server:%@",hotFixDictionary);
                
                NSString *md5 = [hotFixDictionary valueForKey:@"md5"];
                NSString *jsDonwloadUrl = [hotFixDictionary valueForKey:@"downloadurl"];
                
                if (md5.length > 0 && jsDonwloadUrl.length > 0) {
                    [weakSelf.aDJHotfixManager setServerMd5:md5];
                    [weakSelf.aDJHotfixManager excuteJSFromServerWithUrl:jsDonwloadUrl];
                }
            }
        }
    }];
    
    [task resume];
}

#pragma mark - DJHotfixManagerDeleagte
- (void)applyPatchSuccess:(BOOL)isFromServer
{
    if (isFromServer) {
        //hot fix 完毕后继续启动
        DJLaunchCompleteBlock normalLaunchBlock = [self dj_normalLaunchBlock];
        if (normalLaunchBlock) {
            normalLaunchBlock();
        }
    }
}

- (DJHotfixManager *)aDJHotfixManager
{
    if (_aDJHotfixManager == nil) {
        _aDJHotfixManager = [DJHotfixManager new];
        _aDJHotfixManager.hotFixHelper.rsa_public_key = kPublicESAKey;
        _aDJHotfixManager.delegate = self;
    }
    return _aDJHotfixManager;
}

@end
