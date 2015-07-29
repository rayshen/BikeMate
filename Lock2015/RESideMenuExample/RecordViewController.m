//
//  DEMOSecondViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "RecordViewController.h"

@implementation RecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
	self.title = @"行车记录";
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:202/255.0 blue:101/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"burger"]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开始行车"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(newrecord:)];
    [_sidemenu addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self updateViews];
    /*
    //加载等待视图
    self.panelView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.panelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.panelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.frame = CGRectMake((self.view.frame.size.width - self.loadingView.frame.size.width) / 2, (self.view.frame.size.height - self.loadingView.frame.size.height) / 2, self.loadingView.frame.size.width, self.loadingView.frame.size.height);
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.panelView addSubview:self.loadingView];
     */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

-(void)newrecord:(id)sender{
    
}

- (IBAction)tonavi:(id)sender {
    MapViewController *MVC=[[MapViewController alloc]init];
    MVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:MVC animated:YES completion:nil];
    
    /*
    MapViewController *MapVC=[[MapViewController alloc]init];
    MapVC.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:MapVC animated:YES completion:nil];
     */
}

- (IBAction)sharebtn:(id)sender {
    [self screenShare];
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _updatetimes++;
    NSLog(@"%@", locations);
    if (_currentLocation == nil) {
        _currentLocation = (CLLocation *)[locations lastObject];
        _oldLocation = (CLLocation *)[locations lastObject];
    }else{
        if (_updatetimes>1) {
            _currentLocation = (CLLocation *)[locations lastObject];
            _currentSpeed =[_currentLocation speed]*3.6;
            
            double Distance =(double)[_currentLocation distanceFromLocation:_oldLocation];
            _totalDistance+=fabs(Distance)/1000;
            
            _oldLocation=_currentLocation;
            [self updateViews];
        }
    }
}

-(void)updateViews{
    if (_currentSpeed<0) {
        self.speedlabel.text=@"0";
    }else{
        self.speedlabel.text=[NSString stringWithFormat:@"%.1f",_currentSpeed];
    }
    self.distancelabel.text=[NSString stringWithFormat:@"%.2f",_totalDistance];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"totalmiles"]==nil) {
        NSLog(@"没有记录");
        self.totlemileslabel.text=@"0";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"0" forKey:@"totalmiles"];
        [defaults setValue:@"0" forKey:@"totalcalorie"];
        [defaults synchronize];//这句话的意义在于写入硬盘，必须。
        _totlemileslabel.text=@"0";
        _totalcalorielabel.text=@"0";
    }else{
        _totalmiles=[[[NSUserDefaults standardUserDefaults] valueForKey:@"totalmiles"] doubleValue];
        _totalcalorie=[[[NSUserDefaults standardUserDefaults] valueForKey:@"totalcalorie"] doubleValue];
        _totalmiles+=_totalDistance;
        _totalcalorie+=36*_totalDistance;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSString stringWithFormat:@"%.2f",_totalmiles] forKey:@"totalmiles"];
        [defaults setValue:[NSString stringWithFormat:@"%.2f",_totalcalorie] forKey:@"totalcalorie"];
        [defaults synchronize];//这句话的意义在于写入硬盘，必须。
        _totlemileslabel.text=[NSString stringWithFormat:@"%.2f",_totalmiles];
        _totalcalorielabel.text=[NSString stringWithFormat:@"%.0f",_totalcalorie];
    }
}

#pragma mark -

/**
 *  显示加载动画
 *
 *  @param flag YES 显示，NO 不显示
 */
- (void)showLoadingView:(BOOL)flag
{
    if (flag)
    {
        [self.view addSubview:self.panelView];
        [self.loadingView startAnimating];
    }
    else
    {
        [self.panelView removeFromSuperview];
    }
}

#pragma mark 屏幕截图分享

/**
 *  屏幕截图分享
 */
- (void)screenShare
{
    /**
     * 使用ShareSDKExtension插件可以实现屏幕截图分享，对于原生界面和OpenGL的游戏界面同样适用
     * 通过使用SSEShareHelper可以调用屏幕截图分享方法，在方法的第一个参数里面可以取得截图图片和分享处理入口，只要构造分享内容后，将要分享的内容和平台传入分享处理入口即可。
     *
     * 小技巧：
     * 当取得屏幕截图后，如果shareHandler入口不满足分享需求（如截取屏幕后需要弹出分享菜单而不是直接分享），可以不调用shareHandler进行分享，而是在block中写入自定义的分享操作。
     * 这样的话截屏分享接口实质只充当获取屏幕截图的功能。
     **/
    
    __weak RecordViewController *theController = self;
    [theController showLoadingView:YES];
    
    [SSEShareHelper screenCaptureShare:^(SSDKImage *image, SSEShareHandler shareHandler) {
        
        if (!image)
        {
            //如果无法取得屏幕截图则使用默认图片
            image = [[SSDKImage alloc] initWithImage:[UIImage imageNamed:@"shareImg.png"] format:SSDKImageFormatJpeg settings:nil];
        }
        
        //构造分享参数
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"我正在使用BikeMate自行车智能车载系统，快来跟我一起体验骑行的乐趣吧~" images:@[image] url:nil title:nil type:SSDKContentTypeImage];
        
        //回调分享
        if (shareHandler)
        {
            shareHandler (SSDKPlatformTypeSinaWeibo, shareParams);
        }
        
        
    } onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            case SSDKResponseStateFail:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                    message:[NSString stringWithFormat:@"%@", error]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            case SSDKResponseStateCancel:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            default:
                break;
        }
        
        [theController showLoadingView:NO];
    }];
}

@end
