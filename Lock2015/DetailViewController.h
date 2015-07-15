//
//  DetailTableViewController.h
//  ShenBluetooth
//
//  Created by shen on 15/5/9.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DetailViewController : UIViewController<
CBPeripheralManagerDelegate,
CBCentralManagerDelegate,
CBPeripheralDelegate
>

@property (nonatomic, strong) CBCentralManager *centralMgr;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong) CBService *thisService;
@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;

// tableview sections，保存蓝牙设备里面的services字典，字典第一个为service，剩下是特性与值
@property (nonatomic, strong) NSMutableArray *arrayServices;

// 用来记录有多少特性，当全部特性保存完毕，刷新列表
@property (atomic, assign) int characteristicNum;
@property (weak, nonatomic) IBOutlet UILabel *thelabel;

@property int current_humitidy;
@property int current_temperature;

@property NSTimer *updatetimer;
- (IBAction)led1control:(id)sender;
- (IBAction)led2control:(id)sender;
- (IBAction)led3control:(id)sender;
- (IBAction)jdqcontrol:(id)sender;


@end
