//
//  DJHotfixHelper.m
//  DJLibComponentHotfix
//
//  Created by Dokay on 16/7/26.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "DJHotfixHelper.h"
#import "RSA.h"

#define HOT_UPDATE_DIR @"dj_hotfix"
#define CACHE_FILE_NAME @"dj_hotfix_cache_file.js"

@implementation DJHotfixHelper

- (void)saveCacheValue:(NSString *)value forKey:(NSString *)key
{
    value = value ? value : @"";
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)valueForCacheKey:(NSString *)key
{
    NSAssert(key.length > 0, @"key can not be empty");
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (NSString *)decryptionMd5:(NSString *)md5Encryption
{
    if (self.rsa_public_key.length > 0) {
        NSString *decMd5 = [RSA decryptString:md5Encryption publicKey:self.rsa_public_key];
        return decMd5;
    }else{
        return md5Encryption;
    }
}

- (void)saveJSContent:(NSData *)jsContentData
{
    return [self saveJSFileWithData:jsContentData];
}

- (NSString *)jsContentCached
{
    return [self readJSFileFromLocal];
}

/**
 *  保存js文件
 *
 *  @param data js 字符串二进制
 */
- (void)saveJSFileWithData:(NSData *)data
{
    if (data) {
        NSString *filePath = [self jsCacheFilePath];
        NSError *error;
        [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if (error) {
            NSLog(@"js write fail :%@",error);
        }
    }
}

- (NSString *)readJSFileFromLocal
{
    NSString *filePath = [self jsCacheFilePath];
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        if (fileData) {
            NSString *jsContentNew =[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            return jsContentNew;
        }
    }
    return nil;
}

- (NSString *)jsCacheFilePath
{
    return [NSString stringWithFormat:@"%@/%@",[self dirForCache],CACHE_FILE_NAME];
}

- (NSString *)dirForCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,HOT_UPDATE_DIR];
    BOOL dir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

@end
