//
//  ViewController.m
//  OC_deep_learn
//
//  Created by Netban on 2019/10/12.
//  Copyright © 2019 scn. All rights reserved.
//

#import "ViewController.h"
#import "MyOperation.h"

@interface ViewController ()
@property(nonatomic, assign) NSInteger ticketSurplusCount;
@property(nonatomic, strong) NSLock *lock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     NSLog(@"main---%@", [NSThread currentThread]); // 打印当前线程
    // 在当前主线程中执行
//    [self userInvocationOperation];
    
    
    // 在主线程中执行
//    [self useNSBlockOperation];

    // 新开辟线程去执行,不会阻塞当前主线程
//    [NSThread detachNewThreadSelector:@selector(userInvocationOperation) toTarget:self withObject:nil];
    
    // 新开辟线程去执行,不会阻塞当前主线程
//    [NSThread detachNewThreadSelector:@selector(useNSBlockOperation) toTarget:self withObject:nil];

    
    
//    [self useZDYOperation];
//
//    [self addOperationToQueue];
    
//    [self setMaxOperationCount];
    
    [self addDependce];
//    [self communication];
    
    // 这种方式 得到的票数是错乱的
//    [self initTicksStatusNoSave];
    NSLog(@"end");
    
    // 获取主队列
    [NSOperationQueue mainQueue];

}


-(void)userInvocationOperation{
    // 同步 阻断线程
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    [op start];
}


-(void)useNSBlockOperation{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
          [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
          NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 新开辟了一个线程,并发执行
    // 这里也是需要调用一下 start 方法
    // 这里的线程并不一定和 blockOperationWithBlock 在同一个线程里,由系统分配
    [op addExecutionBlock:^{
        NSLog(@"addExecutionBlock");
        NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
    }];
    
    [op start];
}


-(void)useZDYOperation{
    MyOperation *op = [[MyOperation alloc] init];
    [op start];
}

-(void)task1{
    for (int i = 0; i < 2; i++) {
           [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
           NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
       }
}


-(void)task2{
    for (int i = 0; i < 2; i++) {
           [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
           NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
       }
}

// 开辟新线程,异步执行
-(void)addOperationToQueue{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [op3 addExecutionBlock:^{
       for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"5---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    
    // 直接使用 queue 来进行操作 addOperation
}

// NSOperationQueue 控制串行执行、并发执行
-(void)setMaxOperationCount{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    queue.maxConcurrentOperationCount = -1; //不进行限制,可并发操作
//    queue.maxConcurrentOperationCount = 1; // 串行队列,不可进行并发操作 只能并行进行操作
    queue.maxConcurrentOperationCount = 2; // 可进行的最大并发数
    // 3.添加操作
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
}



// NSOperation 操作依赖
-(void)addDependce{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
       for (int i = 0; i < 2; i++) {
           [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
           NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
       }
    }];
    

    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
          for (int i = 0; i < 3; i++) {
              [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
              NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
          }
    }];
    
    
    [op2 addDependency:op1];
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    //通过添加操作依赖，无论运行几次，其结果都是 op1 先执行，op2 后执行。
    
}


// 线程间的优先级
-(void)queuePriority{
    
}

// 线程通讯
-(void)communication{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
        // 等上面的操作执行完成以后,才会执行下面的方法
        // 回到h主线程做一些操作
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }];
    }];
}

-(void)initTicksStatusNoSave{
    self.ticketSurplusCount = 50;
    self.lock = [[NSLock alloc] init];
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    [queue1 addOperationWithBlock:^{
        [self saleTicketNotSafe];
    }];
    
    [queue2 addOperationWithBlock:^{
        [self saleTicketNotSafe];
    }];
}

// 使用 NSLock 来加锁 解锁
- (void)saleTicketNotSafe {
    while (1) {
        [self.lock lock];
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else {
            NSLog(@"所有火车票均已售完");
            break;
        }
        [self.lock unlock];
    }
}



@end
