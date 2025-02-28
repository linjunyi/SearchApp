//
//  IntentHandler.m
//  SearchIntent
//
//  Created by 林君毅 on 2025/2/26.
//

#import "IntentHandler.h"
#import "SearchQuestionIntent.h"
#import "SearchQuestionIntentHandler.h"

@interface IntentHandler ()

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {
    // This is the default implementation.  If you want different objects to handle different intents,
    // you can override this and return the handler you want for that particular intent.
    
    if ([intent isKindOfClass:[SearchQuestionIntent class]]) {
        return [SearchQuestionIntentHandler new];
    }
    
    return self;
}

@end
