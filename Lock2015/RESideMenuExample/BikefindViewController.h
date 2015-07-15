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

@interface BikefindViewController : UIViewController <HSDatePickerViewControllerDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *datelabel2;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *selectedDate2;
- (IBAction)tofind:(id)sender;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;

@end
