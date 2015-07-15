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
//#import "NSString+RTStyle.h"

#define SYSTEM_NAVIBAR_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:1]
#define ISIOS7 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7)
#define ISIOS6 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=6)
#define STATUS_BAR_H 20
#define NAV_BAT_H 44

#define FRAME_WITH_NAV CGRectMake(0, 0, [self windowWidth], [self windowHeight])
#define FRAME_USER_LOC CGRectMake(8, [self windowHeight]-44, 40, 40)


@interface MapViewController ()
@end

@implementation MapViewController

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
    self.locationManager = [CLLocationManager new];
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
    [_goUserLocBtn setImage:[UIImage imageNamed:@"wl_map_icon_position_press"] forState:UIControlStateHighlighted];

    [self.view bringSubviewToFront:_goUserLocBtn];
    [self.view bringSubviewToFront:_databutton];
    [self.view bringSubviewToFront:_searchbar];
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                @"中国上海市陆家嘴延安东路",@"address",
                                @"上海市",@"city",
                                @"google",@"from_map_type",
                                @"31.23733484",@"google_lat",
                                @"121.50142656",@"google_lng",
                                @"浦东新区",@"region", nil];
    self.navDic = dic;
    //显示导航的点
    //如果是导航，先把要查询的地点的坐标转换成地图坐标，然后在地图显示该地点
    [self getChangedLoc];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:_naviCoordsGd.latitude longitude:_naviCoordsGd.longitude];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_naviCoordsGd, 500, 500);
    self.naviRegion = [self.regionMapView regionThatFits:viewRegion];
    [self showAnnotation:loc coord:_naviCoordsGd];
}

