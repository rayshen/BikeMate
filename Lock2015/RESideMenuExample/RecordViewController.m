//
//  DEMOSecondViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "RecordViewController.h"

@implementation RecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"行车记录";
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:202/255.0 blue:101/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"burger"]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开始行车"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(newrecord:)];
    
    /*
    [self.view addSubview:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(0, 84, self.view.frame.size.width, 44);
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [button setTitle:@"Push View Controller" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pushViewController:) forControlEvents:UIControlEventTouchUpInside];
        button;
    })];*/
    
    [self addtableview];
}

- (void)pushViewController:(id)sender
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"DEMOSecondViewController will appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"DEMOSecondViewController will disappear");
}

-(void)newrecord:(id)sender{
    
}

-(void)addtableview{
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)+40) style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndentifier=@"RecordCell";
    RecordCell * cell=[self.tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"RecordCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    
    cell.nolabel.text=[NSString stringWithFormat:@"No.%ld",[indexPath row]+1];
    cell.dislabel.text=[NSString stringWithFormat:@"Distance: %d km",5];
    //cell.datelabel.text=@"2015.07.08";
    //cell.fromlabel.text=@"";
    //cell.tolabel.text=@"";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


@end
