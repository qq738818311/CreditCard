//
//  ToolClass.m
//  bracelet
//
//  Created by dehangsui on 14-11-10.
//  Copyright (c) 2014年 com.i.spark. All rights reserved.
//

#import "ToolClass.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

#import "SDImageCache.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "KeyboardManager.h"
#import "Reachability.h"

NSString * const NetIsConnectedNotification = @"NetIsConnectedNotification";    //网络改变通知
NSString * const NetConnectStatu = @"NetConnectStatu";                          //网络连接状态
NSString * const NetIsConnected = @"NetIsConnected";                            //是否连接网络

typedef void(^myWillHanleBlock)();
//typedef void (^clickedButtonAtIndex)(UIAlertView *alertView, NSUInteger buttonIndex);

@interface ToolClass() <UIAlertViewDelegate>
{
    myWillHanleBlock _dealblock;
//    clickedButtonAtIndex _alertViewBlock;
}

@property (nonatomic, copy) void (^alertViewClickedButtonAtIndexBlock)(UIAlertView *alertView, NSUInteger buttonIndex);

@end
@implementation ToolClass
singleton_implementation(ToolClass)

- (instancetype)init
{
    if (self = [super init]) {

    }
    return self;
}

//- (MBProgressHUD *)processHub
//{
//    if (!_processHub) {
//        _processHub = [[MBProgressHUD alloc] initWithWindow:[ToolClass appDelegate].window];
////        _processHub.dimBackground = YES;
//    }
//    return _processHub;
//}

#pragma mark - 本地储存相关

+ (id)objectForKey:(NSString *)defaultName
{
    return [UserDefaults objectForKey:defaultName];
}

+ (void)setObject:(id)value forKey:(NSString *)defaultName
{
    [UserDefaults setObject:value forKey:defaultName];
    [UserDefaults synchronize];
}

+ (BOOL)boolForKey:(NSString *)defaultName
{
    return [UserDefaults boolForKey:defaultName];
}

+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
    [UserDefaults setBool:value forKey:defaultName];
    [UserDefaults synchronize];
}

+ (void)removeObjectForKey:(NSString *)defaultName
{
    [UserDefaults removeObjectForKey:defaultName];
    [UserDefaults synchronize];
}

+ (void)setData:(NSData *)data forKey:(NSString *)defaultName
{
    [UserDefaults setValue:data forKey:defaultName];
    [UserDefaults synchronize];
}

+ (NSData *)dataForKey:(NSString *)defaultName
{
    return [UserDefaults valueForKey:defaultName];
}

//32位MD5加密方式
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString isUppercase:(BOOL)isUppercase{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    if (isUppercase) {
        return   [result uppercaseString];
    }else{
        return result;
    }
}

/**
 *  返回空Token
 *
 *  @param userId   用户id
 *  @param youlife  与服务协商定义的字符串
 *  @param deviceId 设备信息
 *
 *  @return 返回一个空Token
 */
+ (NSString *)tokenMD5WithUserId:(NSString *)userId youLife:(NSString *)youlife deviceId:(NSString *)deviceId
{
    //ea8f538c-fece-c6a84842-8a0df724
    /*
     userId 用户Id
     youlife 与后台协商定义的字符串
     deviceId 设备信息deviceId=[UIDevice currentDevice].identifierForVendor.UUIDString;
     */
    NSString * str1 = [[self getMd5_32Bit_String:userId isUppercase:NO] substringToIndex:8];
    NSString * str2 = [[self getMd5_32Bit_String:youlife isUppercase:NO] substringToIndex:4];
    NSString * str3 = [[self getMd5_32Bit_String:deviceId isUppercase:NO] substringToIndex:8];
    NSString * str4 = [[self getMd5_32Bit_String:[NSString stringWithFormat:@"%llu",(long long)[[NSDate date] timeIntervalSince1970]] isUppercase:NO] substringToIndex:8];
    return [NSString stringWithFormat:@"%@-%@-%@-%@",str1,str2,str3,str4];
    
}

//遍历文件夹获得缓存文件夹大小，返回多少M
+ (float)folderSizeAtPath:(NSString*) folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
//        folderSize += [self fileSizeAtPath:fileAbsolutePath];
        if ([manager fileExistsAtPath:fileAbsolutePath]){
            folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
        }
    }
    return folderSize/(1024.0*1024);
}

//清除缓存
+ (void)clearCache:(NSString *)path
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    [[SDImageCache sharedImageCache] cleanDisk];
}

#pragma mark - 提示相关

/** 提示控件(默认显示时间为1.5秒，如果不传toView默认加到Window上) */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view
{
    [ToolClass showMBMessageTitle:text toView:view showTime:1.5];
}

