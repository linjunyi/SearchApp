本文介绍如何使用快捷指令结合触控功能，实现在不打开app的情况下，通过长按屏幕弹出搜题浮窗。

## 1. 添加Intent

我们需要在工程内引入**Intents Extension**、**Intents UI Extension**。其中**Intents Extension**用于处理快捷指令，**Intents UI Extension**用于设置快捷指令触发后的浮窗UI。
![添加Extension](https://upload-images.jianshu.io/upload_images/4890409-23129d2dfdd2e200.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

添加**Intent Definition File**，这是个定义文件，我们可以在其中添加我们app支持的快捷指令。
![Intent Definition File](https://upload-images.jianshu.io/upload_images/4890409-cbfaa8510aa30f0d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们把**intent.intentdefinition**的app、Intents、IntentsUI的target都勾选上，以便它们都能调用我们的自定义Intent类。
![勾选target](https://upload-images.jianshu.io/upload_images/4890409-386adfe694709f27.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

添加新的Intent，并配置相应的选项：
- *Category* 设置Intent类型，不同的类型弹窗的UI和交互略有不同
- *Custom Class* 系统默认生成的Intent只读头文件，包含Intent对应的类和handler需遵循的协议
- *User confirmation required* 会先弹一个包含 *下一步* 和 *取消* 按钮的弹窗
- *Intent is user-configurable in the Shortcuts app and Add to Siri* 指令是否能在**快捷指令app**中找到
- 为Intent添加一个参数 *image* ，并将其type选择为File，File Type选择image
- 在Shortcuts app中的Input parameter选中 *image* ，  将上一个指令的输出，作为 *image* 参数输入

![添加新Intent](https://upload-images.jianshu.io/upload_images/4890409-1c39dd404671ec85.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![配置Intent 1](https://upload-images.jianshu.io/upload_images/4890409-d3efae1b4cd566b9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![配置intent 2](https://upload-images.jianshu.io/upload_images/4890409-74e8aa515f7007c1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

添加完Intent后，需要修改主app、Intents、IntentsUI的info.plist, 添加对**SearchQuestionIntent**的关联

![主app info.plist](https://upload-images.jianshu.io/upload_images/4890409-a500ce53118f9d70.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![Intents info.plist](https://upload-images.jianshu.io/upload_images/4890409-475b1a6b2419a609.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![IntentsUI info.plist](https://upload-images.jianshu.io/upload_images/4890409-4b7d2e1cf51c8911.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### ⚠️ Swift编译问题解决方案
当使用swift时添加 *image* 参数编译会报错。这是因为在**SearchQuestionIntent.swift**中两个swift方法指向了同一个objc方法导致的。这个文件由Xcode自动生成的只读文件，我们没法修改。这是Xcode 14的bug，不过我使用Xcode 15.3也复现了。解决的办法是：升级Xcode或者添加Extension的时候选择Objective-C语言。参考：[xcode-14-release-notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes)

![编译报错](https://upload-images.jianshu.io/upload_images/4890409-179fee3ca5d71610.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![方法定义](https://upload-images.jianshu.io/upload_images/4890409-2100f7d7032dda0f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![Xcode14 note](https://upload-images.jianshu.io/upload_images/4890409-88691487fb86c073.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 2. 代码实现要点
现在我们已经配置完快捷指令了，之后需要在代码层面进行处理。

### 2.1 AppDelegate
修改AppDelegate内关于UserActivity的代理方法，这个是快捷指令打开app时触发（包括指令直接调起app，以及点击siri浮窗进入等情况）。
```
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
```

### 2.2 IntentHandler
修改**IntentHandler**文件，返回我们的自定义Handler
```
- (id)handlerForIntent:(INIntent *)intent {
    // This is the default implementation.  If you want different objects to handle different intents,
    // you can override this and return the handler you want for that particular intent.
    
    if ([intent isKindOfClass:[SearchQuestionIntent class]]) {
        return [SearchQuestionIntentHandler new];
    }
    
    return self;
}
```

**SearchQuestionIntentHandler**需要实现 *SearchQuestionIntentHandling* 的代理方法。我们这里实现了3个方法，他们的调用顺序是 *comfirm -> resolveImage -> handle* 。*handle* 方法返回了一个带有code的response，code是在 **SearchQuestionIntent.h** 中定义的枚举，每个code对应一种状态，其弹窗和交互也略有不同。比如 *ContinueInApp* 是不弹窗直接跳转到app，*Success* 弹出一个带有勾号的弹窗，*InProgress* 也是弹窗但不带勾号。（具体的UI和交互可能在不同的iOS系统版本下略有不同）

```
#import "SearchQuestionIntentHandler.h"
#import "SearchQuestionIntent.h"

@interface SearchQuestionIntentHandler() <SearchQuestionIntentHandling>
@end

@implementation SearchQuestionIntentHandler

#pragma mark - SearchQuestionIntentHandling
// 调用顺序: comfirm -> resolveImage -> handle

//- (void)confirmSearchQuestion:(SearchQuestionIntent *)intent completion:(void (^)(SearchQuestionIntentResponse * _Nonnull))completion {
//}

- (void)handleSearchQuestion:(nonnull SearchQuestionIntent *)intent completion:(nonnull void (^)(SearchQuestionIntentResponse * _Nonnull))completion {
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([SearchQuestionIntent class])];
    SearchQuestionIntentResponse *response = [[SearchQuestionIntentResponse alloc] initWithCode:SearchQuestionIntentResponseCodeInProgress userActivity:userActivity];
    completion(response);
}

- (void)resolveImageForSearchQuestion:(nonnull SearchQuestionIntent *)intent withCompletion:(nonnull void (^)(INFileResolutionResult * _Nonnull))completion  API_AVAILABLE(ios(13.0)){
    INFile *image = intent.image;
    if (image != nil) {
        INFileResolutionResult *result = [INFileResolutionResult successWithResolvedFile:intent.image];
        completion(result);
    } else {
        // image 参数无效，提示用户重新输入
        INFileResolutionResult *result = [INFileResolutionResult needsValue];
        completion(result);
    }
}
```
```
/*!
 @abstract Constants indicating the state of the response.
 */
typedef NS_ENUM(NSInteger, SearchQuestionIntentResponseCode) {
    SearchQuestionIntentResponseCodeUnspecified = 0,
    SearchQuestionIntentResponseCodeReady,
    SearchQuestionIntentResponseCodeContinueInApp,
    SearchQuestionIntentResponseCodeInProgress,
    SearchQuestionIntentResponseCodeSuccess,
    SearchQuestionIntentResponseCodeFailure,
    SearchQuestionIntentResponseCodeFailureRequiringAppLaunch
} API_AVAILABLE(ios(12.0), macos(11.0), watchos(5.0)) API_UNAVAILABLE(tvos);
```
### 2.3 自定义浮窗UI
接下来我们需要修改**IntentsUI**的代码，来修改我们Siri浮窗的展示。系统对Siri浮窗的UI限制较多，我们只被允许修改中间的部分内容。这部分内容由**IntentViewController**提供。加载流程如下图
![IntentsUI加载流程](https://upload-images.jianshu.io/upload_images/4890409-dee31a64385257ad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们实现```configureViewForParameters:ofInteraction:interactiveBehavior:context:completion:```来定制我们的ui，[*参考intentsUI文档*](https://developer.apple.com/documentation/intentsui/inuihostedviewcontrolling/configureview(for:of:interactivebehavior:context:completion:)?language=objc)。对于不同的Intent，我们应该实现不同的ViewController，并经其添加到self.view当中。在viewDidLoad方法当中，我们添加了一个毛玻璃效果的view，这是因为在系统的Siri浮窗下有一些系统自带的UI(比如勾号、分割线等)，这些不由我们控制，所以添加毛玻璃将其覆盖以美化UI效果。

需要注意的是，受苹果限制，我们添加到siri浮窗中的自定义视图不支持触摸事件，因为无法实现点击按钮、滑动等效果。但是当用户点击自定义视图的整体部分时，系统会跳转到我们的app内部。
```
@implementation IntentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    // 添加毛玻璃效果，覆盖住系统自带的分割线和打勾图标
    UIBlurEffectStyle style = UIBlurEffectStyleLight;
    if (@available(iOS 13.0, *)) {
        style = UIBlurEffectStyleSystemMaterialLight;
    }
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView *bgView = [[UIVisualEffectView alloc] initWithEffect:effect];
    bgView.frame = self.view.bounds;
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:bgView];
}

#pragma mark - INUIHostedViewControlling

// Prepare your view controller for the interaction to handle.
- (void)configureViewForParameters:(NSSet <INParameter *> *)parameters ofInteraction:(INInteraction *)interaction interactiveBehavior:(INUIInteractiveBehavior)interactiveBehavior context:(INUIHostedViewContext)context completion:(void (^)(BOOL success, NSSet <INParameter *> *configuredParameters, CGSize desiredSize))completion {
    // Do configuration here, including preparing views and calculating a desired size for presentation.
    
    if ([interaction.intent isKindOfClass:[SearchQuestionIntent class]]) {
        SearchQuestionResultViewController *searchResultVC = [[SearchQuestionResultViewController alloc] initWithIntent:(SearchQuestionIntent *)interaction.intent completion:^(BOOL success, CGFloat contentHeight) {
            CGSize size = [self extensionContext].hostedViewMaximumAllowedSize;
            size.height = MIN(size.height, contentHeight);
            if (completion) {
                completion(success, parameters, size);
            }
        }];
        [self addChildViewController:searchResultVC];
        [self.view addSubview:searchResultVC.view];
    } else {
        if (completion) {
            completion(YES, parameters, [self desiredSize]);
        }
    }
}

- (CGSize)desiredSize {
    CGSize size = [self extensionContext].hostedViewMaximumAllowedSize;
    return size;
}

@end
```
### 2.4 数据同步
主app是作为 *application* 运行，intents和intentsUI则是作为 *plugin* 运行，它们有不同的沙盒和进程。如果需要在它们之间进行数据共享，比如同步cookie、用户配置等，可以采用**Keychain Group** 或者 **App Group**，我们采用的是**Keychain Group**方案。
> app的沙盒在Containers/Data/Application下，intents的沙盒在 Containers/Data/PluginKitPlugin下， appGroup的沙盒在 Containers/Shared/AppGroup下，Keychain Group则是加密存储在系统的keychain中

#### 2.4.1 添加Keychain Group
在主app的target下，**Signing & Capability** -> **+ Capability** -> **Keychain Sharing**, 添加新的*Keychain group*，比如 *com.fenbi.share.searchDemo.share*。同样地，在intents、intentsUI下添加相同的 *Keychain Group* 。Xcode会自动生成权限声明文件（.entitlements），其中 *appIdentifierPrefix* 是我们的apple开发团队id，他作为前缀拼接在前面，最终的 *Keychain Group* 是 *{开发团队id}.com.fenbi.share.searchDemo.share*。我们可以在 **Build Settings**->**Signing**->**Code Signing Entitlements** 修改Debug、Release各自对应的权限声明文件。
![entitlements文件](https://upload-images.jianshu.io/upload_images/4890409-fd6bd6258eccfc4d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



#### 2.4.2 使用Security进行钥匙串读写
```
#import <Security/Security.h>

#define kKeychainGroup @"com.fenbi.share.searchDemo.share"
#define kKeychainUserService @"com.fenbi.share.searchDemo.userservice"

+ (NSString *)appIdentifierPrefix {
#pragma mark - todo 这是Demo随机生成的id，实际开发中需要替换成开发团队id
    return @"W4E5KLUTS8";
}

+ (NSString *)groupName {
    return [NSString stringWithFormat:@"%@.%@", [self appIdentifierPrefix], kKeychainGroup];
}

// 保存key-value到keychain
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

// 从keychain读取value
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
```


### 2.5 调试
如果需要调试Intents或者IntentsUI，我们需要选中对应的target（比如SearchIntentUI），点击build后在 *Choose an app to run* 弹窗中选择Shortcuts。
![Choose an app to run.png](https://upload-images.jianshu.io/upload_images/4890409-4c6786e57e3ee7eb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


### 2.6 打包
主app、Intents、IntentsUI都需要各自的*bundle identifier*，需要在apple developer后台添加对应的Identifier，并使用同一个签名证书生成各自的Profiles。
在build或者打包的时候，需要让主app和Extension的 **Signing & Capability**下 **Signing Certificate** 保持一致，同时 **Build Settings** 下的 **Architectures** 的配置也应保持一致。

![Architectures配置示例](https://upload-images.jianshu.io/upload_images/4890409-3c20f754de54a6e7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

否则当主app和Extension引入相同的第三方framework时，就会由于主app和Extentsion的签名证书或架构类型的不同而导致签名失败。
例如报错：*Embedded binary is not signed with the same certificate as the parent app. Verify the embedded binary target's code sign settings match the parent app's.*

打包之后，Intents 和 IntentsUI 是作为扩展包嵌入到主程序包中的，如下图
![ipa包](https://upload-images.jianshu.io/upload_images/4890409-d3fcb6cd86bb101b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
我们可以在主app的 **Build Phases** 下的 **Embed Foundation Extensions** 查看我们当前的扩展包，它们都是Embed Without Signing的方式嵌入的，因为它们自己已经进行了签名，不需要主app再次对它们进行签名。
![Build Phases.png](https://upload-images.jianshu.io/upload_images/4890409-a163e29608ac1f73.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 3. 生成快捷指令iCloud链接
打开 **快捷指令app**，在我们的app下能看到所添加 “**搜题🔍**”。我们新建一个快捷指令，分别添加“**截屏**”、“**搜题🔍**”，如下图。可以看到截屏的结果已经作为“**搜题🔍**”的图片参数输入了。“**运行时显示**”打开时才能显示Siri浮窗。我们点击分享，生成快捷指令的iCloud链接，之后我们就可以通过iCloud链接引导用户快速地构建这个指令。我们生成的链接是：https://www.icloud.com/shortcuts/3b76dbdcd840459fa4819a7974b6b08e，用 **UIApplication** 的```openURL:options:completionHandler:```方法打开它。

![构造快捷指令](https://upload-images.jianshu.io/upload_images/4890409-d01b1c0de792c046.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```
//    NSString *urlString = @"ShortCut://create-shortCut";
    NSString *urlString = @"https://www.icloud.com/shortcuts/3b76dbdcd840459fa4819a7974b6b08e";
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
```

![添加窗口](https://upload-images.jianshu.io/upload_images/4890409-cfac5d2ef0a64ca5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 4. 关联触控
打开 **设置-辅助功能-触控-辅助触控** 页面，打开**辅助触控**功能，在 **自定义操作** 中选择一个手势，比如长按，选中我们的快捷指令“**搜题🔍**”。之后我们就可以在手机任意页面，通过长按触控球来进行搜题了。

![效果展示](https://upload-images.jianshu.io/upload_images/4890409-b313d800893294ad.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)











