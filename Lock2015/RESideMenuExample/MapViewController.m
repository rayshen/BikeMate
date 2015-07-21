//
//  MapViewController.m
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-18.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import "MapViewController.h"
#import "RegionAnnotation.h"
#import "CheckInstalledMapAPP.h"
#import "LocationChange.h"
#import "LocIsBaidu.h"

#define SYSTEM_NAVIBAR_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:1]
#define ISIOS7 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7)
#define ISIOS6 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=6)
#define STATUS_BAR_H 20
#define NAV_BAT_H 44

#define FRAME_WITH_NAV CGRectMake(0, 0, [self windowWidth], [self windowHeight])
#define FRAME_USER_LOC CGRectMake(8, [self windowHeight]-44, 40, 40)


@interface MapViewController ()

//导航目的地2d,百度
@property(nonatomic,assign) CLLocationCoordinate2D naviCoordsBd;
//导航目的地2d,高德
@property(nonatomic,assign) CLLocationCoordinate2D naviCoordsGd;
//user最新2d
@property(nonatomic,assign) CLLocationCoordinate2D nowCoords;
//最近一次请求的中心2d
@property(nonatomic,assign) CLLocationCoordinate2D centerCoordinate;
@property(nonatomic,strong) NSMutableArray *requestLocArr;
@property (weak, nonatomic) IBOutlet MKMapView *regionMapView;
@property(nonatomic,assign) int updateInt;
@property MKUserLocation *userlocation;
@property CLRegion *myregion;

//userRegion 地图中心点定位参数
@property(nonatomic,assign) MKCoordinateRegion userRegion;
@property(nonatomic,assign) MKCoordinateRegion naviRegion;

@property(nonatomic,assign) MKCoordinateRegion lastRegion;
@property(nonatomic,assign) MKCoordinateRegion nextRegion;
@property  NSString *city;
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

@property MKRoute *Naviroute;
@property MKRoute *Myroute;

@property NSMutableArray *nowRoadArray;

@end

CLLocationCoordinate2D lastCoords[2];
CLLocationCoordinate2D Routecoords[];

QSearchViewController *QSVC;
@implementation MapViewController
@synthesize regionMapView;
@synthesize addressStr;
@synthesize updateInt;
@synthesize userRegion;
@synthesize naviRegion;
@synthesize naviCoordsBd;
@synthesize naviCoordsGd;
@synthesize nowCoords;
@synthesize regionStr;
@synthesize navDic;
@synthesize requestLocArr;
@synthesize centerCoordinate;
@synthesize locationManager;
@synthesize regionAnnotation;
@synthesize loadStatus;

- (NSInteger)windowWidth {
    return [[[[UIApplication sharedApplication] windows] objectAtIndex:0] frame].size.width;
}
- (NSInteger)windowHeight {
    return [[[[UIApplication sharedApplication] windows] objectAtIndex:0] frame].size.height;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self searchbarsetting];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.regionMapView.delegate = self;
    self.regionMapView.showsUserLocation = YES;
    
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager setDelegate:self];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    [_goUserLocBtn addTarget:self action:@selector(goUserLoc:) forControlEvents:UIControlEventTouchUpInside];
    [_goUserLocBtn setImage:[UIImage imageNamed:@"wl_map_icon_position"] forState:UIControlStateNormal];

    [self.view bringSubviewToFront:_goUserLocBtn];
    [self.view bringSubviewToFront:_databutton];
    [self.view bringSubviewToFront:_searchbar];
    
    //显示导航的点,先把要查询的地点的坐标转换成地图坐标，然后在地图显示该地点
    //[self addnaviitem];
    
    /*
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:@"屏峰" completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil){
            NSLog(@"Found %lu placemark(s).", (unsigned long)[placemarks count]);
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            NSLog(@"Longitude = %f", firstPlacemark.location.coordinate.longitude);
            NSLog(@"Latitude = %f", firstPlacemark.location.coordinate.latitude);
        }
        else if ([placemarks count] == 0 && error == nil){
            NSLog(@"Found no placemarks.");
        }
        else if (error != nil){
            NSLog(@"An error occurred = %@", error);
        }
    }];
    */
}

