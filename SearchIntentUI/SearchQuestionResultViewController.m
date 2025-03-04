//
//  SearchQuestionResultViewController.m
//  SearchIntentUI
//
//  Created by 林君毅 on 2025/2/26.
//

#import "SearchQuestionResultViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define SolutionTop 50
#define SolutionLeftRight 20
#define SolutionBottom 30

@interface SearchQuestionResultViewController()

@property (nonatomic, strong) SearchQuestionIntent *intent;

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UILabel *solutionLbl;
@property (nonatomic, strong) UILabel *errorLbl;
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
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(SolutionLeftRight, 0, 100, 20)];
        _titleLbl.textColor = [UIColor blackColor];
        _titleLbl.font = [UIFont boldSystemFontOfSize:20];
        _titleLbl.text = @"解析";
        [self.view addSubview:_titleLbl];
    }
    return _titleLbl;
}

- (UILabel *)solutionLbl {
    if (!_solutionLbl) {
        _solutionLbl = [[UILabel alloc] initWithFrame:CGRectMake(SolutionLeftRight, SolutionTop, self.view.frame.size.width-SolutionLeftRight*2, 0)];
        _solutionLbl.backgroundColor = [UIColor clearColor];
        _solutionLbl.textColor = [UIColor blackColor];
        _solutionLbl.font = [UIFont systemFontOfSize:12];
        _solutionLbl.numberOfLines = 0;
        [self.view addSubview:_solutionLbl];
    }
    return _solutionLbl;
}

- (UILabel *)errorLbl {
    if (!_errorLbl) {
        _errorLbl = [[UILabel alloc] initWithFrame:CGRectMake(SolutionLeftRight, SolutionTop, self.view.frame.size.width-SolutionLeftRight*2, 0)];
        _errorLbl.backgroundColor = [UIColor clearColor];
        _errorLbl.textColor = [UIColor redColor];
        _errorLbl.font = [UIFont systemFontOfSize:15];
        _errorLbl.numberOfLines = 0;
        [self.view addSubview:_errorLbl];
    }
    return _errorLbl;
}

#pragma mark - Search

- (void)beginSearch {
    if (@available(iOS 13.0, *)) {
        [self p_beginSearch];
    } else {
        [self updateError:@"浮窗搜题仅支持 iOS 13.0以上版本~"];
    }
}

- (void)p_beginSearch API_AVAILABLE(ios(13.0)) {
    UIImage *image = [UIImage imageWithData:_intent.image.data];
    if (image == nil) {
        [self updateError:@"图片有误"];
        return;
    }
    
    // 模拟搜索过程，用时1.5秒
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateSolutionText:@"这是一段模拟的搜索结果。\n\n本Demo用于实现浮窗搜题效果，支持iOS12+系统。通过快捷指令+触控实现， 快捷指令使用iClound的链接快捷创建，采用Keychain进行app与plugin之间的数据共享"];
        if (self.completion) {
            CGFloat contentHeight = self.solutionLbl.frame.origin.y + self.solutionLbl.frame.size.height;
            self.completion(YES, contentHeight);
        }
    });
}

- (void)updateError:(NSString *)error {
    self.errorLbl.text = error;
    [self.errorLbl sizeToFit];
    if (self.completion) {
        self.completion(YES, CGRectGetMaxY(self.errorLbl.frame) + SolutionBottom);
    }
}

- (void)updateSolutionText:(NSString *)text {
    self.solutionLbl.text = text;
    [self.solutionLbl sizeToFit];
    if (self.completion) {
        self.completion(YES, CGRectGetMaxY(self.solutionLbl.frame) + SolutionBottom);
    }
}

@end
