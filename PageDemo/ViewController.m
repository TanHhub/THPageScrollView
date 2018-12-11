//
//  ViewController.m
//  PageDemo
//
//  Created by SolorDreams on 2018/11/18.
//  Copyright © 2018年 SolorDreams. All rights reserved.
//

#import "ViewController.h"
#import "PageViewController.h"
#import "ListViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gooog)];
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)gooog
{
    PageViewController *pageview = [[PageViewController alloc] init];
    [self.navigationController pushViewController:pageview animated:YES];
    
//    ListViewController *lll = [[ListViewController alloc] init];
//    [self.navigationController pushViewController:lll animated:YES];
}


@end
