//
//  DEMOFirstViewController.h
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "CBCCylinderBudgetChartView.h"
#import "MBProgressHUD.h"

@interface IndexViewController : UIViewController<CBCCylinderBudgetChartViewDataSource, CBCCylinderBudgetChartViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}
@property BOOL isFirstusing;
@property BOOL isConnected;

@property (weak, nonatomic) IBOutlet UIButton *sidebutton;
@property (weak, nonatomic) IBOutlet UIButton *setbutton;
@property (weak, nonatomic) IBOutlet UIButton *lockbutton;
@property (weak, nonatomic) IBOutlet CBCCylinderBudgetChartView *chart;
@property (weak, nonatomic) IBOutlet UILabel *connectingstatelabel;

@end
