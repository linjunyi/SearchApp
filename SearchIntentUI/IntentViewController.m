//
//  IntentViewController.m
//  SearchIntentUI
//
//  Created by 林君毅 on 2025/2/26.
//

#import "IntentViewController.h"
#import "SearchQuestionIntent.h"
#import "SearchQuestionResultViewController.h"
#import "KeychainGroupService.h"

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

@interface IntentViewController ()

@end

@implementation IntentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *view = self.view;
    while (view) {
        view.backgroundColor = [UIColor clearColor];
        view = view.superview;
    }
    
    // 读取appVersion
//    NSArray<NSHTTPCookie *> *cookies = [KeychainGroupService getCookie];
}

#pragma mark - INUIHostedViewControlling

// Prepare your view controller for the interaction to handle.
- (void)configureViewForParameters:(NSSet <INParameter *> *)parameters ofInteraction:(INInteraction *)interaction interactiveBehavior:(INUIInteractiveBehavior)interactiveBehavior context:(INUIHostedViewContext)context completion:(void (^)(BOOL success, NSSet <INParameter *> *configuredParameters, CGSize desiredSize))completion {
    // Do configuration here, including preparing views and calculating a desired size for presentation.
    
    CGSize desiredSize = [self extensionContext].hostedViewMaximumAllowedSize;
    if ([interaction.intent isKindOfClass:[SearchQuestionIntent class]]) {
        SearchQuestionResultViewController *searchResultVC = [[SearchQuestionResultViewController alloc] initWithIntent:(SearchQuestionIntent *)interaction.intent completion:^(BOOL success, CGFloat contentHeight) {
            CGSize size = CGSizeMake(desiredSize.width, MIN(desiredSize.height, contentHeight));
            if (completion) {
                completion(success, parameters, size);
            }
        }];
        [self addChildViewController:searchResultVC];
        [self.view addSubview:searchResultVC.view];
        searchResultVC.view.frame = CGRectMake(0, 0, desiredSize.width, desiredSize.height);
    } else {
        if (completion) {
            completion(YES, parameters, desiredSize);
        }
    }
}

- (CGSize)desiredSize {
    CGSize size = [self extensionContext].hostedViewMaximumAllowedSize;
    return size;
}

@end
