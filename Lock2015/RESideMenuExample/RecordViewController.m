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

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", locations);
    if (_currentLocation == nil) {
        _currentLocation = (CLLocation *)[locations lastObject];
        _oldLocation = (CLLocation *)[locations lastObject];
    }else{
        _currentLocation = (CLLocation *)[locations lastObject];
        _currentSpeed =[_currentLocation speed]*3.6;
        
        double Distance =(double)[_currentLocation distanceFromLocation:_oldLocation];
        _totalDistance+=fabs(Distance)/1000;
        
        _oldLocation=_currentLocation;
        [self updateViews];
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

@end
