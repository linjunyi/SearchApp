//
//  SearchQuestionIntentHandler.m
//  SearchIntent
//
//  Created by 林君毅 on 2025/2/27.
//

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

@end
