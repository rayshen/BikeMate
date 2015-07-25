//
//  BikerouteViewController.m
//  Lock2015
//
//  Created by shen on 15/7/25.
//  Copyright (c) 2015年 shen. All rights reserved.
//


#import "BikerouteViewController.h"
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


@interface BikerouteViewController ()
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

@property (weak, nonatomic) IBOutlet UIButton *goUserLocBtn;

@property MKRoute *Naviroute;
@property MKRoute *Myroute;
@property NSMutableArray *nowRoadArray;
@property QSearchViewController *QSVC;
@property CLLocation *loation;
@end

CLLocationCoordinate2D myCoords[];
@implementation BikerouteViewController

- (NSInteger)windowWidth {
    return [[[[UIApplication sharedApplication] windows] objectAtIndex:0] frame].size.width;
}
- (NSInteger)windowHeight {
    return [[[[UIApplication sharedApplication] windows] objectAtIndex:0] frame].size.height;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.regionMapView.delegate = self;
    self.regionMapView.showsUserLocation = YES;
    
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager setDelegate:self];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    [_goUserLocBtn addTarget:self action:@selector(goUserLoc:) forControlEvents:UIControlEventTouchUpInside];
    [_goUserLocBtn setImage:[UIImage imageNamed:@"wl_map_icon_position"] forState:UIControlStateNormal];
    
    [self.view bringSubviewToFront:_goUserLocBtn];
    
    int resultnum;
    for (NSDictionary *suchdic in _resultdic) {
        _loation=[[CLLocation alloc] initWithLatitude:[[suchdic valueForKey:@"latitude"] floatValue] longitude:[[suchdic valueForKey:@"longitude"] floatValue]];
        CLLocationCoordinate2D suchCoords=[_loation coordinate];
        myCoords[resultnum]=suchCoords;
        resultnum++;
    }
    
    Routepolyline *cc = [Routepolyline polylineWithCoordinates:myCoords count:[_resultdic count]];//执行画线方法
    [self.regionMapView insertOverlay:cc atIndex:2];
    self.lastRegion = MKCoordinateRegionMakeWithDistance([_loation coordinate], 200, 200);
    [self.regionMapView setRegion:self.lastRegion animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    _QSVC=[[QSearchViewController alloc]init];
    _QSVC.delegate=self;
    _QSVC.myregion=_myregion;
    _QSVC.city=self.city;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_QSVC];
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
    if(_updateInt>0){
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
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:_nowCoords addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:_naviCoordsGd addressDictionary:nil];
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
    _updateInt++;
    
    _userlocation=userLocation;
    self.nowCoords = [userLocation coordinate];
    
    //存路线
    [_nowRoadArray addObject:userLocation];
    
    //放大地图到自身的经纬度位置。
    self.userRegion = MKCoordinateRegionMakeWithDistance(self.nowCoords, 200, 200);
    if(_iffollowed==YES){
        [self.regionMapView setRegion:self.userRegion animated:NO];
    }
    //仅在打开地图后，第一次更新地理信息时，确定使用者的大致地理位置
    if (_updateInt<=1) {
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
                [_QSVC setCity:self.city];
                NSLog(@"当前使用者所在：地点名：%@，地址：%@，城市：%@",self.regionStr,self.addressStr,self.city);
            }else{
                self.regionStr = @"";
                self.addressStr = @"";
                self.city = @"";
                NSLog(@"未查询到有效地址");
            }
        }];
    }else{

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
        _loadStatus = 4;
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
    
    if (_loadStatus == 0) {
        self.regionAnnotation.annotationStatus = ChooseLoading;
    }else if (_loadStatus == 1){
        self.regionAnnotation.annotationStatus = ChooseSuc;
    }else if (_loadStatus == 2){
        self.regionAnnotation.annotationStatus = ChooseFail;
    }else if (_loadStatus == 3){
        self.regionAnnotation.annotationStatus = NaviLoading;
    }else if (_loadStatus == 4){
        //带导航按钮的点
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
    if ([annotation isKindOfClass:[RegionAnnotation class]]) {
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
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:_naviCoordsGd.latitude longitude:_naviCoordsGd.longitude];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_naviCoordsGd, 500, 500);
    self.naviRegion = [self.regionMapView regionThatFits:viewRegion];
    [self showAnnotation:loc coord:_naviCoordsGd];
    [self.regionMapView setRegion:self.naviRegion animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
