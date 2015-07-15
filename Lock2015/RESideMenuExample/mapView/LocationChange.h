//
//  LocationChange.h
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-21.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import <Foundation/Foundation.h>

void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon);
void bd_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon);

@interface LocationChange : NSObject

@end