-(void)searchbarsetting{
    _searchbar.placeholder = @"点击搜索目的地";
    _searchbar.delegate=self;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    QSVC=[[QSearchViewController alloc]init];
    QSVC.delegate=self;
    QSVC.myregion=_myregion;
    QSVC.city=self.city;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:QSVC];
    [self presentViewController:nav animated:YES completion:nil];
    return NO;
}

-(void)addnaviitem{
    /*
     NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
        @"中国上海市陆家嘴延安东路",@"address",
        @"上海市",@"city",
        @"google",@"from_map_type",
        @"31.23733484",@"google_lat",
        @"121.50142656",@"google_lng",
        @"浦东新区",@"region", nil];
        self.navDic = dic;
     */
    /*
     NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
        @"留下镇留和路288号",@"address",
        @"杭州市",@"city",
        @"baidu",@"from_map_type",
        @"30.230782",@"baidu_lat",
        @"120.043408",@"baidu_lng",
        @"浙江工业大学(留和路)",@"region", nil];
     self.navDic = dic;
    
    
    self.navDic = dic;
    [self getChangedLoc];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:_naviCoordsGd.latitude longitude:_naviCoordsGd.longitude];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_naviCoordsGd, 500, 500);
    self.naviRegion = [self.regionMapView regionThatFits:viewRegion];
    [self showAnnotation:loc coord:_naviCoordsGd];
    */
}

#pragma mark - 百度和火星经纬度转换
-(void)getChangedLoc{
    if ([LocIsBaidu locIsBaid:self.navDic]) {
        naviCoordsBd.latitude = [[self.navDic objectForKey:@"baidu_lat"] doubleValue];
        naviCoordsBd.longitude = [[self.navDic objectForKey:@"baidu_lng"] doubleValue];
        
        double gdLat,gdLon;
        bd_decrypt(naviCoordsBd.latitude, naviCoordsBd.longitude, &gdLat, &gdLon);
        
        naviCoordsGd.latitude = gdLat;
        naviCoordsGd.longitude = gdLon;
    }else{

        naviCoordsGd.latitude = [[self.navDic objectForKey:@"google_lat"] doubleValue];
        naviCoordsGd.longitude = [[self.navDic objectForKey:@"google_lng"] doubleValue];
        
        double bdLat,bdLon;
        bd_encrypt(naviCoordsGd.latitude, naviCoordsGd.longitude, &bdLat, &bdLon);
        
        naviCoordsBd.latitude = bdLat;
        naviCoordsBd.longitude = bdLon;
    }
}

-(void)openGPSTips{
    UIAlertView *alet = [[UIAlertView alloc] initWithTitle:@"当前定位服务不可用" message:@"请到“设置->隐私->定位服务”中开启定位" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alet show];
}

-(void)doBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goUserLoc:(id)sender{
    if(updateInt>0){
        if (_iffollowed==NO) {
            _iffollowed=YES;
            [_goUserLocBtn setImage:[UIImage imageNamed:@"wl_map_icon_position_press"] forState:UIControlStateNormal];
            [self.regionMapView setRegion:self.userRegion animated:YES];
        }else{
            _iffollowed=NO;
            [_goUserLocBtn setImage:[UIImage imageNamed:@"wl_map_icon_position"] forState:UIControlStateNormal];
        }
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"正在努力的定位中..." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)doAcSheet{
    NSArray *appListArr = [CheckInstalledMapAPP checkHasOwnApp];
    NSString *sheetTitle = [NSString stringWithFormat:@"导航到 %@",[self.navDic objectForKey:@"address"]];
    UIActionSheet *sheet;
    if ([appListArr count] == 2) {
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1], nil];
    }else if ([appListArr count] == 3){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2], nil];
    }else if ([appListArr count] == 4){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3], nil];
    }else if ([appListArr count] == 5){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3],appListArr[4], nil];
    }
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == 0) {
            CLLocationCoordinate2D to;
            to.latitude = naviCoordsGd.latitude;
            to.longitude = naviCoordsGd.longitude;
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
            
            toLocation.name = addressStr;
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }
    if ([btnTitle isEqualToString:@"google地图"]) {
        NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=transit",self.nowCoords.latitude,self.nowCoords.longitude,self.naviCoordsGd.latitude,self.naviCoordsGd.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        
    }else if ([btnTitle isEqualToString:@"高德地图"]){
        NSLog(@"高德导航");
        
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&poiname=%@&lat=%f&lon=%f&dev=1&style=2",@"app name", @"",self.addressStr, self.naviCoordsGd.latitude, self.naviCoordsGd.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }else if ([btnTitle isEqualToString:@"百度地图"]){
        double bdNowLat,bdNowLon;
        bd_encrypt(self.nowCoords.latitude, self.nowCoords.longitude, &bdNowLat, &bdNowLon);
        
        NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%.8f,%.8f&destination=%.8f,%.8f&&mode=driving",bdNowLat,bdNowLon,self.naviCoordsBd.latitude,self.naviCoordsBd.longitude];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }else if ([btnTitle isEqualToString:@"显示路线"]){
        [self drawRout];
    }
}

