//
//  BLEOperation.m
//  Lock2015
//
//  Created by shen on 15/7/13.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import "BLEOperation.h"

@implementation BLEOperation

//创建单例
+(BLEOperation *)shenInstance
{
    static BLEOperation *SingleShenBLE;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SingleShenBLE = [[BLEOperation alloc] init];
    });
    return SingleShenBLE;
}



@end
