//
//  ViewController.m
//  高德地图检索
//
//  Created by 张艳江 on 2018/7/6.
//  Copyright © 2018年 张艳江. All rights reserved.
//

#import "ViewController.h"
#import "ZYJGaodeMapController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    [btn setBackgroundColor:[UIColor blueColor]];
    [btn setTitle:@"地图" forState:0];
    [btn setTitleColor:[UIColor whiteColor] forState:0];
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}
- (void)clickBtn{
    
    ZYJGaodeMapController *gaodeMapVc = [ZYJGaodeMapController alloc];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:gaodeMapVc];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
