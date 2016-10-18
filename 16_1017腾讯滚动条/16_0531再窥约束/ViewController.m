//
//  ViewController.m
//  16_0531再窥约束
//
//  Created by apple on 16/5/31.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "ViewController1.h"
#import "CYPageViewHeader.h"

@interface ViewController ()

@property (nonatomic, strong) CYPageViewHeader *pageHeader;

@property (nonatomic, strong) NSMutableArray <UIViewController *>*pageViewControllers;

@property (nonatomic, strong) NSArray <NSString *>*titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"腾讯视频";
    
    [self.view addSubview:self.pageHeader];
    
    [self.view addSubview:self.pageHeader.pageViewController.view];
    
    __weak typeof(self) weakself = self;
    [self.pageHeader.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakself.view);
        make.top.equalTo(weakself.pageHeader.mas_bottom);
    }];
}

#pragma mark - get & set

- (CYPageViewHeader *)pageHeader{
    if (!_pageHeader) {
        _pageHeader = [[CYPageViewHeader alloc] initWithFrame:CGRectMake(0, 64, CYScreenWidth, 50) titles:self.titles pageViewControllers:self.pageViewControllers defaultColor:@[@0, @0, @0] highLightColor:@[@0.1, @0.7, @0.2]];
    }
    return _pageHeader;
}

#pragma get & set

- (NSArray<NSString *> *)titles{
    return @[@"标题1", @"标题2", @"标题3", @"长标题1", @"更长标题2", @"超长的标题3", @"标题1", @"标题2", @"标题3"];
}

- (NSMutableArray<UIViewController *> *)pageViewControllers{
    if (!_pageViewControllers) {
        _pageViewControllers = [[NSMutableArray alloc] init];
        __weak typeof(self) weakself = self;
        [self.titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakself.pageViewControllers addObject:[[ViewController1 alloc] init]];
        }];
    }
    return _pageViewControllers;
}

@end




