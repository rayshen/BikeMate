//
//  CHKeychain.h
//  Lock2015
//
//  Created by shen on 15/7/22.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHKeychain : NSObject
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteData:(NSString *)service;
@end
