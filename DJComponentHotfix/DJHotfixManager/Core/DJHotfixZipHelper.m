//
//  DJHotfixZipHelper.m
//  DJComponentHotfix
//
//  Created by Dokay on 16/11/23.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "DJHotfixZipHelper.h"
#import "ZipArchive.h"

@implementation DJHotfixZipHelper

+ (NSString *)unzipJSWithData:(NSData *)data password:(NSString *)password
{
    data = [NSData dataWithBytes:data.bytes length:data.length];
    
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
    [data writeToFile:zipPath options:0 error:&error];
    if (!error) {
        if ([SSZipArchive unzipFileAtPath:zipPath toDestination:zipDirPath overwrite:YES password:[DJHotfixZipHelper processPwd:password] error:&error]) {
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

+ (NSString *)processPwd:(NSString *)originalPwd
{
    if (originalPwd.length > 11) {
        return [originalPwd substringFromIndex:11];
    }
    return originalPwd;
}

@end
