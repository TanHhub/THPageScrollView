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

/**
 mainsScrollView scroll delegate
 */
- (void)verticalScrollViewDidScroll:(UIScrollView *_Nullable)scrollView;

- (void)verticalScrollViewWillBeginDragging:(UIScrollView *_Nullable)scrollView;

- (void)verticalScrollViewDidEndDecelerating:(UIScrollView *_Nullable)scrollView;

- (void)verticalScrollViewDidEndScrollingAnimation:(UIScrollView *_Nullable)scrollView;

/**
 horizontalScrollView begin to scroll

 @param page THPageScrollView
 @param currentIndex begin scroll's index
 */
- (void)pageScrollView:(THPageScrollView *_Nonnull)page horizontalScrollViewBeginScrollIndex:(NSInteger)currentIndex;

/**
 horizontalScrollView end scroll

 @param page THPageScrollView
 @param currentIndex end scroll 's index
 */
- (void)pageScrollView:(THPageScrollView *_Nonnull)page horizontalScrollViewEndScrollIndex:(NSInteger)currentIndex;


/**
 horizontalScrollView scrollWiewDidScroll

 @param page THPageScrollView
 @param offsetX horizontalScrollView.contentOffset.x
 */
- (void)pageScrollView:(THPageScrollView *_Nonnull)page horizontalScrollViewScrollOffsetX:(CGFloat)offsetX;

@end

@protocol THPageScrollViewDataSource <NSObject>

@required

/**
child views count
 */
- (NSUInteger)numberOfChildViewsInPageView:(THPageScrollView *_Nonnull)pageView;

/**
 view at index

 @param pageScrollView PageScrollView
 @param index index
 @return PageScrollView
 */
- (UIView *_Nonnull)pageScrollView:(THPageScrollView *_Nullable)pageScrollView viewForItemAtIndex:(NSInteger)index;

/**
 scroll view at index,used to observer the scrollView.contentSize,
 
 UITableView,UICollectionView,if "viewForItemAtIndex" returns nil, will add scrollView as subview,

 
 @param pageScrollView PageScrollView
 @param index index
 @return scrollview
 */

- (UIScrollView *_Nonnull)pageScrollView:(THPageScrollView *_Nullable)pageScrollView scrollViewForItemAtIndex:(NSInteger)index;

@optional

/**
 pageHeaderView
 
 @return view
 */
- (UIView *_Nullable)pageScrollViewHeaderView;

/**
 menubarView,floatingView
 
 @return view
 */
- (UIView *_Nullable)pageScrollViewBarView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface THPageScrollView : UIView

@property (nonatomic, weak) id<THPageScrollViewDelegate>delegate;

@property (nonatomic, weak) id<THPageScrollViewDataSource>dataSource;

/**
 main scrollview
 */
@property (nonatomic, strong) UIScrollView *mainBackScrollView;

/**
main back view
 */
@property (nonatomic, strong) UIView *pageBackView;

/**
horizontalScrollView
 */
@property (nonatomic, strong) UIScrollView *horizontalScrollView;

@property (nonatomic, weak) UIView *pageBarView;
@property (nonatomic, weak) UIView *pageHeaderView;

/**
 *  headerview.height
 */
@property (nonatomic, assign) CGFloat pageHeaderViewHeight;

/**
pageBarView.height
 */
@property (nonatomic, assign) CGFloat pageBarHeight;

@property (nonatomic, assign) NSUInteger defaultSeletedIndex;

@property (nonatomic, assign, readonly) NSInteger currentItemIndex;

/**
 mainScrollView.showsVerticalScrollIndicator,default is YES;
 */
@property (nonatomic, assign) BOOL showsVerticalScrollIndicator;

/**
 pageBarView scrollView with mainScrollView,default is YES;
 */
@property (nonatomic, assign) BOOL pageBarScrollEnable;

- (void)reloadData;

/**
 set pageScrollView select index

 @param index index
 @param animated animated
 */
- (void)pageViewScrollToIndex:(NSInteger)index animated:(BOOL)animated;

/**
 update HeaderView's heigt

 @param height height
 @param animated animated
 */
- (void)updateHeaderViewHeight:(CGFloat)height animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
