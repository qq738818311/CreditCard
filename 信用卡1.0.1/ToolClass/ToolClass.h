//
//  ToolClass.h
//  bracelet
//
//  Created by dehangsui on 14-11-10.
//  Copyright (c) 2014年 com.i.spark. All rights reserved.
//

//创建单例的宏定义
#define singleton_interface(className) \
+ (className *)shared##className;

// @implementation
#define singleton_implementation(className) \
static className *_instance; \
+ (id)allocWithZone:(NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
+ (className *)shared##className \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
}

//RGB Color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
//RGB
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define WIDTH  [UIScreen mainScreen].bounds.size.width                                              //屏幕的宽度
#define HEIGHT [UIScreen mainScreen].bounds.size.height                                             //屏幕的高度

#define UserDefaults          [NSUserDefaults standardUserDefaults]                                 //UserDefaults
#define NotificationCenter    [NSNotificationCenter defaultCenter]                                  //通知中心

#define kBHDevice [UIDevice currentDevice].identifierForVendor.UUIDString                           //设备信息
#define AppVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] //版本信息
#define AppName [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]                  //App名字

#define kRequestTimeoutInterval 10                                          //请求超时时间

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AppDelegate;
@class MBProgressHUD;

extern NSString * const NetIsConnectedNotification;                         //网络改变通知
extern NSString * const NetConnectStatu;                                    //网络连接状态
extern NSString * const NetIsConnected;                                     //是否连接网络

typedef void (^successBlock)(id responseObject);                            //请求成功回调block
typedef void (^failureBlock)(NSError *error);                               //请求失败回调block

@interface ToolClass : NSObject
{

}

@property (nonatomic, strong) MBProgressHUD *processHub;                    //MBHud控件

@property (nonatomic, copy) NSString *connectStatu;                         //网络连接类型
@property (nonatomic, assign) BOOL isConnectedNet;                          //是否有网络

//宏定义创建单例
singleton_interface(ToolClass)

#pragma mark - 本地储存相关

/**
 *  UserDefaults从本地取对象
 *
 *  @param defaultName 取的名字Key
 *
 *  @return 返回本地名字Key所对应的对象的值
 */
+ (id)objectForKey:(NSString *)defaultName;

/**
 *  UserDefaults存本地的对象
 *
 *  @param value       要存本地的对象的值
 *  @param defaultName 存的名字Key
 */
+ (void)setObject:(id)value forKey:(NSString *)defaultName;

/**
 *  UserDefaults从本地取BOOL值
 *
 *  @param defaultName 取的名字Key
 *
 *  @return 返回本地名字Key所对应的BOOL值
 */
+ (BOOL)boolForKey:(NSString *)defaultName;

/**
 *  UserDefaults存本地BOOL值
 *
 *  @param value       要存本地的BOOL值
 *  @param defaultName 存的名字Key
 */
+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName;

/** UserDefaults通过key删除一个对象 */
+ (void)removeObjectForKey:(NSString *)defaultName;

/**
 *  UserDefaults存本地Data数据
 *
 *  @param data        要存本地的Data数据
 *  @param defaultName 存的名字Key
 */
+ (void)setData:(NSData *)data forKey:(NSString *)defaultName;

/**
 *  UserDefaults从本地取Data数据
 *
 *  @param defaultName 取的名字Key
 *
 *  @return 返回本地名字Key所对应的Data数据
 */
+ (NSData *)dataForKey:(NSString *)defaultName;

/**
 *  返回Token
 *
 *  @param userId   用户id
 *  @param youlife  与后台协商定义的字段
 *  @param deviceId 设备信息
 *
 *  @return 返回一个Token字串
 */
+(NSString *)tokenMD5WithUserId:(NSString *)userId youLife:(NSString *)youlife deviceId:(NSString *)deviceId;

/**
 *  计算缓存大小
 *
 *  @param folderPath 传入文件夹位置
 *
 *  @return 返回缓存大小单位为M
 */
+ (float)folderSizeAtPath:(NSString *)folderPath;

/**
 *  通过文件夹位置来清理缓存
 *
 *  @param path 文件夹位置
 */
+ (void)clearCache:(NSString *)path;

#pragma mark - 提示相关

