//
//  DEMOFirstViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "IndexViewController.h"

@interface IndexViewController (){
    CGFloat batteryvalue;
}

@property BOOL isOnLock;
@property BOOL DeviceisAround;

@end

@implementation IndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //假如需要导航条
    [self firstusingtest];
    [self connectingtest];
	self.title = @"首页";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Right"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentRightMenuViewController:)];
    
    //判断连接状态
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.image = [UIImage imageNamed:@"Balloon"];
    [self.view insertSubview:imageView atIndex:0];
    
    /**加锁解锁*/
    _isOnLock=NO;
    [_sidebutton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [_setbutton addTarget:self action:@selector(presentRightMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    if (_isOnLock==YES) {
        [_lockbutton setImage:[UIImage imageNamed:@"onlock"] forState:UIControlStateNormal];
    }else{
        [_lockbutton setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];
    }
    [_lockbutton addTarget:self action:@selector(lockbuttonclk:) forControlEvents:UIControlEventTouchUpInside];
    
    /**电池*/
    batteryvalue = 50;
    _chart.delegate = self;
    _chart.dataSource = self;
    [_chart reloadData];

    
    if(_isConnected==YES){
        [_connectingstatelabel setText:@"已连接"];
        [_connectingstatelabel setTextColor:[UIColor greenColor]];
           }else{
        [_connectingstatelabel setText:@"未连接"];
        [_connectingstatelabel setTextColor:[UIColor redColor]];
        [self connectingDiscover];
    }
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

/****************函数区域****************/
-(void)firstusingtest{
    if(_isFirstusing==YES){
        UIAlertView *ConnetionTips=[[UIAlertView alloc] initWithTitle:@"绑定成功" message:@"请尽情享受您的骑车之旅吧~" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        ConnetionTips.tag=1;
        [ConnetionTips show];
    }
}

-(void)connectingtest{
    //_isConnected=NO;
    
}


-(void)connectingDiscover{
    _DeviceisAround=YES;
    if(_DeviceisAround==YES){
        [self alertConnetionTips];
    }
}

-(void)alertConnetionTips{
    UIAlertView *ConnetionTips=[[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到您的周边" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"一键连接",nil];
    ConnetionTips.tag=2;
    [ConnetionTips show];
}

#pragma alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2&&buttonIndex==1) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"连接蓝牙中";
        [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
        }
}

-(void)lockbuttonclk:(id)sender{
    if (_isOnLock==YES) {
        _isOnLock=NO;
        [_lockbutton setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];

    }else{
        _isOnLock=YES;
        [_lockbutton setImage:[UIImage imageNamed:@"onlock"] forState:UIControlStateNormal];
    }

}

- (void)myTask {
    sleep(3);
}
#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    NSLog(@"loading over");
    [HUD removeFromSuperview];
    HUD = nil;
    [self toconnect];
}

-(void)toconnect{
    [_connectingstatelabel setText:@"已连接"];
    [_connectingstatelabel setTextColor:[UIColor greenColor]];
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
