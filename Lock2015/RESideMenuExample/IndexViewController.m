//
//  DEMOFirstViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "IndexViewController.h"

@interface IndexViewController (){
    enum lockstate{
        isONLOCK,
        isUNLOCK
    };
}

@property int Lockstate;

@property UIButton *lockbutton;

@end

@implementation IndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"首页";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Right"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentRightMenuViewController:)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.image = [UIImage imageNamed:@"Balloon"];
    [self.view addSubview:imageView];
    
    UIButton *sidebutton=[[UIButton alloc]initWithFrame:CGRectMake(16, 20, 48, 48)];
    [sidebutton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    [sidebutton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sidebutton];
    
    _lockbutton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2-65,self.view.bounds.size.height/2-130, 130, 130)];
    [_lockbutton setImage:[UIImage imageNamed:@"onlock"] forState:UIControlStateNormal];
    [_lockbutton addTarget:self action:@selector(lockbuttonclk:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_lockbutton];
    _Lockstate=isONLOCK;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    NSLog(@"DEMOFirstViewController will appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"DEMOFirstViewController will disappear");
}

-(void)lockbuttonclk:(id)sender{
    if (_Lockstate==isONLOCK) {
        _Lockstate=isUNLOCK;
        [_lockbutton setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];

    }else{
        _Lockstate=isONLOCK;
        [_lockbutton setImage:[UIImage imageNamed:@"onlock"] forState:UIControlStateNormal];
    }

}
@end