-(void)drawRout{
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:nowCoords addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:naviCoordsGd addressDictionary:nil];
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    [self.regionMapView removeOverlay:_Naviroute.polyline];
    [self findDirectionsFrom:fromItem to:toItem];
}

#pragma mark - 实时路线绘制
-(void)drawlineFrom:(MKMapItem *)from to:(MKMapItem *)to{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = from;
    request.destination = to;
    request.transportType = MKDirectionsTransportTypeWalking;
    if (ISIOS7) {
        request.requestsAlternateRoutes = YES;
    }
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    //ios7获取绘制路线的路径方法
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
        }
        else {
            MKRoute *route = response.routes[0];
            [self.regionMapView addOverlay:route.polyline];
        }
    }];
}

#pragma mark - 导航路线绘制
-(void)findDirectionsFrom:(MKMapItem *)from to:(MKMapItem *)to{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = from;
    request.destination = to;
    request.transportType = MKDirectionsTransportTypeWalking;
    if (ISIOS7) {
        request.requestsAlternateRoutes = YES;
    }
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    //ios7获取绘制路线的路径方法
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
        }
        else {
            _Naviroute = response.routes[0];
            [self.regionMapView insertOverlay:_Naviroute.polyline atIndex:1];
        }
    }];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[Routepolyline class]])
    {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor=[UIColor blueColor];
        renderer.lineWidth=5.0;
        return renderer;
    }else{
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 5.0;
        renderer.strokeColor = [UIColor redColor];
        return renderer;
    }
}


#pragma mark - 检测应用是否开启定位服务
- (void)locationManager: (CLLocationManager *)manager
       didFailWithError: (NSError *)error {
    [manager stopUpdatingLocation];
    switch([error code]) {
        case kCLErrorDenied:
            [self openGPSTips];
            break;
        case kCLErrorLocationUnknown:
            break;
        default:
            break;
    }
}

