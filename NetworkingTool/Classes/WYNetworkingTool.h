//
//  WYNetworkingTool.h
//  AFNetworking
//
//  Created by macWangYuan on 2022/7/27.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

#import "WYGeneralTools.h"

#ifdef DEBUG // 开发阶段

/* 主域名URL地址 **/
#define BASE_DOMAIN_URL @"http://api.hclyz.com:81/mf/"

#define WY_LOG(FORMAT, ...) fprintf(stderr, "   %s     %d \n%s \n",[[[NSString stringWithUTF8String:__FILE__]lastPathComponent]UTF8String],__LINE__,[[NSString stringWithFormat:FORMAT,##__VA_ARGS__]UTF8String]);

#else // 发布阶段

/* 主域名URL地址 **/
#define BASE_DOMAIN_URL @"http://api.hclyz.com:81/mf/"

#define WY_LOG(...)

#endif

/* 内部版本号 1.0 code=1 每次发版加1  **/
#define CLIENT_CODE @"1"

@interface WYFileModel : NSObject

@property (strong, nonatomic) NSData *fileData;

@property (copy, nonatomic) NSString *keyName;

@property (copy, nonatomic) NSString *fileName;

@property (copy, nonatomic) NSString *mimeType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/* 生成文件名 根据 无"-"的UUID  extension扩展名png,jgp,mp4等 **/
+ (NSString *)generateFileNameAccordingUUIDAndExtension:(NSString *)extension;

/* 创建 无"-"的 UUID 字符串 **/
+ (NSString *)createUUIDString;

@end

@interface WYHttpToolSessionManager : AFHTTPSessionManager

+ (instancetype)sharedHttpToolSessionManager;

@end


typedef void(^HttpSuccessBlock)(id JSON);
typedef void(^HttpFailureBlock)(NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface WYNetworkingTool : NSObject

/* HTTP GET 请求 **/
+ (void)GET:(NSString *)urlString
 parameters:(nullable id)parameters
    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
isHeadersBool:(BOOL)isHeadersBool
  isHudBool:(BOOL)isHudBool
    success:(HttpSuccessBlock)success
    failure:(HttpFailureBlock)failure;

/* HTTP POST 请求 **/
+ (void)POST:(NSString *)urlString
  parameters:(nullable id)parameters
     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
isHeadersBool:(BOOL)isHeadersBool
   isHudBool:(BOOL)isHudBool
     success:(HttpSuccessBlock)success
     failure:(HttpFailureBlock)failure;

/* HTTP PUT 请求 **/
+ (void)PUT:(NSString *)urlString
 parameters:(nullable id)parameters
    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
isHeadersBool:(BOOL)isHeadersBool
  isHudBool:(BOOL)isHudBool
    success:(HttpSuccessBlock)success
    failure:(HttpFailureBlock)failure;

/* HTTP DELETE 请求 **/
+ (void)DELETE:(NSString *)urlString
    parameters:(nullable id)parameters
       headers:(nullable NSDictionary <NSString *, NSString *> *)headers
 isHeadersBool:(BOOL)isHeadersBool
     isHudBool:(BOOL)isHudBool
       success:(HttpSuccessBlock)success
       failure:(HttpFailureBlock)failure;

/* HTTP POST 上传多文件 请求 **/
+ (void)filePOST:(NSString *)urlString
      parameters:(nullable id)parameters
         headers:(nullable NSDictionary <NSString *, NSString *> *)headers
           files:(NSArray <WYFileModel *> *)filses
        progress:(nullable void (^)(NSProgress * _Nonnull))progress
   isHeadersBool:(BOOL)isHeadersBool
       isHudBool:(BOOL)isHudBool
         success:(HttpSuccessBlock)success
         failure:(HttpFailureBlock)failure;

/* HTTP JSON参数请求 **/
+ (void)JSON:(NSString *)urlString
  parameters:(nullable id)parameters
      method:(NSString *)method
     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
isHeadersBool:(BOOL)isHeadersBool
   isHudBool:(BOOL)isHudBool
     success:(HttpSuccessBlock)success
     failure:(HttpFailureBlock)failure;

/* 获取网络时间 **/
+ (NSDate *)getInternetDate;

/* 当前网络状态 1正常 0没网异常 **/
+ (NSInteger)currentConnectedToNetwork;

/* 检查当前代理设置 1安全 0设置了代理有抓包嫌疑 **/
+ (NSInteger)checkCurrentProxySetting;

@end

NS_ASSUME_NONNULL_END
