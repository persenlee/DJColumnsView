//
//  DJColumnsView.m
//  DJColumnsView
//
//  Created by 一维 on 2017/6/21.
//  Copyright © 2017年 LeePersen. All rights reserved.
//

#import "DJColumnsView.h"
@interface DJColumnsView()
{
    NSMutableArray *_itemsArray;
    NSInteger _numberOfItems;
    BOOL _enableMove;
    CGRect _blankFrame;
    UILabel *_targetLabel;
    NSInteger _currentIndex;
    //UI
    UIColor *_textColor;
    UIColor *_moveDisableTextColor;
    UIColor *_textBackgroundColor;
    UIColor *_textBorderColor;
    UIColor *_backgroundViewColor;
}
@end
@implementation DJColumnsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    _numberOfItems = 0;
    _itemSize = CGSizeMake(72, 25);
    _itemSpacing = 21;
    _lineSpacing = 15;
    _inset = UIEdgeInsetsMake(15, 12, 0, 12);
    _enableMove = YES;
    
    _textColor = [UIColor colorWithRed: (CGFloat)0xc6/0xff green: (CGFloat)0x35/0xff blue: (CGFloat)0x35/0xff alpha:1];
    _moveDisableTextColor = [UIColor colorWithRed: (CGFloat)0x66/0xff green: (CGFloat)0x66/0xff blue: (CGFloat)0x66/0xff alpha:1];
    _textBackgroundColor = [UIColor whiteColor];
    _textBorderColor = [UIColor colorWithRed: (CGFloat)0x99/0xff green: (CGFloat)0x99/0xff blue: (CGFloat)0x99/0xff alpha:1];
    _backgroundViewColor = [UIColor colorWithRed: (CGFloat)0xf3/0xff green: (CGFloat)0xf3/0xff blue: (CGFloat)0xf3/0xff alpha:1];
}

- (void)reloadData
{
    [self setupItems];
}

- (void)setupItems
{
    if ([self.columnsViewDelegate respondsToSelector:@selector(numbersOfItem)]) {
        _numberOfItems = [self.columnsViewDelegate numbersOfItem];
    }
    _itemsArray = [NSMutableArray arrayWithCapacity:_numberOfItems];
    for (NSInteger i = 0; i < _numberOfItems; i++) {
        NSInteger currentRow = i / [self numberOfItemsPerRow];
        NSInteger currentColumn = i % [self numberOfItemsPerRow];
        UILabel *itemLabel = [[UILabel alloc] init];
        CGFloat x = self.inset.left + currentColumn * (self.itemSize.width  + self.itemSpacing);
        CGFloat y = self.inset.top + currentRow * (self.itemSize.height + self.lineSpacing);
        
        
        if ([self.columnsViewDelegate respondsToSelector:@selector(configureItem:AtIndex:)]) {
            [self.columnsViewDelegate configureItem:itemLabel AtIndex:i];
        } else {
            [self configureDefaultItemLabel:itemLabel atIndex:i];
        }
        itemLabel.frame = CGRectMake(x, y, self.itemSize.width, self.itemSize.height);
        itemLabel.tag = i;
        
        CGRect bgViewFrame = CGRectInset(itemLabel.frame, 1, 1);
        UIView *bgView = [[UIView alloc] initWithFrame:bgViewFrame];
        if ([self.columnsViewDelegate respondsToSelector:@selector(configureItemBackground:atIndex:)]) {
            [self.columnsViewDelegate configureItemBackground:bgView atIndex:i];
        } else {
            [self configureDefaultItemBackgroundView:bgView atIndex:i];
        }
        
        BOOL canMove = _enableMove;
        if ([self.columnsViewDelegate respondsToSelector:@selector(canMoveItemAtIndex:)]) {
            canMove = [self.columnsViewDelegate canMoveItemAtIndex:i];
        }
        if (canMove) {
            UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
            [itemLabel addGestureRecognizer:panGR];
        }
        
        [self addSubview:bgView];
        [self addSubview:itemLabel];
        [_itemsArray addObject:itemLabel];
    }
}

//默认item 样式
- (void)configureDefaultItemLabel: (UILabel *)itemLabel atIndex: (NSInteger)index
{
    NSString *title = nil;
    if ([self.columnsViewDelegate respondsToSelector:@selector(itemTitleAtIndex:)]) {
        title = [self.columnsViewDelegate itemTitleAtIndex:index];
    }
    itemLabel.text = title;
    itemLabel.textAlignment = NSTextAlignmentCenter;
    itemLabel.textColor = _textColor;
    itemLabel.backgroundColor = _textBackgroundColor;
    
    BOOL canMove = _enableMove;
    if ([self.columnsViewDelegate respondsToSelector:@selector(canMoveItemAtIndex:)]) {
        canMove = [self.columnsViewDelegate canMoveItemAtIndex:index];
    }
    if (canMove) {
        itemLabel.layer.borderColor = _textBorderColor.CGColor;
        itemLabel.layer.borderWidth = 1;
        itemLabel.layer.cornerRadius = 4;
        itemLabel.layer.masksToBounds = YES;
        itemLabel.userInteractionEnabled = YES;
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [itemLabel addGestureRecognizer:panGR];
    }
}