/** 提示控件 */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view showTime:(NSTimeInterval)second
{
    UIView *tempView = view ? : [ToolClass appDelegate].window;
    [MBProgressHUD hideAllHUDsForView:tempView animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tempView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text ? : @"";
    hud.detailsLabelText = @"";
    hud.labelFont = [UIFont systemFontOfSize:14];
    hud.margin = 10;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:second];
}

/** 显示MBHUD(默认延时1秒) */
+ (void)showMBConnectTitle:(NSString *)text toView:(UIView *)view
{
    [ToolClass showMBConnectTitle:text toView:view afterDelay:1 isNeedUserInteraction:NO];
}

/** 延时显示MBHUD */
+ (void)showMBConnectTitle:(NSString *)text toView:(UIView *)view afterDelay:(NSTimeInterval)delay isNeedUserInteraction:(BOOL)isNeed
{
    UIView *tempView = view ? : [ToolClass appDelegate].window;
    ToolClass * tool = [ToolClass sharedToolClass];
    [tool.processHub hide:YES];
//    [MBProgressHUD hideAllHUDsForView:tempView animated:YES];
    tool.processHub = [[MBProgressHUD alloc] initWithView:tempView];
    [tempView addSubview:tool.processHub];
    tool.processHub.mode = MBProgressHUDModeIndeterminate;
    tool.processHub.detailsLabelText =@"";
    tool.processHub.labelText = text ? : @"";
    tool.processHub.margin = 10;
    tool.processHub.userInteractionEnabled = isNeed ? NO : YES;
    // 隐藏时候从父控件中移除
    tool.processHub.removeFromSuperViewOnHide = YES;
    [tool performSelector:@selector(showProcessHub) withObject:nil afterDelay:delay];
}

- (void)showProcessHub
{
    [[ToolClass sharedToolClass].processHub show:YES];
}

/** 刷新MBHUD的文字 */
+ (void)reloadMBConnectTitle:(NSString *)text
{
    [ToolClass sharedToolClass].processHub.labelText = text;
}

/**
 *  结束MBHUD
 */
+ (void)hideMBConnect
{
    [[ToolClass sharedToolClass].processHub hide:YES];
}

/**
 *  检测网络连接
 */
+ (void)reachabilityNetConnectWithAF
{
    ToolClass *tool = [ToolClass sharedToolClass];
    AFNetworkReachabilityManager * afReachability = [AFNetworkReachabilityManager sharedManager];
    [afReachability startMonitoring];  //开启网络监视器；
    [afReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:       //无网络
            {
                tool.connectStatu = @"无网络";
                tool.isConnectedNet = NO;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:   //WiFi连接
            {
                tool.connectStatu = @"WiFi连接";
                tool.isConnectedNet = YES;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:   //移动数据连接
            {
                tool.connectStatu = @"移动数据连接";
                tool.isConnectedNet = YES;
            }
                break;
            case AFNetworkReachabilityStatusUnknown:            //未知连接
            {
                tool.connectStatu = @"未知连接";
                tool.isConnectedNet = YES;
            }
                break;
                
            default:
            {
                tool.connectStatu = @"无网络";
                tool.isConnectedNet = NO;
            }
                break;
        }
        [NotificationCenter postNotificationName:NetIsConnectedNotification object:@{NetConnectStatu : tool.connectStatu , NetIsConnected : [NSString stringWithFormat:@"%@",tool.isConnectedNet ? @"YES" : @"NO"]}];
    }];
}

+ (void)reachabilityNetConnect
{
    ToolClass *tool = [ToolClass sharedToolClass];
    // 1.检测wifi状态
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];
    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    // 3.判断网络状态
    if ([wifi currentReachabilityStatus] != NotReachable) { // 有wifi
        tool.connectStatu = @"WiFi连接";
        tool.isConnectedNet = YES;
    } else if([conn currentReachabilityStatus] != NotReachable){
        // 没有使用wifi, 使用手机自带网络进行上网
        tool.connectStatu = @"移动数据连接";
        tool.isConnectedNet = YES;
    }else{
        tool.connectStatu = @"无网络";
        tool.isConnectedNet = NO;
    }
    [NotificationCenter postNotificationName:NetIsConnectedNotification object:@{NetConnectStatu : tool.connectStatu , NetIsConnected : [NSString stringWithFormat:@"%@",tool.isConnectedNet ? @"YES" : @"NO"]}];
}

/**
 *  获取AppDelegate单例
 *
 *  @return 返回AppDelegate单例
 */
+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

