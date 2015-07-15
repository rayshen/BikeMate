//
//  DEMOSecondViewController.h
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "DBTileButton.h"
#import "MapViewController.h"
@interface RecordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *sidemenu;
@property (weak, nonatomic) IBOutlet DBTileButton *navibutton;
- (IBAction)tonavi:(id)sender;

@end
