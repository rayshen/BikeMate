//
//  CheckInstalledMapAPP.m
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-20.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import "CheckInstalledMapAPP.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@implementation CheckInstalledMapAPP


-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+(NSArray *)checkHasOwnApp{
    NSArray *mapSchemeArr = @[@"comgooglemaps://",@"iosamap://navi",@"baidumap://map/"];

    NSMutableArray *appListArr = [[NSMutableArray alloc] initWithObjects:@"苹果地图", nil];
    
    for (int i = 0; i < [mapSchemeArr count]; i++) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[mapSchemeArr objectAtIndex:i]]]]) {
            if (i == 0) {
                [appListArr addObject:@"google地图"];
            }else if (i == 1){
                [appListArr addObject:@"高德地图"];
            }else if (i == 2){
                [appListArr addObject:@"百度地图"];
            }
        }
    }
    
    [appListArr addObject:@"显示路线"];
    
    return appListArr;
}
@end