/**
 *  GET请求
 *
 *  @param url     请求地址
 *  @param params  传入参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+ (void)httpRequestGETWithURL:(NSString *)url params:(NSDictionary *)params  success:(successBlock)success failure:(failureBlock)failure
{
    NSMutableDictionary * dict = [params mutableCopy];
//    [dict setObject:[ToolClass objectForKey:@"employee_token"]?[ToolClass objectForKey:@"employee_token"]:[ToolClass tokenMD5WithUserId:@"" youLife:@"HEALTHAPP" deviceId:kBHDevice] forKey:@"token"];
    // 1.创建AFN管理者
    AFHTTPRequestOperationManager *mange = [AFHTTPRequestOperationManager manager];
    
    // 2.发送请求
    [mange GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 请求成功
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

/**
 *  POST请求
 *
 *  @param url     请求地址
 *  @param params  传入参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+ (void)httpRequestPOSTWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure
{
    NSMutableDictionary * dict = [params mutableCopy];
//    [dict setObject:[ToolClass objectForKey:@"employee_token"]?[ToolClass objectForKey:@"employee_token"]:[ToolClass tokenMD5WithUserId:@"" youLife:@"HEALTHAPP" deviceId:kBHDevice] forKey:@"token"];
    // 1.创建AFN管理者
    AFHTTPRequestOperationManager *mange = [AFHTTPRequestOperationManager manager];
    mange.requestSerializer.timeoutInterval = kRequestTimeoutInterval;
    mange.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json",@"text/html",nil];
    // 2.发送请求
    [mange POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 请求成功, 通知调用者请求成功
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 通知调用者请求失败
        if (failure) {
            failure(error);
        }
    }];
}

/** 注册IQKeyboard，在程序入口处调用 */
+ (void)registerIQKeyboard
{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    // enable控制整个功能是否启用。
    manager.enable = YES;
    // 控制点击背景是否收起键盘。
    manager.shouldResignOnTouchOutside = YES;
    // 控制键盘上的工具条文字颜色是否用户自定义。
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    // 控制是否显示键盘上的工具条。
    manager.enableAutoToolbar = NO;
}

#pragma mark - 时间相关

/** 时间格式化为字符串(format:yyyy-MM-dd HH:mm:ss) */
+ (NSString *)stringFromDateWithFormat:(NSString *)format date:(NSDate *)date
{
    NSDateFormatter * dateFormat =[[NSDateFormatter alloc] init];
    dateFormat.dateFormat = format;
    NSString *dateStr = [dateFormat stringFromDate:date];
    return dateStr;
}

/** 当前时间格式化为字符串(format:yyyy-MM-dd HH:mm:ss) */
+ (NSString *)stringFromNowDateFormat:(NSString *)format
{
    return [ToolClass stringFromDateWithFormat:format date:[NSDate date]];
}

/** 获取传入时间的时间戳 */
+ (NSTimeInterval)timeIntervalFromDate:(NSDate *)date
{
    return date.timeIntervalSince1970;
}

/** 获取当前时间的时间戳 */
+ (NSTimeInterval)timeIntervalFromNowDate
{
    return [ToolClass timeIntervalFromDate:[NSDate date]];
}

/** 获取传入时间毫秒级的时间戳 */
+ (long long)milliSecondTimeIntervalFromDate:(NSDate *)date
{
    long long result = [ToolClass timeIntervalFromDate:date]* (long long)1000;
    return result;
}

/** 获取当前时间毫秒级的时间戳 */
+ (long long)milliSecondTimeIntervalFromNowDate
{
    return [ToolClass milliSecondTimeIntervalFromDate:[NSDate date]];
}

#pragma mark - UI相关

/** 隐藏TableView多余的线 */
+ (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView * view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

/** 显示一个AlertView */
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message completionBlock:(void (^)(UIAlertView *alertView, NSUInteger buttonIndex))block cancelButtonTitle:(NSString *) cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:[ToolClass sharedToolClass] cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if (otherButtonTitles != nil) {
        id eachObject;
        va_list argumentList;
        if (otherButtonTitles) {
            [alertView addButtonWithTitle:otherButtonTitles];
            va_start(argumentList, otherButtonTitles);
            while ((eachObject = va_arg(argumentList, id))) {
                [alertView addButtonWithTitle:eachObject];
            }
            va_end(argumentList);
        }
    }
    [alertView show];
    [ToolClass sharedToolClass].alertViewClickedButtonAtIndexBlock = block;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertViewClickedButtonAtIndexBlock) {
        self.alertViewClickedButtonAtIndexBlock (alertView, buttonIndex);
    }
}

@end
