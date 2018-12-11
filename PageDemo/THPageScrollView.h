//
//  THPageScrollView.h
//  PageDemo
//
//  Created by SolorDreams on 2018/11/18.
//  Copyright © 2018年 SolorDreams. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THPageScrollView;

@protocol THPageScrollViewDelegate <NSObject>

@optional

- (void)pageScrollView:(THPageScrollView *)pageScrollView didScrollToIndex:(NSInteger)index;

/**
 scrollview delegate
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;


- (void)pageScrollView:(THPageScrollView *)page horizontalScrollViewBeginScrollIndex:(NSInteger)currentIndex;

- (void)pageScrollView:(THPageScrollView *)page horizontalScrollViewEndScrollIndex:(NSInteger)currentIndex;

- (void)pageScrollView:(THPageScrollView *)page horizontalScrollViewScrollOffsetX:(CGFloat)offsetX;

@end

@protocol THPageScrollViewDataSource <NSObject>

@required

/**
 子控制器的数量
 */
- (NSUInteger)numberOfChildControllersInPageView:(THPageScrollView *)pageView;

/**
 返回当前index 下的对应的view

 @param pageScrollView PageScrollView
 @param index index
 @return PageScrollView
 */
- (UIView *)pageScrollView:(THPageScrollView *)pageScrollView viewForItemAtIndex:(NSInteger)index;

/**
 返回当前index 下的对应的scrollview
 @param pageScrollView PageScrollView
 @param index index
 @return scrollview
 */

- (UIScrollView *)pageScrollView:(THPageScrollView *)pageScrollView scrollViewForItemAtIndex:(NSInteger)index;

@optional

/**
 头部view
 
 @return view
 */
- (UIView *)pageScrollViewHeaderView;

/**
 悬浮view
 
 @return view
 */
- (UIView *)pageScrollViewBarView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface THPageScrollView : UIView

@property (nonatomic, weak) id<THPageScrollViewDelegate>delegate;
@property (nonatomic, weak) id<THPageScrollViewDataSource>dataSource;

/**
 底层scrollview 可上下滚动
 */
@property (nonatomic, strong) UIScrollView *mainBackScrollView;

/**
 水平滑动的scrollview 的容器
 */
@property (nonatomic, strong) UIView *pageBackView;

/**
 水平滑动的scrollview
 */
@property (nonatomic, strong) UIScrollView *horizontalScrollView;

/**
 *  headerview.height
 */
@property (nonatomic, assign) CGFloat pageHeaderViewHeight;

/**
 悬浮view.height
 */
@property (nonatomic, assign) CGFloat pageBarHeight;

/**
 * 获取pageivew当前childView的index
 */
@property (nonatomic, readonly) NSInteger currentItemIndex;

/**
 默认选中index
 */
@property (nonatomic, assign) NSUInteger defaultSeletedIndex;

/**
 *  获取pageivew当前childView
 */
@property (nonatomic, readonly, strong) UIView * currentView;

/**
 *  showsVerticalScrollIndicator 
 */
@property (nonatomic, assign) BOOL showsVerticalScrollIndicator;

/**
 *  pageBarScrollEnable是否跟随滚动，默认为 YES;
 */
@property (nonatomic, assign) BOOL pageBarScrollEnable;

- (void)reloadData;

- (void)pageViewScrollToIndex:(NSInteger)index animated:(BOOL)animated;

- (void)updateHeaderViewHeight:(CGFloat)height animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