-(void)searchbarsetting{
    _searchbar.placeholder = @"点击搜索目的地";
    _searchbar.delegate=self;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    QSearchViewController *QSVC=[[QSearchViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:QSVC];
    [self presentViewController:nav animated:YES completion:nil];
    return NO;
}


#pragma mark - 百度和火星经纬度转换
-(void)getChangedLoc{
    if ([LocIsBaidu locIsBaid:self.navDic]) {
        _naviCoordsBd.latitude = [[self.navDic objectForKey:@"baidu_lat"] doubleValue];
        _naviCoordsBd.longitude = [[self.navDic objectForKey:@"baidu_lng"] doubleValue];
        
        double gdLat,gdLon;
        bd_decrypt(_naviCoordsBd.latitude, _naviCoordsBd.longitude, &gdLat, &gdLon);
        
        _naviCoordsGd.latitude = gdLat;
        _naviCoordsGd.longitude = gdLon;
    }else{

        _naviCoordsGd.latitude = [[self.navDic objectForKey:@"google_lat"] doubleValue];
        _naviCoordsGd.longitude = [[self.navDic objectForKey:@"google_lng"] doubleValue];
        
        double bdLat,bdLon;
        bd_encrypt(_naviCoordsGd.latitude, _naviCoordsGd.longitude, &bdLat, &bdLon);
        
        _naviCoordsBd.latitude = bdLat;
        _naviCoordsBd.longitude = bdLon;
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
    [self.regionMapView setRegion:self.userRegion animated:YES];
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
            
            to.latitude = _naviCoordsGd.latitude;
            to.longitude = _naviCoordsGd.longitude;
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
            
            toLocation.name = _addressStr;
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }
    if ([btnTitle isEqualToString:@"google地图"]) {
        NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=transit",self.nowCoords.latitude,self.nowCoords.longitude,self.naviCoordsGd.latitude,self.naviCoordsGd.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }else if ([btnTitle isEqualToString:@"高德地图"]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"iosamap://navi?sourceApplication=broker&backScheme=openbroker2&poiname=%@&poiid=BGVIS&lat=%.8f&lon=%.8f&dev=1&style=2",self.addressStr,self.naviCoordsGd.latitude,self.naviCoordsGd.longitude]];
        [[UIApplication sharedApplication] openURL:url];
        
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
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:_nowCoords addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:_naviCoordsGd addressDictionary:nil];
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    [self.regionMapView removeOverlays:self.regionMapView.overlays];
    
    [self.regionMapView removeOverlays:self.regionMapView.overlays];
    [self findDirectionsFrom:fromItem to:toItem];
    
}
#pragma mark - ios7路线绘制方法
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
            MKRoute *route = response.routes[0];
            [self.regionMapView addOverlay:route.polyline];
        }
    }];
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 5.0;
    renderer.strokeColor = [UIColor redColor];
    return renderer;
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
    self.nowCoords = [userLocation coordinate];
    //放大地图到自身的经纬度位置。
    self.userRegion = MKCoordinateRegionMakeWithDistance(self.nowCoords, 200, 200);
    
    //[self.regionMapView setRegion:self.userRegion animated:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    return;
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    return;
}
#pragma mark- 获取位置信息，并判断是否显示，block方法支持ios6及以上
-(void)showAnnotation:(CLLocation *)location coord:(CLLocationCoordinate2D)coords{
    
    self.updateInt += 1;
    if (![[self.navDic objectForKey:@"region"] isEqualToString:@""]) {
        _loadStatus = 4;
        [self addAnnotationView:location coord:coords region:[self.navDic objectForKey:@"region"]  address:[self.navDic objectForKey:@"address"]];
        return;
    }
    
    //每次请求位置时，把latitude塞入arr。在block回掉时判断但会latitude是否存在arr且和最近一次请求latitude一致。如果一致，则显示，否则舍弃
    [self.requestLocArr addObject:[NSString stringWithFormat:@"%.8f",[location coordinate].latitude]];
    self.regionStr = @"";
    self.addressStr = @"";
    self.city = @"";
    self.lastCoords = coords;
    _loadStatus = 3;
    [self addAnnotationView:location coord:coords region:@"加载地址中..." address:nil];
    
    //CLGeocoder ios5之后支持
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
        //判断返回loc和当前最后一次请求loc的latitude是否一致，否则不返回位置信息

        if ([self.requestLocArr count] > 0) {
            [self.requestLocArr removeAllObjects];
        }
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            NSString *region = [placemark.addressDictionary objectForKey:@"SubLocality"];
            NSString *address = [placemark.addressDictionary objectForKey:@"Name"];
            self.regionStr = region;
            self.addressStr = address;
            self.city = placemark.administrativeArea ? placemark.administrativeArea : @"";
            

            _loadStatus = 4;
            [self addAnnotationView:location coord:coords region:region address:address];
        }else{
            self.regionStr = @"";
            self.addressStr = @"";
            self.city = @"";
            
    
            _loadStatus = 5;
            [self addAnnotationView:location coord:coords region:@"没有找到有效地址" address:nil];
        }
    }];
    
    if (_lastCoords.latitude && _lastCoords.longitude) {
        NSMutableDictionary *locationDic = [[NSMutableDictionary alloc] init];
        [locationDic setValue:self.addressStr forKey:@"address"];
        [locationDic setValue:self.city forKey:@"city"];
        [locationDic setValue:self.regionStr forKey:@"region"];
        [locationDic setValue:[NSString stringWithFormat:@"%.8f",_lastCoords.latitude] forKey:@"google_lat"];
        [locationDic setValue:[NSString stringWithFormat:@"%.8f",_lastCoords.longitude] forKey:@"google_lng"];
        [locationDic setValue:@"google" forKey:@"from_map_type"];
        self.navDic = locationDic;
    }
}

#pragma mark- 添加大头针的标注
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
    
    if (_loadStatus == 0) {
        self.regionAnnotation.annotationStatus = ChooseLoading;
    }else if (_loadStatus == 1){
        self.regionAnnotation.annotationStatus = ChooseSuc;
    }else if (_loadStatus == 2){
        self.regionAnnotation.annotationStatus = ChooseFail;
    }else if (_loadStatus == 3){
        self.regionAnnotation.annotationStatus = NaviLoading;
    }else if (_loadStatus == 4){
        self.regionAnnotation.annotationStatus = NaviSuc;
    }else if (_loadStatus == 5){
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
    if ([annotation isKindOfClass:[_regionAnnotation class]]) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
