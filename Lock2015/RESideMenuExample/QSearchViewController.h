//
//  MainViewController.h
//  UISearchDisplayControllerDemo
//
//  Created by Enwaysoft on 14-8-20.
//  Copyright (c) 2014年 Enway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShenAFN.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol UpdateAlertDelegate <NSObject>
- (void)updateAlert:(NSMutableDictionary *)navidic;
@end

@interface QSearchViewController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate>{
    NSMutableArray *recordData;
    NSDictionary *searchResults;
    NSMutableArray *Resultarray;
    NSMutableArray *Resultname;
    NSMutableArray *Resultaddr;
    UISearchDisplayController *searchDisplayController;
}

@property NSString *city;
@property CLRegion *myregion;
@property (nonatomic, weak) id<UpdateAlertDelegate> delegate;

@end
