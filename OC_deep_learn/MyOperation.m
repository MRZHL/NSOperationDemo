//
//  MyOperation.m
//  OC_deep_learn
//
//  Created by Netban on 2019/11/12.
//  Copyright © 2019 scn. All rights reserved.
//

#import "MyOperation.h"

@implementation MyOperation

-(void)main{
    if(!self.isCancelled){
        for (int i = 0; i < 2; i++) {
           [NSThread sleepForTimeInterval:2];
           NSLog(@"zdy---%@", [NSThread currentThread]);
       }
    }
}


@end
