//
//  THPageScrollView.m
//  PageDemo
//
//  Created by SolorDreams on 2018/11/18.
//  Copyright © 2018年 SolorDreams. All rights reserved.
//

#import "THPageScrollView.h"
#import "UIView+THExtentsion.h"
#import <objc/runtime.h>

@interface UIScrollView (THPageScroollViewExtension)

@property (nonatomic, assign) NSInteger thPageScrollIndex;

@end

@implementation UIScrollView (THPageScroollViewExtension)

- (void)setThPageScrollIndex:(NSInteger)thPageScrollIndex
{
    objc_setAssociatedObject(self, @selector(thPageScrollIndex), @(thPageScrollIndex), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)thPageScrollIndex {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    return number.integerValue;
}

@end

@interface THPageScrollView() <UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat kWidth;
@property (nonatomic, assign) CGFloat kHeight;

@property (nonatomic, assign) NSUInteger pageViewsCount;
@property (nonatomic, assign) NSUInteger selectedIndex;;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *allViewsHeightCache;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *offsetsCache;
@property (nonatomic, strong) NSMutableArray *scrollViewObserverCache;

@property (nonatomic, strong) NSMutableDictionary <NSString *, UIView *> *childViews;//controller.view
@property (nonatomic, strong) NSMutableDictionary <NSString *, UIScrollView *> *subscrollViews; //sub scrollview

@property (nonatomic, assign) BOOL isInScrolling;
@property (nonatomic, assign) CGFloat lastOffsetY;

@end

@implementation THPageScrollView

- (void)dealloc{
    [self removeScrollViewObservers];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedIndex = 0;
        self.defaultSeletedIndex = 0;
        self.kWidth = self.frame.size.width;
        self.kHeight = self.frame.size.height;
        self.pageBarScrollEnable = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedIndex = 0;
        self.defaultSeletedIndex = 0;
        self.kWidth = self.frame.size.width;
        self.kHeight = self.frame.size.height;
        self.pageBarScrollEnable = YES;
    }
    return self;
}

#pragma mark ____________________________________
#pragma mark remove scrollview.observer
- (void)removeScrollViewObservers {
    
    for (NSInteger i = _scrollViewObserverCache.count-1;i>=0;i--) {
        UIView *sub = _scrollViewObserverCache[i];
        if (sub && [sub isKindOfClass:[UIScrollView class]]) {
            [sub removeObserver:self forKeyPath:@"contentSize"];
            [_scrollViewObserverCache removeObject:sub];
        }
    }
}

#pragma mark add scrollView.observer

