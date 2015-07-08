//
//  SettingViewController.m
//  IntelLock
//
//  Created by shen on 15/7/7.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@property UITableView *tableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:202/255.0 blue:101/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"burger"]];
    
    [self addtableview];

}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

-(void)addtableview{
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)+40) style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return 1;
    }
    else if (section==1) {
        return 1;
    }
    else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = (int)indexPath.section;
    int row = (int)indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    switch (section) {
        case 0:
            switch (row) {
                case 0:
                    cell.textLabel.text = @"手势设置";
                    cell.detailTextLabel.text=@"已设置";
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (row) {
                case 0:
                    cell.textLabel.text = @"自动上锁";
                    cell.detailTextLabel.text=@"否";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
