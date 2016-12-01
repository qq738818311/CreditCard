//
//  CPFControl.h
//  FreeLimitProject
//
//  Created by CPF on 15/6/8.
//  Copyright (c) 2015年 CPF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CPFControl : NSObject
//创建View
+(UIView *)createViewWithFrame:(CGRect)frame;
//创建Label
+(UILabel *)createLabelWithFrame:(CGRect)frame Text:(NSString *)text font:(CGFloat)font;
//创建Button
+(UIButton *)createButtonWithFrame:(CGRect)frame Text:(NSString *)text ImageName:(NSString *)imageName bgImageName:(NSString *)bgImageName Target:(id)target method:(SEL)Method;
//创建ImageView
+(UIImageView *)createImageViewWithFrame:(CGRect)frame ImageName:(NSString *)imageName;
//textField
@end
