//
//  ViewController.m
//  SearchApp
//
//  Created by 林君毅 on 2025/2/26.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat centerX = self.view.frame.size.width / 2;
    CGFloat btnWidth = 200, btnHeight = 50;
    CGFloat btnLeft = centerX - btnWidth/2;
    
    UIButton *addSearchBtn = [self createBtnWith:@"添加截屏搜题指令" selector:@selector(addSearchShortCut)];
    addSearchBtn.frame = CGRectMake(btnLeft, 150, btnWidth, btnHeight);
    [self.view addSubview:addSearchBtn];
}


- (UIButton *)createBtnWith:(NSString *)title selector:(SEL)selector {
    UIButton *btn = [UIButton new];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title ?: @"按钮" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    btn.layer.cornerRadius = 8;
    btn.layer.shadowColor = [UIColor blackColor].CGColor;
    btn.layer.shadowOpacity = .1;
    btn.layer.shadowRadius = 10;
    btn.layer.shadowOffset = CGSizeMake(0, 6);
    return btn;
}

#pragma mark - Action

- (void)addSearchShortCut {
    //    NSString *urlString = @"ShortCut://create-shortCut";
    NSString *urlString = @"https://www.icloud.com/shortcuts/3b76dbdcd840459fa4819a7974b6b08e";
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
