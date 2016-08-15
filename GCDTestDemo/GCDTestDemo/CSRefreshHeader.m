//
//  CSRefreshHeader.m
//  CloudSong
//
//  Created by 汪辉 on 15/10/8.
//  Copyright © 2015年 ethank. All rights reserved.
//

#import "CSRefreshHeader.h"
//#import "CSDefine.h"


@interface CSRefreshHeader()
@property (weak, nonatomic) UIView * containerView;
@property (weak, nonatomic) UILabel *stateLabel;
@property (weak, nonatomic) UIImageView *gifView;
@property (strong, nonatomic) NSArray *textArray;
@end
@implementation CSRefreshHeader
#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 50;
    
    UIView * containerView = [[UIView alloc]init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:containerView];
    self.containerView = containerView;
    
    // 添加label
    UILabel *stateLabel = [[UILabel alloc] init];
    stateLabel.textColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
    stateLabel.font = [UIFont systemFontOfSize:12];
    stateLabel.textAlignment = NSTextAlignmentCenter;
//    stateLabel.text = @"我的脑袋在开party,不晃都不行...";
    [self addSubview:stateLabel];
    self.stateLabel = stateLabel;
    [self randomText];

    UIImageView * gifView = [[UIImageView alloc]init];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
//    NSMutableArray *refreshingImages = [NSMutableArray array];
//    for (NSUInteger i = 1; i<=8; i++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Refresh%ld", i]];
//        [refreshingImages addObject:image];
//    }
//    gifView.animationImages = refreshingImages;
//    gifView.image = refreshingImages[0];
    [self addSubview:gifView];
    self.gifView = gifView;
    
    self.textArray = @[@"也许我们不是最好的，但我们会努力做到最好…",
                       @"我们现在需要你的“声音”，让我们一起前进…",
                       @"K歌可以美容、减肥，还能增强胃肠及肝功能…",
                       @"不要去追求幸福，而是要幸福的去追求…",
                       @"一无所知的世界，走下去，才有惊喜…",
                       @"幸福是一种灵魂的香味…",
                       @"与人同乐，其乐无穷…",
                       @"我们只想做最了解你的人…",
                       @"我一直相信我们是有缘分的…",
                       @"迈出腿、走出去，就总会遇到什么…"];
    
}
- (void)randomText{
    
    int randomNum = arc4random() % 9;
    _stateLabel.text = [_textArray objectAtIndex:randomNum];

}
#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    CGSize imageSize = _gifView.image.size;
    
    CGSize textSize = [_stateLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSMutableDictionary dictionaryWithObject:_stateLabel.font forKey:NSFontAttributeName] context:nil].size;
    
    CGFloat padding = (self.frame.size.width - (imageSize.width + textSize.width+10))/2;
    
    
    CGFloat gifViewH = imageSize.height;
    CGFloat gifViewW = imageSize.width;
    CGFloat gitViewX = padding;
    CGFloat gitViewY = (self.frame.size.height - gifViewH) * 0.5;
    _gifView.frame = CGRectMake(gitViewX, gitViewY, gifViewW, gifViewH);
    
    CGFloat labelW = textSize.width;
    CGFloat labelH = textSize.height;
    CGFloat labelY = (self.frame.size.height - labelH) * 0.5;
    CGFloat LabelX = padding + gifViewW + 10;
    
    _stateLabel.frame = CGRectMake(LabelX, labelY, labelW, labelH);
    
}


#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
    // 每次刷新完毕后，提示文案随机更新
    CGPoint newPoint = [change[@"new"] CGPointValue];
    if (newPoint.y == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJRefreshSlowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self randomText];
            [self placeSubviews];
        });
    }
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            [self.gifView stopAnimating];
            break;
        case MJRefreshStatePulling:
            [self.gifView startAnimating];
            break;
        case MJRefreshStateRefreshing:
            [self.gifView startAnimating];
            break;
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    
    self.stateLabel.textColor = [UIColor redColor];
}

-(void)endRefreshing{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super endRefreshing];
    });
}

@end