- (void)safeAddObserver:(UIScrollView *)scrollView index:(NSInteger)index
{
    if (scrollView == nil || ![scrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    if (![self.scrollViewObserverCache containsObject:scrollView]) {
        scrollView.thPageScrollIndex = index;
        [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];//context: in iOS 8 ,sompe codition will cause crash,so use thPageScrollIndex to distinguish scrollView
        [self.scrollViewObserverCache addObject:scrollView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            if ([[self.subscrollViews allValues] containsObject:scrollView]) {
                NSInteger index = scrollView.thPageScrollIndex;
                [self updateContentSize:scrollView.contentSize index:index];
            }
        }
    }
}

 #pragma mark update scrollview.contentsize

- (void)updateContentSize:(CGSize)size index:(NSInteger)index {
    if (size.height <= 0) {
        self.offsetsCache[index] = @(0);
    }
    
    CGSize contentSize = size;
  
    contentSize.height = contentSize.height + self.pageHeaderViewHeight + self.pageBarHeight;
    //mainBackScrollView'min contentsize
    CGFloat minContentSizeHeight = self.kHeight + self.pageHeaderViewHeight + self.pageBarHeight;
    if (contentSize.height < minContentSizeHeight) {
        contentSize.height = minContentSizeHeight;
    }
    self.allViewsHeightCache[index] = @(contentSize.height);
    
    if ([self localIndex]!= index) {
        return;
    }
    
    self.mainBackScrollView.contentSize = contentSize;
}

#pragma mark reset
- (void)reloadData
{
    //clear scrollView's observer
    [self removeScrollViewObservers];
    
    //remove subviews if have
    [self clearAllSubViews];
    NSAssert(self.dataSource != nil, @"pageView.datasource can't be nil !!!");
    
    self.pageViewsCount = [self.dataSource numberOfChildViewsInPageView:self];
    if (self.pageViewsCount < 1) {
        return;
    }
    
    //add mainscrollview,backview,horizontalScrollView
    [self setUpSubViews];
    
    //if horizontalScrollView has not scroll use the defaultSeletedIndex
    if (self.defaultSeletedIndex > 0 && self.defaultSeletedIndex < self.pageViewsCount) {
        self.selectedIndex = self.defaultSeletedIndex;
    }
    //add currentIndex's itemView
    [self setUpCurrentIndexView];
    
    //reset scrollview.offset
    [self resetContetnOffset];
    
    if (self.selectedIndex > 0) {
        [self.horizontalScrollView setContentOffset:CGPointMake(self.kWidth * self.selectedIndex, 0) animated:NO];
    }
    
    [self layoutIfNeeded];
}

//add mainscrollView, horizontalScrollView,pageHeadrView,pagebarView
- (void)setUpSubViews
{
    self.horizontalScrollView.contentSize = CGSizeMake(self.kWidth * self.pageViewsCount, 0);
    
    [self initOffsetCache];
    
    [self addSubview:self.mainBackScrollView];
    
    [self.mainBackScrollView addSubview:self.pageBackView];
    [self.pageBackView addSubview:self.horizontalScrollView];
    
    self.pageBarView = [self.dataSource pageScrollViewBarView];
    self.pageHeaderView = [self.dataSource pageScrollViewHeaderView];
    
    if (_pageHeaderView && self.pageHeaderViewHeight > 0) {
        [self.mainBackScrollView addSubview:_pageHeaderView];
    }
    
    if (_pageBarView) {
        _pageBarView.frame = CGRectMake(0, self.pageHeaderViewHeight, self.kWidth, self.pageBarHeight);
        [self.mainBackScrollView addSubview:_pageBarView];
    }
}



- (void)setUpCurrentIndexView
{

    //use viewForItemAtIndex first
    UIView *atIndexView = [self.dataSource pageScrollView:self viewForItemAtIndex:self.selectedIndex];
    UIScrollView *atIndexScrollView = [self.dataSource pageScrollView:self scrollViewForItemAtIndex:self.selectedIndex];
    
    if (atIndexView) {
        [self.childViews setObject:atIndexView forKey:[NSString stringWithFormat:@"%lu",(unsigned long)self.selectedIndex]];
        [self.horizontalScrollView addSubview:atIndexView];
        // if atIndexView is UITableViewController.view,UITableViewController.tableView.frame change as atIndexView
        //will display out off screen
        atIndexView.frame = CGRectMake(self.kWidth * self.selectedIndex, 0, self.kWidth, self.kHeight);
        
        if (atIndexScrollView != nil && [atIndexScrollView isKindOfClass:[UIScrollView class]]) {
            atIndexScrollView.scrollEnabled = NO;
            [self.subscrollViews setObject:atIndexScrollView forKey:[NSString stringWithFormat:@"%lu",(unsigned long)self.selectedIndex]];
            [self safeAddObserver:atIndexScrollView index:self.selectedIndex];
        }
    } else {
        if (atIndexScrollView != nil && [atIndexScrollView isKindOfClass:[UIScrollView class]]) {
            atIndexScrollView.scrollEnabled = NO;
            [self.subscrollViews setObject:atIndexScrollView forKey:[NSString stringWithFormat:@"%lu",(unsigned long)self.selectedIndex]];
            [self.horizontalScrollView addSubview:atIndexScrollView];
            atIndexScrollView.frame = CGRectMake(self.kWidth * self.selectedIndex, 0, self.kWidth, self.kHeight);
            [self safeAddObserver:atIndexScrollView index:self.selectedIndex];
        } else {
            NSLog(@"viewForItemAtIndex and scrollViewForItemAtIndex return nil!");
        }
    }
}

- (void)clearAllSubViews
{
    [_childViews removeAllObjects];
    [_subscrollViews removeAllObjects];
    for (UIView *aview in _horizontalScrollView.subviews) {
        [aview removeFromSuperview];
    }
}

- (void)initOffsetCache
{
    [self.allViewsHeightCache removeAllObjects];
    [self.offsetsCache removeAllObjects];

    NSNumber *initHeight = [NSNumber numberWithFloat:self.kHeight + self.pageHeaderViewHeight + self.pageBarHeight];
    
    for (NSInteger i = 0; i < self.pageViewsCount; i ++) {
        [self.allViewsHeightCache addObject:initHeight];
    }
    
    for (NSInteger i = 0; i < self.pageViewsCount; i ++) {
        [self.offsetsCache addObject:@(0)];
    }
}

//设置mainBackScrollView及当前选中的scrollView为初始状态
- (void)resetContetnOffset
{
    [self.mainBackScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
  
    UIScrollView *currentScrollView = [self.subscrollViews valueForKey:[NSString stringWithFormat:@"%lu",(unsigned long)self.selectedIndex]];
    if (currentScrollView && [currentScrollView isKindOfClass:[UIScrollView class]]) {
        [currentScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

#pragma mark -- 改变pageHeadrView.height
- (void)updateHeaderViewHeight:(CGFloat)height animated:(BOOL)animated
{
    if (self.pageHeaderViewHeight == height) {
        return;
    }
    
    CGFloat tempOffsetY = self.pageHeaderViewHeight - height;
    CGSize contentSize = self.mainBackScrollView.contentSize;
    contentSize.height = contentSize.height - tempOffsetY;

    CGFloat minContentSizeHeight = self.kHeight + self.pageHeaderViewHeight + self.pageBarHeight;
    if (contentSize.height < minContentSizeHeight) {
        contentSize.height = minContentSizeHeight;
    }
    
    __weak typeof(self) weakSelf = self;
    //头部高度改变后，要更改缓存的所有view的高度，偏移量
    [_allViewsHeightCache enumerateObjectsUsingBlock:^(NSNumber*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat value = obj.floatValue;
        value = value - tempOffsetY;
        NSNumber *sNumber = [NSNumber numberWithFloat:value];
        [weakSelf.allViewsHeightCache replaceObjectAtIndex:idx withObject:sNumber];
    }];
    
    [_offsetsCache enumerateObjectsUsingBlock:^(NSNumber*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat value = obj.floatValue;
        value = value - tempOffsetY;
        NSNumber *sNumber = [NSNumber numberWithFloat:value];
        [weakSelf.offsetsCache replaceObjectAtIndex:idx withObject:sNumber];
    }];
    
    self.mainBackScrollView.contentSize = contentSize;
    [self.mainBackScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.15 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
            self.pageHeaderViewHeight = height;
            self.pageHeaderView.th_h = height;
            self.pageBarView.th_y = self.pageHeaderViewHeight;
            self.pageBackView.th_y = self.pageHeaderViewHeight+self.pageBarHeight;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.pageHeaderViewHeight = height;
        self.pageHeaderView.th_h = height;
        self.pageBarView.th_y = self.pageHeaderViewHeight;
        self.pageBackView.th_y = self.pageHeaderViewHeight+self.pageBarHeight;
    }
}

- (UIView *)loadCachedViewOrCreateOneAtIndex:(NSInteger)index
{
    UIView *cView = [self.childViews objectForKey:[NSString stringWithFormat:@"%ld", (long)index]];
    if (cView == nil) {
        cView = [self.dataSource pageScrollView:self viewForItemAtIndex:index];
        if (cView) {
            CGFloat w = self.kWidth;
            CGFloat h = self.kHeight;
            cView.frame = CGRectMake(index * w, 0, w, h);
            [self.horizontalScrollView addSubview:cView];
            [self.childViews setObject:cView forKey:[NSString stringWithFormat:@"%ld", (long)index]];
        }
    }
    return cView;
}

- (void)loadCachedScrollViewOrCreateOneAtIndex:(NSInteger)index needAddScroll:(BOOL)needAddScroll
{
    UIScrollView *ascrollview = [self.subscrollViews objectForKey:[NSString stringWithFormat:@"%ld", (long)index]];
    if (ascrollview == nil) {
        ascrollview = [self.dataSource pageScrollView:self scrollViewForItemAtIndex:index];
        if (ascrollview) {
            ascrollview.scrollEnabled = NO;
            [ascrollview setContentOffset:CGPointMake(0, 0)];
            [self safeAddObserver:ascrollview index:index];
            [self.subscrollViews setObject:ascrollview forKey:[NSString stringWithFormat:@"%ld", (long)index]];
            CGFloat w = self.kWidth;
            CGFloat h = self.kHeight;
            if (needAddScroll) {
                ascrollview.frame = CGRectMake(index * w, 0, w, h);
                [self.horizontalScrollView addSubview:ascrollview];
            }
            
            CGFloat sizeHeight = ascrollview.contentSize.height+self.pageHeaderViewHeight+self.pageBarHeight;
            NSNumber *oldHeight = self.allViewsHeightCache[index];
            if (oldHeight.floatValue < sizeHeight) {
                NSNumber *newHeight = [NSNumber numberWithFloat:sizeHeight];
                [self.allViewsHeightCache replaceObjectAtIndex:index withObject:newHeight];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _horizontalScrollView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollView:horizontalScrollViewScrollOffsetX:)]) {
            [self.delegate pageScrollView:self horizontalScrollViewScrollOffsetX:scrollView.contentOffset.x];
        }

        double per = scrollView.contentOffset.x / self.kWidth;
        self.defaultSeletedIndex = 0;
        int index = ceil(per);
        [self willBeginScrollPageView];
        if ((double)index != per) {
            return ;
        }
        
        UIView *selectedView = [self loadCachedViewOrCreateOneAtIndex:index];
        if (selectedView) {
            [self loadCachedScrollViewOrCreateOneAtIndex:index needAddScroll:NO];
        } else {
            [self loadCachedScrollViewOrCreateOneAtIndex:index needAddScroll:YES];
        }
    } else if (scrollView == _mainBackScrollView) {
        [self synScrollCurrentScrollview:scrollView withSelectedIndex:[self localIndex]];
        if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.delegate verticalScrollViewDidScroll:scrollView];
        }
    }
}

- (void)synScrollCurrentScrollview:(UIScrollView *)scrollView withSelectedIndex:(NSInteger)index {
    CGFloat y = scrollView.contentOffset.y;
    CGRect oframe = self.pageBackView.frame;
    NSLog(@"==== %f",y);
    if (y < 0) {
        
        self.pageHeaderView.th_y = 0;
        self.pageBarView.th_y = self.pageBarScrollEnable ? self.pageHeaderViewHeight : y;
        oframe.origin.y = self.pageHeaderViewHeight + self.pageBarHeight;
        self.pageBackView.frame = oframe;
        
        [self updateScrollViewOffsetY:0 atIndex:index];
        
    } else if (y >= 0 && y < self.pageHeaderViewHeight) {
        
        self.pageHeaderView.th_y = 0;
        self.pageBarView.th_y = self.pageBarScrollEnable ? self.pageHeaderViewHeight : y;
        self.pageBackView.th_y = self.pageHeaderViewHeight + self.pageBarHeight;
        
        [self updateScrollViewOffsetY:0 atIndex:index];
        
    } else if (y >= self.pageHeaderViewHeight) {
        
        self.pageBarView.th_y = self.pageBarScrollEnable ? y : y;
        self.pageBackView.th_y =  y + self.pageBarHeight;
        self.pageHeaderView.th_y = 0;
        
        [self updateScrollViewOffsetY:y - self.pageHeaderViewHeight atIndex:index];
    }
}

- (void)updateScrollViewOffsetY:(CGFloat)offset atIndex:(NSInteger)index
{
    UIScrollView *scrollView = [self.subscrollViews valueForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    if (scrollView && [scrollView isKindOfClass:[UIScrollView class]]) {
        [scrollView setContentOffset:CGPointMake(0, offset)];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (scrollView == _mainBackScrollView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
            [self.delegate verticalScrollViewWillBeginDragging:scrollView];
        }
    }
    
    if (scrollView == _horizontalScrollView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollView:horizontalScrollViewBeginScrollIndex:)]) {
            [self.delegate pageScrollView:self horizontalScrollViewBeginScrollIndex:[self localIndex]];
        }
        [self willBeginScrollPageView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate verticalScrollViewDidEndDecelerating:scrollView];
    }
    
    if (scrollView == _horizontalScrollView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollView:horizontalScrollViewEndScrollIndex:)]) {
            [self.delegate pageScrollView:self horizontalScrollViewEndScrollIndex:[self localIndex]];
        }
        [self didEndScrollPageView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == _horizontalScrollView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollView:horizontalScrollViewEndScrollIndex:)]) {
            [self.delegate pageScrollView:self horizontalScrollViewEndScrollIndex:[self localIndex]];
        }
        [self didEndScrollPageView];
    }
}

