//
//  SearchQuestionResultViewController.m
//  SearchIntentUI
//
//  Created by 林君毅 on 2025/2/26.
//

#import "SearchQuestionResultViewController.h"

@interface SearchQuestionResultViewController()

@property (nonatomic, strong) SearchQuestionIntent *intent;

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UILabel *solutionLbl;
@property (nonatomic, strong) void(^completion)(BOOL success, CGFloat contentHeight);

@end

@implementation SearchQuestionResultViewController

- (id)initWithIntent:(SearchQuestionIntent *)intent completion:(nonnull void (^)(BOOL, CGFloat))completion {
    if (self = [super init]) {
        _intent = intent;
        _completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self titleLbl];
    [self beginSearch];
}

#pragma mark - Getter

- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
        _titleLbl.textColor = [UIColor blackColor];
        _titleLbl.font = [UIFont boldSystemFontOfSize:20];
        _titleLbl.text = @"解析";
        [self.view addSubview:_titleLbl];
    }
    return _titleLbl;
}

- (UILabel *)solutionLbl {
    if (!_solutionLbl) {
        _solutionLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, self.view.frame.size.width-40, 0)];
        _solutionLbl.textColor = [UIColor blackColor];
        _solutionLbl.font = [UIFont systemFontOfSize:12];
        _solutionLbl.numberOfLines = 0;
        [self.view addSubview:_solutionLbl];
    }
    return _solutionLbl;
}

#pragma mark - Search

- (void)beginSearch {
    UIImage *image = [UIImage imageWithData:_intent.image.data];
    if (image == nil) {
        [self updateSolutionText:@"图片有误"];
        return;
    }
    
    // 模拟搜索过程，用时1.5秒
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateSolutionText:@"这是搜索结果\n\n用户之前遇到了很多关于Siri Intent和快捷指令集成到Objective-C项目中的问题。现在他们想要从头开始，详细了解如何从零创建一个Intents并实现快捷指令。我需要确保每一步都清晰，特别是考虑到用户之前在配置和类生成上遇到的困难。\n\n首先，用户需要创建一个新的Siri Intent目标。这可能涉及到在Xcode中添加新目标，但用户之前可能混淆了主目标和独立目标的位置，所以需要明确指导如何找到和创建它。\n\n接下来，定义Intent的参数是关键。用户之前因为缺少参数组合的摘要而遇到错误，因此需要强调在.IntentDefinition文件中填写必要信息，尤其是无参数情况的摘要。同时，参数类型和必填项的检查也是重点，避免后续的类型不匹配问题。 "];
        if (self.completion) {
            CGFloat contentHeight = self.solutionLbl.frame.origin.y + self.solutionLbl.frame.size.height;
            self.completion(YES, contentHeight);
        }
    });
}

- (void)updateSolutionText:(NSString *)text {
    self.solutionLbl.text = text;
    [self.solutionLbl sizeToFit];
}

@end
