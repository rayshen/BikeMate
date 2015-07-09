//
//  DEMOSecondViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "BikefindViewController.h"

@implementation BikefindViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"车辆找回";
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:202/255.0 blue:101/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"burger"]];

    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.image = [UIImage imageNamed:@"pic1"];
    [self.view insertSubview:imageView atIndex:0];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)showDatePicker:(id)sender {
    UIButton *selectbutton=(UIButton*)sender;
    HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
    hsdpvc.delegate = self;
    if (self.selectedDate) {
        hsdpvc.date = self.selectedDate;
    }
    hsdpvc.index=(int)selectbutton.tag;
    [self presentViewController:hsdpvc animated:YES completion:nil];
}

#pragma mark - HSDatePickerViewControllerDelegate
- (void)hsDatePickerPickedDate:(NSDate *)date indexofbutton:(int)index{
    NSLog(@"Date picked %@", date);
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    dateFormater.dateFormat = @"yyyy.MM.dd HH:mm";
    
    if (index==1) {
        self.dateLabel.text = [dateFormater stringFromDate:date];
        self.dateLabel.textColor=[UIColor greenColor];
        self.selectedDate = date;
    }
    
    if(index==2){
        self.datelabel2.text = [dateFormater stringFromDate:date];
        self.datelabel2.textColor=[UIColor greenColor];
        self.selectedDate2 = date;
    }
}

//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker did dismiss with %lu", method);
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker will dismiss with %lu", method);
}
- (IBAction)tofind:(id)sender {
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];

}

//添加侧滑手势
-(void)addges{
    _rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(gotoright)];
    _rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:_rightSwipe];
}

-(void)gotoright{
    
}
@end
