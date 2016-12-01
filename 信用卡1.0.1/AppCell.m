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

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        user=[NSUserDefaults standardUserDefaults];
        UIImageView * imgageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 95)];
        imageView.userInteractionEnabled=YES;
        imgageView.image=[UIImage imageNamed:@"资讯背景底"];
        [self.contentView addSubview:imgageView];
        bgImageView=[CPFControl createImageViewWithFrame:CGRectMake(5, 5, WIDTH-10, 85) ImageName:@"列表底2_1"];
        bgImageView.userInteractionEnabled=YES;
        [imgageView addSubview:bgImageView];
        
        imageView=[CPFControl createImageViewWithFrame:CGRectMake(10, 10, WIDTH/2-15, 30) ImageName:nil];
        imageView.layer.masksToBounds=YES;
        imageView.layer.cornerRadius=5;
        [bgImageView addSubview:imageView];
        titleLabel=[CPFControl createLabelWithFrame:CGRectMake(WIDTH/2, 10, 56, 30) Text:[NSString stringWithFormat:@"额度:￥"] font:15];
        titleLabel.font=[UIFont boldSystemFontOfSize:15];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [bgImageView addSubview:titleLabel];
        self.edu=[[UITextField alloc]initWithFrame:CGRectMake(WIDTH/2+5, 15, WIDTH/2-15, 30)];
        self.edu.font=[UIFont boldSystemFontOfSize:14];
        self.edu.leftView=titleLabel;
        self.edu.leftViewMode=UITextFieldViewModeUnlessEditing;
        self.edu.borderStyle=UITextBorderStyleNone;
        self.edu.clearButtonMode=UITextFieldViewModeWhileEditing;
//        self.edu.keyboardType=UIKeyboardTypeDecimalPad;
//        self.edu.delegate=self;
        [self.contentView addSubview:self.edu];
        
        self.qiankuan=[[UITextField alloc]initWithFrame:CGRectMake(15, 50, WIDTH/2-15, 30)];
        UILabel * qiankuanLabel=[CPFControl createLabelWithFrame:CGRectMake(5, 0, 45, 30) Text:@"欠款:￥" font:15];
        qiankuanLabel.font=[UIFont boldSystemFontOfSize:13];
        qiankuanLabel.textAlignment=NSTextAlignmentCenter;
        self.qiankuan.font=[UIFont boldSystemFontOfSize:14];
        self.qiankuan.leftView=qiankuanLabel;
        self.qiankuan.leftViewMode=UITextFieldViewModeUnlessEditing;
        self.qiankuan.borderStyle=UITextBorderStyleBezel;
        self.qiankuan.clearButtonMode=UITextFieldViewModeWhileEditing;
//        self.qiankuan.keyboardType=UIKeyboardTypeDecimalPad;
        self.qiankuan.textColor=[UIColor redColor];
//        self.qiankuan.delegate=self;
        [self.contentView addSubview:self.qiankuan];
        self.yue=[[UITextField alloc]initWithFrame:CGRectMake(WIDTH/2-1, 50, WIDTH/2-15, 30)];
        UILabel * yueLabel=[CPFControl createLabelWithFrame:CGRectMake(0, 0, 45, 30) Text:@"余额:￥" font:15];
        yueLabel.font=[UIFont boldSystemFontOfSize:13];
        yueLabel.textAlignment=NSTextAlignmentCenter;
        self.yue.font=[UIFont boldSystemFontOfSize:14];
        self.yue.leftView=yueLabel;
        self.yue.leftViewMode=UITextFieldViewModeUnlessEditing;
        self.yue.borderStyle=UITextBorderStyleBezel;
        self.yue.clearButtonMode=UITextFieldViewModeWhileEditing;
//        self.yue.keyboardType=UIKeyboardTypeDecimalPad;
        self.yue.textColor=[UIColor greenColor];
//        self.yue.delegate=self;
        [self.contentView addSubview:self.yue];
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.edu resignFirstResponder];
    [self.qiankuan resignFirstResponder];
    [self.yue resignFirstResponder];
}
-(void)configWithModel:(CustomModel *)model
{
    imageView.image=[UIImage imageNamed:model.imageName];
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