#pragma mark MKMapViewDelegate -user location定位变化
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    NSLog(@"定位到当前位置");
    updateInt++;

    _userlocation=userLocation;
    self.nowCoords = [userLocation coordinate];
    
    //存路线
    [_nowRoadArray addObject:userLocation];
    
    //放大地图到自身的经纬度位置。
    self.userRegion = MKCoordinateRegionMakeWithDistance(self.nowCoords, 200, 200);
    if(updateInt==1||_iffollowed==YES){
        [self.regionMapView setRegion:self.userRegion animated:NO];
    }
    //仅在打开地图后，第一次更新地理信息时，确定使用者的大致地理位置
    if (updateInt<=1) {
        //CLGeocoder 是谷歌接口通过经纬度查询大致地址
        NSLog(@"通过经纬度查询地理信息");
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[userLocation location] completionHandler:^(NSArray *array, NSError *error) {
            if (array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                _myregion=[placemark region];
                NSString *region = [placemark.addressDictionary objectForKey:@"SubLocality"];
                NSString *address = [placemark.addressDictionary objectForKey:@"Name"];
                self.regionStr = region;
                self.addressStr = address;
                self.city = placemark.locality;
                [self.siteDelegate loadMapSiteMessage:self.city];
                [QSVC setCity:self.city];
                NSLog(@"当前使用者所在：地点名：%@，地址：%@，城市：%@",self.regionStr,self.addressStr,self.city);
            }else{
                self.regionStr = @"";
                self.addressStr = @"";
                self.city = @"";
                NSLog(@"未查询到有效地址");
            }
        }];
        lastCoords[0]=nowCoords;
    }else{
        lastCoords[1]=nowCoords;
        //绘制路线
        Routepolyline *cc = [Routepolyline polylineWithCoordinates:lastCoords count:2];//执行画线方法
        [self.regionMapView insertOverlay:cc atIndex:2];
        lastCoords[0]=lastCoords[1];
    }
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    return;
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    return;
}
#pragma mark- 获取位置信息，并判断是否显示，block方法支持ios6及以上
-(void)showAnnotation:(CLLocation *)location coord:(CLLocationCoordinate2D)coords{
    //如果导航字典里存有要导航的地址信息，插目的地的标志
    if (![[self.navDic objectForKey:@"region"] isEqualToString:@""]&&[self.navDic objectForKey:@"region"]!=nil) {
        NSLog(@"存在导航目的地信息,目的地：%@",[self.navDic objectForKey:@"region"]);
        loadStatus = 4;
        [self addAnnotationView:location coord:coords region:[self.navDic objectForKey:@"region"]  address:[self.navDic objectForKey:@"address"]];
        return;
    }
}

#pragma mark- 添加大头针的标注 类型4为带导航按钮的提示框
-(void)addAnnotationView:(CLLocation *)location coord:(CLLocationCoordinate2D)coords region:(NSString *)region address:(NSString *)address{
    if ([self.regionMapView.annotations count]) {
        [self.regionMapView removeAnnotations:self.regionMapView.annotations];
    }
    
    if (!self.regionAnnotation) {
        self.regionAnnotation = [[RegionAnnotation alloc] init];
    }
    
    self.regionAnnotation.coordinate = coords;
    self.regionAnnotation.title = region;
    self.regionAnnotation.subtitle  = address;
    
    if (loadStatus == 0) {
        self.regionAnnotation.annotationStatus = ChooseLoading;
    }else if (loadStatus == 1){
        self.regionAnnotation.annotationStatus = ChooseSuc;
    }else if (loadStatus == 2){
        self.regionAnnotation.annotationStatus = ChooseFail;
    }else if (loadStatus == 3){
        self.regionAnnotation.annotationStatus = NaviLoading;
    }else if (loadStatus == 4){
        //带导航按钮的点
        self.regionAnnotation.annotationStatus = NaviSuc;
    }else if (loadStatus == 5){
        self.regionAnnotation.annotationStatus = NaviFail;
    }
    [self.regionMapView addAnnotation:self.regionAnnotation];
    [self.regionMapView selectAnnotation:self.regionAnnotation animated:YES];
}

#pragma mark MKMapViewDelegate -显示大头针标注
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    if ([annotation isKindOfClass:[regionAnnotation class]]) {
        static NSString* identifier = @"MKAnnotationView";
        RegionAnnotationView *annotationView;
        
        annotationView = (RegionAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!annotationView) {
            annotationView = [[RegionAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.acSheetDelegate = self;
        }
        
        annotationView.backgroundColor = [UIColor clearColor];
        annotationView.annotation = annotation;
        [annotationView layoutSubviews];
        [annotationView setCanShowCallout:NO];
        
        return annotationView;
    }else{
        return nil;
    }
}
- (IBAction)backtodata:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)naviClick{
    [self doAcSheet];
}

- (void)updateAlert:(NSMutableDictionary *)navidic{
    self.navDic = navidic;
    [self getChangedLoc];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:naviCoordsGd.latitude longitude:naviCoordsGd.longitude];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(naviCoordsGd, 500, 500);
    self.naviRegion = [self.regionMapView regionThatFits:viewRegion];
    [self showAnnotation:loc coord:naviCoordsGd];
    [self.regionMapView setRegion:self.naviRegion animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
