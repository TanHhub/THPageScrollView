//
//  ViewController.m
//  PageDemo
//
//  Created by SolorDreams on 2018/11/18.
//  Copyright © 2018年 SolorDreams. All rights reserved.
//

#import "ViewController.h"
#import "ListViewController.h"
#import "THPageScrollView.h"

@interface ViewController ()<THPageScrollViewDelegate,THPageScrollViewDataSource>

@property (nonatomic, strong) THPageScrollView *pageView;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIView *barView;

@property (nonatomic, strong) NSMutableArray <ListViewController *>* controllers;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addchilds];
    self.header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 160)];
    _header.backgroundColor = [UIColor redColor];
    
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    _barView.backgroundColor = [UIColor brownColor];
    
    self.pageView = [[THPageScrollView alloc] initWithFrame:CGRectMake(0, 94, self.view.bounds.size.width, 570)];
    self.pageView.pageHeaderViewHeight = 160;
    self.pageView.pageBarHeight = 40;
    self.pageView.pageBarScrollEnable = YES;
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    self.pageView.defaultSeletedIndex = 0;
    [self.view addSubview:self.pageView];
    [self.pageView reloadData];
    
    [self addButton];
}

- (void)addButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"change" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickChange:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *batItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = batItem;
}

- (void)clickChange:(UIButton *)sender
{
    NSInteger tempHeight = arc4random()%500 + 100;
    [self.pageView updateHeaderViewHeight:tempHeight animated:YES];
    //    [self.pageView reloadData];
    //    [self.pageView pageViewScrollToIndex:self.pageView.currentItemIndex + 1 animated:NO];
}


- (void)pageScrollView:(THPageScrollView *)page horizontalScrollViewEndScrollIndex:(NSInteger)currentIndex
{
    NSLog(@"%ld",currentIndex);
}

- (NSUInteger)numberOfChildViewsInPageView:(THPageScrollView *)pageView
{
    return 5;
}

- (UIView *)pageScrollViewHeaderView
{
    return self.header;
}

- (UIView *)pageScrollViewBarView {
    return self.barView;
}

- (UIView *)pageScrollView:(THPageScrollView *)pageView viewForItemAtIndex:(NSInteger)index
{
    UIView *subView = nil;
    if (index < 5) {
        ListViewController *controller = self.controllers[index];
        subView = controller.view;
    }
    
    return subView;
}

- (UIScrollView *)pageScrollView:(THPageScrollView *)pageView scrollViewForItemAtIndex:(NSInteger)index
{
    UIScrollView *subView = nil;
    if (index < 5) {
        ListViewController *controller = self.controllers[index];
        subView = controller.tableView;
    }
    
    return subView;
}

- (void)addchilds
{
    self.controllers = [NSMutableArray new];
    for (NSInteger i = 0;i<5;i++) {
        ListViewController *list = [[ListViewController alloc] init];
        list.iddsss = [NSString stringWithFormat:@"第%ld页",i];
        [self addChildViewController:list];
        [self.controllers addObject:list];
    }
}

@end
