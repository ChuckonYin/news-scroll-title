//
//  CYPageViewHeader.m
//  16_0531再窥约束
//
//  Created by yinxukun on 2016/10/17.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

#import "CYPageViewHeader.h"
#import <Masonry.h>

const CGFloat fastPercent = 0.5;

@interface CYPageViewHeader ()<UIScrollViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSMutableArray <UILabel *> *titleLabs;

@property (nonatomic, assign) NSInteger currentIndex;

//标题间距
@property (nonatomic, strong) NSMutableArray <NSNumber *>*distances;

@property (nonatomic, assign) BOOL animating;

@property (nonatomic, strong) UIPageViewController *pageViewController;

@end

@implementation CYPageViewHeader

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray <NSString *>*)titles
          pageViewControllers:(NSArray <UIViewController *>*)pageViewControllers
                 defaultColor:(NSArray <NSNumber *> *)defaultColors
               highLightColor:(NSArray <NSNumber *> *)highLightColors{
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.pageViewControllers = pageViewControllers;
        self.defaultColors = defaultColors;
        self.highLightColors = highLightColors;
        self.gapWidth = 15.0;
        self.pageWidth = CYScreenWidth;
        self.moveLineSize = CGSizeMake(20, 4);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self cy_initUI];
        });
    }
    return self;
}


#pragma mark - UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSInteger index = [self.pageViewControllers indexOfObject:viewController];
    if (index==0) {
        return nil;
    }
    else{
        return self.pageViewControllers[index-1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSInteger index = [self.pageViewControllers indexOfObject:viewController];
    if (index==self.pageViewControllers.count-1) {
        return nil;
    }
    else{
        return self.pageViewControllers[index+1];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    NSInteger toIndex = [self.pageViewControllers indexOfObject:self.pageViewController.viewControllers[0]];
    self.currentIndex = toIndex;
    //手势滑动页面后调整标题
    [self cy_adjustTitleOffSet:toIndex];
}

#pragma mark - UIScrollDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self cy_adjustTitleOffSet];
    [self scrollDidScroll:scrollView];
}

#pragma mark - private

- (void)cy_initUI{
    __weak typeof(self) weakself = self;
    
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.scrollView);
        make.height.equalTo(weakself.scrollView);
    }];
    //添加标题栏
    [self.titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *titleLab = [self cy_titleLab:obj];
        [self.contentView addSubview:titleLab];
        [self.titleLabs addObject:titleLab];
        if (idx == 0) {
            UIColor *highLightColor = [UIColor colorWithRed:self.highLightColors[0].floatValue green:self.highLightColors[1].floatValue  blue:self.highLightColors[2].floatValue  alpha:1];
            titleLab.textColor = highLightColor;
            [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakself.contentView).offset(15);
                make.centerY.equalTo(weakself.contentView);
            }];
        }
        else{
            [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(weakself.contentView);
                make.left.equalTo(weakself.titleLabs[idx-1].mas_right).offset(15);
            }];
        }
        if (idx == weakself.titles.count-1) {
            [weakself.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(titleLab).offset(15);
            }];
        }
    }];
    //添加滚动条
    [self addSubview:self.moveLine];
    [self.moveLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.titleLabs[0]);
        make.top.equalTo(weakself.titleLabs[0].mas_bottom).offset(5);
        make.size.mas_equalTo(weakself.moveLineSize);
    }];
}

- (void)cy_titleTap:(UITapGestureRecognizer *)tap{
    UILabel *tapTitleLab = (UILabel *)tap.view;
    NSInteger toIndex = [self.titleLabs indexOfObject:tapTitleLab];
    [self scrollToIndex:toIndex animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(CYPageViewHeaderTapTitle:)]) {
        [self.delegate CYPageViewHeaderTapTitle:toIndex];
    }
    [self.pageViewController setViewControllers:@[self.pageViewControllers[toIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
    }];
}

//初始化单个标题
- (UILabel *)cy_titleLab:(NSString *)title{
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = title;
    titleLab.userInteractionEnabled = YES;
    [titleLab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cy_titleTap:)]];
    titleLab.textColor = [UIColor colorWithRed:self.defaultColors[0].floatValue green:self.defaultColors[1].floatValue blue:self.defaultColors[2].floatValue alpha:1];
    return titleLab;
}

