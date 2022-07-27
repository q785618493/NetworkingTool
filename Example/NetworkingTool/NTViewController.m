//
//  NTViewController.m
//  NetworkingTool
//
//  Created by 785618493@qq.com on 07/27/2022.
//  Copyright (c) 2022 785618493@qq.com. All rights reserved.
//

#import "NTViewController.h"

#import "WYNetworkingTool.h"

@interface NTViewController ()

@end

@implementation NTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self createView];
}

- (void)createView {
    self.title = @"title";
    
    [WYNetworkingTool GET:@"https://live.maozhuazb.com/Room/HotLiveApple?type=0&useridx=63092319&page=1" parameters:nil headers:nil isHeadersBool:false isHudBool:true success:^(id JSON) {
        WY_LOG(@" 获取主播列表数据JSON == %@ ", [WYGeneralTools nativeDataParseJson:JSON]);
    } failure:^(NSError *error) {
        WY_LOG(@" 获取主播列表数据Error == %@ ", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