- (void)willBeginScrollPageView {
    if (_isInScrolling == NO) {
        _isInScrolling = YES;
        [self cacheCurrentIndexOffset];
        
        _lastOffsetY = self.mainBackScrollView.contentOffset.y;
        if (_lastOffsetY < self.pageHeaderViewHeight) {
            for (int i = 0; i< self.offsetsCache.count; i++) {
                self.offsetsCache[i] = @(0);
                [self synScrollCurrentScrollview:_mainBackScrollView withSelectedIndex:i];
            }
        }
    }
}

- (void)didEndScrollPageView{
    _isInScrolling = NO;
    
    NSInteger index = [self localIndex];
    
    self.mainBackScrollView.contentSize = CGSizeMake(0, [self.allViewsHeightCache[index] floatValue]);
    
    CGFloat currentY = [self.offsetsCache[index] floatValue];

    if (_lastOffsetY < self.pageHeaderViewHeight) {
        currentY = _lastOffsetY;
    } else if (_lastOffsetY >= self.pageHeaderViewHeight && currentY < self.pageHeaderViewHeight) {
        currentY = self.pageHeaderViewHeight;
    }
    
    [self.mainBackScrollView setContentOffset:CGPointMake(0, currentY)];
}

- (void)cacheCurrentIndexOffset
{
    NSInteger index = [self localIndex];
    self.allViewsHeightCache[index] = @(self.mainBackScrollView.contentSize.height);
    self.offsetsCache[index] = @(self.mainBackScrollView.contentOffset.y);
}

