//
//  ViewController.m
//  信用卡1.0
//
//  Created by CPF on 15/9/5.
//  Copyright (c) 2015年 CPF. All rights reserved.
//

#import "ViewController.h"
#import "AppCell.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "NumInfoCell.h"
#import <MessageUI/MessageUI.h>
#import "ARC4ViewController.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define UserDefaults [NSUserDefaults standardUserDefaults]

#define KRGB(r,g,b)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
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
    NSString * _tempOperation;
    BOOL _isOperationResult;
    BOOL _isDeleteOperator;//是否删除运算符号
    
    
    UIButton * _addButton;
    UIButton * _minusButton;
    UIButton * _multiplyButton;
    UIButton * _divideButton;
    
    CGFloat _tempContentOffSetY;
    BOOL _isScorll1;
    BOOL _isScorll2;
    
    int _numInfoCount;
    int _tempLoc;
    BOOL _isNeedSave;
}
@property(nonatomic,strong)NSMutableArray * dataSource;
@property(nonatomic,strong)AppCell * cell;

@property (nonatomic, strong) UIView *numberInfoView;
@property (nonatomic, strong) UILabel *bankNameLabel;
@property (nonatomic, strong) UIButton *numInfoEditBtn;
@property (nonatomic, strong) UILabel *editStatus;
@property (nonatomic, strong) UITableView *numInfoTableView;
@property (nonatomic, strong) UITextField *numInfoTextField;
@property (nonatomic, strong) NumInfoCell *numInfoCell;
@property (nonatomic, strong) NSMutableArray *numInfoDataSource;
@property (nonatomic, strong) UIView *footerBgView;
@property (nonatomic, strong) UILabel *explainLabel;
@property (nonatomic, strong) UIButton *numInfoSendSmsBtn;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIButton *closePickerViewBtn;
@property (nonatomic, strong) UIView *pickerViewBg;
@property (nonatomic, strong) UILabel *pickerExplainLabel;
@property (nonatomic, strong) NSString *pickerCardLast;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@,%@",[NSBundle mainBundle],NSHomeDirectory());
    
    self.navigationController.navigationBar.translucent = NO;
    self.dataSource=[NSMutableArray array];
    self.numInfoDataSource = [NSMutableArray array];
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"资讯背景底"]];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ARC4" style:UIBarButtonItemStylePlain target:self action:@selector(arc4BarButtonItemClick)];
    
    [self createDataSource];
    [self createTableView];
    [self createUI];
    [self addNotification];
    _isScorll1 = NO;
    _isScorll2 = YES;
    _tempContentOffSetY = 0;
    _numInfoTextField = [UITextField new];
    _numInfoTextField.delegate = self;
    _tempLoc = 0;
    
//    [self.navigationController pushViewController:[ARC4ViewController new] animated:YES];
}

#pragma mark - 准备UI
//准备TableView
-(void)createTableView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //设置tableView的线的风格
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
}

//准备数据
- (void)createDataSource
{
    [self.dataSource removeAllObjects];
    
    NSArray * bankNameArray=@[@"广发银行",@"交通银行",@"招商银行",@"中信银行",@"华夏银行",@"光大银行",@"民生银行",@"蚂蚁借呗",@"微粒贷",@"京东金条",@"兴业银行",];
    
    for (int i=0; i<bankNameArray.count; i++) {
        CustomModel * model=[[CustomModel alloc]init];
        model.bankName = bankNameArray[i];
        NSString *imageName = [self getChineseFirstAndSecondLetter:model.bankName];
        model.imageName = imageName;
        NSString * yueString = [ToolClass objectForKey:[NSString stringWithFormat:@"%@yue",imageName]];
        NSString * qiankuanString = [ToolClass objectForKey:[NSString stringWithFormat:@"%@qiankuan",imageName]];
        NSString * eduString = [ToolClass objectForKey:[NSString stringWithFormat:@"%@edu",imageName]];
        if (qiankuanString.length > 0 && qiankuanString.floatValue != 0) {
            model.qiankuan=qiankuanString;
        }else{
            model.qiankuan=@"0.00";
        }
        if (eduString.length > 0 && eduString.floatValue != 0) {
            model.edu=eduString;
        }else{
            model.edu=@"请先设置额度";
        }
        if (yueString.length > 0 && yueString.floatValue != 0) {
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
    
    /** 总计背景控件 */
    _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT-64-55, WIDTH, 55)];
    _titleView.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.7);

    UILabel * titleLabel=[[UILabel alloc] init];
    titleLabel.text=@"总计:";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:20];
    [_titleView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_titleView);
        make.left.equalTo(_titleView).offset(5);
    }];
