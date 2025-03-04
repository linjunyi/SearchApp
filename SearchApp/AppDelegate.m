//
//  AppDelegate.m
//  SearchApp
//
//  Created by 林君毅 on 2025/2/26.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SearchQuestionIntent.h"
#import "KeychainGroupService.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [self shareInitDataToIntents];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    INIntent *intent = userActivity.interaction.intent;
    if (intent) {
        //需 #import "SearchQuestionIntent.h"
        if ([intent isKindOfClass:[SearchQuestionIntent class]]) {
            if (@available(iOS 13.0, *)) {
                SearchQuestionIntent *sqIntent = (SearchQuestionIntent *)intent;
                INFile *imageFile = sqIntent.image;
                if (imageFile.fileURL) {
                    // UIImage *image = [UIImage imageWithContentsOfFile:imageFile.fileURL.path];
                    // 点击浮窗区域跳转进app
                    // 处理代码省略
                }
            }
        }
    }
    return YES;
}

- (void)shareInitDataToIntents {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    [KeychainGroupService saveCookie:cookies];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [KeychainGroupService saveAppVersion:appVersion];
}

@end
