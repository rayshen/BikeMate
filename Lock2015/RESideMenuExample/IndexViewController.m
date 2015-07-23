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
@property UIAlertView *ConnetionTips;
@end

@implementation IndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([AppDelegate getisConnect]==YES){
        [self setConnectState:@"YES"];
    }else{
        [self setConnectState:@"NO"];
    }

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
    [self.view insertSubview:imageView atIndex:0];
    
    /**加锁解锁*/
    [_sidebutton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [_setbutton addTarget:self action:@selector(presentRightMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([AppDelegate getisOnlock]==YES) {
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

    _ConnetionTips=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有连接蓝牙，现在进行搜索设备并连接吗？" delegate:self cancelButtonTitle:@"搜索" otherButtonTitles:nil];
    _ConnetionTips.tag=2;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBLEstate:) name:@"APPDelegate" object:nil];
}

-(void)changeBLEstate:(NSNotification*)notification
{
    NSLog(@"%@",[notification userInfo]);
    if([[notification userInfo] objectForKey:@"ConnectState"]){
        NSString *state=[[notification userInfo] objectForKey:@"ConnectState"];
        [self setConnectState:state];
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


-(void)setConnectState:(NSString *)string{
    if ([string isEqualToString:@"YES"]) {
        [_connectingstatelabel setText:@"已连接"];
        [_connectingstatelabel setTextColor:[UIColor greenColor]];
    }
    
    if ([string isEqualToString:@"NO"]) {
        [_connectingstatelabel setText:@"未连接"];
        [_connectingstatelabel setTextColor:[UIColor redColor]];
    }
}
/****************函数区域****************/
-(void)firstusingtest{
    //if(_isFirstusing==YES){
        UIAlertView *ConnetionTips=[[UIAlertView alloc] initWithTitle:@"绑定成功" message:@"请尽情享受您的骑车之旅吧~" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        ConnetionTips.tag=1;
        [ConnetionTips show];
    //}
}

-(void)lockbuttonclk:(id)sender{
    //假如没有连接蓝牙
    if ([AppDelegate getisConnect]==NO) {
        [_ConnetionTips show];
    }else{
        if (_isOnLock==YES) {
            _isOnLock=NO;
            [_lockbutton setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];
            NSDictionary *dic = @{
                                  @"Operation":@"CLOSE",
                                  };
            [self notifiction:dic forname:@"LOCKCMD"];
        }else{
            _isOnLock=YES;
            [_lockbutton setImage:[UIImage imageNamed:@"onlock"] forState:UIControlStateNormal];
            NSDictionary *dic = @{
                                  @"Operation":@"OPEN",
                                  };
            [self notifiction:dic forname:@"LOCKCMD"];
        }
    }
}

#pragma alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2&&buttonIndex==0) {
        [self toSearchBLE];
    }
}

-(void)toSearchBLE{
    //需要连接蓝牙
    NSDictionary *dic = @{
                          @"Operation":@"SEARCH"
                          };
    [self notifiction:dic forname:@"LOCKCMD"];
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

-(void)notifiction:(NSDictionary *)dic forname:(NSString *)name{
    NSLog(@"发送通知");
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:dic];
}
@end
