//
//  BikerouteViewController.h
//  Lock2015
//
//  Created by shen on 15/7/25.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RegionAnnotationView.h"
#import "QSearchViewController.h"
#import "Routepolyline.h"


@interface BikerouteViewController : UIViewController<MKMapViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,CLLocationManagerDelegate,doAcSheetDelegate,UISearchBarDelegate,UpdateAlertDelegate>
@property BOOL iffollowed;
@property(nonatomic,strong) NSDictionary *navDic;
@property NSDictionary *resultdic;
@end
