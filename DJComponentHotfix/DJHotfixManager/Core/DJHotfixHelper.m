//
//  DJHotfixHelper.m
//  DJLibComponentHotfix
//
//  Created by Dokay on 16/7/26.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "DJHotfixHelper.h"
#import "RSA.h"
#import <CommonCrypto/CommonCrypto.h>

#define HOT_UPDATE_DIR @"dj_hotfix"
#define CACHE_FILE_NAME @"dj_hotfix_cache_file.js"

@implementation DJHotfixHelper

- (void)saveCacheValue:(NSObject *)value forKey:(NSString *)key
{
    value = value ? value : @"";
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSObject *)valueForCacheKey:(NSString *)key
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
    return [self p_saveJSFileWithData:jsContentData];
}

- (NSString *)jsContentCached
{
    return [self p_readJSFileFromLocal];
}

- (NSString *)jsRealMd5
{
    NSString *filePath = [self p_jsCacheFilePath];
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        return [self p_md5WithData:fileData];
    }
    return @"";
}

/**
 *  保存js文件
 *
 *  @param data js 字符串二进制
 */
- (void)p_saveJSFileWithData:(NSData *)data
{
    if (data) {
        NSString *filePath = [self p_jsCacheFilePath];
        NSError *error;
        [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if (error) {
            NSLog(@"js write fail :%@",error);
        }
    }
}

- (NSString *)p_readJSFileFromLocal
{
    NSString *filePath = [self p_jsCacheFilePath];
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        if (fileData) {
            NSString *jsContentNew =[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            return jsContentNew;
        }
    }
    return nil;
}

- (NSString *)p_jsCacheFilePath
{
    return [NSString stringWithFormat:@"%@/%@",[self p_dirForCache],CACHE_FILE_NAME];
}

- (NSString *)p_dirForCache
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

- (NSString*)p_md5WithData:(NSData *)data
{
    unsigned char result[16];
    CC_MD5( data.bytes, (CC_LONG)data.length, result ); // This is the md5 call
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

@end
