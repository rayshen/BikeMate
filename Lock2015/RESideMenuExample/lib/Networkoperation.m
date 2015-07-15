//
//  Networkoperation.m
//  Lock2015
//
//  Created by shen on 15/7/9.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import "Networkoperation.h"

@implementation Networkoperation

//创建单例
+(Networkoperation *)shenInstance
{
    static Networkoperation *SingleShenNetwork;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SingleShenNetwork = [[Networkoperation alloc] init];
    });
    return SingleShenNetwork;
}
@end
