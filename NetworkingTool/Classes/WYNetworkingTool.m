//
//  WYNetworkingTool.m
//  AFNetworking
//
//  Created by macWangYuan on 2022/7/27.
//

#import "WYNetworkingTool.h"

#import <objc/runtime.h>
#import <arpa/inet.h>
#import <Security/Security.h>

#import "SVProgressHUD.h"

NSString *const httpNoData = @"暂无更多数据,请稍后重试!";
NSString *const httpMessage = @"获取数据失败,请稍后重试!";
NSString *const httpError = @"服务器或网络异常,请稍后重试!";

@implementation WYFileModel

- (NSString *)keyName {
    if (!_keyName) {
        _keyName = @"multipartFiles";
    }
    return _keyName;
}

- (NSString *)mimeType {
    if (!_mimeType) {
        _mimeType = @"application/octet-stream";
    }
    return _mimeType;
}

/* xml text/xml
   json application/json
   PDF application/pdf
   超文本标记语言文本 .html,.html text/html
　　普通文本 .txt text/plain
　　RTF文本 .rtf application/rtf
　　GIF图形 .gif image/gif
   PNG图形 .png image/png
　　JPEG图形 .jpe,.jpeg,.jpg image/jpeg
　　au声音文件 .au audio/basic
　　MIDI音乐文件 mid,.midi audio/midi,audio/x-midi
   mp3音乐文件  .mp3 audio/mpeg
　　RealAudio音乐文件 .ra, .ram audio/x-pn-realaudio
　　MPEG文件 .mpg,.mpeg video/mpeg
   mp4/mpg4/m4v/mp4v video/mp4
　　AVI文件 .avi video/x-msvideo
　　GZIP文件 .gz application/x-gzip
　　TAR文件 .tar application/x-tar
 
 注：文件资源类型如果不知道，可以传万能类型application/octet-stream，服务器会自动解析文件类型
 **/

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        id fileData = dictionary[@"fileData"];
        if ([fileData isKindOfClass:[NSData class]]) {
            self.fileData = fileData;
        }
        
        id keyName = dictionary[@"keyName"];
        if ([keyName isKindOfClass:[NSString class]]) {
            self.keyName = keyName;
        }
        
        id fileName = dictionary[@"fileName"];
        if ([fileName isKindOfClass:[NSString class]]) {
            self.fileName = fileName;
        }
        
        id mimeType = dictionary[@"mimeType"];
        if ([mimeType isKindOfClass:[NSString class]]) {
            self.mimeType = keyName;
        }
    }
    return self;
}

#pragma mark - 生成文件名 根据 无"-"的UUID  extension扩展名 png,jgp,mp4等
+ (NSString *)generateFileNameAccordingUUIDAndExtension:(NSString *)extension {
    return [[self createUUIDString] stringByAppendingPathExtension:extension];
}

