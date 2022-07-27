//
//  WYGeneralTools.m
//  NetworkingTool
//
//  Created by macWangYuan on 2022/7/27.
//

#import "WYGeneralTools.h"

#import <AVFoundation/AVFoundation.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <sys/types.h>

@implementation WYGeneralTools

#pragma mark -  id数据 转 json
+ (NSString *)nativeDataParseJson:(id)obj {
    if ([obj isKindOfClass:[NSNull class]] || !obj) {
        return @"obj数据类型错误 或者 obj为nil";
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:&parseError];
    if (parseError) {
        return @"obj数据解析错误";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark -  json 转 id数据
+ (id)nativeDataWithJsonString:(NSString *)jsonString {
    if (![jsonString isKindOfClass:[NSString class]] || 0 == jsonString.length) {
        NSLog(@" JSON串数据类型错误 或者 JSON串为空 ");
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if (err) {
        NSLog(@"json解析失败Error == %@", err.localizedDescription);
        return nil;
    }
    return obj;
}

#pragma mark - 10位当前时间戳
+ (NSNumber *)getTenThisMachineTheTimeStamp {
    NSUInteger dateInt = [[NSDate date] timeIntervalSince1970];
    return [NSNumber numberWithInteger:dateInt];
}

#pragma mark - 获取 网络 10位 时间戳
+ (NSNumber *)getInternetTenTimeStamp {
    NSUInteger dateInt = [[self getInternetDate] timeIntervalSince1970];
    return @(dateInt);
}

#pragma mark - 13位当前时间戳
+ (NSInteger)getThisMachineTheTimeStamp {
    NSUInteger dateInt = [[NSDate date] timeIntervalSince1970] * 1000;
    return dateInt;
}

#pragma mark - 13位当前时间戳
+ (NSNumber *)getThirteenThisMachineTheTimeStamp {
    NSUInteger dateInt = [[NSDate date] timeIntervalSince1970] * 1000;
    return [NSNumber numberWithInteger:dateInt];
}

#pragma mark - 获取 网络 13位 时间戳
+ (NSNumber *)getInternetThirteenTimeStamp {
    NSUInteger dateInt = [[self getInternetDate] timeIntervalSince1970] * 1000;
    return @(dateInt);
}

#pragma mark - 获取网络时间
+ (NSDate *)getInternetDate {
    NSString *urlString = @"https://m.baidu.com";
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval: 2];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    NSString *date = [[response allHeaderFields] objectForKey:@"Date"];
    date = [date substringFromIndex:5];
    date = [date substringToIndex:[date length]-4];
    NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
    dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
    //    NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
    NSDate *netDate = [dMatter dateFromString:date];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: netDate];
    NSDate *localeDate = [netDate  dateByAddingTimeInterval: interval];
    return localeDate;
}

#pragma mark - 获取App对外版本号
+ (NSString*)getAppVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

#pragma mark - 获取BuiId版本号
+ (NSString *)getBuiIdVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

#pragma mark - 获取UUID
+ (NSString *)getUUIDString {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

#pragma mark - 获取当前设备系统版本
+ (NSString *)getCurrentDeviceSystemVersionString {
    return [[UIDevice currentDevice] systemVersion];
}

#pragma mark ----- 获取当前设备型号
+ (NSString *)getCurrentDeviceModel {
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone8,3"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6Plus";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6sPlus";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7Plus";
    if ([platform isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])    return @"iPhone 8Plus";
    if ([platform isEqualToString:@"iPhone10,5"])    return @"iPhone 8Plus";
    
    
    if ([platform isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    
    if ([platform isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";
    if ([platform isEqualToString:@"iPhone12,8"]) return @"iPhone SE 2020";
    
    if ([platform isEqualToString:@"iPhone13,1"]) return @"iPhone 12 mini";
    if ([platform isEqualToString:@"iPhone13,2"]) return @"iPhone 12";
    if ([platform isEqualToString:@"iPhone13,3"]) return @"iPhone 12 Pro";
    if ([platform isEqualToString:@"iPhone13,4"]) return @"iPhone 12 Pro Max";
    
    if ([platform isEqualToString:@"iPhone14,4"]) return @"iPhone 13 mini";
    if ([platform isEqualToString:@"iPhone14,5"]) return @"iPhone 13";
    if ([platform isEqualToString:@"iPhone14,2"]) return @"iPhone 13 Pro";
    if ([platform isEqualToString:@"iPhone14,3"]) return @"iPhone 13 Pro Max";
    
    return platform;
}

#pragma mark - 文字转语音播报
+ (void)theCustomVoiceBroadcast:(NSString *)speechString {
    //初始化语音播报
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    //设置播报的内容
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:speechString];
    //设置语言类别 中文
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice = voiceType;
    //设置播报语速 0.5 - 1
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    [synthesizer speakUtterance:utterance];
}


@end
