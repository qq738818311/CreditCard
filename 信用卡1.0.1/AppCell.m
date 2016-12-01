//
//  AppCell.m
//  Vista看天下
//
//  Created by CPF on 15/6/15.
//  Copyright (c) 2015年 CPF. All rights reserved.
//

#import "AppCell.h"
#import "CPFControl.h"
#import "CustomModel.h"
#import "ViewController.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation AppCell
{
    UITextField *_tempTextField;
    NSString * _is;//什么运算
    NSString * _tempString;//运算时记录值
    BOOL _isPoint;
    NSString * _resultString;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        
        bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"列表底2_1"]];
        bgImageView.userInteractionEnabled=YES;
        [self.contentView addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView).offset(5);
            make.right.bottom.equalTo(self.contentView).offset(-5);
        }];
        
        _titleIconButton = [UIButton new];
        [bgImageView addSubview:_titleIconButton];
        [_titleIconButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(bgImageView).offset(10);
            make.width.height.mas_equalTo(30);
        }];
        
        _titleButton = [UIButton new];
        [_titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_titleButton addTarget:self action:@selector(cardNumberButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgImageView addSubview:_titleButton];
        [_titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleIconButton.mas_right).offset(8);
            make.centerY.equalTo(_titleIconButton);
        }];
        
        UIButton *button = [UIButton new];
        [button setImage:[UIImage imageNamed:@"提示标"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(alertButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgImageView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleButton.mas_right).offset(5);
            make.centerY.equalTo(_titleButton);
            make.width.height.mas_equalTo(18);
        }];
        
        titleLabel=[CPFControl createLabelWithFrame:CGRectMake(WIDTH/2, 10, 56, 30) Text:[NSString stringWithFormat:@"额度:￥"] font:15];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        
        self.edu = [[UITextField alloc] init];
        self.edu.font = [UIFont systemFontOfSize:15];
        self.edu.leftView = titleLabel;
        self.edu.leftViewMode = UITextFieldViewModeUnlessEditing;
        self.edu.borderStyle = UITextBorderStyleNone;
        self.edu.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.contentView addSubview:self.edu];
        [self.edu mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_centerX);
            make.centerY.equalTo(_titleButton);
        }];
        
        UILabel * qiankuanLabel=[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 45, 30)];
        qiankuanLabel.textColor = UIColorFromRGB(0x373535);
        qiankuanLabel.font=[UIFont systemFontOfSize:13];
        qiankuanLabel.textAlignment=NSTextAlignmentCenter;
        qiankuanLabel.attributedText = [ViewController handelWithString:@"欠款:￥" andColor:UIColorFromRGB(0xf94553)];
        self.qiankuan=[[UITextField alloc] init];
        self.qiankuan.font=[UIFont systemFontOfSize:13];
        self.qiankuan.leftView=qiankuanLabel;
        self.qiankuan.leftViewMode=UITextFieldViewModeUnlessEditing;
        self.qiankuan.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.qiankuan.layer.borderWidth = 0.5;
        self.qiankuan.clearButtonMode=UITextFieldViewModeWhileEditing;
//        self.qiankuan.textColor=[UIColor redColor];
        [self.contentView addSubview:self.qiankuan];
        [self.qiankuan mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgImageView).offset(10);
            make.top.equalTo(_titleIconButton.mas_bottom).offset(5);
            make.right.equalTo(bgImageView.mas_centerX).offset(0.25);
            make.height.mas_equalTo(30);
        }];
        
        UILabel * yueLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
        yueLabel.textColor = UIColorFromRGB(0x373535);
        yueLabel.font=[UIFont systemFontOfSize:13];
        yueLabel.textAlignment=NSTextAlignmentCenter;
        yueLabel.attributedText = [ViewController handelWithString:@"余额:￥" andColor:UIColorFromRGB(0x5cf65f)];
        self.yue=[[UITextField alloc] init];
        self.yue.font=[UIFont systemFontOfSize:13];
        self.yue.leftView=yueLabel;
        self.yue.leftViewMode=UITextFieldViewModeUnlessEditing;
        self.yue.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.yue.layer.borderWidth = 0.5;
        self.yue.clearButtonMode=UITextFieldViewModeWhileEditing;
//        self.yue.textColor=[UIColor greenColor];
        [self.contentView addSubview:self.yue];
        [self.yue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgImageView.mas_centerX);
            make.centerY.equalTo(self.qiankuan).offset(-0.25);
            make.right.equalTo(bgImageView).offset(-10);
            make.height.mas_equalTo(30);
        }];
    }
    return self;
}

- (void)alertButtonClick:(UIButton *)button
{
    if (self.showSmsSendExplain) {
        self.showSmsSendExplain();
    }
}

- (void)cardNumberButtonClick:(UIButton *)button
{
    if (self.cardNumberButtonClick) {
        self.cardNumberButtonClick();
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.edu resignFirstResponder];
    [self.qiankuan resignFirstResponder];
    [self.yue resignFirstResponder];
}
- (void)configWithModel:(CustomModel *)model
{
    [_titleButton setTitle:model.bankName forState:UIControlStateNormal];
    [_titleIconButton setImage:[UIImage imageNamed:model.imageName] forState:UIControlStateNormal];
    self.string=model.imageName;
    self.edu.text=model.edu;
    self.yue.text=model.yue;
    self.qiankuan.text=model.qiankuan;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
