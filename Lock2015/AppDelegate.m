//
//  AppDelegate.m
//  Lock2015
//
//  Created by shen on 15/7/8.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import "AppDelegate.h"
#import "DEMOLeftMenuViewController.h"
#import "DEMORightMenuViewController.h"
#import "IndexViewController.h"

#define UUIDKEY @"UUID"

@interface AppDelegate ()

@property NSString* PhoneUUID;
@property NSString* LockUUID;
@property NSString* LockState;
@property NSString* Batteryinfo;
@property NSString* Ring;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //第一次用于生成手机的UUID，之后直接读取
    [self uuid];
    
    //[CHKeychain deleteData:@"LOCKUUID"];
    //看DIDUSED，是否第一次登陆
    if(![CHKeychain load:@"LOCKUUID"]){
        NSLog(@"未记录锁UUID");
        FirstpageViewController *FPVC=[[FirstpageViewController alloc]init];
        self.window.rootViewController = FPVC;
    }else{
        _LockUUID=[CHKeychain load:@"LOCKUUID"];
        NSLog(@"已记录锁UUID：%@",_LockUUID);
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[IndexViewController alloc] init]];
        DEMOLeftMenuViewController *leftMenuViewController = [[DEMOLeftMenuViewController alloc] init];
        DEMORightMenuViewController *rightMenuViewController = [[DEMORightMenuViewController alloc] init];
        
        RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController leftMenuViewController:leftMenuViewController rightMenuViewController:rightMenuViewController];
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"Stars"];
        sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
        sideMenuViewController.delegate = self;
        sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
        sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
        sideMenuViewController.contentViewShadowOpacity = 0.6;
        sideMenuViewController.contentViewShadowRadius = 12;
        sideMenuViewController.contentViewShadowEnabled = YES;
        self.window.rootViewController = sideMenuViewController;
        [self connectingDiscover];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Notifictiontodo:) name:@"LOCKCMD" object:nil];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark--获取设备UUID
-(NSString*)uuid{
    if ([CHKeychain load:UUIDKEY]) {
        NSString *result = [CHKeychain load:UUIDKEY];
        _PhoneUUID=result;
        NSLog(@"已存在手机UUID：%@",result);
        return result;
    }
    else
    {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        [CHKeychain save:UUIDKEY data:result];
        NSLog(@"初次创建手机UUID：%@",result);
        _PhoneUUID=result;
        return result;
    }
    return nil;
}

-(void)connectingDiscover{
    self.centralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.arrayBLE = [[NSMutableArray alloc] init];
}

-(void)alertConnetionTips{
    UIAlertView *ConnetionTips=[[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到您的周边" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"一键连接",nil];
    ConnetionTips.tag=2;
    [ConnetionTips show];
}

#pragma alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2&&buttonIndex==1) {
        HUD = [[MBProgressHUD alloc] initWithView:self.window];
        [self.window addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"连接蓝牙中";
        [HUD show:YES];
        [_centralMgr connectPeripheral:_discoveredPeripheral options:nil];

    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    NSLog(@"loading over");
    [HUD removeFromSuperview];
    HUD = nil;
}

//蓝牙状态delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            [self.centralMgr scanForPeripheralsWithServices:nil options:nil];
            NSLog(@"蓝牙打开，开始搜索蓝牙");
            break;
        default:
            NSLog(@"蓝牙状态改变");
            NSDictionary *dic = @{
                                  @"ConnectState":@"NO",
                                  @"LockState":@"",
                                  @"Batteryinfo":@"",
                                  @"Ring":@""
                                  };
            [self notifiction:dic forname:@"APPDelegate"];
            break;
    }
}

//发现设备delegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BLEInfo *discoveredBLEInfo = [[BLEInfo alloc] init];
    discoveredBLEInfo.discoveredPeripheral = peripheral;
    discoveredBLEInfo.rssi = RSSI;
    
    // update tableview
    [self saveBLE:discoveredBLEInfo];
}