//    [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    UIView *tempView = [UIView new];
    [_titleView addSubview:tempView];
    
    _eduLabel=[[UILabel alloc] init];
    _eduLabel.font=[UIFont boldSystemFontOfSize:15];
    _eduLabel.textColor = [UIColor whiteColor];
    _eduLabel.text = [NSString stringWithFormat:@" 额度:￥%@ ★",[self loadDataWithIdentifier:@"edu"]];
    _eduLabel.layer.borderWidth = 0.5;
    _eduLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    [tempView addSubview:_eduLabel];
    
    _qiankuanLabel=[[UILabel alloc]init];
    _qiankuanLabel.font=[UIFont systemFontOfSize:14];
    _qiankuanLabel.textColor=[UIColor redColor];
    _qiankuanLabel.text=[NSString stringWithFormat:@" 欠款:￥%@ ",[self loadDataWithIdentifier:@"qiankuan"]];
    _qiankuanLabel.layer.borderWidth = 0.5;
    _qiankuanLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    [tempView addSubview:_qiankuanLabel];
    [_qiankuanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tempView);
        make.top.equalTo(_eduLabel.mas_bottom).offset(-0.5);
        make.height.mas_equalTo(23);
    }];
    
    _yueLabel=[[UILabel alloc]init];
    _yueLabel.font=[UIFont systemFontOfSize:14];
    _yueLabel.textColor = [UIColor whiteColor];
    _yueLabel.text=[NSString stringWithFormat:@" 余额:￥%.2f ",[self loadDataWithIdentifier:@"edu"].floatValue-[self loadDataWithIdentifier:@"qiankuan"].floatValue];
    _yueLabel.layer.borderWidth = 0.5;
    _yueLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    [tempView addSubview:_yueLabel];
    [_yueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_qiankuanLabel.mas_right).offset(-0.5);
        make.top.equalTo(_eduLabel.mas_bottom).offset(-0.5);
        make.height.mas_equalTo(23);
    }];
    
    [_eduLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(tempView);
        make.right.equalTo(_yueLabel);
        make.height.mas_equalTo(23);
    }];
    
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_titleView);
        make.left.equalTo(titleLabel.mas_right).offset(10);
        make.top.equalTo(_eduLabel);
        make.bottom.equalTo(_qiankuanLabel);
        make.right.equalTo(_yueLabel);
    }];
    
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
    
    _numberInfoView = [UIView new];
    [self.view addSubview:_numberInfoView];
    _numberInfoView.backgroundColor = UIColorFromRGBWithAlpha(0xffffff, 1);
    _numberInfoView.hidden = YES;
    [_numberInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(10);
        make.right.bottom.equalTo(self.view).offset(-10);
    }];
    [self.view layoutIfNeeded];
    _numberInfoView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    _numberInfoView.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    _numberInfoView.layer.shadowOpacity = 0.7;//阴影透明度，默认0
    _numberInfoView.layer.shadowRadius = 4;//阴影半径，默认3
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    float width = _numberInfoView.bounds.size.width;
    float height = _numberInfoView.bounds.size.height;
    float x = _numberInfoView.bounds.origin.x;
    float y = _numberInfoView.bounds.origin.y;
    float addWH = 0;
    float test = 61;
    float add = 2;
    CGPoint topLeft = CGPointMake(x - add, y - add);//左上角
    CGPoint topMiddle = CGPointMake(x+(width/2),y-addWH - add);//上面的中间
    CGPoint topRight = CGPointMake(x+width + add,y - add);//右上角
    CGPoint rightMiddle = CGPointMake(x+width+addWH + add,y+(height/2));
    CGPoint bottomRight = CGPointMake(x+width + add,y+height - test);
    CGPoint bottomMiddle = CGPointMake(x+(width/2),y+height+addWH - test);
    CGPoint bottomLeft = CGPointMake(x - add,y+height - test);
    CGPoint leftMiddle = CGPointMake(x-addWH - add,y+(height/2));
    [path moveToPoint:topLeft];
    //添加四个二元曲线
    [path addQuadCurveToPoint:topRight controlPoint:topMiddle];
    [path addQuadCurveToPoint:bottomRight controlPoint:rightMiddle];
    [path addQuadCurveToPoint:bottomLeft controlPoint:bottomMiddle];
    [path addQuadCurveToPoint:topLeft controlPoint:leftMiddle];
    //设置阴影路径
    _numberInfoView.layer.shadowPath = path.CGPath;
    
//    UITapGestureRecognizer *hideGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBtnClick:)];
//    [_numberInfoView addGestureRecognizer:hideGesture];
    
    /** 关闭按钮 */
    UIButton *closeBtn = [UIButton new];
    [_numberInfoView addSubview:closeBtn];
    [closeBtn setImage:[UIImage imageNamed:@"btn_cancleForImageCheck"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(_numberInfoView).offset(10);
        make.width.height.mas_equalTo(29);
    }];
    
    /** 银行名称 */
    _bankNameLabel = [UILabel new];
    [_numberInfoView addSubview:_bankNameLabel];
    [_bankNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_numberInfoView);
        make.top.equalTo(_numberInfoView).offset(15);
    }];
    _bankNameLabel.textAlignment = NSTextAlignmentCenter;
    _bankNameLabel.font = [UIFont systemFontOfSize:20];
    
    /** 编辑按钮 */
    _numInfoEditBtn = [UIButton new];
    [_numberInfoView addSubview:_numInfoEditBtn];
    [_numInfoEditBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_numberInfoView).offset(10);
        make.right.equalTo(_numberInfoView).offset(-10);
    }];
    [_numInfoEditBtn setImage:[UIImage imageNamed:@"btn_edit"] forState:UIControlStateNormal];
    [_numInfoEditBtn setImage:[UIImage imageNamed:@"btn_edit_finish"] forState:UIControlStateSelected];
    [_numInfoEditBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *numInfoTitleLine = [UIView new];
    numInfoTitleLine.backgroundColor = [UIColor lightGrayColor];
    [self.numberInfoView addSubview:numInfoTitleLine];
    [numInfoTitleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bankNameLabel.mas_bottom).offset(19.5);
        make.left.right.equalTo(_numberInfoView);
        make.height.mas_equalTo(0.5);
    }];
    
    /** 卡号信息的TableView */
    _numInfoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _numInfoTableView.delegate = self;
    _numInfoTableView.dataSource = self;
    _numInfoTableView.backgroundColor = UIColorFromRGB(0xf6f6f6);
    _numInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.numberInfoView addSubview:_numInfoTableView];
    [_numInfoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bankNameLabel.mas_bottom).offset(20);
        make.left.right.equalTo(_numberInfoView);
        make.bottom.equalTo(_numberInfoView).offset(-45);
    }];
    
    /** tableView的FooterView */
    _footerBgView = [UIView new];
    _footerBgView.backgroundColor = [UIColor clearColor];
    [self.numInfoTableView setTableFooterView:_footerBgView];
    
    _explainLabel = [UILabel new];
    _explainLabel.numberOfLines = 0;
    _explainLabel.font = [UIFont systemFontOfSize:14];
    _explainLabel.textColor = [UIColor lightGrayColor];
