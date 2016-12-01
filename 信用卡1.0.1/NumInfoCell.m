//
//  NumInfoCell.m
//  信用卡1.0.1
//
//  Created by 曹鹏飞 on 16/2/18.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "NumInfoCell.h"

@implementation NumInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    /** 第一行卡号 */
    _cardLabel = [UILabel new];
    _cardLabel.text = @"卡号1:";
    _cardLabel.font = [UIFont systemFontOfSize:16];
    _cardLabel.textColor = RGBACOLOR(130, 130, 130, 1);
    [self.contentView addSubview:_cardLabel];
    [_cardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.centerY.equalTo(self.contentView);
    }];
    [_cardLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _cardNumber = [UITextField new];
    _cardNumber.placeholder = @"请先设置卡号";
    _cardNumber.font = [UIFont systemFontOfSize:16];
    _cardNumber.keyboardType = UIKeyboardTypeDecimalPad;
    _cardNumber.delegate = self;
    _cardNumber.userInteractionEnabled = NO;
    [self.contentView addSubview:_cardNumber];
    [_cardNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_cardLabel);
        make.left.equalTo(_cardLabel.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-20);
    }];
    
    _cardNumberLine = [UILabel new];
    _cardNumberLine.backgroundColor = UIColorFromRGB(0xafaeae);
    [self.contentView addSubview:_cardNumberLine];
    [_cardNumberLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_cardLabel.mas_right);
        make.right.equalTo(_cardNumber);
        make.bottom.equalTo(_cardNumber).offset(4);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *line2 = [UILabel new];
    line2.backgroundColor = UIColorFromRGB(0xcecece);
    [self.contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_cardLabel);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.textFieldDidBeginEditing) {
        self.textFieldDidBeginEditing(textField);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.textFieldDidEndEditing) {
        self.textFieldDidEndEditing(textField);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.shouldChangeCharactersInRange) {
        return self.shouldChangeCharactersInRange(textField, range, string);
    } else {
        return NO;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
