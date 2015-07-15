//
//  RegionAnnotationView.m
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-19.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import "RegionAnnotationView.h"
#import "RegionAnnotation.h"
#import "MapViewController.h"

#define ISIOS6 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=6)

@implementation RegionAnnotationView
@synthesize regionDetailView;
@synthesize acSheetDelegate;
@synthesize bgImgView;
@synthesize isBroker;
@synthesize regionAnnotaytion;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        self.isBroker = YES;
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.canShowCallout = NO;
        [self addCallView];
    }
    return self;
}
- (void)layoutSubviews{
    regionAnnotaytion = self.annotation;
    
    self.canShowCallout = NO;
    switch (regionAnnotaytion.annotationStatus) {
        case ChooseLoading:
            [self loadLoadingView];
            break;
        case ChooseSuc:
            [self loadChooseSucView];
            break;
        case ChooseFail:
            [self loadFailView];
            break;
        case NaviLoading:
            [self loadNaviViewForLoading];
            break;
        case NaviSuc:
            [self loadNaviView];
            break;
        case NaviFail:
            [self loadNaviViewForFail];
            break;
        default:
            break;
    }
}

//- (MKAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier{
//    self.backgroundColor = [UIColor clearColor];
//    self.canShowCallout = NO;
//    [self addCallView];
//
//    return self;
//}


-(void)addCallView{
    regionAnnotaytion = self.annotation;
    
    self.canShowCallout = NO;
    switch (regionAnnotaytion.annotationStatus) {
        case ChooseLoading:
            [self loadLoadingView];
            break;
        case ChooseSuc:
            [self loadChooseSucView];
            break;
        case ChooseFail:
            [self loadFailView];
            break;
        case NaviLoading:
            [self loadNaviViewForLoading];
            break;
        case NaviSuc:
            [self loadNaviView];
            break;
        case NaviFail:
            [self loadNaviViewForFail];
            break;
        default:
            break;
    }
}
-(void)initUI{
    if (self.regionDetailView) {
        [self.regionDetailView removeFromSuperview];
    }
    self.regionDetailView = [[UIView alloc] init];
    self.regionDetailView.backgroundColor = [UIColor clearColor];
    self.bgImgView = [[UIImageView alloc] init];
    self.bgImgView.image = [[UIImage imageNamed:@"wl_map_icon_5.png"] stretchableImageWithLeftCapWidth:28 topCapHeight:16];
    [self.regionDetailView addSubview:self.bgImgView];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
//    if (!ISIOS6) {
//        return;
//    }
//    [super setSelected:selected animated:animated];
//    regionAnnotaytion = self.annotation;
//    self.canShowCallout = NO;
//    if (selected) {
//        switch (regionAnnotaytion.annotationStatus) {
//            case ChooseLoading:
//                [self loadLoadingView];
//                break;
//            case ChooseSuc:
//                [self loadChooseSucView];
//                break;
//            case ChooseFail:
//                [self loadFailView];
//                break;
//            case NaviLoading:
//                [self loadNaviViewForLoading];
//                break;
//            case NaviSuc:
//                [self loadNaviView];
//                break;
//            case NaviFail:
//                [self loadNaviViewForFail];
//                break;
//            default:
//                break;
//        }
//    }
//}

//选址获取地址加载
-(void)loadLoadingView{
    [self initUI];
    [self loadingView:YES];
}
//选址获取地址成功
-(void)loadChooseSucView{
    [self loadViewSuc:YES];
}
//选址获取地址失败
-(void)loadFailView{
    [self loadViewFail:YES];
}
//导航加载地址
-(void)loadNaviViewForLoading{
    [self initUI];
    [self loadingView:NO];
}
//导航获取地址成功
-(void)loadNaviView{
    [self loadViewSuc:NO];
}
//导航获取地址失败
-(void)loadNaviViewForFail{
    [self loadViewFail:NO];
}
//loading view
-(void)loadingView:(BOOL)chooseLoad{
    [self initUI];
    if (chooseLoad) {
        CGRect bgCgrect = CGRectMake(-60, -80, 120, 56);
        self.regionDetailView.frame = bgCgrect;
        [self addConner:bgCgrect];
    }else{
        CGRect anFrame = CGRectMake(0, 0, 185, 162);
        [self addCenter:anFrame];
        
        self.frame = anFrame;
        self.backgroundColor = [UIColor clearColor];
        
        CGRect bgCgrect = CGRectMake(0, 0, 185, 56);
        self.regionDetailView.frame = bgCgrect;
        [self addConner:bgCgrect];
        
        [self createBtn:120];
    }
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = CGRectMake(0, 0, 30, 46);
    [regionDetailView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    UILabel *loadingLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 90, 46)];
    loadingLab.text = @"加载地址中...";
    loadingLab.font = [UIFont systemFontOfSize:14];
    loadingLab.textColor = [UIColor whiteColor];
    loadingLab.backgroundColor = [UIColor clearColor];
    [regionDetailView addSubview:loadingLab];
    
    [self addSubview:regionDetailView];
}
//loading view suc
-(void)loadViewSuc:(BOOL)chooseLoad{
    [self initUI];
    float maxWidth;
    if (chooseLoad) {
        maxWidth = 290.0;
    }else{
        maxWidth = 235.0;
    }
    
    CGSize addSize1 = [self getSizeOfString:self.regionAnnotaytion.subtitle maxWidth:maxWidth withFontSize:14];
    CGSize addSize2 = [self getSizeOfString:self.regionAnnotaytion.subtitle maxWidth:maxWidth withFontSize:12];
    float width = ([self commpareWith:addSize1 size2:addSize2] <= 80) ? 80 : [self commpareWith:addSize1 size2:addSize2];

    if (chooseLoad) {
        CGRect bgCgrect = CGRectMake(-(width+10)/2, -80, width+10, 56);
        
        regionDetailView.frame = bgCgrect;
        [self addConner:bgCgrect];
    
    }else{
        CGRect anFrame = CGRectMake(0, 0, width+10+65, 162);
        [self addCenter:anFrame];
        
        self.frame = anFrame;
        self.backgroundColor = [UIColor clearColor];
        
        CGRect bgCgrect = CGRectMake(0, 0, width+10+65, 56);
        
        regionDetailView.frame = bgCgrect;
        [self addConner:bgCgrect];
        
        [self createBtn:width+10];
    }
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.frame = CGRectMake(5, 5, width, 15);
    titleLab.font = [UIFont systemFontOfSize:13];
    titleLab.text = self.regionAnnotaytion.title;
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.font = [UIFont systemFontOfSize:14];
    titleLab.textColor = [UIColor whiteColor];
    [regionDetailView addSubview:titleLab];
    
    UILabel *subtitleLab = [[UILabel alloc] init];
    subtitleLab.frame = CGRectMake(5, 25, width, 15);
    subtitleLab.font = [UIFont systemFontOfSize:12];
    subtitleLab.text = self.regionAnnotaytion.subtitle;
    subtitleLab.textColor = [UIColor whiteColor];
    subtitleLab.backgroundColor = [UIColor clearColor];
    [regionDetailView addSubview:subtitleLab];
    
    [self addSubview:regionDetailView];
}
//load fail view
-(void)loadViewFail:(BOOL)chooseLoad{
    [self initUI];
    if (chooseLoad) {
        CGRect bgCgrect = CGRectMake(-60, -80, 120, 56);
        
        regionDetailView.frame = bgCgrect;
        [self addConner:bgCgrect];
    }else{
        CGRect anFrame = CGRectMake(0, 0, 185, 162);
        [self addCenter:anFrame];
        
        self.frame = anFrame;
        self.backgroundColor = [UIColor clearColor];
        
        CGRect bgCgrect = CGRectMake(0, 0, 185, 56);
        
        regionDetailView.frame = bgCgrect;
        [self addConner:bgCgrect];
        
        [self createBtn:120];
    }
    UILabel *addressLab = [[UILabel alloc] init];
    addressLab.frame = CGRectMake(0, 0, 120, 46);
    addressLab.font = [UIFont systemFontOfSize:14];
    if (chooseLoad) {
        addressLab.text = @"重新滑动寻址";
    }else{
        addressLab.text = @"加载地址失败";
    }
    addressLab.textColor = [UIColor whiteColor];
    addressLab.backgroundColor = [UIColor clearColor];
    addressLab.textAlignment = NSTextAlignmentCenter;
    [regionDetailView addSubview:addressLab];

    [self addSubview:regionDetailView];
}

