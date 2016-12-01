//
//  ViewController.m
//  信用卡1.0
//
//  Created by CPF on 15/9/5.
//  Copyright (c) 2015年 CPF. All rights reserved.
//

#import "ViewController.h"
#import "AppCell.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define UserDefaults [NSUserDefaults standardUserDefaults]

#define KRGB(r,g,b)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate>
{
    UITableView * _tableView;
    
    UITextField * _titleTextField;
    
    UILabel * _yueLabel;//总余额
    UILabel * _qiankuanLabel;//总欠款
    UILabel * _eduLabel;//总额度
    UIView * _titleView;//总计背景图
    UIView * _inputView;
    UITextField * _tempTextField;
    NSString * _tempString;
    NSString * _is;
    BOOL _isContinue;
    
    UIButton * _addButton;
    UIButton * _minusButton;
    UIButton * _multiplyButton;
    UIButton * _divideButton;
}
@property(nonatomic,strong)NSMutableArray * dataSource;
@property(nonatomic,strong)AppCell * cell;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent=NO;
    self.dataSource=[NSMutableArray array];
    [self createDataSource];
    [self createTableView];
    [self createUI];
    [self addNotification];
}
#pragma - mark 准备UI
//准备TableView
-(void)createTableView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64-44) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //设置tableView的线的风格
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:_tableView];
}
//准备数据
-(void)createDataSource
{
    [self.dataSource removeAllObjects];
    
    NSArray * imageNameArray=@[@"gf",@"zg",@"jt",@"zs",@"zx",@"hx"];
    for (int i=0; i<imageNameArray.count; i++) {
        CustomModel * model=[[CustomModel alloc]init];
        model.imageName=imageNameArray[i];
        NSString * yueString=[UserDefaults objectForKey:[NSString stringWithFormat:@"%@yue",imageNameArray[i]]];
        NSString * qiankuanString=[UserDefaults objectForKey:[NSString stringWithFormat:@"%@qiankuan",imageNameArray[i]]];
        NSString * eduString=[UserDefaults objectForKey:[NSString stringWithFormat:@"%@edu",imageNameArray[i]]];
        if (qiankuanString.length>0) {
            model.qiankuan=qiankuanString;
        }else{
            model.qiankuan=@"0.00";
        }
        if (eduString.length>0) {
            model.edu=eduString;
        }else{
            model.edu=@"请先设置额度";
        }
        if (yueString.length>0) {
            model.yue=yueString;
        }else{
            model.yue=@"0.00";
        }
        [self.dataSource addObject:model];
    }
    
    [_tableView reloadData];
}
//准备总计UI和计算器键盘的UI布局
-(void)createUI
{
    self.navigationItem.title=@"★ 信用卡计算器 ★";
    _titleTextField=[[UITextField alloc]init];
    _titleTextField.text=@"★ 信用卡计算器 ★";
    _titleTextField.font=[UIFont boldSystemFontOfSize:20];
    [_titleTextField sizeToFit];
    _titleTextField.borderStyle=UITextBorderStyleNone;
    _titleTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    
    _titleTextField.delegate=self;
    self.navigationItem.titleView=_titleTextField;
    self.navigationController.navigationBar.tintColor=KRGB(68, 201, 235);
    
    _titleView=[[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT-64-44, WIDTH, 44)];
    _titleView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"资讯背景底"]];
    //    _titleView.backgroundColor=[UIColor cyanColor];
    
    UILabel * titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 5, 50, 30)];
    titleLabel.text=@"总计:";
    titleLabel.font=[UIFont boldSystemFontOfSize:20];
    [_titleView addSubview:titleLabel];
    
    _eduLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, WIDTH-80, 22)];
    _eduLabel.font=[UIFont boldSystemFontOfSize:15];
    _eduLabel.text=[NSString stringWithFormat:@" 额度:￥%@ ★",[self loadDataWithIdentifier:@"edu"]];
    _eduLabel.layer.borderWidth=1;
    [_titleView addSubview:_eduLabel];
    
    _qiankuanLabel=[[UILabel alloc]init];
    _qiankuanLabel.font=[UIFont systemFontOfSize:14];
    _qiankuanLabel.textColor=[UIColor redColor];
    _qiankuanLabel.text=[NSString stringWithFormat:@" 欠款:￥%@ ",[self loadDataWithIdentifier:@"qiankuan"]];
    [_qiankuanLabel sizeToFit];
    CGRect qiankuanLabelFrame=_qiankuanLabel.frame;
    _qiankuanLabel.frame=CGRectMake(60, 21, qiankuanLabelFrame.size.width, 22);
    _qiankuanLabel.layer.borderWidth=1;
    [_titleView addSubview:_qiankuanLabel];
    
    _yueLabel=[[UILabel alloc]init];
    _yueLabel.font=[UIFont systemFontOfSize:14];
    _yueLabel.text=[NSString stringWithFormat:@" 余额:￥%.2f ",[self loadDataWithIdentifier:@"edu"].floatValue-[self loadDataWithIdentifier:@"qiankuan"].floatValue];
    [_yueLabel sizeToFit];
    CGRect yueLabelFrame=_yueLabel.frame;
    _yueLabel.frame=CGRectMake(qiankuanLabelFrame.size.width+60-1, 21, yueLabelFrame.size.width, 22);
    _yueLabel.layer.borderWidth=1;
    [_titleView addSubview:_yueLabel];
    
    _eduLabel.frame=CGRectMake(60, 0, qiankuanLabelFrame.size.width+yueLabelFrame.size.width-1, 22);
    
    //    self.navigationItem.titleView=_titleView;
    [self.view addSubview:_titleView];
    
    //自定义计算器键盘
    _inputView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 280)];
    _inputView.backgroundColor=[UIColor blackColor];
    //布局计算器按钮
    for (int i=0; i<19; i++) {
        UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i]] forState:UIControlStateNormal];
        CGRect frame;
        if (i==7) {
            frame=CGRectMake(WIDTH/4*3, 40, WIDTH/4-0.5, 120-1);
        }else if (i==11){
            button.hidden=YES;
        }else if (i==15){
            frame=CGRectMake(WIDTH/4*3, 160, WIDTH/4-0.5, 120-1);
        }else if (i<4){
            frame=CGRectMake(WIDTH/4*(i%4), 0, WIDTH/4-0.5, 40-0.5);
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"2%d",i]] forState:UIControlStateSelected];
        }else{
            int temp;
            if (i<8) {
                temp=40;
            }else if (i<12){
                temp=100;
            }else if (i<16){
                temp=160;
            }else{
                temp=220;
            }
            frame=CGRectMake(WIDTH/4*(i%4), temp, WIDTH/4-0.5, 60-0.5);
        }
        button.frame=frame;
        button.tag=1000+i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_inputView addSubview:button];
    }
    _addButton=(UIButton *)[_inputView viewWithTag:1000];
    _minusButton=(UIButton *)[_inputView viewWithTag:1001];
    _multiplyButton=(UIButton *)[_inputView viewWithTag:1002];
    _divideButton=(UIButton *)[_inputView viewWithTag:1003];
    
    _titleTextField.inputView=_inputView;
}
-(void)deleteButtonClick
{
    NSLog(@"删除键");
    NSInteger index;
    if (_tempTextField.text.length>0) {
        index=_tempTextField.text.length-1;
    }else{
        index=0;
    }
    _tempTextField.text=[_tempTextField.text substringToIndex:index];
    if ([_tempTextField.text isEqualToString:@""]) {
        _is=nil;
    }
    [self operationButtonUnSelected];
}
//计算器键盘逻辑(触发方法)
-(void)buttonClick:(UIButton *)button
{
    switch (button.tag-1000) {
        case 0://+
        {//加
            if (button.selected) {
                break;
            }
            if (!_isContinue) {
                _is=nil;
            }
            _addButton.selected=YES;
            _minusButton.selected=NO;
            _multiplyButton.selected=NO;
            _divideButton.selected=NO;
            
            _isContinue=NO;
            if (_is) {
                [self operationResult];
                _tempString=_tempTextField.text;
            }else{
                _tempString=_tempTextField.text;
            }
            _is=@"+";
        }
            break;
        case 1://-
        {//减
            if (button.selected) {
                break;
            }
            if (!_isContinue) {
                _is=nil;
            }
            _addButton.selected=NO;
            _minusButton.selected=YES;
            _multiplyButton.selected=NO;
            _divideButton.selected=NO;
            
            _isContinue=NO;
            if (_is) {
                [self operationResult];
                _tempString=_tempTextField.text;
            }else{
                _tempString=_tempTextField.text;
            }
            _is=@"-";
        }
            break;
        case 2://*
        {//乘
            if (button.selected) {
                break;
            }
            if (!_isContinue) {
                _is=nil;
            }
            _addButton.selected=NO;
            _minusButton.selected=NO;
            _multiplyButton.selected=YES;
            _divideButton.selected=NO;
            
            _isContinue=NO;
            if (_is) {
                [self operationResult];
                _tempString=_tempTextField.text;
            }else{
                _tempString=_tempTextField.text;
            }
            _is=@"*";
        }
            break;
        case 3://除
        {//除
            if (button.selected) {
                break;
            }
            if (!_isContinue) {
                _is=nil;
            }
            _addButton.selected=NO;
            _minusButton.selected=NO;
            _multiplyButton.selected=NO;
            _divideButton.selected=YES;
            
            _isContinue=NO;
            if (_is) {
                [self operationResult];
                _tempString=_tempTextField.text;
            }else{
                _tempString=_tempTextField.text;
            }
            _is=@"/";
        }
            break;
        case 4://1
        {// 1
            if ([self isFloat:_tempTextField.text]) {
                if (_is&&!_isContinue) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"1"];
            }else{
                if (_tempTextField.text.floatValue==0||(_is&&!_isContinue)) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"1"];
            }
            [self operationButtonUnSelected];
        }
            break;
        case 5://2
        {// 2
            if ([self isFloat:_tempTextField.text]) {
                if (_is&&!_isContinue) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"2"];
            }else{
                if (_tempTextField.text.floatValue==0||(_is&&!_isContinue)) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"2"];
            }
            [self operationButtonUnSelected];
        }
            break;
        case 6://3
        {// 3
            if ([self isFloat:_tempTextField.text]) {
                if (_is&&!_isContinue) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"3"];
            }else{
                if (_tempTextField.text.floatValue==0||(_is&&!_isContinue)) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"3"];
            }
            [self operationButtonUnSelected];
        }
            break;
        case 7://C
        {//删除
            NSInteger index;
            if (_tempTextField.text.length>0) {
                index=_tempTextField.text.length-1;
            }else{
                index=0;
            }
            _tempTextField.text=[_tempTextField.text substringToIndex:index];
            if ([_tempTextField.text isEqualToString:@""]) {
                _is=nil;
            }
            [self operationButtonUnSelected];
        }
            break;
        case 8://4
        {// 4
            if ([self isFloat:_tempTextField.text]) {
                if (_is&&!_isContinue) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"4"];
            }else{
                if (_tempTextField.text.floatValue==0||(_is&&!_isContinue)) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"4"];
            }
            [self operationButtonUnSelected];
        }
            break;
        case 9://5
        {// 5
            if ([self isFloat:_tempTextField.text]) {
                if (_is&&!_isContinue) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"5"];
            }else{
                if (_tempTextField.text.floatValue==0||(_is&&!_isContinue)) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"5"];
            }
            [self operationButtonUnSelected];
        }
            break;
        case 10://6
        {// 6
            if ([self isFloat:_tempTextField.text]) {
                if (_is&&!_isContinue) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"6"];
            }else{
                if (_tempTextField.text.floatValue==0||(_is&&!_isContinue)) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"6"];
            }
            [self operationButtonUnSelected];
        }
            break;
        case 11://没有
        {
            
        }
            break;
        case 12://7
        {// 7
            if ([self isFloat:_tempTextField.text]) {
                if (_is&&!_isContinue) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"7"];
            }else{
                if (_tempTextField.text.floatValue==0||(_is&&!_isContinue)) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"7"];
            }
            [self operationButtonUnSelected];
        }
            break;
        case 13://8
        {// 8
            if ([self isFloat:_tempTextField.text]) {
                if (_is&&!_isContinue) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"8"];
            }else{
                if (_tempTextField.text.floatValue==0||(_is&&!_isContinue)) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"8"];
            }
            [self operationButtonUnSelected];
        }
            break;
        case 14://9
        {// 9
            if ([self isFloat:_tempTextField.text]) {
                if (_is&&!_isContinue) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"9"];
            }else{
                if (_tempTextField.text.floatValue==0||(_is&&!_isContinue)) {
                    _tempTextField.text=@"";
                    _isContinue=YES;
                }
                _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"9"];
            }
            [self operationButtonUnSelected];
        }
            break;
        case 15://=
        {// =
            if ([_is isEqualToString:@"*"]) {
                _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempString.floatValue*_tempTextField.text.floatValue]];
            }else if ([_is isEqualToString:@"/"]){
                _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempString.floatValue/_tempTextField.text.floatValue]];
            }else if ([_is isEqualToString:@"+"]){
                _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempString.floatValue+_tempTextField.text.floatValue]];
            }else if ([_is isEqualToString:@"-"]){
                _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempString.floatValue-_tempTextField.text.floatValue]];;
            }
            _is=nil;
            [self operationButtonUnSelected];
            //            [_tempTextField resignFirstResponder];
        }
            break;
        case 16://.
        {// .
            if (_tempTextField.text.floatValue==0) {
                _tempTextField.text=@"0.";
            }else{
                if (![self isFloat:_tempTextField.text]) {
                    _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"."];
                }
            }
            [self operationButtonUnSelected];
        }
            break;
        case 17://0
        {// 0
            if ([_tempTextField.text isEqualToString:@"0"]||[_tempTextField.text isEqualToString:@""]) {
                _tempTextField.text=@"0";
            }else{
                if (_tempTextField.text.floatValue==0) {
                    if ([self isFloat:_tempTextField.text]) {
                        if (_is&&!_isContinue) {
                            _tempTextField.text=@"";
                            _isContinue=YES;
                        }
                        _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"0"];
                    }else{
                        _tempTextField.text=@"0";
                    }
                }else{
                    if (_is&&!_isContinue) {
                        _tempTextField.text=@"";
                        _isContinue=YES;
                    }
                    _tempTextField.text=[NSString stringWithFormat:@"%@%@",_tempTextField.text,@"0"];
                }
            }
            [self operationButtonUnSelected];
        }
            break;
        case 18://回键
        {
            [self operationButtonUnSelected];
            [_tempTextField resignFirstResponder];
        }
            break;
            
        default:
            break;
    }
}
#pragma - mark 便捷工具方法
//将TextField的text小数后面的0去掉
-(NSString *)formatString:(NSString *)string
{
    if ([self isFloat:string]&&([[string substringFromIndex:string.length-1] isEqualToString:@"0"]||[[string substringFromIndex:string.length-1] isEqualToString:@"."])) {
        return [self formatString:[string substringToIndex:string.length-1]];
    }else{
        return string;
    }
}
//运算结果
-(void)operationResult
{
    if ([_is isEqualToString:@"*"]) {
        _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempString.floatValue*_tempTextField.text.floatValue]];
    }else if ([_is isEqualToString:@"/"]){
        _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempString.floatValue/_tempTextField.text.floatValue]];
    }else if ([_is isEqualToString:@"+"]){
        _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempString.floatValue+_tempTextField.text.floatValue]];
    }else if ([_is isEqualToString:@"-"]){
        _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempString.floatValue-_tempTextField.text.floatValue]];;
    }
}
//将运算符号置为未选择状态
-(void)operationButtonUnSelected
{
    _addButton.selected=NO;
    _minusButton.selected=NO;
    _multiplyButton.selected=NO;
    _divideButton.selected=NO;
}
//判断是否是小数
-(BOOL)isFloat:(NSString *)string
{
    NSString * tempStr;
    for (int i=0; i<string.length; i++) {
        NSString * charStr=[NSString stringWithFormat:@"%c",[string characterAtIndex:i]];
        if ([charStr isEqualToString:@"."]) {
            tempStr=@"yes";
        }
    }
    if ([tempStr isEqualToString:@"yes"]||[_tempTextField.text isEqualToString:@"0."]||[_tempTextField.text isEqualToString:@"0.0"]||[_tempTextField.text isEqualToString:@"0.00"]||[_tempTextField.text isEqualToString:@"0.000"]||[_tempTextField.text isEqualToString:@"0.0000"]) {
        return YES;
    }else{
        return NO;
    }
}
//从UserDefaults里面获取总和
-(NSString *)loadDataWithIdentifier:(NSString *)identifier
{
    float all=0;
    for (int i=0; i<self.dataSource.count; i++) {
        CustomModel * model=self.dataSource[i];
        all+=[[UserDefaults valueForKey:[NSString stringWithFormat:@"%@%@",model.imageName,identifier]] floatValue];
    }
    NSString * string=[[NSString alloc]init];
    if ([identifier isEqualToString:@"edu"]) {
        string=[NSString stringWithFormat:@"%.0f",all];
    }else{
        string=[NSString stringWithFormat:@"%.2f",all];
    }
    return string;
}
#pragma - mark 通知相关
//注册通知
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueChange) name:@"ValueChange" object:nil];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if (_tempTextField.text.floatValue==0) {
        _tempTextField.text=@"0";
    }
    
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float height = keyboardRect.size.height;
    CGRect frame=_tableView.frame;
    if (frame.size.height==HEIGHT-height-64-2) {
        return;
    }
    frame.size.height=HEIGHT-height-64-2;
    _tableView.frame=frame;
    _titleView.hidden=YES;
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    //将运算符号置空
    _is=nil;
    
    CGRect frame=_tableView.frame;
    frame.size.height=HEIGHT-64-44;
    _tableView.frame=frame;
    _titleView.hidden=NO;
}
//输入结束通知触发方法
-(void)valueChange
{
    //刷新数据
    [self createDataSource];
    NSLog(@"valueChange刷新数据");
    
    //    NSLog(@"edu==%@",[self loadDataWithIdentifier:@"edu"]);
    _eduLabel.text=[NSString stringWithFormat:@" 额度:￥%@ ★",[self loadDataWithIdentifier:@"edu"]];
    
    _qiankuanLabel.text=[NSString stringWithFormat:@" 欠款:￥%@ ",[self loadDataWithIdentifier:@"qiankuan"]];
    [_qiankuanLabel sizeToFit];
    CGRect qiankuanLabelFrame=_qiankuanLabel.frame;
    _qiankuanLabel.frame=CGRectMake(60, 21, qiankuanLabelFrame.size.width, 22);
    _qiankuanLabel.layer.borderWidth=1;
    
    _yueLabel.text=[NSString stringWithFormat:@" 余额:￥%.2f ",[self loadDataWithIdentifier:@"edu"].floatValue-[self loadDataWithIdentifier:@"qiankuan"].floatValue];
    [_yueLabel sizeToFit];
    CGRect yueLabelFrame=_yueLabel.frame;
    _yueLabel.frame=CGRectMake(qiankuanLabelFrame.size.width+60-1, 21, yueLabelFrame.size.width, 22);
    _yueLabel.layer.borderWidth=1;
    
    _eduLabel.frame=CGRectMake(60, 0, qiankuanLabelFrame.size.width+yueLabelFrame.size.width-1, 22);
}
#pragma - mark UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self.cell.edu resignFirstResponder];
//    [self.cell.qiankuan resignFirstResponder];
//    [self.cell.yue resignFirstResponder];
//    [_titleTextField resignFirstResponder];
    [_tempTextField resignFirstResponder];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollView.contentOffSet==%.f",scrollView.contentOffset.y);
}
#pragma - mark UITextFeild代理方法
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"开始输入,%@",textField.text);
    if (textField==_titleTextField) {
        _titleTextField.frame=CGRectMake(0, 0, WIDTH/2, 40);
        _titleTextField.clearButtonMode=UITextFieldViewModeAlways;
        _titleTextField.layer.borderWidth=1.5;
        /*
         UITextFieldViewModeNever,
         UITextFieldViewModeWhileEditing,
         UITextFieldViewModeUnlessEditing,
         UITextFieldViewModeAlways
         */
        _titleTextField.leftView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 40)];
        _titleTextField.leftViewMode=UITextFieldViewModeAlways;
        _titleTextField.rightView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 40)];
        _titleTextField.rightViewMode=UITextFieldViewModeAlways;
    }else{
        self.cell=(AppCell *)textField.superview.superview;
        self.cell.edu.inputView=_inputView;
        self.cell.qiankuan.inputView=_inputView;
        self.cell.yue.inputView=_inputView;
    }
    
    _tempTextField=textField;
    
    if (_tempTextField.text.floatValue==0) {
        _tempTextField.text=@"0";
    }
    [self operationButtonUnSelected];
    _is=nil;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.cell.yue) {
        self.cell.qiankuan.text=[NSString stringWithFormat:@"%.2f",self.cell.edu.text.floatValue-self.cell.yue.text.floatValue];
        self.cell.yue.text=[NSString stringWithFormat:@"%.2f",self.cell.yue.text.floatValue];
    }else if (textField==self.cell.qiankuan){
        self.cell.yue.text=[NSString stringWithFormat:@"%.2f",self.cell.edu.text.floatValue-self.cell.qiankuan.text.floatValue];
        self.cell.qiankuan.text=[NSString stringWithFormat:@"%.2f",self.cell.qiankuan.text.floatValue];
    }else if (textField==self.cell.edu){
        self.cell.qiankuan.text=[NSString stringWithFormat:@"%.2f",self.cell.edu.text.floatValue-self.cell.yue.text.floatValue];
        self.cell.yue.text=[NSString stringWithFormat:@"%.2f",self.cell.yue.text.floatValue];
    }else if (textField==_titleTextField){
        _titleTextField.text=@"★ 信用卡计算器 ★";
        [_titleTextField sizeToFit];
        _titleTextField.layer.borderWidth=0;
    }
