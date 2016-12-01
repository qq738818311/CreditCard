//
//  ARC4ViewController.m
//  信用卡1.0.1
//
//  Created by 曹鹏飞 on 16/7/15.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "ARC4ViewController.h"

@interface ARC4ViewController ()

@property (nonatomic, strong) UITextField *enterNumber;
@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation ARC4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"随机数";
    
    self.enterNumber = [[UITextField alloc] init];
    [self.view addSubview:self.enterNumber];
    [self.enterNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
        make.width.mas_equalTo(WIDTH - 40);
        make.height.mas_equalTo(30);
    }];
    self.enterNumber.placeholder = @"请输入目标值";
    self.enterNumber.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.enterNumber.layer.borderWidth = 0.5;
    self.enterNumber.layer.cornerRadius = 3;
    self.enterNumber.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.enterNumber.leftViewMode = UITextFieldViewModeAlways;
    self.enterNumber.font = [UIFont systemFontOfSize:15];
    self.enterNumber.keyboardType = UIKeyboardTypeNumberPad;
    
    UILabel *resultTips = [UILabel new];
    [self.view addSubview:resultTips];
    [resultTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.enterNumber.mas_bottom).offset(10);
    }];
    resultTips.text = @"结果输出：";
    resultTips.font = [UIFont systemFontOfSize:15];
    resultTips.textColor = [UIColor lightGrayColor];
    
    self.resultLabel = [UILabel new];
    [self.view addSubview:self.resultLabel];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(resultTips.mas_bottom).offset(5);
        make.width.mas_equalTo(WIDTH - 40);
        make.height.mas_equalTo(30);
    }];
    self.resultLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.resultLabel.layer.borderWidth = 0.5;
    self.resultLabel.layer.cornerRadius = 3;
    self.resultLabel.font = [UIFont systemFontOfSize:15];
//    self.resultLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
    
    UIButton *runBtn = [UIButton new];
    [self.view addSubview:runBtn];
    [runBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.resultLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(WIDTH - 40);
        make.height.mas_equalTo(35);
    }];
    runBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    runBtn.layer.borderWidth = 0.5;
    runBtn.layer.cornerRadius = 5;
    runBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [runBtn setTitle:@"运行" forState:UIControlStateNormal];
    runBtn.backgroundColor = [UIColor blueColor];
    [runBtn addTarget:self action:@selector(runBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)runBtnClick:(UIButton *)button
{
    self.resultLabel.text = [NSString stringWithFormat:@"   %.2f",arc4random_uniform(50.0) + (self.enterNumber.text.integerValue-50.0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
