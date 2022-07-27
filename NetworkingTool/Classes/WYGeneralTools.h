//
//  WYGeneralTools.h
//  NetworkingTool
//
//  Created by macWangYuan on 2022/7/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WYGeneralTools : NSObject

/* id数据 转 json串 **/
+ (NSString *)nativeDataParseJson:(id _Nonnull)obj;

/* json串 转 id数据 **/
+ (id)nativeDataWithJsonString:(NSString *_Nonnull)jsonString;

/*  10位当前时间戳 */
+ (NSNumber *)getTenThisMachineTheTimeStamp;

/* 获取 网络 10位 时间戳 **/
+ (NSNumber *)getInternetTenTimeStamp;

/*  13位当前时间戳 */
+ (NSInteger)getThisMachineTheTimeStamp;

/* 13位当前时间戳 **/
+ (NSNumber *)getThirteenThisMachineTheTimeStamp;

/* 获取 网络 13位 时间戳 **/
+ (NSNumber *)getInternetThirteenTimeStamp;

/* 获取网络时间 **/
+ (NSDate *)getInternetDate;

/* 获取App对外版本号 **/
+ (NSString*)getAppVersion;

/* 获取BuiId版本号 **/
+ (NSString *)getBuiIdVersion;

/* 获取UUID **/
+ (NSString *)getUUIDString;

/* 获取当前设备系统版本 **/
+ (NSString *)getCurrentDeviceSystemVersionString;

/* 获取当前设备型号 **/
+ (NSString *)getCurrentDeviceModel;

/* 文字转语音播报 **/
+ (void)theCustomVoiceBroadcast:(NSString *)speechString;

@end

NS_ASSUME_NONNULL_END