//保存设备信息
- (BOOL)saveBLE:(BLEInfo *)discoveredBLEInfo
{
    for (BLEInfo *info in self.arrayBLE)
    {
        if ([info.discoveredPeripheral.identifier.UUIDString isEqualToString:discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString])
        {
            return NO;
        }
    }
    if ([discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString isEqualToString:[CHKeychain load:@"LOCKUUID"]])
    {
        NSLog(@"发现配对的锁");
        _discoveredPeripheral=discoveredBLEInfo.discoveredPeripheral;
        
        [self alertConnetionTips];
    }

    //NSLog(@"\n发现新的蓝牙设备!\n");
    //NSLog(@"BLEInfo\n UUID：%@\n RSSI:%@\n\n",discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString,discoveredBLEInfo.rssi);
    
    //保存devices到self.arrayBLE
    [self.arrayBLE addObject:discoveredBLEInfo];
    return YES;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral : %@", error.localizedDescription);
    NSDictionary *dic = @{
                          @"ConnectState":@"NO",
                          @"LockState":@"",
                          @"Batteryinfo":@"",
                          @"Ring":@""
                          };
    [self notifiction:dic forname:@"APPDelegate"];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"已经连接设备");
    [self.arrayServices removeAllObjects];
    [_discoveredPeripheral setDelegate:self];
    [_discoveredPeripheral discoverServices:nil];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverServices : %@", [error localizedDescription]);
        return;
    }
    
    for (CBService *s in peripheral.services)
    {
        //NSLog(@"Service found with UUID : %@", s.UUID);
        //搜索该service里的character
        [s.peripheral discoverCharacteristics:nil forService:s];
        //保存services到self.arrayServices
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{@"ServiceDescription":s.UUID.description}];
        [self.arrayServices addObject:dic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverCharacteristicsForService error : %@", [error localizedDescription]);
        return;
    }
    
     for (CBCharacteristic *c in service.characteristics)
     {
         //NSLog(@"Characteristic found with UUID: %@ inService UUID：%@", c.UUID,service.UUID);
         
         //FFF1特征：发送数据控制硬件端
         if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFE9"]]){
             _writeCharacteristic = c;
             NSLog(@"找到Write Characteristic : %@", c.UUID);
            [self writeToPeripheral:[NSString stringWithFormat:@"dong14:newuser:%@\r\n",_PhoneUUID]];
            [self writeToPeripheral:[NSString stringWithFormat:@"dong14:newuser:%@\r\n",_PhoneUUID]];
         }
         
         //FFF6特征：广播
         if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFE4"]]){
             NSLog(@"找到notify Characteristic : %@", c.UUID);
             [_discoveredPeripheral setNotifyValue:YES forCharacteristic:c];
         }
     }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didUpdateValueForCharacteristic error : %@", error.localizedDescription);
        return;
    }
    //NSLog(@"Notify:this Character with UUID %@ value is:%@",characteristic.UUID,characteristic.value);
    NSString *getvalue=[[NSString alloc]initWithData:characteristic.value encoding:NSASCIIStringEncoding];
    NSLog(@"Notify Value is %@",getvalue);
    
    NSDictionary *dic = @{
                          @"ConnectState":@"YES",
                          @"LockState":_LockState?_LockState:@"",
                          @"Batteryinfo":_Batteryinfo?_Batteryinfo:@"",
                          @"Ring":_Ring?_Ring:@""
                          };
    [self notifiction:dic forname:@"APPDelegate"];
    [HUD hide:YES];

    /*
    NSArray *list=[getvalue componentsSeparatedByString:@":"];
    NSString *flag=list[0];
    NSString *cmd=list[1];
    NSString *cmdvalue=list[2];
    if ([flag isEqualToString:@"dong14"]) {
        if ([cmd isEqualToString:@""]) {
            
        }
        if ([cmd isEqualToString:@""]) {
            
        }
        if ([cmd isEqualToString:@""]) {
            
        }
    }*/
}


//向peripheral中写入数据
- (void)writeToPeripheral:(NSString *)string{
    if(!_writeCharacteristic){
        NSLog(@"writeCharacteristic is nil!");
        return;
    }
    
    NSData* value = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"Witedata: %@",value);
    
    [_discoveredPeripheral writeValue:value forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"write value success : %@", characteristic);
}

-(void)notifiction:(NSDictionary *)dic forname:(NSString *)name{
    NSLog(@"发送通知");
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:dic];
}

-(void)Notifictiontodo:(NSNotification*)notification
{
    NSLog(@"接收到通知:%@",[notification userInfo]);
    NSString *Operation;
    if([[notification userInfo] objectForKey:@"LOCKUUID"]){
        _LockUUID=[[notification userInfo] objectForKey:@"LOCKUUID"];
        NSLog(@"收到锁的信息:%@",_LockUUID);
    }
    if ([[notification userInfo] objectForKey:@"Operation"]) {
        Operation=[[notification userInfo] objectForKey:@"Operation"];
        if([Operation isEqualToString:@"CONNECT"]){
            [self connectingDiscover];
            NSLog(@"收到连接指令");
        }
        if([Operation isEqualToString:@"OPEN"]){
            [self writeToPeripheral:[NSString stringWithFormat:@"dong14:open:%@\r\n",_PhoneUUID]];
            NSLog(@"收到开锁指令");
        }
        if([Operation isEqualToString:@"CLOSE"]){
            [self writeToPeripheral:[NSString stringWithFormat:@"dong14:close:%@\r\n",_PhoneUUID]];
            NSLog(@"收到关锁指令");
        }
    }
}
@end