- (void)pageViewScrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index >= 0 && index < self.pageViewsCount) {
        if (animated) {
            [_horizontalScrollView setContentOffset:CGPointMake(self.kWidth*index, 0) animated:animated];
        } else {
            //animated == NO ,不能触发beginDragging
            [self willBeginScrollPageView];
            [_horizontalScrollView setContentOffset:CGPointMake(self.kWidth*index, 0)];
            [self didEndScrollPageView];
        }
    }
}

- (NSInteger)localIndex {
    NSInteger index = round(self.horizontalScrollView.contentOffset.x / self.horizontalScrollView.frame.size.width);
    self.selectedIndex = index;
    return index;
}

- (NSInteger)currentItemIndex
{
    return self.selectedIndex;
}

#pragma mark -- lazy
- (UIScrollView *)horizontalScrollView
{
    if (_horizontalScrollView == nil) {
        _horizontalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.kWidth, self.kHeight)];
        _horizontalScrollView.delegate                = self;
        _horizontalScrollView.backgroundColor        = [UIColor clearColor];
        _horizontalScrollView.pagingEnabled = YES;
        _horizontalScrollView.showsVerticalScrollIndicator = NO;
        _horizontalScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _horizontalScrollView;
}

- (UIScrollView *)mainBackScrollView
{
    if (_mainBackScrollView == nil) {
        _mainBackScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mainBackScrollView.delegate                = self;
        _mainBackScrollView.contentSize            = CGSizeMake(0, self.frame.size.height);
        _mainBackScrollView.backgroundColor        = [UIColor clearColor];
        _mainBackScrollView.showsVerticalScrollIndicator = self.showsVerticalScrollIndicator;
    }
    return _mainBackScrollView;
}

