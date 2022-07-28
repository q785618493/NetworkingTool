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

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation NTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self createView];
}

- (void)createView {
    self.title = @"title";
    
    __weak typeof(self) ws = self;
    [WYNetworkingTool GET:@"https://live.maozhuazb.com/Room/HotLiveApple?type=0&useridx=63092319&page=1" parameters:nil headers:nil isHeadersBool:false isHudBool:true success:^(id JSON) {
        NSString *dataString = [WYGeneralTools nativeDataParseJson:JSON];
        WY_LOG(@" 获取主播列表数据JSON == %@ ", dataString);
        ws.textView.text = dataString;
    } failure:^(NSError *error) {
        WY_LOG(@" 获取主播列表数据Error == %@ ", error);
        ws.textView.text = error.localizedDescription;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
