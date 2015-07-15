//
//  RegionAnnotationView.h
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-19.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "RegionAnnotation.h"

@protocol doAcSheetDelegate <NSObject>
-(void)naviClick;
@end

@interface RegionAnnotationView : MKAnnotationView
@property(nonatomic,strong) UIView *regionDetailView;
@property(nonatomic,strong) UIImageView *bgImgView;
@property(nonatomic,assign) id<doAcSheetDelegate>acSheetDelegate;
@property(nonatomic,assign) BOOL isBroker;
@property(nonatomic,strong) RegionAnnotation *regionAnnotaytion;
- (void)layoutSubviews;
@end