//navi button
-(void)createBtn:(float)width{
    UIButton *naviBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    naviBtn.backgroundColor = [UIColor clearColor];
    [naviBtn addTarget:self action:@selector(naviMap:) forControlEvents:UIControlEventTouchUpInside];
    if (self.isBroker) {
        [naviBtn setImage:[UIImage imageNamed:@"anjuke_icon_to_position.png"] forState:UIControlStateNormal];
        [naviBtn setImage:[UIImage imageNamed:@"anjuke_icon_to_position1.png"] forState:UIControlStateHighlighted];
    }else{
        [naviBtn setImage:[UIImage imageNamed:@"wl_map_icon_1.png"] forState:UIControlStateNormal];
        [naviBtn setImage:[UIImage imageNamed:@"wl_map_icon_1_press.png"] forState:UIControlStateHighlighted];
    }
    naviBtn.frame = CGRectMake(width, 0, 65, 46);
    [self.regionDetailView addSubview:naviBtn];
}

#pragma mark-
#pragma acSheetDelegate
-(void)naviMap:(id)sender{
    [acSheetDelegate naviClick];
}
// 获取指定最大宽度和字体大小的string的size
- (CGSize)getSizeOfString:(NSString *)string maxWidth:(float)width withFontSize:(int)fontSize {
	UIFont *font = [UIFont systemFontOfSize:fontSize];
	CGSize size = [string sizeWithFont:font constrainedToSize:CGSizeMake(width, 10000.0f) lineBreakMode:NSLineBreakByWordWrapping];
	return size;
}
//添加尖角图片
-(void)addConner:(CGRect)rect{
    self.bgImgView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height-10);
    
    UIImageView *connerView = [[UIImageView alloc] initWithFrame:CGRectMake((rect.size.width-16)/2, rect.size.height-10, 16, 10)];
    connerView.image = [UIImage imageNamed:@"wl_map_icon_4.png"];
    
    [self.bgImgView addSubview:connerView];
}
//RegionAnnotationView中心定位
-(void)addCenter:(CGRect)anFrame{
    UIImageView *locImg = [[UIImageView alloc] init];
    locImg.frame = CGRectMake((anFrame.size.width-16)/2, 56, 16, 33);
    locImg.image = [UIImage imageNamed:@"anjuke_icon_itis_position.png"];
    [self.regionDetailView addSubview:locImg];
}
//判断title和subtitle宽度
-(float)commpareWith:(CGSize)size1 size2:(CGSize)size2{
    if (size1.width >= size2.width) {
        return size1.width;
    }else{
        return size2.width;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

