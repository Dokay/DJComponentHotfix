//
//  DJHotfixZipHelper.h
//  DJComponentHotfix
//
//  Created by Dokay on 16/11/23.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJHotfixZipHelper : NSObject

+ (NSString *)unzipJSWithData:(NSData *)data password:(NSString *)password andEncryptContent:(NSString *)encryptContent;

@end
