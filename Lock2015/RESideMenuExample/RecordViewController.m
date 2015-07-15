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
    UIButton *sidebutton=[[UIButton alloc]initWithFrame:CGRectMake(16, self.view.bounds.size.height-60, 30, 30)];
    [sidebutton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    [sidebutton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sidebutton];
    */
    [_sidemenu addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
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

-(void)newrecord:(id)sender{
    
}

- (IBAction)tonavi:(id)sender {
    
    MapViewController *MVC=[[MapViewController alloc]init];
    MVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:MVC animated:YES completion:nil];
    
    /*
    MapViewController *MapVC=[[MapViewController alloc]init];
    MapVC.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:MapVC animated:YES completion:nil];
     */
}
@end
