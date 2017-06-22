//
//  DJColumnsView.h
//  DJColumnsView
//
//  Created by 一维 on 2017/6/21.
//  Copyright © 2017年 LeePersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DJColumnsViewDelegate <NSObject>
@required
- (NSInteger)numbersOfItem;
@optional
- (BOOL)canMoveItemAtIndex: (NSInteger)index;
//配置item 标题
- (NSString *)itemTitleAtIndex: (NSInteger)index;
//配置item appearance
- (void)configureItem: (UILabel *)label AtIndex: (NSInteger)index;
//配置item 背景视图
- (void)configureItemBackground: (UIView *)view atIndex: (NSInteger)index;
//结束移动后item的顺序
- (void)didFinishSortWithOrderArray: (NSArray *)array;
@end

@interface DJColumnsView : UIScrollView
@property(nonatomic,assign) CGSize itemSize;
@property(nonatomic,assign) CGFloat itemSpacing;
@property(nonatomic,assign) UIEdgeInsets inset;
@property(nonatomic,assign) CGFloat lineSpacing;
@property(nonatomic,weak) id<DJColumnsViewDelegate> columnsViewDelegate;
- (void)reloadData;
@end
