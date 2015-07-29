//
//  DEMOSecondViewController.h
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "DBTileButton.h"
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>

@interface RecordViewController : UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}
@property CLLocationSpeed currentSpeed;
@property double totalDistance;
@property double totalmiles;
@property double totalcalorie;
@property CLLocation *currentLocation;
@property CLLocation *oldLocation;
@property int updatetimes;

@property (weak, nonatomic) IBOutlet UILabel *speedlabel;
@property (weak, nonatomic) IBOutlet UILabel *distancelabel;
@property (weak, nonatomic) IBOutlet UILabel *totlemileslabel;

@property (weak, nonatomic) IBOutlet UILabel *totalcalorielabel;

@property (weak, nonatomic) IBOutlet UIButton *sidemenu;
@property (weak, nonatomic) IBOutlet DBTileButton *navibutton;
- (IBAction)tonavi:(id)sender;
- (IBAction)sharebtn:(id)sender;

/**
 *  面板
 */
@property (nonatomic, strong) UIView *panelView;

/**
 *  加载视图
 */
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end