#pragma mark - 创建 无"-"的 UUID 字符串
+ (NSString *)createUUIDString {
    NSMutableString *muStr = [[NSMutableString alloc] initWithString:[[NSUUID UUID] UUIDString]];
    muStr = [NSMutableString stringWithString:[muStr stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    return muStr;
}

@end

static WYHttpToolSessionManager *manager;

static dispatch_once_t onceToken;

@implementation WYHttpToolSessionManager

+ (instancetype)sharedHttpToolSessionManager {
    
    dispatch_once(&onceToken, ^{
        manager = [[WYHttpToolSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_DOMAIN_URL]];
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        //最大并发数
        manager.operationQueue.maxConcurrentOperationCount = 26;
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/html", @"text/javascript", @"text/css", @"text/plain", @"application/x-javascript", @"text/html; charset=utf-8", @"image/gif", @"multipart/form-data", @"application/x-www-form-urlencoded", @"multipart/raw",  nil]];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        // 是否信任具有无效或过期SSL证书的服务器
        manager.securityPolicy.allowInvalidCertificates = true;
        [manager.securityPolicy setValidatesDomainName:false];
        
        // 设置超时时间
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 15.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
        [manager.requestSerializer setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"version"];
        [manager.requestSerializer setValue:CLIENT_CODE forHTTPHeaderField:@"clientCode"];
    });
    return manager;
}

#pragma mark 销毁单例
+ (void)tearDownSessionManager {
    onceToken = 0;
    manager = nil;
}

#pragma mark - 取消所有进行中的请求
+ (void)cancelAllRequest {
    WYHttpToolSessionManager *manager = [WYHttpToolSessionManager sharedHttpToolSessionManager];
    [manager.operationQueue cancelAllOperations];
    if (manager.tasks.count) {
        [manager.tasks makeObjectsPerformSelector:@selector(cancel)];
//        [manager invalidateSessionCancelingTasks:true];
    }
}

@end

@implementation WYNetworkingTool

+ (void)showIsHudBool:(BOOL)isHudBool {
    if (isHudBool) {
        [SVProgressHUD show];
    }
}

+ (void)hiddenIsHudBool:(BOOL)isHudBool  {
    if (isHudBool) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark -  HTTP GET 请求
+ (void)GET:(NSString *)urlString
 parameters:(nullable id)parameters
    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
isHeadersBool:(BOOL)isHeadersBool
  isHudBool:(BOOL)isHudBool
    success:(HttpSuccessBlock)success
    failure:(HttpFailureBlock)failure {
    
    if ([self currentConnectedToNetwork]) {
        if ([self checkCurrentProxySetting]) {
            
            [self showIsHudBool:isHudBool];
            
            WYHttpToolSessionManager *manager = [WYHttpToolSessionManager sharedHttpToolSessionManager];
            
            NSMutableDictionary *muHeadersDict = [[NSMutableDictionary alloc] initWithDictionary:headers];
            if (isHeadersBool) {
                
            }
        
            
            [manager GET:urlString parameters:parameters headers:muHeadersDict progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self hiddenIsHudBool:isHudBool];
                
                NSError *jsonError;
                id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    if (failure) {
                        failure(jsonError);
                    }
                }
                else if (success) {
                    // 登录失效
                    NSInteger codeInt = [data[@"code"] integerValue];
                    if (604 == codeInt) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginError" object:nil userInfo:@{@"type":@"1"}];
                    }
                    
                    success(data);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self hiddenIsHudBool:isHudBool];
                
                if (failure) {
                    failure(error);
                }
            }];
        }
        else {
            if (success) {
                success(@{@"code":@999, @"msg":@"当前网络不安全，请更换网络"});
            }
        }
    }
    else {
        if (success) {
            success(@{@"code":@998, @"msg":@"网络连接异常，请检查您的网络设置"});
        }
    }
}

#pragma mark -  HTTP POST 请求
+ (void)POST:(NSString *)urlString
  parameters:(nullable id)parameters
     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
isHeadersBool:(BOOL)isHeadersBool
   isHudBool:(BOOL)isHudBool
     success:(HttpSuccessBlock)success
     failure:(HttpFailureBlock)failure {
    
    if ([self currentConnectedToNetwork]) {
        if ([self checkCurrentProxySetting]) {
            
            [self showIsHudBool:isHudBool];
            
            WYHttpToolSessionManager *manager = [WYHttpToolSessionManager sharedHttpToolSessionManager];
            
            NSMutableDictionary *muHeadersDict = [[NSMutableDictionary alloc] initWithDictionary:headers];
            if (isHeadersBool) {
                
            }
            
            [manager POST:urlString parameters:parameters headers:muHeadersDict progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self hiddenIsHudBool:isHudBool];
                
                NSError *jsonError;
                id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    if (failure) {
                        failure(jsonError);
                    }
                }
                else if (success) {
                    // 登录失效
                    NSInteger codeInt = [data[@"code"] integerValue];
                    if (604 == codeInt) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginError" object:nil userInfo:@{@"type":@"1"}];
                    }
                    
                    success(data);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self hiddenIsHudBool:isHudBool];
                
                if (failure) {
                    failure(error);
                }
            }];
        }
        else {
            if (success) {
                success(@{@"code":@999, @"msg":@"当前网络不安全，请更换网络"});
            }
        }
    }
    else {
        if (success) {
            success(@{@"code":@998, @"msg":@"网络连接异常，请检查您的网络设置"});
        }
    }
}

#pragma mark -  HTTP PUT 请求
+ (void)PUT:(NSString *)urlString
 parameters:(nullable id)parameters
    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
isHeadersBool:(BOOL)isHeadersBool
  isHudBool:(BOOL)isHudBool
    success:(HttpSuccessBlock)success
    failure:(HttpFailureBlock)failure {
    
    if ([self currentConnectedToNetwork]) {
        if ([self checkCurrentProxySetting]) {
            
            [self showIsHudBool:isHudBool];
            
            WYHttpToolSessionManager *manager = [WYHttpToolSessionManager sharedHttpToolSessionManager];
            
            NSMutableDictionary *muHeadersDict = [[NSMutableDictionary alloc] initWithDictionary:headers];
            if (isHeadersBool) {
                
            }
            
            [manager PUT:urlString parameters:parameters headers:muHeadersDict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self hiddenIsHudBool:isHudBool];
                
                NSError *jsonError;
                id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    if (failure) {
                        failure(jsonError);
                    }
                }
                else if (success) {
                    // 登录失效
                    NSInteger codeInt = [data[@"code"] integerValue];
                    if (604 == codeInt) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginError" object:nil userInfo:@{@"type":@"1"}];
                    }
                    
                    success(data);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self hiddenIsHudBool:isHudBool];
                
                if (failure) {
                    failure(error);
                }
            }];
        }
        else {
            if (success) {
                success(@{@"code":@999, @"msg":@"当前网络不安全，请更换网络"});
            }
        }
    }
    else {
        if (success) {
            success(@{@"code":@998, @"msg":@"网络连接异常，请检查您的网络设置"});
        }
    }
    
}

