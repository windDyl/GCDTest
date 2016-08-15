//
//  ViewController.m
//  GCDTestDemo
//
//  Created by Ethank on 16/3/16.
//  Copyright © 2016年 Ldy. All rights reserved.
//

#import "ViewController.h"
#import "CSRefreshFooter.h"
#import "CSRefreshHeader.h"
#import "Masonry.h"
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()
@end

@implementation ViewController
- (void)viewDidLoad {
    //串行队列
//    [self createSerialQueue];
    //并发队列
//    [self createConCurrentQueue];
//    [self combineGlobalAndMainQueue];
    //给创建的queue指定priority
//    [self setQueuePriority];
    //group
//    [self createGroupQueue];
    //barrier_async
    [self barrier_async];
    //dispatch_apply
//    [self dispatch_apply];
    //semaphore
//    [self semaphore];
    //suspendAndResume
//    [self suspendAndResume];
    //排序
//    [self sort];

    //移位
//    [self shift];
    
}
/**
 *  Serial Diapatch Queue 串行队列
 */
//当任务相互依赖，具有明显的先后顺序的时候，使用串行队列是一个不错的选择 创建一个串行队列：
- (void)createSerialQueue {
    //第一个参数为队列名，第二个参数为队列类型，当然，第二个参数人如果写NULL，创建出来的也是一个串行队列
    dispatch_queue_t serialDiapatchQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(serialDiapatchQueue, ^{
        NSLog(@"serial1");
    });
    
    dispatch_async(serialDiapatchQueue, ^{
        sleep(10);
        NSLog(@"serial2");
    });
    
    dispatch_async(serialDiapatchQueue, ^{
        NSLog(@"serial3");
    });
    
    //执行结果 1 2 3
}
/**
 *  Concurrent Diapatch Queue 并发队列
 */
//任务相互不依赖，不阻塞
- (void)createConCurrentQueue {
    dispatch_queue_t conCurrentQueue = dispatch_queue_create("conCurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(conCurrentQueue, ^{
        NSLog(@"conCurrent1");
    });
    
    dispatch_async(conCurrentQueue, ^{
        NSLog(@"conCurrent2");
    });
    
    dispatch_async(conCurrentQueue, ^{
        NSLog(@"conCurrent3");
    });
    
    //输出在线程中进行，而且相互不依赖，不阻塞
}
/**
 *  Global Queue & Main Queue
 *
 *  这是系统为我们准备的2个队列：
 *  Global Queue其实就是系统创建的Concurrent Diapatch Queue
 *  Main Queue 其实就是系统创建的位于主线程的Serial Diapatch Queue
 *
 *  通常情况我们会把这2个队列放在一起使用，也是我们最常用的开异步线程-执行异步任务-回主线程的一种方式
 */
- (void)combineGlobalAndMainQueue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //dispatch_get_global_queue存在优先级 优先级由高到低 依次是 DISPATCH_QUEUE_PRIORITY_HIGH DISPATCH_QUEUE_PRIORITY_DEFAULT DISPATCH_QUEUE_PRIORITY_LOW DISPATCH_QUEUE_PRIORITY_BACKGROUND
        NSLog(@"异步线程");
        dispatch_async(dispatch_get_main_queue(), ^{
            //异步主线程  除了在其他线程返回主线程的时候需要用这个方法，还有一些时候我们在主线程中直接调用异步主线程，这是利用dispatch_async的特性：block中的任务会放在主线程本次runloop之后返回
            NSLog(@"异步主线程");
        });
    });
}
/**
 *  dispatch_set_target_queue
 */
//用dispatch_set_target_queue给自己创建的队列指定执行的优先级
- (void)setQueuePriority {
    dispatch_queue_t serialDispatchQueue = dispatch_queue_create("queue1", NULL);
    dispatch_queue_t globalDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_set_target_queue(serialDispatchQueue, globalDispatchQueue);//将serialDispatchQueue放到globalDispatchQueue中执行
    dispatch_async(serialDispatchQueue, ^{
        NSLog(@"dispatch_set_target_queue1");
    });
    
    dispatch_async(globalDispatchQueue, ^{
        NSLog(@"dispatch_set_target_queue2");
    });
}
/**
 *  dispatch_group
 *  用dispatch_group来实现所有任务都完成后再去执行某个任务
 *  通过dispatch_group_notify可以获取所有任务都执行完了
 */
- (void)createGroupQueue {
    __block int i = 0;
    __block int s = 0;
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, globalQueue, ^{
        i += 1;
        NSLog(@"createGroupQueue1 = %d", i);
    });
    dispatch_group_async(group, globalQueue, ^{
        i += 2;
        NSLog(@"createGroupQueue2 = %d", i);
    });
    //上边两个任务执行完毕，然后才执行下边的任务
    dispatch_group_notify(group, globalQueue, ^{
        s = i;
        NSLog(@"createGroupQueue3 %d", s*s);
    });
}
/**
 *  dispatch_barrier_async
 *  作用是在并发队列中，完成在它之前提交到队列中的任务后打断，单独执行其block，并在执行完成之后才能继续执行在他之后提交到队列中的任务
 */
