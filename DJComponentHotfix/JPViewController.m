//
//  JPViewController.m
//  DJLibComponentHotfix
//
//  Created by Dokay on 16/7/26.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "JPViewController.h"
#import "DJHotfixManager.h"
#import "RSA.h"

#define KPrivateRSAKey @"-----BEGIN PRIVATE KEY-----\nMIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAN4N32iNuFV9MwnC\nSXSm1bzGjNDhdQO3WyWh5y9myGWDkCHUtBsavNgpUFNR6yXn8jSHehUZlIxEae3D\nnYpkjhyt750xusV2dmDYdV2F5BZlMmmvbHB+IDO+N7NV0ACIsv5Ual5RZrqvlVfp\nl09j2t4EZqoogZ8Y1AfD0JOZXJ8NAgMBAAECgYEA0JYDeHk34MY8vTwOOE/Hkw6H\nlGdUvers6crOGc7ZC9Kr/7uIe7WAEyWr2LioxPC+qe1hFpTy31gckUYhpLCUdEdV\n9DEsgiWe2CUcQcpsdER6XJog84uDEVgatAzLt7Tz5nKwD7MY+yGFiTvmyukVMNhD\n66ntqN3q4KtfWedRQhkCQQD+/Ba3pThv26/wv8GjcTilZoMM/Zy558LV+sTMfg21\nFGpprH72QoxRdudC5Tvo4DzHfG9iUx+56xAIzCukNXvbAkEA3vA3mHIreA7lBLvC\ndqUjdPeq97UFw+kDCYFNv9q90h2gxbaNVKsDL0R6YDgBu5msM6e4ZFqMZYojCyIO\n/WX5NwJADGRR8lDcQktp7IhVL81D1H375ni40iwaQu3x/IIvxlocpdAVR4CKczcV\nHCIp3DJxobxBaYTiqNVsrRDHGi7jOwJAGNpauEnyAp5WdaKg2S0ruLxreNXbYK23\nQvYBPuQZyTS4WZIyS0ANSNWvds6HkuxcwB1wdu+JO0CdC36ugR0/HQJADa8mszbC\nvMa00H52JYedk7ehU+l/YmPWdnjCui1Ix/X29lIdgEolbiUECZT08KCxYu+sCnIs\nWwHAzqOdKK1oxQ==\n-----END PRIVATE KEY-----"

#define kPublicESAKey @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDeDd9ojbhVfTMJwkl0ptW8xozQ\n4XUDt1sloecvZshlg5Ah1LQbGrzYKVBTUesl5/I0h3oVGZSMRGntw52KZI4cre+d\nMbrFdnZg2HVdheQWZTJpr2xwfiAzvjezVdAAiLL+VGpeUWa6r5VX6ZdPY9reBGaq\nKIGfGNQHw9CTmVyfDQIDAQAB\n-----END PUBLIC KEY-----"

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

@interface JPViewController ()

@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 50)];
    [btn setTitle:@"Push JPTableViewController" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:btn];
    
    [self setupHotfix];
}

- (void)setupHotfix
{
    DJHotfixManager *aDJHotfixManager = [DJHotfixManager new];
    
    aDJHotfixManager.hotFixHelper.rsa_public_key = kPublicESAKey;
    //7fb62de8c2a3e2a05c4f49ac24235681
    NSString *encryptionMd5 = @"Nnn3MunT0rZUyvc1Wvv4r8DoIb+J+9fKf8ezqb7cqXnoBOGY+5R8/aC0LAbeksUjO52YTP2ezPxXuKAxiaJQ81GsfVty1wnRssDDZOpH+ru0RkANDAYLyKDT2QWOgu6XHcRt8Xn3+ui7uDhize8bqrpRHZogVqVYMcuhI57VgxM=";
    [aDJHotfixManager setServerMd5:encryptionMd5];
    [aDJHotfixManager excuteJSFromServerWithUrl:@"http://www.douzhongxu.com/jspatch/demo.js"];
}

@end
