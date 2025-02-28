# SearchApp

本文介绍如何使用快捷指令结合触控功能，实现在不打开app的情况下，通过长按屏幕弹出搜题浮窗。

#1. 添加Intent

我们需要在工程内引入**Intents Extension**、**Intents UI Extension**。其中**Intents Extension**用于处理快捷指令，**Intents UI Extension**用于设置快捷指令触发后的浮窗UI。
![添加Extension](https://upload-images.jianshu.io/upload_images/4890409-23129d2dfdd2e200.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

添加**Intent Definition File**，这是个定义文件，我们可以在其中添加我们app支持的快捷指令。
![Intent Definition File](https://upload-images.jianshu.io/upload_images/4890409-cbfaa8510aa30f0d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们把**.intentdefinition**的app、Intents、IntentsUI的target都勾选上，以便它们都能调用我们的自定义Intent类。
![勾选target](https://upload-images.jianshu.io/upload_images/4890409-386adfe694709f27.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

添加新的Intent，并配置相应的选项：
- Category设置Intent类型，不同的类型弹窗的UI和交互略有不同
- Custom Class 系统默认生成的Intent只读头文件，包含Intent对应的类和handler需遵循的协议
- User confirmation required 会先弹一个包含取消按钮的弹窗
- Intent is user-configurable in the Shortcuts app and Add to Siri 指令是否能在**快捷指令app**中找到
- 为Intent添加一个参数image，并将其type选择为File，File Type选择image
- 在Shortcuts app中的Input parameter选中image，  将上一个指令的输出，作为image参数输入

![添加新Intent](https://upload-images.jianshu.io/upload_images/4890409-1c39dd404671ec85.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![配置Intent 1](https://upload-images.jianshu.io/upload_images/4890409-d3efae1b4cd566b9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![配置intent 2](https://upload-images.jianshu.io/upload_images/4890409-74e8aa515f7007c1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

添加完Intent后，需要修改主app、Intents、IntentsUI的info.plist, 添加对SearchQuestionIntent的关联

![主app info.plist](https://upload-images.jianshu.io/upload_images/4890409-a500ce53118f9d70.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![Intents info.plist](https://upload-images.jianshu.io/upload_images/4890409-475b1a6b2419a609.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![IntentsUI info.plist](https://upload-images.jianshu.io/upload_images/4890409-4b7d2e1cf51c8911.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### ⚠️ Swift编译问题解决方案
当使用swift时添加image参数编译会报错。这是因为在SearchQuestionIntent.swift中两个swift方法指向了同一个objc方法导致的。这个文件由Xcode自动生成的只读文件，我们没法修改。这是Xcode 14的bug，不过我使用Xcode 15.3也复现了。解决的办法是：升级Xcode或者添加Extension的时候选择Objective-C语言。参考：[xcode-14-release-notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes)

![编译报错](https://upload-images.jianshu.io/upload_images/4890409-179fee3ca5d71610.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![方法定义](https://upload-images.jianshu.io/upload_images/4890409-2100f7d7032dda0f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![Xcode14 note](https://upload-images.jianshu.io/upload_images/4890409-88691487fb86c073.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#2. 代码实现要点
现在我们已经配置完快捷指令了，之后需要在代码层面进行处理。

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



修改IntentHandler文件，返回我们的自定义Handler
![handlerForIntent](https://upload-images.jianshu.io/upload_images/4890409-34b1cc71a9740bc5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

SearchQuestionIntentHandler需要实现SearchQuestionIntentHandling的代理方法。我们这里实现了3个方法，他们的调用顺序是comfirm -> resolveImage -> handle。handle方法返回了一个带有code的response，code是在SearchQuestionIntent.h中定义的枚举，每个code对应一种状态，其弹窗和交互也略有不同。比如ContinueInApp是不弹窗直接跳转到app，Success弹出一个带有勾号的弹窗，InProgress也是弹窗但不带勾号。（具体的UI和交互可能在不同的iOS系统版本下略有不同）
![SearchQuestionHandler](https://upload-images.jianshu.io/upload_images/4890409-a43ee6f194771941.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![Response Code](https://upload-images.jianshu.io/upload_images/4890409-ee51962151109d26.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


接下来我们需要修改IntentsUI的代码，来修改我们Siri浮窗的展示。系统对Siri浮窗的UI限制较多，我们只被允许修改中间的部分内容。这部分内容由IntentViewController提供。加载流程如下图
![IntentsUI加载流程](https://upload-images.jianshu.io/upload_images/4890409-dee31a64385257ad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们实现```configureViewForParameters:ofInteraction:interactiveBehavior:context:completion:```来定制我们的ui，[参考intentsUI文档](https://developer.apple.com/documentation/intentsui/inuihostedviewcontrolling/configureview(for:of:interactivebehavior:context:completion:)?language=objc)。对于不同的Intent，我们应该实现不同的ViewController，并经其添加到self.view当中。在viewDidLoad方法当中，我们添加了一个毛玻璃效果的view，这是因为在系统的Siri浮窗下有一些系统自带的UI(比如勾号、分割线等)，这些不由我们控制，所以添加毛玻璃将其覆盖以美化UI效果。

需要注意的是，受苹果限制，我们添加到siri浮窗中的自定义视图不支持触摸事件，因为无法实现点击按钮、滑动等效果。但是当用户点击自定义视图的整体部分时，系统会跳转到我们的app内部。

#生成快捷指令iCloud链接
打开 **快捷指令app**，在我们的app下就能看到所添加 “搜题🔍”。我们新建一个快捷指令，分别添加“截屏”、“搜题🔍”，如下图。可以看到截屏的结果已经作为“搜题🔍”的图片参数输入了。“运行时显示”打开时才能显示Siri浮窗。我们点击分享，生成快捷指令的iCloud链接，之后我们就可以通过iCloud链接引导用户快速地构建这个指令。我们生成的链接是：https://www.icloud.com/shortcuts/3b76dbdcd840459fa4819a7974b6b08e，用UIApplication的```openURL:options:completionHandler:```方法打开它。

![构造快捷指令](https://upload-images.jianshu.io/upload_images/4890409-d01b1c0de792c046.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![iCloud链接快速构建快捷指令](https://upload-images.jianshu.io/upload_images/4890409-d8df9912691d11d9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![添加窗口](https://upload-images.jianshu.io/upload_images/4890409-cfac5d2ef0a64ca5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#关联触控
打开 设置-辅助功能-触控-辅助触控 页面，打开辅助触控功能，在 自定义操作 中选择一个手势，比如长按，选中我们的快捷指令“搜题🔍”。之后我们就可以在手机任意页面，通过长按触控球来进行搜题了。

![效果展示](https://upload-images.jianshu.io/upload_images/4890409-70cf8278f3400f96.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)





demo地址：