//默认item 背景样式
- (void)configureDefaultItemBackgroundView: (UIView *)bgView atIndex: (NSInteger)index
{
    bgView.backgroundColor = _backgroundViewColor;
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.strokeColor = [UIColor redColor].CGColor;// [UIColor colorWithRed:67/255.0f green:37/255.0f blue:83/255.0f alpha:1].CGColor;
    borderLayer.fillColor = nil;
    borderLayer.lineWidth = 0.5;
    CGRect borderFrame = bgView.bounds;
    borderLayer.path = [UIBezierPath bezierPathWithRect:borderFrame].CGPath;
    borderLayer.lineDashPattern = @[@2, @1];
    borderLayer.frame = borderFrame;
    [bgView.layer addSublayer:borderLayer];
}

- (NSInteger) numberOfItemsPerRow
{
   CGFloat width =  CGRectGetWidth(self.bounds);
   NSInteger number = floor((width - self.inset.left - self.inset.right + self.itemSpacing) / (self.itemSize.width + self.itemSpacing));
   return number;
}


- (void)panAction: (UIPanGestureRecognizer *)gr
{
    _targetLabel = (UILabel *) gr.view;
    CGPoint point = [gr locationInView:self];
    switch (gr.state) {
        case UIGestureRecognizerStateBegan:
        {
            _blankFrame = _targetLabel.frame;
            _currentIndex = [_itemsArray indexOfObject:_targetLabel];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGRect frame =  _targetLabel.frame;
            frame.origin.x = point.x - CGRectGetWidth(frame) / 2;
            frame.origin.y = point.y - CGRectGetHeight(frame) / 2;
            _targetLabel.frame = frame;
            [self moveItemsAtPoint:point];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        {
            _targetLabel.frame = _blankFrame;
            [self bringSubviewToFront:_targetLabel];
            [self finishOrder];
        }
            break;
        default:
            break;
    }
}


#define DJColumnsViewReorder  \
            UILabel *currentLabel = [_itemsArray objectAtIndex:i]; \
            if ([self canMoveAtIndex:i]) { \
                nextFame = currentLabel.frame; \
                [self bringSubviewToFront:currentLabel]; \
                [UIView animateWithDuration:0.4 animations:^{ \
                    currentLabel.frame = currentFrame; \
                }];\
                currentFrame = nextFame; \
                [_itemsArray exchangeObjectAtIndex:i withObjectAtIndex:nextIdx]; \
                nextIdx  = i;\
            } 

//所在位置是移动原位置或者不能移动的item 不做移动
- (void)moveItemsAtPoint: (CGPoint)point
{
   __block NSInteger movedIndex = NSNotFound;
    [_itemsArray enumerateObjectsUsingBlock:^(UILabel *  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if(CGRectContainsPoint(item.frame, point) && item.tag != _targetLabel.tag) {
            movedIndex = idx;
            *stop =YES;
        }
    }];
    
    if (_currentIndex == movedIndex || ![self canMoveAtIndex:movedIndex]) {
        return;
    }
    if (movedIndex != NSNotFound) {
        NSInteger fromIndex = _currentIndex;
        CGRect nextFame;
        CGRect currentFrame = _blankFrame;
        NSInteger nextIdx = fromIndex;
        if (fromIndex < movedIndex) { //向上移动
            for (NSInteger i = fromIndex + 1 ; i <= movedIndex; i++) {
                DJColumnsViewReorder
            }

        } else { //向下移动
            for (NSInteger i = fromIndex - 1; i >= movedIndex; i--) {
                DJColumnsViewReorder
            }
        }
        _blankFrame = currentFrame;
        _currentIndex = movedIndex;
    }
}

- (BOOL)canMoveAtIndex: (NSInteger)index
{
    BOOL canMove = _enableMove;
    if ([self.columnsViewDelegate respondsToSelector:@selector(canMoveItemAtIndex:)]) {
        canMove = [self.columnsViewDelegate canMoveItemAtIndex:index];
    }
    return canMove;
}

- (void)finishOrder
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:_itemsArray.count];
    for (UIView *view in _itemsArray) {
        [array addObject:@(view.tag)];
    }
    if ([self.columnsViewDelegate respondsToSelector:@selector(didFinishSortWithOrderArray:)]) {
        [self.columnsViewDelegate didFinishSortWithOrderArray:[array copy]];
    }
}
@end
