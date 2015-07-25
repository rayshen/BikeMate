//
//  DEMOSecondViewController.h
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "HSDatePickerViewController.h"
#import "ShenAFN.h"
#import "AppDelegate.h"
#import "MapViewController.h"
@interface BikefindViewController : UIViewController <HSDatePickerViewControllerDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *datelabel2;
@property UInt64 recordTime;
@property UInt64 recordTime2;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *selectedDate2;
- (IBAction)tofind:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bgview;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;

@end
