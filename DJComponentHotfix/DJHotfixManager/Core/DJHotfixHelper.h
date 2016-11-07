//
//  DJHotfixHelper.h
//  DJLibComponentHotfix
//
//  Created by Dokay on 16/7/26.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DJHotfixHelperProtocol <NSObject>

/**
 *  保存键值对
 *
 *  @param value 需要保存的值
 *  @param key 需要保存的键
 */
- (void)saveCacheValue:(NSObject *)value forKey:(NSString *)key;

/**
 *  根据键值读取值
 *
 *  @param key 键值
 *
 *  @return 值
 */
- (NSObject *)valueForCacheKey:(NSString *)key;

/**
 *  最近缓存的js补丁
 *
 *  @return 补丁内容
 */
- (NSString *)jsContentCached;

/**
 *  保存服务端下载的js文件
 *
 *  @param jsContentData js文件数据
 */
- (void)saveJSContent:(NSData *)jsContentData;

/**
 *  解密Md5
 *
 *  @param md5Encryption 加密的Md5
 *
 *  @return 解密后的Md5
 */
- (NSString *)decryptionMd5:(NSString *)md5Encryption;

/**
 *  获取本地下载好的js文件Md5
 *
 *  @return md5
 */
- (NSString *)jsRealMd5;

/**
 *  验证md5的公钥
 */
@property (nonatomic, strong) NSString *rsa_public_key;

@end

@interface DJHotfixHelper : NSObject<DJHotfixHelperProtocol>

@property (nonatomic, strong) NSString *rsa_public_key;

@end