//    [_footerBgView addSubview:_explainLabel];
//    [_explainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.equalTo(_footerBgView).offset(20);
//        make.right.equalTo(_footerBgView).offset(-20);
//    }];
    _explainLabel.text = @"说明:\n1、如果没有添加卡号请先点击编辑添加卡号;\n2、如果添加卡号后可以直接点击下面的按钮发送短信查询信用卡的余额;\n3、删除一个卡号，将该卡号清空保存即可删除。";
    
    UIView *numInfoBottomLine = [UIView new];
    numInfoBottomLine.backgroundColor = UIColorFromRGB(0xcecece);
    [_numberInfoView addSubview:numInfoBottomLine];
    [numInfoBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_numInfoTableView.mas_bottom);
        make.left.right.equalTo(_numberInfoView);
        make.height.mas_equalTo(0.8);
    }];
    
    UIView *bottomView = [UIView new];
    [_numberInfoView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(numInfoBottomLine.mas_bottom);
        make.left.right.bottom.equalTo(_numberInfoView);
    }];
    
    _numInfoSendSmsBtn = [UIButton new];
    [bottomView addSubview:_numInfoSendSmsBtn];
    [_numInfoSendSmsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bottomView).offset(-20);
        make.centerY.equalTo(bottomView);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(23);
    }];
    [_numInfoSendSmsBtn setTitle:@"发送信息" forState:UIControlStateNormal];
    [_numInfoSendSmsBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    _numInfoSendSmsBtn.layer.borderColor = UIColorFromRGB(0x333333).CGColor;
    _numInfoSendSmsBtn.layer.borderWidth = 1;
    _numInfoSendSmsBtn.layer.masksToBounds = YES;
    _numInfoSendSmsBtn.layer.cornerRadius = 3;
    _numInfoSendSmsBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_numInfoSendSmsBtn addTarget:self action:@selector(sendSmsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    sendSmsBtn.backgroundColor = [DEBUGCOLOR redColor];
    
    _numberInfoView.transform = CGAffineTransformScale(_numberInfoView.transform, 0.1, 0.1);
    
    _closePickerViewBtn = [UIButton new];
    [[ToolClass appDelegate].window addSubview:_closePickerViewBtn];
    _pickerViewBg = [UIView new];
    [_closePickerViewBtn addSubview:_pickerViewBg];
    _pickerView = [UIPickerView new];
    [_pickerViewBg addSubview:_pickerView];
    UIView *lineView = [UIView new];
    [_pickerViewBg addSubview:lineView];
    UIButton *pickerCancelBtn = [UIButton new];
    [_pickerViewBg addSubview:pickerCancelBtn];
    UIButton *pickerOkBtn = [UIButton new];
    [_pickerViewBg addSubview:pickerOkBtn];
    _pickerExplainLabel = [UILabel new];
    [_pickerViewBg addSubview:_pickerExplainLabel];
    
    [_closePickerViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([ToolClass appDelegate].window);
    }];
    
    [_pickerViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_closePickerViewBtn).offset(5);
        make.right.equalTo(_closePickerViewBtn).offset(-5);
        make.height.mas_equalTo(165);
        make.top.equalTo(_closePickerViewBtn.mas_bottom);
    }];
    
    [pickerCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_pickerViewBg).offset(5);
        make.left.equalTo(_pickerViewBg).offset(13);
    }];
    [pickerOkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_pickerViewBg).offset(5);
        make.right.equalTo(_pickerViewBg).offset(-13);
    }];
    [_pickerExplainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(pickerCancelBtn);
        make.centerX.equalTo(_pickerViewBg);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_pickerViewBg);
        make.bottom.equalTo(pickerCancelBtn).offset(5);
        make.height.mas_equalTo(0.5);
    }];
    
    [_pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_pickerViewBg);
        make.top.equalTo(lineView.mas_bottom);
    }];

    _pickerViewBg.backgroundColor = [UIColor whiteColor];
    _pickerViewBg.layer.masksToBounds = YES;
    _pickerViewBg.layer.cornerRadius = 10;
    
    _closePickerViewBtn.backgroundColor = RGBACOLOR(1, 1, 1, 0.35);
    _closePickerViewBtn.hidden = YES;
