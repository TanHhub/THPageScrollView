//
//  PageViewController.m
//  PageDemo
//
//  Created by SolorDreams on 2018/11/18.
//  Copyright © 2018年 SolorDreams. All rights reserved.
//

#import "PageViewController.h"

#import "ListViewController.h"
#import "THPageScrollView.h"

@interface PageViewController ()<THPageScrollViewDelegate,THPageScrollViewDataSource>


@property (nonatomic, strong) THPageScrollView *pageView;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIView *barView;

@property (nonatomic, strong) NSMutableArray <ListViewController *>* controllers;;

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    UIScrollView *dd =[UIScrollView new];
    [self.view addSubview:dd];
    self.view.backgroundColor = [UIColor yellowColor];
    self.controllers = [NSMutableArray new];
    [self addchilds];
    self.header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 160)];
    _header.backgroundColor = [UIColor redColor];
    
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    _barView.backgroundColor = [UIColor brownColor];
    
    self.pageView = [[THPageScrollView alloc] initWithFrame:CGRectMake(0, 94, self.view.bounds.size.width, 600)];
    self.pageView.pageHeaderViewHeight = 160;
    self.pageView.pageBarHeight = 40;
    self.pageView.pageBarScrollEnable = YES;
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    self.pageView.defaultSeletedIndex = 0;
    [self.view addSubview:self.pageView];
    [self.pageView reloadData];
    
    [self addButton];
   
    // Do any additional setup after loading the view.
}

- (void)addButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"改变高度" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickChange:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *batItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = batItem;
}

- (void)clickChange:(UIButton *)sender
{
//    NSInteger tempHeight = arc4random()%500 + 100;
//    [self.pageView updateHeaderViewHeight:tempHeight animated:YES];
    [self.pageView reloadData];
//    [self.pageView setSeleteViewWithIndex:self.pageView.currentItemIndex+1 animated:YES];
}


- (void)pageScrollView:(THPageScrollView *)page horizontalScrollViewEndScrollIndex:(NSInteger)currentIndex
{
    NSLog(@"%ld",currentIndex);
}

- (NSUInteger)numberOfChildControllersInPageView:(THPageScrollView *)pageView
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
    for (NSInteger i = 0;i<5;i++) {
        ListViewController *list = [[ListViewController alloc] init];
        [self addChildViewController:list];
        [self.controllers addObject:list];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