//    self.cell.edu.font=[UIFont systemFontOfSize:15];
    
    [UserDefaults setObject:self.cell.edu.text forKey:[NSString stringWithFormat:@"%@edu",self.cell.string]];
    [UserDefaults setObject:self.cell.yue.text forKey:[NSString stringWithFormat:@"%@yue",self.cell.string]];
    [UserDefaults setObject:self.cell.qiankuan.text forKey:[NSString stringWithFormat:@"%@qiankuan",self.cell.string]];
    [UserDefaults synchronize];
    //输入结束发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ValueChange" object:nil];
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==self.cell.yue) {
        self.cell.qiankuan.text=[NSString stringWithFormat:@"%.2f",self.cell.edu.text.floatValue-self.cell.yue.text.floatValue];
    }else if (textField==self.cell.qiankuan){
        self.cell.yue.text=[NSString stringWithFormat:@"%.2f",self.cell.edu.text.floatValue-self.cell.qiankuan.text.floatValue];
    }
    return YES;
}
#pragma - mark TableView的代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppCell * cell=[tableView dequeueReusableCellWithIdentifier:@"a"];
    if (!cell) {
        cell=[[AppCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"a"];
    }
    CustomModel * model=self.dataSource[indexPath.row];
    [cell configWithModel:model];
    cell.edu.delegate=self;
    cell.qiankuan.delegate=self;
    cell.yue.delegate=self;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
