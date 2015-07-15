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

@protocol MapViewControllerDelegate <NSObject>
@required
-(void)loadMapSiteMessage:(NSDictionary *)mapSiteDic;
@end

@interface MapViewController : UIViewController<MKMapViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,CLLocationManagerDelegate,doAcSheetDelegate,UISearchBarDelegate>{
    CLLocationManager *locationManager;
    NSArray *data;
    NSArray *filterData;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property(nonatomic,assign) id<MapViewControllerDelegate> siteDelegate;
@property(nonatomic,strong) NSDictionary *navDic;
//导航目的地2d,百度
@property(nonatomic,assign) CLLocationCoordinate2D naviCoordsBd;
//导航目的地2d,高德
@property(nonatomic,assign) CLLocationCoordinate2D naviCoordsGd;
//user最新2d
@property(nonatomic,assign) CLLocationCoordinate2D nowCoords;
//最近一次成功查询2d
@property(nonatomic,assign) CLLocationCoordinate2D lastCoords;
//最近一次请求的中心2d
@property(nonatomic,assign) CLLocationCoordinate2D centerCoordinate;
@property(nonatomic,strong) NSMutableArray *requestLocArr;
@property (weak, nonatomic) IBOutlet MKMapView *regionMapView;
//updateInt初始化为0，大于1时，didUpdateUserLocation中setRegion不再执行
@property(nonatomic,assign) int updateInt;
//userRegion 地图中心点定位参数
@property(nonatomic,assign) MKCoordinateRegion userRegion;
@property(nonatomic,assign) MKCoordinateRegion naviRegion;

@property  NSString *city;
@property  NSArray *routes;//ios6路线arr
//地图的区域和详细地址
@property(nonatomic,strong) NSString *regionStr;
@property(nonatomic,strong) NSString *addressStr;
@property(nonatomic,strong) CLLocationManager *locationManager;
//定位参数信息
@property(nonatomic,strong) RegionAnnotation *regionAnnotation;
//定位状态，包括6种状态
@property(nonatomic, assign) int loadStatus;

@property (weak, nonatomic) IBOutlet DBTileButton *databutton;
- (IBAction)backtodata:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *goUserLocBtn;
-(void)naviClick;
@end