- (void)cy_adjustTitleOffSet:(NSInteger)toIndex{
    UIView *toLabel = self.titleLabs[toIndex];
    CGFloat offX = CGRectGetMidX(toLabel.frame) - self.frame.size.width/2.0;
    if (offX<=0){
        offX = 0;
    }
    if (offX>=self.scrollView.contentSize.width-self.frame.size.width){
        offX = self.scrollView.contentSize.width-self.frame.size.width;
    }
    [self.scrollView setContentOffset:CGPointMake(offX, 0) animated:YES];
}

- (void)scrollDidScroll:(UIScrollView *)scrollView{
    //动画执行中
    if (self.animating) return;
    //偏移量  -1~1
    CGFloat offPercent = (scrollView.contentOffset.x - self.pageWidth)/self.pageWidth;
    if (self.currentIndex==0 && offPercent<=0) {
        return;
    }
    if (self.currentIndex==self.titles.count-1 && offPercent>=0) {
        return;
    }
    //调整当前和左侧文字颜色
    self.titleLabs[self.currentIndex].textColor = [self gradientDefaultColor:offPercent];
    if (offPercent<0) {
        self.titleLabs[self.currentIndex-1].textColor = [self gradientHighLightColor:offPercent];
    }
    //调整当前和右侧文字颜色{
    else{
        self.titleLabs[self.currentIndex+1].textColor = [self gradientHighLightColor:offPercent];
    }
    CGFloat startDistance = 0;
    CGFloat endDistance = 0;
    //右滑
    if (offPercent>0) {
        //快速滑行长度 0.5的偏移量滑完
        CGFloat fastDistace = self.distances[self.currentIndex].floatValue - self.moveLineSize.width/2.0;
        //慢速滑行长度 0.5的偏移量滑完
        CGFloat slowDistace = self.moveLineSize.width/2.0;
        if (offPercent<fastPercent) {
            //右滑半屏以前
            //起始端
            startDistance = (offPercent)/fastPercent*fastDistace;
            //终止端
            endDistance = offPercent/(1-fastPercent)*slowDistace;
        }
        else{
            //右滑半屏以后
            startDistance = fastDistace + (offPercent-fastPercent)/(1-fastPercent)*slowDistace;
            endDistance = slowDistace + (offPercent-(1-fastPercent))/fastPercent*fastDistace;
        }
    }
    //左滑
    else{
        //快速滑行长度 0.8的偏移量滑完
        CGFloat fastDistace = self.distances[self.currentIndex-1].floatValue - self.moveLineSize.width/2.0;
        //慢速滑行长度 0.2的偏移量滑完
        CGFloat slowDistace = self.moveLineSize.width/2.0;
        if (offPercent>-fastPercent) {
            //左滑半屏以前
            startDistance = (offPercent)/fastPercent*fastDistace;
            endDistance = offPercent/(1-fastPercent)*slowDistace;
        }
        else{
            //左滑半屏以后
            startDistance = -fastDistace + (offPercent+fastPercent)/(1-fastPercent)*slowDistace;
            endDistance = -slowDistace + (offPercent+(1-fastPercent))/fastPercent*fastDistace;
        }
//        distance = self.distances[self.currentIndex-1].floatValue*offPercent;
    }
    
    NSLog(@"%f_____%f", offPercent, startDistance);
    
    __weak typeof(self) weakself = self;
    [self.moveLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.titleLabs[0].mas_bottom).offset(5);
        make.height.mas_equalTo(weakself.moveLineSize.height);
        UILabel *currentLabel = weakself.titleLabs[weakself.currentIndex];
        if (offPercent>0) {
            make.left.equalTo(currentLabel.mas_centerX).offset(-self.moveLineSize.width/2.0+endDistance);
            make.right.equalTo(currentLabel.mas_centerX).offset(self.moveLineSize.width/2.0+startDistance);
        }
        else{
            make.right.equalTo(currentLabel.mas_centerX).offset(self.moveLineSize.width/2.0+endDistance);
            make.left.equalTo(currentLabel.mas_centerX).offset(-self.moveLineSize.width/2.0+startDistance);
        }
    }];
}

