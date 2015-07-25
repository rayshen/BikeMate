//
//  DEMORightMenuViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 2/11/14.
//  Copyright (c) 2014 Roman Efimov. All rights reserved.
//

#import "DEMORightMenuViewController.h"
#import "IndexViewController.h"
#import "RecordViewController.h"
#import "DEMOLeftMenuViewController.h"

@interface DEMORightMenuViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;
@property int sumitems;
@property UIAlertView *ConnetionTips;
@end

UISwitch *switchview;

@implementation DEMORightMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sumitems=1;
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-220, (self.view.frame.size.height - 54 * _sumitems) / 2.0f, 220, 54 * _sumitems) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
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
    
    if([[notification userInfo] objectForKey:@"RingState"]){
        NSString *state=[[notification userInfo] objectForKey:@"RingState"];
        [self setRingState:state];
    }
}

-(void)setConnectState:(NSString *)string{
    if ([string isEqualToString:@"YES"]) {
        switchview.userInteractionEnabled=YES;
    }
    
    if ([string isEqualToString:@"NO"]) {
        switchview.userInteractionEnabled=NO;
    }
}

-(void)setRingState:(NSString *)string{
    if ([string isEqualToString:@"1"]) {
        [switchview setOn:YES animated:YES];
    }
    
    if ([string isEqualToString:@"0"]) {
        [switchview setOn:NO animated:YES];
    }
}
#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[IndexViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[RecordViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        default:
            break;
    }
    */
    if([AppDelegate getisConnect]==YES){
    
    }else{
        [_ConnetionTips show];
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

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _sumitems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    
    NSArray *items =[[NSArray alloc] initWithObjects:@"防盗鸣笛",@"靠近自动解锁",@"摔倒通知亲友",nil];
    cell.textLabel.text = items[[indexPath row]];
    cell.textLabel.textAlignment = NSTextAlignmentRight;

    
    switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = switchview;
    [switchview addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    switchview.tag=[indexPath row];
    if ([AppDelegate getisConnect]==YES) {
        switchview.userInteractionEnabled=YES;
    }else{
        switchview.userInteractionEnabled=NO;

    }
    return cell;
}

-(void)switchAction:(id)sender{
        UISwitch *switchButton = (UISwitch*)sender;
        BOOL isButtonOn = [switchButton isOn];
        if (isButtonOn) {
                NSLog(@"switchButton %li turn on",(long)switchButton.tag);
                if ((long)switchButton.tag==0) {
                    NSDictionary *dic = @{
                                          @"Operation":@"RINGON",
                                          };
                    [self notifiction:dic forname:@"LOCKCMD"];
                }
            
        }else {
            NSLog(@"switchButton %li turn off",(long)switchButton.tag);
            if ((long)switchButton.tag==0) {
                NSDictionary *dic = @{
                                      @"Operation":@"RINGOFF",
                                      };
                [self notifiction:dic forname:@"LOCKCMD"];
            }
        }
}

-(void)notifiction:(NSDictionary *)dic forname:(NSString *)name{
    NSLog(@"发送通知");
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:dic];
}
@end
