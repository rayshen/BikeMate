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
    //self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:202/255.0 blue:101/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"burger"]];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.image = [UIImage imageNamed:@"Balloon"];
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
    if(_recordTime>_recordTime2||_recordTime==0||_recordTime2==0){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"您选择的时间有误" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
        return;
    }
    // The hud will dispable all input on the window
    HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"网络查询查询中...";
    [HUD showWhileExecuting:@selector(URLrequest) onTarget:self withObject:nil animated:YES];
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


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    NSLog(@"loading over");
    [HUD removeFromSuperview];
    HUD = nil;
    if(_iflost==YES){
        NSLog(@"找到丢失记录");
        BikerouteViewController *BrVC=[[BikerouteViewController alloc]init];
        BrVC.resultdic=_resultdic;
        [self.navigationController pushViewController:BrVC animated:YES];
    }
}

-(void)URLrequest{
    // 初始化请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *url=[NSString stringWithFormat:@"http://dong14lock.aliapp.com/position/%@/%@?pageSize=9999&pageNo=1&time_from=%llu&time_to=%llu",[AppDelegate getlockUUID],[AppDelegate getphoneUUID],_recordTime,_recordTime2];
    // 设置URL
    [request setURL:[NSURL URLWithString:url]];
    // 设置HTTP方法
    [request setHTTPMethod:@"GET"];
    // 发 送同步请求, 这里得returnData就是返回得数据了
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    NSString *returnstr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [returnstr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSLog(@"%@",dic);
    if ([dic valueForKey:@"status"]) {
        NSLog(@"%@",[dic valueForKey:@"status"]);
        NSNumber *intNumber = [NSNumber numberWithInteger:0];
        
        if([[dic valueForKey:@"status"] isEqualToNumber:intNumber]){
            NSDictionary *datadic=[dic valueForKey:@"data"];
            if([datadic valueForKey:@"result"]){
                _resultdic=[datadic valueForKey:@"result"];
                _iflost=YES;
            }else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"没有查询到丢失记录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
                [alert show];
            }
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"该锁还未登记吧" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alert show];
        }
    }
}
@end
