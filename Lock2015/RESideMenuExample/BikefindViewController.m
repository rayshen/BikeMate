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
    
    [_bgview setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.5]];
    
    [self addges];
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
        _recordTime = [_selectedDate timeIntervalSince1970];
    }
    
    if(index==2){
        self.datelabel2.text = [dateFormater stringFromDate:date];
        self.datelabel2.textColor=[UIColor greenColor];
        self.selectedDate2 = date;
        _recordTime2 = [_selectedDate2 timeIntervalSince1970];
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
    
    NSString *urlstr=[NSString stringWithFormat:@"http://dong14lock.aliapp.com/position/%@/%@",[AppDelegate getlockUUID],[AppDelegate getphoneUUID]];
    NSDictionary *searchdic=@{
                              @"time_from":[NSString stringWithFormat:@"%llu",_recordTime],
                              @"time_to":[NSString stringWithFormat:@"%llu",_recordTime2],
                              @"pageSize":@"1000",
                              @"pageNo":@"1"
                              };
    
    [[ShenAFN shenInstance] JSONDataWithUrl:urlstr parameter:searchdic success:^(id jsondata) {
        NSLog(@"%@",jsondata);
    } fail:^{
        NSLog(@"请求失败");
    }];

}

//添加侧滑手势
-(void)addges{
    _leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(gotoright)];
    _leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftSwipe.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:_leftSwipe];
}

-(void)gotoright{
    NSLog(@"检测有左滑");
}
@end
