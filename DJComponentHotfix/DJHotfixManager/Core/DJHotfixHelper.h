//
//  DJHotfixHelper.h
//  DJLibComponentHotfix
//
//  Created by Dokay on 16/7/26.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DJHotfixHelperProtocol <NSObject>

- (void)saveCacheValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)valueForCacheKey:(NSString *)key;
- (NSString *)decryptionMd5:(NSString *)md5Encryption;
- (void)saveJSContent:(NSData *)jsContentData;
- (NSString *)jsContentCached;

@property (nonatomic, strong) NSString *rsa_public_key;

@end

@interface DJHotfixHelper : NSObject<DJHotfixHelperProtocol>

@property (nonatomic, strong) NSString *rsa_public_key;

@end
