//
//  KeychainGroupService.h
//  Ape_uni
//
//  Created by 林君毅 on 2025/3/2.
//  Copyright © 2025 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeychainGroupService : NSObject

+ (void)saveAppVersion:(NSString *)appVersion;
+ (NSString *)getAppVersion;

+ (void)saveCookie:(nullable NSArray<NSHTTPCookie *> *)cookie;
+ (nullable NSArray<NSHTTPCookie *> *)getCookie;

@end

NS_ASSUME_NONNULL_END