- (void)scrollToIndex:(NSInteger)toIndex animated:(BOOL)animated{
    __weak typeof(self) weakself = self;
    self.currentIndex = toIndex;
    if (animated){
        self.animating = YES;
        [UIView animateWithDuration:0.20 animations:^{
            [self.moveLine mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(weakself.titleLabs[toIndex]);
                make.top.equalTo(weakself.titleLabs[0].mas_bottom).offset(5);
                make.size.mas_equalTo(weakself.moveLineSize);
            }];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.animating = NO;
            });
            [self setTitleLabelsColors:toIndex];
            [self cy_adjustTitleOffSet:toIndex];
        }];
    }
}

- (NSMutableArray<UILabel *> *)titleLabs{
    if (!_titleLabs) {
        _titleLabs = [[NSMutableArray alloc] init];
    }
    return _titleLabs;
}

- (UIView *)moveLine{
    if (!_moveLine) {
        _moveLine = [[UIView alloc] init];
//        _moveLine.backgroundColor = [UIColor redColor];
    }
    return _moveLine;
}

- (NSMutableArray *)distances{
    if (!_distances) {
        __weak typeof(self) weakself = self;
        _distances = [[NSMutableArray alloc] init];
        [self.titleLabs enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx<self.titleLabs.count-1) {
                UILabel *label1 = obj;
                UILabel *label2 = weakself.titleLabs[idx+1];
                CGFloat distance = CGRectGetMidX(label2.frame) - CGRectGetMidX(label1.frame);
                [weakself.distances addObject:@(distance)];
            }
        }];
    }
    return _distances;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIColor *)gradientDefaultColor:(CGFloat)percent{
    CGFloat r = self.defaultColors[0].floatValue + (1-ABS(percent))*(self.highLightColors[0].floatValue-self.defaultColors[0].floatValue);
    CGFloat g = self.defaultColors[1].floatValue + (1-ABS(percent))*(self.highLightColors[1].floatValue-self.defaultColors[1].floatValue);
    CGFloat b = self.defaultColors[2].floatValue + (1-ABS(percent))*(self.highLightColors[2].floatValue-self.defaultColors[2].floatValue);
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

- (UIColor *)gradientHighLightColor:(CGFloat)percent{
    CGFloat r = self.highLightColors[0].floatValue + (1-ABS(percent))*(self.defaultColors[0].floatValue-self.highLightColors[0].floatValue);
    CGFloat g = self.highLightColors[1].floatValue + (1-ABS(percent))*(self.defaultColors[1].floatValue-self.highLightColors[1].floatValue);
    CGFloat b = self.highLightColors[2].floatValue + (1-ABS(percent))*(self.defaultColors[2].floatValue-self.highLightColors[2].floatValue);
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

- (void)setDefaultColors:(NSArray<NSNumber *> *)defaultColors{
    _defaultColors = defaultColors;
    [self setTitleLabelsColors:0];
}

- (void)setHighLightColors:(NSArray<NSNumber *> *)highLightColors{
    _highLightColors = highLightColors;
    UIColor *highLightColor = [UIColor colorWithRed:highLightColors[0].floatValue green:highLightColors[1].floatValue  blue:highLightColors[2].floatValue  alpha:1];
    self.moveLine.backgroundColor = highLightColor;
    [self setTitleLabelsColors:0];
}

- (void)setTitleLabelsColors:(NSInteger)toIndex{
    if (self.highLightColors && self.defaultColors) {
        [self.titleLabs enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx==toIndex) {
                obj.textColor = [self gradientDefaultColor:0];
            }
            else{
                obj.textColor = [self gradientDefaultColor:1.0];
            }
        }];
    }
}

- (UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        [self.pageViewController setViewControllers:@[self.pageViewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        }];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        for (UIView *view in _pageViewController.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scroll = (UIScrollView *)view;
                scroll.delegate = self;
            }
        }
    }
    return _pageViewController;
}

@end