#pragma mark -  HTTP DELETE 请求
+ (void)DELETE:(NSString *)urlString
    parameters:(nullable id)parameters
       headers:(nullable NSDictionary <NSString *, NSString *> *)headers
 isHeadersBool:(BOOL)isHeadersBool
     isHudBool:(BOOL)isHudBool
       success:(HttpSuccessBlock)success
       failure:(HttpFailureBlock)failure {
    
    if ([self currentConnectedToNetwork]) {
        if ([self checkCurrentProxySetting]) {
            
            [self showIsHudBool:isHudBool];
            
            WYHttpToolSessionManager *manager = [WYHttpToolSessionManager sharedHttpToolSessionManager];
            
            NSMutableDictionary *muHeadersDict = [[NSMutableDictionary alloc] initWithDictionary:headers];
            if (isHeadersBool) {
                
            }
            
//            manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
            
            [manager DELETE:urlString parameters:parameters headers:muHeadersDict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self hiddenIsHudBool:isHudBool];
                
                NSError *jsonError;
                id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    if (failure) {
                        failure(jsonError);
                    }
                }
                else if (success) {
                    // 登录失效
                    NSInteger codeInt = [data[@"code"] integerValue];
                    if (604 == codeInt) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginError" object:nil userInfo:@{@"type":@"1"}];
                    }
                    
                    success(data);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self hiddenIsHudBool:isHudBool];
                
                if (failure) {
                    failure(error);
                }
            }];
        }
        else {
            if (success) {
                success(@{@"code":@999, @"msg":@"当前网络不安全，请更换网络"});
            }
        }
    }
    else {
        if (success) {
            success(@{@"code":@998, @"msg":@"网络连接异常，请检查您的网络设置"});
        }
    }
}

#pragma mark -  HTTP POST 上传多文件 请求
+ (void)filePOST:(NSString *)urlString
      parameters:(nullable id)parameters
         headers:(nullable NSDictionary <NSString *, NSString *> *)headers
           files:(NSArray <WYFileModel *> *)filses
        progress:(nullable void (^)(NSProgress * _Nonnull))progress
   isHeadersBool:(BOOL)isHeadersBool
       isHudBool:(BOOL)isHudBool
         success:(HttpSuccessBlock)success
         failure:(HttpFailureBlock)failure {
    
    if ([self currentConnectedToNetwork]) {
        if ([self checkCurrentProxySetting]) {
            
            [self showIsHudBool:isHudBool];
            
            WYHttpToolSessionManager *manager = [WYHttpToolSessionManager sharedHttpToolSessionManager];
            
            NSMutableDictionary *muHeadersDict = [[NSMutableDictionary alloc] initWithDictionary:headers];
            if (isHeadersBool) {
                
            }
            
            [manager POST:urlString parameters:parameters headers:muHeadersDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
                for (WYFileModel *model in filses) {
                    [formData appendPartWithFileData:model.fileData name:model.keyName fileName:model.fileName mimeType:model.mimeType];
                }
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                if (progress) {
                    progress(uploadProgress);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self hiddenIsHudBool:isHudBool];
                
                NSError *jsonError;
                id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    if (failure) {
                        failure(jsonError);
                    }
                }
                else if (success) {
                    // 登录失效
                    NSInteger codeInt = [data[@"code"] integerValue];
                    if (604 == codeInt) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginError" object:nil userInfo:@{@"type":@"1"}];
                    }
                    
                    success(data);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self hiddenIsHudBool:isHudBool];
                
                if (failure) {
                    failure(error);
                }
            }];
        }
        else {
            if (success) {
                success(@{@"code":@999, @"msg":@"当前网络不安全，请更换网络"});
            }
        }
    }
    else {
        if (success) {
            success(@{@"code":@998, @"msg":@"网络连接异常，请检查您的网络设置"});
        }
    }
    
}

#pragma mark -  HTTP JSON参数请求
+ (void)JSON:(NSString *)urlString
  parameters:(nullable id)parameters
      method:(NSString *)method
     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