//    [_closePickerViewBtn addTarget:self action:@selector(closePickerViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.backgroundColor = [UIColor whiteColor];
    
    lineView.backgroundColor = RGBACOLOR(213, 213, 217, 1);
    
    [pickerCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [pickerCancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [pickerCancelBtn addTarget:self action:@selector(closePickerViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    pickerCancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [pickerOkBtn setTitle:@"确定" forState:UIControlStateNormal];
    [pickerOkBtn setTitleColor:RGBACOLOR(13, 95, 255, 1) forState:UIControlStateNormal];
    [pickerOkBtn addTarget:self action:@selector(pickerOkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    pickerOkBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    
    _pickerExplainLabel.textColor = [UIColor lightGrayColor];
    _pickerExplainLabel.font = [UIFont systemFontOfSize:15];
    _pickerExplainLabel.textAlignment = NSTextAlignmentCenter;
    _pickerExplainLabel.text = @"请先选择银行卡";
}

#pragma mark - 触发方法

- (void)pickerOkBtnClick:(UIButton *)button
{
    NSDictionary *dict = [self getBankSmsInfoDict][[self getChineseFirstAndSecondLetter:self.bankNameLabel.text]];
    NSString *prefix = dict[@"prefix"];
    NSString *smsBody;
    if ([[prefix substringFromIndex:prefix.length - 1] isEqualToString:@"+"]) {
        smsBody = [NSString stringWithFormat:@"%@%@",[prefix substringToIndex:prefix.length -1], _pickerCardLast];
    }else{
        smsBody = prefix;
    }
    [ToolClass showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"确定发送短信“%@”到%@，查询%@信用卡余额？",smsBody, dict[@"number"], self.bankNameLabel.text] completionBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self closePickerViewBtnClick:nil];
            [ToolClass showMBConnectTitle:nil toView:self.view afterDelay:0 isNeedUserInteraction:NO];
            [self showMessageView:@[dict[@"number"]] title:@"test"body:smsBody];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
}

- (void)closePickerViewBtnClick:(UIButton *)button
{
    [UIView animateWithDuration:0.2 animations:^{
        [_pickerViewBg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_closePickerViewBtn.mas_bottom);
        }];
        [_pickerViewBg.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        _closePickerViewBtn.hidden = YES;
        [_pickerView reloadAllComponents];
    }];
}

- (void)sendSmsBtnClick:(UIButton *)button
{
    NSDictionary *dict = [self getBankSmsInfoDict][[self getChineseFirstAndSecondLetter:self.bankNameLabel.text]];
    NSString *prefix = dict[@"prefix"];
    if (self.numInfoDataSource.count == 1) {
        NSString *cardLast = [self getCardNumberLastFourBit:self.numInfoDataSource.firstObject];
        NSString *smsBody;
        if ([[prefix substringFromIndex:prefix.length - 1] isEqualToString:@"+"]) {
            smsBody = [NSString stringWithFormat:@"%@%@",[prefix substringToIndex:prefix.length -1], cardLast];
        }else{
            smsBody = prefix;
        }
        [ToolClass showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"确定发送短信“%@”到%@，查询%@信用卡余额？",smsBody, dict[@"number"], self.bankNameLabel.text] completionBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
            if (buttonIndex == 1) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", dict[@"number"]]]];
                [ToolClass showMBConnectTitle:nil toView:self.view afterDelay:0 isNeedUserInteraction:NO];
                [self showMessageView:@[dict[@"number"]] title:@"test"body:smsBody];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    }else{
        [_pickerView reloadAllComponents];
        _closePickerViewBtn.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            [_pickerViewBg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_closePickerViewBtn.mas_bottom).offset(-170);
            }];
            [_pickerViewBg.superview layoutIfNeeded];
        }];
    }
}

- (void)closeBtnClick:(UIButton *)button
{
    if (self.numInfoEditBtn.selected && (self.numInfoDataSource.count != _numInfoCount || _isNeedSave)) {
        [ToolClass showAlertWithTitle:@"提示" message:@"还没有保存刚刚修改的信息\n是否保存？" completionBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
            if (buttonIndex != 0) {
                if (buttonIndex == 1) {
                    [self saveCardNumberInfoDataSource];
                }
                [self.view endEditing:YES];
                [_tempTextField resignFirstResponder];
                _numInfoEditBtn.selected = NO;
                [self.numInfoDataSource removeAllObjects];
                [self.numInfoTableView reloadData];
                [UIView animateWithDuration:0.3 animations:^{
                    _numberInfoView.transform = CGAffineTransformScale(_numberInfoView.transform, 0.1, 0.1);
                } completion:^(BOOL finished) {
                    _numberInfoView.hidden = YES;
                }];
                _isNeedSave = NO;
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"保存", @"不保存", nil];
    }else{
        [self.view endEditing:YES];
        [_tempTextField resignFirstResponder];
        _numInfoEditBtn.selected = NO;
        [self.numInfoDataSource removeAllObjects];
        [self.numInfoTableView reloadData];
        [UIView animateWithDuration:0.3 animations:^{
            _numberInfoView.transform = CGAffineTransformScale(_numberInfoView.transform, 0.1, 0.1);
        } completion:^(BOOL finished) {
            _numberInfoView.hidden = YES;
        }];
    }
}

- (void)editBtnClick:(UIButton *)button
{
    NSLog(@"编辑按钮触发事件");
    if (button.selected) {
        //保存数据
        [self saveCardNumberInfoDataSource];
        
        NSString *prefix = [NSString stringWithFormat:@"%@CardNumber", [self getChineseFirstAndSecondLetter:self.bankNameLabel.text]];
        NSArray *resultArray = [self sortedCardNumberArrayWithPrefix:prefix];
        for (int i = 0; i < resultArray.count; i++) {
            [self.numInfoDataSource addObject:[resultArray[i] componentsSeparatedByString:@","].firstObject];
        }
        if (self.numInfoDataSource.count > 0) {
            self.numInfoSendSmsBtn.hidden = NO;
        }else{
            self.numInfoSendSmsBtn.hidden = YES;
        }
        _isNeedSave = NO;
    }else{
        self.numInfoSendSmsBtn.hidden = YES;
        _numInfoCount = self.numInfoDataSource.count;
    }
    button.selected = !button.selected;
    [self.numInfoTableView reloadData];
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
static UITextField * extracted(ViewController *object) {
    return object->_tempTextField;
}

//计算器键盘逻辑(触发方法)
-(void)buttonClick:(UIButton *)button
{
    if (button.tag!=1015) {
        _tempOperation=nil;
    }
    if (button.tag>1003&&button.tag!=1015) {
        _isOperationResult=NO;
    }
    //修复删除键删除到最后一位得时候清除运算符号
    if (button.tag != 1007) {
        _isDeleteOperator = NO;
    }
    switch (button.tag-1000) {
        case 0://+
        {//加
            if (button.selected) {
                break;
            }
            if (_isOperationResult) {
                _isContinue=NO;
                _addButton.selected=YES;
                _minusButton.selected=NO;
                _multiplyButton.selected=NO;
                _divideButton.selected=NO;
                _tempString=_tempTextField.text;
                _is=@"+";
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
            if (_isOperationResult) {
                _isContinue=NO;
                _addButton.selected=NO;
                _minusButton.selected=YES;
                _multiplyButton.selected=NO;
                _divideButton.selected=NO;
                _tempString=_tempTextField.text;
                _is=@"-";
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
            if (_isOperationResult) {
                _isContinue=NO;
                _addButton.selected=NO;
                _minusButton.selected=NO;
                _multiplyButton.selected=YES;
                _divideButton.selected=NO;
                _tempString=_tempTextField.text;
                _is=@"*";
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
            if (_isOperationResult) {
                _isContinue=NO;
                _addButton.selected=NO;
                _minusButton.selected=NO;
                _multiplyButton.selected=NO;
                _divideButton.selected=YES;
                _tempString=_tempTextField.text;
                _is=@"/";
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
            //修复删除键删除到最后一位清除运算符号的bug
            if (_isDeleteOperator) {
                _is = nil;
                return;
            }
            NSInteger index;
            if (_tempTextField.text.length>0) {
                index=_tempTextField.text.length-1;
            }else{
                index=0;
            }
            _tempTextField.text=[_tempTextField.text substringToIndex:index];
            if ([_tempTextField.text isEqualToString:@""]) {
                _isDeleteOperator = YES;
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
            _isOperationResult=YES;
            [self operationButtonUnSelected];
            if (_tempOperation) {
                if ([_is isEqualToString:@"*"]) {
                    _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempTextField.text.floatValue*_tempOperation.floatValue]];
                }else if ([_is isEqualToString:@"/"]){
                    _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempTextField.text.floatValue/_tempOperation.floatValue]];
                }else if ([_is isEqualToString:@"+"]){
                    _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempTextField.text.floatValue+_tempOperation.floatValue]];
                }else if ([_is isEqualToString:@"-"]){
                    _tempTextField.text=[self formatString:[NSString stringWithFormat:@"%.2f",_tempTextField.text.floatValue-_tempOperation.floatValue]];
                }
            }else{
                if (_isContinue) {
                    _tempOperation=_tempTextField.text;
                    [self operationResult];
                }else{
                    [self operationResult];
                    _tempOperation=_tempTextField.text;
                    NSLog(@"_tempString==%@,_tempTextField.text==%@",_tempString,_tempTextField);
                }
            }
//            if (![_tempTextField isEqual:_titleTextField]) {
//                [_tempTextField resignFirstResponder];
//            }
            [self.view endEditing:YES];
        }
            break;
        case 16: //.
        { // .
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
            [extracted(self) resignFirstResponder];
        }
            break;
            
        default:
            break;
    }
}

- (void)arc4BarButtonItemClick
{
    [self.navigationController pushViewController:[ARC4ViewController new] animated:YES];
}

#pragma mark - 便捷工具方法
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

/** 获取汉字拼音的前两个字的首字母 */
- (NSString *)getChineseFirstAndSecondLetter:(NSString *)chinese
{
    NSString *resultStr;
    if (chinese.length && ![chinese isEqualToString:@""]) {
        NSMutableString *ms = [[NSMutableString alloc] initWithString:chinese];
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
            NSLog(@"pinyin: %@", ms);
        }
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
            NSLog(@"pinyin: %@", ms);
            return [ms stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSArray * resultArray = [ms componentsSeparatedByString:@" "];
            if (resultArray.count > 2) {
                resultStr = [NSString stringWithFormat:@"%@%@",[resultArray.firstObject substringWithRange:NSMakeRange(0, 1)],[resultArray[1] substringWithRange:NSMakeRange(0, 1)]];
            }else if (resultArray.count == 1){
                resultStr = [resultArray[0] substringWithRange:NSMakeRange(0, 1)];
            }else{
                resultStr = @"";
            }
        }
    }
    return resultStr;
}

