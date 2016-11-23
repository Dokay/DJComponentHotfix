//
//  DJHotfixManager.h
//  DJLibComponentHotfix
//
//  Created by Dokay on 16/7/26.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJHotfixHelper.h"

@protocol DJHotfixManagerDeleagte <NSObject>

- (void)applyPatchSuccess:(BOOL)isFromServer;
- (void)downloadFail;

@end

@interface DJHotfixManager : NSObject

@property (nonatomic, readonly) NSObject<DJHotfixHelperProtocol> *hotFixHelper;//默认是DJHotfixHelper，这里使用者可以自己实现DJHotfixHelperProtocol
@property (nonatomic, weak)     NSObject<DJHotfixManagerDeleagte> *delegate;
@property (nonatomic, assign) BOOL serverZipEnable;
@property (nonatomic, strong) NSString *tmpZipPassword;

- (instancetype)initWithHelper:(NSObject<DJHotfixHelperProtocol> *)helper;

- (void)excuteJSFromLocal;
- (void)excuteJSFromServerWithUrl:(NSString *)url;

- (NSString *)readLastestMd5;
- (void)setServerMd5:(NSString *)md5;

@end
