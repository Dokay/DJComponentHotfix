//
//  DJHotfixZipHelper.m
//  DJComponentHotfix
//
//  Created by Dokay on 16/11/23.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "DJHotfixZipHelper.h"
#import "ZipArchive.h"
#import "AESCrypt.h"

@implementation DJHotfixZipHelper

+ (NSString *)unzipJSWithData:(NSData *)data password:(NSString *)password andEncryptContent:(NSString *)encryptContent
{
    NSData *zipData = [NSData dataWithBytes:data.bytes length:data.length];
    
    NSError *error = nil;
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *zipDirPath = [dirPath stringByAppendingPathComponent:@"djpath"];
    BOOL isDirectory = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:zipDirPath isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:zipDirPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (error) {
        return @"";
    }
    NSString *zipPath = [zipDirPath stringByAppendingPathComponent:@"js.zip"];
    [zipData writeToFile:zipPath options:0 error:&error];
    zipData = nil;
    if (!error) {
        if ([SSZipArchive unzipFileAtPath:zipPath toDestination:zipDirPath overwrite:YES password:[DJHotfixZipHelper processPwd:password andEncryptContent:encryptContent] error:&error]) {
            NSString *jsContent;
            NSArray *filesNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:zipDirPath error:&error];
            
            if (filesNameArray.count > 0) {
                __block NSString *firstJSName;
                [filesNameArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj hasSuffix:@"js"]) {
                        firstJSName = obj;
                    }
                }];
                
                NSString *jsFilePath = [zipDirPath stringByAppendingPathComponent:firstJSName];
                
                jsContent = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:&error];
            }
            //clear
            [[NSFileManager defaultManager] removeItemAtPath:zipDirPath error:&error];
            return jsContent;
        }
    }else{
        NSLog(@"zip error:%@",error);
    }
    return @"";
}

+ (NSString *)processPwd:(NSString *)originalPwd andEncryptContent:(NSString *)encryptContent
{
    NSString *passwordLong = [AESCrypt decrypt:[encryptContent copy] password:[originalPwd copy]];
    if (passwordLong.length > 11) {
        return [passwordLong substringFromIndex:11];
    }
    return @"";
}

@end
