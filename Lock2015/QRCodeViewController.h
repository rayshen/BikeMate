//
//  RootViewController.h
//  NewProject
//
//  Created by 学鸿 张 on 13-11-29.
//  Copyright (c) 2013年 Steven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "RESideMenu.h"

@interface QRCodeViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate,MBProgressHUDDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    MBProgressHUD *HUD;
    long long expectedLength;
    long long currentLength;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;
@end
