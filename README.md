# NSOperationDemo
# NSOperation,NSOperationQueue
参考[https://www.jianshu.com/p/4b1d77054b35](https://www.jianshu.com/p/4b1d77054b35)
NSOperation、NSOperationQueue 是苹果提供给我们的一套多线程解决方案。实际上 NSOperation、NSOperationQueue 是基于 GCD 更高一层的封装，完全面向对象。但是比 GCD 更简单易用、代码可读性也更高。

为什么要使用 NSOperation、NSOperationQueue？
```
1. 可添加完成的代码块，在操作完成后执行。
2. 添加操作之间的依赖关系，方便的控制执行顺序。
3. 设定操作执行的优先级。
4. 可以很方便的取消一个操作的执行。
5. 使用 KVO 观察对操作执行状态的更改：isExecuteing、isFinished、isCancelled。
```

## 常用的场景
```
// 模拟耗时操作
-(void)task1{
    for (int i = 0; i < 2; i++) {
           [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
           NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
       }
}
```

## 同步操作
记得要用 start 操作开启操作
### NSInvocationOperation
```
-(void)userInvocationOperation{
    // 同步 阻断线程
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    [op start];
}
```
### NSBlockOperation
同步阻塞线程的另外一种方法
blockOperationWithBlock 阻塞线程
但是 addExecutionBlock 不阻塞线程
```
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
```

## NSOperationQueue 操作队列
### 队列的作用
使用 `NSOperationQueue` 来声明一个队列，将操作
`NSInvocationOperation` 和 `NSBlockOperation` 对象放到队列里就可以执行，不用使用start方法.

**这个可以开启新线程 异步操作**

```
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
```
### 使用maxConcurrentOperationCount来控制并发数量

```
 queue.maxConcurrentOperationCount = -1; //不进行限制,可并发操作
 queue.maxConcurrentOperationCount = 1; // 串行队列,不可进行并发操作 只能并行进行操作
 queue.maxConcurrentOperationCount = 2; // 可进行的最大并发数
```
控制最大并发数量为2来进行操作，1，2 执行完以后才会执行3，4
```
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
```

## 操作依赖
正常是 op1 和 op2 和 op3 并行执行。这里添加了依赖 op2 依赖于 op1, 操作结果是，op1 和 op3并行执行，op1执行结束之后，再执行op2,但是op1 和 op2并不在同一个线程上
```
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
```

## 线程通讯
在另外一个线程上结束以后，回到主线程上执行UI的操作,
communication 方法中的耗时操作并不会阻塞主线程，当耗时操作完成后，回到主线程来刷新UI操作
```
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
```

## 使用 NSLock 加锁
模拟售票的情况，两个队列里，不同的线程对同一个对象进行操作，如果不加锁，会看到打印不规律，剩余票不是连续的规则的，使用NSLock,就会连续的出现。
```
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
```
使用NSLock对象，将有可能在不同线程上执行的相同操作加锁
```
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
```
参考 [https://www.jianshu.com/p/4b1d77054b35](https://www.jianshu.com/p/4b1d77054b35)

## NSOperation常用方法
取消操作方法
- (void)cancel; 可取消操作，实质是标记 isCancelled 状态。
判断操作状态方法
- (BOOL)isFinished; 判断操作是否已经结束。
- (BOOL)isCancelled; 判断操作是否已经标记为取消。
- (BOOL)isExecuting; 判断操作是否正在在运行。
- (BOOL)isReady; 判断操作是否处于准备就绪状态，这个值和操作的依赖关系相关
操作同步
- (void)waitUntilFinished; 阻塞当前线程，直到该操作结束。可用于线程执行顺序的同步。
- (void)setCompletionBlock:(void (^)(void))block; completionBlock 会在当前操作执行完毕时执行 completionBlock。
- (void)addDependency:(NSOperation *)op; 添加依赖，使当前操作依赖于操作 op 的完成。
- (void)removeDependency:(NSOperation *)op; 移除依赖，取消当前操作对操作 op 的依赖。
@property (readonly, copy) NSArray<NSOperation *> *dependencies; 在当前操作开始执行之前完成执行的所有操作对象数组。
## NSOperationQueue 的常用方法
### 取消/暂停/恢复操作
- (void)cancelAllOperations; 可以取消队列的所有操作。
- (BOOL)isSuspended; 判断队列是否处于暂停状态。 YES 为暂停状态，NO 为恢复状态。
- (void)setSuspended:(BOOL)b; 可设置操作的暂停和恢复，YES 代表暂停队列，NO 代表恢复队列。
### 操作同步
- (void)waitUntilAllOperationsAreFinished; 阻塞当前线程，直到队列中的操作全部执行完毕。
### 添加/获取操作`
- (void)addOperationWithBlock:(void (^)(void))block; 向队列中添加一个 NSBlockOperation 类型操作对象。
- (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait; 向队列中添加操作数组，wait 标志是否阻塞当前线程直到所有操作结束
- (NSArray *)operations; 当前在队列中的操作数组（某个操作执行结束后会自动从这个数组清除）。
- (NSUInteger)operationCount; 当前队列中的操作数。
### 获取队列
+ (id)currentQueue; 获取当前队列，如果当前线程不是在 NSOperationQueue 上运行则返回 nil。
+ (id)mainQueue; 获取主队列







