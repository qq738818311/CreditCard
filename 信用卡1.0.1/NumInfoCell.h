//
//  NumInfoCell.h
//  信用卡1.0.1
//
//  Created by 曹鹏飞 on 16/2/18.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumInfoCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, strong) UILabel * cardLabel;
@property (nonatomic, strong) UITextField *cardNumber;
@property (nonatomic, strong) UILabel *cardNumberLine;

@property (nonatomic, copy) void (^textFieldDidBeginEditing)(UITextField *textField);
@property (nonatomic, copy) void (^textFieldDidEndEditing)(UITextField *textField);
@property (nonatomic, copy) BOOL (^shouldChangeCharactersInRange)(UITextField *textField, NSRange range, NSString *string);

@end
