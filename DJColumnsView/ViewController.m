//
//  ViewController.m
//  DJColumnsView
//
//  Created by 一维 on 2017/6/21.
//  Copyright © 2017年 LeePersen. All rights reserved.
//

#import "ViewController.h"
#import "DJColumnsView.h"
@interface ViewController () <DJColumnsViewDelegate>
@property(nonatomic,strong) DJColumnsView *columnsView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.columnsView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.columnsView reloadData];
}

- (UIView *)columnsView
{
    if (!_columnsView) {
        _columnsView = [[DJColumnsView alloc] initWithFrame:self.view.bounds];
        _columnsView.columnsViewDelegate = self;
    }
    return _columnsView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numbersOfItem
{
    return 50;
}

- (NSString *)itemTitleAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"项目%li",index];
}

- (BOOL)canMoveItemAtIndex:(NSInteger)index
{
    return index % 3;
}

- (void)didFinishSortWithOrderArray:(NSArray *)array
{
    NSLog(@"%@",[array description]);
}

@end
