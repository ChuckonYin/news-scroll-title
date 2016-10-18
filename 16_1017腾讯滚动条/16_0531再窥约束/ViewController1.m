//
//  ViewController1.m
//  16_0531再窥约束
//
//  Created by yinxukun on 16/9/12.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

#import "ViewController1.h"

@interface ViewController1 ()

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:[self arcFloat] green:[self arcFloat] blue:[self arcFloat] alpha:1.0];
}

- (CGFloat)arcFloat{
    return (CGFloat)(arc4random()%10)/10.0;
}

@end