- (UIView *)pageBackView
{
    if (_pageBackView == nil) {
        _pageBackView = [[UIView alloc] initWithFrame:CGRectMake(0, self.pageHeaderViewHeight + self.pageBarHeight, self.kWidth, self.kHeight - self.pageBarHeight)];
    }
    return _pageBackView;
}

- (NSMutableDictionary<NSString *,UIView *> *)childViews
{
    if (_childViews == nil) {
        _childViews = [NSMutableDictionary dictionary];
    }
    return _childViews;
}

- (NSMutableDictionary<NSString *,UIScrollView *> *)subscrollViews
{
    if (_subscrollViews == nil) {
        _subscrollViews = [NSMutableDictionary dictionary];
    }
    return _subscrollViews;
}

- (NSMutableArray *)scrollViewObserverCache
{
    if (_scrollViewObserverCache == nil) {
        _scrollViewObserverCache = [NSMutableArray array];
    }
    return _scrollViewObserverCache;
}

- (NSMutableArray<NSNumber *> *)allViewsHeightCache
{
    if (_allViewsHeightCache == nil) {
        _allViewsHeightCache = [NSMutableArray new];
    }
    return _allViewsHeightCache;
}

- (NSMutableArray<NSNumber *> *)offsetsCache
{
    if (_offsetsCache == nil) {
        _offsetsCache = [NSMutableArray new];
    }
    return _offsetsCache;
}

@end