/** 提示多行文字 */
- (void)showMBMessageContentText:(NSString *)text
{
    UIView *tempView = [ToolClass appDelegate].window;
    [MBProgressHUD hideAllHUDsForView:tempView animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tempView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.dimBackground = YES;
    hud.labelText = @"短信查询余额";
    hud.detailsLabelText = text ? : @"";
    hud.detailsLabelFont = [UIFont systemFontOfSize:14];
    hud.removeFromSuperViewOnHide = YES;
    UIButton * hideButton = [UIButton new];
    [hideButton setImage:[UIImage imageNamed:@"btn_clear"] forState:UIControlStateNormal];
    [hideButton addTarget:self action:@selector(hideBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [hud addSubview:hideButton];
    [hideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(hud).offset(-20);
        make.top.equalTo(hud).offset(30);
        make.width.height.mas_equalTo(30);
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        hideButton.transform = CGAffineTransformRotate(hideButton.transform, M_PI * 5);
    }];
    
    UITapGestureRecognizer *hideGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBtnClick:)];
    [hud addGestureRecognizer:hideGesture];
}

- (void)hideBtnClick:(id )object
{
    if ([object isKindOfClass:[UIButton class]]) {
        [(MBProgressHUD *)((UIButton *)object).superview hide:YES];
    }else{
        if ([((UIGestureRecognizer *)object).view isKindOfClass:[MBProgressHUD class]]) {
            [(MBProgressHUD *)((UIGestureRecognizer *)object).view hide:YES];
        }else{
            [self.view endEditing:YES];
            [_tempTextField resignFirstResponder];
        }
    }
}

+ (NSMutableAttributedString *)handelWithString:(NSString *)str andColor:(UIColor *)color
{
    NSMutableAttributedString * result = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger length = str.length;
    NSRange range = [str rangeOfString:@":"];
    NSUInteger pointlength = range.location + range.length;
    [result addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(pointlength,(length - pointlength))];
    return result;
}

/** 格式化卡号为“8888 8888 8888 8...” */
- (NSString *)cardNumberFormat:(NSString *)string
{
    NSMutableString *str = [NSMutableString new];
    NSMutableString *tempStr = [NSMutableString new];
    NSArray *subStrs = [string componentsSeparatedByString:@" "];
    if (subStrs.count) {
        for (int i = 0; i < subStrs.count; i++) {
            [tempStr appendString:subStrs[i]];
        }
    }
    string = tempStr;
    if (string.length > 4) {
        for (int i = 0; i < string.length; i++) {
            if (i % 4 == 0) {
                if (string.length - i > 4) {
                    [str appendString:[NSString stringWithFormat:@"%@ ",[string substringWithRange:NSMakeRange(i, 4)]]];
                }else{
                    [str appendString:[string substringFromIndex:i]];
                }
            }
        }
    }else{
        [str appendString:string];
    }
    return str;
}

