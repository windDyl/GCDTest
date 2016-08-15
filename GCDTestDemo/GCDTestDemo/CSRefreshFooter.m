//
//  CSRefreshFooter.m
//  CloudSong
//
//  Created by 汪辉 on 15/10/9.
//  Copyright © 2015年 ethank. All rights reserved.
//

#import "CSRefreshFooter.h"
//#import "CSDefine.h"

@implementation CSRefreshFooter

- (void)prepare
{
    [super prepare];
    self.stateLabel.hidden = YES;
    // 初始化文字
    [self setTitle:@"加载完毕" forState:MJRefreshStateNoMoreData];
    self.stateLabel.font =[UIFont systemFontOfSize:12];
    self.stateLabel.textColor = [UIColor redColor];
}


#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateNoMoreData:
            self.stateLabel.hidden = NO;
            break;
        default:
            self.stateLabel.hidden = YES;
            break;
    }
}
@end
