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

#define peripheralUUID @"CE01C79E-B3BC-F8D9-DD85-ADFECAA7EA8A"
#define UUIDKEY @"UUID"
@interface AppDelegate ()

@property BOOL isFirstusing;
@property NSTimer *updatetimer;
@property int sendindex;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //看是否第一次登陆
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"Didused"]){
        _isFirstusing=NO;
    }else{
        _isFirstusing=YES;
    }
    
    if(_isFirstusing==YES){
        FirstpageViewController *FPVC=[[FirstpageViewController alloc]init];
        self.window.rootViewController = FPVC;
    }else{
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
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self connectingDiscover];
    [self uuid];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark--获取设备UUID
-(NSString*)uuid{
    if ([CHKeychain load:UUIDKEY]) {
        NSString *result = [CHKeychain load:UUIDKEY];
        NSLog(@"已经存在UUID：%@",result);
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
        NSLog(@"初次创建UUID：%@",result);
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
        [_centralMgr connectPeripheral:_discoveredPeripheral options:nil];
    }
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
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"未连接" forKey:@"State"];
            [self notifiction:dictionary forname:@"APPDelegate"];
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
    if ([discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString isEqualToString:peripheralUUID])
    {
        NSLog(@"correct product,connectPeripheral");
        _discoveredPeripheral=discoveredBLEInfo.discoveredPeripheral;
        [self alertConnetionTips];
    }

    NSLog(@"\n发现新的蓝牙设备!\n");
    NSLog(@"BLEInfo\n UUID：%@\n RSSI:%@\n\n",discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString,discoveredBLEInfo.rssi);
    
    //保存devices到self.arrayBLE
    [self.arrayBLE addObject:discoveredBLEInfo];
    return YES;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral : %@", error.localizedDescription);
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"未连接" forKey:@"State"];
    [self notifiction:dictionary forname:@"APPDelegate"];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"已经连接设备");
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"已连接" forKey:@"State"];
    [self notifiction:dictionary forname:@"APPDelegate"];
    
    [self.arrayServices removeAllObjects];
    [_discoveredPeripheral setDelegate:self];
    //查找服务
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
             //[self performSelector:@selector(settimer) withObject:nil afterDelay:5];
         }
         
         //FFF6特征：广播
         if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFE4"]]){
             NSLog(@"找到notify Characteristic : %@", c.UUID);
             //[_discoveredPeripheral setNotifyValue:YES forCharacteristic:c];
         }
     }
}

-(void)settimer{
    //self.updatetimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(todisplaydata) userInfo:nil repeats:YES];
}


-(void)todisplaydata{
    _sendindex++;
    [self writeToPeripheral:[NSString stringWithFormat:@"HELLO_%d\r\n",_sendindex]];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didUpdateValueForCharacteristic error : %@", error.localizedDescription);
        return;
    }
    NSLog(@"Notify:this Character with UUID %@ value is:%@",characteristic.UUID,characteristic.value);
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

-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}


-(void)notifiction:(NSDictionary *)dic forname:(NSString *)name{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:dic];
}
@end
