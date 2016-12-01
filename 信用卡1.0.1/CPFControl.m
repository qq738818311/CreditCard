//
//  CPFControl.m
//  FreeLimitProject
//
//  Created by CPF on 15/6/8.
//  Copyright (c) 2015年 CPF. All rights reserved.
//

#import "CPFControl.h"

@implementation CPFControl
//创建View
+(UIView *)createViewWithFrame:(CGRect)frame
{
    UIView * view=[[UIView alloc]initWithFrame:frame];
    return view;
}
//创建Label
+(UILabel *)createLabelWithFrame:(CGRect)frame Text:(NSString *)text font:(CGFloat)font
{
    UILabel * label=[[UILabel alloc]initWithFrame:frame];
    label.text=text;
    label.font=[UIFont systemFontOfSize:font];
    return label;
}
//创建Button
+(UIButton *)createButtonWithFrame:(CGRect)frame Text:(NSString *)text ImageName:(NSString *)imageName bgImageName:(NSString *)bgImageName Target:(id)target method:(SEL)Method
{
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=frame;
    if (imageName) {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (bgImageName) {
        [button setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
    }
    [button addTarget:target action:Method forControlEvents:UIControlEventTouchUpInside];
    if (text) {
        [button setTitle:text forState:UIControlStateNormal];
    }
    return button;
}
//创建ImageView
+(UIImageView *)createImageViewWithFrame:(CGRect)frame ImageName:(NSString *)imageName
{
    UIImageView * imageView=[[UIImageView alloc]initWithFrame:frame];
    imageView.image=[UIImage imageNamed:imageName];
    imageView.userInteractionEnabled=YES;
    return imageView;
}

@end
