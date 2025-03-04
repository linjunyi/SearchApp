//
//  KeychainGroupService.m
//  Ape_uni
//
//  Created by 林君毅 on 2025/3/2.
//  Copyright © 2025 Fenbi. All rights reserved.
//

#import "KeychainGroupService.h"
#import <Security/Security.h>

#define kKeychainGroup @"com.fenbi.share.searchDemo.share"
#define kKeychainUserService @"com.fenbi.share.searchDemo.userservice"

#define kKeychainAppVersionKey @"appVersion"
#define kKeychainCookieKey @"cookie"

#define NSStringConvertToNSData(string) (string ? [string dataUsingEncoding:NSUTF8StringEncoding] : nil)
#define NSStringConvertFromNSData(data) (data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil)
#define NSDataConvertFromNSArray(ary) (ary ? [NSKeyedArchiver archivedDataWithRootObject:ary requiringSecureCoding:NO error:nil] : nil)
#define NSArrayConvertFromNSData(data, objClass) (data ? [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class], objClass, nil] fromData:data error:nil] : nil)

@implementation KeychainGroupService

+ (BOOL)isAppStoreVersion {
    return [[NSBundle mainBundle].bundleIdentifier hasPrefix:@"com."];
}

+ (NSString *)appIdentifierPrefix {
#ifdef DEBUG
    return @"V34ASSQSUT";
#endif
    return @"N6S7VM347S";
}

+ (NSString *)groupName {
    return [NSString stringWithFormat:@"%@.%@", [self appIdentifierPrefix], kKeychainGroup];
}

+ (BOOL)saveData:(nullable NSData *)data key:(NSString *)key {
    if (key == nil) {
        return NO;
    }
    NSMutableDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kKeychainUserService,
        (__bridge id)kSecAttrAccessGroup: [self groupName],
        (__bridge id)kSecAttrAccount: key,
    }.mutableCopy;
    
    // 先尝试删除数据
    SecItemDelete((__bridge CFDictionaryRef)query);
    if (data) {
        query[(__bridge id)kSecValueData] = data;
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        if (status != errSecSuccess) {
            return NO;
        }
    }
    return YES;
}

+ (NSData *)getDataForkey:(NSString *)key {
    if (key == nil) {
        return nil;
    }
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kKeychainUserService,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecAttrAccessGroup: [self groupName],
        (__bridge id)kSecReturnData : @YES,
    };

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess) {
        return nil;
    }
    NSData *data = (__bridge_transfer NSData *)result;
    return data;
}

+ (void)saveAppVersion:(NSString *)appVersion {
    [self saveData:NSStringConvertToNSData(appVersion) key:kKeychainAppVersionKey];
}

+ (NSString *)getAppVersion {
    return NSStringConvertFromNSData([self getDataForkey:kKeychainAppVersionKey]);
}

+ (void)saveCookie:(nullable NSArray<NSHTTPCookie *> *)cookie {
    [self saveData:NSDataConvertFromNSArray(cookie) key:kKeychainCookieKey];
}

+ (nullable NSArray<NSHTTPCookie *> *)getCookie {
    return NSArrayConvertFromNSData([self getDataForkey:kKeychainCookieKey], [NSHTTPCookie class]);
}

@end
