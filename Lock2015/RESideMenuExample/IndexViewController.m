//
//  DEMOFirstViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "IndexViewController.h"

@interface IndexViewController (){
    enum lockstate{
        isONLOCK,
        isUNLOCK
    };
    
    CGFloat batteryvalue;
}
@property CBCCylinderBudgetChartView *chart;

@property int Lockstate;

@property UIButton *lockbutton;

@end

@implementation IndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"首页";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Right"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentRightMenuViewController:)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.image = [UIImage imageNamed:@"Balloon"];
    [self.view addSubview:imageView];
    
    UIButton *sidebutton=[[UIButton alloc]initWithFrame:CGRectMake(16, 20, 48, 48)];
    [sidebutton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    [sidebutton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sidebutton];
    
    UIButton *setbutton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-60, self.view.bounds.size.height-60, 48, 48)];
    [setbutton setImage:[UIImage imageNamed:@"IconSettings"] forState:UIControlStateNormal];
    [setbutton addTarget:self action:@selector(presentRightMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setbutton];
    
    _lockbutton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2-65,self.view.bounds.size.height/2-150, 150, 150)];
    [_lockbutton setImage:[UIImage imageNamed:@"onlock"] forState:UIControlStateNormal];
    [_lockbutton addTarget:self action:@selector(lockbuttonclk:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_lockbutton];
    _Lockstate=isONLOCK;
    
    //===========================================
    _chart=[[CBCCylinderBudgetChartView alloc]initWithFrame:CGRectMake(20,self.view.bounds.size.height-120, 50, 100)];
    [self.view addSubview:_chart];
    batteryvalue = 50;
    self.chart.delegate = self;
    self.chart.dataSource = self;
    [self.chart reloadData];
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

-(void)lockbuttonclk:(id)sender{
    if (_Lockstate==isONLOCK) {
        _Lockstate=isUNLOCK;
        [_lockbutton setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];

    }else{
        _Lockstate=isONLOCK;
        [_lockbutton setImage:[UIImage imageNamed:@"onlock"] forState:UIControlStateNormal];
    }

}

#pragma mark DataSource
-(CGFloat)totalValueForChart:(CBCCylinderBudgetChartView*) chart {
    return 100;
}

-(CGFloat)fillValueForChart:(CBCCylinderBudgetChartView*) chart {
    return batteryvalue;
}

-(NSString*) totalTextWithValue:(CGFloat)value1 ForChart:(CBCCylinderBudgetChartView*) chart {
    return @"电量";
}

#pragma mark Delegate
-(UIColor*)backgroundColorForChart:(CBCCylinderBudgetChartView*) chart {
    return [UIColor whiteColor];
}

-(UIColor*)fillColorForChart:(CBCCylinderBudgetChartView*) chart {
    CGFloat red = 100 - batteryvalue;
    CGFloat green = batteryvalue;
    
    red = red / 100.0;
    green = green / 100.0;
    
    return [UIColor colorWithRed:red green:green blue:0 alpha:1.0];
}

-(UIFont*)fillValueFontForChart:(CBCCylinderBudgetChartView*) chart {
    return [UIFont boldSystemFontOfSize:14];
}

-(UIFont*)totalValueFontForChart:(CBCCylinderBudgetChartView*) chart {
    return [UIFont boldSystemFontOfSize:14];
}

-(UIColor*)fillValueFontColorForChart:(CBCCylinderBudgetChartView*) chart {
    CGFloat color = batteryvalue;
    if(batteryvalue < 50)
        color = 0;
    if(batteryvalue >=50)
        color = 100;
    color /= 100;
    
    return [UIColor colorWithRed: color green: color blue:color alpha:1];
}

-(UIColor*)totalValueFontColorForChart:(CBCCylinderBudgetChartView*) chart {
    return [UIColor whiteColor];
}

-(CGFloat)totalValueHeightForChart:(CBCCylinderBudgetChartView*)chart {
    return 20;
}

-(CGFloat)fillValueHeightForChart:(CBCCylinderBudgetChartView*)chart {
    return 20;
}

-(BOOL)shouldShowTotalValueForChart:(CBCCylinderBudgetChartView*)chart {
    return YES;
}

-(BOOL)shouldShowFillValueForChart:(CBCCylinderBudgetChartView*)chart {
    if(batteryvalue == 0)
        return NO;
    return YES;
}

-(UIColor*)gradientColorForChart:(CBCCylinderBudgetChartView*) chart {
    return [UIColor brownColor];
}

-(CGFloat)gradientAlpha:(CBCCylinderBudgetChartView*) chart {
    return 0.3;
}
@end