- (void)barrier_async {
    dispatch_queue_t conCurrentQueue = dispatch_queue_create("conCurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(conCurrentQueue, ^{
        NSLog(@"conCurrentQueue1");
    });
    dispatch_async(conCurrentQueue, ^{
        NSLog(@"conCurrentQueue2");
    });
    dispatch_barrier_async(conCurrentQueue, ^{
        sleep(10);
        NSLog(@"conCurrentQueue0");
    });
    dispatch_async(conCurrentQueue, ^{
        NSLog(@"conCurrentQueue3");
    });
    dispatch_async(conCurrentQueue, ^{
        NSLog(@"conCurrentQueue4");
    });
}
/**
 *  dispatch_apply
 *
 *  用于无序查找。比如，在一个数组中，我们能开启多个线程来查找所需要的值，虽然会开启多个线程来遍历这个数组，但是在遍历完成之前会阻塞主线程,适用于大量数据遍历
 */
- (void)dispatch_apply {
    NSArray *arrar = @[@"0",@"1",@"2",@"3",@"4"];//开启多个线程便利数组
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply([arrar count], queue, ^(size_t index) {
        NSLog(@"%zu=%@",index,arrar[index]);
    });
    NSLog(@"阻塞");
}
/**
 *  Semaphore
 *
 *  我们可以通过设置信号量的大小，来解决并发过多导致资源吃紧的情况，以单核CPU做并发为例，一个CPU永远只能干一件事情，那如何同时处理多个事件呢，聪明的内核工程师让CPU干第一件事情，一定时间后停下来，存取进度，干第二件事情以此类推，所以如果开启非常多的线程，单核CPU会变得非常吃力，即使多核CPU，核心数也是有限的，所以合理分配线程，变得至关重要，那么如何发挥多核CPU的性能呢？如果让一个核心模拟传很多线程，经常干一半放下干另一件事情，那效率也会变低，所以我们要合理安排，将单一任务或者一组相关任务并发至全局队列中运算或者将多个不相关的任务或者关联不紧密的任务并发至用户队列中运算，所以用好信号量，合理分配CPU资源，程序也能得到优化
 */
- (void)semaphore {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);//为了一次输出10个，创建初始信号量为10
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 100; i ++) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//每进来一次，信号量-1。10次后就一直hold住，直到信号量大于0
        dispatch_async(queue, ^{
            NSLog(@"%i", i);
            sleep(20);
            dispatch_semaphore_signal(semaphore);//由于log处理比较快，就模拟2秒后信号量+1
        });
    }
}
/**
 *  dispatch_once
 */
//单例
//- (instancetype)createSingleton {
//    static Singleton *singlrInstance;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        singlrInstance = [[Singleton alloc] init];
//    });
//    return singlrInstance;
//}
/**
 *  dispatch_suspend & dispatch_resume
 */
- (void)suspendAndResume {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        for (int i = 0; i < 100; i ++) {
            NSLog(@"%i", i);
            if (i == 50) {
                NSLog(@"-------------------");
                dispatch_suspend(concurrentQueue);
                sleep(5);
                dispatch_resume(concurrentQueue);
            }
        }
    });
}
//排序
- (void)sort {
    NSArray *arr = @[@"1.0",@"1.0.1",@"2.1",@"2.2.1",@"2.1.3",@"3.1",@"3.0.1",@"3.1.3"];
    CFTimeInterval timer = CFAbsoluteTimeGetCurrent();
    NSArray *resultArr = [arr sortedArrayUsingSelector:@selector(compare:)];
    CFTimeInterval current = CFAbsoluteTimeGetCurrent();
    for (NSInteger i = resultArr.count - 1; i >= 0; i --) {
        NSLog(@"time %lf", CFAbsoluteTimeGetCurrent() - current);
        NSLog(@"resultArr %@", resultArr[i]);
    }
    NSLog(@"%lf", current - timer);
    NSLog(@"%@", resultArr);
    NSLog(@"%lf", CFAbsoluteTimeGetCurrent() - current);
    //有两个房间，一间房间里有三盏灯，另一间房间里有控制这三盏灯的三个开关。。有两个房间，一间另一间
}
//暴力左移一位
void leftShiftone(char *s,int n) {
    char t = s[0];
    for (int i = 1; i < n; i++) {
        s[i-1] = s[i];
    }
    s[n-1] = t;
}
//暴力左移m位
void leftShift(char *s,int n,int m) {
    while (m--) {
        leftShiftone(s, n);
    }
    printf("%s", s);
}
//位移
- (void)shift {
    char s[] = "abcdef";
    leftShift(s,6,4);
}
@end
