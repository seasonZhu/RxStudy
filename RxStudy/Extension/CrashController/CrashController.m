//
//  CrashController.m
//  DCZLApp
//
//  Created by dy on 2023/3/16.
//

#import "CrashController.h"
#import "Rxstudy-bridging-Header.h"

@interface CrashController ()

@end

@implementation CrashController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    /// 通过宏来完成OC的guard方法
    guard(self.navigationController) else { return; }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [button setTitle:@"Crash Button" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    button.center = self.view.center;
    [self.view addSubview:button];
}

@end
