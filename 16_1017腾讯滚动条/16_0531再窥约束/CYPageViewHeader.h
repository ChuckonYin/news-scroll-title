//
//  CYPageViewHeader.h
//  16_0531再窥约束
//
//  Created by yinxukun on 2016/10/17.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CYScreenWidth [[UIScreen mainScreen] bounds].size.width

@protocol CYPageViewHeaderDelegate <NSObject>

- (void)CYPageViewHeaderTapTitle:(NSInteger)toIndex;

@end

@interface CYPageViewHeader : UIView

//滚动条
@property (nonatomic, strong) UIView *moveLine;
//标题栏
@property (nonatomic, strong, readonly) NSMutableArray <UILabel *> *titleLabs;
//标题
@property (nonatomic, strong, readwrite) NSArray <NSString *>*titles;
//标题间距 default 15
@property (nonatomic, assign) CGFloat gapWidth;
//头宽 default ScreenWidth
@property (nonatomic, assign, readwrite) CGFloat headerWidth;
//page宽 default ScreenWidth
@property (nonatomic, assign, readwrite) CGFloat pageWidth;
//滚动条尺寸 default size(20, 4)
@property (nonatomic, assign) CGSize moveLineSize;

@property (nonatomic, weak) id<CYPageViewHeaderDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger currentIndex;

//R/G/B   1 1 1 1;
@property (nonatomic, strong) NSArray <NSNumber *> *highLightColors;
@property (nonatomic, strong) NSArray <NSNumber *> *defaultColors;

@property (nonatomic, strong, readonly) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSArray <UIViewController *>*pageViewControllers;

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray <NSString *>*)titles
          pageViewControllers:(NSArray <UIViewController *>*)pageViewControllers
                 defaultColor:(NSArray <NSNumber *> *)defaultColors
               highLightColor:(NSArray <NSNumber *> *)highLightColors;

@end
