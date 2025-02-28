//
//  SearchQuestionResultViewController.h
//  SearchIntentUI
//
//  Created by 林君毅 on 2025/2/26.
//

#import <UIKit/UIKit.h>
#import "SearchQuestionIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchQuestionResultViewController : UIViewController

- (id)initWithIntent:(SearchQuestionIntent *)intent completion:(void(^)(BOOL success, CGFloat contentHeight))completion;

@end

NS_ASSUME_NONNULL_END