- (NSDictionary *)getBankSmsInfoDict
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SmsQueryBalance" ofType:@"plist"]];
    return dict;
}

- (NSString *)getCardNumberLastFourBit:(NSString *)cardNum
{
    NSArray *array = [cardNum componentsSeparatedByString:@" "];
    NSMutableString *tempStr = [NSMutableString new];
    for (int i = 0; i < array.count; i++) {
        [tempStr appendString:array[i]];
    }
    return [tempStr substringFromIndex:tempStr.length - 4];
}

- (int)getSaveNumberWithPrefix:(NSString *)prefix
{
    int num = 0;
    for (int i = 0; i < 10; i++) {
        NSString *cardNum = [ToolClass objectForKey:[NSString stringWithFormat:@"%@%d",prefix, i]];
        if (cardNum) {
            num ++;
        }else{
            break;
        }
    }
    return num;
}

- (NSArray *)sortedCardNumberArrayWithPrefix:(NSString *)prefix
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        NSString *cardNum = [ToolClass objectForKey:[NSString stringWithFormat:@"%@%d",prefix, i]];
        if (cardNum) {
            [array addObject:[NSString stringWithFormat:@"%@,%@", cardNum, [NSString stringWithFormat:@"%@%d",prefix, i]]];
        }
    }
    NSArray *resultArray = [NSArray array];
    resultArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if ([obj1 componentsSeparatedByString:@","][1].doubleValue < [obj2 componentsSeparatedByString:@","][1].doubleValue) {
            return(NSComparisonResult)NSOrderedAscending;
        }else{
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    return resultArray;
}

/** 保存数据 */
- (void)saveCardNumberInfoDataSource
{
    [self.numInfoDataSource removeAllObjects];
    [self.numInfoTableView.superview layoutIfNeeded];
    NSArray *indexPaths = [NSArray arrayWithArray:[self.numInfoTableView indexPathsForRowsInRect:CGRectMake(0, 0, self.numInfoTableView.frame.size.width, self.numInfoTableView.contentSize.height)]];
    NSString *prefix = [NSString stringWithFormat:@"%@CardNumber", [self getChineseFirstAndSecondLetter:self.bankNameLabel.text]];
    NSMutableArray *removeKeys = [NSMutableArray array];
    NSMutableArray *addValues = [NSMutableArray array];
    for (int i = 0; i < indexPaths.count - 1 - 1; i++) {
        NSIndexPath *indexPath= indexPaths[i];
        NumInfoCell *cell = [self.numInfoTableView cellForRowAtIndexPath:indexPath];
        if (cell.cardNumber.text.length != 0) {
            NSArray *resultArray = [self sortedCardNumberArrayWithPrefix:prefix];
            if (indexPath.row < resultArray.count) {
                NSString *keyStr = [resultArray[indexPath.row] componentsSeparatedByString:@","].lastObject;
                if ([ToolClass objectForKey:keyStr] && ![cell.cardNumber.text isEqualToString:[[ToolClass objectForKey:keyStr] componentsSeparatedByString:@","].firstObject]) {
                    [ToolClass setObject:[NSString stringWithFormat:@"%@,%@", cell.cardNumber.text, [[ToolClass objectForKey:keyStr] componentsSeparatedByString:@","].lastObject] forKey:keyStr];
                }
            }else{
                [addValues addObject:[NSString stringWithFormat:@"%@,%f", cell.cardNumber.text, [ToolClass timeIntervalFromNowDate]]];
            }
        }else{
            NSArray *resultArray = [self sortedCardNumberArrayWithPrefix:prefix];
            if (indexPath.row < resultArray.count) {
                NSString *removeKey = [resultArray[indexPath.row] componentsSeparatedByString:@","].lastObject;
                [removeKeys addObject:removeKey];
            }
        }
    }
    if (addValues.count) {
        for (NSString *value in addValues) {
            [ToolClass setObject:value forKey:[NSString stringWithFormat:@"%@%d", prefix, [self getSaveNumberWithPrefix:prefix]]];
        }
        [addValues removeAllObjects];
    }
    if (removeKeys.count) {
        for (int i = 0; i < removeKeys.count; i++) {
            [ToolClass removeObjectForKey:removeKeys[i]];
        }
        [removeKeys removeAllObjects];
    }
}

/** 发送短信的方法 */
- (void)showMessageView:(NSArray*)phones title:(NSString*)title body:(NSString*)body
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = phones;
        controller.navigationBar.tintColor = [UIColor redColor];
        controller.body = body;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            [ToolClass hideMBConnect];
        }];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
    } else {
        [ToolClass hideMBConnect];
        [ToolClass showMBMessageTitle:@"该设备不支持短信功能" toView:self.view];
    }
}

#pragma mark - 通知相关
//注册通知
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueChange) name:@"ValueChange" object:nil];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    /** TextFieldTextDidChange接收通知 */
    [NotificationCenter addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

}
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if (_tempTextField.text.floatValue==0) {
        _tempTextField.text=@"0";
    }
//    _titleView.hidden=YES;
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    //将运算符号置空
    _is=nil;
//    _titleView.hidden=NO;
}
//输入结束通知触发方法
-(void)valueChange
{
    //刷新数据
    [self createDataSource];
    NSLog(@"valueChange刷新数据");
    
    _eduLabel.text=[NSString stringWithFormat:@" 额度:￥%@ ★",[self loadDataWithIdentifier:@"edu"]];
    
    _qiankuanLabel.text=[NSString stringWithFormat:@" 欠款:￥%@ ",[self loadDataWithIdentifier:@"qiankuan"]];
    
    _yueLabel.text=[NSString stringWithFormat:@" 余额:￥%.2f ",[self loadDataWithIdentifier:@"edu"].floatValue-[self loadDataWithIdentifier:@"qiankuan"].floatValue];
}

