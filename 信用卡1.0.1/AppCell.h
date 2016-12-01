//
//  AppCell.h
//  Vista看天下
//
//  Created by CPF on 15/6/15.
//  Copyright (c) 2015年 CPF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomModel.h"
@interface AppCell : UITableViewCell<UITextFieldDelegate>
{
    UIImageView * bgImageView;
    UIImageView * imageView;
    UILabel * titleLabel;
    NSUserDefaults * user;

}
@property(nonatomic,copy)NSString * string;
@property(nonatomic,strong)UITextField * edu;
@property(nonatomic,strong)UITextField * qiankuan;
@property(nonatomic,strong)UITextField * yue;
//@property(nonatomic,assign)UITextField * qiankuan;
//@property(nonatomic,assign)UITextField * yue;
-(void)configWithModel:(CustomModel *)model;
@end
