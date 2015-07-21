//
//  MapViewController.h
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-18.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RegionAnnotationView.h"
#import "QSearchViewController.h"
#import "DBTileButton.h"
#import "Routepolyline.h"

@protocol MapViewControllerDelegate <NSObject>
-(void)loadMapSiteMessage:(NSString *)city;
@end

@interface MapViewController : UIViewController<MKMapViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,CLLocationManagerDelegate,doAcSheetDelegate,UISearchBarDelegate,UpdateAlertDelegate>{
    CLLocationManager *locationManager;
}
@property BOOL iffollowed;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property(nonatomic,assign) id<MapViewControllerDelegate> siteDelegate;
@property(nonatomic,strong) NSDictionary *navDic;

-(void)naviClick;
@end