/** 卡号输入框在text改变后调用通知 */
- (void)textFieldDidChange:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UITextField class]]) {
        if ((UITextField *)notification.object == _numInfoTextField) {
            _numInfoTextField.text = [self cardNumberFormat:_numInfoTextField.text];
            _isNeedSave = YES;
        }
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [_tempTextField resignFirstResponder];
    // 当开始滚动时将是否滚动置为YES
    if (scrollView == _tableView) {
        _isScorll2 = YES;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{

}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    // 当结束滑动，开始减速时将是否滚动置为NO
    if (scrollView == _tableView && _tableView.contentSize.height > _tableView.frame.size.height - 55) {
        _isScorll2 = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollView.contentOffSet==%.f",scrollView.contentOffset.y);
    NSLog(@"scrollView.contentSize.height == %.2f, scrollView.frame.size.height == %.2f",scrollView.contentSize.height, scrollView.frame.size.height);
    if (scrollView == _tableView) {
        CGFloat currentContentOffSetY = scrollView.contentOffset.y;
        if (_tempContentOffSetY <= 0 || currentContentOffSetY < _tempContentOffSetY) {
            __block CGRect frame = _titleView.frame;
            if (frame.origin.y != HEIGHT - 64 - 55 && _isScorll2) {
                [UIView animateWithDuration:0.3 animations:^{
                    frame.origin.y = HEIGHT - 64 - 55;
                    _titleView.frame = frame;
                }];
            }
        }else if (currentContentOffSetY > _tempContentOffSetY){
            __block CGRect frame = _titleView.frame;
            if (frame.origin.y != HEIGHT - 64) {
                [UIView animateWithDuration:0.3 animations:^{
                    frame.origin.y = HEIGHT - 64;
                    _titleView.frame = frame;
                }];
            }
        }
//        if (currentContentOffSetY > _tempContentOffSetY && currentContentOffSetY > 0 && currentContentOffSetY < _tableView.contentSize.height - scrollView.frame.size.height) {
//            if (_isScorll1) {
//                [UIView animateWithDuration:0.3 animations:^{
//                    CGRect frame = _titleView.frame;
//                    frame.origin.y += 55;
//                    _titleView.frame = frame;
//                    _isScorll1 = NO;
//                    _isScorll2 = YES;
//                }];
//            }
//        }else if (currentContentOffSetY < _tempContentOffSetY && currentContentOffSetY > 0 && currentContentOffSetY < _tableView.contentSize.height - scrollView.frame.size.height) {
//            if (_isScorll2) {
//                [UIView animateWithDuration:0.3 animations:^{
//                    CGRect frame = _titleView.frame;
//                    frame.origin.y -= 55;
//                    _titleView.frame = frame;
//                }];
//                _isScorll1 = YES;
//                _isScorll2 = NO;
//            }
//        }
        _tempContentOffSetY = scrollView.contentOffset.y;
    }else{
    
    }
}

#pragma mark - UITextFeild代理方法
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"开始输入,%@",textField.text);
    if (textField == self.numInfoTextField) {
        
    }else{
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
            _titleTextField.textAlignment=NSTextAlignmentRight;
        }else{
            self.cell = (AppCell *)textField.superview.superview;
            self.cell.edu.inputView=_inputView;
            self.cell.qiankuan.inputView=_inputView;
            self.cell.yue.inputView=_inputView;
        }
        
        _tempTextField = textField;
        _tempTextField.textAlignment=NSTextAlignmentRight;
        
        if (_tempTextField.text.floatValue==0) {
            _tempTextField.text=@"0";
        }
        [self operationButtonUnSelected];
        _is=nil;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.numInfoTextField) {
        
    }else{
        textField.textAlignment=NSTextAlignmentLeft;
        
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
        
        [UserDefaults setObject:self.cell.edu.text forKey:[NSString stringWithFormat:@"%@edu",self.cell.string]];
        [UserDefaults setObject:self.cell.yue.text forKey:[NSString stringWithFormat:@"%@yue",self.cell.string]];
        [UserDefaults setObject:self.cell.qiankuan.text forKey:[NSString stringWithFormat:@"%@qiankuan",self.cell.string]];
        [UserDefaults synchronize];
        //输入结束发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ValueChange" object:nil];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.numInfoTextField) {
        
    }else{
        if (textField==self.cell.yue) {
            self.cell.qiankuan.text=[NSString stringWithFormat:@"%.2f",self.cell.edu.text.floatValue-self.cell.yue.text.floatValue];
        }else if (textField==self.cell.qiankuan){
            self.cell.yue.text=[NSString stringWithFormat:@"%.2f",self.cell.edu.text.floatValue-self.cell.qiankuan.text.floatValue];
        }
    }
    return YES;
}
#pragma mark - TableView的代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        return self.dataSource.count;
    }else{
        if (self.numInfoEditBtn.selected) {
            return self.numInfoDataSource.count + 1 + 1;
        }else{
            return self.numInfoDataSource.count + 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        AppCell * cell=[tableView dequeueReusableCellWithIdentifier:@"a"];
        if (!cell) {
            cell=[[AppCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"a"];
        }
        CustomModel * model=self.dataSource[indexPath.row];
        [cell configWithModel:model];
        cell.edu.delegate=self;
        cell.qiankuan.delegate=self;
        cell.yue.delegate=self;
        
        [cell setShowSmsSendExplain:^{
            [_tempTextField resignFirstResponder];
            NSDictionary *dict = [self getBankSmsInfoDict];
            [self showMBMessageContentText:dict[model.imageName][@"description"]];
        }];
        
        [cell setCardNumberButtonClick:^{
            [_tempTextField resignFirstResponder];
            
            self.bankNameLabel.text = model.bankName;
            
            NSString *prefix = [NSString stringWithFormat:@"%@CardNumber", [self getChineseFirstAndSecondLetter:self.bankNameLabel.text]];
            
            NSArray *resultArray = [self sortedCardNumberArrayWithPrefix:prefix];
            for (int i = 0; i < resultArray.count; i++) {
                [self.numInfoDataSource addObject:[resultArray[i] componentsSeparatedByString:@","].firstObject];
            }
            
            [self.numInfoTableView reloadData];
            if (self.numInfoDataSource.count > 0) {
                self.numInfoSendSmsBtn.hidden = NO;
            }else{
                self.numInfoSendSmsBtn.hidden = YES;
            }
            _numberInfoView.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                _numberInfoView.transform = CGAffineTransformScale(_numberInfoView.transform, 10, 10);
            } completion:^(BOOL finished) {
            }];
        }];
        
        return cell;
    }else{
        UITableViewCell *cell;
        if ((!self.numInfoEditBtn.selected && indexPath.row == self.numInfoDataSource.count) || (self.numInfoEditBtn.selected && indexPath.row == self.numInfoDataSource.count + 1)) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"explainCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"explainCell"];
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:_explainLabel];
            [_explainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.equalTo(cell.contentView).offset(20);
                make.right.equalTo(cell.contentView).offset(-20);
            }];
        }else if (self.numInfoEditBtn.selected && indexPath.row == self.numInfoDataSource.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addCell"];
            }
            
            cell.imageView.image = [UIImage imageNamed:@"currency_add"];
            cell.textLabel.text = @"添加一个卡号";
            
            UILabel *line2 = [UILabel new];
            line2.backgroundColor = UIColorFromRGB(0xcecece);
            [cell.contentView addSubview:line2];
            [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell.imageView.mas_right);
                make.right.equalTo(cell.contentView);
                make.bottom.equalTo(cell.contentView);
                make.height.mas_equalTo(0.5);
            }];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@""];
            if (!cell) {
                cell = [[NumInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
            }
            ((NumInfoCell *)cell).cardNumber.userInteractionEnabled = self.numInfoEditBtn.selected;
            ((NumInfoCell *)cell).cardNumberLine.hidden = !self.numInfoEditBtn.selected;
            ((NumInfoCell *)cell).cardLabel.text = [NSString stringWithFormat:@"卡号%d:",indexPath.row + 1];
            ((NumInfoCell *)cell).cardNumber.text = self.numInfoDataSource[indexPath.row];
            if (!self.numInfoEditBtn.selected) {
                ((NumInfoCell *)cell).cardNumber.text = [NSString stringWithFormat:@"%@ **** **** %@", [((NumInfoCell *)cell).cardNumber.text substringToIndex:4], [self getCardNumberLastFourBit:((NumInfoCell *)cell).cardNumber.text]];
            }
            if (self.numInfoEditBtn.selected && indexPath.row == self.numInfoDataSource.count - 1) {
                [((NumInfoCell *)cell).cardNumber becomeFirstResponder];
            }
            
            __weak typeof((NumInfoCell *)cell) weakCell = (NumInfoCell *)cell;
            [(NumInfoCell *)cell setTextFieldDidBeginEditing:^(UITextField *textField) {
                self.numInfoTextField = textField;
                _tempLoc = weakCell.cardNumber.text.length;
            }];
            [(NumInfoCell *)cell setTextFieldDidEndEditing:^(UITextField *textField) {
                
            }];
            [(NumInfoCell *)cell setShouldChangeCharactersInRange:^BOOL(UITextField *textField, NSRange range, NSString *string) {
                NSString *tempStr = weakCell.cardNumber.text;
                if (range.location < _tempLoc) {
                    if (range.location % 5 == 0) {
                        textField.text = [tempStr substringToIndex:textField.text.length - 1];
                    }
                }
                _tempLoc = range.location;
                return YES;
            }];
        }
        return cell;
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        return 95;
    }else{
        if ((!self.numInfoEditBtn.selected && indexPath.row == self.numInfoDataSource.count) || (self.numInfoEditBtn.selected && indexPath.row == self.numInfoDataSource.count + 1)) {
            [_explainLabel.superview layoutIfNeeded];
            return _explainLabel.bounds.size.height + 20 * 2;
        }else{
            return 44;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _tableView) {

    }else{
        if (indexPath.row == self.numInfoDataSource.count && self.numInfoEditBtn.selected) {
            if (self.numInfoDataSource.count < 10) {
                [self.numInfoDataSource addObject:@""];
                [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                
                [_explainLabel.superview layoutIfNeeded];
                CGSize tempSize = _numInfoTableView.contentSize;
                tempSize.height += _explainLabel.bounds.size.height + 20 * 2;
                _numInfoTableView.contentSize = tempSize;
            }else{
                [ToolClass showMBMessageTitle:@"最多添加10个卡号" toView:self.view];
            }
        }
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    switch(result){
        case MessageComposeResultSent:
            //信息传送成功
            [ToolClass showMBMessageTitle:@"信息发送成功" toView:self.view];
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            [ToolClass showMBMessageTitle:@"信息发送失败" toView:self.view];
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            [ToolClass showMBMessageTitle:@"信息被用户取消发送" toView:self.view];
            break;
        default:
            break;
    }
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
//以下3个方法实现PickerView的数据初始化
//确定picker的轮子个数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//确定picker的每个轮子的item数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.numInfoDataSource.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _pickerCardLast = [self getCardNumberLastFourBit:self.numInfoDataSource[row]];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (row == 0) {
        _pickerCardLast = [self getCardNumberLastFourBit:self.numInfoDataSource[row]];
    }
    UILabel *_pickerTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _pickerView.bounds.size.width, 30)];
    _pickerTextLabel.textAlignment = NSTextAlignmentCenter;
    _pickerTextLabel.text = [NSString stringWithFormat:@"%@ **** **** %@", [self.numInfoDataSource[row] substringToIndex:4], [self getCardNumberLastFourBit:self.numInfoDataSource[row]]];
    _pickerTextLabel.font = [UIFont systemFontOfSize:16];         //用label来设置字体大小
    _pickerTextLabel.backgroundColor = [UIColor clearColor];
    return _pickerTextLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
