//
//  LocIsBaidu.m
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-21.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import "LocIsBaidu.h"

@implementation LocIsBaidu
+(BOOL)locIsBaid:(NSDictionary *)dic{
    if ([dic[@"from_map_type"] isEqualToString:@"baidu"] && ![dic[@"baidu_lat"] isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}
@end
