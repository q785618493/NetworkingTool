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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
