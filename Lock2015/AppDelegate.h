//
//  AppDelegate.h
//  Lock2015
//
//  Created by shen on 15/7/8.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "FirstpageViewController.h"
#import "QRCodeViewController.h"
#import "BLEInfo.h"
#import "CHKeychain.h"
#import "QRCodeViewController.h"
#import "MBProgressHUD.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,RESideMenuDelegate,CBPeripheralManagerDelegate,
CBCentralManagerDelegate,
CBPeripheralDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CBCentralManager *centralMgr;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong) NSMutableArray *arrayBLE;
@property (nonatomic, strong) CBService *thisService;
@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;
// tableview sections，保存蓝牙设备里面的services字典，字典第一个为service，剩下是特性与值
@property (nonatomic, strong) NSMutableArray *arrayServices;
// 用来记录有多少特性，当全部特性保存完毕，刷新列表
@property (atomic, assign) int characteristicNum;

+(BOOL)getisConnect;
+(BOOL)getisOnlock;
+(NSString *)getphoneUUID;
+(NSString *)getlockUUID;
+(int)getBatteryinfo;
@end