/**
 *  提示控件(默认显示时间为1.5秒，如果不传toView默认加到Window上)
 *
 *  @param text 显示的文字
 *  @param view 承载的控件(如果不传toView默认加到Window上)
 */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view;

/**
 *  提示控件
 *
 *  @param text   显示的文字
 *  @param view   承载的控件(如果不传toView默认加到Window上)
 *  @param second 显示时间
 */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view showTime:(NSTimeInterval)second;

/**
 *  显示MBHUD
 *
 *  @param text 需要显示的文字
 */
+ (void)showMBConnectTitle:(NSString *)text toView:(UIView *)view;

/**
 *  延时显示MBHUD(单位:(秒)0为立即显示)
 *
 *  @param text  显示的文字
 *  @param view  显示的控件
 *  @param delay 延时的时间(秒)
 */
+ (void)showMBConnectTitle:(NSString *)text toView:(UIView *)view afterDelay:(NSTimeInterval)delay isNeedUserInteraction:(BOOL)isNeed;

/**
 *  刷新MBHUD的文字
 *
 *  @param text 刷新时显示的文字
 */
+ (void)reloadMBConnectTitle:(NSString *)text;

/**
 *  结束MBHUD
 */
+ (void)hideMBConnect;

/**
 *  检测网络连接，用AF的是异步的，放到AppDelegate类里面
 */
+ (void)reachabilityNetConnectWithAF;

/** 检测网络连接，这是同步的，放到AppDelegate类里面 */
+ (void)reachabilityNetConnect;

/**
 *  获取AppDelegate单例
 *
 *  @return 返回AppDelegate单例
 */
+ (AppDelegate *)appDelegate;

/**
 *  网络请求，GET
 *
 *  @param url     请求地址
 *  @param params  传入参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+ (void)httpRequestGETWithURL:(NSString *)url params:(NSDictionary *)params  success:(successBlock)success failure:(failureBlock)failure;

/**
 *  网络请求，POST
 *
 *  @param url     请求地址
 *  @param params  传入参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+ (void)httpRequestPOSTWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure;

/**
 *  注册IQKeyboard，在程序入口处调用
 */
+ (void)registerIQKeyboard;

#pragma mark - 时间相关

/**
 *  时间格式化为字符串(format:YYYY-MM-DD HH:mm:ss)
 *
 *  @param format YYYY-MM-DD HH:mm:ss
 *  @param date   时间
 *
 *  @return 格式化后的时间字符串
 */
+ (NSString *)stringFromDateWithFormat:(NSString *)format date:(NSDate *)date;

/**
 *  当前时间格式化为字符串(format:YYYY-MM-DD HH:mm:ss)
 *
 *  @param format YYYY-MM-DD HH:mm:ss
 *
 *  @return 当前时间格式化后的字符串
 */
+ (NSString *)stringFromNowDateFormat:(NSString *)format;

/**
 *  获取传入时间的时间戳
 *
 *  @param date 传入的时间对象
 *
 *  @return 返回时间戳
 */
+ (NSTimeInterval)timeIntervalFromDate:(NSDate *)date;

/**
 *  获取当前时间的时间戳
 *
 *  @return 返回当前时间的时间戳
 */
+ (NSTimeInterval)timeIntervalFromNowDate;

/**
 *  获取传入时间毫秒级的时间戳
 *
 *  @param date 传入的时间对象
 *
 *  @return 返回毫秒级的时间戳
 */
+ (long long)milliSecondTimeIntervalFromDate:(NSDate *)date;

/**
 *  获取当前时间毫秒级的时间戳
 *
 *  @return 返回当前时间毫秒级的时间戳
 */
+ (long long)milliSecondTimeIntervalFromNowDate;

#pragma mark - UI相关

/**
 *  隐藏TableView多余的线(如果设了FooterView就不要用该方法)
 *
 *  @param tableView 传入的TableView
 */
+ (void)setExtraCellLineHidden: (UITableView *)tableView;

/**
 *  显示一个AlertView
 *
 *  @param title             显示的标题
 *  @param message           显示的信息
 *  @param block             block回调
 *  @param cancelButtonTitle 取消按钮的标题
 *  @param otherButtonTitles 其他按钮的标题
 */
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message completionBlock:(void (^)(UIAlertView *alertView, NSUInteger buttonIndex))block cancelButtonTitle:(NSString *) cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