isHeadersBool:(BOOL)isHeadersBool
   isHudBool:(BOOL)isHudBool
     success:(HttpSuccessBlock)success
     failure:(HttpFailureBlock)failure {
    if ([self currentConnectedToNetwork]) {
        if ([self checkCurrentProxySetting]) {
            
            [self showIsHudBool:isHudBool];
            
            WYHttpToolSessionManager *manager = [WYHttpToolSessionManager sharedHttpToolSessionManager];
            
            NSMutableDictionary *muHeadersDict = [[NSMutableDictionary alloc] initWithDictionary:headers];
            if (isHeadersBool) {
                
            }

            NSMutableURLRequest *muRequest = [[AFJSONRequestSerializer serializer] requestWithMethod:method URLString:[NSString stringWithFormat:@"%@%@", BASE_DOMAIN_URL, urlString] parameters:parameters error:nil];
            [muRequest setTimeoutInterval:15.0f];
//            [muRequest addValue:@"raw" forHTTPHeaderField:@"Content-Type"];
            [muRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [muRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            
//            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
//            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//            [muRequest setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            
            [[manager dataTaskWithRequest:muRequest uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                [self hiddenIsHudBool:isHudBool];
                if (!error) {
                    NSError *postError;
                    id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&postError];
                    
                    if (postError) {
                        WY_LOG(@" POST-Error == %@ ", postError);
                    }
                    
    //                NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    //                WY_LOG(@" TWO == %@ ", string);
                    
                    NSInteger codeInt = [json[@"code"] integerValue];
                    if (604 == codeInt) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginError" object:nil userInfo:@{@"type":@"1"}];
                    }
                    
                    if (success) {
                        success(json);
                    }
                }
                else {
                    if (failure) {
                        failure(error);
                    }
                    WY_LOG(@" HTTP JSON 参数Error %@ == %@ ", urlString, error.localizedDescription);
                }
            }] resume];
            
        }
        else {
            if (success) {
                success(@{@"code":@999, @"msg":@"当前网络不安全，请更换网络"});
            }
        }
    }
    else {
        if (success) {
            success(@{@"code":@998, @"msg":@"网络连接异常，请检查您的网络设置"});
        }
    }
}

#pragma mark - 获取网络时间
+ (NSDate *)getInternetDate {
    NSString *urlString = @"https://www.baidu.com";
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:2];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    NSString *date = [[response allHeaderFields] objectForKey:@"Date"];
    date = [date substringFromIndex:5];
    date = [date substringToIndex:[date length] - 4];
    NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
    dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
//    [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss:SSS"];
    //    NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
    NSDate *netDate = [dMatter dateFromString:date];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:netDate];
    NSDate *localeDate = [netDate dateByAddingTimeInterval:interval];
    return localeDate;
}

#pragma mark - 当前网络状态 网络状态 1正常, 0没网异常
+ (NSInteger)currentConnectedToNetwork {
    if ([self getInternetDate]) {
        return 1;
    }

    return 0;
    
//    struct sockaddr_in zeroAddress;
//
//    bzero(&zeroAddress, sizeof(zeroAddress));
//
//    zeroAddress.sin_len = sizeof(zeroAddress);
//
//    zeroAddress.sin_family = AF_INET;
//
//    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
//
//    SCNetworkReachabilityFlags flags;
//
//    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
//
//    CFRelease(defaultRouteReachability);
//
//    if (!didRetrieveFlags) return 0;
//
//    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
//
//    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
//
//    return (isReachable && !needsConnection) ? 1 : 0;
}

#pragma mark - 检查当前代理设置 1安全 0设置了代理有抓包嫌疑
+ (NSInteger)checkCurrentProxySetting {
    // https://cdn.ddbes.com/ddbes.txt  https://www.baidu.com
    NSDictionary *proxySettings = (__bridge_transfer NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge_transfer NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSDictionary *settings = proxies[0];
    /*
     Possible values for kCFProxyTypeKey:
     kCFProxyTypeNone - no proxy should be used; contact the origin server directly
     kCFProxyTypeHTTP - the proxy is an HTTP proxy
     kCFProxyTypeHTTPS - the proxy is a tunneling proxy as used for HTTPS
     kCFProxyTypeSOCKS - the proxy is a SOCKS proxy
     kCFProxyTypeFTP - the proxy is an FTP proxy
     kCFProxyTypeAutoConfigurationURL - the proxy is specified by a proxy autoconfiguration (PAC) file
     */
    /** 当前的代理状态
     去广告的VPN == kCFProxyTypeAutoConfigurationURL
     默认--翻墙VPN == kCFProxyTypeNone
     **/
    NSString *typeString = [settings objectForKey:(NSString *)kCFProxyTypeKey];
    if ([typeString isEqualToString:@"kCFProxyTypeNone"] || [typeString isEqualToString:@"kCFProxyTypeAutoConfigurationURL"]) {
        return 1;
    }
    return 0;
}


@end
